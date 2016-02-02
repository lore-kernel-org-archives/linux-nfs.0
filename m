Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:55363 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S933116AbcBBPYx (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Tue, 2 Feb 2016 10:24:53 -0500
Subject: Re: [PATCH] Ignore whitespace at the beginning of option tags
To: Malahal Naineni <malahal@us.ibm.com>, linux-nfs@vger.kernel.org
References: <1454020727-1814-1-git-send-email-malahal@us.ibm.com>
From: Steve Dickson <SteveD@redhat.com>
Message-ID: <56B0CA44.40105@RedHat.com>
Date: Tue, 2 Feb 2016 10:24:52 -0500
MIME-Version: 1.0
In-Reply-To: <1454020727-1814-1-git-send-email-malahal@us.ibm.com>
Content-Type: text/plain; charset=windows-1252
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>



On 01/28/2016 05:38 PM, Malahal Naineni wrote:
> The following should work now:
> 
> [General]
> 	Domain = local.domain.edu
> 
> Signed-off-by: Malahal Naineni <malahal@us.ibm.com>
> ---
>  cfg.c | 9 ++++++++-
Ok.. I give... :-) What is this patch relative to? There is
a conf_parse_line() in support/nfs/conffile.c but there
is no cfg.c file in nfs-utils... and this patch does
not apply... 

steved.

>  1 file changed, 8 insertions(+), 1 deletion(-)
> 
> diff --git a/cfg.c b/cfg.c
> index c615d24..e0ab839 100644
> --- a/cfg.c
> +++ b/cfg.c
> @@ -210,6 +210,7 @@ static void
>  conf_parse_line (int trans, char *line, size_t sz)
>  {
>    char *val;
> +  char *tag;
>    size_t i;
>    int j;
>    static char *section = 0;
> @@ -262,8 +263,14 @@ conf_parse_line (int trans, char *line, size_t sz)
>  	/* Skip trailing whitespace, if any */
>  	for (j = sz - (val - line) - 1; j > 0 && isspace (val[j]); j--)
>  	  val[j] = '\0';
> +
> +	/* Skip beginning white space */
> +	tag = line;
> +	while (isspace(*tag))
> +		tag++;
> +
>  	/* XXX Perhaps should we not ignore errors?  */
> -	conf_set (trans, section, line, val, 0, 0);
> +	conf_set (trans, section, tag, val, 0, 0);
>  	return;
>        }
>  
> 
