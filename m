Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx2.netapp.com ([216.240.18.37]:28751 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754250Ab0KZS4I convert rfc822-to-8bit (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Fri, 26 Nov 2010 13:56:08 -0500
Subject: [GIT PULL] Please pull NFS client bugfixes
From: Trond Myklebust <Trond.Myklebust@netapp.com>
To: Linus Torvalds <torvalds@linux-foundation.org>
Cc: linux-nfs@vger.kernel.org, linux-kernel@vger.kernel.org
Content-Type: text/plain; charset="UTF-8"
Date: Fri, 26 Nov 2010 13:56:07 -0500
Message-ID: <1290797767.4905.11.camel@heimdal.trondhjem.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

Hi Linus,

Please pull from the "bugfixes" branch of the repository at

   git pull git://git.linux-nfs.org/projects/trondmy/nfs-2.6.git bugfixes

This will update the following files through the appended changesets.

  Cheers,
    Trond

----
 fs/nfs/dir.c            |   62 +++++++++++++++++++++++++---------------------
 fs/nfs/direct.c         |    2 +-
 fs/nfs/internal.h       |    9 +++++++
 fs/nfs/nfs2xdr.c        |    4 ++-
 fs/nfs/nfs3xdr.c        |    4 ++-
 fs/nfs/nfs4xdr.c        |    6 ++++-
 include/linux/nfs_xdr.h |    1 +
 net/sunrpc/clnt.c       |   24 +++++++++++-------
 8 files changed, 71 insertions(+), 41 deletions(-)

commit 0b26a0bf6ff398185546432420bb772bcfdf8d94
Author: Trond Myklebust <Trond.Myklebust@netapp.com>
Date:   Sat Nov 20 14:26:44 2010 -0500

    NFS: Ensure we return the dirent->d_type when it is known
    
    Store the dirent->d_type in the struct nfs_cache_array_entry so that we
    can use it in getdents() calls.
    
    This fixes a regression with the new readdir code.
    
    Signed-off-by: Trond Myklebust <Trond.Myklebust@netapp.com>

commit 3020093f578fb6c9acc6914dfd887a1ebd1db659
Author: Trond Myklebust <Trond.Myklebust@netapp.com>
Date:   Sat Nov 20 15:18:22 2010 -0500

    NFS: Correct the array bound calculation in nfs_readdir_add_to_array
    
    It looks as if the array size calculation in MAX_READDIR_ARRAY does not
    take the alignment of struct nfs_cache_array_entry into account.
    
    Signed-off-by: Trond Myklebust <Trond.Myklebust@netapp.com>

commit ece0b4233b6b915d1f63add2bd9f2733aec6317a
Author: Trond Myklebust <Trond.Myklebust@netapp.com>
Date:   Sat Nov 20 13:55:33 2010 -0500

    NFS: Don't ignore errors from nfs_do_filldir()
    
    We should ignore the errors from the filldir callback, and just interpret
    them as meaning we should exit, however we should definitely pass back
    ENOMEM errors.
    
    Signed-off-by: Trond Myklebust <Trond.Myklebust@netapp.com>

commit 85f8607e163f8d281fb407357279cb4ac6df12e6
Author: Trond Myklebust <Trond.Myklebust@netapp.com>
Date:   Sat Nov 20 13:24:49 2010 -0500

    NFS: Fix the error handling in "uncached_readdir()"
    
    Currently, uncached_readdir() is broken because if fails to handle
    the results from nfs_readdir_xdr_to_array() correctly.
    
    Signed-off-by: Trond Myklebust <Trond.Myklebust@netapp.com>

commit 7a8e1dc34f52fd2927dbf7e520d7cd8eadc51336
Author: Trond Myklebust <Trond.Myklebust@netapp.com>
Date:   Sat Nov 20 13:24:46 2010 -0500

    NFS: Fix a page leak in uncached_readdir()
    
    Signed-off-by: Trond Myklebust <Trond.Myklebust@netapp.com>

commit e7c58e974a0318fcca5368e7b3570e10e9ae9028
Author: Trond Myklebust <Trond.Myklebust@netapp.com>
Date:   Sat Nov 20 13:22:24 2010 -0500

    NFS: Fix a page leak in nfs_do_filldir()
    
    nfs_do_filldir() must always free desc->page when it is done, otherwise
    we end up leaking the page.
    
    Also remove unused variable 'dentry'.
    
    Signed-off-by: Trond Myklebust <Trond.Myklebust@netapp.com>

commit 5c346854d8ce6ca91931f8fc9177934257a667d0
Author: Trond Myklebust <Trond.Myklebust@netapp.com>
Date:   Sat Nov 20 12:43:45 2010 -0500

    NFS: Assume eof if the server returns no readdir records
    
    Some servers are known to be buggy w.r.t. this. Deal with them...
    
    Signed-off-by: Trond Myklebust <Trond.Myklebust@netapp.com>

commit 463a376eae1c92a66c912af539bfd4bbefa37673
Author: Trond Myklebust <Trond.Myklebust@netapp.com>
Date:   Sat Nov 20 12:22:20 2010 -0500

    NFS: Buffer overflow in ->decode_dirent() should not be fatal
    
    Overflowing the buffer in the readdir ->decode_dirent() should not lead to
    a fatal error, but rather to an attempt to reread the record in question.
    
    Signed-off-by: Trond Myklebust <Trond.Myklebust@netapp.com>

commit b47d19de2c714020ba8f5545a6e7d4968f37eb45
Author: Arun Bharadwaj <arun@linux.vnet.ibm.com>
Date:   Thu Nov 18 10:36:43 2010 +0000

    Pure nfs client performance using odirect.
    
    When an application opens a file with O_DIRECT flag, if the size of
    the data that is written is equal to wsize, the client sends a
    WRITE RPC with stable flag set to UNSTABLE followed by a single
    COMMIT RPC rather than sending a single WRITE RPC with the stable
    flag set to FILE_SYNC. This a bug.
    
    Patch to fix this.
    
    Signed-off-by: Arun R Bharadwaj <arun@linux.vnet.ibm.com>
    Signed-off-by: Trond Myklebust <Trond.Myklebust@netapp.com>

commit 5fc43978a79e8021c189660ab63249fd29c5fb32
Author: Trond Myklebust <Trond.Myklebust@netapp.com>
Date:   Sat Nov 20 11:13:31 2010 -0500

    SUNRPC: Fix an infinite loop in call_refresh/call_refreshresult
    
    If the rpcauth_refreshcred() call returns an error other than
    EACCES, ENOMEM or ETIMEDOUT, we currently end up looping forever
    between call_refresh and call_refreshresult.
    
    The correct thing to do here is to exit on all errors except
    EAGAIN and ETIMEDOUT, for which case we retry 3 times, then
    return EACCES.
    
    Signed-off-by: Trond Myklebust <Trond.Myklebust@netapp.com>


-- 
Trond Myklebust
Linux NFS client maintainer

NetApp
Trond.Myklebust@netapp.com
www.netapp.com

