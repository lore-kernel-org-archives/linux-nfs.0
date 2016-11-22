Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:49464 "EHLO mx1.redhat.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1755492AbcKVTGU (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Tue, 22 Nov 2016 14:06:20 -0500
Subject: Re: [PATCH] nfs-utils: exportfs remove redundant exports options
 output
To: "Jianhong.Yin" <yin-jianhong@163.com>, linux-nfs@vger.kernel.org
References: <1479459523-7649-1-git-send-email-yin-jianhong@163.com>
From: Steve Dickson <SteveD@redhat.com>
Message-ID: <20775fcf-adc5-57c9-4238-2e1c3ea1facd@RedHat.com>
Date: Tue, 22 Nov 2016 14:05:29 -0500
MIME-Version: 1.0
In-Reply-To: <1479459523-7649-1-git-send-email-yin-jianhong@163.com>
Content-Type: text/plain; charset=windows-1252
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>



On 11/18/2016 03:58 AM, Jianhong.Yin wrote:
> before this commit, run 'exportfs -s' will output some
>  options more than one time. for example:
>  /path *(rw,no_root_squash,rw,secure,no_root_squash,no_all_squash)
>  the options rw,no_root_squash,etc will be print twice.
> the reason is secinfo_show() will show these security options again
> this patch remove these redundant outputs.
> 
> Signed-off-by: Jianhong Yin <yin-jianhong@163.com>
Committed!

steved.

> ---
>  utils/exportfs/exportfs.c | 18 ++++++------------
>  1 file changed, 6 insertions(+), 12 deletions(-)
> 
> diff --git a/utils/exportfs/exportfs.c b/utils/exportfs/exportfs.c
> index 98368a5..b11f06b 100644
> --- a/utils/exportfs/exportfs.c
> +++ b/utils/exportfs/exportfs.c
> @@ -747,26 +747,20 @@ dump(int verbose, int export_format)
>  				continue;
>  			}
>  			c = '(';
> -			if (ep->e_flags & NFSEXP_READONLY)
> -				c = dumpopt(c, "ro");
> -			else
> -				c = dumpopt(c, "rw");
>  			if (ep->e_flags & NFSEXP_ASYNC)
>  				c = dumpopt(c, "async");
> +			else
> +				c = dumpopt(c, "sync");
>  			if (ep->e_flags & NFSEXP_GATHERED_WRITES)
>  				c = dumpopt(c, "wdelay");
> +			else
> +				c = dumpopt(c, "no_wdelay");
>  			if (ep->e_flags & NFSEXP_NOHIDE)
>  				c = dumpopt(c, "nohide");
> +			else
> +				c = dumpopt(c, "hide");
>  			if (ep->e_flags & NFSEXP_CROSSMOUNT)
>  				c = dumpopt(c, "crossmnt");
> -			if (ep->e_flags & NFSEXP_INSECURE_PORT)
> -				c = dumpopt(c, "insecure");
> -			if (ep->e_flags & NFSEXP_ROOTSQUASH)
> -				c = dumpopt(c, "root_squash");
> -			else
> -				c = dumpopt(c, "no_root_squash");
> -			if (ep->e_flags & NFSEXP_ALLSQUASH)
> -				c = dumpopt(c, "all_squash");
>  			if (ep->e_flags & NFSEXP_NOSUBTREECHECK)
>  				c = dumpopt(c, "no_subtree_check");
>  			if (ep->e_flags & NFSEXP_NOAUTHNLM)
> 
