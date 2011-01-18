Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from rcsinet10.oracle.com ([148.87.113.121]:43864 "EHLO
	rcsinet10.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751706Ab1ARWOG convert rfc822-to-8bit (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Tue, 18 Jan 2011 17:14:06 -0500
Subject: Re: [PATCH 1/2] NFSD: use nfserr for status after decode_cb_op_status
Content-Type: text/plain; charset=us-ascii
From: Chuck Lever <chuck.lever@oracle.com>
In-Reply-To: <1294910731-18370-1-git-send-email-bhalevy@panasas.com>
Date: Tue, 18 Jan 2011 17:13:12 -0500
Cc: " J. Bruce Fields" <bfields@redhat.com>, linux-nfs@vger.kernel.org
Message-Id: <7BE4C87F-5758-4496-85CC-718F8D0F10E1@oracle.com>
References: <4D2EC4AC.9090205@panasas.com> <1294910731-18370-1-git-send-email-bhalevy@panasas.com>
To: Benny Halevy <bhalevy@panasas.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0


On Jan 13, 2011, at 4:25 AM, Benny Halevy wrote:

> Bugs introduced in 85a56480191ca9f08fc775c129b9eb5c8c1f2c05
> "NFSD: Update XDR decoders in NFSv4 callback client"
> 
> Cc: Chuck Lever <chuck.lever@oracle.com>
> Signed-off-by: Benny Halevy <bhalevy@panasas.com>
> ---
> fs/nfsd/nfs4callback.c |    6 ++----
> 1 files changed, 2 insertions(+), 4 deletions(-)
> 
> diff --git a/fs/nfsd/nfs4callback.c b/fs/nfsd/nfs4callback.c
> index 21a63da..5a6dcf8 100644
> --- a/fs/nfsd/nfs4callback.c
> +++ b/fs/nfsd/nfs4callback.c
> @@ -484,7 +484,7 @@ static int decode_cb_sequence4res(struct xdr_stream *xdr,
> out:
> 	return status;
> out_default:
> -	return nfs_cb_stat_to_errno(status);
> +	return nfs_cb_stat_to_errno(nfserr);

Good fix.

> }
> 
> /*
> @@ -564,11 +564,9 @@ static int nfs4_xdr_dec_cb_recall(struct rpc_rqst *rqstp,
> 	if (unlikely(status))
> 		goto out;
> 	if (unlikely(nfserr != NFS4_OK))
> -		goto out_default;
> +		status = nfs_cb_stat_to_errno(nfserr);
> out:
> 	return status;
> -out_default:
> -	return nfs_cb_stat_to_errno(status);

Good fix, but I would rather keep the same style here that every other NFS decoder uses here.  The "goto out_default" -- we want to keep the non-common cases out of the mainline code path.  It is Bruce-preferred (tm) style to branch on error.

> }
> 
> /*
> -- 
> 1.7.3.4
> 

-- 
Chuck Lever
chuck[dot]lever[at]oracle[dot]com




