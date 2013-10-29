Return-Path: linux-nfs-owner@vger.kernel.org
Received: from bombadil.infradead.org ([198.137.202.9]:41586 "EHLO
	bombadil.infradead.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751774Ab3J2Hjn (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Tue, 29 Oct 2013 03:39:43 -0400
Date: Tue, 29 Oct 2013 00:39:43 -0700
From: Christoph Hellwig <hch@infradead.org>
To: Anna Schumaker <bjschuma@netapp.com>
Cc: Trond.Myklebust@netapp.com, linux-nfs@vger.kernel.org
Subject: Re: [PATCH 2/3] NFS: Allow for asynchronous WRITE_PLUS calls
Message-ID: <20131029073943.GD10889@infradead.org>
References: <1382972418-2249-1-git-send-email-bjschuma@netapp.com>
 <1382972418-2249-3-git-send-email-bjschuma@netapp.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <1382972418-2249-3-git-send-email-bjschuma@netapp.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Mon, Oct 28, 2013 at 11:00:17AM -0400, Anna Schumaker wrote:
> Clients are required to support CB_OFFLOAD for the NFS4_CONTENT_HOLE arm
> of the WRITE_PLUS union.

This sounds pretty stupid.  Just curious, who got this braindamage into
the standard?

