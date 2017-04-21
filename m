Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from bombadil.infradead.org ([65.50.211.133]:37653 "EHLO
        bombadil.infradead.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1037958AbdDUKuq (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Fri, 21 Apr 2017 06:50:46 -0400
Date: Fri, 21 Apr 2017 03:50:38 -0700
From: Christoph Hellwig <hch@infradead.org>
To: Valentin Rothberg <valentinrothberg@gmail.com>
Cc: Christoph Hellwig <hch@lst.de>, ooo@electrozaur.com,
        martin.petersen@oracle.com, trond.myklebust@primarydata.com,
        axboe@kernel.dk, osd-dev@open-osd.org, linux-nfs@vger.kernel.org,
        linux-scsi@vger.kernel.org, linux-block@vger.kernel.org,
        LKML <linux-kernel@vger.kernel.org>
Subject: Re: [PATCH 3/4] nfs: remove the objlayout driver
Message-ID: <20170421105038.GA28396@infradead.org>
References: <20170412160109.10598-1-hch@lst.de>
 <20170412160109.10598-4-hch@lst.de>
 <CAD3Xx4+79ryvNDtB4F1v-9TxQe8sTxYKeysCGqWuUYG8Ca=Yxg@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <CAD3Xx4+79ryvNDtB4F1v-9TxQe8sTxYKeysCGqWuUYG8Ca=Yxg@mail.gmail.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Fri, Apr 21, 2017 at 09:27:11AM +0200, Valentin Rothberg wrote:
> Hi Christoph,
> 
> I just came across this patch in linux-next commit 6d22323b2e9f.
> scripts/checkkconfigsymbols.py reports that there is a leftover
> reference on PNFS_OBJLAYOUT in fs/exofs/Kconfig.ore line 10 (depends
> on EXOFS_FS || PNFS_OBJLAYOUT). I assume that this reference can
> safely be removed now? If you want to I can send a trivial patch
> removing it.

Yes, please do.
