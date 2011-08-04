Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:34425 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750837Ab1HDG3w (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Thu, 4 Aug 2011 02:29:52 -0400
Received: from int-mx12.intmail.prod.int.phx2.redhat.com (int-mx12.intmail.prod.int.phx2.redhat.com [10.5.11.25])
	by mx1.redhat.com (8.14.4/8.14.4) with ESMTP id p746TpGC026085
	(version=TLSv1/SSLv3 cipher=DHE-RSA-AES256-SHA bits=256 verify=OK)
	for <linux-nfs@vger.kernel.org>; Thu, 4 Aug 2011 02:29:51 -0400
Received: from ns3.rdu.redhat.com (ns3.rdu.redhat.com [10.11.255.199])
	by int-mx12.intmail.prod.int.phx2.redhat.com (8.14.4/8.14.4) with ESMTP id p746Tpud026110
	for <linux-nfs@vger.kernel.org>; Thu, 4 Aug 2011 02:29:51 -0400
Received: from regina.usersys.redhat.com (dhcp-176-225.mel.redhat.com [10.64.176.225])
	by ns3.rdu.redhat.com (8.13.8/8.13.8) with ESMTP id p746ToGj029498
	for <linux-nfs@vger.kernel.org>; Thu, 4 Aug 2011 02:29:50 -0400
In-Reply-To: <20026.13331.411712.805796@regina.usersys.redhat.com>
References: <20026.13331.411712.805796@regina.usersys.redhat.com>
From: Max Matveev <makc@redhat.com>
Date: Thu, 4 Aug 2011 15:42:26 +1000
Subject: [PATCH] NFS: allow enough time for timeouts to run
To: linux-nfs@vger.kernel.org
Message-Id: <20110804062950.1A7B9813270B@regina.usersys.redhat.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
Content-Type: text/plain
MIME-Version: 1.0

NFS/TCP uses linear backoff when retransmiting requests but
miscalculates the cut-off time for the timeout sequence resulting
in premature major timeouts.

The cutoff should be the sum of first retransmits+1 numbers
multiplied by the timeo, not the retransmits+1 multiplied by
timeo.

Signed-off-by: Max Matveev <makc@redhat.com>
---
 fs/nfs/client.c |    3 ++-
 1 files changed, 2 insertions(+), 1 deletions(-)

diff --git a/fs/nfs/client.c b/fs/nfs/client.c
index 5833fbb..3d12d10 100644
--- a/fs/nfs/client.c
+++ b/fs/nfs/client.c
@@ -604,7 +604,8 @@ static void nfs_init_timeout_values(struct rpc_timeout *to, int proto,
 		if (to->to_initval > NFS_MAX_TCP_TIMEOUT)
 			to->to_initval = NFS_MAX_TCP_TIMEOUT;
 		to->to_increment = to->to_initval;
-		to->to_maxval = to->to_initval + (to->to_increment * to->to_retries);
+		to->to_maxval = (to->to_retries + 1) * (to->to_retries + 2) / 2;
+		to->to_maxval *= to->to_initval;
 		if (to->to_maxval > NFS_MAX_TCP_TIMEOUT)
 			to->to_maxval = NFS_MAX_TCP_TIMEOUT;
 		if (to->to_maxval < to->to_initval)
-- 
1.7.4.4

