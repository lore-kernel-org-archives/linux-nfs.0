Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:29492 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752316Ab1FGUVd (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Tue, 7 Jun 2011 16:21:33 -0400
Message-ID: <4DEE8846.3010009@RedHat.com>
Date: Tue, 07 Jun 2011 16:21:26 -0400
From: Steve Dickson <SteveD@redhat.com>
To: Pavel Shilovsky <piastry@etersoft.ru>
CC: linux-nfs@vger.kernel.org
Subject: Re: [PATCH] mountd: Fix missing varialble assignment in auth_unix_gid
References: <1306954641-2560-1-git-send-email-piastry@etersoft.ru>
In-Reply-To: <1306954641-2560-1-git-send-email-piastry@etersoft.ru>
Content-Type: text/plain; charset=ISO-8859-1
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0



On 06/01/2011 02:57 PM, Pavel Shilovsky wrote:
> When we get into auth_unix_gid at the second time, groups_len
> is not 0 and ngroups variable leave as 0. Then we use ngroups
> in getgrouplist that fails in this case. This patch fixes it.
> 
> Signed-off-by: Pavel Shilovsky <piastry@etersoft.ru>
> ---
>  utils/mountd/cache.c |    6 ++++--
>  1 files changed, 4 insertions(+), 2 deletions(-)
> 
> diff --git a/utils/mountd/cache.c b/utils/mountd/cache.c
> index df6b38f..dbe20e9 100644
> --- a/utils/mountd/cache.c
> +++ b/utils/mountd/cache.c
> @@ -138,7 +138,7 @@ static void auth_unix_gid(FILE *f)
>  	static gid_t *groups = NULL;
>  	static int groups_len = 0;
>  	gid_t *more_groups;
> -	int ngroups = 0;
> +	int ngroups;
>  	int rv, i;
>  	char *cp;
>  
> @@ -147,9 +147,11 @@ static void auth_unix_gid(FILE *f)
>  		if (!groups)
>  			return;
>  
> -		groups_len = ngroups = INITIAL_MANAGED_GROUPS;
> +		groups_len = INITIAL_MANAGED_GROUPS;
>  	}
>  
> +	ngroups = groups_len;
> +
>  	if (readline(fileno(f), &lbuf, &lbuflen) != 1)
>  		return;
>  
Committed...

steved.
