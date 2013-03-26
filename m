Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mout.perfora.net ([74.208.4.194]:56526 "EHLO mout.perfora.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S934899Ab3CZP5A (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Tue, 26 Mar 2013 11:57:00 -0400
Date: Tue, 26 Mar 2013 11:56:45 -0400
From: Jim Rees <rees@umich.edu>
To: Simo Sorce <simo@redhat.com>
Cc: "Myklebust, Trond" <Trond.Myklebust@netapp.com>,
        "libtirpc-devel@lists.sourceforge.net"
	<libtirpc-devel@lists.sourceforge.net>,
        linux-nfs <linux-nfs@vger.kernel.org>,
        Steve Dickson <steved@redhat.com>
Subject: Re: Allow building libtirpc directly against GSSAPI
Message-ID: <20130326155645.GA31975@umich.edu>
References: <1364308888.2660.119.camel@willson.li.ssimo.org>
 <1364311505.4534.0.camel@leira.trondhjem.org>
 <1364312268.2660.122.camel@willson.li.ssimo.org>
 <1364312636.4534.8.camel@leira.trondhjem.org>
 <1364312992.2660.126.camel@willson.li.ssimo.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <1364312992.2660.126.camel@willson.li.ssimo.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Doesn't nfs-utils build without gssglue if libgssglue is not installed? If
that's true I see no reason to change the default. If you don't want
gssglue, uninstall it. If you have it installed and want to build without
it, use --without-gssglue.
