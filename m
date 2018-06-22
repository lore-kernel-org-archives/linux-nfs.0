Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from aserp2120.oracle.com ([141.146.126.78]:36226 "EHLO
        aserp2120.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S934153AbeFVDTE (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Thu, 21 Jun 2018 23:19:04 -0400
Cc: calum.mackay@oracle.com, Steve Dickson <steved@redhat.com>
Subject: Re: [PATCH 5/5] nfs-utils: Add config setting to nfsconf cli tool
To: Justin Mitchell <jumitche@redhat.com>,
        Linux NFS Mailing list <linux-nfs@vger.kernel.org>
References: <1529496583.7473.8.camel@redhat.com>
 <1529496853.7473.13.camel@redhat.com>
From: Calum Mackay <calum.mackay@oracle.com>
Message-ID: <e6d15961-2381-8212-253d-6e970587f862@oracle.com>
Date: Fri, 22 Jun 2018 04:18:47 +0100
MIME-Version: 1.0
In-Reply-To: <1529496853.7473.13.camel@redhat.com>
Content-Type: text/plain; charset=utf-8; format=flowed
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

hi Justin, it's not a part of your patch, but I noticed a tiny typo: see 
below.

On 20/06/2018 1:14 pm, Justin Mitchell wrote:
> Use the new conf_write() function to add setting and
> unsetting of config file values to the cli tool
> 
> Signed-off-by: Justin Mitchell <jumitche@redhat.com>
> ---
>   tools/nfsconf/nfsconf.man  | 26 ++++++++++++++++
>   tools/nfsconf/nfsconfcli.c | 75 +++++++++++++++++++++++++++++++++++++++-------
>   2 files changed, 90 insertions(+), 11 deletions(-)
> 
> diff --git a/tools/nfsconf/nfsconf.man b/tools/nfsconf/nfsconf.man
> index 5b5e914..197caae 100644
> --- a/tools/nfsconf/nfsconf.man
> +++ b/tools/nfsconf/nfsconf.man
> @@ -28,6 +28,25 @@ nfsconf \- Query various NFS configuration settings
>   .IR subsection ]
>   .IR section
>   .IR tag
> +.P
> +.B nfsconf \-\-set
> +.RB [ \-v | \-\-verbose ]
> +.RB [ \-f | \-\-file
> +.IR infile.conf ]
> +.RB [ \-a | \-\-arg
> +.IR subsection ]
> +.IR section
> +.IR tag
> +.IR value
> +.P
> +.B nfsconf \-\-unset
> +.RB [ \-v | \-\-verbose ]
> +.RB [ \-f | \-\-file
> +.IR infile.conf ]
> +.RB [ \-a | \-\-arg
> +.IR subsection ]
> +.IR section
> +.IR tag
>   .SH DESCRIPTION
>   The
>   .B nfsconf
> @@ -41,6 +60,10 @@ Output an alphabetically sorted dump of the current configuration in conf file f
>   Test if a specific tag has a value set.
>   .IP "\fB\-g, \-\-get\fP"
>   Output the current value of the specified tag.
> +.IP "\fB\-s, \-\-set\fP"
> +Update or Add a tag and value to the config file, creating the file if necessary.
> +.IP "\fB\-u, \-\-unset\fP"
> +Remove the specified tag and its value from the config file.
>   .SH OPTIONS
>   .SS Options valid in all modes
>   .TP
> @@ -69,6 +92,9 @@ The tool allows for easy testing of configuration values from shell scripts, her
>   .TP
>   .B nfsconf --file /etc/nfsmount.conf --get --arg /home MountPoint background
>   Show default value for \fIbackground\fR option for NFS mounts of the \fI/home\fR path.
> +.TP
> +.B nfsconf --file /etc/nfs.conf --set nfsd debug 1
> +Enable debugging in nfsd
>   .SH FILES
>   .TP
>   .B /etc/nfs.conf
> diff --git a/tools/nfsconf/nfsconfcli.c b/tools/nfsconf/nfsconfcli.c
> index 034ec51..b5cb132 100644
> --- a/tools/nfsconf/nfsconfcli.c
> +++ b/tools/nfsconf/nfsconfcli.c
> @@ -12,7 +12,9 @@ typedef enum {
>   	MODE_NONE,
>   	MODE_GET,
>   	MODE_ISSET,
> -	MODE_DUMP
> +	MODE_DUMP,
> +	MODE_SET,
> +	MODE_UNSET
>   } confmode_t;
>   
>   static void usage(const char *name)
> @@ -29,11 +31,14 @@ static void usage(const char *name)
>   	fprintf(stderr, "      Output one specific config value\n");
>   	fprintf(stderr, "  --isset [--arg subsection] {section} {tag}\n");
>   	fprintf(stderr, "      Return code indicates if config value is present\n");
> +	fprintf(stderr, "  --set [--arg subsection] {section} {tag} {value}\n");
> +	fprintf(stderr, "      Set and Write a config value\n");
> +	fprintf(stderr, "  --unset [--arg subsection] {section} {tag}\n");
> +	fprintf(stderr, "      Remove an existing config value\n");
>   }
>   
>   int main(int argc, char **argv)
>   {
> -	const char * val;
>   	char * confpath = NFS_CONFFILE;
>   	char * arg = NULL;
>   	int verbose=0;
> @@ -47,6 +52,8 @@ int main(int argc, char **argv)
>   		int index = 0;
>   		struct option long_options[] = {
>   			{"get",		no_argument, 0, 'g' },
> +			{"set",		no_argument, 0, 's' },
> +			{"unset",	no_argument, 0, 'u' },
>   			{"arg",	  required_argument, 0, 'a' },
>   			{"isset", 	no_argument, 0, 'i' },
>   			{"dump",  optional_argument, 0, 'd' },
> @@ -55,7 +62,7 @@ int main(int argc, char **argv)
>   			{NULL,			  0, 0, 0 }
>   		};
>   
> -		c = getopt_long(argc, argv, "ga:id::f:v", long_options, &index);
> +		c = getopt_long(argc, argv, "gsua:id::f:v", long_options, &index);
>   		if (c == -1) break;
>   
>   		switch (c) {
> @@ -75,6 +82,12 @@ int main(int argc, char **argv)
>   			case 'g':
>   				mode = MODE_GET;
>   				break;
> +			case 's':
> +				mode = MODE_SET;
> +				break;
> +			case 'u':
> +				mode = MODE_UNSET;
> +				break;
>   			case 'i':
>   				mode = MODE_ISSET;
>   				break;
> @@ -105,14 +118,18 @@ int main(int argc, char **argv)
>   		return 1;
>   	}
>   
> -	if (conf_init_file(confpath)) {
> -		/* config file was missing or had an error, warn about it */
> -		if (verbose || mode != MODE_ISSET)
> -			fprintf(stderr, "Error loading config file %s\n",
> -				confpath);
> -		/* this isnt fatal for --isset */
> -		if (mode != MODE_ISSET)
> -			return 1;
> +	if (mode != MODE_SET && mode != MODE_UNSET) {
> +		if (conf_init_file(confpath)) {
> +			/* config file was missing or had an error, warn about it */
> +			if (verbose || mode != MODE_ISSET) {
> +				fprintf(stderr, "Error loading config file %s\n",
> +					confpath);
> +			}
> +
> +			/* this isnt fatal for --isset */
> +			if (mode != MODE_ISSET)
> +				return 1;
> +		}
>   	}
>   
>   	/* --dump mode, output the current configuration */
> @@ -144,6 +161,7 @@ int main(int argc, char **argv)
>   	if (mode == MODE_GET || mode == MODE_ISSET) {
>   		char * section = NULL;
>   		char * tag = NULL;
> +		const char * val;
>   
>   		/* test they supplied section and tag names */
>   		if (optind+1 >= argc) {
> @@ -169,6 +187,41 @@ int main(int argc, char **argv)
>   				fprintf(stderr, "Tag '%s' not found\n", tag);
>   			ret = 1;
>   		}
> +	} else
> +	if (mode == MODE_SET || mode == MODE_UNSET) {
> +		char * section = NULL;
> +		char * tag = NULL;
> +		char * val = NULL;
> +		int need = 2;
> +
> +		if (mode == MODE_UNSET)
> +			need = 1;
> +
> +		/* test they supplied section and tag names */
> +		if (optind+need >= argc) {
> +			fprintf(stderr, "Error: insufficient arguments for mode\n");
> +			usage(argv[0]);
> +			ret = 2;
> +			goto cleanup;
> +		}
> +
> +		/* now we have a section and tag name */
> +		section = argv[optind++];
> +		tag = argv[optind++];
> +		if (mode == MODE_SET)
> +			val = argv[optind++];
> +
> +		/* setting an empty string is same as unsetting */
> +		if (val!=NULL && *val == '\0') {
> +			mode = MODE_UNSET;
> +			val = NULL;
> +		}
> +
> +		if (conf_write(confpath, section, arg, tag, val)) {
> +			if (verbose)
> +				fprintf(stderr, "Error writing config\n");
> +			ret = 1;
> +		}
>   	} else {
>   		fprintf(stderr, "Mode not yet implimented.\n");

-> implemented

>   		ret = 2;
> 

