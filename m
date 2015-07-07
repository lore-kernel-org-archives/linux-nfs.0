Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from bombadil.infradead.org ([198.137.202.9]:60498 "EHLO
	bombadil.infradead.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756061AbbGGI6s (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Tue, 7 Jul 2015 04:58:48 -0400
Date: Tue, 7 Jul 2015 01:58:45 -0700
From: "'Christoph Hellwig'" <hch@infradead.org>
To: Steve Wise <swise@opengridcomputing.com>
Cc: "'Christoph Hellwig'" <hch@infradead.org>, dledford@redhat.com,
        sagig@mellanox.com, ogerlitz@mellanox.com, roid@mellanox.com,
        linux-rdma@vger.kernel.org, eli@mellanox.com,
        target-devel@vger.kernel.org, linux-nfs@vger.kernel.org,
        trond.myklebust@primarydata.com, bfields@fieldses.org
Subject: Re: [PATCH V3 1/5] RDMA/core: Transport-independent access flags
Message-ID: <20150707085845.GA11736@infradead.org>
References: <20150705231831.12029.80307.stgit@build2.ogc.int>
 <20150705232158.12029.25472.stgit@build2.ogc.int>
 <20150706052515.GA1109@infradead.org>
 <000c01d0b7f7$5c5f02c0$151d0840$@opengridcomputing.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <000c01d0b7f7$5c5f02c0$151d0840$@opengridcomputing.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Mon, Jul 06, 2015 at 09:23:42AM -0500, Steve Wise wrote:
> > Please add an assert for the values that are allowed for attrs.
> > 
> > It also would be highly useful to add a kerneldoc comment describing
> > the function and the parameters.  Also __bitwise sparse tricks
> > to ensure the right flags are passed wouldn't be a too bad idea.
> > 
> 
> Can you explain the "__bitwise sparse tricks"?  Or point me to an example.  

Grep the kernel tree for __bitwise.  It allows creating a type with
additional type annotations so that sparse will warn when assigning
incorrect values to it.

> > Why not specfiy these as separate nuerical namespace?
> > 
> 
> To avoid having to translate them. 

But they are different values, so you should translate them.

