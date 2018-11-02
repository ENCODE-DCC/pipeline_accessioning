workflow accession {
	String metadata_outputs_path
	File google_credentials
	Array[Object] steps

	call filter_outputs { input :
		credentials = google_credentials,
		filter_path = metadata_outputs_path
	}

	scatter(metadata in filter_outputs.metadata_outputs) {

		call accession { input :
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
		accession.py ${"--filter-from-path" filter_path}
		cat filtered.txt | xargs -I % ln % filtered_out
	}

	output {
		Array[File] metadata_outputs = glob('filtered_out/*.json')
	}
}

task accession {
	File metadata
	File credentials

	command {}

	output {
		File logs = read_lines(stdout())
	}
}