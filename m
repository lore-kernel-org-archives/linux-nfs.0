Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from moutng.kundenserver.de ([212.227.17.10]:50520 "EHLO
	moutng.kundenserver.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752261Ab0J0Tsw (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Wed, 27 Oct 2010 15:48:52 -0400
From: Arnd Bergmann <arnd@arndb.de>
To: Linus Torvalds <torvalds@linux-foundation.org>
Subject: Re: nfsd changes for 2.6.37
Date: Wed, 27 Oct 2010 21:48:47 +0200
Cc: "J. Bruce Fields" <bfields@fieldses.org>,
        Christoph Hellwig <hch@infradead.org>,
        Bryan Schumaker <bjschuma@netapp.com>, linux-nfs@vger.kernel.org,
        linux-kernel@vger.kernel.org
References: <20101026164549.GD19445@fieldses.org> <AANLkTimZSj7Y8KUic-VLSgrPFTf5wc_KRdfedzLAkNKT@mail.gmail.com> <AANLkTin53pdmfaBahExgi79XjaeFtP5wCS=rrKxfrAHs@mail.gmail.com>
In-Reply-To: <AANLkTin53pdmfaBahExgi79XjaeFtP5wCS=rrKxfrAHs@mail.gmail.com>
Content-Type: Text/Plain;
  charset="iso-8859-1"
Message-Id: <201010272148.47376.arnd@arndb.de>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

On Wednesday 27 October 2010 20:43:59 Linus Torvalds wrote:
> On Wed, Oct 27, 2010 at 11:42 AM, Linus Torvalds
> <torvalds@linux-foundation.org> wrote:
> >
> > Feel free to edit the message/patch to your hearts content.
> 
> Oh, and if you want me to just commit this part, I can do so. It
> doesn't make much sense without the other parts to actually make it
> useful, though, so it probably makes more sense to come with them.

Once Bruce is happy with the test results, you can pull it from

git+ssh://master.kernel.org/pub/scm/linux/kernel/git/arnd/bkl.git flock

I've rewritten all the changelogs to make more sense as a series,
and split out the bits that turn lock_flocks into a spinlock to
come last, so we get a bisectable series.

The contents are left unchanged.

	Arnd
---

commit b3426739cc8f7c7dd127ca8dad5e25195930cac1
Author: Arnd Bergmann <arnd@arndb.de>
Date:   Wed Oct 27 21:39:58 2010 +0200

    locks: turn lock_flocks into a spinlock
    
    Nothing depends on lock_flocks using the BKL
    any more, so we can do the switch over to
    a private spinlock.
    
    Signed-off-by: Arnd Bergmann <arnd@arndb.de>

 fs/Kconfig |    1 -
 fs/locks.c |    5 +++--
 2 files changed, 3 insertions(+), 3 deletions(-)

commit 55d3ff97c5c0b3dce39f705e2b1fe85818891822
Author: Linus Torvalds <torvalds@linux-foundation.org>
Date:   Wed Oct 27 12:38:12 2010 -0400

    locks: avoid fasync allocation under lock_flocks
    
    This splits fasync_helper into four functions: fasync_alloc,
    fasync_free, fasync_insert_entry and fasync_remove_entry,
    in order to allow the lease handling to call them directly
    instead of going through fasync_helper.
    
    The fasync_helper interface really doesn't make sense outside
    of ->fasync file operations, which use the same calling
    conventions of passing flags in and out as the helper.
    
    After the change, fcntl_setlease can simply allocate the
    new fasync_struct outside of lock_flocks, which is required
    to turn that into a spinlock.
    
    Signed-off-by: Linus Torvalds <torvalds@linux-foundation.org>
    [bfields@redhat.com: rebase on top of my changes to Arnd's patch]
    Signed-off-by: J. Bruce Fields <bfields@redhat.com>
    [arnd: rewrite changelog text]
    Signed-off-by: Arnd Bergmann <arnd@arndb.de>

 fs/fcntl.c         |   66 +++++++++++++++++++++++++++++++++++++++------------
 fs/locks.c         |   18 +++++++++++++-
 include/linux/fs.h |    5 ++++
 3 files changed, 72 insertions(+), 17 deletions(-)

commit c5b1f0d92c36851aca09ac6c7c0c4f9690ac14f3
Author: Arnd Bergmann <arnd@arndb.de>
Date:   Wed Oct 27 15:46:08 2010 +0200

    locks/nfsd: allocate file lock outside of spinlock
    
    As suggested by Christoph Hellwig, this moves allocation
    of new file locks out of generic_setlease into the
    callers, nfs4_open_delegation and fcntl_setlease in order
    to allow GFP_KERNEL allocations when lock_flocks has
    become a spinlock.
    
    Signed-off-by: Arnd Bergmann <arnd@arndb.de>
    Acked-by: J. Bruce Fields <bfields@redhat.com>

 fs/locks.c          |   36 ++++++++++++------------------------
 fs/nfsd/nfs4state.c |   26 +++++++++++++++-----------
 include/linux/fs.h  |    1 +
 3 files changed, 28 insertions(+), 35 deletions(-)

commit a282a1fa6b23bd21ba0b86e53ed2a316b001836f
Author: J. Bruce Fields <bfields@redhat.com>
Date:   Tue Oct 26 18:25:30 2010 -0400

    lockd: fix nlmsvc_notify_blocked locking
    
    nlmsvc_notify_blocked walks the nlm_blocked list,
    which requires nlm_blocked_lock.
    
    Signed-off-by: J. Bruce Fields <bfields@redhat.com>
    Signed-off-by: Arnd Bergmann <arnd@arndb.de>

 fs/lockd/svclock.c |    6 ++++--
 1 files changed, 4 insertions(+), 2 deletions(-)

commit 763641d81202834e9d64de2019d1edec12868f4f
Author: Arnd Bergmann <arnd@arndb.de>
Date:   Tue Oct 26 22:55:40 2010 +0200

    lockd: push lock_flocks down
    
    lockd should use lock_flocks() instead of lock_kernel()
    to lock against posix locks accessing the i_flock list.
    
    This is a prerequisite to turning lock_flocks into a
    spinlock.
    
    Signed-off-by: Arnd Bergmann <arnd@arndb.de>
    Acked-by: J. Bruce Fields <bfields@redhat.com>

 fs/lockd/svc.c     |   11 -----------
 fs/lockd/svcsubs.c |    9 ++++++++-
 fs/nfs/Kconfig     |    1 -
 fs/nfsd/Kconfig    |    1 -
 4 files changed, 8 insertions(+), 14 deletions(-)
