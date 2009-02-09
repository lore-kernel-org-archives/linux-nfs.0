From: "J. Bruce Fields" <bfields@fieldses.org>
Subject: Re: [NLM] 2.6.27 broken
Date: Mon, 9 Feb 2009 13:10:36 -0500
Message-ID: <20090209181036.GI10297@fieldses.org>
References: <20081115132831.GA11329@janus> <20081120222731.GA591@fieldses.org> <20081128112447.GA25340@janus> <20081216173923.GE16388@fieldses.org> <1229456632.6023.1.camel@tucsk> <20081216201610.GE18928@fieldses.org> <20090204233348.GD20917@fieldses.org> <1233830829.4965.56.camel@tucsk> <20090205195203.GD9200@fieldses.org> <1233919798.4965.63.camel@tucsk>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Frank van Maarseveen <frankvm@frankvm.com>,
	Linux NFS mailing list <linux-nfs@vger.kernel.org>
To: Miklos Szeredi <mszeredi@suse.cz>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mail.fieldses.org ([141.211.133.115]:47551 "EHLO
	pickle.fieldses.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753934AbZBISKb (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 9 Feb 2009 13:10:31 -0500
In-Reply-To: <1233919798.4965.63.camel@tucsk>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Fri, Feb 06, 2009 at 12:29:58PM +0100, Miklos Szeredi wrote:
> On Thu, 2009-02-05 at 14:52 -0500, J. Bruce Fields wrote:
> > On Thu, Feb 05, 2009 at 11:47:09AM +0100, Miklos Szeredi wrote:
> > > But I think at least a comment in the code would be in order, or this
> > > same mistake might be made again.  Also I think the original code flow
> > > is somewhat illogical.
> > 
> > Yeah, I was literally just reverting the problematic lines of your
> > previous commit.  I'd rather keep it that way for now, just as a clear
> > separation between the revert/bugfix and the cleanup.
> 
> OK.
> 
> > > How about this (it's essentially the same patch just a bit rearranged,
> > > the authorship is still yours of course ;)
> > 
> > ... but would happily queue up the cleanup for 2.6.30.
> 
> Cool.
> 
> > Actually, I find it strange to have just that single case which breaks,
> > so that the code after the switch, which looks like it should be shared,
> > actually just applies to one case.  I'd be inclined to just suck
> > everything up to "out:" into the -EAGAIN case and then make all cases
> > "goto out" (or, equivalently, break).
> 
> Yes, but it needs to be sucked into the FILE_LOCK_DEFERRED case as well.
> It's just two lines and one of them is setting the error value, so it's
> not real duplication.

Whoops, right, missed that; so, I'm applying the below, sending the
fixup in now, and queuing up the cleanup for 2.6.30 (with the blame
assigned back to you, hah--object or have me add your signed-off-by).

--b.


commit c4a06d0957ea5b386b1cd83fa9a9d6c19b736346
Author: Miklos Szeredi <mszeredi@suse.cz>
Date:   Mon Feb 9 12:30:43 2009 -0500

    lockd: clean up blocking lock cases of nlsmvc_lock()
    
    No change in behavior, just rearranging the switch so that we break out
    of the switch if and only if we're in the wait case.
    
    Signed-off-by: J. Bruce Fields <bfields@citi.umich.edu>

diff --git a/fs/lockd/svclock.c b/fs/lockd/svclock.c
index 763b78a..83ee342 100644
--- a/fs/lockd/svclock.c
+++ b/fs/lockd/svclock.c
@@ -426,8 +426,15 @@ nlmsvc_lock(struct svc_rqst *rqstp, struct nlm_file *file,
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
-			break;
+			goto out;
 		case FILE_LOCK_DEFERRED:
 			if (wait)
 				break;
@@ -443,10 +450,6 @@ nlmsvc_lock(struct svc_rqst *rqstp, struct nlm_file *file,
 			goto out;
 	}
 
-	ret = nlm_lck_denied;
-	if (!wait)
-		goto out;
-
 	ret = nlm_lck_blocked;
 
 	/* Append to list of blocked */

commit 716cb6d7901f92bdfe1c80dbf4765027dceab384
Author: J. Bruce Fields <bfields@citi.umich.edu>
Date:   Wed Feb 4 17:35:38 2009 -0500

    lockd: fix regression in lockd's handling of blocked locks
    
    If a client requests a blocking lock, is denied, then requests it again,
    then here in nlmsvc_lock() we will call vfs_lock_file() without FL_SLEEP
    set, because we've already queued a block and don't need the locks code
    to do it again.
    
    But that means vfs_lock_file() will return -EAGAIN instead of
    FILE_LOCK_DENIED.  So we still need to translate that -EAGAIN return
    into a nlm_lck_blocked error in this case, and put ourselves back on
    lockd's block list.
    
    The bug was introduced by bde74e4bc64415b1 "locks: add special return
    value for asynchronous locks".
    
    Thanks to From: Frank van Maarseveen for the report; his original test
    case was essentially
    
    	for i in `seq 30`; do flock /nfsmount/foo sleep 10 & done
    
    Tested-by: Frank van Maarseveen <frankvm@frankvm.com>
    Reported-by: Frank van Maarseveen <frankvm@frankvm.com>
    Cc: Miklos Szeredi <mszeredi@suse.cz>
    Signed-off-by: J. Bruce Fields <bfields@citi.umich.edu>

diff --git a/fs/lockd/svclock.c b/fs/lockd/svclock.c
index 6063a8e..763b78a 100644
--- a/fs/lockd/svclock.c
+++ b/fs/lockd/svclock.c
@@ -427,7 +427,7 @@ nlmsvc_lock(struct svc_rqst *rqstp, struct nlm_file *file,
 			goto out;
 		case -EAGAIN:
 			ret = nlm_lck_denied;
-			goto out;
+			break;
 		case FILE_LOCK_DEFERRED:
 			if (wait)
 				break;
@@ -443,6 +443,10 @@ nlmsvc_lock(struct svc_rqst *rqstp, struct nlm_file *file,
 			goto out;
 	}
 
+	ret = nlm_lck_denied;
+	if (!wait)
+		goto out;
+
 	ret = nlm_lck_blocked;
 
 	/* Append to list of blocked */
