Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from out1.smtp.messagingengine.com ([66.111.4.25]:57838 "EHLO
	out1.smtp.messagingengine.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1753200Ab1BXKHl (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 24 Feb 2011 05:07:41 -0500
Subject: Re: [PATCH 0/3] Fixes for vfs-scale and vfs-automount
From: Ian Kent <raven@themaw.net>
To: Al Viro <viro@ZenIV.linux.org.uk>
Cc: Trond Myklebust <Trond.Myklebust@netapp.com>,
        David Howells <dhowells@redhat.com>,
        Kernel Mailing List <linux-kernel@vger.kernel.org>,
        linux-fsdevel <linux-fsdevel@vger.kernel.org>,
        Linus Torvalds <torvalds@linux-foundation.org>,
        Andrew Morton <akpm@linux-foundation.org>,
        Linux NFS Mailing List <linux-nfs@vger.kernel.org>, npiggin@gmail.com
In-Reply-To: <20110224070724.GW22723@ZenIV.linux.org.uk>
References: <20110118040449.23109.33071.stgit@localhost6.localdomain6>
	 <1295420817.3076.24.camel@perseus> <1297779902.13007.86.camel@perseus>
	 <20110224015817.GQ22723@ZenIV.linux.org.uk>
	 <1298516618.2916.20.camel@perseus>
	 <20110224031439.GR22723@ZenIV.linux.org.uk>
	 <1298518137.2916.35.camel@perseus>
	 <20110224035836.GS22723@ZenIV.linux.org.uk>
	 <1298529260.2916.91.camel@perseus>
	 <20110224070724.GW22723@ZenIV.linux.org.uk>
Content-Type: text/plain; charset="UTF-8"
Date: Thu, 24 Feb 2011 18:07:33 +0800
Message-ID: <1298542053.3058.56.camel@perseus>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

On Thu, 2011-02-24 at 07:07 +0000, Al Viro wrote: 
> On Thu, Feb 24, 2011 at 02:34:20PM +0800, Ian Kent wrote:
> 
> > It does now but it doesn't do a whole lot, just checks for a negative
> > dentry, returning false, and drops out of RCU mode when the dentry isn't
> > selected or being checked for expiry yet.
> 
> Er?  Where does ->d_revalidate() exist in fs/autofs4?  Mainline doesn't
> have anything of that kind...

Sorry, that's just in my testing source.

> 
> > I've seen walks fail with a dentry that has gone away (ie. I'm walking
> > in a tree that is being expired, they seem to be trees with no actual
> > mount at their base), which should be because I'm not catching the block
> > request at a higher level dentry. Unfortunately, including a check for
> > the base dentry in __follow_mount_rcu(), regardless of it being a
> > mountpoint, doesn't always catch the need to block either. That the tree
> > is being selected for expire is probably because the expire can't detect
> > a walk within the mount tree when the walker is between the
> > __d_lookup_rcu() and __follow_mount_rcu() calls. Jumping out of rcu-walk
> > mode in an added revalidate reduces the possibility of this happening
> > (assuming walks are sneaking in between dropping and acquiring the
> > vfsmount_lock) but doesn't eliminate it. 
> > 
> > At this point I loop back to the trying to work out why a reference gets
> > picked up and the cycle repeats with various small changes to the
> > overall approach.
> > 
> > Actually, it's not just the root of a mount that is getting an extra
> > reference either. When I notice a root dentry has picked up a reference
> > (from a printk) and SIGKILL everything and start umounting manually I
> > get to a point in the tree where I need to umount autofs mounts twice,
> > which usually means nothing more than a get/put mismatch somewhere, but
> > in that case I normally don't see a root dentry pick up a reference.
> > That's confusing me too.
> 
> OK, now I'm really confused.  Where does your tree live?

Sorry.

> 
> I really don't like the look of autofs4_tree_busy(), BTW - you don't need
> RCU to get races here; just a plain chdir("../../.."); done by a process
> that sits deep enough in subtree you are checking can very well race with
> your check, so that your iterator gets through the new cwd before chdir()
> and through the old one after it...

Yes, that's a problem.

Previously the dcache_lock would have blocked on the dput() ... mmm, I'd
missed that so far, although Nick didn't talk with me about his changes
very much at all and I didn't pay enough attention to his patch series
along the way, oops!

> 
> Maybe I'm missing something subtle here.  A braindump on how you expect
> all "we choose dentry for expiry" stuff to work and what is really required
> from it would be nice...

Anything that has a reference count that reflects an open file or pwd is
considered busy. In some places only the dentry count is used but that's
mostly used (or was) to check for a concurrent path walk on the dentry
and was an optimization to bail out early.

A direct mount may have mount directly upon it and is checked for expiry
using may_umount_tree() on the root dentry and then the idle time is
checked.

An indirect mount may have mounts on dentrys within the root and it uses
may_umount_tree() and then checks idle time. It is supposed to ignore
mounts that are themselves autofs mounts (within the root directory) and
they are expected to be expired separately. If it sees any of those then
the mount is immediately considered busy.

Both indirect mount dentrys and direct mounts may have a tree of mounts
mounted on them, with or without a mount at the base. In these cases
anything mounted underneath, except for autofs trigger mounts, should
cause the tree to be seen as busy. In particular, submounts (an
independent indirect mount in itself) will have an ioctl file handle
open on it for its lifetime as will trigger mounts with a mount upon
them. 

When checking a direct mount or indirect mount dentry the super block
fs_lock is held which is meant to be used to prevent walks into that
dentry tree during the expire check. As you mentioned before fs_lock
should be a mutex not a spin lock, I agree.

When selected the AUTOFS_INF_EXPIRING flag is set as a result of the
expire check that, in conjunction with the fs_lock, should allow
processes to be blocked by autofs while a mount or tree of mounts is
expired. The DCACHE_MANAGE_TRANSIT flag has similar scope and is meant
to be used to get us into ->d_manage so we can check the autofs specific
flags although locking is not present for that check which might be a
problem. It wasn't prior to the rcu-walk changes.

> 
> > > BTW, Nick has moved to kernel.dk; whether he's still reachable there is
> > > a question, though - he seems to have disappeared since mid-January.
> > 
> > Yeah, I've forwarded a couple of messages where I forgot to change the
> > email. A few emails back Nick said he was following the thread anyway.
> 
> Could you _please_ forward to him the question I tried to ask, without
> any success so far?  Namely, what was the reason for reverting do_filp_open()
> to use of do_path_lookup() in non-create case?  I have a couple of guesses,
> but...

Nicks email, at least the one I think he is using is included in the cc
list above.

