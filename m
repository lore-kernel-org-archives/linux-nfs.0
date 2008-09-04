From: Chuck Lever <chuck.lever@oracle.com>
Subject: [PATCH 06/16] sm-notify command: getaddrinfo(3) addrinfo leak
Date: Thu, 04 Sep 2008 12:56:25 -0400
Message-ID: <20080904165625.1471.31815.stgit@manray.1015granger.net>
References: <20080904165122.1471.24485.stgit@manray.1015granger.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Cc: neilb@suse.de, linux-nfs@vger.kernel.org
To: steved@redhat.com
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from rgminet01.oracle.com ([148.87.113.118]:48007 "EHLO
	rgminet01.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752958AbYIDQ5U (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 4 Sep 2008 12:57:20 -0400
In-Reply-To: <20080904165122.1471.24485.stgit-meopP2rzCrTwdl/1UfZZQIVfYA8g3rJ/@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Make sure the results of getaddrinfo(3) are properly freed in notify().

Note this is a one-time addrinfo allocation that would be automatically
freed when sm-notify exits anyway, so this is more of a nit than a real
bug fix.

Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
---

 utils/statd/sm-notify.c |    5 ++++-
 1 files changed, 4 insertions(+), 1 deletions(-)

diff --git a/utils/statd/sm-notify.c b/utils/statd/sm-notify.c
index 5a02394..b69f4cc 100644
--- a/utils/statd/sm-notify.c
+++ b/utils/statd/sm-notify.c
@@ -241,8 +241,11 @@ notify(void)
 				opt_srcaddr);
 			exit(1);
 		}
-		memcpy(&local_addr, ai->ai_addr, ai->ai_addrlen);
+
 		/* We know it's IPv4 at this point */
+		memcpy(&local_addr, ai->ai_addr, ai->ai_addrlen);
+
+		freeaddrinfo(ai);
 	}
 
 	/* Use source port if provided on the command line,

