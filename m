Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx12.netapp.com ([216.240.18.77]:36085 "EHLO mx12.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755725Ab3HAPYH convert rfc822-to-8bit (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 1 Aug 2013 11:24:07 -0400
From: "Adamson, Dros" <Weston.Adamson@netapp.com>
To: "J. Bruce Fields" <bfields@fieldses.org>
CC: linux-nfs list <linux-nfs@vger.kernel.org>
Subject: Re: SP4_MACH_CRED
Date: Thu, 1 Aug 2013 15:24:05 +0000
Message-ID: <88EAD768-768D-43A3-8E4D-D9B904C0283C@netapp.com>
References: <A0A1021A-64E6-4E0C-89A5-9F719C8E1AFC@netapp.com>
 <20130731213904.GB2668@fieldses.org>
 <75E5568D-320C-45A1-B7E6-23CE73217BAF@netapp.com>
 <20130731234800.GC2668@fieldses.org>
 <0E0FF4CB-4388-417B-9D1C-24940472D844@netapp.com>
 <47D6EDEC-B91A-446F-A227-FDA9D37DB618@netapp.com>
 <20130801145617.GA15123@fieldses.org>
In-Reply-To: <20130801145617.GA15123@fieldses.org>
Content-Type: text/plain; charset="Windows-1252"
MIME-Version: 1.0
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>


On Aug 1, 2013, at 10:56 AM, J. Bruce Fields <bfields@fieldses.org> wrote:

> On Thu, Aug 01, 2013 at 02:09:49PM +0000, Adamson, Dros wrote:
>> 
>> On Aug 1, 2013, at 10:03 AM, "Adamson, Dros" <Weston.Adamson@netapp.com>
>> wrote:
>> 
>>> 
>>> On Jul 31, 2013, at 7:48 PM, J. Bruce Fields <bfields@fieldses.org> wrote:
>>> 
>>>> On Wed, Jul 31, 2013 at 10:22:22PM +0000, Adamson, Dros wrote:
>>>>> 
>>>>> On Jul 31, 2013, at 5:39 PM, "J. Bruce Fields" <bfields@fieldses.org>
>>>>> wrote:
>>>>> 
>>>>>> This should probably be cc'd to the mailing list.
>>>>> 
>>>>> Agreed!
>>>>> 
>>>>>> 
>>>>>> On Wed, Jul 31, 2013 at 09:25:29PM +0000, Adamson, Dros wrote:
>>>>>>> I have a pretty functional client-side SP4_MACH_CRED implementation
>>>>>>> and I'm trying to implement the server side so I can fully test the
>>>>>>> client code. I was testing against another server, but that didn't
>>>>>>> implement any useful set of operations other than the required ones.
>>>>>> 
>>>>>> The latest Linux server implements SP4_MACH_CRED but only for the
>>>>>> required operations.  (But that hasn't really been tested--any testing
>>>>>> even to make sure that basic stuff works would be welcomed.)
>>>>>> 
>>>>> 
>>>>> Right, I'm happy to report that the initial implementation of the required operations seems to work with (at least) one small patch I'll send your way soon.
> 
> (And I think I forgot to say thanks here!  It's useful to have that
> tested.)

I should note it's somewhat useless to use SP4_MACH_CRED in this way from the linux client's perspective. We already use the machine cred with krb5i if possible for state manager ops even in SP4_NONE mode.

> 
>>>>> The problem I'm trying to solve initially with SP4_MACH_CRED is when there are a bunch of buffered writes and the user's credentials expire. Any client side operations initiated after the credentials expire will fail (as expected), but operations that have already been seen as successful still need to be flushed.
>>>>> 
>>>>> Andy is addressing this in a different way by falling back to unbuffered writes and flushing all data right before a cred expires, but this method is better when available - and it's Trond requested.
>>>> 
>>>> I understand the problem it solves, but it is a bit of a change to the
>>>> security model and I just wonder what the right thing is to do by
>>>> default.
>>> 
>>> So you think
> 
> I'm not staking out a position, just trying to understand the tradeoffs:
> 
>> the default behavior should be that buffered writes just hang around
>> forever in the client's buffer cache when a user cred expires?  That
>> seems really wrong to me.
> 
> So once Andy's work is also done, I guess the client can attempt to:
> 	- try to get creds renewed well in advance.

This is still up to the user / distro / config.

> 	- if they aren't, flush everything and start writing
> 	  synchronously.
> 
> But problems could still happen, for example, if:
> 	- an unfortunately timed network outage prevents the above.
> 	  (Then again, MACH_CHRED may not help here if that also means
> 	  the client's state expires?)

Right. Using MACH_CRED has a much better chance of being able to flush the data.

> 	- an unfortunately timed server reboot prevents the above.

Yep, and using the machine creds should help here.

> 	- user credentials go away before they're expected to expire.
> 	  (I wonder how this would typically happen?)

I don't believe this can happen yet.  IIRC a kdestroy isn't noticed by gssd, but this is probably going to change soon with Andy's keyring work, so it'd be nice to plan for it.

> 
> And then the client may be forced to choose between throwing away
> buffered data and allowing users to DOS it by filling memory with data
> it can't write back.

Right, and this leads to data corruption - the application believes it has written bytes to storage that never really made it.

> 
> So the choices are:
> 	1. allow those problems, or
> 	2. change the nfs/krb5 security model from "once you give a
> 	   client your credential, you trust it with your data till the
> 	   credential expires" to "once you give a client your
> 	   credential, you trust it indefinitely".  (Well, until its
> 	   state expires, anyway.)
> 
> And we can implement either 1, or 2, or both, and if we implement both,
> we get to choose which of 1 or 2 is the default.
> 
> So I don't have a strong opinion yet, but I do fear that if we only
> implement #2 there will be users who see that as a serious regression in
> security.

Perhaps you're right - the server is essentially trusting the client machine to do the right thing here, but the server is already trusting the client machine (not users) to do the right thing.  A rouge client implementation could create all types of havoc as it stands now, i.e. using another user's credentials to bypass permissions, etc.

I argue that from a user's perspective, #2 is the right way to go.  If my credentials aren't expired when I write some bytes, and the application is told that the write succeeded, I expect those bytes next time I open the file.

-dros

> 
> --b.
> 
>>> 
>>> If this isn't something you want, I'm not sure that we want any SP4_MACH_CRED support other than the required operations, which is kind of a moot point since we now use krb5i for state manager operations by default (whether in SP4_MACH_CRED or SP4_NONE).
>>> 
>>> The other case we are aiming for with the client is to be able to use the machine cred in recovery when the user's creds expire so that flushing of buffers can happen once recovery is complete. Of course, if you don't want to see the flushing changes, this is useless.
>>> 
>>> So… Is SP4_MACH_CRED support even worth the effort?
>>> 
>>> -dros
>>> 
>>>> 
>>>> --b.
>>>> 
>>>>> 
>>>>>> 
>>>>>> This violates that assumption, so I wonder if it needs to be
>>>>>> configurable, and even off by default.
>>>>>> 
>>>>> 
>>>>> This will fix potential data corruption in a corner case of the way things currently work and doesn't change expected behavior from a user's perspective. 
>>>>> 
>>>>> -dros
>>>>> 
>>>> --
>>>> To unsubscribe from this list: send the line "unsubscribe linux-nfs" in
>>>> the body of a message to majordomo@vger.kernel.org
>>>> More majordomo info at  http://vger.kernel.org/majordomo-info.html
>>> 
>>> --
>>> To unsubscribe from this list: send the line "unsubscribe linux-nfs" in
>>> the body of a message to majordomo@vger.kernel.org
>>> More majordomo info at  http://vger.kernel.org/majordomo-info.html
>> 
> --
> To unsubscribe from this list: send the line "unsubscribe linux-nfs" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html

