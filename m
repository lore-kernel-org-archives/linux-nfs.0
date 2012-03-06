Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx1.redhat.com ([209.132.183.28]:41191 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750795Ab2CFQFh (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Tue, 6 Mar 2012 11:05:37 -0500
Received: from int-mx02.intmail.prod.int.phx2.redhat.com (int-mx02.intmail.prod.int.phx2.redhat.com [10.5.11.12])
	by mx1.redhat.com (8.14.4/8.14.4) with ESMTP id q26G5afR020417
	(version=TLSv1/SSLv3 cipher=DHE-RSA-AES256-SHA bits=256 verify=OK)
	for <linux-nfs@vger.kernel.org>; Tue, 6 Mar 2012 11:05:36 -0500
Message-ID: <4F5635D4.9090504@RedHat.com>
Date: Tue, 06 Mar 2012 11:05:40 -0500
From: Steve Dickson <SteveD@redhat.com>
MIME-Version: 1.0
To: Steve Dickson <steved@redhat.com>
CC: Linux NFS Mailing List <linux-nfs@vger.kernel.org>
Subject: Re: [PATCH 1/1] nfsmount: Fixed parsing error in the nfsmount.conf
 code.
References: <1330992800-6895-1-git-send-email-steved@redhat.com>
In-Reply-To: <1330992800-6895-1-git-send-email-steved@redhat.com>
Content-Type: text/plain; charset=ISO-8859-1
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>



On 03/05/2012 07:13 PM, Steve Dickson wrote:
> When the options where prefixed with spaces (instead of tabs)
> the second option in the list was missed to so a miscalculation
> the the nfsmount.conf parsing code.
> 
> Signed-off-by: Steve Dickson <steved@redhat.com>
Committed....

steved.

> ---
>  support/nfs/conffile.c |   19 ++++++-------------
>  1 files changed, 6 insertions(+), 13 deletions(-)
> 
> diff --git a/support/nfs/conffile.c b/support/nfs/conffile.c
> index 3990578..2f1e235 100644
> --- a/support/nfs/conffile.c
> +++ b/support/nfs/conffile.c
> @@ -211,7 +211,7 @@ static void
>  conf_parse_line(int trans, char *line, size_t sz)
>  {
>  	char *val, *ptr;
> -	size_t i;
> +	size_t i, valsize;
>  	size_t j;
>  	static char *section = 0;
>  	static char *arg = 0;
> @@ -298,23 +298,16 @@ conf_parse_line(int trans, char *line, size_t sz)
>  			}
>  			line[strcspn (line, " \t=")] = '\0';
>  			val = line + i + 1 + strspn (line + i + 1, " \t");
> +			valsize = 0;
> +			while (val[valsize++]);
>  
> -			/* Skip trailing comments, if any */
> -			for (j = 0; j < sz - (val - line); j++) {
> -				if (val[j] == '#' || val[j] == ';') {
> +			/* Skip trailing spaces and comments */
> +			for (j = 0; j < valsize; j++) {
> +				if (val[j] == '#' || val[j] == ';' || isspace(val[j])) {
>  					val[j] = '\0';
>  					break;
>  				}
>  			}
> -
> -			/* Skip trailing whitespace, if any */
> -			for (j--; j > 0; j--) {
> -				if (isspace(val[j]))
> -					val[j] = '\0';
> -				else 
> -					break;
> -			}
> -
>  			/* XXX Perhaps should we not ignore errors?  */
>  			conf_set(trans, section, arg, line, val, 0, 0);
>  			return;
