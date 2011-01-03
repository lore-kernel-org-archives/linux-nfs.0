Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from metis.ext.pengutronix.de ([92.198.50.35]:49055 "EHLO
	metis.ext.pengutronix.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751583Ab1ACVi7 (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 3 Jan 2011 16:38:59 -0500
Date: Mon, 3 Jan 2011 22:38:50 +0100
From: Uwe =?iso-8859-1?Q?Kleine-K=F6nig?=
	<u.kleine-koenig@pengutronix.de>
To: Trond Myklebust <Trond.Myklebust@netapp.com>
Cc: linux-nfs@vger.kernel.org, Linus Torvalds <torvalds@linux-foundation.org>,
        linux-kernel@vger.kernel.org, linux-arm-kernel@lists.infradead.org
Subject: Re: still nfs problems [Was: Linux 2.6.37-rc8]
Message-ID: <20110103213850.GC25121@pengutronix.de>
References: <20101230171453.GA5787@pengutronix.de> <1293731992.4919.5.camel@heimdal.trondhjem.org> <20101230191846.GB14221@pengutronix.de>
Content-Type: text/plain; charset=iso-8859-1
In-Reply-To: <20101230191846.GB14221@pengutronix.de>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

On Thu, Dec 30, 2010 at 08:18:46PM +0100, Uwe Kleine-König wrote:
> On Thu, Dec 30, 2010 at 12:59:52PM -0500, Trond Myklebust wrote:
> > What filesystem are you exporting on the server? What is the NFS
> > version? Is this nfsroot, autofs or an ordinary nfs mount?
> This is an nfsroot of /home/ukl/nfsroot/tx28 which is a symlink to a
> directory on a different partition.  I don't know the filesystem of my
> homedir as it resides on a server I have no access to, but I asked the
> admin, so I can follow up with this info later (I'd suspect ext3, too).
Yes, it is ext3.

> The real root directory is on ext3 (rw,noatime).
> 
> The serving nfs-server is Debian's nfs-kernel-server 1:1.2.2-1.
If that matters, kernel is linux-image-2.6.32-5-amd64 (2.6.32-29)
provided by Debian.

>                                                                I don't
> know if testing that further would help or just waste of my time, so
> please let me know if I can help you and how.
This still applies

Uwe

-- 
Pengutronix e.K.                           | Uwe Kleine-König            |
Industrial Linux Solutions                 | http://www.pengutronix.de/  |
