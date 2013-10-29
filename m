Return-Path: linux-nfs-owner@vger.kernel.org
Received: from bombadil.infradead.org ([198.137.202.9]:41584 "EHLO
	bombadil.infradead.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751774Ab3J2HjJ (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Tue, 29 Oct 2013 03:39:09 -0400
Date: Tue, 29 Oct 2013 00:39:08 -0700
From: Christoph Hellwig <hch@infradead.org>
To: Anna Schumaker <bjschuma@netapp.com>
Cc: Trond.Myklebust@netapp.com, linux-nfs@vger.kernel.org
Subject: Re: [PATCH 1/3] NFS: Use WRITE_PLUS for hole punches
Message-ID: <20131029073908.GC10889@infradead.org>
References: <1382972418-2249-1-git-send-email-bjschuma@netapp.com>
 <1382972418-2249-2-git-send-email-bjschuma@netapp.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <1382972418-2249-2-git-send-email-bjschuma@netapp.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Mon, Oct 28, 2013 at 11:00:16AM -0400, Anna Schumaker wrote:
> This patch implements a version of fallocate for NFS v4.  In the v4.2
> case, we use WRITE_PLUS with DATA_CONTENT_HOLE set to punch a hole in a
> file.  In NFS < v4.2, we fall back to the generic VFS fallocate
> implementation.

What generic VFS fallocate implementation do you fall back to?  Not only
can't I find a call to to it, nor does such a thing even exist.

