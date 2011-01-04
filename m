Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx2.netapp.com ([216.240.18.37]:26246 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750786Ab1ADAWo convert rfc822-to-8bit (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 3 Jan 2011 19:22:44 -0500
Subject: Re: still nfs problems [Was: Linux 2.6.37-rc8]
From: Trond Myklebust <Trond.Myklebust@netapp.com>
To: Uwe =?ISO-8859-1?Q?Kleine-K=F6nig?=
	<u.kleine-koenig@pengutronix.de>
Cc: linux-nfs@vger.kernel.org, Linus Torvalds <torvalds@linux-foundation.org>,
        linux-kernel@vger.kernel.org, linux-arm-kernel@lists.infradead.org
In-Reply-To: <20110103213850.GC25121@pengutronix.de>
References: <20101230171453.GA5787@pengutronix.de>
	 <1293731992.4919.5.camel@heimdal.trondhjem.org>
	 <20101230191846.GB14221@pengutronix.de>
	 <20110103213850.GC25121@pengutronix.de>
Content-Type: text/plain; charset="UTF-8"
Date: Mon, 03 Jan 2011 19:22:38 -0500
Message-ID: <1294100558.25100.8.camel@heimdal.trondhjem.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

On Mon, 2011-01-03 at 22:38 +0100, Uwe Kleine-König wrote: 
> On Thu, Dec 30, 2010 at 08:18:46PM +0100, Uwe Kleine-König wrote:
> > On Thu, Dec 30, 2010 at 12:59:52PM -0500, Trond Myklebust wrote:
> > > What filesystem are you exporting on the server? What is the NFS
> > > version? Is this nfsroot, autofs or an ordinary nfs mount?
> > This is an nfsroot of /home/ukl/nfsroot/tx28 which is a symlink to a
> > directory on a different partition.  I don't know the filesystem of my
> > homedir as it resides on a server I have no access to, but I asked the
> > admin, so I can follow up with this info later (I'd suspect ext3, too).
> Yes, it is ext3.
> 
> > The real root directory is on ext3 (rw,noatime).
> > 
> > The serving nfs-server is Debian's nfs-kernel-server 1:1.2.2-1.
> If that matters, kernel is linux-image-2.6.32-5-amd64 (2.6.32-29)
> provided by Debian.
> 
> >                                                                I don't
> > know if testing that further would help or just waste of my time, so
> > please let me know if I can help you and how.
> This still applies

I'm having trouble reproducing this with my own nfsroot setup (which is
just a 'fedora 13 live' disk with NetworkManager turned firmly off).

However looking back at your report, you said that when you remove the
symlink, you get an error message of the form:

"starting splashutils daemon.../etc/rc.d/S00splashutils: line
50: //sbin/fbsplashd.static: Unknown error 521"

Error 521 is EBADHANDLE, which basically means your client got a
corrupted filehandle. The 'fileid changed' thing also indicates some
form of corruption.

The question is whether this is something happening on the server or the
client. Does an older client kernel boot without any trouble?

-- 
Trond Myklebust
Linux NFS client maintainer

NetApp
Trond.Myklebust@netapp.com
www.netapp.com

