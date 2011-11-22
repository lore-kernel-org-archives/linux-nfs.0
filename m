Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx2.netapp.com ([216.240.18.37]:28009 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755741Ab1KVLuP convert rfc822-to-8bit (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Tue, 22 Nov 2011 06:50:15 -0500
Message-ID: <1321962613.3323.69.camel@lade.trondhjem.org>
Subject: [GIT PULL] Please pull NFS client bugfixes
From: Trond Myklebust <Trond.Myklebust@netapp.com>
To: Linus Torvalds <torvalds@linux-foundation.org>
Cc: linux-nfs@vger.kernel.org, linux-kernel@vger.kernel.org
Date: Tue, 22 Nov 2011 13:50:13 +0200
Content-Type: text/plain; charset="UTF-8"
Mime-Version: 1.0
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Hi Linus,

Please pull from the "bugfixes" branch of the repository at

   git pull git://git.linux-nfs.org/projects/trondmy/linux-nfs.git bugfixes

This will update the following files through the appended changesets.

  Cheers,
    Trond

----
 fs/nfs/dir.c            |    2 +-
 fs/nfs/file.c           |   91 ++++++++++++++++++++++++++--------------------
 fs/nfs/inode.c          |    2 +-
 fs/nfs/internal.h       |    2 +
 fs/nfs/nfs3proc.c       |    1 +
 fs/nfs/nfs4proc.c       |    4 +-
 fs/nfs/pnfs.c           |   26 +++++++++++---
 fs/nfs/proc.c           |    1 +
 fs/nfs/read.c           |   14 +------
 include/linux/nfs_fs.h  |    3 ++
 include/linux/nfs_xdr.h |    1 +
 net/sunrpc/xprtsock.c   |    4 ++-
 12 files changed, 89 insertions(+), 62 deletions(-)

commit 62e4a76987eab2b7fa952546614bc83e5bfc9d3e
Author: Trond Myklebust <Trond.Myklebust@netapp.com>
Date:   Thu Nov 10 14:30:37 2011 -0500

    NFS: Revert pnfs ugliness from the generic NFS read code path
    
    pNFS-specific code belongs in the pnfs layer. It should not be
    hijacking generic NFS read or write code paths.
    
    Signed-off-by: Trond Myklebust <Trond.Myklebust@netapp.com>

commit 2aa13531bbbc6582874bedfcd853e1058b0fb4f9
Author: Stanislav Kinsbursky <skinsbursky@parallels.com>
Date:   Thu Nov 10 14:33:23 2011 +0300

    SUNRPC: destroy freshly allocated transport in case of sockaddr init error
    
    Otherwise we will leak xprt structure and struct net reference.
    
    Signed-off-by: Stanislav Kinsbursky <skinsbursky@parallels.com>
    Signed-off-by: Trond Myklebust <Trond.Myklebust@netapp.com>

commit a6f498a891c730327645a7afa10c5ae977de6fd8
Author: Trond Myklebust <Trond.Myklebust@netapp.com>
Date:   Mon Nov 7 15:50:32 2011 -0500

    NFS: Fix a regression in the referral code
    
    Fix a regression that was introduced by commit
    0c2e53f11a6dae9e3af5f50f5ad0382e7c3e0cfa (NFS: Remove the unused
    "lookupfh()" version of nfs4_proc_lookup()).
    
    In the case where the lookup gets an NFS4ERR_MOVED, we want to return
    the result of nfs4_get_referral(). Instead, that value is getting
    clobbered by the call to nfs4_handle_exception()...
    
    Reported-by: Tigran Mkrtchyan <tigran.mkrtchyan@desy.de>
    Tested-by: Tigran Mkrtchyan <tigran.mkrtchyan@desy.de>
    Signed-off-by: Trond Myklebust <Trond.Myklebust@netapp.com>

commit 0486958f57a496212e3c1e3d9194deebba3dc3d4
Author: Jeff Layton <jlayton@redhat.com>
Date:   Fri Nov 4 13:31:22 2011 -0400

    nfs: move nfs_file_operations declaration to bottom of file.c (try #2)
    
    ...a remove a set of forward declarations.
    
    Signed-off-by: Jeff Layton <jlayton@redhat.com>
    Signed-off-by: Trond Myklebust <Trond.Myklebust@netapp.com>

commit 1788ea6e3b2a58cf4fb00206e362d9caff8d86a7
Author: Jeff Layton <jlayton@redhat.com>
Date:   Fri Nov 4 13:31:21 2011 -0400

    nfs: when attempting to open a directory, fall back on normal lookup (try #5)
    
    commit d953126 changed how nfs_atomic_lookup handles an -EISDIR return
    from an OPEN call. Prior to that patch, that caused the client to fall
    back to doing a normal lookup. When that patch went in, the code began
    returning that error to userspace. The d_revalidate codepath however
    never had the corresponding change, so it was still possible to end up
    with a NULL ctx->state pointer after that.
    
    That patch caused a regression. When we attempt to open a directory that
    does not have a cached dentry, that open now errors out with EISDIR. If
    you attempt the same open with a cached dentry, it will succeed.
    
    Fix this by reverting the change in nfs_atomic_lookup and allowing
    attempts to open directories to fall back to a normal lookup
    
    Also, add a NFSv4-specific f_ops->open routine that just returns
    -ENOTDIR. This should never be called if things are working properly,
    but if it ever is, then the dprintk may help in debugging.
    
    To facilitate this, a new file_operations field is also added to the
    nfs_rpc_ops struct.
    
    Cc: stable@kernel.org
    Signed-off-by: Jeff Layton <jlayton@redhat.com>
    Signed-off-by: Trond Myklebust <Trond.Myklebust@netapp.com>


-- 
Trond Myklebust
Linux NFS client maintainer

NetApp
Trond.Myklebust@netapp.com
www.netapp.com

