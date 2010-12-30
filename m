Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx2.netapp.com ([216.240.18.37]:1296 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754598Ab0L3R7y convert rfc822-to-8bit (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 30 Dec 2010 12:59:54 -0500
Subject: Re: still nfs problems [Was: Linux 2.6.37-rc8]
From: Trond Myklebust <Trond.Myklebust@netapp.com>
To: Uwe =?ISO-8859-1?Q?Kleine-K=F6nig?=
	<u.kleine-koenig@pengutronix.de>
Cc: Linus Torvalds <torvalds@linux-foundation.org>, linux-nfs@vger.kernel.org,
        linux-kernel@vger.kernel.org, linux-arm-kernel@lists.infradead.org
In-Reply-To: <20101230171453.GA5787@pengutronix.de>
References: <20101230171453.GA5787@pengutronix.de>
Content-Type: text/plain; charset="UTF-8"
Date: Thu, 30 Dec 2010 12:59:52 -0500
Message-ID: <1293731992.4919.5.camel@heimdal.trondhjem.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

On Thu, 2010-12-30 at 18:14 +0100, Uwe Kleine-König wrote: 
> Hello,
> 
> I wonder if the nfs-stuff is considered to be solved, because I still
> see strange things.
> 
> During boot my machine sometimes (approx one out of two times) hangs with
> the output pasted below on Sysctl-l.  The irq 
> 
> I'm not 100% sure it's related, but at least it seems to hang in
> nfs_readdir.  (When the serial irq happend that triggered the sysrq the
> program counter was at 0xc014601c, which is fs/nfs/dir.c:647 for me.)
> 
> This is on 2.6.37-rc8 plus some patches for machine support on an ARM
> machine.

Ccing linux-nfs@vger.kernel.org

What filesystem are you exporting on the server? What is the NFS
version? Is this nfsroot, autofs or an ordinary nfs mount?

In short, how can we reproduce this?

Trond
-- 
Trond Myklebust
Linux NFS client maintainer

NetApp
Trond.Myklebust@netapp.com
www.netapp.com

