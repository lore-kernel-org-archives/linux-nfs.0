Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail.candelatech.com ([208.74.158.172]:34518 "EHLO
	ns3.lanforge.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756550Ab1FIXDW (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 9 Jun 2011 19:03:22 -0400
From: greearb@candelatech.com
To: linux-nfs@vger.kernel.org
Cc: Ben Greear <greearb@candelatech.com>
Subject: [RFC 02/11] nfs:  Two AF_UNSPEC addresses should always match each other.
Date: Thu,  9 Jun 2011 16:02:46 -0700
Message-Id: <1307660575-6994-3-git-send-email-greearb@candelatech.com>
In-Reply-To: <1307660575-6994-1-git-send-email-greearb@candelatech.com>
References: <1307660575-6994-1-git-send-email-greearb@candelatech.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
Content-Type: text/plain
MIME-Version: 1.0

From: Ben Greear <greearb@candelatech.com>

Signed-off-by: Ben Greear <greearb@candelatech.com>
---
:100644 100644 b3dc2b8... 8ba7e1a... M	fs/nfs/client.c
 fs/nfs/client.c |    2 ++
 1 files changed, 2 insertions(+), 0 deletions(-)

diff --git a/fs/nfs/client.c b/fs/nfs/client.c
index b3dc2b8..8ba7e1a 100644
--- a/fs/nfs/client.c
+++ b/fs/nfs/client.c
@@ -403,6 +403,8 @@ static int nfs_sockaddr_match_ipaddr(const struct sockaddr *sa1,
 		return nfs_sockaddr_match_ipaddr4(sa1, sa2);
 	case AF_INET6:
 		return nfs_sockaddr_match_ipaddr6(sa1, sa2);
+	case AF_UNSPEC:
+		return 1; /* two UNSPEC addresses match */
 	}
 	return 0;
 }
-- 
1.7.3.4

