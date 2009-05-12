From: Steve Wise <swise@opengridcomputing.com>
Subject: Re: [PATCH 2.6.30] xprtrdma: The frmr iova_start values are  truncated
 by	the nfs rdma client.
Date: Mon, 11 May 2009 19:13:16 -0500
Message-ID: <4A08BF1C.2050204@opengridcomputing.com>
References: <20090424190510.3134.90405.stgit@build.ogc.int>	 <49F31A16.2080806@opengridcomputing.com>	 <49F4AE86.4090908@opengridcomputing.com>	 <49f515a5.1d1e640a.1c82.6677@mx.google.com>	 <49F5ED55.1010607@opengridcomputing.com>	 <1240855510.8818.9.camel@heimdal.trondhjem.org>	 <1240856613.8818.16.camel@heimdal.trondhjem.org>	 <49F60845.4010007@opengridcomputing.com>	 <1240865214.8818.73.camel@heimdal.trondhjem.org>	 <4A08A5C6.7040003@opengridcomputing.com> <1242082203.1743.11.camel@heimdal.trondhjem.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Cc: Tom Talpey <tmtalpey@gmail.com>, tom@opengridcomputing.com,
	linux-nfs@vger.kernel.org, vuhuong@mellanox.com
To: Trond Myklebust <trond.myklebust@fys.uio.no>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from smtp.opengridcomputing.com ([209.198.142.2]:38872 "EHLO
	smtp.opengridcomputing.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1754421AbZELANT (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 11 May 2009 20:13:19 -0400
In-Reply-To: <1242082203.1743.11.camel-rJ7iovZKK19ZJLDQqaL3InhyD016LWXt@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Trond Myklebust wrote:
> On Mon, 2009-05-11 at 17:25 -0500, Steve Wise wrote:
>   
>> Hey Trond,
>>
>> Will this bug fix make 2.6.30?
>>
>> Thanks,
>>
>> Steve.
>>     
>
> Not in the form it is in now. As I've said earlier, I'm not happy about
> the sunrpc layer having to circumvent ordinary type checking on
> non-sunrpc structures.
>
> Cheers
>     Trond
How is it circumventing?  It's currently incorrectly casting a pointer 
into a u64.  That seems just broken to me.  Also, its really the sunrpc 
rdma transport layer.  It deals specifically with rdma.  It _should_ 
know about rdma interfaces and types.

But  I'll whip up get/put type accessor methods for this field if that's 
what you require.  In the meantime, customers will just crash I guess.


Steve.



