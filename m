Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx1.redhat.com ([209.132.183.28]:33846 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753341Ab3JUOEJ (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Mon, 21 Oct 2013 10:04:09 -0400
Received: from int-mx01.intmail.prod.int.phx2.redhat.com (int-mx01.intmail.prod.int.phx2.redhat.com [10.5.11.11])
	by mx1.redhat.com (8.14.4/8.14.4) with ESMTP id r9LE4979032642
	(version=TLSv1/SSLv3 cipher=DHE-RSA-AES256-SHA bits=256 verify=OK)
	for <linux-nfs@vger.kernel.org>; Mon, 21 Oct 2013 10:04:09 -0400
Message-ID: <52653482.1030800@RedHat.com>
Date: Mon, 21 Oct 2013 10:04:50 -0400
From: Steve Dickson <SteveD@redhat.com>
MIME-Version: 1.0
To: Steve Dickson <steved@redhat.com>
CC: Linux NFS Mailing list <linux-nfs@vger.kernel.org>
Subject: Re: [PATCH 2/2] nfsmount.conf: remove duplicate 'timeo' from the
 parsing string
References: <1381267825-27457-1-git-send-email-steved@redhat.com> <1381267825-27457-2-git-send-email-steved@redhat.com>
In-Reply-To: <1381267825-27457-2-git-send-email-steved@redhat.com>
Content-Type: text/plain; charset=ISO-8859-1
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>



On 08/10/13 17:30, Steve Dickson wrote:
> When the 'timeo' option is specified in multiple sections of
> the nfsmount.conf file, each instance is added to the parsing
> string. This patch make the first instance override any others.
> 
> Signed-off-by: Steve Dickson <steved@redhat.com>
Committed... 

steved.
> ---
>  utils/mount/configfile.c | 10 ++++++++++
>  1 file changed, 10 insertions(+)
> 
> diff --git a/utils/mount/configfile.c b/utils/mount/configfile.c
> index 6985ed9..39d3741 100644
> --- a/utils/mount/configfile.c
> +++ b/utils/mount/configfile.c
> @@ -186,8 +186,18 @@ char *lookup_entry(char *opt)
>  {
>  	struct entry *entry;
>  	char *alias = is_alias(opt);
> +	char *ptr;
>  
>  	SLIST_FOREACH(entry, &head, entries) {
> +		/*
> +		 * Only check the left side or options that use '='
> +		 */
> +		if ((ptr = strchr(entry->opt, '=')) != 0) {
> +			int len = (int) (ptr - entry->opt);
> +
> +			if (strncasecmp(entry->opt, opt, len) == 0)
> +				return opt;
> +		}
>  		if (strcasecmp(entry->opt, opt) == 0)
>  			return opt;
>  		if (alias && strcasecmp(entry->opt, alias) == 0)
> 
