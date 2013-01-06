Return-Path: linux-nfs-owner@vger.kernel.org
Received: from plane.gmane.org ([80.91.229.3]:37216 "EHLO plane.gmane.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751598Ab3AFKtE (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Sun, 6 Jan 2013 05:49:04 -0500
Received: from list by plane.gmane.org with local (Exim 4.69)
	(envelope-from <glN-linux-nfs@m.gmane.org>)
	id 1Trnn2-0004J7-KS
	for linux-nfs@vger.kernel.org; Sun, 06 Jan 2013 11:49:16 +0100
Received: from p4FE15490.dip.t-dialin.net ([79.225.84.144])
        by main.gmane.org with esmtp (Gmexim 0.1 (Debian))
        id 1AlnuQ-0007hv-00
        for <linux-nfs@vger.kernel.org>; Sun, 06 Jan 2013 11:49:16 +0100
Received: from mario.bachmann by p4FE15490.dip.t-dialin.net with local (Gmexim 0.1 (Debian))
        id 1AlnuQ-0007hv-00
        for <linux-nfs@vger.kernel.org>; Sun, 06 Jan 2013 11:49:16 +0100
To: linux-nfs@vger.kernel.org
From: Mario Bachmann <mario.bachmann@gmail.com>
Subject: Re: [PATCH 0/2] Fix regression on NFS in mainline kernel
Date: Sun, 6 Jan 2013 10:48:48 +0000 (UTC)
Message-ID: <loom.20130106T114119-13@post.gmane.org>
References: <20120418105147.2a6f1c55@corrin.poochiereds.net>  <1334770614-10653-1-git-send-email-Trond.Myklebust@netapp.com>  <20120419093025.GA2916@zeus> <20120419134847.GC2916@zeus>  <1334856549.21419.48.camel@lade.trondhjem.org>  <20120419204638.GB22948@zeus> <loom.20130104T105915-661@post.gmane.org> <4FA345DA4F4AE44899BD2B03EEEC2FA91198A4B4@SACEXCMBX04-PRD.hq.netapp.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Myklebust, Trond <Trond.Myklebust@...> writes:

> > I use kernel 3.7.1 from kernel.org which has the patches included, 
> > which should fix the problems (I checked the source code). But:
> > I get "NFS: nfs4_reclaim_open_state: Lock reclaim failed!" on the 
> > client, which mounts home over nfs4. 
> > I get senseless network traffic (50MB/s on my gigabit network). 
> > Finally I get Kernel Ops on the Server sometimes. 
> 
> Lock reclaiming is not guaranteed to succeed; it all depends on why the
> lock was lost in the first place. Did the server restart, or did a
> network partition occur? Was some other process able to take that lock
> (or even delete the file, doh!), before your client could reclaim it?
> 
> That said, if the server is Oopsing, then you have a broken server. I'd
> suggest posting that Oops to this list first.
> 
Thanks for the hint, the server was really broken! The power supply of the
server had some broken capacitors. With a new power supply there are no oopses
any more!

So my reported problems with locking are worthless, because it happened with the
broken server. 

