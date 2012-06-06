Return-Path: linux-nfs-owner@vger.kernel.org
Received: from acsinet15.oracle.com ([141.146.126.227]:41747 "EHLO
	acsinet15.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751634Ab2FFSb6 (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Wed, 6 Jun 2012 14:31:58 -0400
Subject: Re: [PATCH] NFS: Map minor mismatch error to protocol not support error.
Mime-Version: 1.0 (Apple Message framework v1278)
Content-Type: text/plain; charset=us-ascii
From: Chuck Lever <chuck.lever@oracle.com>
In-Reply-To: <1339006327-27815-1-git-send-email-steved@redhat.com>
Date: Wed, 6 Jun 2012 14:31:51 -0400
Cc: Trond Myklebust <Trond.Myklebust@netapp.com>,
        Linux NFS Mailing list <linux-nfs@vger.kernel.org>
Message-Id: <63B16CAE-BAE9-471F-B213-65D990A0788B@oracle.com>
References: <1339006327-27815-1-git-send-email-steved@redhat.com>
To: Steve Dickson <SteveD@redhat.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>


On Jun 6, 2012, at 2:12 PM, Steve Dickson wrote:

> Sservers that only have NFSv4.1 support the
> NFS4ERR_MINOR_VERS_MISMATCH error is return on
> v4.0 mounts. Mapping that error to EPROTONOSUPPORT
> will cause the mount to back off to v3 instead of
> failing.

Should we try NFSv4.0 first?

> 
> Signed-off-by: Steve Dickson <steved@redhat.com>
> ---
> fs/nfs/nfs4proc.c |    2 ++
> 1 files changed, 2 insertions(+), 0 deletions(-)
> 
> diff --git a/fs/nfs/nfs4proc.c b/fs/nfs/nfs4proc.c
> index d48dbef..eda028b 100644
> --- a/fs/nfs/nfs4proc.c
> +++ b/fs/nfs/nfs4proc.c
> @@ -105,6 +105,8 @@ static int nfs4_map_errors(int err)
> 		return -EINVAL;
> 	case -NFS4ERR_SHARE_DENIED:
> 		return -EACCES;
> +	case -NFS4ERR_MINOR_VERS_MISMATCH:
> +		return -EPROTONOSUPPORT;
> 	default:
> 		dprintk("%s could not handle NFSv4 error %d\n",
> 				__func__, -err);
> -- 
> 1.7.1
> 
> --
> To unsubscribe from this list: send the line "unsubscribe linux-nfs" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html

---
Chuck Lever
chuck [dot] lever [at] oracle [dot] com




