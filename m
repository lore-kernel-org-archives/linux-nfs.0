Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from bombadil.infradead.org ([198.137.202.9]:52403 "EHLO
	bombadil.infradead.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1758256AbbGHKUn (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Wed, 8 Jul 2015 06:20:43 -0400
Date: Wed, 8 Jul 2015 03:20:35 -0700
From: "'Christoph Hellwig'" <hch@infradead.org>
To: Sagi Grimberg <sagig@dev.mellanox.co.il>
Cc: "'Christoph Hellwig'" <hch@infradead.org>,
        Jason Gunthorpe <jgunthorpe@obsidianresearch.com>,
        Steve Wise <swise@opengridcomputing.com>, dledford@redhat.com,
        sagig@mellanox.com, ogerlitz@mellanox.com, roid@mellanox.com,
        linux-rdma@vger.kernel.org, eli@mellanox.com,
        target-devel@vger.kernel.org, linux-nfs@vger.kernel.org,
        trond.myklebust@primarydata.com, bfields@fieldses.org,
        Oren Duer <oren@mellanox.com>
Subject: Re: [PATCH V3 1/5] RDMA/core: Transport-independent access flags
Message-ID: <20150708102035.GA28421@infradead.org>
References: <559AAA22.1000608@dev.mellanox.co.il>
 <20150707090001.GB11736@infradead.org>
 <559B9891.8060907@dev.mellanox.co.il>
 <000b01d0b8bd$f2bfcc10$d83f6430$@opengridcomputing.com>
 <20150707161751.GA623@obsidianresearch.com>
 <559BFE03.4020709@dev.mellanox.co.il>
 <20150707213628.GA5661@obsidianresearch.com>
 <559CD174.4040901@dev.mellanox.co.il>
 <20150708081320.GB24203@infradead.org>
 <559CF5E8.6080000@dev.mellanox.co.il>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <559CF5E8.6080000@dev.mellanox.co.il>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Wed, Jul 08, 2015 at 01:05:28PM +0300, Sagi Grimberg wrote:
> If we agree to consolidate on a single MR allocation API, I don't see
> how this wrapper is moving us forward. But if you guys prefer to have it
> than I don't have a hard objection.

Well, when are we going to get that MR allocation API?  Unless it's
ready to go in ASAP I'd rather take a first step in the right direction
instead of waiting.
