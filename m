From: Harry Edmon <harry@uw.edu>
Subject: Re: 2.6.38.6 - state manager constantly respawns
Date: Mon, 16 May 2011 13:37:23 -0700
Message-ID: <4DD18B03.1050101@uw.edu>
References: <4DD16FA8.4030602@uw.edu>	 <05D08339-888C-4A64-BDC5-8667B3901E7A@oracle.com> <4DD1772E.9010609@uw.edu>	 <6A6FB1C3-D4C3-40BE-810A-B4551FA9E591@oracle.com> <4DD17CB5.7010009@uw.edu>	 <1305575007.19725.3.camel@lade.trondhjem.org>	 <8382A5A9-381C-47D7-B2DF-64625FE7C08C@oracle.com> <1305578007.19725.24.camel@lade.trondhjem.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Cc: Chuck Lever <chuck.lever@oracle.com>, linux-nfs@vger.kernel.org
To: Trond Myklebust <Trond.Myklebust@netapp.com>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-pw0-f46.google.com ([209.85.160.46]:58549 "EHLO
	mail-pw0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755569Ab1EPUhZ (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 16 May 2011 16:37:25 -0400
Received: by pwi15 with SMTP id 15so2286518pwi.19
        for <linux-nfs@vger.kernel.org>; Mon, 16 May 2011 13:37:25 -0700 (PDT)
In-Reply-To: <1305578007.19725.24.camel-SyLVLa/KEI9HwK5hSS5vWB2eb7JE58TQ@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On 05/16/11 13:33, Trond Myklebust wrote:
> On Mon, 2011-05-16 at 16:21 -0400, Chuck Lever wrote:
>    
>> On May 16, 2011, at 3:43 PM, Trond Myklebust wrote:
>>
>>      
>>> On Mon, 2011-05-16 at 12:36 -0700, Harry Edmon wrote:
>>>        
>>>> On 05/16/11 12:22, Chuck Lever wrote:
>>>>          
>>>>> On May 16, 2011, at 3:12 PM, Harry Edmon wrote:
>>>>>
>>>>>
>>>>>            
>>>>>> Attached is 1000 lines of output from tshark when the problem is occurring.   The client and server are connected by a private ethernet.
>>>>>>
>>>>>>              
>>>>> Disappointing: tshark is not telling us the return codes.  However, I see "PUTFH;READ" then "RENEW" in a loop, which indicates the state manager thread is being kicked off because of ongoing difficulties with state recovery.  Is there a stuck application on that client?
>>>>>
>>>>> Try again with "tshark -V".
>>>>>
>>>>>            
>>>> Here is the output from tshark -V (first 50,000 lines).   Nothing
>>>> appears to be stuck, and as I said when I reboot the client into 2.6.32
>>>> the problem goes away, only to reappear when I reboot it back into 2.6.38.6.
>>>>
>>>>          
>>> Possibly, but it definitely indicates a server bug. What kind of server
>>> are you using?
>>>
>>> Basically, the client is getting confused because when it sends a READ,
>>> the server is telling it that the lease has expired, then when it sends
>>> a RENEW, the same server replies that the lease is OK...
>>>        
>> I've seen this during migration recovery testing.  The client may be testing the wrong client ID.
>>
>> But I wonder if it's really worth doing that separate RENEW.  I've seen the client send a RENEW after it gets STALE_STATEID.  Would RENEW really tell the client anything in that case?
>>      
> It is needed.
>
> Without the RENEW, we have no idea whether or not we need to do a full
> state recovery. Running a full recovery when we don't have to is _bad_,
> and will usually cause us to lose delegations and may possibly even
> cause us to lose locks.
>
>    
By the way, this is not the only client/server running 2.6.38 that I 
have this problem on.   It is occurring on other random ones I 
maintain.  This example is happens to be the cleanest one I have, this 
NFS server is only talking to this specific NFS client over a private 
network.
-- 

  Dr. Harry Edmon			E-MAIL: harry@uw.edu
  206-543-0547 FAX: 206-543-0308			harry-qmPYOCrcNLLyFCzt5hm0YvZ8FUJU4vz8@public.gmane.org
  Director of IT, College of the Environment and
  Director of Computing, Dept of Atmospheric Sciences
  University of Washington, Box 351640, Seattle, WA 98195-1640

