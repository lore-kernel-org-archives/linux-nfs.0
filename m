Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx1.redhat.com ([209.132.183.28]:29829 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S965273Ab3CZPh6 (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Tue, 26 Mar 2013 11:37:58 -0400
Subject: Re: Allow building libtirpc directly against GSSAPI
From: Simo Sorce <simo@redhat.com>
To: "Myklebust, Trond" <Trond.Myklebust@netapp.com>
Cc: "libtirpc-devel@lists.sourceforge.net"
	<libtirpc-devel@lists.sourceforge.net>,
        linux-nfs <linux-nfs@vger.kernel.org>,
        Steve Dickson <steved@redhat.com>
In-Reply-To: <1364311505.4534.0.camel@leira.trondhjem.org>
References: <1364308888.2660.119.camel@willson.li.ssimo.org>
	 <1364311505.4534.0.camel@leira.trondhjem.org>
Content-Type: text/plain; charset="UTF-8"
Date: Tue, 26 Mar 2013 11:37:48 -0400
Message-ID: <1364312268.2660.122.camel@willson.li.ssimo.org>
Mime-Version: 1.0
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Tue, 2013-03-26 at 15:25 +0000, Myklebust, Trond wrote:
> On Tue, 2013-03-26 at 10:41 -0400, Simo Sorce wrote:
> > Libgssglue is not really useful anymore, it is a sort of middleman that
> > wraps the actual GSSAPI that is already pluggable/extensible via shared
> > modules.
> > 
> > In particular libgssglue interferes with the workings of gss-proxy in my
> > case.
> > 
> > The attached patch makes building against libgssglue optional and
> > defaults to not build against libgssglue and instead builds directly
> > against the native GSSAPI.
> > 
> > ./configure --enable-gss
> > will now build against GSSAPI
> > 
> > ./configure --enable-gss --with-gssglue
> > will keep building against libgssglue in case someone still needs it for
> > whatever reason.
> > 
> > Simo.
> > 
> 
> Won't that be a backward compatibility issue?

What are you worried about exactly ? Is there a use case we should know
about ?

Simo.

-- 
Simo Sorce * Red Hat, Inc * New York

