From: Benny Halevy <bhalevy@panasas.com>
Subject: Re: [Patch 2/10] NFS Mount Configuration File (Vers 3)
Date: Fri, 07 Aug 2009 11:07:14 +0300
Message-ID: <4A7BE0B2.9010008@panasas.com>
References: <4A7B2324.9090406@RedHat.com> <4A7B23D2.6080900@RedHat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: Linux NFS Mailing list <linux-nfs@vger.kernel.org>,
	Linux NFSv4 mailing list <nfsv4@linux-nfs.org>
To: Steve Dickson <SteveD@redhat.com>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from ip67-152-220-66.z220-152-67.customer.algx.net ([67.152.220.66]:31051
	"EHLO daytona.int.panasas.com" rhost-flags-OK-OK-OK-FAIL)
	by vger.kernel.org with ESMTP id S1757043AbZHGIHP (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Fri, 7 Aug 2009 04:07:15 -0400
In-Reply-To: <4A7B23D2.6080900-AfCzQyP5zfLQT0dZR+AlfA@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Aug. 06, 2009, 21:41 +0300, Steve Dickson <SteveD@redhat.com> wrote:
> commit f6f4d0b872c01eaffbcb4c3919f13237aa8678e1
> Author: Steve Dickson <steved@redhat.com>
> Date:   Mon Mar 9 13:55:25 2009 -0400
> 
>     Taught conf_parse_line() to ignore spaces in the
>      '[section]' parsing and before the assignment statements
>     
>     Signed-off-by: Steve Dickson <steved@redhat.com>
> 
> diff --git a/support/nfs/conffile.c b/support/nfs/conffile.c
> index c5f9fa7..5f491eb 100644
> --- a/support/nfs/conffile.c
> +++ b/support/nfs/conffile.c
> @@ -50,11 +50,6 @@
>  #include "xlog.h"
>  
>  static void conf_load_defaults (int);
> -#if 0
> -static int conf_find_trans_xf (int, char *);
> -#endif
> -
> -size_t  strlcpy(char *, const char *, size_t);
>  
>  struct conf_trans {
>  	TAILQ_ENTRY (conf_trans) link;
> @@ -219,26 +214,48 @@ conf_parse_line(int trans, char *line, size_t sz)
>  	if (*line == '#' || *line == ';')
>  		return;
>  
> +	/* Ignore blank lines */
> +	if (*line == '\0')
> +		return;
> +
> +	/* Strip off any leading blanks */
> +	while (isblank(*line)) 
> +		line++;
> +

Why not do this before looking for '#' or ';'?

Benny

>  	/* '[section]' parsing...  */
>  	if (*line == '[') {
> -		for (i = 1; i < sz; i++)
> -			if (line[i] == ']')
> +		line++;
> +		/* Strip off any blanks after '[' */
> +		while (isblank(*line)) 
> +			line++;
> +
> +		for (i = 0; i < sz; i++) {
> +			if (line[i] == ']') {
>  				break;
> +			}
> +		}
>  		if (section)
> -			free (section);
> +			free(section);
>  		if (i == sz) {
>  			xlog_warn("conf_parse_line: %d:"
>   				"non-matched ']', ignoring until next section", ln);
>  			section = 0;
>  			return;
>  		}
> +		/* Strip off any blanks before ']' */
> +		val = line;
> +		while (*val && !isblank(*val)) 
> +			val++, j++;
> +		if (*val)
> +			i = j;
> +
>  		section = malloc(i);
>  		if (!section) {
>  			xlog_warn("conf_parse_line: %d: malloc (%lu) failed", ln,
>  						(unsigned long)i);
>  			return;
>  		}
> -		strlcpy(section, line + 1, i);
> +		strncpy(section, line, i);
>  		return;
>  	}
>  
> 
> _______________________________________________
> NFSv4 mailing list
> NFSv4@linux-nfs.org
> http://linux-nfs.org/cgi-bin/mailman/listinfo/nfsv4
