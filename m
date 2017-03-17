Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from elasmtp-spurfowl.atl.sa.earthlink.net ([209.86.89.66]:58851
        "EHLO elasmtp-spurfowl.atl.sa.earthlink.net" rhost-flags-OK-OK-OK-OK)
        by vger.kernel.org with ESMTP id S1751306AbdCQVjz (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Fri, 17 Mar 2017 17:39:55 -0400
From: "Frank Filz" <ffilzlnx@mindspring.com>
To: "'Olga Kornievskaia'" <aglo@umich.edu>
Cc: "'NeilBrown'" <neilb@suse.com>,
        "'linux-nfs'" <linux-nfs@vger.kernel.org>
References: <CAN-5tyH433qTV9EY5MQpDhRhgekUv7e=R1H7N_Q_46cAwPO=eg@mail.gmail.com> <055901d29f46$4adcb0f0$e09612d0$@mindspring.com> <CAN-5tyFhibO2wCHrw7NZPVqFe1tEh8gprO9ubruQ53iqL4GdyA@mail.gmail.com> <057b01d29f60$c2645dc0$472d1940$@mindspring.com> <CAN-5tyE5e1whg2xnvaWRF1orwvmzJ4nDXFN25Hw-05W7nQ0A_w@mail.gmail.com>
In-Reply-To: <CAN-5tyE5e1whg2xnvaWRF1orwvmzJ4nDXFN25Hw-05W7nQ0A_w@mail.gmail.com>
Subject: RE: question about open_owner sequencing
Date: Fri, 17 Mar 2017 14:39:30 -0700
Message-ID: <058001d29f66$f6970a60$e3c51f20$@mindspring.com>
MIME-Version: 1.0
Content-Type: text/plain;
        charset="UTF-8"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

> On Fri, Mar 17, 2017 at 4:55 PM, Frank Filz <ffilzlnx@mindspring.com> wrote:
> >> On Fri, Mar 17, 2017 at 1:45 PM, Frank Filz <ffilzlnx@mindspring.com>
> wrote:
> >> >  Hi folks,
> >> >>
> >> >> I have a question about recovery from the BAD_SEQID and what
> >> >> should happen.
> >> >>
> >> >> I have the following application that does:
> >> >>
> >> >> 1. open(file1)
> >> >> 2. open(file2)
> >> >> 3. close(file1)
> >> >> 4. open(file3)
> >> >> 5. lock(file2)
> >> >>
> >> >> If CLOSE gets BAD_SEQID (for whatever reason), I see that LOCK
> >> >> later fails with BAD_SEQID as well.
> >> >>
> >> >> step1 OPEN creates open_owner1 seq 0
> >> >> step2 OPEN uses open_owner1 seq1
> >> >> step3 CLOSE uses open_owner1 seq2 gets BAD_SEQID
> >> >> step4 OPEN sends new open_owner2 seq2 and it triggers
> >> OPEN_CONFIRM
> >> >> with seq3
> >> >> step5 sends LOCK with seq4 and open stateid from the reply in step 2.
> >> >>
> >> >> LOCK gets BAD_SEQID.
> >> >>
> >> >> Question: is client sending something incorrect? is server not
> >> >> correct? I tested against two different servers (Linux and NetApp)
> >> >> and both reply the same way so I'm leaning towards "no". But I
> >> >> don't see why "seq4" is not a valid sequence given that the
> >> open_owner/sequence was just confirmed.
> >> >
> >> > Wait step4 is using a new open owner? Each open owner has its own
> >> > seqid
> >> (assuming this is V4.0, owner seqid doesn't apply to 4.1 since the
> >> sequencing is done for the session with the SEQUENCE op).
> >>
> >> Yes this is v4.0. Yes step4 uses new open owner but seq# doesn't go to 0.
> >> This is the new behavior to not drop the open owner as per the
> >> following commit (below).
> >>
> >> Since LOCK just has the seq# (and not a value of the open_owner) I
> >> thought it's be the "valid" (current) open owner which would be
> open_owner2.
> >
> > Hmm, so in step5, there is not yet a lock stateid?
> >
> > So it's using this form of the lock?
> >
> > struct open_to_lock_owner4 {
> > seqid4 open_seqid;
> > stateid4 open_stateid;
> > seqid4 lock_seqid;
> > lock_owner4 lock_owner;
> >
> > If so, open_seqid should be 3, lock_seqid can be anything.
> 
> Why is it 3? As far as I can tell, 3 is not a valid seq_id for either
> open_owner1 or open_owner2. open_owner1 is left at seq_id=2 (because
> after "using" seq2 on the CLOSE it got BAD_SEQID so seq_id isn't
> incremented) and open_owner2 would have seq_id=4 (OPEN_CONFIRM
> used up 3)?
> 
> From 7530 section 16.10.5:
> 
> Note that
>       although the open-owner is not given explicitly, the open_seqid
>       associated with it is used to check for open-owner sequencing
>       issues. This case provides a method to use the established state
>       of the open_stateid to transition to the use of a lock stateid.

I'd love to understand what caused the BAD_SEQID, because I thought the close SHOULD use seqid 2

Hmm, if the stateid really is still valid, the lock should use open_seqid 1, the lock doesn't change the state of the open. I think... darn, this stuff is confusing...

I know I bumbled through some of this with Ganesha. To the extent that has pynfs tests for seqid, Ganesha does what pynfs expects...

Use 4.1 :-)

Frank


---
This email has been checked for viruses by Avast antivirus software.
https://www.avast.com/antivirus

