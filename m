Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx1.redhat.com ([209.132.183.28]:48253 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751596Ab3CZQ5H (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Tue, 26 Mar 2013 12:57:07 -0400
Subject: Re: Allow building libtirpc directly against GSSAPI
From: Simo Sorce <simo@redhat.com>
To: Jim Rees <rees@umich.edu>
Cc: "Myklebust, Trond" <Trond.Myklebust@netapp.com>,
        "libtirpc-devel@lists.sourceforge.net"
	<libtirpc-devel@lists.sourceforge.net>,
        linux-nfs <linux-nfs@vger.kernel.org>,
        Steve Dickson <steved@redhat.com>
In-Reply-To: <20130326155645.GA31975@umich.edu>
References: <1364308888.2660.119.camel@willson.li.ssimo.org>
	 <1364311505.4534.0.camel@leira.trondhjem.org>
	 <1364312268.2660.122.camel@willson.li.ssimo.org>
	 <1364312636.4534.8.camel@leira.trondhjem.org>
	 <1364312992.2660.126.camel@willson.li.ssimo.org>
	 <20130326155645.GA31975@umich.edu>
Content-Type: text/plain; charset="UTF-8"
Date: Tue, 26 Mar 2013 12:56:52 -0400
Message-ID: <1364317012.2660.129.camel@willson.li.ssimo.org>
Mime-Version: 1.0
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Tue, 2013-03-26 at 11:56 -0400, Jim Rees wrote:
> Doesn't nfs-utils build without gssglue if libgssglue is not installed?

Not really, both libtirpc needs --enable-gss, if yo pass that they check
only for libgssglue right now and fail if not available.

> If that's true I see no reason to change the default. If you don't want
> gssglue, uninstall it. If you have it installed and want to build without
> it, use --without-gssglue.

I am changing the default to build against system GSSAPI libraries when
--enable-gss is passed in, if you want to force to build against
libgssglue for some specific reason you use --with-gssglue

I believe building against system libraries instead of a shim is the
better default in the general case.

Simo.

-- 
Simo Sorce * Red Hat, Inc * New York

