From: "J. Bruce Fields" <bfields@fieldses.org>
Subject: [PATCH] nfsd: quiet compile warning
Date: Sun,  3 May 2009 14:16:28 -0400
Message-ID: <1241374599-20348-3-git-send-email-bfields@fieldses.org>
References: <1241374599-20348-1-git-send-email-bfields@fieldses.org>
 <1241374599-20348-2-git-send-email-bfields@fieldses.org>
Cc: "J. Bruce Fields" <bfields@citi.umich.edu>
To: linux-nfs@vger.kernel.org
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mail.fieldses.org ([141.211.133.115]:58597 "EHLO
	pickle.fieldses.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753520AbZECSQj (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Sun, 3 May 2009 14:16:39 -0400
In-Reply-To: <1241374599-20348-2-git-send-email-bfields@fieldses.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

From: J. Bruce Fields <bfields@citi.umich.edu>

Stephen Rothwell said:
"Today's linux-next build (powerpc ppc64_defconfig) produced this new
warning:

fs/nfsd/nfs4state.c: In function 'EXPIRED_STATEID':
fs/nfsd/nfs4state.c:2757: warning: comparison of distinct pointer types lacks a cast

Caused by commit 78155ed75f470710f2aecb3e75e3d97107ba8374 ("nfsd4:
distinguish expired from stale stateids")."

Signed-off-by: J. Bruce Fields <bfields@citi.umich.edu>
Reported-by: Stephen Rothwell <sfr@canb.auug.org.au>
---
 fs/nfsd/nfs4state.c |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/fs/nfsd/nfs4state.c b/fs/nfsd/nfs4state.c
index 74e822e..d24dd12 100644
--- a/fs/nfsd/nfs4state.c
+++ b/fs/nfsd/nfs4state.c
@@ -2754,7 +2754,7 @@ EXPIRED_STATEID(stateid_t *stateid)
 {
 	if (time_before((unsigned long)boot_time,
 			((unsigned long)stateid->si_boot)) &&
-	    time_before((stateid->si_boot + lease_time), get_seconds())) {
+	    time_before((unsigned long)(stateid->si_boot + lease_time), get_seconds())) {
 		dprintk("NFSD: expired stateid (%08x/%08x/%08x/%08x)!\n",
 			stateid->si_boot, stateid->si_stateownerid,
 			stateid->si_fileid, stateid->si_generation);
-- 
1.6.0.4

