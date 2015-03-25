Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-wi0-f177.google.com ([209.85.212.177]:37558 "EHLO
	mail-wi0-f177.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752294AbbCYLTN (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Wed, 25 Mar 2015 07:19:13 -0400
Received: by wixw10 with SMTP id w10so33618406wix.0
        for <linux-nfs@vger.kernel.org>; Wed, 25 Mar 2015 04:19:12 -0700 (PDT)
Message-ID: <551299AD.7070702@profitbricks.com>
Date: Wed, 25 Mar 2015 12:19:09 +0100
From: Michael Wang <yun.wang@profitbricks.com>
MIME-Version: 1.0
To: Roland Dreier <roland@kernel.org>, Sean Hefty <sean.hefty@intel.com>,
        Hal Rosenstock <hal.rosenstock@gmail.com>, linux-rdma@vger.kernel.org,
        linux-kernel@vger.kernel.org, linux-nfs@vger.kernel.org,
        netdev@vger.kernel.org, Ira Weiny <ira.weiny@intel.com>
CC: "J. Bruce Fields" <bfields@fieldses.org>,
        Trond Myklebust <trond.myklebust@primarydata.com>,
        "David S. Miller" <davem@davemloft.net>,
        Moni Shoua <monis@mellanox.com>,
        PJ Waskiewicz <pj.waskiewicz@solidfire.com>,
        Steve Wise <swise@opengridcomputing.com>,
        Tatyana Nikolova <Tatyana.E.Nikolova@intel.com>,
        Yan Burman <yanb@mellanox.com>,
        Jack Morgenstein <jackm@dev.mellanox.co.il>,
        Yann Droneaud <ydroneaud@opteya.com>,
        Bart Van Assche <bvanassche@acm.org>,
        Colin Ian King <colin.king@canonical.com>,
        Mel Gorman <mgorman@suse.de>, Majd Dibbiny <majd@mellanox.com>,
        Jiri Kosina <jkosina@suse.cz>, Matan Barak <matanb@mellanox.com>,
        Dan Carpenter <dan.carpenter@oracle.com>,
        Eugenia Emantayev <eugenia@mellanox.co.il>,
        Doug Ledford <dledford@redhat.com>,
        Alex Estrin <alex.estrin@intel.com>,
        Erez Shitrit <erezsh@mellanox.com>, Eric Dumazet <edumazet@google.com>,
        Tom Gundersen <teg@jklm.no>, Sagi Grimberg <sagig@mellanox.com>,
        Haggai Eran <haggaie@mellanox.com>,
        Shachar Raindel <raindel@mellanox.com>,
        Mike Marciniszyn <mike.marciniszyn@intel.com>, Tom Tucker <tom@ogc.us>,
        Chuck Lever <chuck.lever@oracle.com>
Subject: Re: [PATCH 1/2] IB/Verbs: Use helpers to refine the checking on transport
 and link layer
References: <55129832.2070707@profitbricks.com>
In-Reply-To: <55129832.2070707@profitbricks.com>
Content-Type: text/plain; charset=utf-8; format=flowed
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

This should be [PATCH 0/2], and my sincerely apologize on the duplicated
mail, the connection is really terrible...

Regards,
Michael Wang

On 03/25/2015 12:12 PM, Michael Wang wrote:
>
> There are too many lengthy code to check the transport type of IB device,
> or the link layer type of it's port, this patch set try to use some 
> helper to
> refine and save us some code.
>
> TODO:
>     Currently we inferred from the transport type and link layer type 
> to identify
>     the way of management, it will be better if we can directly get 
> the indicator
>     from vendor.
>
>     Sean proposed one suggestion:
>  https://www.mail-archive.com/linux-rdma@vger.kernel.org/msg23339.html
>
>     It may need a big work to adapt current implementation to utilize
>     these flags elegantly.
>
>     Also the performance concern on query_port() need to be addressed, 
> may be
>     some new callback like query_mgmt() could works.
>
> Michael Wang (2):
>     [PATCH 1/2] IB/Verbs: Use helpers to check transport and link layer
>     [PATCH 2/2] IB/Verbs: Use helpers to check IBoE technology
>
> ---
>  drivers/infiniband/core/agent.c           |    2 -
>  drivers/infiniband/core/cm.c              |    2 -
>  drivers/infiniband/core/cma.c             |   33 
> ++++++++++++------------------
>  drivers/infiniband/core/mad.c             |    6 ++---
>  drivers/infiniband/core/multicast.c       |   11 +++-------
>  drivers/infiniband/core/sa_query.c        |   14 ++++++------
>  drivers/infiniband/core/ucm.c             |    3 --
>  drivers/infiniband/core/user_mad.c        |    2 -
>  drivers/infiniband/core/verbs.c           |    5 +---
>  drivers/infiniband/hw/mlx4/ah.c           |    2 -
>  drivers/infiniband/hw/mlx4/cq.c           |    4 ---
>  drivers/infiniband/hw/mlx4/mad.c          |   14 +++---------
>  drivers/infiniband/hw/mlx4/main.c         |    8 ++-----
>  drivers/infiniband/hw/mlx4/mlx4_ib.h      |    2 -
>  drivers/infiniband/hw/mlx4/qp.c           |   21 ++++++-------------
>  drivers/infiniband/hw/mlx4/sysfs.c        |    6 +----
>  drivers/infiniband/ulp/ipoib/ipoib_main.c |    6 ++---
>  include/rdma/ib_verbs.h                   |   30 
> +++++++++++++++++++++++++++
>  net/sunrpc/xprtrdma/svc_rdma_recvfrom.c   |    3 --
>  19 files changed, 87 insertions(+), 87 deletions(-)

