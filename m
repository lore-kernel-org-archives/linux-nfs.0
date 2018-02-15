Return-Path: <bfields@fieldses.org>
Date: Thu, 15 Feb 2018 10:29:20 -0500
From: Bruce Fields <bfields@fieldses.org>
To: Jeff Layton <jlayton@redhat.com>
Cc: "Mkrtchyan, Tigran" <tigran.mkrtchyan@desy.de>,
	Olga Kornievskaia <aglo@umich.edu>,
	Trond Myklebust <trond.myklebust@primarydata.com>,
	linux-nfs <linux-nfs@vger.kernel.org>,
	Benjamin Coddington <bcodding@redhat.com>
Subject: Re: [PATCH 1/2] NFSv4: Fix CLOSE races with OPEN
Message-ID: <20180215152920.GA9999@fieldses.org>
References: <1479140396-17779-1-git-send-email-trond.myklebust@primarydata.com>
 <1479140396-17779-2-git-send-email-trond.myklebust@primarydata.com>
 <CAN-5tyGEn3vGJicR+00ATSp7PzUEm_6FzjBwYwiS-++OcqqfaA@mail.gmail.com>
 <159288847.6126985.1518697149126.JavaMail.zimbra@desy.de>
 <1518697380.4086.10.camel@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <1518697380.4086.10.camel@redhat.com>
List-ID: <linux-nfs.vger.kernel.org>

On Thu, Feb 15, 2018 at 07:23:00AM -0500, Jeff Layton wrote:
> On Thu, 2018-02-15 at 13:19 +0100, Mkrtchyan, Tigran wrote:
> > 
> > ----- Original Message -----
> > > From: "Olga Kornievskaia" <aglo@umich.edu>
> > > To: "Trond Myklebust" <trond.myklebust@primarydata.com>
> > > Cc: "linux-nfs" <linux-nfs@vger.kernel.org>, "Benjamin Coddington" <bcodding@redhat.com>, "Jeff Layton"
> > > <jlayton@redhat.com>
> > > Sent: Tuesday, February 13, 2018 9:08:01 PM
> > > Subject: Re: [PATCH 1/2] NFSv4: Fix CLOSE races with OPEN
> > > On Mon, Nov 14, 2016 at 11:19 AM, Trond Myklebust
> > > <trond.myklebust@primarydata.com> wrote:
> > > > If the reply to a successful CLOSE call races with an OPEN to the same
> > > > file, we can end up scribbling over the stateid that represents the
> > > > new open state.
> > > > The race looks like:
> > > > 
> > > >   Client                                Server
> > > >   ======                                ======
> > > > 
> > > >   CLOSE stateid A on file "foo"
> > > >                                         CLOSE stateid A, return stateid C
> > > 
> > > Hi folks,
> > > 
> > > I'd like to understand this particular issue. Specifically I don't
> > > understand how can server return stateid C to the close with stateid
> > > A.
> > > 
> > > As per RFC 7530 or 5661. It says that state is returned by the close
> > > shouldn't be used.
> > > 
> > > Even though CLOSE returns a stateid, this stateid is not useful to
> > >   the client and should be treated as deprecated.  CLOSE "shuts down"
> > >   the state associated with all OPENs for the file by a single
> > >   open-owner.  As noted above, CLOSE will either release all file
> > >   locking state or return an error.  Therefore, the stateid returned by
> > >   CLOSE is not useful for the operations that follow.
> > > 
> > > Is this because the spec says "should" and not a "must"?
> > > 
> > > Linux server increments a state's sequenceid on CLOSE. Ontap server
> > > does not. I'm not sure what other servers do. Are all these
> > 
> > 
> > Our server sends back invalid state id for v4.1 and v4.0.
> > 
> > Tigran.
> > 
> 
> That's probably the best thing to do, and we should probably do the same
>  for v4.0 in knfsd. Doing that might cause problems for clients that are
> not ignoring that field like they should, but they're buggy already.

Not only buggy in theory, but actually failing in practice, it sounds
like.  So, a pretty safe change?

Returning an all-zeroes stateid would be simple and make the situation
really obvious.

--b.
