Return-Path: linux-nfs-owner@vger.kernel.org
Received: from fieldses.org ([174.143.236.118]:49805 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753913Ab1LXXui (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Sat, 24 Dec 2011 18:50:38 -0500
Date: Sat, 24 Dec 2011 18:50:35 -0500
From: "J. Bruce Fields" <bfields@fieldses.org>
To: Al Viro <viro@ZenIV.linux.org.uk>
Cc: Linus Torvalds <torvalds@linux-foundation.org>, linux-nfs@vger.kernel.org,
        linux-fsdevel@vger.kernel.org, linux-kernel@vger.kernel.org
Subject: Re: file locking fix for 3.2
Message-ID: <20111224235035.GA23711@fieldses.org>
References: <20111224215012.GA23495@fieldses.org>
 <20111224225525.GR23916@ZenIV.linux.org.uk>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <20111224225525.GR23916@ZenIV.linux.org.uk>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Sat, Dec 24, 2011 at 10:55:25PM +0000, Al Viro wrote:
> On Sat, Dec 24, 2011 at 04:50:12PM -0500, J. Bruce Fields wrote:
> 
> >     locks: fix null dereference on lease-break failure path
> >     
> >     Commit 778fc546f749c588aa2f6cd50215d2715c374252 "locks: fix tracking of
> >     inprogress lease breaks" introduced a null dereference on failure to
> >     allocate memory.
> >     
> >     This means an open (without O_NONBLOCK set) on a file with a lease
> >     applied (generally only done when Samba or nfsd (with v4) is running)
> >     could crash if a kmalloc() fails.
> 
> NULL?  AFAICS, lease_alloc() returns ERR_PTR() on failure...

Erp, you're right.

(The fix is still right, it's the changelog that's wrong; happy to
fix and resend if it's wanted....)

> I really
> don't like the look of that code, TBH - at the very least it needs to
> be commented a lot.  E.g. the rules for calling or not calling ->lm_break()
> are really not obvious - AFAICS, we do that if
> 	i_have_this_lease || (mode & O_NONBLOCK)
> is true *or* if allocation has succeeded.  The former condition is what'll
> end up with -EWOULDBLOCK; I can understand not wanting to return that in
> preference to -ENOMEM, but...  Do we want to skip ->lm_break() stuff only
> in case of allocation failures that won't be overridden by -EWOULDBLOCK?

We do want to break leases at least in the O_NONBLOCK case so that a
caller can make forward progress by retrying open(.,O_NONBLOCK).

In the other cases I don't think there's any logic to the current
behavior.  Something like:

-	if (IS_ERR(new_fl) && !i_have_this_lease
-			&& ((mode & O_NONBLOCK) == 0)) {
-		error = PTR_ERR(new_fl);
-		goto out;
-	}
-
...
 		error = -EWOULDBLOCK;
 		goto out;
 	}
-
+	if (IS_ERR(new_fl)) {
+		error = PTR_ERR(new_fl);
+		goto out;
+	}
 restart:
 	break_time = flock->fl_break_time;
 	if (break_time != 0) {

would be a little less convoluted.

Or we could just do it the really obvious way:

 	new_fl = lease_alloc(NULL, want_write ? F_WRLCK : F_RDLCK);
+	if (IS_ERR(new_fl))
+		return PTR_ERR(new_fl);
 
 	lock_flocks();
... 
-	if (IS_ERR(new_fl) && !i_have_this_lease
-			&& ((mode & O_NONBLOCK) == 0)) {
-		error = PTR_ERR(new_fl);
-		goto out;
-	}
-

Then you're returning -ENOMEM in a case when we really didn't need to do
an allocation, but is that really a problem?  It's a rare case, and
opens can already fail with -ENOMEM for other reasons, and I'd rather
not have the extra hair.

?

--b.
