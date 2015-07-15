Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from bombadil.infradead.org ([198.137.202.9]:46847 "EHLO
	bombadil.infradead.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752825AbbGOMTh (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Wed, 15 Jul 2015 08:19:37 -0400
Date: Wed, 15 Jul 2015 05:19:26 -0700
From: "'Christoph Hellwig'" <hch@infradead.org>
To: Sagi Grimberg <sagig@dev.mellanox.co.il>
Cc: Jason Gunthorpe <jgunthorpe@obsidianresearch.com>,
        "'Christoph Hellwig'" <hch@infradead.org>,
        Steve Wise <swise@opengridcomputing.com>,
        "'Steve Wise'" <swise@ogc.us>, "'Tom Talpey'" <tom@talpey.com>,
        "'Doug Ledford'" <dledford@redhat.com>, sagig@mellanox.com,
        ogerlitz@mellanox.com, roid@mellanox.com, linux-rdma@vger.kernel.org,
        eli@mellanox.com, target-devel@vger.kernel.org,
        linux-nfs@vger.kernel.org, trond.myklebust@primarydata.com,
        bfields@fieldses.org, "'Oren Duer'" <oren@mellanox.com>
Subject: Re: [PATCH V3 1/5] RDMA/core: Transport-independent access flags
Message-ID: <20150715121926.GB14993@infradead.org>
References: <559FC710.1050307@talpey.com>
 <20150710161108.GA19042@obsidianresearch.com>
 <CCB6E837-88FF-4DBB-976D-4CF56396A1A1@ogc.us>
 <55A24571.60902@dev.mellanox.co.il>
 <00e201d0be6a$e49bc910$add35b30$@opengridcomputing.com>
 <20150714192941.GA26292@obsidianresearch.com>
 <00e401d0be6b$d3952750$7abf75f0$@opengridcomputing.com>
 <20150714195511.GB7716@infradead.org>
 <20150714202943.GB26927@obsidianresearch.com>
 <55A61E38.20201@dev.mellanox.co.il>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <55A61E38.20201@dev.mellanox.co.il>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Wed, Jul 15, 2015 at 11:47:52AM +0300, Sagi Grimberg wrote:
> >  struct ib_pd *ib_alloc_pd(struct ib_device *device)
> >  {
> >  	struct ib_pd *pd;
> >+	struct ib_device_attr devattr;
> >+	int rc;
> >+
> >+	rc = ib_query_device(device, &devattr);
> >+	if (rc)
> >+		return ERR_PTR(rc);
> 
> Unrelated question,
> Can we just cache the dev_attr in ib_device already? It's pretty
> obvious that each consumer that opens a device will automatically
> query its attributes...

Instead of caching it I'd suggest to kill ib_device_attr and move
the field into struct ib_device, similar to how all major kernel
subsystems work.  Otherwise fully agreed.

