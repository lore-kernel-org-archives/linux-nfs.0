From: "J. Bruce Fields" <bfields@fieldses.org>
Subject: Re: [opensuse] nfs_update_inode: inode X mode changed, Y to Z
Date: Wed, 12 Mar 2008 18:15:11 -0400
Message-ID: <20080312221511.GC31632@fieldses.org>
References: <47CF0829.4020502@m2000.com> <1204752463.5035.34.camel@heimdal.trondhjem.org> <47CF157B.1010908@m2000.com> <18383.24847.381754.517731@notabene.brown> <47CF62C5.7000908@m2000.com> <18384.50909.866848.966192@notabene.brown> <9a8748490803121513w285cd45rb6b26a3d842cac1b@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Neil Brown <neilb@suse.de>, Adam Schrotenboer <adam-PMR2DCmmWYEAvxtiuMwx3w@public.gmane.org>,
	Trond Myklebust <Trond.Myklebust@netapp.com>,
	lkml@vger.kernel.org, linux-nfs@vger.kernel.org,
	Thomas Daniel <tdaniel-PMR2DCmmWYEAvxtiuMwx3w@public.gmane.org>
To: Jesper Juhl <jesper.juhl@gmail.com>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mail.fieldses.org ([66.93.2.214]:59030 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751864AbYCLWPP (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Wed, 12 Mar 2008 18:15:15 -0400
In-Reply-To: <9a8748490803121513w285cd45rb6b26a3d842cac1b-JsoAwUIsXosN+BqQ9rBEUg@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Wed, Mar 12, 2008 at 11:13:23PM +0100, Jesper Juhl wrote:
> On 07/03/2008, Neil Brown <neilb@suse.de> wrote:
> > On Wednesday March 5, adam-PMR2DCmmWYEAvxtiuMwx3w@public.gmane.org wrote:
> >  > Neil Brown wrote:
> >  > > On Wednesday March 5, adam-PMR2DCmmWYEAvxtiuMwx3w@public.gmane.org wrote:
> >  > >
> >  > > Where :-)
> >  > >
> >  > > A excerpt from the logs to show actual error messages could be
> >  > > helpful.
> >  > >
> >  > > Thanks,
> >  > > NeilBrown
> >  > sorry, must have missed the paste
> >  >
> >  > Feb 28 17:27:58 koi kernel: nfs_update_inode: inode 3221350147 mode
> >  > changed, 0040755 to 0100644
> >  > Feb 28 21:57:22 koi kernel: nfs_update_inode: inode 2149056279 mode
> >  > changed, 0040755 to 0100755
> >  > Mar  5 01:43:21 koi kernel: nfs_update_inode: inode 3222473680 mode
> >  > changed, 0040755 to 0100644
> >  > Mar  5 08:52:19 koi kernel: nfs_update_inode: inode 3222473568 mode
> >  > changed, 0120777 to 0100644
> >  > Mar  5 15:00:01 koi kernel: nfs_update_inode: inode 3222473569 mode
> >  > changed, 0120777 to 0100644
> >  > Mar  5 15:00:31 koi kernel: nfs_update_inode: inode 3222473674 mode
> >  > changed, 0120777 to 0100644
> >  > Mar  5 15:00:31 koi kernel: nfs_update_inode: inode 3222473675 mode
> >  > changed, 0120777 to 0100644
> >  > Mar  5 15:00:31 koi kernel: nfs_update_inode: inode 3222473672 mode
> >  > changed, 0040755 to 0100644
> >  > Mar  5 15:00:31 koi kernel: nfs_update_inode: inode 3222473673 mode
> >  > changed, 0120777 to 0100644
> >  >
> >  >
> >
> > Hmmm...
> >  Directories and symlinks "changing" to regular files.
> >
> >  32bit inode numbers with the high bit set.
> >
> >  Random times, but a burst at 3pm one afternoon.
> >
> >  The fact that it happens so rarely make is very hard to collect more
> >  data....
> >
> 
> I've reported this problem in the past for 2.6.13.4, so it's not a new problem.
> Happens very rarely indeed.
> See http://lkml.org/lkml/2007/2/26/102 and
> http://lkml.org/lkml/2007/3/1/53 for details.

What was the exported filesystem?

--b.
