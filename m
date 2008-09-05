From: Chuck Lever <chuck.lever@oracle.com>
Subject: [PATCH 06/19] sm-notify command: getaddrinfo(3) addrinfo leak
Date: Fri, 05 Sep 2008 17:07:30 -0400
Message-ID: <20080905210729.10001.35557.stgit@manray.1015granger.net>
References: <20080905210054.10001.8518.stgit@manray.1015granger.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Cc: neilb@suse.de, linux-nfs@vger.kernel.org
To: steved@redhat.com
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from agminet01.oracle.com ([141.146.126.228]:41182 "EHLO
	agminet01.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752118AbYIEVIH (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Fri, 5 Sep 2008 17:08:07 -0400
In-Reply-To: <20080905210054.10001.8518.stgit-meopP2rzCrTwdl/1UfZZQIVfYA8g3rJ/@public.gmane.org>
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

