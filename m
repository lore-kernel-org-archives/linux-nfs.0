Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from bombadil.infradead.org ([198.137.202.9]:46993 "EHLO
	bombadil.infradead.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754287AbbHIHRD (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Sun, 9 Aug 2015 03:17:03 -0400
Date: Sun, 9 Aug 2015 00:17:02 -0700
From: Christoph Hellwig <hch@infradead.org>
To: Jeff Layton <jlayton@poochiereds.net>
Cc: bfields@fieldses.org, linux-nfs@vger.kernel.org
Subject: Re: [PATCH v2 04/18] nfsd: add a new struct file caching facility to
 nfsd
Message-ID: <20150809071702.GD9772@infradead.org>
References: <1438264341-18048-1-git-send-email-jeff.layton@primarydata.com>
 <1438809216-4846-1-git-send-email-jeff.layton@primarydata.com>
 <1438809216-4846-5-git-send-email-jeff.layton@primarydata.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <1438809216-4846-5-git-send-email-jeff.layton@primarydata.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Wed, Aug 05, 2015 at 05:13:22PM -0400, Jeff Layton wrote:
> Currently, NFSv2/3 reads and writes have to open a file, do the read or
> write and then close it again for each RPC. This is highly inefficient,
> especially when the underlying filesystem has a relatively slow open
> routine.

.. as do many NFSv4 reads and writes as they often get special stateids
passed from the client.  Seems a little odd that we take more care
of this for the legacy protocols than the current one.

I think I'd rather see a nfs4_file cache and turn v2/3 into something
like the special stateid case.  Did you consider that?
