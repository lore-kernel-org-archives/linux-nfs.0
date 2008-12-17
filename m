From: "J. Bruce Fields" <bfields@fieldses.org>
Subject: Re: [PATCH] lockd: handle fl_grant callbacks with coalesced locks
	(RFC)
Date: Wed, 17 Dec 2008 15:01:56 -0500
Message-ID: <20081217200156.GO4614@fieldses.org>
References: <1227130623-31607-1-git-send-email-jlayton@redhat.com> <20081122011555.GA28485@fieldses.org> <20081124103313.0c779324@tleilax.poochiereds.net> <20081124170653.GF17862@fieldses.org> <20081213074042.2e8223c3@tleilax.poochiereds.net> <20081216193806.GC18928@fieldses.org> <20081216195635.GD18928@fieldses.org> <20081216161158.2d173667@tleilax.poochiereds.net> <20081217191453.GA16777@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Jeff Layton <jlayton@redhat.com>, linux-nfs@vger.kernel.org
To: David Teigland <teigland@redhat.com>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mail.fieldses.org ([66.93.2.214]:42204 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751056AbYLQUB5 (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Wed, 17 Dec 2008 15:01:57 -0500
In-Reply-To: <20081217191453.GA16777@redhat.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Wed, Dec 17, 2008 at 01:14:53PM -0600, David Teigland wrote:
> On Tue, Dec 16, 2008 at 04:11:58PM -0500, Jeff Layton wrote:
> > On Tue, 16 Dec 2008 14:56:35 -0500
> > "J. Bruce Fields" <bfields@fieldses.org> wrote:
> > > After thinking a little more: the interface is a lot simpler if it's
> > > just a simple request and reply (with the reply for a lock identical to
> > > the request).  I believe that's more or less what gfs2 is already do
> > > internally, if we look at the posix lock upcalls it's making to
> > > userspace.  So it shouldn't be hard to fix gfs2 to hand us back a lock
> > > that doesn't take into account any coalescing.  If it needs to keep an
> > > extra (unmodified) copy of the lock around, that's OK.
> > > 
> > > Did you try that and find a reason that doesn't work?
> > > 
> > > --b.
> > > 
> > 
> > Agreed. That would be much simpler, I think...
> > 
> > I didn't try that, though I did consider it before wandering down the
> > rabbit hole. Dave, any thoughts?
> 
> Jeff suggested the following patch, which I've tried and it fixes the
> problem I was seeing.  It passes the original, unmodified file_lock to
> notify(), instead of the copy which is passed to (and coalesced by)
> posix_lock_file().  I'm guessing this was reason for having a copy of the
> file_lock in the first place, but it was just not used correctly.

Yep, that looks much better.  Though actually I suspect what was really
intended was to use "flc" for the notifies, and "fl" for the
posix_lock_file().

Also, since flc is never actually handed to the posix lock system, I
think it should be a "shallow" lock copy--so it should be created with
__locks_copy_lock().  Something like the below?

--b.

diff --git a/fs/dlm/plock.c b/fs/dlm/plock.c
index eba87ff..e8d9086 100644
--- a/fs/dlm/plock.c
+++ b/fs/dlm/plock.c
@@ -103,7 +103,7 @@ int dlm_posix_lock(dlm_lockspace_t *lockspace, u64 number, struct file *file,
 		op->info.owner	= (__u64) fl->fl_pid;
 		xop->callback	= fl->fl_lmops->fl_grant;
 		locks_init_lock(&xop->flc);
-		locks_copy_lock(&xop->flc, fl);
+		__locks_copy_lock(&xop->flc, fl);
 		xop->fl		= fl;
 		xop->file	= file;
 	} else {
@@ -173,8 +173,8 @@ static int dlm_plock_callback(struct plock_op *op)
 	}
 
 	/* got fs lock; bookkeep locally as well: */
-	flc->fl_flags &= ~FL_SLEEP;
-	if (posix_lock_file(file, flc, NULL)) {
+	fl->fl_flags &= ~FL_SLEEP;
+	if (posix_lock_file(file, fl, NULL)) {
 		/*
 		 * This can only happen in the case of kmalloc() failure.
 		 * The filesystem's own lock is the authoritative lock,
