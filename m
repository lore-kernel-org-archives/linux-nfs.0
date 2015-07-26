Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from bombadil.infradead.org ([198.137.202.9]:41400 "EHLO
	bombadil.infradead.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753665AbbGZKna (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Sun, 26 Jul 2015 06:43:30 -0400
Date: Sun, 26 Jul 2015 03:43:28 -0700
From: Christoph Hellwig <hch@infradead.org>
To: Sagi Grimberg <sagig@dev.mellanox.co.il>
Cc: Steve Wise <swise@opengridcomputing.com>, dledford@redhat.com,
        infinipath@intel.com, sagig@mellanox.com, ogerlitz@mellanox.com,
        roid@mellanox.com, linux-rdma@vger.kernel.org, eli@mellanox.com,
        target-devel@vger.kernel.org, linux-nfs@vger.kernel.org,
        bfields@fieldses.org
Subject: Re: [PATCH V6 6/9] isert: Rename IO functions to more descriptive
 names
Message-ID: <20150726104328.GB18944@infradead.org>
References: <20150724161331.25617.8475.stgit@build2.ogc.int>
 <20150724161848.25617.26092.stgit@build2.ogc.int>
 <55B4B190.7070305@dev.mellanox.co.il>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <55B4B190.7070305@dev.mellanox.co.il>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Sun, Jul 26, 2015 at 01:08:16PM +0300, Sagi Grimberg wrote:
> I've given this some thought and I think we should avoid splitting
> logic from PI and iWARP. The reason (other than code duplication) is
> that currently the iser target support only up to 1MB IOs. I have some
> code (not done yet) to support larger IOs by using multiple
> registrations  per IO (with or without PI).

Just curious: How is this going to work with iSER only having a single
rkey/offset/len field?
