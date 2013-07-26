Return-Path: linux-nfs-owner@vger.kernel.org
Received: from fieldses.org ([174.143.236.118]:37983 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1757386Ab3GZO7l (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Fri, 26 Jul 2013 10:59:41 -0400
Date: Fri, 26 Jul 2013 10:59:37 -0400
To: Larry Keegan <lk@pfw.demon.co.uk>
Cc: Jeff Layton <jlayton@redhat.com>, linux-nfs@vger.kernel.org
Subject: Re: nfs client: Now you see it, now you don't (aka spurious ESTALE
 errors)
Message-ID: <20130726145937.GB30651@fieldses.org>
References: <20130725134515.67af44e2@cs3.al.itld>
 <20130725101143.6a22cb81@corrin.poochiereds.net>
 <20130725170526.6e54c7db@cs3.al.itld>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <20130725170526.6e54c7db@cs3.al.itld>
From: "J. Bruce Fields" <bfields@fieldses.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Thu, Jul 25, 2013 at 05:05:26PM +0000, Larry Keegan wrote:
> On Thu, 25 Jul 2013 10:11:43 -0400
> Jeff Layton <jlayton@redhat.com> wrote:
> > On Thu, 25 Jul 2013 13:45:15 +0000
> > Larry Keegan <lk@pfw.demon.co.uk> wrote:
> > 
> > > Dear Chaps,
> > > 
> > > I am experiencing some inexplicable NFS behaviour which I would
> > > like to run past you.
> > > 
> > > I have a linux NFS server running kernel 3.10.2 and some clients
> > > running the same. The server is actually a pair of identical
> > > machines serving up a small number of ext4 filesystems atop drbd.
> > > They don't do much apart from serve home directories and deliver
> > > mail into them. These have worked just fine for aeons.
> > > 
> > > The problem I am seeing is that for the past month or so, on and
> > > off, one NFS client starts reporting stale NFS file handles on some
> > > part of the directory tree exported by the NFS server. During the
> > > outage the other parts of the same export remain unaffected. Then,
> > > some ten minutes to an hour later they're back to normal. Access to
> > > the affected sub-directories remains possible from the server (both
> > > directly and via nfs) and from other clients. There do not appear
> > > to be any errors on the underlying ext4 filesystems.
> > > 
> > > Each NFS client seems to get the heebie-jeebies over some directory
> > > or other pretty much independently. The problem affects all of the
> > > filesystems exported by the NFS server, but clearly I notice it
> > > first in home directories, and in particular in my dot
> > > subdirectories for things like my mail client and browser. I'd say
> > > something's up the spout about 20% of the time.

And the problem affects just that one directory?  Ohter files and
directories on the same filesystem continue to be accessible?

> > > The server and clients are using nfs4, although for a while I tried
> > > nfs3 without any appreciable difference. I do not have
> > > CONFIG_FSCACHE set.
> > > 
> > > I wonder if anyone could tell me if they have ever come across this
> > > before, or what debugging settings might help me diagnose the
> > > problem?
> > > 
> > > Yours,
> > > 
> > > Larry
> > > --
> > > To unsubscribe from this list: send the line "unsubscribe
> > > linux-nfs" in the body of a message to majordomo@vger.kernel.org
> > > More majordomo info at  http://vger.kernel.org/majordomo-info.html
> > 
> > 
> > Were these machines running older kernels before this started
> > happening? What kernel did you upgrade from if so?
> > 
> 
> Dear Jeff,
> 
> The full story is this:
> 
> I had a pair of boxes running kernel 3.4.3 with the aforementioned drbd
> pacemaker malarkey and some clients running the same.
> 
> Then I upgraded the machines by moving from plain old dos partitions to
> gpt. This necessitated a complete reload of everything, but there were
> no software changes. I can be sure that nothing else was changed
> because I build my entire operating system in one ginormous makefile.
> 
> Rapidly afterwards I switched the motherboards for ones with more PCI
> slots. There were no software changes except those relating to MAC
> addresses.
> 
> Next I moved from 100Mbit to gigabit hubs. Then the problems started.

So both the "good" and "bad" behavior were seen with the same 3.4.3
kernel?

...
> Anyway, to cut a long story short, this problem seemed to me to be a
> file server problem so I replaced network cards, swapped hubs,

Including reverting back to your original configuration with 100Mbit
hubs?

--b.
