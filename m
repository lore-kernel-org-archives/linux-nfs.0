Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from merlin.infradead.org ([205.233.59.134]:47417 "EHLO
	merlin.infradead.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751138AbcFVN3g (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Wed, 22 Jun 2016 09:29:36 -0400
Subject: Re: [PATCH v3 25/25] IB/mlx4: Workaround for mlx4_alloc_priv_pages()
 array allocator
To: Or Gerlitz <gerlitz.or@gmail.com>, Chuck Lever <chuck.lever@oracle.com>,
        Yishai Hadas <yishaih@mellanox.com>
References: <20160620155751.10809.22262.stgit@manet.1015granger.net>
 <20160620161200.10809.45762.stgit@manet.1015granger.net>
 <CAJ3xEMiS+arM2pYkZKSPe8zHZX_OidngCjVmPXpSjhNNf5_q2A@mail.gmail.com>
Cc: "linux-rdma@vger.kernel.org" <linux-rdma@vger.kernel.org>,
        "linux-nfs@vger.kernel.org" <linux-nfs@vger.kernel.org>,
        Leon Romanovsky <leonro@mellanox.com>
From: Sagi Grimberg <sagi@grimberg.me>
Message-ID: <576A92BA.3020703@grimberg.me>
Date: Wed, 22 Jun 2016 16:29:30 +0300
MIME-Version: 1.0
In-Reply-To: <CAJ3xEMiS+arM2pYkZKSPe8zHZX_OidngCjVmPXpSjhNNf5_q2A@mail.gmail.com>
Content-Type: text/plain; charset=utf-8; format=flowed
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>


>> Ensure the MR's PBL array never occupies the last 8 bytes of a page.
>> This eliminates random "Local Protection Error" flushes when SLUB
>> debugging is enabled.
>>
>> Fixes: 1b2cd0fc673c ('IB/mlx4: Support the new memory registration API')
>
> Can't the driver advertize smaller quantity for what's occupies later
> those last eight bytes (255 or 511 of
> attr XX instead of 256 or 512)?

Not sure I understand your question. Are you suggesting that the driver
would expose that it's capable of 256 pages per MR?
