Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-pf1-f193.google.com ([209.85.210.193]:32930 "EHLO
        mail-pf1-f193.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S2388852AbeGXUhi (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Tue, 24 Jul 2018 16:37:38 -0400
Received: by mail-pf1-f193.google.com with SMTP id b17-v6so1082740pfi.0
        for <linux-nfs@vger.kernel.org>; Tue, 24 Jul 2018 12:29:41 -0700 (PDT)
From: Stephen Hemminger <stephen@networkplumber.org>
To: davem@davemloft.net, ericvh@gmail.com, rminnich@sandia.gov,
        lucho@ionkov.net, ralf@linux-mips.org, jreuter@yaina.de,
        pablo@netfilter.org, kadlec@blackhole.kfki.hu, fw@strlen.de,
        alex.aring@gmail.com, stefan@datenfreihafen.org,
        kuznet@ms2.inr.ac.ru, yoshfuji@linux-ipv6.org,
        johannes@sipsolutions.net, jhs@mojatatu.com,
        xiyou.wangcong@gmail.com, jiri@resnulli.us, vyasevich@gmail.com,
        nhorman@tuxdriver.com, marcelo.leitner@gmail.com,
        trond.myklebust@hammerspace.com, anna.schumaker@netapp.com,
        steffen.klassert@secunet.com, herbert@gondor.apana.org.au
Cc: netdev@vger.kernel.org, v9fs-developer@lists.sourceforge.net,
        linux-hams@vger.kernel.org, ceph-devel@vger.kernel.org,
        linux-decnet-user@lists.sourceforge.net,
        netfilter-devel@vger.kernel.org, coreteam@netfilter.org,
        linux-wpan@vger.kernel.org, linux-s390@vger.kernel.org,
        linux-wireless@vger.kernel.org, linux-rdma@vger.kernel.org,
        linux-sctp@vger.kernel.org, linux-nfs@vger.kernel.org,
        linux-x25@vger.kernel.org,
        Stephen Hemminger <sthemmin@microsoft.com>,
        Stephen Hemminger <stephen@networkplumber.org>
Subject: [PATCH PATCH net-next 08/18] sctp: whitespace fixes
Date: Tue, 24 Jul 2018 12:29:08 -0700
Message-Id: <20180724192918.31165-9-sthemmin@microsoft.com>
In-Reply-To: <20180724192918.31165-1-sthemmin@microsoft.com>
References: <20180724192918.31165-1-sthemmin@microsoft.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Remove blank line at EOF and trailing whitespace.

Signed-off-by: Stephen Hemminger <stephen@networkplumber.org>
---
 net/sctp/Kconfig         | 4 ++--
 net/sctp/sm_sideeffect.c | 1 -
 2 files changed, 2 insertions(+), 3 deletions(-)

diff --git a/net/sctp/Kconfig b/net/sctp/Kconfig
index c740b189d4ba..950ecf6e7439 100644
--- a/net/sctp/Kconfig
+++ b/net/sctp/Kconfig
@@ -41,8 +41,8 @@ config SCTP_DBG_OBJCNT
 	bool "SCTP: Debug object counts"
 	depends on PROC_FS
 	help
-	  If you say Y, this will enable debugging support for counting the 
-	  type of objects that are currently allocated.  This is useful for 
+	  If you say Y, this will enable debugging support for counting the
+	  type of objects that are currently allocated.  This is useful for
 	  identifying memory leaks. This debug information can be viewed by
 	  'cat /proc/net/sctp/sctp_dbg_objcnt'
 
diff --git a/net/sctp/sm_sideeffect.c b/net/sctp/sm_sideeffect.c
index 298112ca8c06..85d393090238 100644
--- a/net/sctp/sm_sideeffect.c
+++ b/net/sctp/sm_sideeffect.c
@@ -1827,4 +1827,3 @@ static int sctp_cmd_interpreter(enum sctp_event event_type,
 	error = -ENOMEM;
 	goto out;
 }
-
-- 
2.18.0

