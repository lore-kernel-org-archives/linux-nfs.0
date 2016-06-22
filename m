Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-oi0-f41.google.com ([209.85.218.41]:34950 "EHLO
	mail-oi0-f41.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751671AbcFVNsz (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Wed, 22 Jun 2016 09:48:55 -0400
MIME-Version: 1.0
In-Reply-To: <576A92BA.3020703@grimberg.me>
References: <20160620155751.10809.22262.stgit@manet.1015granger.net>
 <20160620161200.10809.45762.stgit@manet.1015granger.net> <CAJ3xEMiS+arM2pYkZKSPe8zHZX_OidngCjVmPXpSjhNNf5_q2A@mail.gmail.com>
 <576A92BA.3020703@grimberg.me>
From: Or Gerlitz <gerlitz.or@gmail.com>
Date: Wed, 22 Jun 2016 16:47:58 +0300
Message-ID: <CAJ3xEMiWTME0B6rKQKeCZfxK+s5p-mXcKCdThryRz+zU8V7g3g@mail.gmail.com>
Subject: Re: [PATCH v3 25/25] IB/mlx4: Workaround for mlx4_alloc_priv_pages()
 array allocator
To: Sagi Grimberg <sagi@grimberg.me>
Cc: Chuck Lever <chuck.lever@oracle.com>, Yishai Hadas <yishaih@mellanox.com>,
        "linux-rdma@vger.kernel.org" <linux-rdma@vger.kernel.org>,
        "linux-nfs@vger.kernel.org" <linux-nfs@vger.kernel.org>,
        Leon Romanovsky <leonro@mellanox.com>
Content-Type: text/plain; charset=UTF-8
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Wed, Jun 22, 2016 at 4:29 PM, Sagi Grimberg <sagi@grimberg.me> wrote:
>
>>> Ensure the MR's PBL array never occupies the last 8 bytes of a page.
>>> This eliminates random "Local Protection Error" flushes when SLUB
>>> debugging is enabled.
>>>
>>> Fixes: 1b2cd0fc673c ('IB/mlx4: Support the new memory registration API')
>>
>>
>> Can't the driver advertize smaller quantity for what's occupies later
>> those last eight bytes (255 or 511 of
>> attr XX instead of 256 or 512)?

> Not sure I understand your question. Are you suggesting that the driver
> would expose that it's capable of 256 pages per MR?

I am asking if we can advertize something else what would cause not to
fall into the last
eight bytes on a page, e.g if we fall there since we advertize for
some attr N, lets advertize N-1

just asking
