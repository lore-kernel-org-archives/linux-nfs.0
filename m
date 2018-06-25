Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-io0-f193.google.com ([209.85.223.193]:46779 "EHLO
        mail-io0-f193.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751513AbeFYPjS (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Mon, 25 Jun 2018 11:39:18 -0400
Received: by mail-io0-f193.google.com with SMTP id u23-v6so9255573ioc.13
        for <linux-nfs@vger.kernel.org>; Mon, 25 Jun 2018 08:39:18 -0700 (PDT)
Content-Type: text/plain;
        charset=us-ascii
Mime-Version: 1.0 (Mac OS X Mail 11.4 \(3445.8.2\))
Subject: Re: [PATCH 2/2] nfsd: return ENOSPC if unable to allocate a session
 slot
From: Chuck Lever <chucklever@gmail.com>
In-Reply-To: <d60d8566d215a70d63a31faf8da9ea9126324fa9.camel@hammerspace.com>
Date: Mon, 25 Jun 2018 11:39:15 -0400
Cc: Bruce Fields <bfields@fieldses.org>,
        Linux NFS Mailing List <linux-nfs@vger.kernel.org>,
        "manjunath.b.patil@oracle.com" <manjunath.b.patil@oracle.com>
Message-Id: <1131E2BE-162D-45BB-BC24-49097733ACC3@gmail.com>
References: <1529598933-16506-1-git-send-email-manjunath.b.patil@oracle.com>
 <1529598933-16506-2-git-send-email-manjunath.b.patil@oracle.com>
 <20180622175416.GA7119@fieldses.org>
 <148E65CF-D3D4-4E43-A190-822C5F7824B9@gmail.com>
 <180d25ce5474539f15a84a23258d15c71ec11ad9.camel@hammerspace.com>
 <B3031B82-6CCC-4A11-938F-AD052CC360CD@gmail.com>
 <d60d8566d215a70d63a31faf8da9ea9126324fa9.camel@hammerspace.com>
To: Trond Myklebust <trondmy@hammerspace.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>



> On Jun 24, 2018, at 9:56 AM, Trond Myklebust <trondmy@hammerspace.com> =
wrote:
>=20
> On Sat, 2018-06-23 at 15:00 -0400, Chuck Lever wrote:
>>> On Jun 22, 2018, at 6:31 PM, Trond Myklebust <trondmy@hammerspace.c
>>> om> wrote:
>>>=20
>>> On Fri, 2018-06-22 at 17:49 -0400, Chuck Lever wrote:
>>>> Hi Bruce-
>>>>=20
>>>>=20
>>>>> On Jun 22, 2018, at 1:54 PM, J. Bruce Fields <bfields@fieldses.
>>>>> org>
>>>>> wrote:
>>>>>=20
>>>>> On Thu, Jun 21, 2018 at 04:35:33PM +0000, Manjunath Patil
>>>>> wrote:
>>>>>> Presently nfserr_jukebox is being returned by nfsd for
>>>>>> create_session
>>>>>> request if server is unable to allocate a session slot. This
>>>>>> may
>>>>>> be
>>>>>> treated as NFS4ERR_DELAY by the clients and which may
>>>>>> continue to
>>>>>> re-try
>>>>>> create_session in loop leading NFSv4.1+ mounts in hung state.
>>>>>> nfsd
>>>>>> should return nfserr_nospc in this case as per
>>>>>> rfc5661(section-
>>>>>> 18.36.4
>>>>>> subpoint 4. Session creation).
>>>>>=20
>>>>> I don't think the spec actually gives us an error that we can
>>>>> use
>>>>> to say
>>>>> a CREATE_SESSION failed permanently for lack of resources.
>>>>=20
>>>> The current situation is that the server replies NFS4ERR_DELAY,
>>>> and the client retries indefinitely. The goal is to let the
>>>> client choose whether it wants to try the CREATE_SESSION again,
>>>> try a different NFS version, or fail the mount request.
>>>>=20
>>>> Bill and I both looked at this section of RFC 5661. It seems to
>>>> us that the use of NFS4ERR_NOSPC is appropriate and unambiguous
>>>> in this situation, and it is an allowed status for the
>>>> CREATE_SESSION operation. NFS4ERR_DELAY OTOH is not helpful.
>>>=20
>>> There are a range of errors which we may need to handle by
>>> destroying
>>> the session, and then creating a new one (mainly the ones where the
>>> client and server slot handling get out of sync). That's why
>>> returning
>>> NFS4ERR_NOSPC in response to CREATE_SESSION is unhelpful, and is
>>> why
>>> the only sane response by the client will be to treat it as a
>>> temporary
>>> error.
>>> IOW: these patches will not be acceptable, even with a rewrite, as
>>> they
>>> are based on a flawed assumption.
>>=20
>> Fair enough. We're not attached to any particular solution/fix.
>>=20
>> So let's take "recovery of an active mount" out of the picture
>> for a moment.
>>=20
>> The narrow problem is behavioral: during initial contact with an
>> unfamiliar server, the server can hold off a client indefinitely
>> by sending NFS4ERR_DELAY for example until another client unmounts.
>> We want to find a way to allow clients to make progress when a
>> server is short of resources.
>>=20
>> It appears that the mount(2) system call does not return as long
>> as the server is still returning NFS4ERR_DELAY. Possibly user
>> space is never given an opportunity to stop retrying, and thus
>> mount.nfs gets stuck.
>>=20
>> It appears that DELAY is OK for EXCHANGE_ID too. So if a server
>> decides to return DELAY to EXCHANGE_ID, I wonder if our client's
>> trunking detection would be hamstrung by one bad server...
>=20
> The 'mount' program has the 'retry' option in order to set a timeout
> for the mount operation itself. Is that option not working correctly?

Manjunath will need to confirm that, but my understanding is that
mount.nfs is not regaining control when the server returns DELAY
to CREATE_SESSION. My conclusion was that mount(2) is not returning.


> If so, we should definitely fix that.

My recollection is that mount.nfs polls, it does not set a timer
signal. So it will call mount(2) repeatedly until either "retry"
minutes has passed, or mount(2) succeeds. I don't think it will
deal with mount(2) not returning, but I could be wrong about that.

My preference would be to make the kernel more reliable (ie mount(2)
fails immediately in this case). That gives mount.nfs some time to
try other things (like, try the original mount again after a few
moments, or fall back to NFSv4.0, or fail).

We don't want mount.nfs to wait for the full retry=3D while doing
nothing else. That would make this particular failure mode behave
differently than all the other modes we have had, historically, IIUC.

Also, I agree with Bruce that the server should make CREATE_SESSION
less likely to fail. That would also benefit state recovery.


> We might also want to look into making it take values < 1 minute. That
> could be accomplished either by extending the syntax of the 'retry'
> option (e.g.: 'retry=3D<minutes>:<seconds>') or by adding a new option
> (e.g. 'sretry=3D<seconds>').
>=20
> It would then be up to the caller of mount to decide the policy of =
what
> to do after a timeout.

I agree that the caller of mount(2) should be allowed to provide the
policy.


> Renegotiation downward to NFSv3 might be an
> option, but it's not something that most people want to do in the case
> where there are lots of clients competing for resources since that's
> precisely the regime where the NFSv3 DRC scheme breaks down (lots of
> disconnections, combined with a high turnover of DRC slots).

--
Chuck Lever
chucklever@gmail.com



