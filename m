Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-ob0-f194.google.com ([209.85.214.194]:34798 "EHLO
	mail-ob0-f194.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751292AbcFSTnx (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Sun, 19 Jun 2016 15:43:53 -0400
MIME-Version: 1.0
In-Reply-To: <CAJ3xEMha=i5SaM+fV5XP15Fx6pymrYnvk=a8w+3h1cbBeuVX0A@mail.gmail.com>
References: <20160615030626.14794.43805.stgit@manet.1015granger.net>
 <20160615031525.14794.69066.stgit@manet.1015granger.net> <20160615042849.GR5408@leon.nu>
 <68F7CD80-0092-4B55-9FAD-4C54D284BCA3@oracle.com> <20160616143518.GX5408@leon.nu>
 <576315C9.30002@gmail.com> <652EBA09-2978-414C-8606-38A96C63365A@oracle.com>
 <20160617092018.GZ5408@leon.nu> <4D23496A-FE01-4693-B125-82CD03B8F2D4@oracle.com>
 <20160618105650.GD5408@leon.nu> <5D0A6B47-CB71-42DA-AE76-164B6A660ECC@oracle.com>
 <57666E14.2070802@gmail.com> <CAJ3xEMha=i5SaM+fV5XP15Fx6pymrYnvk=a8w+3h1cbBeuVX0A@mail.gmail.com>
From: Or Gerlitz <gerlitz.or@gmail.com>
Date: Sun, 19 Jun 2016 22:43:51 +0300
Message-ID: <CAJ3xEMg1FdojpWiKKaENQjGnuQzfcQohWcVBDv+ZYGdKvtv1vA@mail.gmail.com>
Subject: Re: [PATCH v2 01/24] mlx4-ib: Use coherent memory for priv pages
To: Sagi Grimberg <sagigrim@gmail.com>, Yishai Hadas <yishaih@mellanox.com>
Cc: Chuck Lever <chuck.lever@oracle.com>, Leon Romanovsky <leon@kernel.org>,
        linux-rdma <linux-rdma@vger.kernel.org>,
        Linux NFS Mailing List <linux-nfs@vger.kernel.org>
Content-Type: text/plain; charset=UTF-8
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Sun, Jun 19, 2016 at 10:38 PM, Or Gerlitz <gerlitz.or@gmail.com> wrote:

> From quick reading of the patch I got the impression that some scheme
> which used to work is now broken, did we get a bisection result
> pointing to the upstream commit which introduce the regression? I
> didn't see such note along the thread, basically, I think this is
> where we should be starting, thoughts? I also added the mlx4 core/IB
> maintainer.

Oh, I missed the 1st post of the thread pointing to commit
1b2cd0fc673c ('IB/mlx4: Support the new memory [...]') -- looking on
the patch, the only thing which is explicitly visible to upper layers
is the setting of ib_dev.map_mr_sg API call. So there's NFS code which
depends on this verb being exported, and if yes, does X else does Y?
