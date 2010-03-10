From: Chuck Lever <chuck.lever@oracle.com>
Subject: [PATCH] mount: Mount should retry unreachable hosts
Date: Wed, 10 Mar 2010 16:42:11 -0500
Message-ID: <20100310214136.3002.78499.stgit@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Cc: linux-nfs@vger.kernel.org
To: steved@redhat.com
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from acsinet12.oracle.com ([141.146.126.234]:20390 "EHLO
	acsinet12.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932128Ab0CJVoP (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Wed, 10 Mar 2010 16:44:15 -0500
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Currently if a server is up but not responding (ie, it answers ARP
requests, but not NFS or RPC requests), mount retries or backgrounds
itself waiting for the server.

If the server is not responding on the network at all, mount fails
the mount request immediately.

Users might find it more useful if mount retried in both cases.

Note that this change means attempting to mount using a misspelled
server name will "hang" for the retry amount.  I suppose the error
message isn't very helpful whether it fails immediately or waits
a couple of minutes, though I imagine that an unreachable server is a
much more common occurrence than a misspelling.

Reported-by: Daniel Goering <g_daniel@gmx.net>
Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
---

 utils/mount/stropts.c |    1 +
 1 files changed, 1 insertions(+), 0 deletions(-)

diff --git a/utils/mount/stropts.c b/utils/mount/stropts.c
index 9b8c38f..98557d2 100644
--- a/utils/mount/stropts.c
+++ b/utils/mount/stropts.c
@@ -799,6 +799,7 @@ static int nfs_is_permanent_error(int error)
 	case ESTALE:
 	case ETIMEDOUT:
 	case ECONNREFUSED:
+	case EHOSTUNREACH:
 		return 0;	/* temporary */
 	default:
 		return 1;	/* permanent */

