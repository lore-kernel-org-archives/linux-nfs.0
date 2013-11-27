Return-Path: linux-nfs-owner@vger.kernel.org
Received: from smtp-o-3.desy.de ([131.169.56.156]:40112 "EHLO smtp-o-3.desy.de"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752983Ab3K0L6f (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Wed, 27 Nov 2013 06:58:35 -0500
Received: from smtp-map-3.desy.de (smtp-map-3.desy.de [131.169.56.68])
	by smtp-o-3.desy.de (DESY-O-3) with ESMTP id A16CC2802C4
	for <linux-nfs@vger.kernel.org>; Wed, 27 Nov 2013 12:52:19 +0100 (CET)
Received: from ZITSWEEP2.win.desy.de (zitsweep2.win.desy.de [131.169.97.96])
	by smtp-map-3.desy.de (DESY_MAP_3) with ESMTP id 835B012AB
	for <linux-nfs@vger.kernel.org>; Wed, 27 Nov 2013 12:52:18 +0100 (MET)
Received: from smtp-intra-3.desy.de (lb-40-26.desy.de) by ZITSWEEP2.win.desy.de
 (Clearswift SMTPRS 5.5.0) with ESMTP id <Tafa606c81a83a961601168@ZITSWEEP2.win.desy.de> for <linux-nfs@vger.kernel.org>;
 Wed, 27 Nov 2013 12:52:19 +0100
From: Tigran Mkrtchyan <tigran.mkrtchyan@desy.de>
To: linux-nfs@vger.kernel.org
Cc: Tigran Mkrtchyan <tigran.mkrtchyan@desy.de>
Subject: [PATCH] proc: change permission of /proc/self/mountstats to 0644
Date: Wed, 27 Nov 2013 12:52:15 +0100
Message-Id: <1385553135-23131-1-git-send-email-tigran.mkrtchyan@desy.de>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

While working on a ganglia plugin for NFS I run into problem that
/proc/self/mountstats is readable by process owner only. As ganglia
changes collector threads effective uid, it can't access to mountstats
file any more.

The content of mountstats is equal for all processes and can be safely
shared.

Signed-off-by: Tigran Mkrtchyan <tigran.mkrtchyan@desy.de>
---
 fs/proc/base.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/fs/proc/base.c b/fs/proc/base.c
index 03c8d74..d41e284 100644
--- a/fs/proc/base.c
+++ b/fs/proc/base.c
@@ -2607,7 +2607,7 @@ static const struct pid_entry tgid_base_stuff[] = {
 	LNK("exe",        proc_exe_link),
 	REG("mounts",     S_IRUGO, proc_mounts_operations),
 	REG("mountinfo",  S_IRUGO, proc_mountinfo_operations),
-	REG("mountstats", S_IRUSR, proc_mountstats_operations),
+	REG("mountstats", S_IRUGO, proc_mountstats_operations),
 #ifdef CONFIG_PROC_PAGE_MONITOR
 	REG("clear_refs", S_IWUSR, proc_clear_refs_operations),
 	REG("smaps",      S_IRUGO, proc_pid_smaps_operations),
-- 
1.8.4.2

