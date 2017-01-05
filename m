Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:39512 "EHLO mx1.redhat.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1754221AbdAEVfL (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Thu, 5 Jan 2017 16:35:11 -0500
From: Scott Mayhew <smayhew@redhat.com>
To: bfields@fieldses.org, jlayton@poochiereds.net
Cc: davej@codemonkey.org.uk, linux-nfs@vger.kernel.org
Subject: [PATCH 2/3] lockd: initialize sin6_scope_id in lockd_inet6addr_event()
Date: Thu,  5 Jan 2017 16:34:50 -0500
Message-Id: <1483652091-25508-3-git-send-email-smayhew@redhat.com>
In-Reply-To: <1483652091-25508-1-git-send-email-smayhew@redhat.com>
References: <1483652091-25508-1-git-send-email-smayhew@redhat.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

I noticed this was missing when I was testing with link local addresses.

Signed-off-by: Scott Mayhew <smayhew@redhat.com>
---
 fs/lockd/svc.c | 2 ++
 1 file changed, 2 insertions(+)

diff --git a/fs/lockd/svc.c b/fs/lockd/svc.c
index 1c13dd8..7e4ea3b 100644
--- a/fs/lockd/svc.c
+++ b/fs/lockd/svc.c
@@ -322,6 +322,8 @@ static int lockd_inet6addr_event(struct notifier_block *this,
 		dprintk("lockd_inet6addr_event: removed %pI6\n", &ifa->addr);
 		sin6.sin6_family = AF_INET6;
 		sin6.sin6_addr = ifa->addr;
+		if (ipv6_addr_type(&sin6.sin6_addr) & IPV6_ADDR_LINKLOCAL)
+			sin6.sin6_scope_id = ifa->idev->dev->ifindex;
 		svc_age_temp_xprts_now(nlmsvc_rqst->rq_server,
 			(struct sockaddr *)&sin6);
 	}
-- 
2.7.4

