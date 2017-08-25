Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx2.suse.de ([195.135.220.15]:47448 "EHLO mx1.suse.de"
        rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
        id S1754239AbdHYHgS (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Fri, 25 Aug 2017 03:36:18 -0400
From: NeilBrown <neilb@suse.com>
To: Trond Myklebust <trond.myklebust@primarydata.com>,
        Anna Schumaker <anna.schumaker@netapp.com>
Date: Fri, 25 Aug 2017 17:34:41 +1000
Subject: [PATCH 0/2] Resolve d_weak_revalidate issues in NFS
Cc: linux-nfs@vger.kernel.org, Jeff Layton <jlayton@redhat.com>
Message-ID: <150364635600.31291.11905399689488751395.stgit@noble>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Following my recent investigations into d_weak_revalidate
I offer these two patches.  The first fixes two closely
related bugs caused by the introduction of d_weak_revalidate.
The second provides a minor code cleanup.

It seems we really do need d_weak_revalidate, but we might
need better documentation describing its purpose.

Thanks,
NeilBrown


---

NeilBrown (2):
      NFS: revalidate "." etc correctly on "open".
      NFS: remove special-case revalidate in nfs_opendir()


 fs/nfs/dir.c |   11 ++---------
 1 file changed, 2 insertions(+), 9 deletions(-)

--
Signature

