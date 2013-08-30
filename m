Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx11.netapp.com ([216.240.18.76]:58464 "EHLO mx11.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1756306Ab3H3N0b convert rfc822-to-8bit (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Fri, 30 Aug 2013 09:26:31 -0400
From: "Myklebust, Trond" <Trond.Myklebust@netapp.com>
To: Dan Carpenter <dan.carpenter@oracle.com>
CC: "linux-nfs@vger.kernel.org" <linux-nfs@vger.kernel.org>
Subject: RE: NFS: Add event tracing for generic NFS lookups
Date: Fri, 30 Aug 2013 13:26:30 +0000
Message-ID: <4FA345DA4F4AE44899BD2B03EEEC2FA946784B13@SACEXCMBX04-PRD.hq.netapp.com>
References: <20130829214909.GA15027@elgon.mountain>
In-Reply-To: <20130829214909.GA15027@elgon.mountain>
Content-Type: text/plain; charset="Windows-1252"
MIME-Version: 1.0
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

> -----Original Message-----
> From: Dan Carpenter [mailto:dan.carpenter@oracle.com]
> Sent: Thursday, August 29, 2013 5:49 PM
> To: Myklebust, Trond
> Cc: linux-nfs@vger.kernel.org
> Subject: re: NFS: Add event tracing for generic NFS lookups
> 
> Hello Trond Myklebust,
> 
> The patch 6e0d0be715fe: "NFS: Add event tracing for generic NFS lookups"
> from Aug 20, 2013, leads to the following static checker
> warning: "fs/nfs/dir.c:1465 nfs_atomic_open()
> 	 	warn: 'ctx' was already freed."
> 
> fs/nfs/dir.c
>   1462          if (IS_ERR(inode)) {
>   1463                  put_nfs_open_context(ctx);
>                         ^^^^^^^^^^^^^^^^^^^^^^^^^ Can free "ctx".
> 
>   1464                  err = PTR_ERR(inode);
>   1465                  trace_nfs_atomic_open_exit(dir, ctx, open_flags, err);
>                                                         ^^^ Dereference.
> 
>   1466                  switch (err) {
>   1467                  case -ENOENT:
>   1468                          d_drop(dentry);
>   1469                          d_add(dentry, NULL);
>   1470                          break;
>   1471                  case -EISDIR:
>   1472                  case -ENOTDIR:
>   1473                          goto no_open;
>   1474                  case -ELOOP:
>   1475                          if (!(open_flags & O_NOFOLLOW))
>   1476                                  goto no_open;
>   1477                          break;
>   1478                          /* case -EINVAL: */
>   1479                  default:
>   1480                          break;
>   1481                  }
>   1482                  goto out;
>   1483          }
>   1484
>   1485          err = nfs_finish_open(ctx, ctx->dentry, file, open_flags, opened);
>   1486          trace_nfs_atomic_open_exit(dir, ctx, open_flags, err);
>                                                 ^^^ If we hit an error in the call to nfs_finish_open()
> then I think "ctx"
> is freed.
> 
>   1487  out:
>   1488          return err;
>   1489
> 

Thanks Dan! I've fixed this up.

Cheers
  Trond

