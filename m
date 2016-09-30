Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:45736 "EHLO mx1.redhat.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S932348AbcI3SaQ (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Fri, 30 Sep 2016 14:30:16 -0400
From: "Benjamin Coddington" <bcodding@redhat.com>
To: "Jeff Layton" <jlayton@redhat.com>
Cc: NeilBrown <neilb@suse.com>,
        "Linux NFS Mailing List" <linux-nfs@vger.kernel.org>
Subject: Re: wrong stateid used after flock lock taken
Date: Fri, 30 Sep 2016 14:30:14 -0400
Message-ID: <CBCD07C2-E6FE-475E-9899-683F06521F59@redhat.com>
In-Reply-To: <1475234523.2541.10.camel@redhat.com>
References: <87twcy5dyn.fsf@notabene.neil.brown.name>
 <1475234523.2541.10.camel@redhat.com>
MIME-Version: 1.0
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>


On 30 Sep 2016, at 7:22, Jeff Layton wrote:

> On Fri, 2016-09-30 at 12:16 +1000, NeilBrown wrote:
>> Hi Jeff et al.
>>
>> I think your patch
>> Commit: 8003d3c4aaa5 ("nfs4: treat lock owners as opaque values")
>>
>> introduced a regression ... or maybe exposed a latent problem.
>>
>> The particular symptom that I can demonstrate is that if I open a file
>> with NFSv4, take a flock() exclusive lock, and then write to the file,
>> then the WRITE request uses the stateid returned by OPEN, not the one
>> returned by LOCK.
>>
>> The Linux NFS server doesn't have a problem with that, but some NFS
>> servers do (one returns NFS4ERR_LOCKED, which seems to imply it imposes
>> mandatory locking!).
>> In any case, this is the wrong stateid to use.
>>
>> The patch changed nfs4_copy_lock_stateid() so it was more restrictive in
>> the stateids it allowed.
>> I must admit that I find the code that you removed incredibly confusing.
>> I defined a union field
>> -               pid_t flock_owner;
>>
>> and I cannot understand how a pid_t would be relevant for a flock_owner,
>> as the flock is tied to the 'struct file', not the pid.
>>
>> Anyway, a write request includes an 'nfs_lock_context' and from that we
>> need to somehow find the correct stateid.
>> I'm wondering if nfs4_set_rw_stateid() should call
>> nfs4_select_rw_stateid() twice, once to look for a flock stated, and
>> once to look for a posix-lock stateid .... or something like that.
>>
>> I'll take a fresh look at the code next week and maybe it will be easier
>> to understand then, but meanwhile if you have any suggestions I'd be
>> very happy to hear them.
>>
>> Thanks,
>> NeilBrown
>
> (cc'ing Ben...)
>
> I'll plan to give this another look as well. Maybe there's some way to
> do this more sanely that we can get Trond to accept? The catch is that
> read and write are both hot paths to some degree so we don't want to
> overly burden the client in those codepaths if we can help it...
>
> Ben Coddington had some patches a a few months ago (April?) that would
> have made OFD locks work properly witn NFSv4. Trond NAK'ed them at the
> time, but perhaps we should give those another look. OFD and flock locks
> both use the filp pointer as the owner, so those patches might also have
> fixed this case.

I think they would fix this case.

I thought the argument against was more about doing extra work for OFD,
rather than inserting latency into the IO path.  I don't think that fix
would have been much extra work for the client to do.. but I never
benchmarked it.  I could have been totally misreading everything, however.

I am very curious: What server is giving you NFS4ERR_LOCKED?

Ben
