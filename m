Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:54980 "EHLO mx1.redhat.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1751395AbdJEOz0 (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Thu, 5 Oct 2017 10:55:26 -0400
Received: from smtp.corp.redhat.com (int-mx04.intmail.prod.int.phx2.redhat.com [10.5.11.14])
        (using TLSv1.2 with cipher AECDH-AES256-SHA (256/256 bits))
        (No client certificate requested)
        by mx1.redhat.com (Postfix) with ESMTPS id A1ACC7EAA1
        for <linux-nfs@vger.kernel.org>; Thu,  5 Oct 2017 14:55:25 +0000 (UTC)
Subject: Re: [PATCH nfs-utils] merge vers= and nfsvers= options in mount.nfs
To: Justin Mitchell <jumitche@redhat.com>,
        Linux NFS Mailing list <linux-nfs@vger.kernel.org>
References: <1506931344.3753.3.camel@redhat.com>
From: Steve Dickson <SteveD@RedHat.com>
Message-ID: <813301d8-a3ca-ebb0-3ac0-5f8e13f40706@RedHat.com>
Date: Thu, 5 Oct 2017 10:55:24 -0400
MIME-Version: 1.0
In-Reply-To: <1506931344.3753.3.camel@redhat.com>
Content-Type: text/plain; charset=utf-8
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>



On 10/02/2017 04:02 AM, Justin Mitchell wrote:
> When using mount.nfs if an nfsvers= option is set in a config file,
> and a vers= option is given on the commandline, then they are not
> always correctly combined and this can result in both being present
> in the resulting mount call.
> 
> Signed-off-by: Justin Mitchell <jumitche@redhat.com>
Committed... 

steved.
> ---
>  utils/mount/configfile.c | 8 +++++---
>  1 file changed, 5 insertions(+), 3 deletions(-)
> 
> diff --git a/utils/mount/configfile.c b/utils/mount/configfile.c
> index e4b39ef..64688bf 100644
> --- a/utils/mount/configfile.c
> +++ b/utils/mount/configfile.c
> @@ -66,6 +66,7 @@ struct mnt_alias {
>  	{"background", "bg", MNT_NOARG},
>  	{"foreground", "fg", MNT_NOARG},
>  	{"sloppy", "sloppy", MNT_NOARG},
> +	{"nfsvers", "vers", MNT_UNSET},
>  };
>  int mnt_alias_sz = (sizeof(mnt_alias_tab)/sizeof(mnt_alias_tab[0]));
>  
> @@ -292,20 +293,21 @@ conf_parse_mntopts(char *section, char *arg, char *opts)
>  
>  	list = conf_get_tag_list(section, arg);
>  	TAILQ_FOREACH(node, &list->fields, link) {
> +		/* check first if this is an alias for another option */
> +		field = mountopts_alias(node->field, &argtype);
>  		/*
>  		 * Do not overwrite options if already exists 
>  		 */
> -		snprintf(buf, BUFSIZ, "%s=", node->field);
> +		snprintf(buf, BUFSIZ, "%s=", field);
>  		if (opts && strcasestr(opts, buf) != NULL)
>  			continue;
>  
> -		if (lookup_entry(node->field) != NULL)
> +		if (lookup_entry(field) != NULL)
>  			continue;
>  		buf[0] = '\0';
>  		value = conf_get_section(section, arg, node->field);
>  		if (value == NULL)
>  			continue;
> -		field = mountopts_alias(node->field, &argtype);
>  		if (strcasecmp(value, "false") == 0) {
>  			if (argtype != MNT_NOARG)
>  				snprintf(buf, BUFSIZ, "no%s", field);
> 
