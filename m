Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:52686 "EHLO mx1.redhat.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S966565AbcKLSrC (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Sat, 12 Nov 2016 13:47:02 -0500
From: "Benjamin Coddington" <bcodding@redhat.com>
To: "Trond Myklebust" <trondmy@primarydata.com>
Cc: "Linux List" <linux-nfs@vger.kernel.org>
Subject: Re: CLOSE/OPEN race
Date: Sat, 12 Nov 2016 13:46:59 -0500
Message-ID: <F1C31BD6-78C8-4D7B-8C9C-42083CCC176A@redhat.com>
In-Reply-To: <C70DF662-8158-4842-9A52-5E1BE42C7FD5@primarydata.com>
References: <9E2B8A0D-7B0E-4AE5-800A-0EF3F7F7F694@redhat.com>
 <C70DF662-8158-4842-9A52-5E1BE42C7FD5@primarydata.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=utf-8; format=flowed
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On 12 Nov 2016, at 13:16, Trond Myklebust wrote:

>
>> On Nov 12, 2016, at 06:08, Benjamin Coddington <bcodding@redhat.com> 
>> wrote:
>>
>> I've been seeing the following on a modified version of generic/089
>> that gets the client stuck sending LOCK with NFS4ERR_OLD_STATEID.
>>
>> 1. Client has open stateid A, sends a CLOSE
>> 2. Client sends OPEN with same owner
>> 3. Client sends another OPEN with same owner
>> 4. Client gets a reply to OPEN in 3, stateid is B.2 (stateid B 
>> sequence 2)
>> 5. Client does LOCK,LOCKU,FREE_STATEID from B.2
>> 6. Client gets a reply to CLOSE in 1
>> 7. Client gets reply to OPEN in 2, stateid is B.1
>> 8. Client sends LOCK with B.1 - OLD_STATEID, now stuck in a loop
>>
>> The CLOSE response in 6 causes us to clear NFS_OPEN_STATE, so that 
>> the OPEN
>> response in 7 is able to update the open_stateid even though it has a 
>> lower
>> sequence number.
>
> Hmm… We probably should not do that if the stateid.other field of A 
> (i.e.
> the one supplied as the argument to CLOSE) does not match the
> stateid.other of B.  In fact, the reply in (4), where the stateid 
> changes
> to B, should be the thing that resets the OPEN state.

At 4, by reset the OPEN state, do you mean we should expect and wait for 
a
pending close to complete, or we should start over with a brand new 
state?
Maybe something else..

The reason the NFS_OPEN_STATE flag is cleared in 6 is that all the state
counts (n_rdwr, n_rdonly, n_wronly) are zero.   There could be a 
"pending
open" flag or counter that would help 6 not clear NFS_OPEN_STATE..
