Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from bombadil.infradead.org ([198.137.202.9]:43870 "EHLO
	bombadil.infradead.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751215AbbGFFZo (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 6 Jul 2015 01:25:44 -0400
Date: Sun, 5 Jul 2015 22:25:42 -0700
From: Christoph Hellwig <hch@infradead.org>
To: Steve Wise <swise@opengridcomputing.com>
Cc: dledford@redhat.com, sagig@mellanox.com, ogerlitz@mellanox.com,
        roid@mellanox.com, linux-rdma@vger.kernel.org, eli@mellanox.com,
        target-devel@vger.kernel.org, linux-nfs@vger.kernel.org,
        trond.myklebust@primarydata.com, bfields@fieldses.org
Subject: Re: [PATCH V3 0/5] Transport-independent MRs
Message-ID: <20150706052542.GB1109@infradead.org>
References: <20150705231831.12029.80307.stgit@build2.ogc.int>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <20150705231831.12029.80307.stgit@build2.ogc.int>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Sun, Jul 05, 2015 at 06:21:53PM -0500, Steve Wise wrote:
> This series introduces transport-independent RDMA core services for
> allocating DMA MRs and computing fast register access flags.  Included are
> changes to the iSER and NFSRDMA ULPs to make use of the new services.

Can you convert all of them and remove the old APIs?

