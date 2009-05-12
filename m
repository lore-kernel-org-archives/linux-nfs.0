From: Tom Talpey <tmtalpey@gmail.com>
Subject: Re: [PATCH 2.6.30] xprtrdma: The frmr iova_start values are
  truncated by	the nfs rdma client.
Date: Mon, 11 May 2009 20:23:55 -0400
Message-ID: <4a08c1b5.151e640a.0a99.fffff868@mx.google.com>
References: <20090424190510.3134.90405.stgit@build.ogc.int>
 <49F31A16.2080806@opengridcomputing.com>
 <49F4AE86.4090908@opengridcomputing.com>
 <49f515a5.1d1e640a.1c82.6677@mx.google.com>
 <49F5ED55.1010607@opengridcomputing.com>
 <1240855510.8818.9.camel@heimdal.trondhjem.org>
 <1240856613.8818.16.camel@heimdal.trondhjem.org>
 <49F60845.4010007@opengridcomputing.com>
 <1240865214.8818.73.camel@heimdal.trondhjem.org>
 <4A08A5C6.7040003@opengridcomputing.com>
 <1242082203.1743.11.camel@heimdal.trondhjem.org>
 <4A08BF1C.2050204@opengridcomputing.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: Trond Myklebust <trond.myklebust@fys.uio.no>,
	tom@opengridcomputing.com, linux-nfs@vger.kernel.org,
	vuhuong@mellanox.com
To: Steve Wise <swise@opengridcomputing.com>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from an-out-0708.google.com ([209.85.132.244]:33612 "EHLO
	an-out-0708.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754205AbZELAY2 (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 11 May 2009 20:24:28 -0400
Received: by an-out-0708.google.com with SMTP id d40so10830121and.1
        for <linux-nfs@vger.kernel.org>; Mon, 11 May 2009 17:24:28 -0700 (PDT)
In-Reply-To: <4A08BF1C.2050204@opengridcomputing.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

At 08:13 PM 5/11/2009, Steve Wise wrote:
>Trond Myklebust wrote:
>> On Mon, 2009-05-11 at 17:25 -0500, Steve Wise wrote:
>>   
>>> Hey Trond,
>>>
>>> Will this bug fix make 2.6.30?
>>>
>>> Thanks,
>>>
>>> Steve.
>>>     
>>
>> Not in the form it is in now. As I've said earlier, I'm not happy about
>> the sunrpc layer having to circumvent ordinary type checking on
>> non-sunrpc structures.
>>
>> Cheers
>>     Trond
>How is it circumventing?  It's currently incorrectly casting a pointer 
>into a u64.  That seems just broken to me.

The cast is definitely broken, and since your patch removes it I agree
with the change, for the record. Especially since with the change, the
code doesn't work on 32-bit CPU / 64-bit IOMMU platforms.

>  Also, its really the sunrpc 
>rdma transport layer.  It deals specifically with rdma.  It _should_ 
>know about rdma interfaces and types.

IOW, this is an issue for the OFA API to address? I agree with Trond that
there are some hardware-specific warts in there. It might be a good idea
for us to go through both the client and server code overall - you up for
doing that? I'm in, if so.

Tom.


>
>But  I'll whip up get/put type accessor methods for this field if that's 
>what you require.  In the meantime, customers will just crash I guess.
>
>
>Steve.
>
>
>
>

