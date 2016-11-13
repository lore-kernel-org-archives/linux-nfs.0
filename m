Return-Path: <jlayton@redhat.com>
Message-ID: <1479006561.8210.6.camel@redhat.com>
Subject: Re: CLOSE/OPEN race
From: Jeff Layton <jlayton@redhat.com>
To: Trond Myklebust <trondmy@primarydata.com>,
        Benjamin Coddington
	 <bcodding@redhat.com>
Cc: Linux List <linux-nfs@vger.kernel.org>
Date: Sat, 12 Nov 2016 22:09:21 -0500
In-Reply-To: <C70DF662-8158-4842-9A52-5E1BE42C7FD5@primarydata.com>
References: <9E2B8A0D-7B0E-4AE5-800A-0EF3F7F7F694@redhat.com>
	 <C70DF662-8158-4842-9A52-5E1BE42C7FD5@primarydata.com>
Content-Type: text/plain; charset="UTF-8"
Mime-Version: 1.0
List-ID: <linux-nfs.vger.kernel.org>

On Sat, 2016-11-12 at 18:16 +0000, Trond Myklebust wrote:
> > On Nov 12, 2016, at 06:08, Benjamin Coddington <bcodding@redhat.com> wrote:
> > 
> > I've been seeing the following on a modified version of generic/089
> > that gets the client stuck sending LOCK with NFS4ERR_OLD_STATEID.
> > 
> > 1. Client has open stateid A, sends a CLOSE
> > 2. Client sends OPEN with same owner
> > 3. Client sends another OPEN with same owner
> > 4. Client gets a reply to OPEN in 3, stateid is B.2 (stateid B sequence 2)
> > 5. Client does LOCK,LOCKU,FREE_STATEID from B.2
> > 6. Client gets a reply to CLOSE in 1
> > 7. Client gets reply to OPEN in 2, stateid is B.1
> > 8. Client sends LOCK with B.1 - OLD_STATEID, now stuck in a loop
> > 
> > The CLOSE response in 6 causes us to clear NFS_OPEN_STATE, so that the OPEN
> > response in 7 is able to update the open_stateid even though it has a lower
> > sequence number.
> 
> Hmm… We probably should not do that if the stateid.other field of A (i.e. the one supplied as the argument to CLOSE) does not match the stateid.other of B.
> In fact, the reply in (4), where the stateid changes to B, should be the thing that resets the OPEN state.NrybXǧv^)޺{.n+{"^nrzh&Gh(階ݢj"mzޖfh~m

It looks like that's already the case in nfs_clear_open_stateid_locked,
though I don't think we ought to be doing anything with the stateid in
the CLOSE response. I sent a draft patch in another part of this
thread, but I don't quite see how that would cause this problem.
-- 
Jeff Layton <jlayton@redhat.com>
