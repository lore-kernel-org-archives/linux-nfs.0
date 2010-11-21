Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from netnation.com ([204.174.223.2]:47085 "EHLO peace.netnation.com"
	rhost-flags-OK-FAIL-OK-OK) by vger.kernel.org with ESMTP
	id S1751890Ab0KUGka (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Sun, 21 Nov 2010 01:40:30 -0500
Date: Sat, 20 Nov 2010 22:40:25 -0800
From: Simon Kirby <sim@hostway.ca>
To: Trond Myklebust <trond.myklebust@fys.uio.no>
Cc: linux-nfs@vger.kernel.org
Subject: Re: NFS client/sunrpc getting stuck on 2.6.36
Message-ID: <20101121064025.GA3285@hostway.ca>
References: <20101111023520.GH16939@hostway.ca> <1289452967.4062.10.camel@heimdal.trondhjem.org> <20101119202004.GA3270@hostway.ca> <1290201888.3135.61.camel@heimdal.trondhjem.org> <20101119220356.GB3270@hostway.ca> <1290205039.3135.74.camel@heimdal.trondhjem.org>
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <1290205039.3135.74.camel@heimdal.trondhjem.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

On Fri, Nov 19, 2010 at 05:17:19PM -0500, Trond Myklebust wrote:

> The only change in 2.6.37-rcX I can think of that might have caused an
> issue here would be Bryan's readdir changes.
> 
> If you can reproduce the above error condition, then could you try
> turning off readdirplus (using the 'nordirplus' mount option) and seeing
> if that makes a difference?

So, of the three boxes now running 2.6.37-rc2-git3, I have two mounted
with nordirplus.  One I booted with "nordirplus" has never logged the
error.  Another I haven't changed the fstab on, is still logging this
fairly often (nfsstat shows it has only made readdirplus calls):

[219158.456270] NFS: server 10.10.52.230 error: fileid changed
[219158.456273] fsid 0:4e: expected fileid 0x57bcf57c, got 0x57bd5442

Finally, on the last one I had remounted all of the NFS mount points with
that option, and there have been no errors since.

Simon-
