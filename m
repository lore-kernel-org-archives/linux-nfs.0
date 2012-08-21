Return-Path: linux-nfs-owner@vger.kernel.org
Received: from fieldses.org ([174.143.236.118]:45330 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751813Ab2HUOQS (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Tue, 21 Aug 2012 10:16:18 -0400
Date: Tue, 21 Aug 2012 10:16:14 -0400
From: "J. Bruce Fields" <bfields@fieldses.org>
To: Stanislav Kinsbursky <skinsbursky@parallels.com>
Cc: "Myklebust, Trond" <Trond.Myklebust@netapp.com>,
        Simo Sorce <simo@redhat.com>,
        "bfields@redhat.com" <bfields@redhat.com>,
        "linux-nfs@vger.kernel.org" <linux-nfs@vger.kernel.org>
Subject: Re: [PATCH 0/4] Add support for new RPCSEC_GSS upcall mechanism
 for nfsd
Message-ID: <20120821141614.GF9483@fieldses.org>
References: <20120710223818.GA6720@fieldses.org>
 <1341961118.17428.29.camel@lade.trondhjem.org>
 <20120711170331.GE11432@fieldses.org>
 <20120711172714.GA13610@fieldses.org>
 <1342028948.25375.45.camel@lade.trondhjem.org>
 <20120712221058.GC24162@fieldses.org>
 <20120713154302.GA32660@fieldses.org>
 <20120808193659.GA942@fieldses.org>
 <20120808194359.GB942@fieldses.org>
 <5022C824.504@parallels.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <5022C824.504@parallels.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

One other question for Stanislav: I assume module parameters are global,
and that there's no plan to try to make them per-container?

--b.
