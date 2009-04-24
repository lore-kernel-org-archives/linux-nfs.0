Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-out1.uio.no ([129.240.10.57]:46560 "EHLO mail-out1.uio.no"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1756495AbZDXOO2 (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Fri, 24 Apr 2009 10:14:28 -0400
Subject: Re: NFS BUG_ON in nfs_do_writepage
From: Trond Myklebust <trond.myklebust@fys.uio.no>
To: Rince <rincebrain@gmail.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, linux-kernel@vger.kernel.org,
        linux-nfs@vger.kernel.org
In-Reply-To: <5da0588e0904240226j3454941y5f58c17a32a9a23d@mail.gmail.com>
References: <alpine.LFD.2.00.0904130145050.4396@centaur.acm.jhu.edu>
	 <20090412235010.c8e3475b.akpm@linux-foundation.org>
	 <1239650202.16771.15.camel@heimdal.trondhjem.org>
	 <5da0588e0904131506k5c58e8ddob9bf38f61da6302a@mail.gmail.com>
	 <5da0588e0904131644g131dc816r61884e83bc4cd006@mail.gmail.com>
	 <5da0588e0904240226j3454941y5f58c17a32a9a23d@mail.gmail.com>
Content-Type: text/plain
Date: Fri, 24 Apr 2009 10:14:19 -0400
Message-Id: <1240582459.4946.31.camel@heimdal.trondhjem.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

On Fri, 2009-04-24 at 05:26 -0400, Rince wrote:
> Applied try 3 of Nick Piggin's patch to 2.6.30-rc3 (cleanly, no less!)
> 
> Doesn't appear to have helped at all - I received my favorite BUG ON
> write.c:252 just like always, within 24 hours of booting the kernel,
> even.
> 
> - Rich

Yes. I'm able to reproduce this bug now. I found that I can trigger it
fairly reliably by running iozone in something like the following
configuration: "iozone -t 32 -r 1k -s 256m -c -D -K -Z -i0 -i8"

I believe it boils down to the problems being discussed in the following
thread:
   http://thread.gmane.org/gmane.linux.nfs/26181

Cheers
  Trond

