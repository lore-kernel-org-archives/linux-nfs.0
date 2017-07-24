Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from bombadil.infradead.org ([65.50.211.133]:41535 "EHLO
        bombadil.infradead.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1750732AbdGXHkt (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Mon, 24 Jul 2017 03:40:49 -0400
Date: Mon, 24 Jul 2017 00:40:39 -0700
From: Christoph Hellwig <hch@infradead.org>
To: NeilBrown <neilb@suse.com>
Cc: Trond Myklebust <trond.myklebust@primarydata.com>,
        Anna Schumaker <anna.schumaker@netapp.com>,
        linux-nfs@vger.kernel.org
Subject: Re: [PATCH 0/2] Fix NFS issues with posix_fallocate() in locked file.
Message-ID: <20170724074038.GA15701@infradead.org>
References: <150086579083.13837.3550463220871996964.stgit@noble>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <150086579083.13837.3550463220871996964.stgit@noble>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Mon, Jul 24, 2017 at 01:18:50PM +1000, NeilBrown wrote:
> /* nfs-lock-allocate.c
>  * Test for performing fallocate() after locking an NFS file.
>  * The nfs client must revalidate the size after getting the
>  * lock, and should merge all the 1-byte writes past EOF into
>  * fewer large writes.
>  */

Can you please wire this test case up for xfstests?
