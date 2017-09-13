Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:56636 "EHLO mx1.redhat.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1751678AbdIMK1c (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Wed, 13 Sep 2017 06:27:32 -0400
From: Stefan Hajnoczi <stefanha@redhat.com>
To: linux-nfs@vger.kernel.org
Cc: NeilBrown <neilb@suse.com>, Matt Benjamin <mbenjami@redhat.com>,
        Jeff Layton <jlayton@redhat.com>,
        "J . Bruce Fields" <bfields@fieldses.org>,
        Chuck Lever <chuck.lever@oracle.com>,
        Steve Dickson <steved@redhat.com>,
        Stefan Hajnoczi <stefanha@redhat.com>
Subject: [PATCH nfs-utils v3 11/14] exportfs: add AF_VSOCK support to set_addrlist()
Date: Wed, 13 Sep 2017 11:26:47 +0100
Message-Id: <20170913102650.10377-12-stefanha@redhat.com>
In-Reply-To: <20170913102650.10377-1-stefanha@redhat.com>
References: <20170913102650.10377-1-stefanha@redhat.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Let set_addrlist() set AF_VSOCK client addresses.

Signed-off-by: Stefan Hajnoczi <stefanha@redhat.com>
---
 support/include/exportfs.h | 3 +++
 1 file changed, 3 insertions(+)

diff --git a/support/include/exportfs.h b/support/include/exportfs.h
index 98d45c5..e73f74e 100644
--- a/support/include/exportfs.h
+++ b/support/include/exportfs.h
@@ -89,6 +89,9 @@ set_addrlist(nfs_client *clp, const int i, const struct sockaddr *sap)
 		memcpy(&clp->m_addrlist[i].s6, sap, sizeof(struct sockaddr_in6));
 		break;
 #endif
+	case AF_VSOCK:
+		memcpy(&clp->m_addrlist[i].svm, sap, sizeof(struct sockaddr_vm));
+		break;
 	}
 }
 
-- 
2.13.5

