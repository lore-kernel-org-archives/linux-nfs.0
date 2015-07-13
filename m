Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from quartz.orcorp.ca ([184.70.90.242]:46622 "EHLO quartz.orcorp.ca"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751149AbbGMQfL (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Mon, 13 Jul 2015 12:35:11 -0400
Date: Mon, 13 Jul 2015 10:35:02 -0600
From: Jason Gunthorpe <jgunthorpe@obsidianresearch.com>
To: "'Christoph Hellwig'" <hch@infradead.org>
Cc: Sagi Grimberg <sagig@dev.mellanox.co.il>, Tom Talpey <tom@talpey.com>,
        Steve Wise <swise@opengridcomputing.com>, dledford@redhat.com,
        sagig@mellanox.com, ogerlitz@mellanox.com, roid@mellanox.com,
        linux-rdma@vger.kernel.org, eli@mellanox.com,
        target-devel@vger.kernel.org, linux-nfs@vger.kernel.org,
        trond.myklebust@primarydata.com, bfields@fieldses.org,
        Oren Duer <oren@mellanox.com>
Subject: Re: [PATCH V3 1/5] RDMA/core: Transport-independent access flags
Message-ID: <20150713163502.GB23832@obsidianresearch.com>
References: <20150707161751.GA623@obsidianresearch.com>
 <559BFE03.4020709@dev.mellanox.co.il>
 <20150707213628.GA5661@obsidianresearch.com>
 <559CD174.4040901@dev.mellanox.co.il>
 <20150708190842.GB11740@obsidianresearch.com>
 <559D983D.6000804@talpey.com>
 <20150708233604.GA20765@obsidianresearch.com>
 <559E54AB.2010905@dev.mellanox.co.il>
 <20150709170142.GA21921@obsidianresearch.com>
 <20150711102538.GB14741@infradead.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <20150711102538.GB14741@infradead.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Sat, Jul 11, 2015 at 03:25:38AM -0700, 'Christoph Hellwig' wrote:

> So a FRMR-like API that allows to use FMRs underneath might be a good
> start.  If the imput to that API are S/G lists as in my suggestion we'll
> get indirect registration support almost for free.

That would be an excellent outcome in my view.

Jason
