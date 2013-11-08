Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx1.redhat.com ([209.132.183.28]:5648 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1757548Ab3KHVYx (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Fri, 8 Nov 2013 16:24:53 -0500
Message-ID: <527D56DD.6080009@RedHat.com>
Date: Fri, 08 Nov 2013 16:25:49 -0500
From: Steve Dickson <SteveD@redhat.com>
MIME-Version: 1.0
To: Chuck Lever <chuck.lever@oracle.com>
CC: Trond Myklebust <Trond.Myklebust@netapp.com>,
        Linux NFS Mailing list <linux-nfs@vger.kernel.org>
Subject: Re: [PATCH] Adding the nfs4_use_min_auth module parameter
References: <1383851364-8370-1-git-send-email-steved@redhat.com> <A8E8F2C4-8CB7-434E-8520-B2B53F0582D9@oracle.com> <527C07B4.800@RedHat.com> <44CA89EA-8B5E-4B83-A622-78A78F760FF1@oracle.com> <527CDBFC.3070903@RedHat.com> <A0F58102-E1A4-4C6B-81EF-91BC31E6A43C@oracle.com>
In-Reply-To: <A0F58102-E1A4-4C6B-81EF-91BC31E6A43C@oracle.com>
Content-Type: text/plain; charset=ISO-8859-1
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Hey,

On 08/11/13 10:46, Chuck Lever wrote:
> 
> On Nov 8, 2013, at 4:41 AM, Steve Dickson <SteveD@redhat.com> wrote:
> 
>>
>>
>> On 07/11/13 18:05, Chuck Lever wrote:
>>>
>>> On Nov 7, 2013, at 1:35 PM, Steve Dickson <SteveD@redhat.com> wrote:
>>>
>>>> Hey mrchuck... 
>>>>
>>>> On 07/11/13 14:25, Chuck Lever wrote:
>>>>> Hi Steve-
>>>>>
>>>>> On Nov 7, 2013, at 11:09 AM, Steve Dickson <steved@redhat.com> wrote:
>>>>>
>>>>>> This new module parameter makes the v4 client
>>>>>> use the minimal authentication flavor (AUTH_UNIX)
>>>>>> when establishing NFSV4 state and doing the
>>>>>> pseudoroot lookup
>>>>>
>>>>> The patch description doesn't say, but is this change to work 
>>>>> around the 15 second GSSD upcall timeout? 
>>>> Yes. A 15 second delay on every mount due to security that
>>>> nobody is requesting is just not good.. IMHO..
>>>
>>> One thing we haven't discussed is reducing the upcall timeout to 5 seconds or less, 
>>> as a form of immediate relief.  15 seconds is arbitrary, and is onerous even when 
>>> you expect the mount to work (ie why would it be good for any properly configured 
>>> environment to take 15 seconds to establish a GSS context?).
>>>
>>> In other words, there are still cases where users wait 15 seconds unnecessarily, 
>>> and not because of the use of krb5i for lease management.  Aren't those of concern?
>> No. I think the concern here, at least my concern, is the lack of management.
>> We are forcing admins to use krb5i in lease management when its not necessary
>> and there is no way to turn it off.
> 
> Before, we were "forcing" admins to use AUTH_SYS on some mounts even 
> though they had chosen to use sec=krb5 on some mounts.  How is that a good thing?
It was not, but it was a small window of where AUTH_SYS was used then
krb5* took over... I think that was better than a 15 sec delay.

> 
> Now, we are "forcing" admins to use security, but only when it is available.  
> In other words, our default now is to be more secure rather than insecure.  Why is that a bad thing?
Again its not... But if the technology is not there to make it a
seamless transition then we should wait until the transition is  seamless 
before we force things on admins... IMHO..
 
> 
> The IETF has now reached consensus to require security in every new 
> protocol it specifies.  They want to enable security and not give ways to turn it off.
> They are even considering re-specifying existing widely deployed protocols to increase 
> their security.
I'll refer to my previous comments... When it becomes seamless... its good to go... 

Remember when SELinux first came out? How it caused everything to fail, especially
on the server side? The first they did was to give us a way to turn in off. How
many times did you use setenforce 0 ? ;-) Heck, I think I'm the reason they
came up with that command! 8-) 
 
> 
> "it's not necessary" is no longer an excuse not to use security. Read the minutes of
> Wednesday's IAB technical plenary if you doubt me (yes, someone actually said that during t
> he open mic, and there was some applause).
Dictating or taking away choice on how people can configure their environment 
is not a good thing IMHO... One size security does not fit all...
 
> 
> Earlier Trond noted that NFSv4 REQUIRES implementations to support RPCSEC GSS.  That 
> requirement has been there since RFC 3010.  There is a reason for that.
Yes it is a requirement, which was a good thing, but admins had a *choice* 
on whether they wanted to use it... I disagree with taking that choice away.

> 
> The only reason you are arguing to disable security here is because it is a mild annoyance.
Mild? You are saying a 15 second delay on every mount is mild? :-) Boy I would
hate to see you though disruptive was... ;-)

> And instead of addressing the annoyance, you want to allow users to disable security.
Yes, I want to give admins the same choice they the have always had.. On or off.
and that is bad? 

> 
> I'd like a solution that chooses to use security when its available, rather than 
> blindly sticking with an insecure default.  I'd like a solution that makes that choice 
> automatically without adding yet another obscure setting to our panoply of obscure settings.
> It should "just work."
If it did "just work" fine.. but it does not. Why not give a bridge to people until 
we get things to "just work"?

> 
> We are "this close" to getting that.  Let's not take a step backwards.
But we are not there yet... So sometimes you have to take one step backwards to 
take two step forwards as the old saying goes... 

steved.

