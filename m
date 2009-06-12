From: Ricardo Labiaga <Ricardo.Labiaga@netapp.com>
Subject: [PATCH 13/14] SQUASHME: Move bc_svc_process() declaration to correct patch
Date: Thu, 11 Jun 2009 22:54:19 -0700
Message-ID: <1244786060-2200-14-git-send-email-Ricardo.Labiaga@netapp.com>
References: <>
 <1244786060-2200-1-git-send-email-Ricardo.Labiaga@netapp.com>
 <1244786060-2200-2-git-send-email-Ricardo.Labiaga@netapp.com>
 <1244786060-2200-3-git-send-email-Ricardo.Labiaga@netapp.com>
 <1244786060-2200-4-git-send-email-Ricardo.Labiaga@netapp.com>
 <1244786060-2200-5-git-send-email-Ricardo.Labiaga@netapp.com>
 <1244786060-2200-6-git-send-email-Ricardo.Labiaga@netapp.com>
 <1244786060-2200-7-git-send-email-Ricardo.Labiaga@netapp.com>
 <1244786060-2200-8-git-send-email-Ricardo.Labiaga@netapp.com>
 <1244786060-2200-9-git-send-email-Ricardo.Labiaga@netapp.com>
 <1244786060-2200-10-git-send-email-Ricardo.Labiaga@netapp.com>
 <1244786060-2200-11-git-send-email-Ricardo.Labiaga@netapp.com>
 <1244786060-2200-12-git-send-email-Ricardo.Labiaga@netapp.com>
 <1244786060-2200-13-git-send-email-Ricardo.Labiaga@netapp.com>
Cc: bhalevy@panasas.com, pnfs@linux-nfs.org, linux-nfs@vger.kernel.org,
	Ricardo Labiaga <Ricardo.Labiaga@netapp.com>
To: trond.myklebust@netapp.com
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mx2.netapp.com ([216.240.18.37]:39089 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754075AbZFLF6M (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Fri, 12 Jun 2009 01:58:12 -0400
In-Reply-To: <1244786060-2200-13-git-send-email-Ricardo.Labiaga@netapp.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

[squash with: nfs41: Backchannel bc_svc_process()]

Signed-off-by: Ricardo Labiaga <Ricardo.Labiaga@netapp.com>
---
 include/linux/sunrpc/svc.h |    2 ++
 1 files changed, 2 insertions(+), 0 deletions(-)

diff --git a/include/linux/sunrpc/svc.h b/include/linux/sunrpc/svc.h
index b8234f2..52e8cb0 100644
--- a/include/linux/sunrpc/svc.h
+++ b/include/linux/sunrpc/svc.h
@@ -418,6 +418,8 @@ int		   svc_set_num_threads(struct svc_serv *, struct svc_pool *, int);
 int		   svc_pool_stats_open(struct svc_serv *serv, struct file *file);
 void		   svc_destroy(struct svc_serv *);
 int		   svc_process(struct svc_rqst *);
+int		   bc_svc_process(struct svc_serv *, struct rpc_rqst *,
+			struct svc_rqst *);
 int		   svc_register(const struct svc_serv *, const int,
 				const unsigned short, const unsigned short);
 
-- 
1.5.4.3

