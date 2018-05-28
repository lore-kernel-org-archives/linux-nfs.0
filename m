Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-wr0-f193.google.com ([209.85.128.193]:43658 "EHLO
        mail-wr0-f193.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S940296AbeE1Qo2 (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Mon, 28 May 2018 12:44:28 -0400
Received: by mail-wr0-f193.google.com with SMTP id d2-v6so5736267wrm.10
        for <linux-nfs@vger.kernel.org>; Mon, 28 May 2018 09:44:28 -0700 (PDT)
Date: Mon, 28 May 2018 10:44:17 -0600
From: Jason Gunthorpe <jgg@ziepe.ca>
To: Arnd Bergmann <arnd@arndb.de>
Cc: Doug Ledford <dledford@redhat.com>,
        Keith Busch <keith.busch@intel.com>, Jens Axboe <axboe@fb.com>,
        Christoph Hellwig <hch@lst.de>,
        Sagi Grimberg <sagi@grimberg.me>,
        Oleg Drokin <oleg.drokin@intel.com>,
        Andreas Dilger <andreas.dilger@intel.com>,
        James Simmons <jsimmons@infradead.org>,
        Greg Kroah-Hartman <gregkh@linuxfoundation.org>,
        Steve French <sfrench@samba.org>,
        Eric Van Hensbergen <ericvh@gmail.com>,
        Ron Minnich <rminnich@sandia.gov>,
        Latchesar Ionkov <lucho@ionkov.net>,
        "David S. Miller" <davem@davemloft.net>,
        Santosh Shilimkar <santosh.shilimkar@oracle.com>,
        Trond Myklebust <trond.myklebust@hammerspace.com>,
        Anna Schumaker <anna.schumaker@netapp.com>,
        "J. Bruce Fields" <bfields@fieldses.org>,
        Jeff Layton <jlayton@kernel.org>,
        Greg Thelen <gthelen@google.com>,
        Bart Van Assche <bart.vanassche@wdc.com>,
        linux-rdma@vger.kernel.org, linux-kernel@vger.kernel.org,
        linux-nvme@lists.infradead.org, lustre-devel@lists.lustre.org,
        devel@driverdev.osuosl.org, linux-cifs@vger.kernel.org,
        samba-technical@lists.samba.org,
        v9fs-developer@lists.sourceforge.net, netdev@vger.kernel.org,
        rds-devel@oss.oracle.com, linux-nfs@vger.kernel.org
Subject: Re: [PATCH] IB: Revert "remove redundant INFINIBAND kconfig
 dependencies"
Message-ID: <20180528164417.GA24505@ziepe.ca>
References: <20180525213123.2113748-1-arnd@arndb.de>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <20180525213123.2113748-1-arnd@arndb.de>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Fri, May 25, 2018 at 11:29:59PM +0200, Arnd Bergmann wrote:
> Several subsystems depend on INFINIBAND_ADDR_TRANS, which in turn depends
> on INFINIBAND. However, when with CONFIG_INIFIBAND=m, this leads to a
> link error when another driver using it is built-in. The
> INFINIBAND_ADDR_TRANS dependency is insufficient here as this is
> a 'bool' symbol that does not force anything to be a module in turn.
> 
> fs/cifs/smbdirect.o: In function `smbd_disconnect_rdma_work':
> smbdirect.c:(.text+0x1e4): undefined reference to `rdma_disconnect'
> net/9p/trans_rdma.o: In function `rdma_request':
> trans_rdma.c:(.text+0x7bc): undefined reference to `rdma_disconnect'
> net/9p/trans_rdma.o: In function `rdma_destroy_trans':
> trans_rdma.c:(.text+0x830): undefined reference to `ib_destroy_qp'
> trans_rdma.c:(.text+0x858): undefined reference to `ib_dealloc_pd'
> 
> Fixes: 9533b292a7ac ("IB: remove redundant INFINIBAND kconfig dependencies")
> Signed-off-by: Arnd Bergmann <arnd@arndb.de>
> Acked-by: Greg Thelen <gthelen@google.com>
> ---
> The patch that introduced the problem has been queued in the
> rdma-fixes/for-rc tree. Please revert the patch before sending
> the branch to Linus.
> ---
>  drivers/infiniband/ulp/srpt/Kconfig | 2 +-
>  drivers/nvme/host/Kconfig           | 2 +-
>  drivers/nvme/target/Kconfig         | 2 +-
>  drivers/staging/lustre/lnet/Kconfig | 2 +-
>  fs/cifs/Kconfig                     | 2 +-
>  net/9p/Kconfig                      | 2 +-
>  net/rds/Kconfig                     | 2 +-
>  net/sunrpc/Kconfig                  | 2 +-
>  8 files changed, 8 insertions(+), 8 deletions(-)

Applied to for-rc, thanks

Jason
