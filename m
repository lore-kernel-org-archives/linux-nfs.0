Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:41092 "EHLO mx1.redhat.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S937178AbdJQRwC (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Tue, 17 Oct 2017 13:52:02 -0400
From: "Benjamin Coddington" <bcodding@redhat.com>
To: "Trond Myklebust" <trondmy@primarydata.com>
Cc: "anna.schumaker@netapp.com" <anna.schumaker@netapp.com>,
        "linux-nfs@vger.kernel.org" <linux-nfs@vger.kernel.org>
Subject: Re: [PATCH 3/3] NFSv4.1: Detect and retry after OPEN and
 CLOSE/DOWNGRADE race
Date: Tue, 17 Oct 2017 13:52:01 -0400
Message-ID: <62F4199A-60AB-4CC1-990F-8BA1BCC39482@redhat.com>
In-Reply-To: <1508262139.6260.7.camel@primarydata.com>
References: <cover.1508248965.git.bcodding@redhat.com>
 <fb76d86caca02c277eea7cb1d469c209b59d06ab.1508248965.git.bcodding@redhat.com>
 <1508255361.3718.17.camel@primarydata.com>
 <8384C212-F32B-4F5A-B522-A8F08108DA58@redhat.com>
 <1508262139.6260.7.camel@primarydata.com>
MIME-Version: 1.0
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On 17 Oct 2017, at 13:42, Trond Myklebust wrote:

> On Tue, 2017-10-17 at 13:33 -0400, Benjamin Coddington wrote:
>> On 17 Oct 2017, at 11:49, Trond Myklebust wrote:
>>
>>> On Tue, 2017-10-17 at 10:46 -0400, Benjamin Coddington wrote:
>>>> If the client issues two simultaneous OPEN calls, and the
>>>> response to
>>>> the
>>>> first OPEN call (sequence id 1) is delayed before updating the
>>>> nfs4_state,
>>>> then the client's nfs4_state can transition through a complete
>>>> lifecycle of
>>>> OPEN (state sequence id 2), and CLOSE (state sequence id
>>>> 3).  When
>>>> the
>>>> first OPEN is finally processed, the nfs4_state is incorrectly
>>>> transitioned
>>>> back to NFS_OPEN_STATE for the first OPEN (sequence id
>>>> 1).  Subsequent calls
>>>> to LOCK or CLOSE will receive NFS4ERR_BAD_STATEID, and trigger
>>>> state
>>>> recovery.
>>>>
>>>> Fix this by passing back the result of need_update_open_stateid()
>>>> to
>>>> the
>>>> open() path, with the result to try again if the OPEN's stateid
>>>> should not
>>>> be updated.
>>>>
>>>
>>> Why are we worried about the special case where the client actually
>>> finds the closed stateid in its cache?
>>
>> Because I am hitting that case very frequently in generic/089, and I
>> hate
>> how unnecessary state recovery slows everything down.  I'm also
>
> Why is it being hit. Is the client processing stuff out of order?

Yes.

>>> In the more general case of your race, the stateid might not be
>>> found
>>> at all because the CLOSE completes and is processed on the client
>>> before it can process the reply from the delayed OPEN. If so, we
>>> really
>>> have no way to detect that the file has actually been closed by the
>>> server until we see the NFS4ERR_BAD_STATEID.
>>
>> I mentioned this case in the cover letter.  It's possible that the
>> client
>> could retain a record of a closed stateid in order to retry an OPEN
>> in that
>
> That would require us to retain all stateids until there are no more
> pending OPEN calls.
>
>> case.  Another approach may be to detect 'holes' in the state id
>> sequence
>> and not call CLOSE until each id is processed.  I think there's an
>> existing
>
> We can't know we have a hole until we know the starting value of the
> seqid, which is undefined according to RFC 5661 section 3.3.12.

Ah, yuck.  I read 8.2.2:

   When such a set of locks is first created, the server returns a
   stateid with seqid value of one.

.. and went from there.  Is this a conflict in the spec?

Ben
