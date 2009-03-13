Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from wf-out-1314.google.com ([209.85.200.173]:18212 "EHLO
	wf-out-1314.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1759505AbZCMVcT (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Fri, 13 Mar 2009 17:32:19 -0400
Received: by wf-out-1314.google.com with SMTP id 28so660944wfa.4
        for <linux-nfs@vger.kernel.org>; Fri, 13 Mar 2009 14:32:17 -0700 (PDT)
In-Reply-To: <1236978608.7265.41.camel@heimdal.trondhjem.org>
References: <72dbd3150903131336m78526d4ao1308052d6233b70@mail.gmail.com>
	 <1236978608.7265.41.camel@heimdal.trondhjem.org>
Date: Fri, 13 Mar 2009 14:32:17 -0700
Message-ID: <72dbd3150903131432u43d9ba43nf0456b99aed0f8fd@mail.gmail.com>
Subject: Re: Horrible NFS Client Performance During Heavy Server IO
From: David Rees <drees76@gmail.com>
To: Trond Myklebust <trond.myklebust@fys.uio.no>
Cc: linux-nfs@vger.kernel.org
Content-Type: text/plain; charset=ISO-8859-1
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

On Fri, Mar 13, 2009 at 2:10 PM, Trond Myklebust
<trond.myklebust@fys.uio.no> wrote:
> On Fri, 2009-03-13 at 13:36 -0700, David Rees wrote:
>> Steps to reproduce:
>>
>> 1. Write a big file to the same partition that is exported on the server:
>> dd if=/dev/zero of=/opt/export/bigfile bs=1M count=5000 conv=fdatasync
>> 2. Write a small file to the same partition from the client:
>> dd if=/dev/zero of=/opt/export/bigfile bs=16k count=8 conf=fdatasync
>
> You don't need conv=fdatasync when writing to NFS. The close-to-open
> cache consistency automatically guarantees fdatasync on close().

Yeah, I didn't think I did, but I added it for good measure since I
needed it to simulate load directly on the server.  It doesn't seem to
affect the numbers significantly either way.

>> I am seeing slightly less than 2kBps (yes, 1000-2000 bytes per second)
>> from the client while this is happening.
>
> UDP transport, or TCP? If the former, then definitely switch to the
> latter, since you're probably pounding the server with unnecessary RPC
> retries while it is busy with the I/O.
>
> For the same reason, also make sure that -otimeo=600 (the default for
> TCP).

Yes, both set that way by default.  From /proc/mounts on the client:

rw,vers=3,rsize=1048576,wsize=1048576,namlen=255,hard,nointr,proto=tcp,timeo=600,retrans=2,sec=sys,mountaddr=10.2.1.13,mountvers=3,mountproto=tcp,addr=10.2.1.13

-Dave
