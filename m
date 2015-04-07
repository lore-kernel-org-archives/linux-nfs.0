Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-wi0-f177.google.com ([209.85.212.177]:35515 "EHLO
	mail-wi0-f177.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753992AbbDGMsn (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Tue, 7 Apr 2015 08:48:43 -0400
Received: by widdi4 with SMTP id di4so16030842wid.0
        for <linux-nfs@vger.kernel.org>; Tue, 07 Apr 2015 05:48:42 -0700 (PDT)
Message-ID: <5523D227.7000404@profitbricks.com>
Date: Tue, 07 Apr 2015 14:48:39 +0200
From: Michael Wang <yun.wang@profitbricks.com>
MIME-Version: 1.0
To: "ira.weiny" <ira.weiny@intel.com>
CC: Roland Dreier <roland@kernel.org>, Sean Hefty <sean.hefty@intel.com>,
        Hal Rosenstock <hal.rosenstock@gmail.com>, linux-rdma@vger.kernel.org,
        linux-kernel@vger.kernel.org, linux-nfs@vger.kernel.org,
        netdev@vger.kernel.org, "J. Bruce Fields" <bfields@fieldses.org>,
        Trond Myklebust <trond.myklebust@primarydata.com>,
        "David S. Miller" <davem@davemloft.net>,
        Or Gerlitz <ogerlitz@mellanox.com>, Moni Shoua <monis@mellanox.com>,
        PJ Waskiewicz <pj.waskiewicz@solidfire.com>,
        Tatyana Nikolova <Tatyana.E.Nikolova@intel.com>,
        Yan Burman <yanb@mellanox.com>,
        Jack Morgenstein <jackm@dev.mellanox.co.il>,
        Bart Van Assche <bvanassche@acm.org>,
        Yann Droneaud <ydroneaud@opteya.com>,
        Colin Ian King <colin.king@canonical.com>,
        Majd Dibbiny <majd@mellanox.com>, Jiri Kosina <jkosina@suse.cz>,
        Matan Barak <matanb@mellanox.com>, Alex Estrin <alex.estrin@intel.com>,
        Doug Ledford <dledford@redhat.com>, Eric Dumazet <edumazet@google.com>,
        Erez Shitrit <erezsh@mellanox.com>, Sagi Grimberg <sagig@mellanox.com>,
        Haggai Eran <haggaie@mellanox.com>,
        Shachar Raindel <raindel@mellanox.com>,
        Mike Marciniszyn <mike.marciniszyn@intel.com>,
        Steve Wise <swise@opengridcomputing.com>, Tom Tucker <tom@ogc.us>,
        Chuck Lever <chuck.lever@oracle.com>
Subject: Re: [RFC PATCH 00/11] IB/Verbs: IB Management Helpers
References: <551579CA.4030901@profitbricks.com> <20150406202255.GA31445@phlsvsds.ph.intel.com>
In-Reply-To: <20150406202255.GA31445@phlsvsds.ph.intel.com>
Content-Type: text/plain; charset=windows-1252
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>



On 04/06/2015 10:22 PM, ira.weiny wrote:
> On Fri, Mar 27, 2015 at 04:39:54PM +0100, Michael Wang wrote:
>>
>> There are plenty of lengthy code to check the transport type of IB device,
>> or the link layer type of it's port, but actually we are just speculating
>> whether a particular management is supported by the device/port.
> 
> Michael,
> 
> There was a lot of input on this patch series which I believe indicates we
> would like to move forward.  Were you working through another version of the
> series with the suggested changes?

I've sent the v2 which is more complete as a solution IMHO, let's see if it
match the requirements :-)

Regards,
Michael Wang

> 
> Thanks,
> Ira
> 
> 
>>
>> Thus instead of inferring, we should have our own mechanism for
>> IB management capability/protocol checking, several proposals below.
>>
>> This patch set is the pioneer which try to collecting all the cases where
>> a management helper applicable, and put all the speculating logical together,
>> in order to be easily integrated to the new querying mechanism in future.
>>
>> TODO:
>>     The helper in patch 10 and 11 are still to be classified, that is
>>     cap_ib() and cap_eth().
>>
>>     The name/description of each helper may not correct enough, those folks
>>     who are familiar with these particular parts, your suggestion would be
>>     invaluable ;-)
>>
>> Proposals:
>>     Sean:
>>     https://www.mail-archive.com/linux-rdma@vger.kernel.org/msg23339.html
>>     Doug:
>>     https://www.mail-archive.com/linux-rdma@vger.kernel.org/msg23418.html
>>     Jason:
>>     https://www.mail-archive.com/linux-rdma@vger.kernel.org/msg23425.html
>>
>> Michael Wang (11):
>>     [PATCH 01/11] IB/Verbs: Use helpers to check transport and link layer
>>     [RFC PATCH 02/11] IB/Verbs: Use management helper tech_iboe() for iboe-check
>>     [RFC PATCH 03/11] IB/Verbs: Use management helper has_mad() for mad-check
>>     [RFC PATCH 04/11] IB/Verbs: Use management helper cap_smi() for smi-check
>>     [RFC PATCH 05/11] IB/Verbs: Use management helper has_cm() for cm-check
>>     [RFC PATCH 06/11] IB/Verbs: Use management helper has_sa() and cap_sa() for sa-check
>>     [RFC PATCH 07/11] IB/Verbs: Use management helper has_mcast() and cap_mcast() for mcast-check
>>     [RFC PATCH 08/11] IB/Verbs: Use management helper has_iwarp() for iwarp-check
>>     [RFC PATCH 09/11] IB/Verbs: Use management helper has_ipoib() and cap_ipoib() for ipoib-check
>>     [RFC PATCH 10/11] IB/Verbs: Use management helper cap_ib() for ib-check
>>     [RFC PATCH 11/11] IB/Verbs: Use management helper cap_eth() for eth-check
>>
>> ---
>>  drivers/infiniband/core/agent.c           |    6
>>  drivers/infiniband/core/cm.c              |    6
>>  drivers/infiniband/core/cma.c             |   79 ++++------
>>  drivers/infiniband/core/mad.c             |   18 +-
>>  drivers/infiniband/core/multicast.c       |   30 +---
>>  drivers/infiniband/core/sa_query.c        |   42 ++---
>>  drivers/infiniband/core/ucm.c             |    8 -
>>  drivers/infiniband/core/user_mad.c        |    6
>>  drivers/infiniband/core/verbs.c           |   14 -
>>  drivers/infiniband/hw/mlx4/ah.c           |    6
>>  drivers/infiniband/hw/mlx4/cq.c           |   10 -
>>  drivers/infiniband/hw/mlx4/mad.c          |   36 +---
>>  drivers/infiniband/hw/mlx4/main.c         |   23 +--
>>  drivers/infiniband/hw/mlx4/mlx4_ib.h      |    6
>>  drivers/infiniband/hw/mlx4/qp.c           |   57 ++-----
>>  drivers/infiniband/hw/mlx4/sysfs.c        |   16 --
>>  drivers/infiniband/ulp/ipoib/ipoib_main.c |   18 +-
>>  include/rdma/ib_verbs.h                   |  218 ++++++++++++++++++++++++++++++
>>  net/sunrpc/xprtrdma/svc_rdma_recvfrom.c   |    8 -
>>  19 files changed, 381 insertions(+), 226 deletions(-)
>>
