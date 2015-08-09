Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from bombadil.infradead.org ([198.137.202.9]:46943 "EHLO
	bombadil.infradead.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754275AbbHIHOi (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Sun, 9 Aug 2015 03:14:38 -0400
Date: Sun, 9 Aug 2015 00:14:38 -0700
From: Christoph Hellwig <hch@infradead.org>
To: Jeff Layton <jlayton@poochiereds.net>
Cc: bfields@fieldses.org, linux-nfs@vger.kernel.org
Subject: Re: [PATCH v2 03/18] nfsd: convert laundry_wq to something less
 nfsd4 specific
Message-ID: <20150809071438.GC9772@infradead.org>
References: <1438264341-18048-1-git-send-email-jeff.layton@primarydata.com>
 <1438809216-4846-1-git-send-email-jeff.layton@primarydata.com>
 <1438809216-4846-4-git-send-email-jeff.layton@primarydata.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <1438809216-4846-4-git-send-email-jeff.layton@primarydata.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Wed, Aug 05, 2015 at 05:13:21PM -0400, Jeff Layton wrote:
> Currently, nfsd uses a singlethread workqueue for this, but that's not
> necessary. If we have multiple namespaces, then there's no need to
> serialize the laundromat runs since they are only requeued at the end of
> the work itself.
> 
> Also, create_singlethread_workqueue adds the WQ_MEM_RECLAIM flag, which
> doesn't really seem to be necessary. The laundromat jobs are always
> kicked off via a timer, and not from memory reclaim paths. There's no
> need for a rescuer thread.

Why would you change it to an unbound WQ?  I'd really prefer to split
the change of workqueue semantics and making it globall available, too.
