Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from cliff.cs.toronto.edu ([128.100.3.120]:41098 "EHLO
        cliff.cs.toronto.edu" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1727754AbeIKXCq (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Tue, 11 Sep 2018 19:02:46 -0400
From: Chris Siebenmann <cks@cs.toronto.edu>
To: Trond Myklebust <trondmy@hammerspace.com>
cc: "linux-nfs@vger.kernel.org" <linux-nfs@vger.kernel.org>,
        cks@cs.toronto.edu
Subject: Re: A NFS client partial file corruption problem in recent/current kernels
In-reply-to: Your message of Tue, 11 Sep 2018 17:12:26 -0000.
             <0bccf484c9b4e0949f767f96265756e5732f91ac.camel@hammerspace.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Date: Tue, 11 Sep 2018 14:02:18 -0400
Message-Id: <20180911180218.9A66C322562@apps1.cs.toronto.edu>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

> >  We've found a readily reproducable situation where the current
> > NFS client code will provide zero bytes instead of actual data at
> > the end of the file (sort of) to user programs. This can result
> > in program failure, or permanent file corruption if the program
> > reading the file writes the bad data back to the file; otherwise,
> > the corruption goes away when the client's cached data is pushed out
> > of memory (or explicitly dropped by dropping the pagecache through
> > /proc/sys/vm/drop_caches).
[...]
> Please see http://nfs.sourceforge.net/#faq_a8

 I don't think this is a close to open consistency issue, or if it is
I would argue that it is a clear bug on the Linux NFS client. I have
a number of reasons for saying this:

- the client clearly sees the new attributes; it knows that the file
  has been extended from the previous state that it knew of. My demo
  program specifically waits until user-level fstat() returns a different
  result, which I believe means that the client kernel has seen a different
  GETATTR result and so should have purged its cache (based on what the
  FAQ says).

  (Unless the FAQ means that the kernel absolutely refuses to guarantee
  anything about file consistency unless you close and then reopen the
  file, even if it *knows* that the file has changed on the server,
  which isn't clear from how the FAQ is currently written.)

- the client is fetching some new data from the fileserver (data after
  the partial 4 KB page at the old end of the file).

- the client isn't writing to the file in my demonstration program; it's
  only opening it in read-write mode and then reading it. Also, this
  doesn't happen if the client does exactly the same set of operations
  but has the file open read-only (with it staying open throughout).

- this didn't happen in older kernels.

In addition, although I didn't mention it in my original email, this
happens on a NFS filesystem mounted 'noac'.

Pragmatically, Alpine used to work with NFS mounted filesystems where
email was appended to them from other machines and it no longer does,
and the only difference is the kernel version involved on the client.
This breakage is actively dangerous.

	- cks
