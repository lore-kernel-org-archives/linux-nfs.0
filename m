Return-Path: <bfields@fieldses.org>
Date: Fri, 26 Jun 2015 14:32:20 -0400
From: "J. Bruce Fields" <bfields@fieldses.org>
To: Trond Myklebust <trond.myklebust@primarydata.com>
Cc: Benjamin Coddington <bcodding@redhat.com>,
        Anders Blomdell <anders.blomdell@control.lth.se>,
        Linux NFS Mailing List <linux-nfs@vger.kernel.org>
Subject: Re: Mount regression between 4.0.4 client and 2.6.35 server
Message-ID: <20150626183220.GB4293@fieldses.org>
References: <55827B8D.3070103@control.lth.se>
 <CAHQdGtS1affPWS=MLM8cn4C-JYjjbJUf2jHaK7uomLLkKc12HA@mail.gmail.com>
 <alpine.OSX.2.19.9992.1506260807060.13917@planck.local>
 <20150626175032.GA4293@fieldses.org>
 <CAHQdGtSS7+Vu4fS9_-UkkoE7AcjsAC8HSqT=LhT32A-kc5UnOA@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <CAHQdGtSS7+Vu4fS9_-UkkoE7AcjsAC8HSqT=LhT32A-kc5UnOA@mail.gmail.com>
List-ID: <linux-nfs.vger.kernel.org>

On Fri, Jun 26, 2015 at 01:58:35PM -0400, Trond Myklebust wrote:
> On Fri, Jun 26, 2015 at 1:50 PM, J. Bruce Fields <bfields@fieldses.org> wrote:
> > On Fri, Jun 26, 2015 at 08:17:30AM -0400, Benjamin Coddington wrote:
> >> On Thu, 18 Jun 2015, Trond Myklebust wrote:
> >>
> >> > On Thu, Jun 18, 2015 at 4:04 AM, Anders Blomdell
> >> > <anders.blomdell@control.lth.se> wrote:
> >> > >
> >> > > I have a problem with a 4.0.4 client refusing to mount from a 2.6.35 server
> >> > > due to NFS4ERR_INVAL returned during nfs4_discover_server_trunking. See
> >> > > https://bugzilla.redhat.com/show_bug.cgi?id=1228272.
> >> >
> >> >
> >> > Why should we change the clients if the server is in clear and obvious
> >> > violation of the spec?
> >>
> >>
> >> What's happening here is knfsd older than 2.6.38 will return NFS4ERR_INVAL
> >> for EXCHANGE_ID that has EXCHGID4_FLAG_BIND_PRINC_STATEID set in the
> >> request.
> >
> > Note that intentionally left off by default until 3.11, exactly because
> > I thought there was a high risk of incompatibility with future clients
> > at that point.
> >
> >> Should the client's use of stateid/princ binding be optional/configureable?
> >
> > So, perhaps there's other reasons for doing this, but we're not going to
> > justify it for compatibility with out-of-spec behavior in older
> > experimental server code.
> 
> The protocol gives the server the option of rejecting the client's
> request for bind_princ_stateid by simply turning off the flag in its
> reply. See https://tools.ietf.org/html/rfc5661#section-18.35.3

Yeah, that's what it's doing.

(The failure in this case was because the code just didn't know about
the flag at all--I think it still had constants taken from an earlier
ietf draft.  Like I say, experimental code.)

--b.

> 
> > Possibly more annoying is that Solaris servers (I don't know which
> > versions, I just have one report that says "Solaris 10") are also
> > returning GARBAGE_ARGS instead of NFS4ERR_MINOR_VERS_MISMATCH on
> > attempts to use 4.2.
