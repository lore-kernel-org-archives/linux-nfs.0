From: Chuck Lever <chuck.lever@oracle.com>
Subject: [PATCH 1/6] mount: Fix a bug in the legacy version of
	nfs_name_to_address()
Date: Fri, 27 Feb 2009 15:05:11 -0500
Message-ID: <20090227200511.11301.33720.stgit@ingres.1015granger.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Cc: linux-nfs@vger.kernel.org
To: steved@redhat.com
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from rcsinet13.oracle.com ([148.87.113.125]:50988 "EHLO
	rgminet13.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755446AbZB0UGx (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Fri, 27 Feb 2009 15:06:53 -0500
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

The legacy version of nfs_name_to_address() returned an incorrect
value for the size of the returned address.

Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
---

 utils/mount/network.c |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/utils/mount/network.c b/utils/mount/network.c
index 92f75b4..b41388e 100644
--- a/utils/mount/network.c
+++ b/utils/mount/network.c
@@ -291,7 +291,7 @@ int nfs_name_to_address(const char *hostname,
 	}
 
 	memcpy(&sin->sin_addr, hp->h_addr, hp->h_length);
-	*salen = hp->h_length;
+	*salen = sizeof(struct sockaddr_in);
 	return 1;
 }
 #endif	/* HAVE_DECL_AI_ADDRCONFIG */

