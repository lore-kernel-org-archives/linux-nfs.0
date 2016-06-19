Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from aserp1040.oracle.com ([141.146.126.69]:24255 "EHLO
	aserp1040.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751286AbcFSUCh (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Sun, 19 Jun 2016 16:02:37 -0400
Content-Type: text/plain; charset=us-ascii
Mime-Version: 1.0 (Mac OS X Mail 9.3 \(3124\))
Subject: Re: [PATCH v2 01/24] mlx4-ib: Use coherent memory for priv pages
From: Chuck Lever <chuck.lever@oracle.com>
In-Reply-To: <CAJ3xEMha=i5SaM+fV5XP15Fx6pymrYnvk=a8w+3h1cbBeuVX0A@mail.gmail.com>
Date: Sun, 19 Jun 2016 16:02:23 -0400
Cc: Sagi Grimberg <sagigrim@gmail.com>, Yishai Hadas <yishaih@mellanox.com>,
        Leon Romanovsky <leon@kernel.org>,
        linux-rdma <linux-rdma@vger.kernel.org>,
        Linux NFS Mailing List <linux-nfs@vger.kernel.org>
Message-Id: <B62EEE84-454D-4D55-9C7E-653F564DF381@oracle.com>
References: <20160615030626.14794.43805.stgit@manet.1015granger.net> <20160615031525.14794.69066.stgit@manet.1015granger.net> <20160615042849.GR5408@leon.nu> <68F7CD80-0092-4B55-9FAD-4C54D284BCA3@oracle.com> <20160616143518.GX5408@leon.nu> <576315C9.30002@gmail.com> <652EBA09-2978-414C-8606-38A96C63365A@oracle.com> <20160617092018.GZ5408@leon.nu> <4D23496A-FE01-4693-B125-82CD03B8F2D4@oracle.com> <20160618105650.GD5408@leon.nu> <5D0A6B47-CB71-42DA-AE76-164B6A660ECC@oracle.com> <57666E14.2070802@gmail.com> <CAJ3xEMha=i5SaM+fV5XP15Fx6pymrYnvk=a8w+3h1cbBeuVX0A@mail.gmail.com>
To: Or Gerlitz <gerlitz.or@gmail.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>


> On Jun 19, 2016, at 3:38 PM, Or Gerlitz <gerlitz.or@gmail.com> wrote:
> 
> On Sun, Jun 19, 2016 at 1:04 PM, Sagi Grimberg <sagigrim@gmail.com> wrote:
> 
>>> I am able to reproduce the Local Protection Errors with
>>> this patch applied and SLUB debugging disabled.
> 
>> Thanks Chuck for proving that the dma alignment is not the issue here.
>> 
>> I suggest that we go with my dma coherent patch for now until Leon and
>> the Mellanox team can debug this one with the HW/FW folks and find out
>> what is going on.
>> 
>> Leon, I had my share of debugging this area on mlx4/mlx5 areas. If you
>> want I can help with debugging this one.
> 
> Hi Sagi, Leon and Co,
> 
> From quick reading of the patch I got the impression that some scheme
> which used to work is now broken, did we get a bisection result
> pointing to the upstream commit which introduce the regression?

Fixes: 1b2cd0fc673c ('IB/mlx4: Support the new memory registration API')

The problem was introduced by the new FR API. I reported
this issue back in late April:

  http://marc.info/?l=linux-rdma&m=146194706501705&w=2

and bisected the appearance of symptoms to:

commit d86bd1bece6fc41d59253002db5441fe960a37f6
Author: Joonsoo Kim <iamjoonsoo.kim@lge.com>
Date:   Tue Mar 15 14:55:12 2016 -0700

    mm/slub: support left redzone

The left redzone changes the alignment characteristics
of regions returned by kmalloc. Further diagnosis showed
the problem was with mlx4_alloc_priv_pages(), and the
WR flush occurred only when mr->pages happened to contain
a page boundary.

What we don't understand is why a page boundary in that
array is a problem.


> I
> didn't see such note along the thread, basically, I think this is
> where we should be starting, thoughts? I also added the mlx4 core/IB
> maintainer.

Yishai was notified about this issue on May 25:

http://marc.info/?l=linux-rdma&m=146419192913960&w=2


--
Chuck Lever



