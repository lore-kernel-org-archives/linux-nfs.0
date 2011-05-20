Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx2.netapp.com ([216.240.18.37]:58022 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S933419Ab1ETSu5 (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Fri, 20 May 2011 14:50:57 -0400
Message-ID: <4DD6B80E.8010402@netapp.com>
Date: Fri, 20 May 2011 14:50:54 -0400
From: Bryan Schumaker <bjschuma@netapp.com>
To: "Dr. J. Bruce Fields" <bfields@fieldses.org>
CC: Trond Myklebust <Trond.Myklebust@netapp.com>, Harry Edmon <harry@uw.edu>,
        Chuck Lever <chuck.lever@oracle.com>, linux-nfs@vger.kernel.org
Subject: Re: 2.6.38.6 - state manager constantly respawns
References: <6A6FB1C3-D4C3-40BE-810A-B4551FA9E591@oracle.com> <4DD17CB5.7010009@uw.edu> <1305575007.19725.3.camel@lade.trondhjem.org> <4DD17F79.305@uw.edu> <1305575656.19725.9.camel@lade.trondhjem.org> <20110516202059.GC1680@fieldses.org> <20110516205351.GD1680@fieldses.org> <4DD694DF.2060302@uw.edu> <20110520172639.GA11670@fieldses.org> <1305913963.12712.6.camel@lade.trondhjem.org> <20110520184738.GB11670@fieldses.org>
In-Reply-To: <20110520184738.GB11670@fieldses.org>
Content-Type: text/plain; charset=ISO-8859-1
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

On 05/20/2011 02:47 PM, Dr. J. Bruce Fields wrote:
> On Fri, May 20, 2011 at 01:52:43PM -0400, Trond Myklebust wrote:
>> On Fri, 2011-05-20 at 13:26 -0400, Dr. J. Bruce Fields wrote: 
>>> On Fri, May 20, 2011 at 09:20:47AM -0700, Harry Edmon wrote:
>>>> On 05/16/11 13:53, Dr. J. Bruce Fields wrote:
>>>>> Hm, so the renews all have clid 465ccc4d09000000, and the reads all have
>>>>> a stateid (0, 465ccc4dc24c0a0000000000).
>>>>>
>>>>> So the first 4 bytes matching just tells me both were handed out by the
>>>>> same server instance (so there was no server reboot in between); there's
>>>>> no way for me to tell whether they really belong to the same client.
>>>>>
>>>>> The server does assume that any stateid from the current server instance
>>>>> that no longer exists in its table is expired.  I believe that's
>>>>> correct, given a correctly functioning client, but perhaps I'm missing a
>>>>> case.
>>>>>
>>>>> --b.
>>>> I am very appreciative of the quick initial comments I receive from
>>>> all of you on my NFS problem.   I notice that there has been silence
>>>> on the problem since the 16th, so I assume that either this is a
>>>> hard bug to track down or you have been busy with higher priority
>>>> tasks.  Is there anything I can do to help develop a solution to
>>>> this problem?
>>>
>>> Well, the only candidate explanation for the problem is that my
>>> assumption--that any time the server gets a stateid from the current
>>> boot instance that it doesn't recognize as an active stateid, it is safe
>>> for the server to return EXPIRED--is wrong.
>>>
>>> I don't immediately see why it's wrong, and based on the silence nobody
>>> else does either, but I'm not 100% convinced I'm right either.
>>>
>>> So one approach might be to add server code that makes a better effort
>>> to return EXPIRED only when we're sure it's a stateid from an expired
>>> client, and see if that solves your problem.
>>>
>>> Remind me, did you have an easy way to reproduce your problem?
>>
>> My silence is simply because I'm mystified as to how this can happen.
> 
> So since the client's sending it with a READ, the client thinks that the
> stateid is still a valid open, lock, or delegation stateid, while the
> server thinks it's not.  Hm.

I found this bug when I used "forget all locks" in the fault injection code I recently posted.  Trond's fix works for me.

- Bryan

> 
> --b.
> 
>> Patching for it is trivial (see below).
>>
>> When the server tells us that our lease is expired, the normal behaviour
>> for the client is to re-establish the lease, and then proceed to recover
>> all known stateids. I don't see how we can 'miss' a stateid that then
>> needs to be recovered afterwards...
> --
> To unsubscribe from this list: send the line "unsubscribe linux-nfs" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html

