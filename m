From: Miklos Szeredi <mszeredi@suse.cz>
Subject: Re: [NLM] 2.6.27 broken
Date: Thu, 05 Feb 2009 11:47:09 +0100
Message-ID: <1233830829.4965.56.camel@tucsk>
References: <20081115132831.GA11329@janus>
	 <20081120222731.GA591@fieldses.org> <20081128112447.GA25340@janus>
	 <20081216173923.GE16388@fieldses.org> <1229456632.6023.1.camel@tucsk>
	 <20081216201610.GE18928@fieldses.org> <20090204233348.GD20917@fieldses.org>
Mime-Version: 1.0
Content-Type: text/plain
Cc: Frank van Maarseveen <frankvm@frankvm.com>,
	Linux NFS mailing list <linux-nfs@vger.kernel.org>
To: "J. Bruce Fields" <bfields@fieldses.org>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from styx.suse.cz ([82.119.242.94]:58537 "EHLO mail.suse.cz"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S1751065AbZBEKrN (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Thu, 5 Feb 2009 05:47:13 -0500
In-Reply-To: <20090204233348.GD20917@fieldses.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Wed, 2009-02-04 at 18:33 -0500, J. Bruce Fields wrote:
> On Tue, Dec 16, 2008 at 03:16:10PM -0500, bfields wrote:
> > On Tue, Dec 16, 2008 at 08:43:52PM +0100, Miklos Szeredi wrote:
> > > On Tue, 2008-12-16 at 12:39 -0500, J. Bruce Fields wrote:
> > > > More precisely, it looks like this started with
> > > > 
> > > > 	bde74e4bc64415b142e "locks: add special return value for
> > > > 		asynchronous locks"
> > > > 
> > > > But I haven't had the chance to look any harder yet.  Miklos?  Is this
> > > > easy for you to reproduce?
> > > 
> > > Not immediately, at the moment I don't have NFS set up.  But if you
> > > don't beat me to it, I'll look into this.
> > 
> > OK, thanks.  I'll take another look too when I get the chance, so let me
> > know of any partial result.
> > 
> > It may just for example be returning the wrong error to the client on an
> > nlm blocking lock request, so that the client assumes the lock is gone
> > and goes away rather than waiting for a grant request.
> 
> Sorry, I've gotten a bit backlogged, but I finally got back to this.  If
> there's no objections, the following is what I intend to submit.

OK (though I don't really understand why we make a lock request to the
VFS _at all_ if we know the lock is already queued???).

But I think at least a comment in the code would be in order, or this
same mistake might be made again.  Also I think the original code flow
is somewhat illogical.

How about this (it's essentially the same patch just a bit rearranged,
the authorship is still yours of course ;)

Thanks,
Miklos

Index: linux-2.6/fs/lockd/svclock.c
===================================================================
--- linux-2.6.orig/fs/lockd/svclock.c	2009-01-26 14:47:48.000000000 +0100
+++ linux-2.6/fs/lockd/svclock.c	2009-02-05 11:42:20.000000000 +0100
@@ -426,6 +426,13 @@ nlmsvc_lock(struct svc_rqst *rqstp, stru
 			ret = nlm_granted;
 			goto out;
 		case -EAGAIN:
+			/*
+			 * If this is a blocking request for an
+			 * already pending lock request then we need
+			 * to put it back on lockd's block list
+			 */
+			if (wait)
+				break;
 			ret = nlm_lck_denied;
 			goto out;
 		case FILE_LOCK_DEFERRED:




