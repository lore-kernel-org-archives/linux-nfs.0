Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([23.128.96.9]:38336 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S2388466AbeGXWUE (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Tue, 24 Jul 2018 18:20:04 -0400
Date: Tue, 24 Jul 2018 14:11:41 -0700 (PDT)
Message-Id: <20180724.141141.740309584672047092.davem@davemloft.net>
To: stephen@networkplumber.org
Cc: ericvh@gmail.com, rminnich@sandia.gov, lucho@ionkov.net,
        ralf@linux-mips.org, jreuter@yaina.de, pablo@netfilter.org,
        kadlec@blackhole.kfki.hu, fw@strlen.de, alex.aring@gmail.com,
        stefan@datenfreihafen.org, kuznet@ms2.inr.ac.ru,
        yoshfuji@linux-ipv6.org, johannes@sipsolutions.net,
        jhs@mojatatu.com, xiyou.wangcong@gmail.com, jiri@resnulli.us,
        vyasevich@gmail.com, nhorman@tuxdriver.com,
        marcelo.leitner@gmail.com, trond.myklebust@hammerspace.com,
        anna.schumaker@netapp.com, steffen.klassert@secunet.com,
        herbert@gondor.apana.org.au, netdev@vger.kernel.org,
        v9fs-developer@lists.sourceforge.net, linux-hams@vger.kernel.org,
        ceph-devel@vger.kernel.org,
        linux-decnet-user@lists.sourceforge.net,
        netfilter-devel@vger.kernel.org, coreteam@netfilter.org,
        linux-wpan@vger.kernel.org, linux-s390@vger.kernel.org,
        linux-wireless@vger.kernel.org, linux-rdma@vger.kernel.org,
        linux-sctp@vger.kernel.org, linux-nfs@vger.kernel.org,
        linux-x25@vger.kernel.org, sthemmin@microsoft.com
Subject: Re: [PATCH PATCH net-next 00/18] net whitespace cleanups
From: David Miller <davem@davemloft.net>
In-Reply-To: <20180724192918.31165-1-sthemmin@microsoft.com>
References: <20180724192918.31165-1-sthemmin@microsoft.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

From: Stephen Hemminger <stephen@networkplumber.org>
Date: Tue, 24 Jul 2018 12:29:00 -0700

> Ran script that I use to check for trailing whitespace and
> blank lines at end of files across all files in net/ directory.
> These are errors that checkpatch reports and git flags.
> 
> These are the resulting fixes broken up mostly by subsystem.

I skipped 9p, ceph, and sunrpc since those don't go via my tree.

I applied the rest because it's mostly small and won't cause too
many conflicts in the future.

Thanks.
