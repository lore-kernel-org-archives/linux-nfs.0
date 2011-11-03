Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx1.redhat.com ([209.132.183.28]:30687 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S934072Ab1KCQby (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Thu, 3 Nov 2011 12:31:54 -0400
Subject: Re: GSSAPI Proxy initiative
From: Simo Sorce <simo@redhat.com>
To: Nico Williams <nico@cryptonector.com>
Cc: linux-nfs@vger.kernel.org, krbdev <krbdev@mit.edu>,
        dhowells <dhowells@redhat.com>,
        Love =?ISO-8859-1?Q?H=F6rnquist_=C5strand?= <lha@kth.se>
In-Reply-To: <CAK3OfOhe_wZz2hKG-6HcSp_Y0=hLuRrKKb=7XOHg3sd_sz5pjw@mail.gmail.com>
References: <1320269170.7734.585.camel@willson.li.ssimo.org>
	 <CAK3OfOgaDjT9Smi8U1FCo=cGz5r5W2uub4xvYRqN4-9Pf-htXw@mail.gmail.com>
	 <1320332310.7734.643.camel@willson.li.ssimo.org>
	 <CAK3OfOhe_wZz2hKG-6HcSp_Y0=hLuRrKKb=7XOHg3sd_sz5pjw@mail.gmail.com>
Content-Type: text/plain; charset="UTF-8"
Date: Thu, 03 Nov 2011 12:31:43 -0400
Message-ID: <1320337903.7734.670.camel@willson.li.ssimo.org>
Mime-Version: 1.0
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Thu, 2011-11-03 at 11:05 -0500, Nico Williams wrote:
> On Thu, Nov 3, 2011 at 9:58 AM, Simo Sorce <simo@redhat.com> wrote:
> > On Wed, 2011-11-02 at 22:24 -0500, Nico Williams wrote:
> >>  - We want stateless GSS daemons, or mostly stateless at least, for
> >> several reasons:
> >>
> >>    a) to protect them against DoS, intentional and not;
> >
> > I get this.
> >
> >>    b) to make GSS daemon restart a non-event (OK, this is a much
> >> lesser concern).
> >
> > I am not sure I get this one, can you expand.
> 
> If the proxy daemon process dies, how should the proxy client recover?

Either wait for the proxy to restart or treat it as an unrecoverable
error, just like if the network goes away ?

>  If the client merely knows about credential handles for credentials
> stored in the proxy, then those are invalidated.  If the client has
> [encrypted] exported credential handle tokens then the new daemon
> process will be able to decrypt and import the client's credential
> handles.  Statelessness is helpful.

Well this case is true only if the proxy keeps state only in memory and
not in persistent storage. But this is something we want to keep in
mind, definitely, if the overhead is not too much it may make things
more robust.

> > Also how do you plan to keep conversations going and still be
> > stateless ? I am not sure transferring state back and forth is
> > necessarily a good thing.
> 
> What I'd like to see is the state cookies passed to the client be
> structured something like this (note that this would be an
> implementation detail, not part of the protocol spec): {object
> reference, verifier cookie, exported object token, [key ID for key
> that encrypted the exported token object, if any]}.  This allows for
> speed (no need to re-import state all the time) and statelessness (the
> server can restart, the server can push state out of a fixed-sized
> cache).

Ok, I can see how this may help.

> >>    Statelessness is not strictly necessary, just highly desirable, so
> >> if this proves difficult (or in some cases credential export turns out
> >> to not possibly be stateless for some mechanisms/credentials), oh
> >> well.  But the *protocol* should be designed to facilitate
> >> statelessness, and certainly not preclude it.
> >
> > I do not want to preclude anything if possible, but I also would like to
> > avoid over-complicating it. Being stateless often makes it slower as
> 
> There's no complication.  The protocol needs to allow for
> arbitrary-sized object handles -- that's all.

Ok, I was complaining about making the server more complicated, but
that's probably not really true, we will just trade one set of issues
with another as the state is kept 'somewhere' anyway, so I retire my
concern.

