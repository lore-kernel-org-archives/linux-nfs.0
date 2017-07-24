Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from bombadil.infradead.org ([65.50.211.133]:54474 "EHLO
        bombadil.infradead.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752301AbdGXH6L (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Mon, 24 Jul 2017 03:58:11 -0400
Date: Mon, 24 Jul 2017 00:57:55 -0700
From: Christoph Hellwig <hch@infradead.org>
To: Arnd Bergmann <arnd@arndb.de>
Cc: Trond Myklebust <trond.myklebust@primarydata.com>,
        Anna Schumaker <anna.schumaker@netapp.com>,
        Benjamin Coddington <bcodding@redhat.com>,
        Alexey Dobriyan <adobriyan@gmail.com>,
        Jens Axboe <axboe@fb.com>,
        Andrew Morton <akpm@linux-foundation.org>,
        linux-nfs@vger.kernel.org, linux-kernel@vger.kernel.org
Subject: Re: [PATCH] [RESEND] nfs: blocklayout: avoid warnings on 32-bit
 sector_t
Message-ID: <20170724075755.GA8149@infradead.org>
References: <20170721201547.3358107-1-arnd@arndb.de>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <20170721201547.3358107-1-arnd@arndb.de>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

A 32-bit will also cause run-time problems.  I think the block layout
code should instead grow a

	depends on 64BIT || LBDAF

to ensure we always have a 64-bit sector_t.
