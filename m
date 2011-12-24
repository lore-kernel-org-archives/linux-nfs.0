Return-Path: linux-nfs-owner@vger.kernel.org
Received: from zeniv.linux.org.uk ([195.92.253.2]:47310 "EHLO
	ZenIV.linux.org.uk" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753050Ab1LXWz3 (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Sat, 24 Dec 2011 17:55:29 -0500
Date: Sat, 24 Dec 2011 22:55:25 +0000
From: Al Viro <viro@ZenIV.linux.org.uk>
To: "J. Bruce Fields" <bfields@fieldses.org>
Cc: Linus Torvalds <torvalds@linux-foundation.org>, linux-nfs@vger.kernel.org,
        linux-fsdevel@vger.kernel.org, linux-kernel@vger.kernel.org
Subject: Re: file locking fix for 3.2
Message-ID: <20111224225525.GR23916@ZenIV.linux.org.uk>
References: <20111224215012.GA23495@fieldses.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <20111224215012.GA23495@fieldses.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Sat, Dec 24, 2011 at 04:50:12PM -0500, J. Bruce Fields wrote:

>     locks: fix null dereference on lease-break failure path
>     
>     Commit 778fc546f749c588aa2f6cd50215d2715c374252 "locks: fix tracking of
>     inprogress lease breaks" introduced a null dereference on failure to
>     allocate memory.
>     
>     This means an open (without O_NONBLOCK set) on a file with a lease
>     applied (generally only done when Samba or nfsd (with v4) is running)
>     could crash if a kmalloc() fails.

NULL?  AFAICS, lease_alloc() returns ERR_PTR() on failure...  I really
don't like the look of that code, TBH - at the very least it needs to
be commented a lot.  E.g. the rules for calling or not calling ->lm_break()
are really not obvious - AFAICS, we do that if
	i_have_this_lease || (mode & O_NONBLOCK)
is true *or* if allocation has succeeded.  The former condition is what'll
end up with -EWOULDBLOCK; I can understand not wanting to return that in
preference to -ENOMEM, but...  Do we want to skip ->lm_break() stuff only
in case of allocation failures that won't be overridden by -EWOULDBLOCK?
