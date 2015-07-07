Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from bombadil.infradead.org ([198.137.202.9]:34623 "EHLO
	bombadil.infradead.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754041AbbGGJBy (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Tue, 7 Jul 2015 05:01:54 -0400
Date: Tue, 7 Jul 2015 02:01:51 -0700
From: "'Christoph Hellwig'" <hch@infradead.org>
To: Steve Wise <swise@opengridcomputing.com>
Cc: "'Christoph Hellwig'" <hch@infradead.org>, dledford@redhat.com,
        sagig@mellanox.com, ogerlitz@mellanox.com, roid@mellanox.com,
        linux-rdma@vger.kernel.org, eli@mellanox.com,
        target-devel@vger.kernel.org, linux-nfs@vger.kernel.org,
        trond.myklebust@primarydata.com, bfields@fieldses.org
Subject: Re: [PATCH V3 0/5] Transport-independent MRs
Message-ID: <20150707090151.GC11736@infradead.org>
References: <20150705231831.12029.80307.stgit@build2.ogc.int>
 <20150706052542.GB1109@infradead.org>
 <000e01d0b7f7$86f6f100$94e4d300$@opengridcomputing.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <000e01d0b7f7$86f6f100$94e4d300$@opengridcomputing.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Mon, Jul 06, 2015 at 09:24:54AM -0500, Steve Wise wrote:
> I can.  These are the only "transport independent" ULPs at this point.

And the only reason for that is that the current APIs are such a
nighmare and require extra effort to be transport independent.  By
removing APIs that encourage this and replacing them with APIs that
get you transport independence automatically we're getting closer to
something that looks like real Linux APIs rather than the current Verbs
nightmare.

