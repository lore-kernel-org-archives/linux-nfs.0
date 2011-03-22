Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx2.netapp.com ([216.240.18.37]:26522 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755364Ab1CVVrv convert rfc822-to-8bit (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Tue, 22 Mar 2011 17:47:51 -0400
Subject: Re: [PATCH] nfs4: Fix memory corruption due to not expected
 FS_LOCATIONS v3
From: Trond Myklebust <Trond.Myklebust@netapp.com>
To: Vitaliy Gusev <gusev.vitaliy@nexenta.com>
Cc: linux-nfs@vger.kernel.org
In-Reply-To: <1300829795-17054-1-git-send-email-gusev.vitaliy@nexenta.com>
References: <1300829795-17054-1-git-send-email-gusev.vitaliy@nexenta.com>
Content-Type: text/plain; charset="UTF-8"
Date: Tue, 22 Mar 2011 17:46:51 -0400
Message-ID: <1300830411.9442.49.camel@lade.trondhjem.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

On Wed, 2011-03-23 at 00:36 +0300, Vitaliy Gusev wrote:
> Changes with v2 version: when unexpected fs_locations occurs:
> 
> 1. Throw print message "unexpected fs_locations"
> 2. Stop parsing xdr and return EIO error
> 
> ----
> 
> There is a remote vulnerability for nfs4-client. That allows
> a remote NFSv4 server or attacker in middle rewrite memory on
> NFSv4 client.
> Of course if encryption is used then only server can do corruption.
> 
> 1. Client send GETATTR request to server, but there are not
>    checks for bitmask in reply from server. Therefore server may return
>    more attributes than were asked.
> 
> 2. Pointer to struct nfs_fattr is passed to decode_getfattr(), but
>    that parameter is considered as pointer to struct nfs4_fs_locations
>    in case set FATTR4_WORD0_FS_LOCATIONS in reply from server.
> 
>    But there is no check for pointer type that was passed!
> 
> 3. Remote side can set FATTR4_WORD0_FS_LOCATIONS and fill
>    datas fsattr4_fs_locations in reply to client.
> 
> 4. sizeof(nfs4_fs_locations) is about 92080 bytes in kernel 2.6.38
> 
>    So ~ 90 Kbytes can be overwritten in memory of NFSv4 client.
> 
>    Fortunately, nfs_fattr is allocated via kmalloc and
>    is not stored on stack. So generally kmalloc-192 is corrupted.
> 
>    Affected kernels: all from v2.6.18
>    Commit 683b57b435326eb512c7305892683b6205669448
>    "NFSv4: Implement the fs_locations function call"
> ---
>  fs/nfs/nfs4xdr.c |   39 +++++++++++++++++++++++++++++----------
>  1 files changed, 29 insertions(+), 10 deletions(-)
> 
> diff --git a/fs/nfs/nfs4xdr.c b/fs/nfs/nfs4xdr.c
> index c87e543..6fea9c9 100644
> --- a/fs/nfs/nfs4xdr.c
> +++ b/fs/nfs/nfs4xdr.c
> @@ -3451,7 +3451,8 @@ out_overflow:
>  	return -EIO;
>  }
>  
> -static int decode_attr_fs_locations(struct xdr_stream *xdr, uint32_t *bitmap, struct nfs4_fs_locations *res)
> +static int decode_attr_fs_locations(struct xdr_stream *xdr, uint32_t *bitmap, struct nfs4_fs_locations *res,
> +				    uint32_t *deny_bitmap)
>  {
>  	int n;
>  	__be32 *p;
> @@ -3462,6 +3463,13 @@ static int decode_attr_fs_locations(struct xdr_stream *xdr, uint32_t *bitmap, st
>  	status = 0;
>  	if (unlikely(!(bitmap[0] & FATTR4_WORD0_FS_LOCATIONS)))
>  		goto out;
> +
> +	if (unlikely(deny_bitmap[0] & FATTR4_WORD0_FS_LOCATIONS)) {
> +		status = -EIO;
> +		printk(KERN_WARNING "%s: Unexpected fs_locations\n", __func__);
> +		goto out;
> +	}

Why are you limiting this to fs_locations? As I believe I said earlier,
any attribute that we didn't explicitly request is an error and can
cause corruption in the client.

If we're going to fix this, we should fix all potential occurrences once
and for all.

-- 
Trond Myklebust
Linux NFS client maintainer

NetApp
Trond.Myklebust@netapp.com
www.netapp.com

