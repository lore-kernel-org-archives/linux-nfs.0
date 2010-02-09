From: Chuck Lever <chuck.lever@oracle.com>
Subject: [PATCH] statd: Remove SIMU_CRASH warning
Date: Tue, 09 Feb 2010 09:52:36 -0500
Message-ID: <20100209145204.2036.29640.stgit@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Cc: linux-nfs@vger.kernel.org
To: steved@redhat.com
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from rcsinet11.oracle.com ([148.87.113.123]:29113 "EHLO
	rcsinet11.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754551Ab0BIOzn (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Tue, 9 Feb 2010 09:55:43 -0500
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

SM_SIMU_CRASH isn't used, so this warning is never seen today.
However, if we ever wanted to use SM_SIMU_CRASH, this warning
is unnecessarily alarming, and serves no real purpose.

At some point in the near future I'd like us to consider using
SM_SIMU_CRASH, so let's get rid of this message now.

Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
---

 utils/statd/simu.c |    1 -
 1 files changed, 0 insertions(+), 1 deletions(-)

diff --git a/utils/statd/simu.c b/utils/statd/simu.c
index 825e428..f1d0bf8 100644
--- a/utils/statd/simu.c
+++ b/utils/statd/simu.c
@@ -43,7 +43,6 @@ sm_simu_crash_1_svc (__attribute__ ((unused)) void *argp, struct svc_req *rqstp)
     goto failure;
   }
 
-  xlog_warn("*** SIMULATING CRASH! ***");
   my_svc_exit ();
 
   if (rtnl)

