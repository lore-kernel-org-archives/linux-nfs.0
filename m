Return-Path: linux-nfs-owner@vger.kernel.org
Received: from 173-166-109-252-newengland.hfc.comcastbusiness.net ([173.166.109.252]:36397
	"EHLO bombadil.infradead.org" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1757885Ab2KWIWA (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Fri, 23 Nov 2012 03:22:00 -0500
Date: Fri, 23 Nov 2012 03:21:57 -0500
From: Christoph Hellwig <hch@infradead.org>
To: Dave Kleikamp <dave.kleikamp@oracle.com>
Cc: linux-fsdevel@vger.kernel.org, linux-kernel@vger.kernel.org,
        Zach Brown <zab@zabbo.net>,
        "Maxim V. Patlasov" <mpatlasov@parallels.com>,
        Mel Gorman <mgorman@suse.de>,
        Trond Myklebust <Trond.Myklebust@netapp.com>,
        linux-nfs@vger.kernel.org, Rik van Riel <riel@redhat.com>
Subject: Re: [PATCH v4 23/31] nfs: simplify swap
Message-ID: <20121123082157.GC10731@infradead.org>
References: <1353537671-26284-1-git-send-email-dave.kleikamp@oracle.com>
 <1353537671-26284-24-git-send-email-dave.kleikamp@oracle.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <1353537671-26284-24-git-send-email-dave.kleikamp@oracle.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Wed, Nov 21, 2012 at 04:41:03PM -0600, Dave Kleikamp wrote:
> swap_writepage can now call nfs's write_iter f_op, eliminating the need to
> implement for the special-case direct_IO a_op. There is no longer a need to
> pass the uio flag through the direct write path.

This should also kill off the nasty REQ_KERNEL flag.

