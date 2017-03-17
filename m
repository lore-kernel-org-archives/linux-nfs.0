Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-it0-f46.google.com ([209.85.214.46]:35457 "EHLO
        mail-it0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751096AbdCQVUD (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Fri, 17 Mar 2017 17:20:03 -0400
Received: by mail-it0-f46.google.com with SMTP id m27so36221836iti.0
        for <linux-nfs@vger.kernel.org>; Fri, 17 Mar 2017 14:19:42 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <057b01d29f60$c2645dc0$472d1940$@mindspring.com>
References: <CAN-5tyH433qTV9EY5MQpDhRhgekUv7e=R1H7N_Q_46cAwPO=eg@mail.gmail.com>
 <055901d29f46$4adcb0f0$e09612d0$@mindspring.com> <CAN-5tyFhibO2wCHrw7NZPVqFe1tEh8gprO9ubruQ53iqL4GdyA@mail.gmail.com>
 <057b01d29f60$c2645dc0$472d1940$@mindspring.com>
From: Olga Kornievskaia <aglo@umich.edu>
Date: Fri, 17 Mar 2017 17:19:40 -0400
Message-ID: <CAN-5tyE5e1whg2xnvaWRF1orwvmzJ4nDXFN25Hw-05W7nQ0A_w@mail.gmail.com>
Subject: Re: question about open_owner sequencing
To: Frank Filz <ffilzlnx@mindspring.com>
Cc: NeilBrown <neilb@suse.com>, linux-nfs <linux-nfs@vger.kernel.org>
Content-Type: text/plain; charset=UTF-8
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Fri, Mar 17, 2017 at 4:55 PM, Frank Filz <ffilzlnx@mindspring.com> wrote:
>> On Fri, Mar 17, 2017 at 1:45 PM, Frank Filz <ffilzlnx@mindspring.com> wrote:
>> >  Hi folks,
>> >>
>> >> I have a question about recovery from the BAD_SEQID and what should
>> >> happen.
>> >>
>> >> I have the following application that does:
>> >>
>> >> 1. open(file1)
>> >> 2. open(file2)
>> >> 3. close(file1)
>> >> 4. open(file3)
>> >> 5. lock(file2)
>> >>
>> >> If CLOSE gets BAD_SEQID (for whatever reason), I see that LOCK later
>> >> fails with BAD_SEQID as well.
>> >>
>> >> step1 OPEN creates open_owner1 seq 0
>> >> step2 OPEN uses open_owner1 seq1
>> >> step3 CLOSE uses open_owner1 seq2 gets BAD_SEQID
>> >> step4 OPEN sends new open_owner2 seq2 and it triggers
>> OPEN_CONFIRM
>> >> with seq3
>> >> step5 sends LOCK with seq4 and open stateid from the reply in step 2.
>> >>
>> >> LOCK gets BAD_SEQID.
>> >>
>> >> Question: is client sending something incorrect? is server not
>> >> correct? I tested against two different servers (Linux and NetApp)
>> >> and both reply the same way so I'm leaning towards "no". But I don't
>> >> see why "seq4" is not a valid sequence given that the
>> open_owner/sequence was just confirmed.
>> >
>> > Wait step4 is using a new open owner? Each open owner has its own seqid
>> (assuming this is V4.0, owner seqid doesn't apply to 4.1 since the sequencing
>> is done for the session with the SEQUENCE op).
>>
>> Yes this is v4.0. Yes step4 uses new open owner but seq# doesn't go to 0.
>> This is the new behavior to not drop the open owner as per the following
>> commit (below).
>>
>> Since LOCK just has the seq# (and not a value of the open_owner) I thought
>> it's be the "valid" (current) open owner which would be open_owner2.
>
> Hmm, so in step5, there is not yet a lock stateid?
>
> So it's using this form of the lock?
>
> struct open_to_lock_owner4 {
> seqid4 open_seqid;
> stateid4 open_stateid;
> seqid4 lock_seqid;
> lock_owner4 lock_owner;
>
> If so, open_seqid should be 3, lock_seqid can be anything.

Why is it 3? As far as I can tell, 3 is not a valid seq_id for either
open_owner1 or open_owner2. open_owner1 is left at seq_id=2 (because
after "using" seq2 on the CLOSE it got BAD_SEQID so seq_id isn't
incremented) and open_owner2 would have seq_id=4 (OPEN_CONFIRM used up
3)?
