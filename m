Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx3-rdu2.redhat.com ([66.187.233.73]:49224 "EHLO mx1.redhat.com"
        rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
        id S1751527AbeEBSZX (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Wed, 2 May 2018 14:25:23 -0400
Received: from smtp.corp.redhat.com (int-mx06.intmail.prod.int.rdu2.redhat.com [10.11.54.6])
        (using TLSv1.2 with cipher AECDH-AES256-SHA (256/256 bits))
        (No client certificate requested)
        by mx1.redhat.com (Postfix) with ESMTPS id E319042AC379
        for <linux-nfs@vger.kernel.org>; Wed,  2 May 2018 18:25:22 +0000 (UTC)
Subject: Re: [PATCH 6/7] nfs-utils: Add nfsconftool cli
To: Justin Mitchell <jumitche@redhat.com>,
        Linux NFS Mailing list <linux-nfs@vger.kernel.org>
References: <1524496788.7418.2.camel@redhat.com>
 <1524497665.7418.10.camel@redhat.com>
From: Steve Dickson <SteveD@RedHat.com>
Message-ID: <5d630e48-bebf-528c-0f47-a50e5393aa84@RedHat.com>
Date: Wed, 2 May 2018 14:25:22 -0400
MIME-Version: 1.0
In-Reply-To: <1524497665.7418.10.camel@redhat.com>
Content-Type: text/plain; charset=utf-8
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>



On 04/23/2018 11:34 AM, Justin Mitchell wrote:
> This tool uses the conffile facilities to allow commandline
> querying of configuration settings and to dump the current
> config for diagnosis and testing
> 
> Signed-off-by: Justin Mitchell <jumitche@redhat.com>
> ---
>  Makefile.am                |   2 +-
>  configure.ac               |   1 +
>  tools/Makefile.am          |   2 +
>  tools/nfsconf/Makefile.am  |   9 +++
>  tools/nfsconf/nfsconfcli.c | 144 +++++++++++++++++++++++++++++++++++++++++++++
>  5 files changed, 157 insertions(+), 1 deletion(-)
>  create mode 100644 tools/nfsconf/Makefile.am
>  create mode 100644 tools/nfsconf/nfsconfcli.c
> 
> diff --git a/Makefile.am b/Makefile.am
> index e1f39aa..0022084 100644
> --- a/Makefile.am
> +++ b/Makefile.am
> @@ -2,7 +2,7 @@
>  
>  AUTOMAKE_OPTIONS = foreign
>  
> -SUBDIRS = tools support utils linux-nfs tests systemd
> +SUBDIRS = support tools utils linux-nfs tests systemd
>  
>  MAINTAINERCLEANFILES = Makefile.in
>  
> diff --git a/configure.ac b/configure.ac
> index 5a11636..b925666 100644
> --- a/configure.ac
> +++ b/configure.ac
> @@ -616,6 +616,7 @@ AC_CONFIG_FILES([
>  	tools/rpcgen/Makefile
>  	tools/mountstats/Makefile
>  	tools/nfs-iostat/Makefile
> +	tools/nfsconf/Makefile
>  	utils/Makefile
>  	utils/blkmapd/Makefile
>  	utils/nfsdcltrack/Makefile
> diff --git a/tools/Makefile.am b/tools/Makefile.am
> index f2ce282..4266da4 100644
> --- a/tools/Makefile.am
> +++ b/tools/Makefile.am
> @@ -6,6 +6,8 @@ if CONFIG_RPCGEN
>  OPTDIRS += rpcgen
>  endif
>  
> +OPTDIRS += nfsconf
> +
>  SUBDIRS = locktest rpcdebug nlmtest mountstats nfs-iostat $(OPTDIRS)
>  
>  MAINTAINERCLEANFILES = Makefile.in
> diff --git a/tools/nfsconf/Makefile.am b/tools/nfsconf/Makefile.am
> new file mode 100644
> index 0000000..4baaa26
> --- /dev/null
> +++ b/tools/nfsconf/Makefile.am
> @@ -0,0 +1,9 @@
> +## Process this file with automake to produce Makefile.in
> +
> +bin_PROGRAMS = nfsconftool
> +
> +nfsconftool_SOURCES = nfsconfcli.c
> +nfsconftool_LDADD = ../../support/nfs/libnfsconf.la
> +
> +MAINTAINERCLEANFILES = Makefile.in
> +
> diff --git a/tools/nfsconf/nfsconfcli.c b/tools/nfsconf/nfsconfcli.c
> new file mode 100644
> index 0000000..1443e97
> --- /dev/null
> +++ b/tools/nfsconf/nfsconfcli.c
> @@ -0,0 +1,144 @@
> +#include <stdlib.h>
> +#include <unistd.h>
> +#include <stdio.h>
> +#include <getopt.h>
> +#include <string.h>
> +#include <errno.h>
> +#include "config.h"
> +#include "conffile.h"
> +#include "xlog.h"
> +
> +typedef enum {
> +	MODE_NONE,
> +	MODE_GET,
> +	MODE_ISSET,
> +	MODE_DUMP
> +} confmode_t;
> +
> +static void usage(const char *name)
> +{
> +	fprintf(stderr, "Usage: %s [-v] [--file filename.conf] ...\n", name);
> +	fprintf(stderr, "Options:\n");
> +	fprintf(stderr, " -v			Increase Verbosity\n");
> +	fprintf(stderr, " --file filename.conf	Load this config file\n");
> +	fprintf(stderr, "     (Default config file: " NFS_CONFFILE "\n");
> +	fprintf(stderr, "Modes:\n");
> +	fprintf(stderr, "  --dump [outputfile]\n");
> +	fprintf(stderr, "      Outputs the configuration to the named file\n");
> +	fprintf(stderr, "  --get [--arg subsection] {section} {tag}\n");
> +	fprintf(stderr, "      Output one specific config value\n");
> +	fprintf(stderr, "  --isset [--arg subsection] {section} {tag}\n");
> +	fprintf(stderr, "      Return code indicates if config value is present\n");
> +}
> +
> +int main(int argc, char **argv)
> +{
> +	const char * val;
> +	char * confpath = NFS_CONFFILE;
> +	char * arg = NULL;
> +	int verbose=0;
> +	int ret = 0;
> +	char * dumpfile = NULL;
> +
> +	confmode_t mode = MODE_NONE;
> +
> +	while (1) {
> +		int c;
> +		int index = 0;
> +		struct option long_options[] = {
> +			{"get",		no_argument, 0, 'g' },
> +			{"arg",	  required_argument, 0, 'a' },
> +			{"isset", 	no_argument, 0, 'i' },
> +			{"dump",  optional_argument, 0, 'd' },
> +			{"file",  required_argument, 0, 'f' },
> +			{"verbose",	no_argument, 0, 'v' },
> +			{NULL,			  0, 0, 0 }
> +		};
> +
> +		c = getopt_long(argc, argv, "ga:id::f:v", long_options, &index);
> +		if (c == -1) break;
> +
> +		switch (c) {
> +			case 0:
> +				break;
> +			case 'f':
> +				confpath = optarg;
> +				break;
> +			case 'a':
> +				arg = optarg;
> +				break;
> +			case 'v':
> +				verbose++;
> +				break;
> +			case 'g':
> +				mode = MODE_GET;
> +				break;
> +			case 'i':
> +				mode = MODE_ISSET;
> +				break;
> +			case 'd':
> +				if (optarg==NULL && argv[optind]!=NULL && argv[optind][0]!='-')
> +					optarg = argv[optind++];
> +				mode = MODE_DUMP;
> +				dumpfile = optarg;
> +				break;
> +			default:
> +				usage(argv[0]);
> +				return 1;
> +		}
> +	}
> +
> +	if (verbose) xlog_config(D_ALL, 1);
New line please.. 
> +	xlog_stderr(1);
> +	xlog_syslog(0);
> +	xlog_open("nfsconf");
> +
> +	if (mode == MODE_NONE) {
> +		fprintf(stderr, "Error: No MODE selected.\n");
> +		usage(argv[0]);
> +		return 1;
> +	}
> +
> +	if (conf_init_file(confpath)) {
> +		if (verbose || mode != MODE_ISSET) fprintf(stderr, "Error loading config file %s\n", confpath);
> +		if (mode != MODE_ISSET) return 1;
> +	}
> +
> +	if (mode == MODE_DUMP) {
> +		FILE *out = stdout;
Declarations up to[ please... and I don't understand why this assignment is even needed
 
> +		if (dumpfile) {
> +			if ((out=fopen(dumpfile, "w"))==NULL) {
> +				fprintf(stderr, "Error opening dumpfile %s: %s\n", dumpfile, strerror(errno));
> +				ret = 2;
> +				goto cleanup;
> +			}
> +			if (verbose) printf("Dumping config to %s\n", dumpfile);
> +		}
> +		conf_report(out);
> +		if (dumpfile) fclose(out);
closing stdout??

> +	} else
> +	if (mode == MODE_GET || mode == MODE_ISSET) {
> +		if (optind+1 >= argc) {
> +			fprintf(stderr, "Error: insufficient arguments for mode\n");
> +			usage(argv[0]);
> +			ret = 2;
> +			goto cleanup;
> +		}
> +		char * section = argv[optind++];
> +		char * tag = argv[optind++];
Up top please... 
> +
> +		if ((val=conf_get_section(section, arg, tag))!=NULL) {
> +			if (mode == MODE_GET) printf("%s\n", val);
> +		} else {
> +			if (mode == MODE_GET && verbose) fprintf(stderr, "Tag '%s' not found\n", tag);
> +			ret = 1;
> +		}
There is a lot going on here... having a few newlines and spacing would help a lot.

steved.
> +	} else {
> +		fprintf(stderr, "Mode not yet implimented.\n");
> +		ret = 2;
> +	}
> +
> +cleanup:
> +	conf_cleanup();
> +	return ret;
> +}
> 
