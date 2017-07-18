Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from fieldses.org ([173.255.197.46]:44490 "EHLO fieldses.org"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1751640AbdGRQEp (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Tue, 18 Jul 2017 12:04:45 -0400
Date: Tue, 18 Jul 2017 12:04:44 -0400
To: Christoph Hellwig <hch@lst.de>
Cc: Eryu Guan <eguan@redhat.com>, linux-nfs@vger.kernel.org,
        Anna Schumaker <schumakeranna@gmail.com>,
        Trond Myklebust <trond.myklebust@primarydata.com>
Subject: Re: [PATCH] nfs: count correct array for mnt3_counts array size
Message-ID: <20170718160444.GD19030@fieldses.org>
References: <20170718053232.14858-1-eguan@redhat.com>
 <20170718090853.GA19665@lst.de>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <20170718090853.GA19665@lst.de>
From: bfields@fieldses.org (J. Bruce Fields)
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Tue, Jul 18, 2017 at 11:08:53AM +0200, Christoph Hellwig wrote:
> On Tue, Jul 18, 2017 at 01:32:32PM +0800, Eryu Guan wrote:
> > Array size of mnt3_counts should be the size of array
> > mnt3_procedures, not mnt_procedures, though they're same in size
> > right now. Found this by code inspection.
> > 
> > Fixes: 1c5876ddbdb4 ("sunrpc: move p_count out of struct rpc_procinfo")
> > Cc: Christoph Hellwig <hch@lst.de>
> > Signed-off-by: Eryu Guan <eguan@redhat.com>
> 
> Oops, yes.
> 
> Looks good:
> 
> Reviewed-by: Christoph Hellwig <hch@lst.de>

Thanks, I'm assuming Anna gets this.

--b.
