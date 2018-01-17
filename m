Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:59372 "EHLO mx1.redhat.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1753617AbeAQQLR (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Wed, 17 Jan 2018 11:11:17 -0500
Subject: Re: [PATCH] exportfs: move ro/rw option back to
 secinfo_flag_displaymap table
To: "Jianhong.Yin" <yin-jianhong@163.com>, linux-nfs@vger.kernel.org
References: <20180112054757.23927-1-yin-jianhong@163.com>
From: Steve Dickson <SteveD@RedHat.com>
Message-ID: <7178cd83-e7bd-b429-6dcf-ad9d49d20bea@RedHat.com>
Date: Wed, 17 Jan 2018 11:11:14 -0500
MIME-Version: 1.0
In-Reply-To: <20180112054757.23927-1-yin-jianhong@163.com>
Content-Type: text/plain; charset=utf-8
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>



On 01/12/2018 12:47 AM, Jianhong.Yin wrote:
> according https://bugzilla.redhat.com/show_bug.cgi?id=1532688#c3
> ro/rw options should be in secinfo_flag_displaymap[]
> 
> test pass:
> '''
> [yjh@test ~]$ cat /etc/exports
> /export_test    127.0.0.1(rw,wdelay,no_root_squash,no_subtree_check,sec=sys,root_squash,all_squash,sec=krb5,ro,root_squash,no_all_squash,sec=krb5i,rw,root_squash,no_all_squash,sec=krb5p,no_root_squash,no_all_squash)
> [yjh@test ~]$ sudo service nfs restart
> Redirecting to /bin/systemctl restart nfs.service
> [yjh@test ~]$ sudo exportfs -v
> /export_test    127.0.0.1(sync,wdelay,hide,no_subtree_check,sec=sys,rw,secure,root_squash,all_squash,sec=krb5,ro,secure,root_squash,no_all_squash,sec=krb5i,rw,secure,root_squash,no_all_squash,sec=krb5p,rw,secure,no_root_squash,no_all_squash)
> '''
> 
> Signed-off-by: Jianhong Yin <yin-jianhong@163.com>
Committed... 

steved.
> ---
>  support/nfs/exports.c     | 1 +
>  utils/exportfs/exportfs.c | 4 ----
>  2 files changed, 1 insertion(+), 4 deletions(-)
> 
> diff --git a/support/nfs/exports.c b/support/nfs/exports.c
> index 92bd6e6..b59d187 100644
> --- a/support/nfs/exports.c
> +++ b/support/nfs/exports.c
> @@ -197,6 +197,7 @@ static const struct secinfo_flag_displaymap {
>  	const char *set;
>  	const char *unset;
>  } secinfo_flag_displaymap[] = {
> +	{ NFSEXP_READONLY, "ro", "rw" },
>  	{ NFSEXP_INSECURE_PORT, "insecure", "secure" },
>  	{ NFSEXP_ROOTSQUASH, "root_squash", "no_root_squash" },
>  	{ NFSEXP_ALLSQUASH, "all_squash", "no_all_squash" },
> diff --git a/utils/exportfs/exportfs.c b/utils/exportfs/exportfs.c
> index 448f195..cd3c979 100644
> --- a/utils/exportfs/exportfs.c
> +++ b/utils/exportfs/exportfs.c
> @@ -695,10 +695,6 @@ dump(int verbose, int export_format)
>  				continue;
>  			}
>  			c = '(';
> -			if (ep->e_flags & NFSEXP_READONLY)
> -				c = dumpopt(c, "ro");
> -			else
> -				c = dumpopt(c, "rw");
>  			if (ep->e_flags & NFSEXP_ASYNC)
>  				c = dumpopt(c, "async");
>  			else
> 
