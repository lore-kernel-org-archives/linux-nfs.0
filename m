Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from bombadil.infradead.org ([198.137.202.9]:47007 "EHLO
	bombadil.infradead.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754287AbbHIHSP (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Sun, 9 Aug 2015 03:18:15 -0400
Date: Sun, 9 Aug 2015 00:18:14 -0700
From: Christoph Hellwig <hch@infradead.org>
To: Jeff Layton <jlayton@poochiereds.net>
Cc: bfields@fieldses.org, linux-nfs@vger.kernel.org
Subject: Re: [PATCH v2 12/18] nfsd: move include of state.h from trace.c to
 trace.h
Message-ID: <20150809071814.GE9772@infradead.org>
References: <1438264341-18048-1-git-send-email-jeff.layton@primarydata.com>
 <1438809216-4846-1-git-send-email-jeff.layton@primarydata.com>
 <1438809216-4846-13-git-send-email-jeff.layton@primarydata.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <1438809216-4846-13-git-send-email-jeff.layton@primarydata.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Wed, Aug 05, 2015 at 05:13:30PM -0400, Jeff Layton wrote:
> Any file which includes trace.h will need to include state.h, even if
> they aren't using any state tracepoints. Ensure that we include any
> headers that might be needed in trace.h instead of relying on the
> *.c files to have the right ones.
> 
> Signed-off-by: Jeff Layton <jeff.layton@primarydata.com>

Looks fine,

Reviewed-by: Christoph Hellwig <hch@lst.de>
