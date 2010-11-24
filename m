Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from netnation.com ([204.174.223.2]:57351 "EHLO peace.netnation.com"
	rhost-flags-OK-FAIL-OK-OK) by vger.kernel.org with ESMTP
	id S1751121Ab0KXFS6 (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Wed, 24 Nov 2010 00:18:58 -0500
Date: Tue, 23 Nov 2010 21:18:55 -0800
From: Simon Kirby <sim@hostway.ca>
To: Trond Myklebust <trond.myklebust@fys.uio.no>
Cc: linux-nfs@vger.kernel.org
Subject: Re: NFS client/sunrpc getting stuck on 2.6.36
Message-ID: <20101124051855.GA22114@hostway.ca>
References: <20101111023520.GH16939@hostway.ca> <1289452967.4062.10.camel@heimdal.trondhjem.org> <20101119202004.GA3270@hostway.ca> <1290201888.3135.61.camel@heimdal.trondhjem.org> <20101119220356.GB3270@hostway.ca> <1290205039.3135.74.camel@heimdal.trondhjem.org> <20101121064025.GA3285@hostway.ca> <1290369260.5481.18.camel@heimdal.trondhjem.org>
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <1290369260.5481.18.camel@heimdal.trondhjem.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

On Sun, Nov 21, 2010 at 02:54:20PM -0500, Trond Myklebust wrote:

> > [219158.456270] NFS: server 10.10.52.230 error: fileid changed
> > [219158.456273] fsid 0:4e: expected fileid 0x57bcf57c, got 0x57bd5442
> > 
> > Finally, on the last one I had remounted all of the NFS mount points with
> > that option, and there have been no errors since.
> 
> I just posted 8 patches to fix up bugs and regressions in the readdir
> code. Can you try with some of these?

2.6.37-rc3 plus those 8 patches was running on one box for just over a
day when it just crashed for some reason (got rebooted before I could see
the console).  Anyway, while it was running, it was still logging "fileid
changed" lines as before:

[84197.182497] NFS: server 10.10.52.228 error: fileid changed
[84197.182499] fsid 0:47: expected fileid 0x96fe0343, got 0x4926a389
[85226.297721] NFS: server 10.10.52.227 error: fileid changed
[85226.297724] fsid 0:39: expected fileid 0x254d3a97, got 0x480014a6 

Simon-
