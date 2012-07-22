Return-Path: linux-nfs-owner@vger.kernel.org
Received: from 1010ds2-suoe.0.fullrate.dk ([90.184.90.115]:27274 "EHLO
	swampdragon.chaosbits.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752602Ab2GVVBq (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Sun, 22 Jul 2012 17:01:46 -0400
Date: Sun, 22 Jul 2012 23:01:44 +0200 (CEST)
From: Jesper Juhl <jj@chaosbits.net>
To: "J. Bruce Fields" <bfields@fieldses.org>
cc: linux-nfs@vger.kernel.org, linux-kernel@vger.kernel.org,
        Kendrick Smith <kmsmith@umich.edu>, Andy Adamson <kandros@umich.edu>,
        Trond Myklebust <Trond.Myklebust@netapp.com>
Subject: Re: [PATCH] NFS4: Fix NULL deref in nfsd4_lock() by makeing
 unhash_lockowner() safe to call with NULL arg
In-Reply-To: <20120130214351.GA1518@fieldses.org>
Message-ID: <alpine.LNX.2.00.1207222300380.31033@swampdragon.chaosbits.net>
References: <alpine.LNX.2.00.1201292226380.27749@swampdragon.chaosbits.net> <20120130214351.GA1518@fieldses.org>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Mon, 30 Jan 2012, J. Bruce Fields wrote:

> On Sun, Jan 29, 2012 at 10:29:24PM +0100, Jesper Juhl wrote:
> > The Coverity checker noticed a path through nfsd4_lock() where we call
> > release_lockowner(lock_sop); (at the 'out:' label) where 'lock_sop' is
> > NULL.
> > That goes bad since release_lockowner() calls unhash_lockowner() which
> > dereferences its argument.
> > release_lockowner() also calls nfs4_free_lockowner(), but that's not a
> > problem since that function just calls kfree() and kmem_cache_free(),
> > both of which are safe to call with NULL as argument.
> > 
> > There are several ways to fix the bug.
> >  - rework nfsd4_lock() so the call to release_lockowner(NULL) will never happen.
> >  - let release_lockowner() test for NULL and return if given one.
> >  - let unhash_lockowner() test for NULL and return if given one (which makes both it and release_lockowner() safe).
> > 
> > I chose the last option for this patch.
> > 
> > For information, the path Coverity spotted (in defect report 201504) is this:
> > 
> ...
> 
> 
> > [...]
> > 4098out:
> > At conditional (12): "status" taking the true branch.
> > At conditional (13): "new_state" taking the true branch.
> > 4099        if (status && new_state)
> 
> new_state is initialized false, and referenced otherwise only once,
> when a reference ot is is passed here:
> 
> 
> > 4010                status = lookup_or_create_lock_state(cstate, open_stp, lock,
> > 4011                                                        &lock_stp, &new_state);
> 
> so if new_state is true, then lookup_or_create_lock_state() set it to
> true.  But it sets that only in one spot, at the end:
> 
> 	*new = true;
> 	return nfs_ok;
> 
> Note nfs_ok is zero.  Therefore:
> 
> > At conditional (11): "status" taking the true branch.
> > 4012                if (status)
> > 4013                        goto out;
> 
> this could not have happened.
> 
> So it looks like a Coverity bug.
> 
Sorry about the late reply, I managed to completely miss this mail until I 
wen't to check up on some of my old patches.

Thank you for the feedback. I've dropped my local copy of this patch.

-- 
Jesper Juhl <jj@chaosbits.net>       http://www.chaosbits.net/
Don't top-post http://www.catb.org/jargon/html/T/top-post.html
Plain text mails only, please.

