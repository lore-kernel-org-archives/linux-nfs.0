Return-Path: <jlayton@redhat.com>
Message-ID: <1475234523.2541.10.camel@redhat.com>
Subject: Re: wrong stateid used after flock lock taken
From: Jeff Layton <jlayton@redhat.com>
To: NeilBrown <neilb@suse.com>
Cc: Linux NFS Mailing List <linux-nfs@vger.kernel.org>,
        Benjamin Coddington
	 <bcodding@redhat.com>
Date: Fri, 30 Sep 2016 07:22:03 -0400
In-Reply-To: <87twcy5dyn.fsf@notabene.neil.brown.name>
References: <87twcy5dyn.fsf@notabene.neil.brown.name>
Content-Type: text/plain; charset="UTF-8"
Mime-Version: 1.0
List-ID: <linux-nfs.vger.kernel.org>

On Fri, 2016-09-30 at 12:16 +1000, NeilBrown wrote:
> Hi Jeff et al.
> 
> I think your patch
> Commit: 8003d3c4aaa5 ("nfs4: treat lock owners as opaque values")
> 
> introduced a regression ... or maybe exposed a latent problem.
> 
> The particular symptom that I can demonstrate is that if I open a file
> with NFSv4, take a flock() exclusive lock, and then write to the file,
> then the WRITE request uses the stateid returned by OPEN, not the one
> returned by LOCK.
> 
> The Linux NFS server doesn't have a problem with that, but some NFS
> servers do (one returns NFS4ERR_LOCKED, which seems to imply it imposes
> mandatory locking!).
> In any case, this is the wrong stateid to use.
> 
> The patch changed nfs4_copy_lock_stateid() so it was more restrictive in
> the stateids it allowed.
> I must admit that I find the code that you removed incredibly confusing.
> I defined a union field
> -               pid_t flock_owner;
> 
> and I cannot understand how a pid_t would be relevant for a flock_owner,
> as the flock is tied to the 'struct file', not the pid.
> 
> Anyway, a write request includes an 'nfs_lock_context' and from that we
> need to somehow find the correct stateid.
> I'm wondering if nfs4_set_rw_stateid() should call
> nfs4_select_rw_stateid() twice, once to look for a flock stated, and
> once to look for a posix-lock stateid .... or something like that.
> 
> I'll take a fresh look at the code next week and maybe it will be easier
> to understand then, but meanwhile if you have any suggestions I'd be
> very happy to hear them.
> 
> Thanks,
> NeilBrown

(cc'ing Ben...)

I'll plan to give this another look as well. Maybe there's some way to
do this more sanely that we can get Trond to accept? The catch is that
read and write are both hot paths to some degree so we don't want to
overly burden the client in those codepaths if we can help it...

Ben Coddington had some patches a a few months ago (April?) that would
have made OFD locks work properly witn NFSv4. Trond NAK'ed them at the
time, but perhaps we should give those another look. OFD and flock locks
both use the filp pointer as the owner, so those patches might also have
fixed this case.

Look for:

    [PATCH 0/3] Include OFD lock owners when looking up state

-- 
Jeff Layton <jlayton@redhat.com>
