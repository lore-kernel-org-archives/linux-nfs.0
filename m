Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-out1.uio.no ([129.240.10.57]:56106 "EHLO mail-out1.uio.no"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751768Ab0KXPF7 (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Wed, 24 Nov 2010 10:05:59 -0500
Subject: Re: NFS client/sunrpc getting stuck on 2.6.36
From: Trond Myklebust <trond.myklebust@fys.uio.no>
To: Simon Kirby <sim@hostway.ca>
Cc: linux-nfs@vger.kernel.org
In-Reply-To: <20101124051855.GA22114@hostway.ca>
References: <20101111023520.GH16939@hostway.ca>
	 <1289452967.4062.10.camel@heimdal.trondhjem.org>
	 <20101119202004.GA3270@hostway.ca>
	 <1290201888.3135.61.camel@heimdal.trondhjem.org>
	 <20101119220356.GB3270@hostway.ca>
	 <1290205039.3135.74.camel@heimdal.trondhjem.org>
	 <20101121064025.GA3285@hostway.ca>
	 <1290369260.5481.18.camel@heimdal.trondhjem.org>
	 <20101124051855.GA22114@hostway.ca>
Content-Type: text/plain; charset="UTF-8"
Date: Wed, 24 Nov 2010 10:05:54 -0500
Message-ID: <1290611154.3234.24.camel@heimdal.trondhjem.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

On Tue, 2010-11-23 at 21:18 -0800, Simon Kirby wrote:
> On Sun, Nov 21, 2010 at 02:54:20PM -0500, Trond Myklebust wrote:
> 
> > > [219158.456270] NFS: server 10.10.52.230 error: fileid changed
> > > [219158.456273] fsid 0:4e: expected fileid 0x57bcf57c, got 0x57bd5442
> > > 
> > > Finally, on the last one I had remounted all of the NFS mount points with
> > > that option, and there have been no errors since.
> > 
> > I just posted 8 patches to fix up bugs and regressions in the readdir
> > code. Can you try with some of these?
> 
> 2.6.37-rc3 plus those 8 patches was running on one box for just over a
> day when it just crashed for some reason (got rebooted before I could see
> the console).  Anyway, while it was running, it was still logging "fileid
> changed" lines as before:
> 
> [84197.182497] NFS: server 10.10.52.228 error: fileid changed
> [84197.182499] fsid 0:47: expected fileid 0x96fe0343, got 0x4926a389
> [85226.297721] NFS: server 10.10.52.227 error: fileid changed
> [85226.297724] fsid 0:39: expected fileid 0x254d3a97, got 0x480014a6 
> 
> Simon-

Please remind me which NFS version you are running? Is this v3 or v4?
Also could you check which files might have inode numbers 2533229379,
and/or 1227269001, on server 10.10.52.228, 625818263 and/or 1207964838
on server 10.10.52.227.

Cheers
  Trond

