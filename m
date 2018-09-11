Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from cliff.cs.toronto.edu ([128.100.3.120]:42740 "EHLO
        cliff.cs.toronto.edu" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1725936AbeILErZ (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Wed, 12 Sep 2018 00:47:25 -0400
From: Chris Siebenmann <cks@cs.toronto.edu>
To: Trond Myklebust <trondmy@hammerspace.com>
cc: "linux-nfs@vger.kernel.org" <linux-nfs@vger.kernel.org>,
        "chuck.lever@oracle.com" <chuck.lever@oracle.com>,
        cks@cs.toronto.edu
Subject: Re: A NFS client partial file corruption problem in recent/current kernels
In-reply-to: trondmy's message of Tue, 11 Sep 2018 22:12:26 -0000.
             <624981c3fe62c3df744f769d46dc9921cc2826ce.camel@hammerspace.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Date: Tue, 11 Sep 2018 19:45:47 -0400
Message-Id: <20180911234547.6D0E2322562@apps1.cs.toronto.edu>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

> >  Our issue also happens when the writes are done on the fileserver,
> > though, and they occur even if you allow plenty of time for the
> > writes to settle. I can run my test program in a mode where it
> > explicitly waits for me to tell it to continue, do the appending
> > to the file on the fileserver, 'sync' on the fileserver, wait five
> > minutes, and the NFS client will still see those zero bytes when it
> > tries to read the new data.
>
> That's happening because we're not optimising for the broken case, and
> instead we assume that we can cache data for as long as the file is
> open and unlocked as indeed the close-to-open cache consistency model
> has always stated that we can do.

 If I'm understanding all of this right, is what the kernel does more
or less like this: when a NFS client program closes a writeable file
(descriptor), the kernel flushes any pending writes, does a GETATTR
afterward, and declares all current cached pages fully valid 'as of'
that GETATTR result. When the file is reopened (in any mode), the kernel
GETATTRs the file again; if the GETATTR hasn't changed, the cached pages
and their contents remain valid.

 As a result, if you write to the file from another machine (including
the fileserver) before the writeable file is closed, on close the
client uses the updated GETATTR from the server but its current cached
pages. These cached pages may be out of date, but if so it is because
one violated close-to-open; you must always close any writeable file
descriptors on machine A before writing to the file on machine B (or
obtain and then release locks?).

 If a client kernel has cached pages this way, is there any simple
sequence of system calls on the client that will cause it to discard
these cached pages? Or do you need the file's GETATTR to change again,
implicitly from another machine? (I assume that changing the file's
attributes from the client with the cached pages doesn't cause it to
invalidate them, and certainly eg a 'touch' doesn't do it from the
client where it does do it from another machine.)

	- cks
