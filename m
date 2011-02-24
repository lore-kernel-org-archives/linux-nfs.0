Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from out1.smtp.messagingengine.com ([66.111.4.25]:34669 "EHLO
	out1.smtp.messagingengine.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S932071Ab1BXDDr (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Wed, 23 Feb 2011 22:03:47 -0500
Subject: Re: [PATCH 0/3] Fixes for vfs-scale and vfs-automount
From: Ian Kent <raven@themaw.net>
To: Al Viro <viro@ZenIV.linux.org.uk>
Cc: Nick Piggin <npiggin@suse.de>,
        Trond Myklebust <Trond.Myklebust@netapp.com>,
        David Howells <dhowells@redhat.com>,
        Kernel Mailing List <linux-kernel@vger.kernel.org>,
        linux-fsdevel <linux-fsdevel@vger.kernel.org>,
        Linus Torvalds <torvalds@linux-foundation.org>,
        Andrew Morton <akpm@linux-foundation.org>,
        Linux NFS Mailing List <linux-nfs@vger.kernel.org>
In-Reply-To: <20110224015817.GQ22723@ZenIV.linux.org.uk>
References: <20110118040449.23109.33071.stgit@localhost6.localdomain6>
	 <1295420817.3076.24.camel@perseus> <1297779902.13007.86.camel@perseus>
	 <20110224015817.GQ22723@ZenIV.linux.org.uk>
Content-Type: text/plain; charset="UTF-8"
Date: Thu, 24 Feb 2011 11:03:38 +0800
Message-ID: <1298516618.2916.20.camel@perseus>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

On Thu, 2011-02-24 at 01:58 +0000, Al Viro wrote: 
> On Tue, Feb 15, 2011 at 10:25:02PM +0800, Ian Kent wrote:
> 
> > I'm seeing a reference being gained, or perhaps not being released
> > quickly enough after a close(2) on a file handle open on a mount point
> > being umounted seen in the backtrace [1] below. I can't say if there is
> > more than one like this because the BUG() stops the umounting. I'm
> > thinking of modifying the code to try and continue to see what else I
> > can find out.
> > 
> > I get this quite reliably running the test described above.
> > 
> > I've looked long and hard at the vfs-scale path walking code (and the
> > vfs-automount code) and I can't yet see how this could be possible.
> > 
> > Here are some observations I've made so far.
> > 
> > In this segement of code in autofs4:
>  
> > int autofs4_d_manage(struct dentry *dentry, bool mounting_here, bool rcu_walk)
> > {
> >         struct autofs_sb_info *sbi = autofs4_sbi(dentry->d_sb);
> > 
> >         DPRINTK("dentry=%p %.*s",
> >                 dentry, dentry->d_name.len, dentry->d_name.name);
> > 
> >         /* The daemon never waits. */
> >         if (autofs4_oz_mode(sbi) || mounting_here) {
> >                 if (!d_mountpoint(dentry))
> >                         return -EISDIR;
> >                 return 0;
> >         }
> > 
> >         /* We need to sleep, so we need pathwalk to be in ref-mode */
> >         if (rcu_walk)
> >                 return -ECHILD;
> 
> [snip]
> 
> > If I move the
> > 
> >         /* We need to sleep, so we need pathwalk to be in ref-mode */
> >         if (rcu_walk)
> >                 return -ECHILD;
> > 
> > above the
> > 
> >         /* The daemon never waits. */
> >         if (autofs4_oz_mode(sbi) || mounting_here) {
> >                 if (!d_mountpoint(dentry))
> >                         return -EISDIR;
> >                 return 0;
> >         }
> > 
> > I almost never see the problem in the first stage of the test, that
> > being the nobrowse configuration, but almost always see it in the second
> > stage, the so called browse configuration. Which amounts to saying that
> > the problem appears to happen more often when mount point directories in
> > the automount headachy exist before being mounted on and are not removed
> > when they are expired. Unfortunately it isn't as simple as that either
> > since the automount map itself is fairly complex. Still, I thought it
> > worth mentioning.
> 
> Curious...  The only caller affected by that transposition is
> __follow_mount_rcu() and it would have to
> 	* be called from do_lookup()
> 	* have path->dentry pointing to a mountpoint
> 	* being called by the daemon.
> So basically you are forcing the daemon to try and drop out of RCU mode
> when it reaches a mountpoint on autofs.

At this point I'm partly clueless as to what's happening.
Even the statements above turn out to be inaccurate although that is
what I observed for quite a while initially.

One thing I've found is that it's possible for __follow_mount_rcu() to
be called on a non-mountpoint autofs dentry that needs to block transit.

Another is an out of order call bug with the active list usage. It was
removing the dentry from the list before hashing it which can cause
multiple dentrys to be created for the same lookup. At this point I
don't think just changing the function call order is sufficient to fix
it. I tried to remove the active list code during the vfs-automount
development but found I couldn't always drop dentrys when I needed to
for error cases. I didn't pursue that because I had something else that
was working fine and seemed to play well with the VFS.

There is also the expire. It uses reference counts to establish
busyness, which is mostly fine, except that's also used to avoid
attempting to expire a tree that has a process walking somewhere within
it. Which more or less says that I need to drop out of rcu-walk for any
dentry that is not already being expired (or checked).

I also have a sick feeling that dentrys may become negative at any point
after __d_lookup_rcu() .....

> 
> > The most recent curious thing is that if I change the test a bit to use
> > bind mounts on local paths instead of NFS mounts I don't get this BUG()
> > at all. Don't get me wrong, I'm not saying this is necessarily an NFS
> > problem, it may be that the reduced latency of bind mounts changes the
> > test behavior and hides the bug. So I'd appreciate some help from NFS
> > folks in case it is something that needs to be changed in NFS, since I
> > can't see anything that might cause it in the NFS code myself.
> 
> It might be "kicks the thing out of RCU mode as soon as we reach into a
> directory on NFS"...  Try binds down into sysfs; ->d_revalidate() will
> act there as well.
> 
> > If anyone would like to try and run the test themselves I'll work on
> > decoupling it from the RHTS infrastructure within which it is currently
> > implemented. 
> 
> Ho-hum...  I can reach RHTS, but I'd rather do that at home boxen, if
> possible...  Has it been reproduced on UP boxen with SMP kernels, BTW?

Nope, I'd need to build a kernel specifically for that. I'm not sure how
useful that would be though since the test is specifically meant to
expose problems with multiple concurrent processes accessing an
automount tree. I don't see any problem running the Connectathon tests
which is essentially one automount and one client process.

Ian

