workflow accession {
	String lab
	String award
	String dcc_server
	String metadata_outputs_path
	File google_credentials
	File dcc_credentials
	Array[Object] steps

	call filter_outputs { input :
		credentials = google_credentials,
		filter_path = metadata_outputs_path
	}

	scatter(metadata in filter_outputs.metadata_jsons) {
		call accession_metadata { input :
			credentials = google_credentials,
			dcc_credentials = dcc_credentials,
			metadata = metadata,
			steps = steps,
			server = dcc_server,
			lab = lab,
			award = award
		}
	}
}

task filter_outputs {
	String filter_path
	File credentials

	command {
		export GOOGLE_APPLICATION_CREDENTIALS=${credentials}
		mkdir json_files
		accession.py ${"--filter-from-path " + filter_path}
		rm ${credentials}
	}

	output {
		Array[File] metadata_jsons = glob("*.json")
	}
}

task accession_metadata {
	String lab
	String award
	String server
	File metadata
	File credentials
	File dcc_credentials
	Array[Object] steps


	command {
		export GOOGLE_APPLICATION_CREDENTIALS=${credentials}
		set -o allexport
		source ${dcc_credentials}
		set +o allexport
		accession.py \
			--accession-steps ${write_json(steps)} \
			${"--accession-metadata " + metadata} \
			${"--server " + server} \ 
			${"--lab " + lab} \
			${"--award " + award}
		rm ${credentials}
		rm ${dcc_credentials}
	}

	runtime {
		cpu : 1
		disks : "local-disk 150 HDD"
	}	


	output {
		String log = read_string(stdout())
		String log_err = read_string(stderr())
	}
}