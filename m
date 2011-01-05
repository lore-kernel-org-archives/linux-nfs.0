Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from magus.merit.edu ([198.108.1.13]:35470 "EHLO magus.merit.edu"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751184Ab1AEO3H (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Wed, 5 Jan 2011 09:29:07 -0500
Date: Wed, 5 Jan 2011 09:29:02 -0500
From: Jim Rees <rees@umich.edu>
To: Uwe =?iso-8859-1?Q?Kleine-K=F6nig?=
	<u.kleine-koenig@pengutronix.de>
Cc: Russell King - ARM Linux <linux@arm.linux.org.uk>,
        Trond Myklebust <Trond.Myklebust@netapp.com>,
        linux-nfs@vger.kernel.org,
        Linus Torvalds <torvalds@linux-foundation.org>,
        linux-kernel@vger.kernel.org, linux-arm-kernel@lists.infradead.org,
        Marc Kleine-Budde <m.kleine-budde@pengutronix.de>
Subject: Re: still nfs problems [Was: Linux 2.6.37-rc8]
Message-ID: <20110105142902.GA9278@merit.edu>
References: <20101230171453.GA5787@pengutronix.de>
 <1293731992.4919.5.camel@heimdal.trondhjem.org>
 <20101230191846.GB14221@pengutronix.de>
 <20110103213850.GC25121@pengutronix.de>
 <1294100558.25100.8.camel@heimdal.trondhjem.org>
 <20110105084014.GN25121@pengutronix.de>
 <20110105110517.GQ25121@pengutronix.de>
 <20110105112701.GA8638@n2100.arm.linux.org.uk>
 <20110105134045.GS25121@pengutronix.de>
Content-Type: text/plain; charset=iso-8859-1
In-Reply-To: <20110105134045.GS25121@pengutronix.de>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

Uwe Kleine-König wrote:

  > The "fileid changed" messages popped up after mounting an export with
  > 'nolock,intr,rsize=4096,soft', and then trying to use bash completion
  > and 'ls' in a few subdirectories - and entries were missing from the
  > directory lists without 'ls' reporting any errors (which I think is bad
  > behaviour in itself.)
  There was a bug in at least -rc5[1] that was considered already fixed in
  -rc4[2]. The later announcements didn't mention it anymore. 
  
  > I don't know why it's stopped producing the errors, although once it
  > went I never investigated it any further (was far too busy trying to
  > get AMBA DMA support working.)
  It seems it was fixed for most users though. Trond?

Trond sent a fix to the nfs list on 27 Nov for "fileid changed" but I don't
know if this is the same bug you're seeing.  The patch was to
nfs_same_file() and I can send it if you want.  As far as I know the patch
made it upstream.
