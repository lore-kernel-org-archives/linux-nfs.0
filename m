Return-Path: linux-nfs-owner@vger.kernel.org
Received: from bombadil.infradead.org ([198.137.202.9]:43433 "EHLO
	bombadil.infradead.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750892AbaLPIzi (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Tue, 16 Dec 2014 03:55:38 -0500
Date: Tue, 16 Dec 2014 00:55:32 -0800
From: Christoph Hellwig <hch@infradead.org>
To: Natanael Copa <ncopa@alpinelinux.org>
Cc: libtirpc-devel@lists.sourceforge.net, linux-nfs@vger.kernel.org
Subject: Re: [PATCH 3/9] Avoid use of internal glibc sys/cdefs.h header
Message-ID: <20141216085532.GA4003@infradead.org>
References: <1418718540-13667-1-git-send-email-ncopa@alpinelinux.org>
 <1418718540-13667-4-git-send-email-ncopa@alpinelinux.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <1418718540-13667-4-git-send-email-ncopa@alpinelinux.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Tue, Dec 16, 2014 at 09:28:54AM +0100, Natanael Copa wrote:
> This header was never intended to be used by programs.
> 
> Expand the macros used, __BEGIN_CDECLS, __END_CDECLS

Keeping __BEGIN_DECLS/__END_DECLS instead of the ifdef hell sounds
sensible, I'd suggest to just provide them if they don't exist.

Note that these are BSDishms, and not glibcisms, and used fairly widely,
so adding them to musl might be a good idea.

> The __THROW macro is a non-portable hint for optimization so we simply
> remove those.

These are important for C++, so please provide a defintion if not
present.

Against it would be useful if musl provided it.

