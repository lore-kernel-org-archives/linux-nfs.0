Return-Path: linux-nfs-owner@vger.kernel.org
Received: from pfw.demon.co.uk ([62.49.22.168]:44053 "EHLO pfw.demon.co.uk"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1756427Ab3GYRFb (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Thu, 25 Jul 2013 13:05:31 -0400
Date: Thu, 25 Jul 2013 17:05:26 +0000
From: Larry Keegan <lk@pfw.demon.co.uk>
To: Jeff Layton <jlayton@redhat.com>
Cc: <linux-nfs@vger.kernel.org>
Subject: Re: nfs client: Now you see it, now you don't (aka spurious ESTALE
 errors)
Message-ID: <20130725170526.6e54c7db@cs3.al.itld>
In-Reply-To: <20130725101143.6a22cb81@corrin.poochiereds.net>
References: <20130725134515.67af44e2@cs3.al.itld>
	<20130725101143.6a22cb81@corrin.poochiereds.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Thu, 25 Jul 2013 10:11:43 -0400
Jeff Layton <jlayton@redhat.com> wrote:
> On Thu, 25 Jul 2013 13:45:15 +0000
> Larry Keegan <lk@pfw.demon.co.uk> wrote:
> 
> > Dear Chaps,
> > 
> > I am experiencing some inexplicable NFS behaviour which I would
> > like to run past you.
> > 
> > I have a linux NFS server running kernel 3.10.2 and some clients
> > running the same. The server is actually a pair of identical
> > machines serving up a small number of ext4 filesystems atop drbd.
> > They don't do much apart from serve home directories and deliver
> > mail into them. These have worked just fine for aeons.
> > 
> > The problem I am seeing is that for the past month or so, on and
> > off, one NFS client starts reporting stale NFS file handles on some
> > part of the directory tree exported by the NFS server. During the
> > outage the other parts of the same export remain unaffected. Then,
> > some ten minutes to an hour later they're back to normal. Access to
> > the affected sub-directories remains possible from the server (both
> > directly and via nfs) and from other clients. There do not appear
> > to be any errors on the underlying ext4 filesystems.
> > 
> > Each NFS client seems to get the heebie-jeebies over some directory
> > or other pretty much independently. The problem affects all of the
> > filesystems exported by the NFS server, but clearly I notice it
> > first in home directories, and in particular in my dot
> > subdirectories for things like my mail client and browser. I'd say
> > something's up the spout about 20% of the time.
> > 
> > The server and clients are using nfs4, although for a while I tried
> > nfs3 without any appreciable difference. I do not have
> > CONFIG_FSCACHE set.
> > 
> > I wonder if anyone could tell me if they have ever come across this
> > before, or what debugging settings might help me diagnose the
> > problem?
> > 
> > Yours,
> > 
> > Larry
> > --
> > To unsubscribe from this list: send the line "unsubscribe
> > linux-nfs" in the body of a message to majordomo@vger.kernel.org
> > More majordomo info at  http://vger.kernel.org/majordomo-info.html
> 
> 
> Were these machines running older kernels before this started
> happening? What kernel did you upgrade from if so?
> 

Dear Jeff,

The full story is this:

I had a pair of boxes running kernel 3.4.3 with the aforementioned drbd
pacemaker malarkey and some clients running the same.

Then I upgraded the machines by moving from plain old dos partitions to
gpt. This necessitated a complete reload of everything, but there were
no software changes. I can be sure that nothing else was changed
because I build my entire operating system in one ginormous makefile.

Rapidly afterwards I switched the motherboards for ones with more PCI
slots. There were no software changes except those relating to MAC
addresses.

Next I moved from 100Mbit to gigabit hubs. Then the problems started.

The symptoms were much as I've described but I didn't see them that
way. Instead I assumed the entire filesystem had gone to pot and tried
to unmount it from the client. Fatal mistake. umount hung. I was left
with an entry in /proc/mounts showing the affected mountpoints as
"/home/larry\040(deleted)" for example. It was impossible to get rid of
this and I had to reboot the box. Unfortunately the problem
snowballed and affected all my NFS clients and the file servers, so
they had to be bounced too.

Anyway, to cut a long story short, this problem seemed to me to be a
file server problem so I replaced network cards, swapped hubs,
checked filesystems, you name it, but I never experienced any actual
network connectivity problems, only NFS problems. As I had kernel 3.4.4
upgrade scheduled I upgraded all the hosts. No change.

Then I upgraded everything to kernel 3.4.51. No change.

Then I tried mounting using NFS version 3. It could be argued the
frequency of gyp reduced, but the substance remained.

Then I bit the bullet and tried kernel 3.10. No change. I noticed that
NFS_V4_1 was on so I turned it off and re-tested. No change. Then
I tried 3.10.1 and 3.10.2. No change.

I've played with the kernel options to remove FSCACHE, not that I was
using it, and that's about it.

Are there any (client or server) kernel options which I should know
about?

> What might be helpful is to do some network captures when the problem
> occurs. What we want to know is whether the ESTALE errors are coming
> from the server, or if the client is generating them. That'll narrow
> down where we need to look for problems.

As it was giving me gyp during typing I tried to capture some NFS
traffic. Unfortunately claws-mail started a mail box check in the
middle of this and the problem disappeared! Normally it's claws which
starts this. It'll come along again soon enough and I'll send a trace.

Thank you for your help.

Yours,

Larry.
