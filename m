Return-Path: linux-nfs-owner@vger.kernel.org
Received: from fieldses.org ([174.143.236.118]:59398 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753325Ab2HHToD (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Wed, 8 Aug 2012 15:44:03 -0400
Date: Wed, 8 Aug 2012 15:43:59 -0400
From: "J. Bruce Fields" <bfields@fieldses.org>
To: Stanislav Kinsbursky <skinsbursky@parallels.com>
Cc: "Myklebust, Trond" <Trond.Myklebust@netapp.com>,
        Simo Sorce <simo@redhat.com>,
        "bfields@redhat.com" <bfields@redhat.com>,
        "linux-nfs@vger.kernel.org" <linux-nfs@vger.kernel.org>
Subject: Re: [PATCH 0/4] Add support for new RPCSEC_GSS upcall mechanism
 for nfsd
Message-ID: <20120808194359.GB942@fieldses.org>
References: <1341958332.17428.12.camel@lade.trondhjem.org>
 <1341959112.17428.19.camel@lade.trondhjem.org>
 <20120710223818.GA6720@fieldses.org>
 <1341961118.17428.29.camel@lade.trondhjem.org>
 <20120711170331.GE11432@fieldses.org>
 <20120711172714.GA13610@fieldses.org>
 <1342028948.25375.45.camel@lade.trondhjem.org>
 <20120712221058.GC24162@fieldses.org>
 <20120713154302.GA32660@fieldses.org>
 <20120808193659.GA942@fieldses.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <20120808193659.GA942@fieldses.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Wed, Aug 08, 2012 at 03:36:59PM -0400, J. Bruce Fields wrote:
> However, one hangup: figuring out how to switch on gssproxy
> per-container isn't very interesting until gssproxy can actually work
> per-container.  I'd *really* like to get the unix socket stuff worked
> out first.

Stanislav, what's left to be done to get per-container unix sockets?

--b.
