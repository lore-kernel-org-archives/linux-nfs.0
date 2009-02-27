From: Chuck Lever <chuck.lever@oracle.com>
Subject: [PATCH 5/6] nfs-utils: Remove fprintf() call from
	support/nfs/getport.c
Date: Fri, 27 Feb 2009 15:05:35 -0500
Message-ID: <20090227200534.11301.15405.stgit@ingres.1015granger.net>
References: <20090227200511.11301.33720.stgit@ingres.1015granger.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Cc: linux-nfs@vger.kernel.org
To: steved@redhat.com
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from rcsinet11.oracle.com ([148.87.113.123]:55976 "EHLO
	rgminet11.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756527AbZB0UHN (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Fri, 27 Feb 2009 15:07:13 -0500
In-Reply-To: <20090227200511.11301.33720.stgit-07a7zB5ZJzbwdl/1UfZZQIVfYA8g3rJ/@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

getport.c is effectively a library, so it should not be emitting messages
via printf.

Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
---

 support/nfs/getport.c |    3 ---
 1 files changed, 0 insertions(+), 3 deletions(-)

diff --git a/support/nfs/getport.c b/support/nfs/getport.c
index 47824a2..bea3c98 100644
--- a/support/nfs/getport.c
+++ b/support/nfs/getport.c
@@ -175,9 +175,6 @@ static void nfs_gp_set_port(struct sockaddr *sap, const in_port_t port)
 	case AF_INET6:
 		sin6->sin6_port = port;
 		break;
-	default:
-		fprintf(stderr, "%s: unrecognized address family\n",
-			__func__);
 	}
 }
 

