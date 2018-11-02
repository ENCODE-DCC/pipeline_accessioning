workflow accession {
	String metadata_outputs_path
	File google_credentials

	call filter_outputs { input :
		credentials = google_credentials,
		filter_path = metadata_outputs_path
	}

	Array[File] metadata_jsons_ = filter_outputs.metadata_jsons

	scatter(metadata in metadata_jsons_) {

		call accession_metadata { input :
			credentials = google_credentials,
			metadata = metadata
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
		Array[File] metadata_jsons = glob("/tmp/*.log")
	}
}


task accession_metadata {
	File metadata
	File credentials

	command {
		ls ${metadata}
	}

	output {
		String log = read_string(stdout())
	}
}