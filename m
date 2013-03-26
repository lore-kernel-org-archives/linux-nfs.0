Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx1.redhat.com ([209.132.183.28]:52089 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S934842Ab3CZPuL (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Tue, 26 Mar 2013 11:50:11 -0400
Subject: Re: Allow building libtirpc directly against GSSAPI
From: Simo Sorce <simo@redhat.com>
To: "Myklebust, Trond" <Trond.Myklebust@netapp.com>
Cc: "libtirpc-devel@lists.sourceforge.net"
	<libtirpc-devel@lists.sourceforge.net>,
        linux-nfs <linux-nfs@vger.kernel.org>,
        Steve Dickson <steved@redhat.com>
In-Reply-To: <1364312636.4534.8.camel@leira.trondhjem.org>
References: <1364308888.2660.119.camel@willson.li.ssimo.org>
	 <1364311505.4534.0.camel@leira.trondhjem.org>
	 <1364312268.2660.122.camel@willson.li.ssimo.org>
	 <1364312636.4534.8.camel@leira.trondhjem.org>
Content-Type: text/plain; charset="UTF-8"
Date: Tue, 26 Mar 2013 11:49:52 -0400
Message-ID: <1364312992.2660.126.camel@willson.li.ssimo.org>
Mime-Version: 1.0
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Tue, 2013-03-26 at 15:43 +0000, Myklebust, Trond wrote:
> On Tue, 2013-03-26 at 11:37 -0400, Simo Sorce wrote:
> > On Tue, 2013-03-26 at 15:25 +0000, Myklebust, Trond wrote:
> > > On Tue, 2013-03-26 at 10:41 -0400, Simo Sorce wrote:
> > > > Libgssglue is not really useful anymore, it is a sort of middleman that
> > > > wraps the actual GSSAPI that is already pluggable/extensible via shared
> > > > modules.
> > > > 
> > > > In particular libgssglue interferes with the workings of gss-proxy in my
> > > > case.
> > > > 
> > > > The attached patch makes building against libgssglue optional and
> > > > defaults to not build against libgssglue and instead builds directly
> > > > against the native GSSAPI.
> > > > 
> > > > ./configure --enable-gss
> > > > will now build against GSSAPI
> > > > 
> > > > ./configure --enable-gss --with-gssglue
> > > > will keep building against libgssglue in case someone still needs it for
> > > > whatever reason.
> > > > 
> > > > Simo.
> > > > 
> > > 
> > > Won't that be a backward compatibility issue?
> > 
> > What are you worried about exactly ? Is there a use case we should know
> > about ?
> 
> Building nfs-utils against existing older setups. There are a lot of
> users out there of 4-5 year old distros (including ones maintained by
> your employer).
> 
> Why isn't it safe to assume that if someone has libgssglue installed,
> then we should be building nfs-utils against it?

A foillowing patch for nfs-utils is coming, both the libtirpc and
nfs-utils patches will make building against libgssglue optional.

I see no value for selecting libgssglue by default though.
libgssglue does nothing but load the underlying gssapi library by
default anyway and adds nothing to that.

I am leaving the option to compile against libgssglue exactly for the
odd case where someone has a good reason to use it (very, very old
systems). In that case all they need to do is to run configure with
--enable-gss --with-gssglue

Simo.

-- 
Simo Sorce * Red Hat, Inc * New York

