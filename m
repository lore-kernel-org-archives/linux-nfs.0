Return-Path: linux-nfs-owner@vger.kernel.org
Received: from bombadil.infradead.org ([198.137.202.9]:52192 "EHLO
	bombadil.infradead.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752706AbaJIQCP (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 9 Oct 2014 12:02:15 -0400
Date: Thu, 9 Oct 2014 09:02:14 -0700
From: Christoph Hellwig <hch@infradead.org>
To: Trond Myklebust <trond.myklebust@primarydata.com>
Cc: linux-nfs@vger.kernel.org, Weston Andros Adamson <dros@primarydata.com>
Subject: Re: [PATCH] NFSv4.1/pnfs: replace broken pnfs_put_lseg_async
Message-ID: <20141009160214.GA32766@infradead.org>
References: <1412801200-17936-1-git-send-email-trond.myklebust@primarydata.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <1412801200-17936-1-git-send-email-trond.myklebust@primarydata.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Wed, Oct 08, 2014 at 04:46:40PM -0400, Trond Myklebust wrote:
> You cannot call pnfs_put_lseg_async() more than once per lseg, so it
> is really an inappropriate way to deal with a refcount issue.
> 
> Instead, replace it with a function that decrements the refcount, and
> puts the final 'free' operation (which is incompatible with locks) on
> the workqueue.

How about calling the clear_request_commit layout driver operation
from a workqueue?  That seems like a much saner approach.

