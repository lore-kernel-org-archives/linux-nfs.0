Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-pv0-f174.google.com ([74.125.83.174]:39521 "EHLO
	mail-pv0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S935437Ab1ETSft (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Fri, 20 May 2011 14:35:49 -0400
Received: by pvg12 with SMTP id 12so1783537pvg.19
        for <linux-nfs@vger.kernel.org>; Fri, 20 May 2011 11:35:48 -0700 (PDT)
Message-ID: <4DD6B483.2030401@uw.edu>
Date: Fri, 20 May 2011 11:35:47 -0700
From: Harry Edmon <harry@uw.edu>
To: "Dr. J. Bruce Fields" <bfields@fieldses.org>
CC: Trond Myklebust <Trond.Myklebust@netapp.com>,
        Chuck Lever <chuck.lever@oracle.com>, linux-nfs@vger.kernel.org
Subject: Re: 2.6.38.6 - state manager constantly respawns
References: <05D08339-888C-4A64-BDC5-8667B3901E7A@oracle.com> <4DD1772E.9010609@uw.edu> <6A6FB1C3-D4C3-40BE-810A-B4551FA9E591@oracle.com> <4DD17CB5.7010009@uw.edu> <1305575007.19725.3.camel@lade.trondhjem.org> <4DD17F79.305@uw.edu> <1305575656.19725.9.camel@lade.trondhjem.org> <20110516202059.GC1680@fieldses.org> <20110516205351.GD1680@fieldses.org> <4DD694DF.2060302@uw.edu> <20110520172639.GA11670@fieldses.org>
In-Reply-To: <20110520172639.GA11670@fieldses.org>
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

On 05/20/11 10:26, Dr. J. Bruce Fields wrote:
> On Fri, May 20, 2011 at 09:20:47AM -0700, Harry Edmon wrote:
>    
>> On 05/16/11 13:53, Dr. J. Bruce Fields wrote:
>>      
>>> Hm, so the renews all have clid 465ccc4d09000000, and the reads all have
>>> a stateid (0, 465ccc4dc24c0a0000000000).
>>>
>>> So the first 4 bytes matching just tells me both were handed out by the
>>> same server instance (so there was no server reboot in between); there's
>>> no way for me to tell whether they really belong to the same client.
>>>
>>> The server does assume that any stateid from the current server instance
>>> that no longer exists in its table is expired.  I believe that's
>>> correct, given a correctly functioning client, but perhaps I'm missing a
>>> case.
>>>
>>> --b.
>>>        
>> I am very appreciative of the quick initial comments I receive from
>> all of you on my NFS problem.   I notice that there has been silence
>> on the problem since the 16th, so I assume that either this is a
>> hard bug to track down or you have been busy with higher priority
>> tasks.  Is there anything I can do to help develop a solution to
>> this problem?
>>      
> Well, the only candidate explanation for the problem is that my
> assumption--that any time the server gets a stateid from the current
> boot instance that it doesn't recognize as an active stateid, it is safe
> for the server to return EXPIRED--is wrong.
>
> I don't immediately see why it's wrong, and based on the silence nobody
> else does either, but I'm not 100% convinced I'm right either.
>
> So one approach might be to add server code that makes a better effort
> to return EXPIRED only when we're sure it's a stateid from an expired
> client, and see if that solves your problem.
>
> Remind me, did you have an easy way to reproduce your problem?
>
> --b.
>    
It is somewhat random.   Sometimes it gets better after a client 
reboot.   The current case I have given you does not get better with a 
client reboot.

-- 
  Dr. Harry Edmon			E-MAIL: harry@uw.edu
  206-543-0547 FAX: 206-543-0308			harry@atmos.washington.edu
  Director of IT, College of the Environment and
  Director of Computing, Dept of Atmospheric Sciences
  University of Washington, Box 351640, Seattle, WA 98195-1640

