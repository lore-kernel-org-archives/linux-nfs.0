Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:42926 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751126AbcDRUE1 (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Mon, 18 Apr 2016 16:04:27 -0400
Date: Mon, 18 Apr 2016 16:04:24 -0400 (EDT)
From: Benjamin Coddington <bcodding@redhat.com>
To: "J. Bruce Fields" <bfields@fieldses.org>
cc: Olga Kornievskaia <aglo@umich.edu>, linux-nfs <linux-nfs@vger.kernel.org>
Subject: Re: gssd and linux containers
In-Reply-To: <20160418183700.GB3193@fieldses.org>
Message-ID: <alpine.OSX.2.19.9992.1604181600280.55780@planck>
References: <CAN-5tyH-ATtHtWuw4t07DjZnnzOit=rQ=H0vq+W04gU=Ys=b+g@mail.gmail.com> <alpine.OSX.2.19.9992.1604141447230.55780@planck> <20160418183700.GB3193@fieldses.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Mon, 18 Apr 2016, J. Bruce Fields wrote:

> On Thu, Apr 14, 2016 at 02:57:51PM -0400, Benjamin Coddington wrote:
> > On Thu, 14 Apr 2016, Olga Kornievskaia wrote:
> >
> > > Hi folks,
> > >
> > > Does somebody know if it's possible to do secure mounts within linux
> > > containers? I seem to recall that gssd is not container-aware. Or is
> > > container-magic makes it so that gssd runs per container and has its
> > > own dedicated krb5.conf+keytab configurations?
> > >
> > > Thank you.
>
> On the server side it should work in theory, I don't know if anyone's
> tested it.  On the client side:
>
> > As far as I know there's no good way to run multiple gssd inside containers.
> > There's only one global upcall mechanism, so even if we could keep track of
> > which container is doing IO, there doesn't exist a way to upcall to the
> > appropriate gssd.  Additionally, containers are a collection of shared
> > namespaces.  A gssd could share one or more of those namespaces with a
> > process doing IO, so what sort of rules do we use to pick the right gssd?
> >
> > Ian Kent has led some discussion on solving this, and right now the thinking
> > is to always upcall into whichever namespace collection created the mount,
> > but the bet way to preserve those namespaces has not been agreed upon yet.
>
> Isn't the client side still using the rpc_pipefs upcall?  That might
> still need containerization work.  But that's different than the problem
> Ian was looking at with running usermode helpers.  Making gssd work
> might be easier.

Yes, the client is still using rpc_pipefs for gssd, and it does need
containerization work.  My understanding is that when containerized
usermode helpers are solved, gssd would move to them since putting
credentials on keyrings would be a convenient way to have multiple
creds per uid.

Ben
