Return-Path: linux-nfs-owner@vger.kernel.org
Received: from natasha.panasas.com ([67.152.220.90]:37728 "EHLO
	natasha.panasas.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752148Ab2FKPE6 (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 11 Jun 2012 11:04:58 -0400
Message-ID: <4FD608EC.2050307@panasas.com>
Date: Mon, 11 Jun 2012 18:04:12 +0300
From: Boaz Harrosh <bharrosh@panasas.com>
MIME-Version: 1.0
To: Jeff Layton <jlayton@redhat.com>
CC: bfields <bfields@fieldses.org>, Steve Dickson <steved@redhat.com>,
        "Myklebust, Trond" <Trond.Myklebust@netapp.com>,
        Joerg Platte <jplatte@naasa.net>,
        "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
        "linux-nfs@vger.kernel.org" <linux-nfs@vger.kernel.org>,
        Hans de Bruin <jmdebruin@xmsnet.nl>
Subject: Re: Kernel 3.4.X NFS server regression
References: <4FD47D4E.9070307@naasa.net> <1339340441.4751.1.camel@lade.trondhjem.org> <20120611121634.GB7654@fieldses.org> <20120611083932.24e27e39@corrin.poochiereds.net> <4FD5F35A.3000903@panasas.com> <20120611095132.045a8d09@corrin.poochiereds.net> <4FD5FB28.4050003@panasas.com> <20120611101141.143fff3c@corrin.poochiereds.net> <4FD60472.7020207@panasas.com> <20120611105515.3b99942c@tlielax.poochiereds.net>
In-Reply-To: <20120611105515.3b99942c@tlielax.poochiereds.net>
Content-Type: text/plain; charset="UTF-8"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On 06/11/2012 05:55 PM, Jeff Layton wrote:

> On Mon, 11 Jun 2012 17:45:06 +0300
> Boaz Harrosh <bharrosh@panasas.com> wrote:
> 
>> On 06/11/2012 05:11 PM, Jeff Layton wrote:
>>
>>> On Mon, 11 Jun 2012 17:05:28 +0300
>>> Boaz Harrosh <bharrosh@panasas.com> wrote:
>>>
>>>> On 06/11/2012 04:51 PM, Jeff Layton wrote:
>>>>
>>>>>
>>>>> That was considered here, but the problem with the usermode helper is
>>>>> that you can't pass anything back to the kernel but a simple status
>>>>> code (and that's assuming that you wait for it to exit). In the near
>>>>> future, we'll need to pass back more info to the kernel for this, so
>>>>> the usermode helper callout wasn't suitable.
>>>>>
>>>>
>>>>
>>>> I have answered that in my mail. Repeated here again. Well you made 
>>>> a simple mistake. Because it is *easy* to pass back any number and
>>>> size of information from user-mode.
>>>>
>>>> You just setup a sysfs entry points where the answers are written
>>>> back to. It's an easy trick to setup a thread safe, way with a
>>>> cookie but 90% of the time you don't have to. Say you set up
>>>> a structure of per-client (identified uniquely) then user mode
>>>> answers back per client, concurrency will not do any harm, since
>>>> you answer to the same question the same answer. ans so on. Each
>>>> problem it's own.
>>>>
>>>> If you want we can talk about this, it would be easy for me to setup
>>>> a toll free conference number we can all use.
>>>
>>> That helpful advice would have been welcome about 3-4 months ago when I
>>> first proposed this in detail. At that point you're working with
>>> multiple upcall/downcall mechanisms, which was something I was keen to
>>> avoid.
>>>
>>> I'm not opposed to moving in that direction, but it basically means
>>> you're going to rip out everything I've got here so far and replace it.
>>>
>>> If you're willing to do that work, I'll be happy to work with you on
>>> it, but I don't have the time or inclination to do that on my own right
>>> now.
>>>
>>
>>
>> No such luck. sorry. I wish I could, but coming from a competing server
>> company, you can imagine the priority of that ever happening.
>> (Even though I use the Linux-Server everyday for my development and
>>  am putting lots of efforts into still, mainly in pnfs)
>>
>> Hopefully re-examining the code, it could all be salvaged just the
>> same, only lots of code thrown a way.
>>
>> But mean-while please address my concern below:
>> Boaz Harrosh wrote: 
>>
>>> One more thing, the most important one. We have already fixed that in the
>>> past and I was hoping the lesson was learned. Apparently it was not, and
>>> we are doomed to do this mistake for ever!!
>>>
>>> What ever crap fails times out and crashes, in the recovery code, we don't
>>> give a dam. It should never affect any Server-client communication.
>>>
>>> When the grace periods ends the clients gates opens period. *Any* error
>>> return from state recovery code must be carefully ignored and normal
>>> operations resumed. At most on error, we move into a mode where any
>>> recovery request from client is accepted, since we don't have any better
>>> data to verify it.
>>>
>>> Please comb recovery code to make sure any catastrophe is safely ignored.
>>> We already did that before and it used to work.
>>
>>
>> We should make sure that any state recovery code does not interfere with
>> regular operations. and fails gracefully / shuts up. 
>>
>> We used to have that, apparently it re-broke. Clients should always be granted
>> access, after grace period. And Server should be made sure not to fail in any
>> situation.
>>
>> I would look into it but I'm not uptodate anymore, I wish you or Bruce could.
>>
>> Thanks for your work so far, sorry to be bearer of bad news
>> Boaz
> 
> This problem turned out to be a fairly straightforward bug in the
> rpc_pipefs queue timeout mechanism that was causing the laundromat job
> to hang and hence to keep the state lock locked. I just sent a patch
> that should fix it.
> 
> I guess I'm not clear on what you're saying is broken. Modulo the
> original bug here, clients are allowed access after the grace period
> whether the upcalls are working or not.
> 
> What we cannot allow is reclaim requests outside of the grace period,
> since we can't verify whether there was conflicting state in the
> interim period. That's true whether the server has a functioning client
> tracking mechanism or not.
> 


I agree. Sorry we keep communicating on two different threads. Dis regard
the other last mail.

Sounds good then. My point, we should be very defensive with  state recovery
code not getting in our way.

Thanks
Boaz

