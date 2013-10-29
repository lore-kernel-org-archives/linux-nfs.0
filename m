Return-Path: linux-nfs-owner@vger.kernel.org
Received: from bombadil.infradead.org ([198.137.202.9]:41578 "EHLO
	bombadil.infradead.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751803Ab3J2HhU (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Tue, 29 Oct 2013 03:37:20 -0400
Date: Tue, 29 Oct 2013 00:37:19 -0700
From: Christoph Hellwig <hch@infradead.org>
To: "J. Bruce Fields" <bfields@fieldses.org>
Cc: Anna Schumaker <bjschuma@netapp.com>, linux-nfs@vger.kernel.org
Subject: Re: [RFC 5/4] NFSD: Add basic CB_OFFLOAD support
Message-ID: <20131029073719.GB10889@infradead.org>
References: <1382972247-1108-1-git-send-email-bjschuma@netapp.com>
 <1382972247-1108-6-git-send-email-bjschuma@netapp.com>
 <20131028215221.GQ31322@fieldses.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <20131028215221.GQ31322@fieldses.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Mon, Oct 28, 2013 at 05:52:21PM -0400, J. Bruce Fields wrote:
> On Mon, Oct 28, 2013 at 10:57:27AM -0400, Anna Schumaker wrote:
> > This patch adds basic offload support to the WRITE_PLUS operation.
> > Since I don't implement OFFLOAD_ABORT, OFFLOAD_REVOKE or OFFLOAD_STATUS
> > this patch is NOT spec compliant and should not be applied without
> > further work.
> 
> Ugh.  I don't understand why we need asynchronous modes for all these
> operations.

Hole punches as implemented by any filesystem at the moement are pure
metadata manipulations and should not require "async" versions that
offload to a workqueue.

