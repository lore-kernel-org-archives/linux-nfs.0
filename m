Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from aserp1040.oracle.com ([141.146.126.69]:35616 "EHLO
        aserp1040.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S933386AbdHYPeY (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Fri, 25 Aug 2017 11:34:24 -0400
Subject: Re: [PATCH 5/7] RDS: make rhashtable_params const
To: Bhumika Goyal <bhumirks@gmail.com>, julia.lawall@lip6.fr,
        marcel@holtmann.org, gustavo@padovan.org, johan.hedberg@gmail.com,
        davem@davemloft.net, pablo@netfilter.org, kadlec@blackhole.kfki.hu,
        fw@strlen.de, stephen@networkplumber.org, alex.aring@gmail.com,
        stefan@osg.samsung.com, kuznet@ms2.inr.ac.ru,
        yoshfuji@linux-ipv6.org, trond.myklebust@primarydata.com,
        anna.schumaker@netapp.com, bfields@fieldses.org,
        jlayton@poochiereds.net, linux-bluetooth@vger.kernel.org,
        netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
        netfilter-devel@vger.kernel.org, coreteam@netfilter.org,
        bridge@lists.linux-foundation.org, linux-wpan@vger.kernel.org,
        linux-rdma@vger.kernel.org, rds-devel@oss.oracle.com,
        linux-nfs@vger.kernel.org
References: <1503670907-23221-1-git-send-email-bhumirks@gmail.com>
 <1503670907-23221-6-git-send-email-bhumirks@gmail.com>
From: Santosh Shilimkar <santosh.shilimkar@oracle.com>
Message-ID: <b3b84569-90d8-4f02-e79d-f7aacc07271a@oracle.com>
Date: Fri, 25 Aug 2017 08:31:36 -0700
MIME-Version: 1.0
In-Reply-To: <1503670907-23221-6-git-send-email-bhumirks@gmail.com>
Content-Type: text/plain; charset=utf-8; format=flowed
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

8/25/2017 7:21 AM, Bhumika Goyal wrote:
> Make this const as it is either used during a copy operation or passed
> to a const argument of the function rhltable_init
> 
> Signed-off-by: Bhumika Goyal <bhumirks@gmail.com>
> ---
Acked-by: Santosh Shilimkar <santosh.shilimkar@oracle.com>
