Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx2.netapp.com ([216.240.18.37]:28463 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751230Ab1KCUj7 convert rfc822-to-8bit (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 3 Nov 2011 16:39:59 -0400
Subject: Re: GSSAPI Proxy initiative
From: Trond Myklebust <Trond.Myklebust@netapp.com>
To: Nico Williams <nico@cryptonector.com>
Cc: Simo Sorce <simo@redhat.com>, linux-nfs@vger.kernel.org,
        krbdev <krbdev@mit.edu>, dhowells <dhowells@redhat.com>,
        Love =?ISO-8859-1?Q?H=F6rnquist_=C5strand?= <lha@kth.se>
Date: Thu, 03 Nov 2011 16:39:44 -0400
In-Reply-To: <CAK3OfOjj0GOPpeEBi4kA9jqP-vfgYqYMdv1P44H3ve0gU0hg5g@mail.gmail.com>
References: <1320269170.7734.585.camel@willson.li.ssimo.org>
	 <CAK3OfOgaDjT9Smi8U1FCo=cGz5r5W2uub4xvYRqN4-9Pf-htXw@mail.gmail.com>
	 <1320332310.7734.643.camel@willson.li.ssimo.org>
	 <CAK3OfOhe_wZz2hKG-6HcSp_Y0=hLuRrKKb=7XOHg3sd_sz5pjw@mail.gmail.com>
	 <1320337903.7734.670.camel@willson.li.ssimo.org>
	 <CAK3OfOjj0GOPpeEBi4kA9jqP-vfgYqYMdv1P44H3ve0gU0hg5g@mail.gmail.com>
Content-Type: text/plain; charset="UTF-8"
Message-ID: <1320352784.18396.109.camel@lade.trondhjem.org>
Mime-Version: 1.0
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Thu, 2011-11-03 at 13:57 -0500, Nico Williams wrote: 
> On Thu, Nov 3, 2011 at 11:31 AM, Simo Sorce <simo@redhat.com> wrote:
> > On Thu, 2011-11-03 at 11:05 -0500, Nico Williams wrote:
> >> If the proxy daemon process dies, how should the proxy client recover?
> >
> > Either wait for the proxy to restart or treat it as an unrecoverable
> > error, just like if the network goes away ?
> 
> If state is lost the client has to recover.  Sure, it's going to
> somehow (perhaps by returning an error to the user, who then retries).
>  Point is: a stateless (or stateless + caching, for perf) design would
> avoid this.
> 
> For the protocol that just means that handles need to be opaque octet
> strings, NOT just small integers.  Whether a given implementation is
> stateless is another story.  This is what I was driving at.
> 
> > Ok, I can see how this may help.
> 
> :)
> 
> >> There's no complication.  The protocol needs to allow for
> >> arbitrary-sized object handles -- that's all.
> >
> > Ok, I was complaining about making the server more complicated, but
> > that's probably not really true, we will just trade one set of issues
> > with another as the state is kept 'somewhere' anyway, so I retire my
> > concern.
> 
> Right.
> 
> >> I'd much rather not have to pass anything, but we need to support OSes
> >> where that's just how it's done.  I'd rather that IPC end-points can
> >> find out what what they need about their peers.  Think
> >> door_ucred(3DOOR).
> >
> > I don't think I want to use the PID and then try to pull out environment
> > variables through /proc or similar interface, that would be bad.
> 
> I would never have suggested that.
> 
> What I had in mind was something like PAGs or keyrings.  Or, to be
> much more specific, search for my name and the string "credentials
> process groups" -- a PAG on steroids.
> 
> The idea is that the IPC peer can observe the other's
> PAG/keyring/CPG/whatever and use that to find the correct credentials
> (authorization is still required though).

Linux already has per-user, per-process and per-thread keyrings which
offer a high security storage solution for keys. The problem with those
is that they are difficult to use in an asynchronous context when the
original user's process/thread context is no longer available to us.

Ideally, though, that's what we'd like to see used.

Trond
-- 
Trond Myklebust
Linux NFS client maintainer

NetApp
Trond.Myklebust@netapp.com
www.netapp.com

