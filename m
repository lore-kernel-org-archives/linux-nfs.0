Return-Path: linux-nfs-owner@vger.kernel.org
Received: from aserp1040.oracle.com ([141.146.126.69]:32573 "EHLO
	aserp1040.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756298Ab3KHPq7 convert rfc822-to-8bit (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Fri, 8 Nov 2013 10:46:59 -0500
Content-Type: text/plain; charset=US-ASCII
Mime-Version: 1.0 (Mac OS X Mail 6.6 \(1510\))
Subject: Re: [PATCH] Adding the nfs4_use_min_auth module parameter
From: Chuck Lever <chuck.lever@oracle.com>
In-Reply-To: <527CDBFC.3070903@RedHat.com>
Date: Fri, 8 Nov 2013 07:46:54 -0800
Cc: Trond Myklebust <Trond.Myklebust@netapp.com>,
        Linux NFS Mailing list <linux-nfs@vger.kernel.org>
Message-Id: <A0F58102-E1A4-4C6B-81EF-91BC31E6A43C@oracle.com>
References: <1383851364-8370-1-git-send-email-steved@redhat.com> <A8E8F2C4-8CB7-434E-8520-B2B53F0582D9@oracle.com> <527C07B4.800@RedHat.com> <44CA89EA-8B5E-4B83-A622-78A78F760FF1@oracle.com> <527CDBFC.3070903@RedHat.com>
To: Steve Dickson <SteveD@redhat.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>


On Nov 8, 2013, at 4:41 AM, Steve Dickson <SteveD@redhat.com> wrote:

> 
> 
> On 07/11/13 18:05, Chuck Lever wrote:
>> 
>> On Nov 7, 2013, at 1:35 PM, Steve Dickson <SteveD@redhat.com> wrote:
>> 
>>> Hey mrchuck... 
>>> 
>>> On 07/11/13 14:25, Chuck Lever wrote:
>>>> Hi Steve-
>>>> 
>>>> On Nov 7, 2013, at 11:09 AM, Steve Dickson <steved@redhat.com> wrote:
>>>> 
>>>>> This new module parameter makes the v4 client
>>>>> use the minimal authentication flavor (AUTH_UNIX)
>>>>> when establishing NFSV4 state and doing the
>>>>> pseudoroot lookup
>>>> 
>>>> The patch description doesn't say, but is this change to work 
>>>> around the 15 second GSSD upcall timeout? 
>>> Yes. A 15 second delay on every mount due to security that
>>> nobody is requesting is just not good.. IMHO..
>> 
>> One thing we haven't discussed is reducing the upcall timeout to 5 seconds or less, 
>> as a form of immediate relief.  15 seconds is arbitrary, and is onerous even when 
>> you expect the mount to work (ie why would it be good for any properly configured 
>> environment to take 15 seconds to establish a GSS context?).
>> 
>> In other words, there are still cases where users wait 15 seconds unnecessarily, 
>> and not because of the use of krb5i for lease management.  Aren't those of concern?
> No. I think the concern here, at least my concern, is the lack of management.
> We are forcing admins to use krb5i in lease management when its not necessary
> and there is no way to turn it off.

Before, we were "forcing" admins to use AUTH_SYS on some mounts even though they had chosen to use sec=krb5 on some mounts.  How is that a good thing?

Now, we are "forcing" admins to use security, but only when it is available.  In other words, our default now is to be more secure rather than insecure.  Why is that a bad thing?

The IETF has now reached consensus to require security in every new protocol it specifies.  They want to enable security and not give ways to turn it off.  They are even considering re-specifying existing widely deployed protocols to increase their security.

"it's not necessary" is no longer an excuse not to use security.  Read the minutes of Wednesday's IAB technical plenary if you doubt me (yes, someone actually said that during the open mic, and there was some applause).

Earlier Trond noted that NFSv4 REQUIRES implementations to support RPCSEC GSS.  That requirement has been there since RFC 3010.  There is a reason for that.

The only reason you are arguing to disable security here is because it is a mild annoyance.  And instead of addressing the annoyance, you want to allow users to disable security.

I'd like a solution that chooses to use security when its available, rather than blindly sticking with an insecure default.  I'd like a solution that makes that choice automatically without adding yet another obscure setting to our panoply of obscure settings.  It should "just work."

We are "this close" to getting that.  Let's not take a step backwards.

--
Chuck Lever
chuck[dot]lever[at]oracle[dot]com



