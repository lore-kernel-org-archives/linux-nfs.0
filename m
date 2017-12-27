Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from aserp2130.oracle.com ([141.146.126.79]:46630 "EHLO
        aserp2130.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751881AbdL0UlH (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Wed, 27 Dec 2017 15:41:07 -0500
From: Chuck Lever <chuck.lever@oracle.com>
Content-Type: text/plain; charset=us-ascii
Subject: NFSv4.1 regression with v4.15-rc
Date: Wed, 27 Dec 2017 15:40:58 -0500
Message-Id: <337F485E-4E53-4EBF-8186-009326C281EC@oracle.com>
Cc: Trond Myklebust <trond.myklebust@primarydata.com>,
        Linux NFS Mailing List <linux-nfs@vger.kernel.org>
To: Bruce Fields <bfields@fieldses.org>,
        Bruce Fields <bfields@redhat.com>
Mime-Version: 1.0 (Mac OS X Mail 9.3 \(3124\))
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Hi Bruce-

Last week I updated my test server from v4.14 to v4.15-rc4, and began to
observe intermittent failures in the git regression suite on NFSv4.1. I
was able to reproduce these failures with NFSv4.1 on both TCP and RDMA,
yet there has not been a reproduction with NFSv3 or NFSv4.0.

The server hardware is a single-socket 4-core system with 32GB of RAM.
The export is a tmpfs. Networking is 56Gb InfiniBand (or IPoIB).

The git regression suite reports individual test failures in the SVN
and CVS tests. On occasion, the client mount point freezes, requiring
that the client be rebooted in order to unstick the mount.

Just before Christmas, I bisected the problem to:

commit 659aefb68eca28ba9aa482a9fc64de107332e256
Author: Trond Myklebust <trond.myklebust@primarydata.com>
Date:   Fri Nov 3 08:00:13 2017 -0400

    nfsd: Ensure we don't recognise lock stateids after freeing them
   =20
    In order to deal with lookup races, nfsd4_free_lock_stateid() needs
    to be able to signal to other stateful functions that the lock =
stateid
    is no longer valid. Right now, nfsd_lock() will check whether or not =
an
    existing stateid is still hashed, but only in the "new lock" path.
   =20
    To ensure the stateid invalidation is also recognised by the =
"existing lock"
    path, and also by a second call to nfsd4_free_lock_stateid() itself, =
we can
    change the type to NFS4_CLOSED_STID under the stp->st_mutex.
   =20
    Signed-off-by: Trond Myklebust <trond.myklebust@primarydata.com>
    Signed-off-by: J. Bruce Fields <bfields@redhat.com>


Since we're already at v4.15-rc5 I thought it would be best to break the
holiday moratorium instead of waiting another week to report this.


--
Chuck Lever



