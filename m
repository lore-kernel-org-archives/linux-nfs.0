From: Pierre Ossman <drzeus-list@drzeus.cx>
Subject: Re: [NFS] What's slated for inclusion in 2.6.24-rc1 from the NFS
 client git tree...
Date: Thu, 4 Oct 2007 18:43:04 +0200
Message-ID: <20071004184304.6e71ab6d@poseidon.drzeus.cx>
References: <1191454876.6726.32.camel@heimdal.trondhjem.org>
	<20071004085206.0a8e37b5@poseidon.drzeus.cx>
	<1191506450.6685.17.camel@heimdal.trondhjem.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Cc: Peter Staubach <staubach@redhat.com>, nfsv4@linux-nfs.org,
	Andrew Morton <akpm@linux-foundation.org>,
	nfs@lists.sourceforge.net, linux-kernel@vger.kernel.org
To: Trond Myklebust <trond.myklebust@fys.uio.no>
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1760929AbXJDQnV@vger.kernel.org>
In-Reply-To: <1191506450.6685.17.camel@heimdal.trondhjem.org>
Sender: linux-kernel-owner@vger.kernel.org
List-ID: <nfs.lists.sourceforge.net>

On Thu, 04 Oct 2007 10:00:50 -0400
Trond Myklebust <trond.myklebust@fys.uio.no> wrote:

> On Thu, 2007-10-04 at 08:52 +0200, Pierre Ossman wrote:
> > On Wed, 03 Oct 2007 19:41:16 -0400
> > Trond Myklebust <trond.myklebust@fys.uio.no> wrote:
> > 
> > > 
> > > We also have the 64-bit inode support from RedHat/Peter Staubach.
> > > 
> > 
> > As has been pointed[1] out[2], this will cause regressions for
> > non-LFS applications (of which there are still lots and lots). This
> > change should be in feature-removal (the "feature" being removed is
> > legacy support for non-LFS applications using NFS servers that make
> > full use of the protocol) and preferably accompanied with
> > appropriate user space changes (e.g. compatibility option in glibc).
> > 
> > [1] https://bugzilla.redhat.com/show_bug.cgi?id=241348
> > [2] http://marc.info/?l=linux-nfs&m=118701088726477&w=2
> > 
> > Rgds
> 
> How about a boot/module parameter to turn it on or off?
> 

That would be perfect. It can even be in non-legacy mode by default,
just as long as you can go back to the old behaviour when/if you run
into a non-LFS application.

> I don't see any point in having a sysctl for something like this:
> either you have legacy applications or you don't. It is not something
> that you switch off as you go off to lunch.
> A compile parameter, OTOH, would be too restrictive since it would
> force distros to choose just one behaviour (which would mean they
> would have to choose the most conservative).
> 

Agreed.

Rgds
-- 
     -- Pierre Ossman

  Linux kernel, MMC maintainer        http://www.kernel.org
  PulseAudio, core developer          http://pulseaudio.org
  rdesktop, core developer          http://www.rdesktop.org