> >>  - I would like mechglues to support mechanisms being provided by
> >> multiple providers.  This is tricky, and for some mechanisms it will
> >> not be possible to make this perfect, but it's worthwhile  The reason
> >> is this: it should be possible to use a proxy for some credentials and
> >> not a proxy for others (particularly on the initiator side, where a
> >> user may not have direct access to some of their credentials but maybe
> >> can always kinit ones that they do have access to).
> >
> > The initiator side seem more complex indeed, but in general we need to
> 
> Let's agree to be careful with client/server vs. initiator/acceptor.
> The latter should refer exactly to the GSS meanings of "initiator" and
> "acceptor".  The former should refer to the proxy client and server.
> 
> > discuss how proxy vs non-proxy is going to be selected. The method may
> > differ between initiatior and acceptor as they are objectively different
> > cases. And it may differ also based on what app is using libgssapi.
> 
> The GSS-API lacks a concept of caller context handl -- an equivalent
> to krb5_context.  This is a problem.  We can't speak of who the
> application is, not in a world where many libraries use the GSS-API,
> because there can be multiple applications in one process and we can't
> easily distinguish which application the caller is.
> 
> I refer you to past discussions of how to address this.  I really want
> to avoid that subject for now though.

Ok, let's defer for now.

> > Do you have an example in mind, I think it would benefit everyone to
> > wrap their minds around these needs/issues if we provide some concrete
> > examples here and there.
> 
> Layered software.  Particularly pluggable layers like PAM.
> 
> >>  - Finding credentials, and authorization, will be a bit of a problem.
> >>  How to deal with things like kernel keyrings and KRB5CCNAME-type
> >> environment variables?
> >>
> >>    One possibility is that the proxy client passes everything the
> >> proxy server needs to the proxy server.  But that still requires that
> >> the proxy server be able to implement authorization correctly.
> >
> > I think we need to pass everything, and yet the proxy MUST be allowed to
> 
> I'd much rather not have to pass anything, but we need to support OSes
> where that's just how it's done.  I'd rather that IPC end-points can
> find out what what they need about their peers.  Think
> door_ucred(3DOOR).

I don't think I want to use the PID and then try to pull out environment
variables through /proc or similar interface, that would be bad.
For the krb5 mech we only care about a handful of environment variables.
Perhaps the protocol should be allowed to pass a list of variable
libgssapi should check for and return back, so that we can easily make
the list extensible and not have libgssapi always have to shove back the
full env var set of the process just in case.

> > decide what to trust and what not of course. Also we should not preclude
> 
> Trust nothing.  Authorization is separate.

That depends on the client.
When the client is the kernel we can decide to trust whatever it says.

> Indeed, I'm not interested in dictating implementation details.  It's
> going to be very difficult to avoid discussing possible implementation
> details, so I don't bother trying not to :)  But the protocol itself
> needs to be agnostic regarding these things.

ACK

> Multi-threaded is fine.  On Solaris it'd have to be multi-processed
> because it's not possible to have different process credentials for
> different threads of the same process in Solaris -- ias with this in
> mind that I mentioned the possible [implementation-specific detail of
> a] design where there's a daemon process per {user session}, {user,
> label}, ...

I am not sure you need that separation, but as it is an implementation
detail I think we should set discussion around this aside for now.

> I suppose I need to be more careful in separating what I intend to be
> part of a standard and what I intend to be an implementation detail
> when I describe these sorts of things.  To me it's clear, but perhaps
> not so much to others.

It is ok to agree that any time we mention implementation details of the
proxy itself these are not binding, but just a tool to explain why
something may be needed.

> >>  - The protocol probably need not be straight up ONC RPC however,
> >> though where ONC RPC supports suitable IPC interfaces as transports,
> >> it'd certainly be worth considering.
> >
> > We definitely MUST NOT require ONC RPC for the protocol, if someone
> > wants to use it for something specific and build it on our work I am
> > quite fine and I do not want to prevent it. But I thikn we do not want
> > to force all that overhead on Kernels and other implementations by
> > default as we do not really need it for a local daemon.
> 
> ONC RPC has next to no overhead when the transport is something like
> doors, for example.

I mean conceptual and development over head, not talking about
performance.

Simo.

-- 
Simo Sorce * Red Hat, Inc * New York

