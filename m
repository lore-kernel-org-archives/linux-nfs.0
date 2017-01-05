Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:32878 "EHLO mx1.redhat.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1754254AbdAEVfL (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Thu, 5 Jan 2017 16:35:11 -0500
From: Scott Mayhew <smayhew@redhat.com>
To: bfields@fieldses.org, jlayton@poochiereds.net
Cc: davej@codemonkey.org.uk, linux-nfs@vger.kernel.org
Subject: [PATCH 1/3] nfsd: initialize sin6_scope_id in nfsd_inet6addr_event()
Date: Thu,  5 Jan 2017 16:34:49 -0500
Message-Id: <1483652091-25508-2-git-send-email-smayhew@redhat.com>
In-Reply-To: <1483652091-25508-1-git-send-email-smayhew@redhat.com>
References: <1483652091-25508-1-git-send-email-smayhew@redhat.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

I noticed this was missing when I was testing with link local addresses.

Signed-off-by: Scott Mayhew <smayhew@redhat.com>
---
 fs/nfsd/nfssvc.c | 2 ++
 1 file changed, 2 insertions(+)

diff --git a/fs/nfsd/nfssvc.c b/fs/nfsd/nfssvc.c
index e6bfd96..2e378d0 100644
--- a/fs/nfsd/nfssvc.c
+++ b/fs/nfsd/nfssvc.c
@@ -354,6 +354,8 @@ static int nfsd_inet6addr_event(struct notifier_block *this,
 		dprintk("nfsd_inet6addr_event: removed %pI6\n", &ifa->addr);
 		sin6.sin6_family = AF_INET6;
 		sin6.sin6_addr = ifa->addr;
+		if (ipv6_addr_type(&sin6.sin6_addr) & IPV6_ADDR_LINKLOCAL)
+			sin6.sin6_scope_id = ifa->idev->dev->ifindex;
 		svc_age_temp_xprts_now(nn->nfsd_serv, (struct sockaddr *)&sin6);
 	}
 
-- 
2.7.4

