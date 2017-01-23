Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from aserp1040.oracle.com ([141.146.126.69]:48317 "EHLO
        aserp1040.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751083AbdAWPBa (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Mon, 23 Jan 2017 10:01:30 -0500
Received: from aserv0022.oracle.com (aserv0022.oracle.com [141.146.126.234])
        by aserp1040.oracle.com (Sentrion-MTA-4.3.2/Sentrion-MTA-4.3.2) with ESMTP id v0NF1TcB014190
        (version=TLSv1.2 cipher=ECDHE-RSA-AES256-GCM-SHA384 bits=256 verify=OK)
        for <linux-nfs@vger.kernel.org>; Mon, 23 Jan 2017 15:01:29 GMT
Received: from aserv0122.oracle.com (aserv0122.oracle.com [141.146.126.236])
        by aserv0022.oracle.com (8.14.4/8.14.4) with ESMTP id v0NF1TdB001497
        (version=TLSv1/SSLv3 cipher=DHE-RSA-AES256-GCM-SHA384 bits=256 verify=OK)
        for <linux-nfs@vger.kernel.org>; Mon, 23 Jan 2017 15:01:29 GMT
Received: from abhmp0003.oracle.com (abhmp0003.oracle.com [141.146.116.9])
        by aserv0122.oracle.com (8.14.4/8.14.4) with ESMTP id v0NF1Tjx031894
        for <linux-nfs@vger.kernel.org>; Mon, 23 Jan 2017 15:01:29 GMT
Content-Type: text/plain; charset=us-ascii
Mime-Version: 1.0 (Mac OS X Mail 9.3 \(3124\))
Subject: Re: [PATCH v1] nfs: Don't increment lock sequence ID after NFS4ERR_MOVED
From: Chuck Lever <chuck.lever@oracle.com>
In-Reply-To: <20170122190429.7337.77928.stgit@manet.1015granger.net>
Date: Mon, 23 Jan 2017 10:01:27 -0500
Message-Id: <69D3212A-874D-42A2-BE65-F3A01B061A87@oracle.com>
References: <20170122190429.7337.77928.stgit@manet.1015granger.net>
To: Linux NFS Mailing List <linux-nfs@vger.kernel.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>


> On Jan 22, 2017, at 2:04 PM, Chuck Lever <chuck.lever@oracle.com> wrote:
> 
> Xuan Qi reports that the Linux NFSv4 client failed to lock a file
> that was migrated. The steps he observed on the wire:
> 
> 1. The client sent a LOCK request
> 2. The server replied NFS4ERR_MOVED
> 3. The client switched to the destination server
> 4. The client sent the LOCK request again with a bumped
>   lock sequence ID
> 5. The server rejected the LOCK request with NFS4ERR_BAD_SEQID

The list of steps could be more clear:

1. The client sent a LOCK request to the source server
2. The source server replied NFS4ERR_MOVED
3. The client switched to the destination server
4. The client sent the same LOCK request to the destination
   server with a bumped lock sequence ID
5. The destination server rejected the LOCK request with
   NFS4ERR_BAD_SEQID


> RFC 3530 section 8.1.5 provides a list of NFS errors which do not
> bump a lock sequence ID.
> 
> However, RFC 3530 is now obsoleted by RFC 7530. In RFC 7530 section
> 9.1.7, this list has been updated by the addition of NFS4ERR_MOVED.
> 
> Reported-by: Xuan Qi <xuan.qi@oracle.com>
> Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
> Cc: stable@vger.kernel.org # v3.7+
> ---
> include/linux/nfs4.h |    3 ++-
> 1 file changed, 2 insertions(+), 1 deletion(-)
> 
> diff --git a/include/linux/nfs4.h b/include/linux/nfs4.h
> index bca5363..1b1ca04 100644
> --- a/include/linux/nfs4.h
> +++ b/include/linux/nfs4.h
> @@ -282,7 +282,7 @@ enum nfsstat4 {
> 
> static inline bool seqid_mutating_err(u32 err)
> {
> -	/* rfc 3530 section 8.1.5: */
> +	/* See RFC 7530, section 9.1.7 */
> 	switch (err) {
> 	case NFS4ERR_STALE_CLIENTID:
> 	case NFS4ERR_STALE_STATEID:
> @@ -291,6 +291,7 @@ static inline bool seqid_mutating_err(u32 err)
> 	case NFS4ERR_BADXDR:
> 	case NFS4ERR_RESOURCE:
> 	case NFS4ERR_NOFILEHANDLE:
> +	case NFS4ERR_MOVED:
> 		return false;
> 	};
> 	return true;
> 
> --
> To unsubscribe from this list: send the line "unsubscribe linux-nfs" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html

--
Chuck Lever



