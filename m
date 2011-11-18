Return-Path: linux-nfs-owner@vger.kernel.org
Received: from oceanic.CalvaEDI.COM ([89.202.194.168]:59133 "EHLO
	oceanic.CalvaEDI.COM" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756576Ab1KRWdG (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Fri, 18 Nov 2011 17:33:06 -0500
Message-ID: <4EC6DD4D.1010008@calvaedi.com>
Date: Fri, 18 Nov 2011 23:33:49 +0100
From: John Hughes <john@calvaedi.com>
MIME-Version: 1.0
To: Trond Myklebust <Trond.Myklebust@netapp.com>
CC: Jim Rees <rees@umich.edu>, John Hughes <john@Calva.COM>,
        linux-nfs@vger.kernel.org, linux-kernel@vger.kernel.org
Subject: Re: [PATCH] Add "-e" option to rpc.gssd to allow error on ticket
 expiry. Try 2 with added man pages.
References: <4EC66D12.2090505@Calva.COM>	 <1321641333.2653.15.camel@lade.trondhjem.org>	 <4EC6AFA9.9000705@calvaedi.com>	 <1321648435.2653.53.camel@lade.trondhjem.org>	 <20111118205749.GA1680@umich.edu> <1321650239.2653.68.camel@lade.trondhjem.org>
In-Reply-To: <1321650239.2653.68.camel@lade.trondhjem.org>
Content-Type: text/plain; charset=UTF-8; format=flowed
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On 11/18/2011 10:03 PM, Trond Myklebust wrote:
> On Fri, 2011-11-18 at 15:57 -0500, Jim Rees wrote:
>    
>>
>> The write() syscall doesn't indicate whether the data is safe or not.  That
>> would be the close() syscall.
>>      
> fsync(). Which may succeed if the user renews their ticket first.
> However you may still have data loss if dirty data has been lost because
> of EKEYEXPIRED returns on the WRITE RPC call...
>    
Only if the write(2) returned EKEYEXPIRED, surely,
> Also, for the fsync() to return EKEYEXPIRED _after_ the user has renewed
> their ticket would seem counter-intuitive to most people.
>    

I would want to know if data was lost.

Intuition means nothing if I get an error.

If it were possible I'd like:

1. write works
1a. WRITE RPC fails, data stays in cache
2. ticket renewed
3. fsync works, data written

But:

1. write...
1a. WRITE RPC fails
1b. ... fails

seems ok.

Even

1. write works
1a WRITE RPC fails
2. ticket renewed
3. fsync fails

would be ok for me.  (light cone problems?)

