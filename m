Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:45774 "EHLO mx1.redhat.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S933360AbcKLPbr (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Sat, 12 Nov 2016 10:31:47 -0500
Received: from int-mx11.intmail.prod.int.phx2.redhat.com (int-mx11.intmail.prod.int.phx2.redhat.com [10.5.11.24])
        (using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
        (No client certificate requested)
        by mx1.redhat.com (Postfix) with ESMTPS id 598FB8F29A
        for <linux-nfs@vger.kernel.org>; Sat, 12 Nov 2016 15:31:46 +0000 (UTC)
From: "Benjamin Coddington" <bcodding@redhat.com>
To: "Jeff Layton" <jlayton@redhat.com>
Cc: "List Linux NFS Mailing" <linux-nfs@vger.kernel.org>
Subject: Re: CLOSE/OPEN race
Date: Sat, 12 Nov 2016 10:31:44 -0500
Message-ID: <B050FA3F-5D9A-4053-BB9E-7668814846B7@redhat.com>
In-Reply-To: <1478955250.2442.16.camel@redhat.com>
References: <9E2B8A0D-7B0E-4AE5-800A-0EF3F7F7F694@redhat.com>
 <1478955250.2442.16.camel@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=utf-8; format=flowed
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On 12 Nov 2016, at 7:54, Jeff Layton wrote:

> On Sat, 2016-11-12 at 06:08 -0500, Benjamin Coddington wrote:
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
>>
>> I think this case could be handled by never updating the open_stateid 
>> if the
>> stateids match but the sequence number of the new state is less than 
>> the
>> current open_state.
>>
>
> What kernel is this on?

On v4.9-rc2 with a couple fixups.  Without them, I can't test long 
enough to
reproduce this race.  I don't think any of those are involved in this
problem, though.

> Yes, that seems wrong. The client should be picking B.2 for the open
> stateid to use. I think that decision of whether to take a seqid is 
> made
> in nfs_need_update_open_stateid. The logic in there looks correct to 
> me
> at first glance though.

nfs_need_update_open_stateid() will return true if NFS_OPEN_STATE is 
unset.
That's the precondition set up by steps 1-6.  Perhaps it should not 
update
the stateid if they match but the sequence number is less, and still set
NFS_OPEN_STATE once more.  That will fix _this_ case.  Are there other 
cases
where that would be a problem?

Ben
