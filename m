Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from rcsinet10.oracle.com ([148.87.113.121]:41842 "EHLO
	rcsinet10.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751470Ab1EPUVr convert rfc822-to-8bit (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 16 May 2011 16:21:47 -0400
Subject: Re: 2.6.38.6 - state manager constantly respawns
Content-Type: text/plain; charset=us-ascii
From: Chuck Lever <chuck.lever@oracle.com>
In-Reply-To: <1305575007.19725.3.camel@lade.trondhjem.org>
Date: Mon, 16 May 2011 16:21:33 -0400
Cc: Harry Edmon <harry@uw.edu>, linux-nfs@vger.kernel.org
Message-Id: <8382A5A9-381C-47D7-B2DF-64625FE7C08C@oracle.com>
References: <4DD16FA8.4030602@uw.edu> <05D08339-888C-4A64-BDC5-8667B3901E7A@oracle.com> <4DD1772E.9010609@uw.edu> <6A6FB1C3-D4C3-40BE-810A-B4551FA9E591@oracle.com> <4DD17CB5.7010009@uw.edu> <1305575007.19725.3.camel@lade.trondhjem.org>
To: Trond Myklebust <Trond.Myklebust@netapp.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0


On May 16, 2011, at 3:43 PM, Trond Myklebust wrote:

> On Mon, 2011-05-16 at 12:36 -0700, Harry Edmon wrote:
>> On 05/16/11 12:22, Chuck Lever wrote:
>>> On May 16, 2011, at 3:12 PM, Harry Edmon wrote:
>>> 
>>> 
>>>> Attached is 1000 lines of output from tshark when the problem is occurring.   The client and server are connected by a private ethernet.
>>>> 
>>> Disappointing: tshark is not telling us the return codes.  However, I see "PUTFH;READ" then "RENEW" in a loop, which indicates the state manager thread is being kicked off because of ongoing difficulties with state recovery.  Is there a stuck application on that client?
>>> 
>>> Try again with "tshark -V".
>>> 
>> Here is the output from tshark -V (first 50,000 lines).   Nothing 
>> appears to be stuck, and as I said when I reboot the client into 2.6.32 
>> the problem goes away, only to reappear when I reboot it back into 2.6.38.6.
>> 
> 
> Possibly, but it definitely indicates a server bug. What kind of server
> are you using?
> 
> Basically, the client is getting confused because when it sends a READ,
> the server is telling it that the lease has expired, then when it sends
> a RENEW, the same server replies that the lease is OK...

I've seen this during migration recovery testing.  The client may be testing the wrong client ID.

But I wonder if it's really worth doing that separate RENEW.  I've seen the client send a RENEW after it gets STALE_STATEID.  Would RENEW really tell the client anything in that case?

-- 
Chuck Lever
chuck[dot]lever[at]oracle[dot]com




