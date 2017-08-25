Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-pg0-f65.google.com ([74.125.83.65]:33915 "EHLO
        mail-pg0-f65.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1756575AbdHYOWK (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Fri, 25 Aug 2017 10:22:10 -0400
From: Bhumika Goyal <bhumirks@gmail.com>
To: julia.lawall@lip6.fr, marcel@holtmann.org, gustavo@padovan.org,
        johan.hedberg@gmail.com, davem@davemloft.net, pablo@netfilter.org,
        kadlec@blackhole.kfki.hu, fw@strlen.de, stephen@networkplumber.org,
        alex.aring@gmail.com, stefan@osg.samsung.com, kuznet@ms2.inr.ac.ru,
        yoshfuji@linux-ipv6.org, santosh.shilimkar@oracle.com,
        trond.myklebust@primarydata.com, anna.schumaker@netapp.com,
        bfields@fieldses.org, jlayton@poochiereds.net,
        linux-bluetooth@vger.kernel.org, netdev@vger.kernel.org,
        linux-kernel@vger.kernel.org, netfilter-devel@vger.kernel.org,
        coreteam@netfilter.org, bridge@lists.linux-foundation.org,
        linux-wpan@vger.kernel.org, linux-rdma@vger.kernel.org,
        rds-devel@oss.oracle.com, linux-nfs@vger.kernel.org
Cc: Bhumika Goyal <bhumirks@gmail.com>
Subject: [PATCH 0/7] net: make some structures const
Date: Fri, 25 Aug 2017 19:51:40 +0530
Message-Id: <1503670907-23221-1-git-send-email-bhumirks@gmail.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Make these const as they are not modified.

Bhumika Goyal (7):
  Bluetooth: 6lowpan: make header_ops const
  bridge: make ebt_table const
  ieee802154: 6lowpan: make header_ops const
  ipv4: make net_protocol const
  RDS: make rhashtable_params const
  netfilter: nat: make rhashtable_params const
  SUNRPC: make kvec const

 net/bluetooth/6lowpan.c            | 2 +-
 net/bridge/netfilter/ebtable_nat.c | 2 +-
 net/ieee802154/6lowpan/core.c      | 2 +-
 net/ipv4/af_inet.c                 | 4 ++--
 net/netfilter/nf_nat_core.c        | 2 +-
 net/rds/bind.c                     | 2 +-
 net/sunrpc/xdr.c                   | 2 +-
 7 files changed, 8 insertions(+), 8 deletions(-)

-- 
1.9.1

