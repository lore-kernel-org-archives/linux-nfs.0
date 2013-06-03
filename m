Return-Path: linux-nfs-owner@vger.kernel.org
Received: from userp1040.oracle.com ([156.151.31.81]:32068 "EHLO
	userp1040.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750728Ab3FCEcx convert rfc822-to-8bit (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 3 Jun 2013 00:32:53 -0400
Content-Type: text/plain; charset=us-ascii
Mime-Version: 1.0 (Mac OS X Mail 6.3 \(1503\))
Subject: Re: [PATCH 0/3] Various gssd fixes including machine-credential issue.
From: Chuck Lever <chuck.lever@oracle.com>
In-Reply-To: <20130603130101.4acfe706@notabene.brown>
Date: Mon, 3 Jun 2013 00:32:54 -0400
Cc: Steve Dickson <SteveD@redhat.com>, linux-nfs@vger.kernel.org
Message-Id: <C4A2C0D1-8900-45AC-90F6-9629E3F71730@oracle.com>
References: <20130603005219.20080.1927.stgit@notabene.brown> <A2E2CEA9-4F2B-4A3F-8661-36D1E6288B0F@oracle.com> <20130603122319.47f4e0dd@notabene.brown> <0016A272-E433-4020-91FE-45A5EE494296@oracle.com> <20130603130101.4acfe706@notabene.brown>
To: NeilBrown <neilb@suse.de>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>


On Jun 2, 2013, at 11:01 PM, NeilBrown <neilb@suse.de> wrote:

> On Sun, 2 Jun 2013 22:45:16 -0400 Chuck Lever <chuck.lever@oracle.com> wrote:
> 
>> 
>> On Jun 2, 2013, at 10:23 PM, NeilBrown <neilb@suse.de> wrote:
>> 
>>> On Sun, 2 Jun 2013 22:01:50 -0400 Chuck Lever <chuck.lever@oracle.com> wrote:
>>> 
>>>> 
>>>> On Jun 2, 2013, at 9:00 PM, Neil Brown <neilb@suse.de> wrote:
>>>> 
>>>>> As you probably know, since 3.7 (I think) Linux NFS has explicitly
>>>>> asked for machine credentials for certain requests rather than asking
>>>>> for root credentials as is previously did.
>>>>> This causes a regression for people who don't have any machine
>>>>> credentials configured and use "gssd -n".
>>>>> 
>>>>> I gather this was discussed on the mailing list earlier this year but
>>>>> not resolved.
>>>> 
>>>> It's resolved in 3.10-rc.
>>>> 
>>>> The kernel will attempt to use krb5i for lease management operations.  If that fails because there is no keytab available, it falls back to using AUTH_SYS.
>>> 
>>> And if the server refuses to accept AUTH_SYS?
>>> 
>>> I guess this is commit 79d852bf5e7691dc7 ??
>> 
>> That's one of the subsequent bug fixes.  The initial change is commit 4edaa308.
>> 
>>> It seems to say that the server should always accept AUTH_SYS ... is that right?
>> 
>> If we ever find a server implementation that does not support either Kerberos or AUTH_SYS, we can add another step to the negotiation.
>> 
>> So far, despite RFC 3530 not requiring AUTH_SYS support on NFSv4 servers, I haven't found an implementation that does not support AUTH_SYS.  We have found one (FreeBSD) that does not support AUTH_NONE.  We do know that some servers allow administrators to control what security flavors are allowed for lease management.
>> 
>>> That commit isn't tagged for -stable.
>>> So do we still need to make it work for 3.7,3.8,3.9 users?
>> 
>> There are several commits that would need to be back-ported, starting with commit 4edaa308.  I am not certain they would apply cleanly to 3.[789], but a backport should not be difficult.
>> 
>> This change also requires that now gssd must be running on the client.  Otherwise without gssd a sec=sys mount hangs for a bit waiting for the upcall to time out (since the client will attempt to use krb5i for lease management operations).  Trond and Bruce have been discussing a change to address that.
> 
> Thanks for the explanation.  That all looks rather painful to back-port
> though, especially as some of it isn't even written yet :-)
> I think I'll stick with my "-N" option for openSUSE for now.
> 
> Do you think that supporting -N (or similar) so that the admin can ask for
> root credentials to be used for SETCLIENTID requests is reasonable? i.e. what
> do you think of my patch going in to nfs-utils anyway?

So, let me confirm my understanding of your proposed changes: a user logs in as root, then kinit's with her own user principal.  That establishes a Kerberos credential for root to use, and "-N" makes gssd return this credential when the kernel requests "service=*".

Lease management is shared among all NFS users on a client.  In particular, machine credentials give us two important features that cannot be matched by user credentials:

  o  Machine credentials never expire even when users log out.  On a
     multi-user client, you don't want credential expiry or a user
     logout to cause lease management to stop working for other users. 

  o  Machine credentials are always the same no matter who is logged
     in.  The client has to use the same credential every time for
     lease management, or else servers return CLID_INUSE and prevent a
     fresh lease from being established (at least until the existing
     lease for that clientid expires on the server).

Using root's credentials for lease management makes it likely one of these two bullets will end up in your foot.  Specifically for the use case where one user is always using the same client (say, a student's laptop), "-N" might work fine.  For other use cases, like a shared build machine that doesn't have a keytab, "-N" would not work reliably.

With 3.10, if we can't use a Kerberos host principal for lease management, we'll use a less secure equivalent.  The point of backing off the security flavor for lease management is that AUTH_SYS with UID 0, or even AUTH_NONE, are essentially machine credentials.  They don't expire, and the client will present a consistent credential for lease management, no matter what user logs in or leaves the machine.

So, yes, machine credentials are a pain in the ass, and have been for years.  I'm sorry this took 3 kernel releases to figure out, but I'm hoping that the path we're on with these kernel changes is towards more transparent support for a wider array of use cases.  NFSv4.1 also offers some relief in this area (see SP4_MACH_CRED, which I think we do not support quite yet).

--
Chuck Lever
chuck[dot]lever[at]oracle[dot]com



