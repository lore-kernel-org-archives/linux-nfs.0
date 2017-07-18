Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from verein.lst.de ([213.95.11.211]:55551 "EHLO newverein.lst.de"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1751334AbdGRJIy (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Tue, 18 Jul 2017 05:08:54 -0400
Date: Tue, 18 Jul 2017 11:08:53 +0200
From: Christoph Hellwig <hch@lst.de>
To: Eryu Guan <eguan@redhat.com>
Cc: linux-nfs@vger.kernel.org, Christoph Hellwig <hch@lst.de>
Subject: Re: [PATCH] nfs: count correct array for mnt3_counts array size
Message-ID: <20170718090853.GA19665@lst.de>
References: <20170718053232.14858-1-eguan@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <20170718053232.14858-1-eguan@redhat.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Tue, Jul 18, 2017 at 01:32:32PM +0800, Eryu Guan wrote:
> Array size of mnt3_counts should be the size of array
> mnt3_procedures, not mnt_procedures, though they're same in size
> right now. Found this by code inspection.
> 
> Fixes: 1c5876ddbdb4 ("sunrpc: move p_count out of struct rpc_procinfo")
> Cc: Christoph Hellwig <hch@lst.de>
> Signed-off-by: Eryu Guan <eguan@redhat.com>

Oops, yes.

Looks good:

Reviewed-by: Christoph Hellwig <hch@lst.de>
