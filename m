Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from cliff.cs.toronto.edu ([128.100.3.120]:41976 "EHLO
        cliff.cs.toronto.edu" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1726866AbeILBsR (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Tue, 11 Sep 2018 21:48:17 -0400
From: Chris Siebenmann <cks@cs.toronto.edu>
To: Chuck Lever <chuck.lever@oracle.com>
cc: Trond Myklebust <trondmy@hammerspace.com>,
        "cks@cs.toronto.edu" <cks@cs.toronto.edu>,
        Linux NFS Mailing List <linux-nfs@vger.kernel.org>
Subject: Re: A NFS client partial file corruption problem in recent/current kernels
In-reply-to: chuck.lever's message of Tue, 11 Sep 2018 16:40:20 -0400.
             <E2172838-41D5-46E5-B8C7-D5CFD9459DBF@oracle.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Date: Tue, 11 Sep 2018 16:47:14 -0400
Message-Id: <20180911204714.1FDBA322562@apps1.cs.toronto.edu>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

> >> Pragmatically, Alpine used to work with NFS mounted filesystems where
> >> email was appended to them from other machines and it no longer does,
> >> and the only difference is the kernel version involved on the client.
> >> This breakage is actively dangerous.
> > 
> > Sure, but unless you are locking the file, or you are explicitly using
> > O_DIRECT to do uncached I/O, then you are in violation of the close-to-
> > open consistency model, and the client is going to behave as you
> > describe above. NFS uses a distributed filesystem model, not a
> > clustered one.
> 
> I would expect Alpine to work if "vers=3,noac" is in use.

 We're setting noac (and vers=3) for our /var/mail NFS mount, but
perhaps we've got some additional option that is wrong here and
should be changed? According to /proc/mounts, our mount settings
for /var/mail are:

	fs0.cs.toronto.edu:/cs/mail /var/mail nfs rw,sync,nosuid,nodev,relatime,vers=3,rsize=1048576,wsize=1048576,namlen=255,acregmin=0,acregmax=0,acdirmin=0,acdirmax=0,hard,noac,noacl,proto=tcp,timeo=11,retrans=4,sec=sys,mountaddr=128.100.3.130,mountvers=3,mountport=34630,mountproto=udp,local_lock=none,addr=128.100.3.130

(To an OmniOS fileserver with ZFS.)

	- cks
