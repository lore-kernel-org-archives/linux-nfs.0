Return-Path: linux-nfs-owner@vger.kernel.org
Received: from bombadil.infradead.org ([198.137.202.9]:46094 "EHLO
	bombadil.infradead.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752542AbaIGRu2 (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Sun, 7 Sep 2014 13:50:28 -0400
Date: Sun, 7 Sep 2014 10:50:28 -0700
From: Christoph Hellwig <hch@infradead.org>
To: Christoph Hellwig <hch@lst.de>
Cc: linux-nfs@vger.kernel.org
Subject: Re: [PATCH 1/6] pnfs: enable CB_NOTIFY_DEVICEID support
Message-ID: <20140907175028.GA27934@infradead.org>
References: <1409719119-2110-1-git-send-email-hch@lst.de>
 <1409719119-2110-2-git-send-email-hch@lst.de>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <1409719119-2110-2-git-send-email-hch@lst.de>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Tue, Sep 02, 2014 at 09:38:34PM -0700, Christoph Hellwig wrote:
> This code has been around for a while, but never was enabled.  Turns out it
> really does work out of the box at least for the block layout driver, so
> we just need to wire it up, and in case of NOTIFY_DEVICEID4_CHANGE remove
> a conditional that returns an error.
> 
> Note that we implement NOTIFY_DEVICEID4_CHANGE identical to
> NOTIFY_DEVICEID4_DELETE.  Given that in either case we can't do anything
> but preventing further lookups of a given device ID there isn't much difference
> in semantics for the two.  For the delete case the server MUST ensure that
> there are no outstanding layouts, while for the change case it doesn't, but
> that has little relevance to the client.

I got a comment that we should probably just enable CB_NOTIFY_DEVICEID
for all layout types unconditionally as there really isn't anything
layout type specific in it.  I'm tempted to agree, so if anyone
disagrees speak up now, or I'll resend it that way in a few days.

