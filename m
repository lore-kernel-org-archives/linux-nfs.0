Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from out1.smtp.messagingengine.com ([66.111.4.25]:55183 "EHLO
	out1.smtp.messagingengine.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1753644Ab1BXGe1 (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 24 Feb 2011 01:34:27 -0500
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
In-Reply-To: <20110224035836.GS22723@ZenIV.linux.org.uk>
References: <20110118040449.23109.33071.stgit@localhost6.localdomain6>
	 <1295420817.3076.24.camel@perseus> <1297779902.13007.86.camel@perseus>
	 <20110224015817.GQ22723@ZenIV.linux.org.uk>
	 <1298516618.2916.20.camel@perseus>
	 <20110224031439.GR22723@ZenIV.linux.org.uk>
	 <1298518137.2916.35.camel@perseus>
	 <20110224035836.GS22723@ZenIV.linux.org.uk>
Content-Type: text/plain; charset="UTF-8"
Date: Thu, 24 Feb 2011 14:34:20 +0800
Message-ID: <1298529260.2916.91.camel@perseus>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

On Thu, 2011-02-24 at 03:58 +0000, Al Viro wrote:
> 
> Anyway, I wonder why you care about __d_lookup_rcu() and ->d_inode stability;
> d_mountpoint() _is_ stable at that point (we hold vfsmount_lock) and you
> don't seem to look at ->d_inode at all in RCU case.  Note that ->d_automount()
> is never called in RCU case at all; nor is ->lookup() and friends, so you
> really only have ->d_manage() to cope with, what with autofs4 having no
> ->d_revalidate() anymore.

It does now but it doesn't do a whole lot, just checks for a negative
dentry, returning false, and drops out of RCU mode when the dentry isn't
selected or being checked for expiry yet.

Indeed, I shouldn't need to care about it and checking for it doesn't
seem to do a whole lot.

I've seen walks fail with a dentry that has gone away (ie. I'm walking
in a tree that is being expired, they seem to be trees with no actual
mount at their base), which should be because I'm not catching the block
request at a higher level dentry. Unfortunately, including a check for
the base dentry in __follow_mount_rcu(), regardless of it being a
mountpoint, doesn't always catch the need to block either. That the tree
is being selected for expire is probably because the expire can't detect
a walk within the mount tree when the walker is between the
__d_lookup_rcu() and __follow_mount_rcu() calls. Jumping out of rcu-walk
mode in an added revalidate reduces the possibility of this happening
(assuming walks are sneaking in between dropping and acquiring the
vfsmount_lock) but doesn't eliminate it. 

At this point I loop back to the trying to work out why a reference gets
picked up and the cycle repeats with various small changes to the
overall approach.

Actually, it's not just the root of a mount that is getting an extra
reference either. When I notice a root dentry has picked up a reference
(from a printk) and SIGKILL everything and start umounting manually I
get to a point in the tree where I need to umount autofs mounts twice,
which usually means nothing more than a get/put mismatch somewhere, but
in that case I normally don't see a root dentry pick up a reference.
That's confusing me too.

> 
> BTW, Nick has moved to kernel.dk; whether he's still reachable there is
> a question, though - he seems to have disappeared since mid-January.

Yeah, I've forwarded a couple of messages where I forgot to change the
email. A few emails back Nick said he was following the thread anyway.

Ian


