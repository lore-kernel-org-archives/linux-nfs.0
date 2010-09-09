Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-out1.uio.no ([129.240.10.57]:50230 "EHLO mail-out1.uio.no"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753792Ab0IIVnu (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Thu, 9 Sep 2010 17:43:50 -0400
Subject: Re: locking and setgid files
From: Trond Myklebust <trond.myklebust@fys.uio.no>
To: Orion Poplawski <orion@cora.nwra.com>
Cc: linux-nfs@vger.kernel.org
In-Reply-To: <loom.20100909T231305-758@post.gmane.org>
References: <loom.20100909T231305-758@post.gmane.org>
Content-Type: text/plain; charset="UTF-8"
Date: Thu, 09 Sep 2010 17:43:45 -0400
Message-ID: <1284068625.14656.37.camel@heimdal.trondhjem.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

On Thu, 2010-09-09 at 21:15 +0000, Orion Poplawski wrote:
> Is this expected?
> 
> $ ls -l /data/sw/svn/dombroski/supergran_paper/db/txn-current-lock
> -rw-rwSr--. 1 dombroski superg    0 Aug 30 16:27 txn-current-lock
> 
> $ id
> uid=6412(aaronb) gid=1001(cora) groups=1001(cora),1041(superg)
> context=unconfined_u:unconfined_r:unconfined_t:s0-s0:c0.c1023
> 
> open("/data/sw/svn/dombroski/supergran_paper/db/txn-current-lock", O_RDWR) = 3
> fcntl64(3, F_GETLK, {type=F_WRLCK, whence=SEEK_SET, start=0, len=0,
> pid=10771680}) = -1 ENOLCK (No locks available)
> 
> I guess I could somewhat understand it, though the fcntl64() call succeeds on
> the server (CentOS 5.5).

It is quite conceivable that your CentOS 5.5 NFS server lacks the proper
support for mandatory posix locking. We only test regularly with
advisory locks.

Cheers
  Trond

