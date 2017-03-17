Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-it0-f45.google.com ([209.85.214.45]:35766 "EHLO
        mail-it0-f45.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751079AbdCQUfi (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Fri, 17 Mar 2017 16:35:38 -0400
Received: by mail-it0-f45.google.com with SMTP id m27so35165166iti.0
        for <linux-nfs@vger.kernel.org>; Fri, 17 Mar 2017 13:35:37 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <055901d29f46$4adcb0f0$e09612d0$@mindspring.com>
References: <CAN-5tyH433qTV9EY5MQpDhRhgekUv7e=R1H7N_Q_46cAwPO=eg@mail.gmail.com>
 <055901d29f46$4adcb0f0$e09612d0$@mindspring.com>
From: Olga Kornievskaia <aglo@umich.edu>
Date: Fri, 17 Mar 2017 16:35:36 -0400
Message-ID: <CAN-5tyFhibO2wCHrw7NZPVqFe1tEh8gprO9ubruQ53iqL4GdyA@mail.gmail.com>
Subject: Re: question about open_owner sequencing
To: Frank Filz <ffilzlnx@mindspring.com>, NeilBrown <neilb@suse.com>
Cc: linux-nfs <linux-nfs@vger.kernel.org>
Content-Type: text/plain; charset=UTF-8
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Fri, Mar 17, 2017 at 1:45 PM, Frank Filz <ffilzlnx@mindspring.com> wrote:
>  Hi folks,
>>
>> I have a question about recovery from the BAD_SEQID and what should
>> happen.
>>
>> I have the following application that does:
>>
>> 1. open(file1)
>> 2. open(file2)
>> 3. close(file1)
>> 4. open(file3)
>> 5. lock(file2)
>>
>> If CLOSE gets BAD_SEQID (for whatever reason), I see that LOCK later fails
>> with BAD_SEQID as well.
>>
>> step1 OPEN creates open_owner1 seq 0
>> step2 OPEN uses open_owner1 seq1
>> step3 CLOSE uses open_owner1 seq2 gets BAD_SEQID
>> step4 OPEN sends new open_owner2 seq2 and it triggers OPEN_CONFIRM
>> with seq3
>> step5 sends LOCK with seq4 and open stateid from the reply in step 2.
>>
>> LOCK gets BAD_SEQID.
>>
>> Question: is client sending something incorrect? is server not correct? I
>> tested against two different servers (Linux and NetApp) and both reply the
>> same way so I'm leaning towards "no". But I don't see why "seq4" is not a
>> valid sequence given that the open_owner/sequence was just confirmed.
>
> Wait step4 is using a new open owner? Each open owner has its own seqid (assuming this is V4.0, owner seqid doesn't apply to 4.1 since the sequencing is done for the session with the SEQUENCE op).

Yes this is v4.0. Yes step4 uses new open owner but seq# doesn't go to
0. This is the new behavior to not drop the open owner as per the
following commit (below).

Since LOCK just has the seq# (and not a value of the open_owner) I
thought it's be the "valid" (current) open owner which would be
open_owner2.

So after step4, are the 2 open owners then: one with value open_owner1
(seq2) and one with value open_owner2 (seq3). And then since LOCK is
associated with the OPEN from step1 and then open_owner 1, then should
it send send seq2?

Neil, when would the client remove this open owner1  that would have
been removed prior to this patch?

commit 86cfb0418537460baf0de0b5e9253784be27a6f9
Author: NeilBrown <neilb@suse.com>
Date:   Mon Dec 19 11:48:23 2016 +1100

    NFS: Don't disconnect open-owner on NFS4ERR_BAD_SEQID

    When an NFS4ERR_BAD_SEQID is received the open-owner is removed from
    the ->state_owners rbtree so that it will no longer be used.

    If any stateids attached to this open-owner are still in use, and if a
    request using one gets an NFS4ERR_BAD_STATEID reply, this can for bad.

    The state is marked as needing recovery and the nfs4_state_manager()
    is scheduled to clean up.  nfs4_state_manager() finds states to be
    recovered by walking the state_owners rbtree.  As the open-owner is
    not in the rbtree, the bad state is not found so nfs4_state_manager()
    completes having done nothing.  The request is then retried, with a
    predicatable result (indefinite retries).

    If the stateid is for a delegation, this open_owner will be used
    to open files when the delegation is returned.  For that to work,
    a new open-owner needs to be presented to the server.

    This patch changes NFS4ERR_BAD_SEQID handling to leave the open-owner
    in the rbtree but updates the 'create_time' so it looks like a new
    open-owner.  With this the indefinite retries no longer happen.

    Signed-off-by: NeilBrown <neilb@suse.com>
    Signed-off-by: Trond Myklebust <trond.myklebust@primarydata.com>


>
> Frank
>
>
> ---
> This email has been checked for viruses by Avast antivirus software.
> https://www.avast.com/antivirus
>
