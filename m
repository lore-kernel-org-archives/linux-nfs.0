Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from bombadil.infradead.org ([198.137.202.9]:59517 "EHLO
	bombadil.infradead.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751376AbbFKIUb (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 11 Jun 2015 04:20:31 -0400
Date: Thu, 11 Jun 2015 01:20:28 -0700
From: Christoph Hellwig <hch@infradead.org>
To: Kinglong Mee <kinglongmee@gmail.com>
Cc: Trond Myklebust <trond.myklebust@primarydata.com>,
        "linux-nfs@vger.kernel.org" <linux-nfs@vger.kernel.org>,
        Weston Andros Adamson <dros@primarydata.com>,
        "J. Bruce Fields" <bfields@fieldses.org>
Subject: Re: [PATCH 1/2] nfs: Only update callback sequnce id when
 CB_SEQUENCE success
Message-ID: <20150611082028.GA11330@infradead.org>
References: <556D8C66.8080203@gmail.com>
 <5578E67C.1030303@gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <5578E67C.1030303@gmail.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Hi Kinglong,

when we last brought up this issue the recommendation was to follow
the model in the clients nfs41_sequence_done() which handles even
more corner cases.  Given that my previous fixes in that area were
just a bandaid I probably shouldn't complain about piece mail handling,
but if you have a little spare time available implementing the full
set of checks might be worthwhile.

