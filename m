Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from aserp1040.oracle.com ([141.146.126.69]:18463 "EHLO
        aserp1040.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751440AbdFFTwq (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Tue, 6 Jun 2017 15:52:46 -0400
Content-Type: text/plain; charset=us-ascii
Mime-Version: 1.0 (Mac OS X Mail 9.3 \(3124\))
Subject: Re: [PATCH] mount.nfs: Use default minor version when -t nfs4 is specified
From: Chuck Lever <chuck.lever@oracle.com>
In-Reply-To: <20170606194812.4248-1-steved@redhat.com>
Date: Tue, 6 Jun 2017 15:52:41 -0400
Cc: Linux NFS Mailing List <linux-nfs@vger.kernel.org>
Message-Id: <5D1A0F34-DD8D-465E-BF94-7E2C92EC8282@oracle.com>
References: <20170606194812.4248-1-steved@redhat.com>
To: Steve Dickson <steved@redhat.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>


> On Jun 6, 2017, at 3:48 PM, Steve Dickson <steved@redhat.com> wrote:
> 
> When the nfs4 filesystem specified, the default minor
> version should be used not v4.0.

Isn't the default specified in the mountnfs config file?


> Signed-off-by: Steve Dickson <steved@redhat.com>
> ---
> utils/mount/stropts.c | 3 ++-
> 1 file changed, 2 insertions(+), 1 deletion(-)
> 
> diff --git a/utils/mount/stropts.c b/utils/mount/stropts.c
> index c0266e5..57efb26 100644
> --- a/utils/mount/stropts.c
> +++ b/utils/mount/stropts.c
> @@ -317,7 +317,8 @@ static int nfs_set_version(struct nfsmount_info *mi)
> 
> 	if (strncmp(mi->type, "nfs4", 4) == 0) {
> 		mi->version.major = 4;
> -		mi->version.v_mode = V_GENERAL;
> +		mi->version.minor = 2;
> +		mi->version.v_mode = V_SPECIFIC;
> 	}
> 	/*
> 	 * Before 2.6.32, the kernel NFS client didn't
> -- 
> 2.9.4
> 
> --
> To unsubscribe from this list: send the line "unsubscribe linux-nfs" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html

--
Chuck Lever



