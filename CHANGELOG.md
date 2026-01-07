# Changelog

## [1.5.1](https://github.com/MPUSP/snakemake-ont-basecalling/compare/v1.5.0...v1.5.1) (2025-12-03)


### Bug Fixes

* included minimum version checking of dorado ([e07ed75](https://github.com/MPUSP/snakemake-ont-basecalling/commit/e07ed753e88b200046f82be38f66dca2bb6607e9))
* linting issue. ([03e3848](https://github.com/MPUSP/snakemake-ont-basecalling/commit/03e38487dffc4efdc12901d974f40a4ddd086b82))
* remove hard coded version in print statement. ([99edfa2](https://github.com/MPUSP/snakemake-ont-basecalling/commit/99edfa28ba3c4a8ae48d2a48af27854d5f685227))
* run computationally non-demanding rules locally ([6e736f9](https://github.com/MPUSP/snakemake-ont-basecalling/commit/6e736f924bc9aef7388968c3a129ddc44d152b9d))
* solve linting issue due to version checking ([526e9ef](https://github.com/MPUSP/snakemake-ont-basecalling/commit/526e9eff857999f3c85b94697ad49819d34a7cee))
* treated extra param as being optional in simplex rule. ([fde1b56](https://github.com/MPUSP/snakemake-ont-basecalling/commit/fde1b563cb3b73a23f3921f545674433793c006a))
* updates to documentation of apptainer ([981a246](https://github.com/MPUSP/snakemake-ont-basecalling/commit/981a246129346e7c76aec5a48343d017e79de332))
* updates to documentation of apptainer, dorado version checking ([e1b4e70](https://github.com/MPUSP/snakemake-ont-basecalling/commit/e1b4e702bdf7f5395b45242ca5349389d3bae1a2))

## [1.5.0](https://github.com/MPUSP/snakemake-ont-basecalling/compare/v1.4.0...v1.5.0) (2025-11-28)


### Features

* added automatic apptainer deployment ([9a010c1](https://github.com/MPUSP/snakemake-ont-basecalling/commit/9a010c1ff6206b8119527838b779c7b4f9dd8090))
* added yaml for container deposition and corresponding image path ([de0b738](https://github.com/MPUSP/snakemake-ont-basecalling/commit/de0b73873127c53d32c6cca56c96fe46f3319f91))


### Bug Fixes

* adaptation to new output dir structure from dorado demux 1.3 ([e61bd78](https://github.com/MPUSP/snakemake-ont-basecalling/commit/e61bd786c3d9e243d6baebd837833a31126ca088))
* adjusted profile to work with latest slurm + executor ([7f0d415](https://github.com/MPUSP/snakemake-ont-basecalling/commit/7f0d4157cbefd13bafe6fb2fcfeeed3da128cdd0))
* formatting ([f736a27](https://github.com/MPUSP/snakemake-ont-basecalling/commit/f736a27bca4b26026e1080da0a4997d37107d88f))
* increase resources as new dorado/minION data require more ([297af7a](https://github.com/MPUSP/snakemake-ont-basecalling/commit/297af7a25e8e82b48ed16f538b1c6c017cfa8f89))
* remove 'slurm_extra' in slurm profile ([763cc39](https://github.com/MPUSP/snakemake-ont-basecalling/commit/763cc39e021c8db3642bb89f653825e7a4c00ef8))
* update dag ([c4328b2](https://github.com/MPUSP/snakemake-ont-basecalling/commit/c4328b2bbf8cba060237d00ff5483bdc6688eb74))

## [1.4.0](https://github.com/MPUSP/snakemake-ont-basecalling/compare/v1.3.0...v1.4.0) (2025-09-12)


### Features

* eliminated intermediate rule aggregate_prefix; closes [#25](https://github.com/MPUSP/snakemake-ont-basecalling/issues/25) ([5eb545e](https://github.com/MPUSP/snakemake-ont-basecalling/commit/5eb545ee9a719cd68dab6d0d200966923436d75c))
* various improvements to format and performance ([649f98d](https://github.com/MPUSP/snakemake-ont-basecalling/commit/649f98d37370732814790711a695d21068a4e4fc))


### Bug Fixes

* corrected urls to json schema ([d437061](https://github.com/MPUSP/snakemake-ont-basecalling/commit/d4370619829a3b48f4544853efd8cce1c8bb66fc))
* more fine grained slurm profile ([136efc6](https://github.com/MPUSP/snakemake-ont-basecalling/commit/136efc6ef6f30a02cd0104cfc97bd536b4b6382f))
* reformat file list to have new line sep ([e0899d3](https://github.com/MPUSP/snakemake-ont-basecalling/commit/e0899d344490a9c738d56c75dfe08e4838dfe3d0))

## [1.3.0](https://github.com/MPUSP/snakemake-ont-basecalling/compare/v1.2.2...v1.3.0) (2025-07-09)


### Features

* added functionality to switch demultiplexing off ([ccd7e4a](https://github.com/MPUSP/snakemake-ont-basecalling/commit/ccd7e4aa9fdcf366fb33d26db5a69f5520acf5fa))
* added params table ([93b9a9d](https://github.com/MPUSP/snakemake-ont-basecalling/commit/93b9a9d7d0141a3a52b6f435cb346b626c406d35))

## [1.2.2](https://github.com/MPUSP/snakemake-ont-basecalling/compare/v1.2.1...v1.2.2) (2025-06-25)


### Bug Fixes

* modified per rule resources for slurm ([#16](https://github.com/MPUSP/snakemake-ont-basecalling/issues/16)) ([a33ac11](https://github.com/MPUSP/snakemake-ont-basecalling/commit/a33ac1121ac6a151279279c3b68c4f208d628f76))

## [1.2.1](https://github.com/MPUSP/snakemake-ont-basecalling/compare/v1.2.0...v1.2.1) (2025-06-06)


### Bug Fixes

* added catalog config yml ([7b2b792](https://github.com/MPUSP/snakemake-ont-basecalling/commit/7b2b792c305cef87519103a7efce190a861d4e86))
* added linting test to github actions. ([77122be](https://github.com/MPUSP/snakemake-ont-basecalling/commit/77122be3ddb4ce65074b3c9373c52c212ff606cb))
* linting errors, e.g. added base conda envs ([221a5f0](https://github.com/MPUSP/snakemake-ont-basecalling/commit/221a5f05fe7fbecea254f29e1c61d4ba47c65b4a))
* minor changes to make workflow compatible with catalog ([8496556](https://github.com/MPUSP/snakemake-ont-basecalling/commit/8496556d3779146b8b8160d08db853fd460e65d0))

## [1.2.0](https://github.com/MPUSP/snakemake-ont-basecalling/compare/v1.1.0...v1.2.0) (2025-06-04)


### Features

* added nanoplot as second qc tool ([dcbebfd](https://github.com/MPUSP/snakemake-ont-basecalling/commit/dcbebfd96f281057a95880deaa2690671d62c16e))
* added schemas ([7804fc0](https://github.com/MPUSP/snakemake-ont-basecalling/commit/7804fc050f877158ad2a57a7ca7161a497f0a0a3))
* additions to docs, nanoplot qc, schemas ([0ac0f2e](https://github.com/MPUSP/snakemake-ont-basecalling/commit/0ac0f2e7eabaa06b3c36ed4dc6baa9718db8407e))


### Bug Fixes

* attempt to repair release please action, see https://github.com/googleapis/release-please-action/issues/1105 ([efeec85](https://github.com/MPUSP/snakemake-ont-basecalling/commit/efeec85584082fc0780433519160a0a054b30ae1))
* linting ([9e3e867](https://github.com/MPUSP/snakemake-ont-basecalling/commit/9e3e867043989cc035dd1f1b4ae76d77b89b20f8))
* only export report html using nanoplot. suppress exporting all plots seperately. ([02a28fa](https://github.com/MPUSP/snakemake-ont-basecalling/commit/02a28faa9aaa0968b904a90c1289cb04eba00460))
* qc tools dont support multiple cores ([71782f9](https://github.com/MPUSP/snakemake-ont-basecalling/commit/71782f9dcf6d72f2bb97f66a78ee2de9ba4a82e6))

## [1.1.0](https://github.com/MPUSP/snakemake-ont-basecalling/compare/v1.0.0...v1.1.0) (2025-05-27)


### Features

* add reporting tool pycoQC, closes [#3](https://github.com/MPUSP/snakemake-ont-basecalling/issues/3) ([bccff5c](https://github.com/MPUSP/snakemake-ont-basecalling/commit/bccff5cbcc8826b45c2d52da82a10fcc2055eda1), [cadb16e](https://github.com/MPUSP/snakemake-ont-basecalling/commit/cadb16e95a915f7abc2dfbd6e5d8064a801d571c))


## 1.0.0 (2025-05-22)


### Features

* add dorado basecalling and demultiplexing. ([b3a3f45](https://github.com/MPUSP/snakemake-ont-basecalling/commit/b3a3f45ad63741cf230cfacefeeceb5ccaf4ef61))
* add merging fastq files based on barcodes. ([c6e55ab](https://github.com/MPUSP/snakemake-ont-basecalling/commit/c6e55ab43b83ed56e0d0b10ee21e8b48db02ac44))
* add slurm example profiles; closes [#2](https://github.com/MPUSP/snakemake-ont-basecalling/issues/2) ([2734b81](https://github.com/MPUSP/snakemake-ont-basecalling/commit/2734b8195284267a133a45f9e29dfc118c68333c))
* add slurm profile ([b57f1d9](https://github.com/MPUSP/snakemake-ont-basecalling/commit/b57f1d9f5f43a7bfa87f46aa823aebcad1085577))
* added config readme, readme formatting, minor additions ([b2b5449](https://github.com/MPUSP/snakemake-ont-basecalling/commit/b2b5449cbf1d1656c0ef33ed36897412c104343f))
* added dorado summary and barcode extraction. ([083306b](https://github.com/MPUSP/snakemake-ont-basecalling/commit/083306bb1e0bebeb592ed6d2d7452e09ead3f79c))
* attempt to simplify file input and merging ([ebd4d08](https://github.com/MPUSP/snakemake-ont-basecalling/commit/ebd4d0810bab6e4b030706fe9d7d8801181a33e5))
* simplification of rules, output paths, fully functional merging ([4c52a16](https://github.com/MPUSP/snakemake-ont-basecalling/commit/4c52a16653d40942f6a3fcc950480650f5df746b))
* update to include merging and other workflow setup changes ([cf3a7e5](https://github.com/MPUSP/snakemake-ont-basecalling/commit/cf3a7e526827adba17094dfcf4c1f9a3c859b525))


### Bug Fixes

* added missing ref to summary ([a84fa72](https://github.com/MPUSP/snakemake-ont-basecalling/commit/a84fa7208aaf559cf0b4b727d0b4e819f9a130ce))
* barcode now supplied as single short hand ([10531cb](https://github.com/MPUSP/snakemake-ont-basecalling/commit/10531cb6f8ee4256e97abdcb39573e1ab6e6d5ac))
* CI issue with reporting. ([c0ff733](https://github.com/MPUSP/snakemake-ont-basecalling/commit/c0ff7332999b69baa66df5b2f632ab103f94b17d))
* example files now follow convention + matching regex ([c501ef0](https://github.com/MPUSP/snakemake-ont-basecalling/commit/c501ef0968ff9b3f2db20bcee0983312ad3e13e4))
* inference of number of barcodes from kit ([ed93e82](https://github.com/MPUSP/snakemake-ont-basecalling/commit/ed93e82303eb3f11c2433a05134cfdd0aec1f0a0))
* linting ([a19191a](https://github.com/MPUSP/snakemake-ont-basecalling/commit/a19191a254fffa482131573efa53c555812d1b05))
* linting error in slurm config. ([e38aaf9](https://github.com/MPUSP/snakemake-ont-basecalling/commit/e38aaf9e78bf01c3ec1cf3b457abb46575371037))
* minor style impprovements ([a50f261](https://github.com/MPUSP/snakemake-ont-basecalling/commit/a50f261c490733fc9d27994b7e8a2d69c33df8a8))
* removed linting rule from testing. ([b3f3c20](https://github.com/MPUSP/snakemake-ont-basecalling/commit/b3f3c20c51c2cd618ffd92392066bd61511cf599))
* removed redundant model dir ([de15045](https://github.com/MPUSP/snakemake-ont-basecalling/commit/de15045a0af590b972817533230c95c95d49d804))
* some formatting improvements ([faea15d](https://github.com/MPUSP/snakemake-ont-basecalling/commit/faea15d40f97e76b456b962977bd86799b8d9f94))
* switch to dry run for testing. ([d8c710f](https://github.com/MPUSP/snakemake-ont-basecalling/commit/d8c710f5d7a221948c485edaf1afc08736156478))
* updated profiles. ([1935180](https://github.com/MPUSP/snakemake-ont-basecalling/commit/1935180ac90366af3f1baeaf03636c2e4062e4f0))
