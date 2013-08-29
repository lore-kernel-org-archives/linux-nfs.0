Return-Path: linux-nfs-owner@vger.kernel.org
Received: from aserp1040.oracle.com ([141.146.126.69]:37198 "EHLO
	aserp1040.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756732Ab3H2VtN (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 29 Aug 2013 17:49:13 -0400
Date: Fri, 30 Aug 2013 00:49:09 +0300
From: Dan Carpenter <dan.carpenter@oracle.com>
To: Trond.Myklebust@netapp.com
Cc: linux-nfs@vger.kernel.org
Subject: re: NFS: Add event tracing for generic NFS lookups
Message-ID: <20130829214909.GA15027@elgon.mountain>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Hello Trond Myklebust,

The patch 6e0d0be715fe: "NFS: Add event tracing for generic NFS
lookups" from Aug 20, 2013, leads to the following static checker
warning: "fs/nfs/dir.c:1465 nfs_atomic_open()
	 	warn: 'ctx' was already freed."

fs/nfs/dir.c
  1462          if (IS_ERR(inode)) {
  1463                  put_nfs_open_context(ctx);
                        ^^^^^^^^^^^^^^^^^^^^^^^^^
Can free "ctx".

  1464                  err = PTR_ERR(inode);
  1465                  trace_nfs_atomic_open_exit(dir, ctx, open_flags, err);
                                                        ^^^
Dereference.

  1466                  switch (err) {
  1467                  case -ENOENT:
  1468                          d_drop(dentry);
  1469                          d_add(dentry, NULL);
  1470                          break;
  1471                  case -EISDIR:
  1472                  case -ENOTDIR:
  1473                          goto no_open;
  1474                  case -ELOOP:
  1475                          if (!(open_flags & O_NOFOLLOW))
  1476                                  goto no_open;
  1477                          break;
  1478                          /* case -EINVAL: */
  1479                  default:
  1480                          break;
  1481                  }
  1482                  goto out;
  1483          }
  1484  
  1485          err = nfs_finish_open(ctx, ctx->dentry, file, open_flags, opened);
  1486          trace_nfs_atomic_open_exit(dir, ctx, open_flags, err);
                                                ^^^
If we hit an error in the call to nfs_finish_open() then I think "ctx"
is freed.

  1487  out:
  1488          return err;
  1489  

regards,
dan carpenter

