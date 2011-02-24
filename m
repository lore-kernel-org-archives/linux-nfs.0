Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from zeniv.linux.org.uk ([195.92.253.2]:60396 "EHLO
	ZenIV.linux.org.uk" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752464Ab1BXB6Z (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Wed, 23 Feb 2011 20:58:25 -0500
Date: Thu, 24 Feb 2011 01:58:17 +0000
From: Al Viro <viro@ZenIV.linux.org.uk>
To: Ian Kent <raven@themaw.net>
Cc: Nick Piggin <npiggin@suse.de>,
        Trond Myklebust <Trond.Myklebust@netapp.com>,
        David Howells <dhowells@redhat.com>,
        Kernel Mailing List <linux-kernel@vger.kernel.org>,
        linux-fsdevel <linux-fsdevel@vger.kernel.org>,
        Linus Torvalds <torvalds@linux-foundation.org>,
        Andrew Morton <akpm@linux-foundation.org>,
        Linux NFS Mailing List <linux-nfs@vger.kernel.org>
Subject: Re: [PATCH 0/3] Fixes for vfs-scale and vfs-automount
Message-ID: <20110224015817.GQ22723@ZenIV.linux.org.uk>
References: <20110118040449.23109.33071.stgit@localhost6.localdomain6>
 <1295420817.3076.24.camel@perseus>
 <1297779902.13007.86.camel@perseus>
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <1297779902.13007.86.camel@perseus>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

On Tue, Feb 15, 2011 at 10:25:02PM +0800, Ian Kent wrote:

> I'm seeing a reference being gained, or perhaps not being released
> quickly enough after a close(2) on a file handle open on a mount point
> being umounted seen in the backtrace [1] below. I can't say if there is
> more than one like this because the BUG() stops the umounting. I'm
> thinking of modifying the code to try and continue to see what else I
> can find out.
> 
> I get this quite reliably running the test described above.
> 
> I've looked long and hard at the vfs-scale path walking code (and the
> vfs-automount code) and I can't yet see how this could be possible.
> 
> Here are some observations I've made so far.
> 
> In this segement of code in autofs4:
 
> int autofs4_d_manage(struct dentry *dentry, bool mounting_here, bool rcu_walk)
> {
>         struct autofs_sb_info *sbi = autofs4_sbi(dentry->d_sb);
> 
>         DPRINTK("dentry=%p %.*s",
>                 dentry, dentry->d_name.len, dentry->d_name.name);
> 
>         /* The daemon never waits. */
>         if (autofs4_oz_mode(sbi) || mounting_here) {
>                 if (!d_mountpoint(dentry))
>                         return -EISDIR;
>                 return 0;
>         }
> 
>         /* We need to sleep, so we need pathwalk to be in ref-mode */
>         if (rcu_walk)
>                 return -ECHILD;

[snip]

> If I move the
> 
>         /* We need to sleep, so we need pathwalk to be in ref-mode */
>         if (rcu_walk)
>                 return -ECHILD;
> 
> above the
> 
>         /* The daemon never waits. */
>         if (autofs4_oz_mode(sbi) || mounting_here) {
>                 if (!d_mountpoint(dentry))
>                         return -EISDIR;
>                 return 0;
>         }
> 
> I almost never see the problem in the first stage of the test, that
> being the nobrowse configuration, but almost always see it in the second
> stage, the so called browse configuration. Which amounts to saying that
> the problem appears to happen more often when mount point directories in
> the automount headachy exist before being mounted on and are not removed
> when they are expired. Unfortunately it isn't as simple as that either
> since the automount map itself is fairly complex. Still, I thought it
> worth mentioning.

Curious...  The only caller affected by that transposition is
__follow_mount_rcu() and it would have to
	* be called from do_lookup()
	* have path->dentry pointing to a mountpoint
	* being called by the daemon.
So basically you are forcing the daemon to try and drop out of RCU mode
when it reaches a mountpoint on autofs.

> The most recent curious thing is that if I change the test a bit to use
> bind mounts on local paths instead of NFS mounts I don't get this BUG()
> at all. Don't get me wrong, I'm not saying this is necessarily an NFS
> problem, it may be that the reduced latency of bind mounts changes the
> test behavior and hides the bug. So I'd appreciate some help from NFS
> folks in case it is something that needs to be changed in NFS, since I
> can't see anything that might cause it in the NFS code myself.

It might be "kicks the thing out of RCU mode as soon as we reach into a
directory on NFS"...  Try binds down into sysfs; ->d_revalidate() will
act there as well.

> If anyone would like to try and run the test themselves I'll work on
> decoupling it from the RHTS infrastructure within which it is currently
> implemented. 

Ho-hum...  I can reach RHTS, but I'd rather do that at home boxen, if
possible...  Has it been reproduced on UP boxen with SMP kernels, BTW?
