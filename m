Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-wm0-f66.google.com ([74.125.82.66]:35971 "EHLO
	mail-wm0-f66.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751748AbcFSKEI (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Sun, 19 Jun 2016 06:04:08 -0400
Subject: Re: [PATCH v2 01/24] mlx4-ib: Use coherent memory for priv pages
To: Chuck Lever <chuck.lever@oracle.com>, leon@kernel.org
References: <20160615030626.14794.43805.stgit@manet.1015granger.net>
 <20160615031525.14794.69066.stgit@manet.1015granger.net>
 <20160615042849.GR5408@leon.nu>
 <68F7CD80-0092-4B55-9FAD-4C54D284BCA3@oracle.com>
 <20160616143518.GX5408@leon.nu> <576315C9.30002@gmail.com>
 <652EBA09-2978-414C-8606-38A96C63365A@oracle.com>
 <20160617092018.GZ5408@leon.nu>
 <4D23496A-FE01-4693-B125-82CD03B8F2D4@oracle.com>
 <20160618105650.GD5408@leon.nu>
 <5D0A6B47-CB71-42DA-AE76-164B6A660ECC@oracle.com>
Cc: linux-rdma <linux-rdma@vger.kernel.org>,
        Linux NFS Mailing List <linux-nfs@vger.kernel.org>
From: Sagi Grimberg <sagigrim@gmail.com>
Message-ID: <57666E14.2070802@gmail.com>
Date: Sun, 19 Jun 2016 13:04:04 +0300
MIME-Version: 1.0
In-Reply-To: <5D0A6B47-CB71-42DA-AE76-164B6A660ECC@oracle.com>
Content-Type: text/plain; charset=windows-1252; format=flowed
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>


> Hi Leon-
>
> I created a different patch, see attachment. It aligns
> the start _and_ end of the DMA mapped region, places
> large arrays so they encounter a page boundary, and
> leaves slack space around each array so there is no
> possibility of a shared DMA cacheline or other activity
> in that memory.
>
> I am able to reproduce the Local Protection Errors with
> this patch applied and SLUB debugging disabled.

Thanks Chuck for proving that the dma alignment is not the issue here.

I suggest that we go with my dma coherent patch for now until Leon and
the Mellanox team can debug this one with the HW/FW folks and find out
what is going on.

Leon, I had my share of debugging this area on mlx4/mlx5 areas. If you
want I can help with debugging this one.
