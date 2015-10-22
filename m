Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:41937 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751453AbbJVLSA (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Thu, 22 Oct 2015 07:18:00 -0400
Date: Thu, 22 Oct 2015 07:17:57 -0400 (EDT)
From: Benjamin Coddington <bcodding@redhat.com>
To: krichy@tvnetwork.hu
cc: linux-nfs@vger.kernel.org
Subject: Re: nfs lockup
In-Reply-To: <alpine.DEB.2.20.1510212206120.16145@krichy.tvnetwork.hu>
Message-ID: <alpine.OSX.2.19.9992.1510220601461.6711@planck.local>
References: <alpine.DEB.2.20.1510211715430.5353@krichy.tvnetwork.hu> <alpine.OSX.2.19.9992.1510211503550.6711@planck.local> <alpine.DEB.2.20.1510212206120.16145@krichy.tvnetwork.hu>
MIME-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

It looks like a lot of processes are waiting on i_mutex in
generic_file_write_iter().  Possible you're in a particularly
bad spot of contention for that mutex?

Maybe you might use the 'perf-top' tool to dig in to what the system seems to be doing
when this happens..

On Wed, 21 Oct 2015, krichy@tvnetwork.hu wrote:

>
> No, the lock is nothing to do with drbd. In the ganeti cluster some vms use
> drbd mirrored disks, but others use images on shared folder on nfs. That locks
> up sometimes. Drbd devices do work well, every network connectivity work well.
>
> Please give me advice, what to check next time. Unfortunately I cannot
> reproduce the problem.
>
> Could the 9000 MTU setting affect NFS somehow? Does that count that we are
> using xen, and thus a hypervisor is involved (regarding drbd it does).
>
> Thanks,
>
>
> Kojedzinszky Richard
> Euronet Magyarorszag Informatika Zrt.
>
> On Wed, 21 Oct 2015, Benjamin Coddington wrote:
>
> > Date: Wed, 21 Oct 2015 15:05:24 -0400 (EDT)
> > From: Benjamin Coddington <bcodding@redhat.com>
> > To: krichy@tvnetwork.hu
> > Cc: linux-nfs@vger.kernel.org
> > Subject: Re: nfs lockup
> >
> > On Wed, 21 Oct 2015, krichy@tvnetwork.hu wrote:
> >
> > > Dear devs,
> > >
> > > We have an nfs lockup issue. We run a ganeti cluster consisting of 7
> > > debian
> > > linux nodes and 1 freenas for hosting the vm images. The images are
> > > exported
> > > via nfsv3. The problem is that randomly we end in a livelock on one of our
> > > nodes.
> > >
> > > That means the nfs share is alive, we can list directories, files, even
> > > can
> > > read files (very slow, see later). And even can write to files, but the
> > > file
> > > close operation does not return, it gets blocked.
> > >
> > > The read is slow in that way that while copying a file from the share to
> > > /tmp,
> > > the data arrives very fast to the node, but in /tmp it accumulates slowly.
> > >
> > > I've also opened a debian bug report on it, but I think it is not related
> > > to
> > > debian (https://bugs.debian.org/cgi-bin/bugreport.cgi?bug=801924).
> > >
> > > The only way is to reboot machine, with all the vm's running on it getting
> > > interrupted.
> > >
> > > I've captured each tasks' stack trace, hopefully it helps someone to find
> > > out
> > > the issue.
> > >
> > > Meanwhile the other 6 nodes can access the nfs share right, so I think
> > > this is
> > > not a networking or server issue. Restarting the nfs server on the server
> > > side
> > > still does not have any effect, not recovering. The nfs tcp connection is
> > > established, listing files works again, but writes not.
> > >
> > > Some information of the nodes:
> > > # uname -a
> > > Linux host 3.16.0-4-amd64 #1 SMP Debian 3.16.7-ckt11-1+deb8u4 (2015-09-19)
> > > x86_64 GNU/Linux
> > >
> > > They have 1.5G ram allocated to dom0, that should be enough.
> > >
> > > I know this information is little information, give me advice what to look
> > > for
> > > next time. Unfortunately I dont know how to reproduce it.
> > >
> > > Thanks in advance,
> > >
> > > Kojedzinszky Richard
> > > Euronet Magyarorszag Informatika Zrt.
> >
> > I took a look at your debian bug report.. what's up with those drbd procs?
> > Are you writing to drbd-backed devs, and have you made sure that's not
> > involved in any way?
> >
> > Ben
> >
>
