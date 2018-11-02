workflow accession {
	String metadata_outputs_path
	String dcc_server
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
			metadata = metadata,
			steps = steps,
			server = dcc_server
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
		Array[File] metadata_jsons = glob("json_files/*.json")
	}
}

task accession_metadata {
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
			${"--accession-output " + write_json(steps)} \
			${"--server " + server}
		rm ${credentials}
		rm ${dcc_credentials}
	}

	output {
		String log = read_string(stdout())
	}
}