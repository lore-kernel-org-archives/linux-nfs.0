Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail.candelatech.com ([208.74.158.172]:39850 "EHLO
	ns3.lanforge.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752783Ab3AUUqe (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 21 Jan 2013 15:46:34 -0500
From: greearb@candelatech.com
To: linux-nfs@vger.kernel.org
Cc: Ben Greear <greearb@candelatech.com>
Subject: [RFC 02/13] nfs: Two AF_UNSPEC addresses should always match each other.
Date: Mon, 21 Jan 2013 12:45:48 -0800
Message-Id: <1358801159-18829-3-git-send-email-greearb@candelatech.com>
In-Reply-To: <1358801159-18829-1-git-send-email-greearb@candelatech.com>
References: <1358801159-18829-1-git-send-email-greearb@candelatech.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

From: Ben Greear <greearb@candelatech.com>

Signed-off-by: Ben Greear <greearb@candelatech.com>
---
 fs/nfs/client.c |    2 ++
 1 files changed, 2 insertions(+), 0 deletions(-)

diff --git a/fs/nfs/client.c b/fs/nfs/client.c
index 5e8d24d..809fd1e 100644
--- a/fs/nfs/client.c
+++ b/fs/nfs/client.c
@@ -369,6 +369,8 @@ int nfs_sockaddr_match_ipaddr(const struct sockaddr *sa1,
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

