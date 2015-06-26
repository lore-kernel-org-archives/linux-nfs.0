Return-Path: <bfields@fieldses.org>
Date: Fri, 26 Jun 2015 13:50:32 -0400
To: Benjamin Coddington <bcodding@redhat.com>
Cc: Trond Myklebust <trond.myklebust@primarydata.com>,
        Anders Blomdell <anders.blomdell@control.lth.se>,
        Linux NFS Mailing List <linux-nfs@vger.kernel.org>
Subject: Re: Mount regression between 4.0.4 client and 2.6.35 server
Message-ID: <20150626175032.GA4293@fieldses.org>
References: <55827B8D.3070103@control.lth.se>
 <CAHQdGtS1affPWS=MLM8cn4C-JYjjbJUf2jHaK7uomLLkKc12HA@mail.gmail.com>
 <alpine.OSX.2.19.9992.1506260807060.13917@planck.local>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <alpine.OSX.2.19.9992.1506260807060.13917@planck.local>
From: bfields@fieldses.org (J. Bruce Fields)
List-ID: <linux-nfs.vger.kernel.org>

On Fri, Jun 26, 2015 at 08:17:30AM -0400, Benjamin Coddington wrote:
> On Thu, 18 Jun 2015, Trond Myklebust wrote:
> 
> > On Thu, Jun 18, 2015 at 4:04 AM, Anders Blomdell
> > <anders.blomdell@control.lth.se> wrote:
> > >
> > > I have a problem with a 4.0.4 client refusing to mount from a 2.6.35 server
> > > due to NFS4ERR_INVAL returned during nfs4_discover_server_trunking. See
> > > https://bugzilla.redhat.com/show_bug.cgi?id=1228272.
> >
> >
> > Why should we change the clients if the server is in clear and obvious
> > violation of the spec?
> 
> 
> What's happening here is knfsd older than 2.6.38 will return NFS4ERR_INVAL
> for EXCHANGE_ID that has EXCHGID4_FLAG_BIND_PRINC_STATEID set in the
> request.

Note that intentionally left off by default until 3.11, exactly because
I thought there was a high risk of incompatibility with future clients
at that point.

> Should the client's use of stateid/princ binding be optional/configureable?

So, perhaps there's other reasons for doing this, but we're not going to
justify it for compatibility with out-of-spec behavior in older
experimental server code.

Possibly more annoying is that Solaris servers (I don't know which
versions, I just have one report that says "Solaris 10") are also
returning GARBAGE_ARGS instead of NFS4ERR_MINOR_VERS_MISMATCH on
attempts to use 4.2.

--b.
