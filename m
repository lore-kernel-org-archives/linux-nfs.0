Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:45352 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751672AbdH1SaX (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Mon, 28 Aug 2017 14:30:23 -0400
Date: Mon, 28 Aug 2017 11:30:21 -0700 (PDT)
Message-Id: <20170828.113021.1460779644530852597.davem@davemloft.net>
To: bhumirks@gmail.com
Cc: julia.lawall@lip6.fr, marcel@holtmann.org, gustavo@padovan.org,
        johan.hedberg@gmail.com, pablo@netfilter.org,
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
Subject: Re: [PATCH 4/7] ipv4: make net_protocol const
From: David Miller <davem@davemloft.net>
In-Reply-To: <1503670907-23221-5-git-send-email-bhumirks@gmail.com>
References: <1503670907-23221-1-git-send-email-bhumirks@gmail.com>
        <1503670907-23221-5-git-send-email-bhumirks@gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

From: Bhumika Goyal <bhumirks@gmail.com>
Date: Fri, 25 Aug 2017 19:51:44 +0530

> Make these const as they are only passed to a const argument of the
> function inet_add_protocol.
> 
> Signed-off-by: Bhumika Goyal <bhumirks@gmail.com>

Applied.
