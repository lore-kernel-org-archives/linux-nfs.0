Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx1.redhat.com ([209.132.183.28]:52386 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753769Ab3JUOD4 (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Mon, 21 Oct 2013 10:03:56 -0400
Received: from int-mx12.intmail.prod.int.phx2.redhat.com (int-mx12.intmail.prod.int.phx2.redhat.com [10.5.11.25])
	by mx1.redhat.com (8.14.4/8.14.4) with ESMTP id r9LE3u8Y001414
	(version=TLSv1/SSLv3 cipher=DHE-RSA-AES256-SHA bits=256 verify=OK)
	for <linux-nfs@vger.kernel.org>; Mon, 21 Oct 2013 10:03:56 -0400
Message-ID: <52653474.1060007@RedHat.com>
Date: Mon, 21 Oct 2013 10:04:36 -0400
From: Steve Dickson <SteveD@redhat.com>
MIME-Version: 1.0
To: Steve Dickson <steved@redhat.com>
CC: Linux NFS Mailing list <linux-nfs@vger.kernel.org>
Subject: Re: [PATCH 1/2] nfsmount.conf: Remove duplicate 'bg' and 'fg' from
 parsing string.
References: <1381267825-27457-1-git-send-email-steved@redhat.com>
In-Reply-To: <1381267825-27457-1-git-send-email-steved@redhat.com>
Content-Type: text/plain; charset=ISO-8859-1
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>



On 08/10/13 17:30, Steve Dickson wrote:
> When the 'Background' and/or 'Foreground' options are set
> in multiple sections of the nfsmount.conf file, each instance
> gets added to the parsing string. This patch makes the first
> instance of either option override the any others.
> 
> Signed-off-by: Steve Dickson <steved@redhat.com>
Committed...

steved.
> ---
>  utils/mount/configfile.c | 25 +++++++++++++++++++++++++
>  1 file changed, 25 insertions(+)
> 
> diff --git a/utils/mount/configfile.c b/utils/mount/configfile.c
> index 68b9f93..6985ed9 100644
> --- a/utils/mount/configfile.c
> +++ b/utils/mount/configfile.c
> @@ -164,6 +164,20 @@ add_entry(char *opt)
>  	SLIST_INSERT_HEAD(&head, entry, entries);
>  }
>  /*
> + * Check the alias list to see if the given 
> + * opt is a alias
> + */
> +char *is_alias(char *opt)
> +{
> +	int i;
> +
> +	for (i=0; i < mnt_alias_sz; i++) {
> +		if (strcasecmp(opt, mnt_alias_tab[i].alias) == 0)
> +			return mnt_alias_tab[i].opt; 
> +	}
> +	return NULL;
> +}
> +/*
>   * See if the given entry exists if the link list,
>   * if so return that entry
>   */
> @@ -171,10 +185,21 @@ inline static
>  char *lookup_entry(char *opt)
>  {
>  	struct entry *entry;
> +	char *alias = is_alias(opt);
>  
>  	SLIST_FOREACH(entry, &head, entries) {
>  		if (strcasecmp(entry->opt, opt) == 0)
>  			return opt;
> +		if (alias && strcasecmp(entry->opt, alias) == 0)
> +			return opt;
> +		if (alias && strcasecmp(alias, "fg") == 0) {
> +			if (strcasecmp(entry->opt, "bg") == 0)
> +				return opt;
> +		}
> +		if (alias && strcasecmp(alias, "bg") == 0) {
> +			if (strcasecmp(entry->opt, "fg") == 0)
> +				return opt;
> +		}
>  	}
>  	return NULL;
>  }
> 
