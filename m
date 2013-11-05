Return-Path: linux-nfs-owner@vger.kernel.org
Received: from bombadil.infradead.org ([198.137.202.9]:43797 "EHLO
	bombadil.infradead.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751009Ab3KEPL6 (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Tue, 5 Nov 2013 10:11:58 -0500
Date: Tue, 5 Nov 2013 07:11:57 -0800
From: Christoph Hellwig <hch@infradead.org>
To: Anna Schumaker <bjschuma@netapp.com>
Cc: bfields@fieldses.org, linux-nfs@vger.kernel.org
Subject: Re: [PATCH 3/4] NFSD: Add WRITE_PLUS support for hole punches
Message-ID: <20131105151157.GA16510@infradead.org>
References: <1382972247-1108-1-git-send-email-bjschuma@netapp.com>
 <1382972247-1108-4-git-send-email-bjschuma@netapp.com>
 <20131105094016.GA7186@infradead.org>
 <5278FF7F.4020000@netapp.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <5278FF7F.4020000@netapp.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Tue, Nov 05, 2013 at 09:23:59AM -0500, Anna Schumaker wrote:
> It's not ignored in do_fallocate() (fs/open.c) where it returns -EOPNOTSUPP if FALLOC_FL_PUNCH_HOLE is set without FALLOC_FL_KEEP_SIZE :)

Oops, looks like we decided to enforce it, despite hole punches never
having an effect on file size.  I stand corrected.
