Return-Path: linux-nfs-owner@vger.kernel.org
Received: from fieldses.org ([174.143.236.118]:59412 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752213Ab3J2NgN (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Tue, 29 Oct 2013 09:36:13 -0400
Date: Tue, 29 Oct 2013 09:36:11 -0400
From: "J. Bruce Fields" <bfields@fieldses.org>
To: Christoph Hellwig <hch@infradead.org>
Cc: Anna Schumaker <bjschuma@netapp.com>, linux-nfs@vger.kernel.org
Subject: Re: [RFC 5/4] NFSD: Add basic CB_OFFLOAD support
Message-ID: <20131029133611.GF29606@fieldses.org>
References: <1382972247-1108-1-git-send-email-bjschuma@netapp.com>
 <1382972247-1108-6-git-send-email-bjschuma@netapp.com>
 <20131028215221.GQ31322@fieldses.org>
 <20131029073719.GB10889@infradead.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <20131029073719.GB10889@infradead.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Tue, Oct 29, 2013 at 12:37:19AM -0700, Christoph Hellwig wrote:
> On Mon, Oct 28, 2013 at 05:52:21PM -0400, J. Bruce Fields wrote:
> > On Mon, Oct 28, 2013 at 10:57:27AM -0400, Anna Schumaker wrote:
> > > This patch adds basic offload support to the WRITE_PLUS operation.
> > > Since I don't implement OFFLOAD_ABORT, OFFLOAD_REVOKE or OFFLOAD_STATUS
> > > this patch is NOT spec compliant and should not be applied without
> > > further work.
> > 
> > Ugh.  I don't understand why we need asynchronous modes for all these
> > operations.
> 
> Hole punches as implemented by any filesystem at the moement are pure
> metadata manipulations and should not require "async" versions that
> offload to a workqueue.

Yeah, understood, I'm glad we're not implementing that, I just wonder
why every one of these operations (COPY, WRITE_PLUS, etc.) has to have
this asynchronous option.

The client's still stuck implementing it even if the server does, it's
extra protocol verbage even if nobody uses it, and I'm not completely
clear what it's for.

--b.
