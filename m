Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from bombadil.infradead.org ([18.85.46.34]:55270 "EHLO
	bombadil.infradead.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1758239Ab1EMKcG (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Fri, 13 May 2011 06:32:06 -0400
Date: Fri, 13 May 2011 06:32:02 -0400
From: Christoph Hellwig <hch@infradead.org>
To: Peng Huang <shawn.p.huang@gmail.com>
Cc: Trond Myklebust <Trond.Myklebust@netapp.com>, linux-nfs@vger.kernel.org,
        linux-kernel@vger.kernel.org
Subject: Re: [PATCH] nfs: check a crash in nfs_lookup_revalidate
Message-ID: <20110513103202.GA27578@infradead.org>
References: <1305147805-5756-1-git-send-email-shawn.p.huang@gmail.com>
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <1305147805-5756-1-git-send-email-shawn.p.huang@gmail.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

On Wed, May 11, 2011 at 05:03:25PM -0400, Peng Huang wrote:
> lookup_one_len() may call nfs_loopup_revalidate() with nd == NULL
> indirectly, that causes the kernel crash.

lookup_one_len must only be called by a filesystem or a library function
called by the filesystem.  You are not allowed to call it on a random
filesystem like nfs that doesn't support the underlying assumptions.

