From: David Teigland <teigland@redhat.com>
Subject: Re: [PATCH] lockd: handle fl_grant callbacks with coalesced locks (RFC)
Date: Wed, 17 Dec 2008 13:14:53 -0600
Message-ID: <20081217191453.GA16777@redhat.com>
References: <1227130623-31607-1-git-send-email-jlayton@redhat.com> <20081122011555.GA28485@fieldses.org> <20081124103313.0c779324@tleilax.poochiereds.net> <20081124170653.GF17862@fieldses.org> <20081213074042.2e8223c3@tleilax.poochiereds.net> <20081216193806.GC18928@fieldses.org> <20081216195635.GD18928@fieldses.org> <20081216161158.2d173667@tleilax.poochiereds.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: "J. Bruce Fields" <bfields@fieldses.org>, linux-nfs@vger.kernel.org
To: Jeff Layton <jlayton@redhat.com>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mx2.redhat.com ([66.187.237.31]:51653 "EHLO mx2.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751099AbYLQTRa (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Wed, 17 Dec 2008 14:17:30 -0500
In-Reply-To: <20081216161158.2d173667-RtJpwOs3+0O+kQycOl6kW4xkIHaj4LzF@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Tue, Dec 16, 2008 at 04:11:58PM -0500, Jeff Layton wrote:
> On Tue, 16 Dec 2008 14:56:35 -0500
> "J. Bruce Fields" <bfields@fieldses.org> wrote:
> > After thinking a little more: the interface is a lot simpler if it's
> > just a simple request and reply (with the reply for a lock identical to
> > the request).  I believe that's more or less what gfs2 is already do
> > internally, if we look at the posix lock upcalls it's making to
> > userspace.  So it shouldn't be hard to fix gfs2 to hand us back a lock
> > that doesn't take into account any coalescing.  If it needs to keep an
> > extra (unmodified) copy of the lock around, that's OK.
> > 
> > Did you try that and find a reason that doesn't work?
> > 
> > --b.
> > 
> 
> Agreed. That would be much simpler, I think...
> 
> I didn't try that, though I did consider it before wandering down the
> rabbit hole. Dave, any thoughts?

Jeff suggested the following patch, which I've tried and it fixes the
problem I was seeing.  It passes the original, unmodified file_lock to
notify(), instead of the copy which is passed to (and coalesced by)
posix_lock_file().  I'm guessing this was reason for having a copy of the
file_lock in the first place, but it was just not used correctly.

diff --git a/fs/dlm/plock.c b/fs/dlm/plock.c
index eba87ff..502b1ea 100644
--- a/fs/dlm/plock.c
+++ b/fs/dlm/plock.c
@@ -168,7 +168,7 @@ static int dlm_plock_callback(struct plock_op *op)
 	notify = xop->callback;
 
 	if (op->info.rv) {
-		notify(flc, NULL, op->info.rv);
+		notify(fl, NULL, op->info.rv);
 		goto out;
 	}
 
@@ -187,7 +187,7 @@ static int dlm_plock_callback(struct plock_op *op)
 			  (unsigned long long)op->info.number, file, fl);
 	}
 
-	rv = notify(flc, NULL, 0);
+	rv = notify(fl, NULL, 0);
 	if (rv) {
 		/* XXX: We need to cancel the fs lock here: */
 		log_print("dlm_plock_callback: lock granted after lock request "
