Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from userp1040.oracle.com ([156.151.31.81]:26129 "EHLO
	userp1040.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753172AbcFOQkD (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Wed, 15 Jun 2016 12:40:03 -0400
Content-Type: text/plain; charset=us-ascii
Mime-Version: 1.0 (Mac OS X Mail 9.3 \(3124\))
Subject: Re: [PATCH v2 01/24] mlx4-ib: Use coherent memory for priv pages
From: Chuck Lever <chuck.lever@oracle.com>
In-Reply-To: <20160615042849.GR5408@leon.nu>
Date: Wed, 15 Jun 2016 12:40:07 -0400
Cc: linux-rdma@vger.kernel.org,
        Linux NFS Mailing List <linux-nfs@vger.kernel.org>
Message-Id: <68F7CD80-0092-4B55-9FAD-4C54D284BCA3@oracle.com>
References: <20160615030626.14794.43805.stgit@manet.1015granger.net> <20160615031525.14794.69066.stgit@manet.1015granger.net> <20160615042849.GR5408@leon.nu>
To: leon@kernel.org
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>


> On Jun 15, 2016, at 12:28 AM, Leon Romanovsky <leon@kernel.org> wrote:
> 
> On Tue, Jun 14, 2016 at 11:15:25PM -0400, Chuck Lever wrote:
>> From: Sagi Grimberg <sagi@grimberg.me>
>> 
>> kmalloc doesn't guarantee the returned memory is all on one page.
> 
> IMHO, the patch posted by Christoph at that thread is best way to go,
> because you changed streaming DMA mappings to be coherent DMA mappings [1].
> 
> "The kernel developers recommend the use of streaming mappings over
> coherent mappings whenever possible" [1].
> 
> [1] http://www.makelinux.net/ldd3/chp-15-sect-4

Hi Leon-

I'll happily drop this patch from my 4.8 series as soon
as an official mlx4/mlx5 fix is merged.

Meanwhile, I notice some unexplained instability (driver
resets, list corruption, and so on) when I test NFS/RDMA
without this patch included. So it is attached to the
series for anyone with mlx4 who wants to pull my topic
branch and try it out.


--
Chuck Lever



