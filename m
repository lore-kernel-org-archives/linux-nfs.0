From: Trond Myklebust <trond.myklebust@fys.uio.no>
Subject: Re: NFS4ERR_DENIED becomes EIO?
Date: Wed, 18 Feb 2009 16:59:59 -0500
Message-ID: <1234994399.8412.206.camel@heimdal.trondhjem.org>
References: <499C7B53.5030802@garzik.org>
Mime-Version: 1.0
Content-Type: text/plain
Cc: linux-nfs@vger.kernel.org,
	linux-fsdevel <linux-fsdevel@vger.kernel.org>
To: Jeff Garzik <jeff@garzik.org>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-out1.uio.no ([129.240.10.57]:45825 "EHLO mail-out1.uio.no"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752731AbZBRWAF (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Wed, 18 Feb 2009 17:00:05 -0500
In-Reply-To: <499C7B53.5030802@garzik.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Wed, 2009-02-18 at 16:19 -0500, Jeff Garzik wrote:
> I think I may have found a tiny NFSv4 client bug.  What I am seeing:
> 
> 1. On Linux NFS client (2.6.29-rc2), issue chown(1) to change the owner 
> of the file (causing SETATTR:OWNER to be issued)
> 
> 2. My userland NFS server returns NFS4ERR_DENIED for the SETATTR op
> 
> 3. Linux NFS client returns EIO (I/O error) to userland
> 
> That was a bit unexpected.  I would have guessed EPERM, perhaps.
> 
> 	Jeff

I'd put this down as a server bug, as rfc 3530 really reserves the error
NFS4ERR_DENIED for the LOCK/LOCKT/LOCKU operations.

In the case of a chown(), I'd expect the server to return NFS4ERR_PERM
when failing because the caller is not root or the file owner. The
client will then correctly translate that into an EPERM...

Cheers
  Trond

