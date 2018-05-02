Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx3-rdu2.redhat.com ([66.187.233.73]:58758 "EHLO mx1.redhat.com"
        rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
        id S1750925AbeEBSVl (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Wed, 2 May 2018 14:21:41 -0400
Received: from smtp.corp.redhat.com (int-mx04.intmail.prod.int.rdu2.redhat.com [10.11.54.4])
        (using TLSv1.2 with cipher AECDH-AES256-SHA (256/256 bits))
        (No client certificate requested)
        by mx1.redhat.com (Postfix) with ESMTPS id E6DC48D774
        for <linux-nfs@vger.kernel.org>; Wed,  2 May 2018 18:21:40 +0000 (UTC)
Subject: Re: [PATCH 2/7] nfs-utils: Make config includes relative to current
 config
To: Justin Mitchell <jumitche@redhat.com>,
        Linux NFS Mailing list <linux-nfs@vger.kernel.org>
References: <1524496788.7418.2.camel@redhat.com>
 <1524497125.7418.5.camel@redhat.com>
From: Steve Dickson <SteveD@RedHat.com>
Message-ID: <6f363a98-479a-8d7e-cbd5-bd5d7248f41d@RedHat.com>
Date: Wed, 2 May 2018 14:21:40 -0400
MIME-Version: 1.0
In-Reply-To: <1524497125.7418.5.camel@redhat.com>
Content-Type: text/plain; charset=utf-8
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Hi Justin,

Sorry for taking so long to get to this... 

Most of my comments is about the style you are using.

I would like to keep the coding style somewhat the same 
and in a few places that is not just not happening...

On 04/23/2018 11:25 AM, Justin Mitchell wrote:
> When including additional config files with the include directive
> make relative paths be relative to the current config file instead
> of to the process's cwd.
> 
> Signed-off-by: Justin Mitchell <jumitche@redhat.com>
> ---
>  support/nfs/conffile.c | 50 +++++++++++++++++++++++++++++++++++++++++---------
>  1 file changed, 41 insertions(+), 9 deletions(-)
> 
> diff --git a/support/nfs/conffile.c b/support/nfs/conffile.c
> index a4cc236..42c0913 100644
> --- a/support/nfs/conffile.c
> +++ b/support/nfs/conffile.c
> @@ -49,6 +49,7 @@
>  #include <errno.h>
>  #include <err.h>
>  #include <syslog.h>
> +#include <libgen.h>
>  
>  #include "conffile.h"
>  #include "xlog.h"
> @@ -60,7 +61,7 @@ static char * conf_readfile(const char *path);
>  static int conf_set(int , const char *, const char *, const char *, 
>  	const char *, int , int );
>  static void conf_parse(int trans, char *buf, 
> -	char **section, char **subsection);
> +	char **section, char **subsection, const char *filename);
>  
>  struct conf_trans {
>  	TAILQ_ENTRY (conf_trans) link;
> @@ -206,12 +207,40 @@ conf_set_now(const char *section, const char *arg, const char *tag,
>  	return 0;
>  }
>  
> +/* Attempt to construct a relative path to the new file */
> +static char *
> +relative_path(const char *oldfile, const char *newfile)
> +{
> +	char * tmpcopy = NULL;
> +	char * dir = NULL;
> +	char * relpath = NULL;
The space between the '*' and variable is not need.
 
> +
> +	if (!newfile) return strdup(oldfile);
> +	if (newfile[0] == '/') return strdup(newfile);
Go a head a put a newline and tab after the if statement.

> +
> +	tmpcopy = strdup(oldfile);
> +	if (!tmpcopy) goto mem_err;
> +
> +	dir = dirname(tmpcopy);
> +	size_t pathlen =  strlen(dir)+strlen(newfile)+2;
> +	relpath = calloc(1, pathlen);
> +	if (!relpath) goto mem_err;
> +	snprintf(relpath, pathlen, "%s/%s", dir, newfile);
Same here... That is just hard to read IMHO...

Also put all variable at the top of the routine. 

 
> +
> +	free(tmpcopy);
> +	return relpath;
> +mem_err:
> +	if (tmpcopy) free(tmpcopy);
> +	return NULL;
> +}
> +
> +
>  /*
>   * Parse the line LINE of SZ bytes.  Skip Comments, recognize section
>   * headers and feed tag-value pairs into our configuration database.
>   */
>  static void
> -conf_parse_line(int trans, char *line, int lineno, char **section, char **subsection)
> +conf_parse_line(int trans, char *line, const char *filename, int lineno, char **section, char **subsection)
>  {
>  	char *val, *ptr;
>  
> @@ -366,10 +395,12 @@ conf_parse_line(int trans, char *line, int lineno, char **section, char **subsec
>  
>  	if (strcasecmp(line, "include")==0) {
>  		/* load and parse subordinate config files */
> -		char * subconf = conf_readfile(val);
> +		char * relpath = relative_path(filename, val);
> +		char * subconf = conf_readfile(relpath);
Same here no space also isn't subconf being over written?

>  		if (subconf == NULL) {
> -			xlog_warn("config file error: line %d: "
> -			"error loading included config", lineno);
> +			xlog_warn("%s:%d: error loading included config %s", 
> +				  filename, lineno, relpath);
> +			if (relpath) free(relpath);
>  			return;
>  		}
>  
> @@ -383,10 +414,11 @@ conf_parse_line(int trans, char *line, int lineno, char **section, char **subsec
>  				inc_subsection = strdup(*subsection);
>  		}
>  
> -		conf_parse(trans, subconf, &inc_section, &inc_subsection);
> +		conf_parse(trans, subconf, &inc_section, &inc_subsection, relpath);
>  
>  		if (inc_section) free(inc_section);
>  		if (inc_subsection) free(inc_subsection);
> +		if (relpath) free(relpath);
Are these if even needed? Won't these either be NULL or allocated memory?

Again... I'm trying to is keep the coding similar which hopefully
will make the code easier to read...
 
>  		free(subconf);
>  	} else {
>  		/* XXX Perhaps should we not ignore errors?  */
> @@ -396,7 +428,7 @@ conf_parse_line(int trans, char *line, int lineno, char **section, char **subsec
>  
>  /* Parse the mapped configuration file.  */
>  static void
> -conf_parse(int trans, char *buf, char **section, char **subsection)
> +conf_parse(int trans, char *buf, char **section, char **subsection, const char *filename)
>  {
>  	char *cp = buf;
>  	char *bufend = NULL;
> @@ -413,7 +445,7 @@ conf_parse(int trans, char *buf, char **section, char **subsection)
>  			else {
>  				*cp = '\0';
>  				lineno++;
> -				conf_parse_line(trans, line, lineno, section, subsection);
> +				conf_parse_line(trans, line, filename, lineno, section, subsection);
>  				line = cp + 1;
>  			}
>  		}
> @@ -508,7 +540,7 @@ conf_load_file(const char *conf_file)
>  	/* Parse config contents into the transaction queue */
>  	char *section = NULL;
>  	char *subsection = NULL;
> -	conf_parse(trans, conf_data, &section, &subsection);
> +	conf_parse(trans, conf_data, &section, &subsection, conf_file);
>  	if (section) free(section);
>  	if (subsection) free(subsection);
Same here...

steved.
>  	free(conf_data);
> 
