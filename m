Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from cliff.cs.toronto.edu ([128.100.3.120]:41916 "EHLO
        cliff.cs.toronto.edu" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1726836AbeILBj5 (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Tue, 11 Sep 2018 21:39:57 -0400
From: Chris Siebenmann <cks@cs.toronto.edu>
To: Trond Myklebust <trondmy@hammerspace.com>
cc: "linux-nfs@vger.kernel.org" <linux-nfs@vger.kernel.org>,
        cks@cs.toronto.edu
Subject: Re: A NFS client partial file corruption problem in recent/current kernels
In-reply-to: trondmy's message of Tue, 11 Sep 2018 20:00:48 -0000.
             <78ca0a56d72cda910b38a37cadd4780e112c7906.camel@hammerspace.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Date: Tue, 11 Sep 2018 16:38:55 -0400
Message-Id: <20180911203856.01574322562@apps1.cs.toronto.edu>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

> > Pragmatically, Alpine used to work with NFS mounted filesystems where
> > email was appended to them from other machines and it no longer does,
> > and the only difference is the kernel version involved on the client.
> > This breakage is actively dangerous.
> 
> Sure, but unless you are locking the file, or you are explicitly using
> O_DIRECT to do uncached I/O, then you are in violation of the close-to-
> open consistency model, and the client is going to behave as you
> describe above. NFS uses a distributed filesystem model, not a
> clustered one.

 In the close to open consistency model, is it legal and proper to
do the following sequence:

- open a file read-write
- fstat() the file until the reported file size changes
- close the file; open it again read-write
- read new data from the file

If this sequence is legal, then I think there is a bug, because I can
make the zero bytes appear even with this sequence. I've updated my
reproduction program, in

	https://www.cs.toronto.edu/~cks/vendors/linux-nfs/

to have a '--reopen' option that does this.

If this sequence is not legal and can legally result in corrupted
data in the file, then I think there is a potential problem, because
it creates a situation where one program (opening the file read-write
and holding it open) could cause corruption for another program (which
properly opens and closes the file). I can reproduce this with two
running instances of my test program. Perhaps this is considered
invalid because it is a violation of close to open across the entire
client kernel, but if so I feel this is dangerous; it puts all programs
reading NFS mounted files at the mercy of everything else on the
system, no matter how much they try to do the right thing. They can
open it read only and close it while they wait for changes and then
reopen it read only afterward, and they will still get corrupted data.

	- cks
