Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-iw0-f174.google.com ([209.85.214.174]:38170 "EHLO
	mail-iw0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752621Ab0JKAGN (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Sun, 10 Oct 2010 20:06:13 -0400
Received: by mail-iw0-f174.google.com with SMTP id 6so2668490iwn.19
        for <linux-nfs@vger.kernel.org>; Sun, 10 Oct 2010 17:06:13 -0700 (PDT)
From: Chuck Lever <chuck.lever@oracle.com>
Subject: [PATCH 13/15] mount.nfs: mountproto does not support RDMA
To: steved@redhat.com
Cc: linux-nfs@vger.kernel.org
Date: Sun, 10 Oct 2010 20:06:10 -0400
Message-ID: <20101011000610.6667.50921.stgit@ellison.1015granger.net>
In-Reply-To: <20101010234836.6667.4057.stgit@ellison.1015granger.net>
References: <20101010234836.6667.4057.stgit@ellison.1015granger.net>
Content-Type: text/plain; charset="utf-8"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

Clean up.  Our client does not support the MNT protocol on RDMA.

nfs_mount_protocol() isn't invoked for RDMA mounts (they are shunted
off before nfs_options2pmap() is invoked).  But in case it ever is,
it should return the expected response.

Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
---

 utils/mount/network.c |    6 +++++-
 1 files changed, 5 insertions(+), 1 deletions(-)

diff --git a/utils/mount/network.c b/utils/mount/network.c
index 62973cf..1ebaced 100644
--- a/utils/mount/network.c
+++ b/utils/mount/network.c
@@ -1521,7 +1521,11 @@ nfs_mount_protocol(struct mount_options *options, unsigned long *protocol)
 	 * set @protocol to zero.  The pmap protocol value will
 	 * be filled in later by an rpcbind query in this case.
 	 */
-	return nfs_nfs_protocol(options, protocol);
+	if (!nfs_nfs_protocol(options, protocol))
+		return 0;
+	if (*protocol == NFSPROTO_RDMA)
+		*protocol = IPPROTO_TCP;
+	return 1;
 }
 
 /*

