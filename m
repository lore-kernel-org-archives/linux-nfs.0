Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from cliff.cs.toronto.edu ([128.100.3.120]:42194 "EHLO
        cliff.cs.toronto.edu" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1727419AbeILCk3 (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Tue, 11 Sep 2018 22:40:29 -0400
From: Chris Siebenmann <cks@cs.toronto.edu>
To: Trond Myklebust <trondmy@hammerspace.com>
cc: "chuck.lever@oracle.com" <chuck.lever@oracle.com>,
        "linux-nfs@vger.kernel.org" <linux-nfs@vger.kernel.org>,
        cks@cs.toronto.edu
Subject: Re: A NFS client partial file corruption problem in recent/current kernels
In-reply-to: trondmy's message of Tue, 11 Sep 2018 21:25:48 -0000.
             <d5ffaf3fa306a6af744d9dfb67c7d13480446039.camel@hammerspace.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Date: Tue, 11 Sep 2018 17:39:13 -0400
Message-Id: <20180911213913.ABE8B322562@apps1.cs.toronto.edu>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

> This has nothing to do with mount options. Buffered reads of a file
> that is being written to over NFS without using locking is inherently
> unsafe. That always has been the case...
>
> Both writes and reads can be reordered by the RPC layer on both the
> client and the server, and they can be further reordered by the
> NFS layer on the server. In practice, this means that you can find
> yourself reading parts of the file that have not yet completed being
> written to, because, for example, a write that extended the file from
> offset 4096- 8191 completed before the write that was supposed to
> extend it from offset 0-4095 was processed by the server.

 Our issue also happens when the writes are done on the fileserver,
though, and they occur even if you allow plenty of time for the writes
to settle. I can run my test program in a mode where it explicitly waits
for me to tell it to continue, do the appending to the file on the
fileserver, 'sync' on the fileserver, wait five minutes, and the NFS
client will still see those zero bytes when it tries to read the new
data.

(To make sure the 'five minutes' bit wasn't hyperbole, I just tested
it.)

	- cks
