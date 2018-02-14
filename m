Return-Path: <jlayton@redhat.com>
Message-ID: <1518621683.13566.5.camel@redhat.com>
Subject: Re: [PATCH 1/2] NFSv4: Fix CLOSE races with OPEN
From: Jeff Layton <jlayton@redhat.com>
To: Benjamin Coddington <bcodding@redhat.com>, Olga Kornievskaia
	 <aglo@umich.edu>
Cc: Trond Myklebust <trond.myklebust@primarydata.com>, linux-nfs
	 <linux-nfs@vger.kernel.org>
Date: Wed, 14 Feb 2018 10:21:23 -0500
In-Reply-To: <698A2B0C-1E38-4B65-ABA3-60C396393E30@redhat.com>
References: 
	<1479140396-17779-1-git-send-email-trond.myklebust@primarydata.com>
	 <1479140396-17779-2-git-send-email-trond.myklebust@primarydata.com>
	 <CAN-5tyGEn3vGJicR+00ATSp7PzUEm_6FzjBwYwiS-++OcqqfaA@mail.gmail.com>
	 <698A2B0C-1E38-4B65-ABA3-60C396393E30@redhat.com>
Content-Type: text/plain; charset="UTF-8"
Mime-Version: 1.0
List-ID: <linux-nfs.vger.kernel.org>

On Wed, 2018-02-14 at 10:05 -0500, Benjamin Coddington wrote:
> Hi Olga,
> 
> On 13 Feb 2018, at 15:08, Olga Kornievskaia wrote:
> 
> > On Mon, Nov 14, 2016 at 11:19 AM, Trond Myklebust
> > <trond.myklebust@primarydata.com> wrote:
> > > If the reply to a successful CLOSE call races with an OPEN to the same
> > > file, we can end up scribbling over the stateid that represents the
> > > new open state.
> > > The race looks like:
> > > 
> > >   Client                                Server
> > >   ======                                ======
> > > 
> > >   CLOSE stateid A on file "foo"
> > >                                         CLOSE stateid A, return stateid C
> > 
> > Hi folks,
> > 
> > I'd like to understand this particular issue. Specifically I don't
> > understand how can server return stateid C to the close with stateid
> > A.
> 
> I think in this explanation of the race, stateid C is an incremented version
> of A -- the stateid's "other" fields match -- OR it is the invalid special
> stateid according to RFC 5661, Section 18.2.4.
> 
> > As per RFC 7530 or 5661. It says that state is returned by the close
> > shouldn't be used.
> > 
> > Even though CLOSE returns a stateid, this stateid is not useful to
> >    the client and should be treated as deprecated.  CLOSE "shuts down"
> >    the state associated with all OPENs for the file by a single
> >    open-owner.  As noted above, CLOSE will either release all file
> >    locking state or return an error.  Therefore, the stateid returned by
> >    CLOSE is not useful for the operations that follow.
> > 
> > Is this because the spec says "should" and not a "must"?
> 
> I don't understand - is what because?  The state returned from CLOSE is
> useful to be used by the client for housekeeping, but it won't be re-used in
> the protocol.
> 
> > Linux server increments a state's sequenceid on CLOSE. Ontap server
> > does not. I'm not sure what other servers do. Are all these
> > implementations equality correct?
> 
> Ah, good question there..  Even though the stateid is not useful for
> operations that follow, I think the sequenceid should be incremented because
> the CLOSE is an operation that modifies the set of locks or state:
> 

It doesn't matter.

> In RFC 7530, Section 9.1.4.2.:
> ...
>    When such a set of locks is first created, the server returns a
>    stateid with a seqid value of one.  On subsequent operations that
>    modify the set of locks, the server is required to advance the
>    seqid field by one whenever it returns a stateid for the same
>    state-owner/file/type combination and the operation is one that might
>    make some change in the set of locks actually designated.  In this
>    case, the server will return a stateid with an "other" field the same
>    as previously used for that state-owner/file/type combination, with
>    an incremented seqid field.
> 
> But, in RFC 5661, the CLOSE response SHOULD be the invalid special stateid.
> I don't recall, does the linux server increment the existing stateid or send
> back the invalid special stateid on v4.1?
> 

A CLOSE, by definition, is destroying the old stateid, so what does it
matter what you return on success? It's bogus either way.

If knfsd is sending back a "real" stateid there, then it's likely only
because that's what the v4.0 spec said to do ~10 years ago. It's
probably fine to fix it to just return the invalid special stateid and
call it a day. All clients should just ignore it.

-- 
Jeff Layton <jlayton@redhat.com>
