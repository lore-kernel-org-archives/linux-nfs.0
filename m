Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-ob0-f182.google.com ([209.85.214.182]:35675 "EHLO
	mail-ob0-f182.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754104AbcFUFw7 (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Tue, 21 Jun 2016 01:52:59 -0400
MIME-Version: 1.0
In-Reply-To: <20160620161200.10809.45762.stgit@manet.1015granger.net>
References: <20160620155751.10809.22262.stgit@manet.1015granger.net> <20160620161200.10809.45762.stgit@manet.1015granger.net>
From: Or Gerlitz <gerlitz.or@gmail.com>
Date: Tue, 21 Jun 2016 08:52:45 +0300
Message-ID: <CAJ3xEMiS+arM2pYkZKSPe8zHZX_OidngCjVmPXpSjhNNf5_q2A@mail.gmail.com>
Subject: Re: [PATCH v3 25/25] IB/mlx4: Workaround for mlx4_alloc_priv_pages()
 array allocator
To: Chuck Lever <chuck.lever@oracle.com>, Yishai Hadas <yishaih@mellanox.com>
Cc: "linux-rdma@vger.kernel.org" <linux-rdma@vger.kernel.org>,
        "linux-nfs@vger.kernel.org" <linux-nfs@vger.kernel.org>,
        Leon Romanovsky <leonro@mellanox.com>,
        Sagi Grimberg <sagi@grimberg.me>
Content-Type: text/plain; charset=UTF-8
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Mon, Jun 20, 2016 at 7:12 PM, Chuck Lever <chuck.lever@oracle.com> wrote:
> Ensure the MR's PBL array never occupies the last 8 bytes of a page.
> This eliminates random "Local Protection Error" flushes when SLUB
> debugging is enabled.
>
> Fixes: 1b2cd0fc673c ('IB/mlx4: Support the new memory registration API')

Can't the driver advertize smaller quantity for what's occupies later
those last eight bytes (255 or 511 of
attr XX instead of 256 or 512)?


> Suggested-by: Christoph Hellwig <hch@infradead.org>
> Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
