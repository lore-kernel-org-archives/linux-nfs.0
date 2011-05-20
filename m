Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-pw0-f46.google.com ([209.85.160.46]:63508 "EHLO
	mail-pw0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S934649Ab1ETQUu (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Fri, 20 May 2011 12:20:50 -0400
Received: by pwi15 with SMTP id 15so1777983pwi.19
        for <linux-nfs@vger.kernel.org>; Fri, 20 May 2011 09:20:50 -0700 (PDT)
Message-ID: <4DD694DF.2060302@uw.edu>
Date: Fri, 20 May 2011 09:20:47 -0700
From: Harry Edmon <harry@uw.edu>
To: "Dr. J. Bruce Fields" <bfields@fieldses.org>
CC: Trond Myklebust <Trond.Myklebust@netapp.com>,
        Chuck Lever <chuck.lever@oracle.com>, linux-nfs@vger.kernel.org
Subject: Re: 2.6.38.6 - state manager constantly respawns
References: <4DD16FA8.4030602@uw.edu> <05D08339-888C-4A64-BDC5-8667B3901E7A@oracle.com> <4DD1772E.9010609@uw.edu> <6A6FB1C3-D4C3-40BE-810A-B4551FA9E591@oracle.com> <4DD17CB5.7010009@uw.edu> <1305575007.19725.3.camel@lade.trondhjem.org> <4DD17F79.305@uw.edu> <1305575656.19725.9.camel@lade.trondhjem.org> <20110516202059.GC1680@fieldses.org> <20110516205351.GD1680@fieldses.org>
In-Reply-To: <20110516205351.GD1680@fieldses.org>
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

On 05/16/11 13:53, Dr. J. Bruce Fields wrote:
> On Mon, May 16, 2011 at 04:20:59PM -0400, Dr. J. Bruce Fields wrote:
>    
>> On Mon, May 16, 2011 at 03:54:16PM -0400, Trond Myklebust wrote:
>>      
>>> On Mon, 2011-05-16 at 12:48 -0700, Harry Edmon wrote:
>>>        
>>>> On 05/16/11 12:43, Trond Myklebust wrote:
>>>>          
>>>>> On Mon, 2011-05-16 at 12:36 -0700, Harry Edmon wrote:
>>>>>
>>>>>            
>>>>>> On 05/16/11 12:22, Chuck Lever wrote:
>>>>>>
>>>>>>              
>>>>>>> On May 16, 2011, at 3:12 PM, Harry Edmon wrote:
>>>>>>>
>>>>>>>
>>>>>>>
>>>>>>>                
>>>>>>>> Attached is 1000 lines of output from tshark when the problem is occurring.   The client and server are connected by a private ethernet.
>>>>>>>>
>>>>>>>>
>>>>>>>>                  
>>>>>>> Disappointing: tshark is not telling us the return codes.  However, I see "PUTFH;READ" then "RENEW" in a loop, which indicates the state manager thread is being kicked off because of ongoing difficulties with state recovery.  Is there a stuck application on that client?
>>>>>>>
>>>>>>> Try again with "tshark -V".
>>>>>>>
>>>>>>>
>>>>>>>                
>>>>>> Here is the output from tshark -V (first 50,000 lines).   Nothing
>>>>>> appears to be stuck, and as I said when I reboot the client into 2.6.32
>>>>>> the problem goes away, only to reappear when I reboot it back into 2.6.38.6.
>>>>>>
>>>>>>
>>>>>>              
>>>>> Possibly, but it definitely indicates a server bug. What kind of server
>>>>> are you using?
>>>>>
>>>>> Basically, the client is getting confused because when it sends a READ,
>>>>> the server is telling it that the lease has expired, then when it sends
>>>>> a RENEW, the same server replies that the lease is OK...
>>>>>
>>>>> Trond
>>>>>
>>>>>            
>>>> The server is running the 2.6.38.6 kernel with Debian squeeze, just like
>>>> the client.   The kernel config is attached.
>>>>          
>>> Bruce, any idea how the server might get into this state?
>>>        
>> So READ is getting ESTALE
>>      
> Err, sorry, EXPIRED.
>
>    
>> and RENEW is getting OK?  And we're positive
>> that the stateid on the READ is derived from the clientid sent with the
>> RENEW?
>>
>> OK, I'll look at the capture....
>>      
> Hm, so the renews all have clid 465ccc4d09000000, and the reads all have
> a stateid (0, 465ccc4dc24c0a0000000000).
>
> So the first 4 bytes matching just tells me both were handed out by the
> same server instance (so there was no server reboot in between); there's
> no way for me to tell whether they really belong to the same client.
>
> The server does assume that any stateid from the current server instance
> that no longer exists in its table is expired.  I believe that's
> correct, given a correctly functioning client, but perhaps I'm missing a
> case.
>
> --b.
>    
I am very appreciative of the quick initial comments I receive from all 
of you on my NFS problem.   I notice that there has been silence on the 
problem since the 16th, so I assume that either this is a hard bug to 
track down or you have been busy with higher priority tasks.  Is there 
anything I can do to help develop a solution to this problem?

-- 
  Dr. Harry Edmon			E-MAIL: harry@uw.edu
  206-543-0547 FAX: 206-543-0308			harry@atmos.washington.edu
  Director of IT, College of the Environment and
  Director of Computing, Dept of Atmospheric Sciences
  University of Washington, Box 351640, Seattle, WA 98195-1640

