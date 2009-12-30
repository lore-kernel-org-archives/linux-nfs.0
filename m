From: Benny Halevy <bhalevy@panasas.com>
Subject: [PATCH 1/2] nfsstat: update cltproc4info for 2.6.33
Date: Wed, 30 Dec 2009 16:55:12 +0200
Message-ID: <1262184912-13405-1-git-send-email-bhalevy@panasas.com>
References: <4B3B6981.8030807@panasas.com>
Cc: linux-nfs@vger.kernel.org, pnfs@linux-nfs.org,
	Benny Halevy <bhalevy@panasas.com>
To: Steve Dickson <steved@redhat.com>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from daytona.panasas.com ([67.152.220.89]:65236 "EHLO
	daytona.int.panasas.com" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1752979AbZL3OzQ (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Wed, 30 Dec 2009 09:55:16 -0500
In-Reply-To: <4B3B6981.8030807@panasas.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Add recalim_complete to client stats.

Signed-off-by: Benny Halevy <bhalevy@panasas.com>
---
 utils/nfsstat/nfsstat.c |    5 +++--
 1 files changed, 3 insertions(+), 2 deletions(-)

diff --git a/utils/nfsstat/nfsstat.c b/utils/nfsstat/nfsstat.c
index fa46d5d..533b4b5 100644
--- a/utils/nfsstat/nfsstat.c
+++ b/utils/nfsstat/nfsstat.c
@@ -30,7 +30,7 @@ static unsigned int	cltproc2info[20], cltproc2info_old[20];	/* NFSv2 call counts
 static unsigned int	srvproc3info[24], srvproc3info_old[24];	/* NFSv3 call counts ([0] == 22) */
 static unsigned int	cltproc3info[24], cltproc3info_old[24];	/* NFSv3 call counts ([0] == 22) */
 static unsigned int	srvproc4info[4], srvproc4info_old[4];	/* NFSv4 call counts ([0] == 2) */
-static unsigned int	cltproc4info[49], cltproc4info_old[49];	/* NFSv4 call counts ([0] == 35) */
+static unsigned int	cltproc4info[50], cltproc4info_old[50];	/* NFSv4 call counts ([0] == 48) */
 static unsigned int	srvproc4opsinfo[61], srvproc4opsinfo_old[61];	/* NFSv4 call counts ([0] == 40) */
 static unsigned int	srvnetinfo[5], srvnetinfo_old[5];	/* 0  # of received packets
 								 * 1  UDP packets
@@ -93,7 +93,7 @@ static const char *	nfssrvproc4name[2] = {
 	"compound",
 };
 
-static const char *	nfscltproc4name[47] = {
+static const char *	nfscltproc4name[48] = {
 	"null",      "read",      "write",   "commit",      "open",        "open_conf",
 	"open_noat", "open_dgrd", "close",   "setattr",     "fsinfo",      "renew",
 	"setclntid", "confirm",   "lock",
@@ -107,6 +107,7 @@ static const char *	nfscltproc4name[47] = {
 	"destroy_ses",
 	"sequence",
 	"get_lease_t",
+	"reclaim_comp",
 	"layoutget",
 	"layoutcommit",
 	"layoutreturn",
-- 
1.6.5.1

