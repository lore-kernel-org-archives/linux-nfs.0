Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-ob0-f196.google.com ([209.85.214.196]:33775 "EHLO
	mail-ob0-f196.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751351AbcFSTjC (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Sun, 19 Jun 2016 15:39:02 -0400
MIME-Version: 1.0
In-Reply-To: <57666E14.2070802@gmail.com>
References: <20160615030626.14794.43805.stgit@manet.1015granger.net>
 <20160615031525.14794.69066.stgit@manet.1015granger.net> <20160615042849.GR5408@leon.nu>
 <68F7CD80-0092-4B55-9FAD-4C54D284BCA3@oracle.com> <20160616143518.GX5408@leon.nu>
 <576315C9.30002@gmail.com> <652EBA09-2978-414C-8606-38A96C63365A@oracle.com>
 <20160617092018.GZ5408@leon.nu> <4D23496A-FE01-4693-B125-82CD03B8F2D4@oracle.com>
 <20160618105650.GD5408@leon.nu> <5D0A6B47-CB71-42DA-AE76-164B6A660ECC@oracle.com>
 <57666E14.2070802@gmail.com>
From: Or Gerlitz <gerlitz.or@gmail.com>
Date: Sun, 19 Jun 2016 22:38:53 +0300
Message-ID: <CAJ3xEMha=i5SaM+fV5XP15Fx6pymrYnvk=a8w+3h1cbBeuVX0A@mail.gmail.com>
Subject: Re: [PATCH v2 01/24] mlx4-ib: Use coherent memory for priv pages
To: Sagi Grimberg <sagigrim@gmail.com>, Yishai Hadas <yishaih@mellanox.com>
Cc: Chuck Lever <chuck.lever@oracle.com>, Leon Romanovsky <leon@kernel.org>,
        linux-rdma <linux-rdma@vger.kernel.org>,
        Linux NFS Mailing List <linux-nfs@vger.kernel.org>
Content-Type: text/plain; charset=UTF-8
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Sun, Jun 19, 2016 at 1:04 PM, Sagi Grimberg <sagigrim@gmail.com> wrote:

>> I am able to reproduce the Local Protection Errors with
>> this patch applied and SLUB debugging disabled.

> Thanks Chuck for proving that the dma alignment is not the issue here.
>
> I suggest that we go with my dma coherent patch for now until Leon and
> the Mellanox team can debug this one with the HW/FW folks and find out
> what is going on.
>
> Leon, I had my share of debugging this area on mlx4/mlx5 areas. If you
> want I can help with debugging this one.

Hi Sagi, Leon and Co,
