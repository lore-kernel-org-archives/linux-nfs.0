Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from coyote.holtmann.net ([212.227.132.17]:39583 "EHLO
        mail.holtmann.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S934093AbdHYQRZ (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Fri, 25 Aug 2017 12:17:25 -0400
Content-Type: text/plain; charset=us-ascii
Mime-Version: 1.0 (Mac OS X Mail 10.3 \(3273\))
Subject: Re: [PATCH 3/7] ieee802154: 6lowpan: make header_ops const
From: Marcel Holtmann <marcel@holtmann.org>
In-Reply-To: <1503670907-23221-4-git-send-email-bhumirks@gmail.com>
Date: Fri, 25 Aug 2017 18:17:21 +0200
Cc: julia.lawall@lip6.fr, "Gustavo F. Padovan" <gustavo@padovan.org>,
        Johan Hedberg <johan.hedberg@gmail.com>,
        "David S. Miller" <davem@davemloft.net>,
        Pablo Neira Ayuso <pablo@netfilter.org>,
        kadlec@blackhole.kfki.hu, Florian Westphal <fw@strlen.de>,
        Stephen Hemminger <stephen@networkplumber.org>,
        Alexander Aring <alex.aring@gmail.com>,
        Stefan Schmidt <stefan@osg.samsung.com>,
        Alexey Kuznetsov <kuznet@ms2.inr.ac.ru>,
        Hideaki YOSHIFUJI <yoshfuji@linux-ipv6.org>,
        santosh.shilimkar@oracle.com, trond.myklebust@primarydata.com,
        anna.schumaker@netapp.com, bfields@fieldses.org,
        jlayton@poochiereds.net,
        "open list:BLUETOOTH DRIVERS" <linux-bluetooth@vger.kernel.org>,
        Network Development <netdev@vger.kernel.org>,
        LKML <linux-kernel@vger.kernel.org>,
        netfilter-devel@vger.kernel.org, coreteam@netfilter.org,
        bridge@lists.linux-foundation.org, linux-wpan@vger.kernel.org,
        linux-rdma@vger.kernel.org, rds-devel@oss.oracle.com,
        linux-nfs@vger.kernel.org
Message-Id: <34C7927D-4D0A-4EB4-AB3E-7DEB9FA7E8B0@holtmann.org>
References: <1503670907-23221-1-git-send-email-bhumirks@gmail.com>
 <1503670907-23221-4-git-send-email-bhumirks@gmail.com>
To: Bhumika Goyal <bhumirks@gmail.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Hi Bhumika,

> Make this const as it is only stored as a reference in a const field of
> a net_device structure.
> 
> Signed-off-by: Bhumika Goyal <bhumirks@gmail.com>
> ---
> net/ieee802154/6lowpan/core.c | 2 +-
> 1 file changed, 1 insertion(+), 1 deletion(-)

patch has been applied to bluetooth-next tree.

Regards

Marcel

