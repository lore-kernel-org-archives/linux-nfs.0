Return-Path: linux-nfs-owner@vger.kernel.org
Received: from fieldses.org ([174.143.236.118]:41803 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751093Ab2HUO3I (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Tue, 21 Aug 2012 10:29:08 -0400
Date: Tue, 21 Aug 2012 10:29:05 -0400
From: "J. Bruce Fields" <bfields@fieldses.org>
To: "Myklebust, Trond" <Trond.Myklebust@netapp.com>
Cc: Stanislav Kinsbursky <skinsbursky@parallels.com>,
        Simo Sorce <simo@redhat.com>,
        "bfields@redhat.com" <bfields@redhat.com>,
        "linux-nfs@vger.kernel.org" <linux-nfs@vger.kernel.org>
Subject: Re: [PATCH 0/4] Add support for new RPCSEC_GSS upcall mechanism
 for nfsd
Message-ID: <20120821142905.GG9483@fieldses.org>
References: <20120711170331.GE11432@fieldses.org>
 <20120711172714.GA13610@fieldses.org>
 <1342028948.25375.45.camel@lade.trondhjem.org>
 <20120712221058.GC24162@fieldses.org>
 <20120713154302.GA32660@fieldses.org>
 <20120808193659.GA942@fieldses.org>
 <20120808194359.GB942@fieldses.org>
 <5022C824.504@parallels.com>
 <20120821141614.GF9483@fieldses.org>
 <4FA345DA4F4AE44899BD2B03EEEC2FA93C1F09@SACEXCMBX04-PRD.hq.netapp.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <4FA345DA4F4AE44899BD2B03EEEC2FA93C1F09@SACEXCMBX04-PRD.hq.netapp.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Tue, Aug 21, 2012 at 02:25:56PM +0000, Myklebust, Trond wrote:
> On Tue, 2012-08-21 at 10:16 -0400, J. Bruce Fields wrote:
> > One other question for Stanislav: I assume module parameters are global,
> > and that there's no plan to try to make them per-container?
> 
> Urgh... Per-container modules? That would be terrible...

Well, of course, but if module parameters can be modified
post-module-install then in theory those modifications could be made to
take effect only per namespace.  (But which namespace?)  I wouldn't be
surprised if the whole idea makes no sense, though, I haven't thought
about it.

--b.
