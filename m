Return-Path: <bfields@fieldses.org>
Date: Mon, 18 Apr 2016 14:37:00 -0400
To: Benjamin Coddington <bcodding@redhat.com>
Cc: Olga Kornievskaia <aglo@umich.edu>, linux-nfs <linux-nfs@vger.kernel.org>
Subject: Re: gssd and linux containers
Message-ID: <20160418183700.GB3193@fieldses.org>
References: <CAN-5tyH-ATtHtWuw4t07DjZnnzOit=rQ=H0vq+W04gU=Ys=b+g@mail.gmail.com>
 <alpine.OSX.2.19.9992.1604141447230.55780@planck>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <alpine.OSX.2.19.9992.1604141447230.55780@planck>
From: bfields@fieldses.org (J. Bruce Fields)
List-ID: <linux-nfs.vger.kernel.org>

On Thu, Apr 14, 2016 at 02:57:51PM -0400, Benjamin Coddington wrote:
> On Thu, 14 Apr 2016, Olga Kornievskaia wrote:
> 
> > Hi folks,
> >
> > Does somebody know if it's possible to do secure mounts within linux
> > containers? I seem to recall that gssd is not container-aware. Or is
> > container-magic makes it so that gssd runs per container and has its
> > own dedicated krb5.conf+keytab configurations?
> >
> > Thank you.

On the server side it should work in theory, I don't know if anyone's
tested it.  On the client side:

> As far as I know there's no good way to run multiple gssd inside containers.
> There's only one global upcall mechanism, so even if we could keep track of
> which container is doing IO, there doesn't exist a way to upcall to the
> appropriate gssd.  Additionally, containers are a collection of shared
> namespaces.  A gssd could share one or more of those namespaces with a
> process doing IO, so what sort of rules do we use to pick the right gssd?
> 
> Ian Kent has led some discussion on solving this, and right now the thinking
> is to always upcall into whichever namespace collection created the mount,
> but the bet way to preserve those namespaces has not been agreed upon yet.

Isn't the client side still using the rpc_pipefs upcall?  That might
still need containerization work.  But that's different than the problem
Ian was looking at with running usermode helpers.  Making gssd work
might be easier.

--b.
