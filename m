Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail.kernel.org ([198.145.29.136]:51148 "EHLO mail.kernel.org"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1751132AbdALNTT (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Thu, 12 Jan 2017 08:19:19 -0500
Date: Thu, 12 Jan 2017 15:09:30 +0200
From: Leon Romanovsky <leon@kernel.org>
To: Bart Van Assche <bart.vanassche@sandisk.com>
Cc: Doug Ledford <dledford@redhat.com>,
        Latchesar Ionkov <lucho@ionkov.net>, devel@driverdev.osuosl.org,
        linux-nfs@vger.kernel.org, Andreas Dilger <andreas.dilger@intel.com>,
        linux-rdma@vger.kernel.org, netdev@vger.kernel.org,
        Trond Myklebust <trond.myklebust@primarydata.com>,
        linux-kernel@vger.kernel.org, linux-nvme@lists.infradead.org,
        Anna Schumaker <anna.schumaker@netapp.com>,
        Oleg Drokin <oleg.drokin@intel.com>,
        Eric Van Hensbergen <ericvh@gmail.com>, target-devel@vger.kernel.org,
        Ron Minnich <rminnich@sandia.gov>,
        James Simmons <jsimmons@infradead.org>,
        v9fs-developer@lists.sourceforge.net, rds-devel@oss.oracle.com,
        "David S . Miller" <davem@davemloft.net>,
        lustre-devel@lists.lustre.org
Subject: Re: [PATCH 9/9] treewide: Inline ib_dma_map_*() functions
Message-ID: <20170112130930.GH20392@mtr-leonro.local>
References: <20170111005648.14988-1-bart.vanassche@sandisk.com>
 <20170111005648.14988-10-bart.vanassche@sandisk.com>
MIME-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha256;
        protocol="application/pgp-signature"; boundary="sClP8c1IaQxyux9v"
In-Reply-To: <20170111005648.14988-10-bart.vanassche@sandisk.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>


--sClP8c1IaQxyux9v
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline

On Tue, Jan 10, 2017 at 04:56:48PM -0800, Bart Van Assche wrote:
> Almost all changes in this patch except the removal of local variables
> that became superfluous and the actual removal of the ib_dma_map_*()
> functions have been generated as follows:
>
> git grep -lE 'ib_(sg_|)dma_' |
>   xargs -d\\n \
>     sed -i -e 's/\([^[:alnum:]_]\)ib_dma_\([^(]*\)(\&\([^,]\+\),/\1dma_\2(\3.dma_device,/g' \
>            -e 's/\([^[:alnum:]_]\)ib_dma_\([^(]*\)(\([^,]\+\),/\1dma_\2(\3->dma_device,/g' \
> 	   -e 's/ib_sg_dma_\(len\|address\)(\([^,]\+\), /sg_dma_\1(/g'
>
> Signed-off-by: Bart Van Assche <bart.vanassche@sandisk.com>
> Reviewed-by: Christoph Hellwig <hch@lst.de>
> Cc: Andreas Dilger <andreas.dilger@intel.com>
> Cc: Anna Schumaker <anna.schumaker@netapp.com>
> Cc: David S. Miller <davem@davemloft.net>
> Cc: Eric Van Hensbergen <ericvh@gmail.com>
> Cc: James Simmons <jsimmons@infradead.org>
> Cc: Latchesar Ionkov <lucho@ionkov.net>
> Cc: Oleg Drokin <oleg.drokin@intel.com>
> Cc: Ron Minnich <rminnich@sandia.gov>
> Cc: Trond Myklebust <trond.myklebust@primarydata.com>
> Cc: devel@driverdev.osuosl.org
> Cc: linux-nfs@vger.kernel.org
> Cc: linux-nvme@lists.infradead.org
> Cc: linux-rdma@vger.kernel.org
> Cc: lustre-devel@lists.lustre.org
> Cc: netdev@vger.kernel.org
> Cc: rds-devel@oss.oracle.com
> Cc: target-devel@vger.kernel.org
> Cc: v9fs-developer@lists.sourceforge.net
> ---
>  drivers/infiniband/core/mad.c                      |  28 +--
>  drivers/infiniband/core/rw.c                       |  30 ++-
>  drivers/infiniband/core/umem.c                     |   4 +-
>  drivers/infiniband/core/umem_odp.c                 |   6 +-
>  drivers/infiniband/hw/mlx4/cq.c                    |   2 +-
>  drivers/infiniband/hw/mlx4/mad.c                   |  28 +--
>  drivers/infiniband/hw/mlx4/mr.c                    |   4 +-
>  drivers/infiniband/hw/mlx4/qp.c                    |  10 +-
>  drivers/infiniband/hw/mlx5/mr.c                    |   4 +-

For mlx5 and mlx4 parts.
Acked-by: Leon Romanovsky <leonro@mellanox.com>

Thanks

--sClP8c1IaQxyux9v
Content-Type: application/pgp-signature; name="signature.asc"

-----BEGIN PGP SIGNATURE-----

iQIzBAEBCAAdFiEEkhr/r4Op1/04yqaB5GN7iDZyWKcFAlh3gAoACgkQ5GN7iDZy
WKdJaRAAk1BjY9bzuSeACwvxCelkFHUxxrnx6eJEeuDYOG23m7coEX9aWWhglrF+
TMG/bb7ia3EaxGF1WBymxhOEGFCHtU5P0Z1FQjrmzAoSDAC6VtTxpZAw+8pnOCFq
ctIICwzuozoQAmVNiNDCULSxrhjwMTyJmM9T1h5T49SA2xFF360bX6RLUOnxAuce
xeAAb/IuSOOOnZ5ht8Qbk5/fGbawMPIU2zR0Md0cMXIGCQ5KPo0YNUfqBK59zVT+
ln0HSIsImhFQvtIsUhMlQUQRzMkHBD5Zl8440SzYO3wyrw+cJIAFm2DJFRLQuNJv
RucqqFEpGTd9RE4K2di13lfLWAdcEnPBbL+HQum2jT6nKnMJAKSy87Eh6D7FUAqj
2uBVB/wOvy5N0X/E2lrn6rQAr1KzV8RCc8pl7Wjjho+20ksOXWAVsiGaPir4Kibx
BiuRaqhQ9VOENtQdJcoBYgslWUvtx2vB0rL/UmZK2LKcsNlbUciKPS9xVQ9Xu5BW
eBQxcuFq5w3HiFWzSkeY1vGLzfuQbTIUgDUULdG1hnq2LfMxl4HNrnjLzn5dQNln
fXu7SUQ8iIJQjJW9X5WTwPLgBASxV98n2Z6OZaSSgsw7FI4tP4VflXMVwoMENLko
ieMsA7zqrMWpQyZGMCkydw1s2hzHd1mEwKE5ApuBEf5vTIUGs0w=
=jPsm
-----END PGP SIGNATURE-----

--sClP8c1IaQxyux9v--
