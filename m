Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from fieldses.org ([174.143.236.118]:47469 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755168Ab0LMV24 (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Mon, 13 Dec 2010 16:28:56 -0500
Date: Mon, 13 Dec 2010 16:28:55 -0500
To: Linus Torvalds <torvalds@linux-foundation.org>
Cc: linux-nfs@vger.kernel.org, Neil Brown <neilb@suse.de>
Subject: nfsd bugfixes for 2.6.37
Message-ID: <20101213212855.GA9394@fieldses.org>
Content-Type: text/plain; charset=us-ascii
From: "J. Bruce Fields" <bfields@fieldses.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

Two nfsd bugfixes are available in the for-2.6.37 branch at:

  git://linux-nfs.org/~bfields/linux.git for-2.6.37

Huh--Neil needs to decide whether or not there's a space in his name.

--b.

Neil Brown (1):
      nfsd: Fix possible BUG_ON firing in set_change_info

NeilBrown (1):
      sunrpc: prevent use-after-free on clearing XPT_BUSY

 fs/nfsd/nfs3xdr.c     |    6 ++++--
 fs/nfsd/xdr4.h        |   21 ++++++++++-----------
 net/sunrpc/svc_xprt.c |    9 ++++++++-
 3 files changed, 22 insertions(+), 14 deletions(-)

commit c1ac3ffcd0bc7e9617f62be8c7043d53ab84deac
Author: Neil Brown <neilb@suse.de>
Date:   Thu Dec 2 11:14:30 2010 +1100

    nfsd: Fix possible BUG_ON firing in set_change_info
    
    If vfs_getattr in fill_post_wcc returns an error, we don't
    set fh_post_change.
    For NFSv4, this can result in set_change_info triggering a BUG_ON.
    i.e. fh_post_saved being zero isn't really a bug.
    
    So:
     - instead of BUGging when fh_post_saved is zero, just clear ->atomic.
     - if vfs_getattr fails in fill_post_wcc, take a copy of i_ctime anyway.
       This will be used i seg_change_info, but not overly trusted.
     - While we are there, remove the pointless 'if' statements in set_change_info.
       There is no harm setting all the values.
    
    Signed-off-by: NeilBrown <neilb@suse.de>
    Cc: stable@kernel.org
    Signed-off-by: J. Bruce Fields <bfields@redhat.com>

commit ed2849d3ecfa339435818eeff28f6c3424300cec
Author: NeilBrown <neilb@suse.de>
Date:   Tue Nov 16 16:55:19 2010 +1100

    sunrpc: prevent use-after-free on clearing XPT_BUSY
    
    When an xprt is created, it has a refcount of 1, and XPT_BUSY is set.
    The refcount is *not* owned by the thread that created the xprt
    (as is clear from the fact that creators never put the reference).
    Rather, it is owned by the absence of XPT_DEAD.  Once XPT_DEAD is set,
    (And XPT_BUSY is clear) that initial reference is dropped and the xprt
    can be freed.
    
    So when a creator clears XPT_BUSY it is dropping its only reference and
    so must not touch the xprt again.
    
    However svc_recv, after calling ->xpo_accept (and so getting an XPT_BUSY
    reference on a new xprt), calls svc_xprt_recieved.  This clears
    XPT_BUSY and then svc_xprt_enqueue - this last without owning a reference.
    This is dangerous and has been seen to leave svc_xprt_enqueue working
    with an xprt containing garbage.
    
    So we need to hold an extra counted reference over that call to
    svc_xprt_received.
    
    For safety, any time we clear XPT_BUSY and then use the xprt again, we
    first get a reference, and the put it again afterwards.
    
    Note that svc_close_all does not need this extra protection as there are
    no threads running, and the final free can only be called asynchronously
    from such a thread.
    
    Signed-off-by: NeilBrown <neilb@suse.de>
    Cc: stable@kernel.org
    Signed-off-by: J. Bruce Fields <bfields@redhat.com>
