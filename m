Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:35204 "EHLO mx1.redhat.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1751659AbdF3NV6 (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Fri, 30 Jun 2017 09:21:58 -0400
From: Stefan Hajnoczi <stefanha@redhat.com>
To: linux-nfs@vger.kernel.org
Cc: Jeff Layton <jlayton@redhat.com>, Abbas Naderi <abiusx@google.com>,
        Steve Dickson <steved@redhat.com>,
        Stefan Hajnoczi <stefanha@redhat.com>
Subject: [PATCH nfs-utils v2 09/12] exportfs: add AF_VSOCK support to set_addrlist()
Date: Fri, 30 Jun 2017 14:21:17 +0100
Message-Id: <20170630132120.31578-10-stefanha@redhat.com>
In-Reply-To: <20170630132120.31578-1-stefanha@redhat.com>
References: <20170630132120.31578-1-stefanha@redhat.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Let set_addrlist() set AF_VSOCK client addresses.

Signed-off-by: Stefan Hajnoczi <stefanha@redhat.com>
---
 support/include/exportfs.h | 5 +++++
 1 file changed, 5 insertions(+)

diff --git a/support/include/exportfs.h b/support/include/exportfs.h
index 98d45c5..d3d5abc 100644
--- a/support/include/exportfs.h
+++ b/support/include/exportfs.h
@@ -89,6 +89,11 @@ set_addrlist(nfs_client *clp, const int i, const struct sockaddr *sap)
 		memcpy(&clp->m_addrlist[i].s6, sap, sizeof(struct sockaddr_in6));
 		break;
 #endif
+#ifdef AF_VSOCK
+	case AF_VSOCK:
+		memcpy(&clp->m_addrlist[i].svm, sap, sizeof(struct sockaddr_vm));
+		break;
+#endif
 	}
 }
 
-- 
2.9.4

