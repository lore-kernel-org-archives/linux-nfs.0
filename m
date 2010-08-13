Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-ww0-f44.google.com ([74.125.82.44]:40790 "EHLO
	mail-ww0-f44.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751640Ab0HMFQ6 (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Fri, 13 Aug 2010 01:16:58 -0400
Received: by wwj40 with SMTP id 40so2495865wwj.1
        for <linux-nfs@vger.kernel.org>; Thu, 12 Aug 2010 22:16:57 -0700 (PDT)
In-Reply-To: <AANLkTikStDSBi2Dm0oMAEpVbE9PFZOTmOkW6Wy92wjj-@mail.gmail.com>
References: <87lj8ckb1e.fsf@patl.com>
	<8762zgmmer.fsf@patl.com>
	<1281628195.2873.12.camel@heimdal.trondhjem.org>
	<AANLkTi=WzNzq7wKf0qa+VFuOBYy4yW==0QvdKsTQ88+x@mail.gmail.com>
	<1281634004.14329.14.camel@heimdal.trondhjem.org>
	<AANLkTikStDSBi2Dm0oMAEpVbE9PFZOTmOkW6Wy92wjj-@mail.gmail.com>
Date: Thu, 12 Aug 2010 22:16:57 -0700
Message-ID: <AANLkTi=OEkPuL+0E_VhPOn-U6neR=jJWunz-2DT755aB@mail.gmail.com>
Subject: Re: [PATCH] nfs: lookupcache coherence bugs in WCC update path (revised)
From: "Patrick J. LoPresti" <lopresti@gmail.com>
To: linux-nfs@vger.kernel.org
Cc: Trond Myklebust <trond.myklebust@fys.uio.no>
Content-Type: text/plain; charset=ISO-8859-1
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

OK, I found the problem.  Whether it is a bug depends on your point of
view, I suppose.

Although I am using XFS on my file server, and XFS has
nanosecond-granularity timestamps, the true granularity of ctime/mtime
is ultimately determined by the resolution of current_fs_time() which
calls current_kernel_time(); i.e. jiffies; i.e. 1/HZ.

On my system (SLES 11 SP1), HZ is 250.  In my failing application, 4
ms is long enough for many filesystem operations, even over NFS. (My
network is 10GigE with a 300 microsecond round trip time, and my
systems are very new.)

Anyway, I instrumented the VFS code on the NFS server to catch it in
the act; specifically, I saw the following sequence:

file A is created on server, updating directory mtime
NFS client does LOOKUP on file B, gets nfserr_noent
file B created on server, does not update directory's mtime

...all within 4 milliseconds (which is why the creation of file B did
not update the directory's mtime).

The result is that the lookup cache on the client is stale and stays
stale until some other client (or the server) updates the directory.
Even making changes from the client does not invalidate the cache,
thanks to the clever WCC logic that Trond had to explain to me
earlier.

This is not exactly an NFS specific question, but I will ask anyway...
 If I were to propose modifying current_fs_time() to call
getnstimeofday() instead of current_kernel_time(), would the VFS folks
laugh me out the door?

1/HZ granularity for file timestamps just seems so...  90s or
something.  4ms really is a lot of time these days.

 - Pat
