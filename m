Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from bombadil.infradead.org ([198.137.202.9]:42074 "EHLO
	bombadil.infradead.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750910AbcFVODC (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Wed, 22 Jun 2016 10:03:02 -0400
Subject: Re: [PATCH v3 25/25] IB/mlx4: Workaround for mlx4_alloc_priv_pages()
 array allocator
To: Or Gerlitz <gerlitz.or@gmail.com>
References: <20160620155751.10809.22262.stgit@manet.1015granger.net>
 <20160620161200.10809.45762.stgit@manet.1015granger.net>
 <CAJ3xEMiS+arM2pYkZKSPe8zHZX_OidngCjVmPXpSjhNNf5_q2A@mail.gmail.com>
 <576A92BA.3020703@grimberg.me>
 <CAJ3xEMiWTME0B6rKQKeCZfxK+s5p-mXcKCdThryRz+zU8V7g3g@mail.gmail.com>
Cc: Chuck Lever <chuck.lever@oracle.com>, Yishai Hadas <yishaih@mellanox.com>,
        "linux-rdma@vger.kernel.org" <linux-rdma@vger.kernel.org>,
        "linux-nfs@vger.kernel.org" <linux-nfs@vger.kernel.org>,
        Leon Romanovsky <leonro@mellanox.com>
From: Sagi Grimberg <sagi@grimberg.me>
Message-ID: <576A9A91.90608@grimberg.me>
Date: Wed, 22 Jun 2016 17:02:57 +0300
MIME-Version: 1.0
In-Reply-To: <CAJ3xEMiWTME0B6rKQKeCZfxK+s5p-mXcKCdThryRz+zU8V7g3g@mail.gmail.com>
Content-Type: text/plain; charset=utf-8; format=flowed
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>


>>> Can't the driver advertize smaller quantity for what's occupies later
>>> those last eight bytes (255 or 511 of
>>> attr XX instead of 256 or 512)?
>
>> Not sure I understand your question. Are you suggesting that the driver
>> would expose that it's capable of 256 pages per MR?
>
> I am asking if we can advertize something else what would cause not to
> fall into the last
> eight bytes on a page, e.g if we fall there since we advertize for
> some attr N, lets advertize N-1
>
> just asking

We do advertise 511 pages, but the code still needs an aligned
allocation to avoid the last 8 bytes.
