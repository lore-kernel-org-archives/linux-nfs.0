Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-ey0-f174.google.com ([209.85.215.174]:40420 "EHLO
	mail-ey0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751234Ab2AOQR3 (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Sun, 15 Jan 2012 11:17:29 -0500
Received: by eaae11 with SMTP id e11so75329eaa.19
        for <linux-nfs@vger.kernel.org>; Sun, 15 Jan 2012 08:17:28 -0800 (PST)
From: Tigran Mkrtchyan <kofemann@googlemail.com>
To: linux-nfs@vger.kernel.org
Cc: Tigran Mkrtchyan <kofemann@gmail.com>
Subject: [PATH v6 1/9] nfsd4: initialize current stateid at compile time
Date: Sun, 15 Jan 2012 17:20:02 +0100
Message-Id: <1326644410-7482-2-git-send-email-tigran.mkrtchyan@desy.de>
In-Reply-To: <1326644410-7482-1-git-send-email-tigran.mkrtchyan@desy.de>
References: <1326644410-7482-1-git-send-email-tigran.mkrtchyan@desy.de>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

From: Tigran Mkrtchyan <kofemann@gmail.com>


Signed-off-by: Tigran Mkrtchyan <kofemann@gmail.com>
---
 fs/nfsd/nfs4state.c |    6 +++++-
 1 files changed, 5 insertions(+), 1 deletions(-)

diff --git a/fs/nfsd/nfs4state.c b/fs/nfsd/nfs4state.c
index 7355fe4..8ca5ed1 100644
--- a/fs/nfsd/nfs4state.c
+++ b/fs/nfsd/nfs4state.c
@@ -58,11 +58,15 @@ static const stateid_t one_stateid = {
 static const stateid_t zero_stateid = {
 	/* all fields zero */
 };
-
+static const stateid_t currentstateid = {
+	.si_generation = 1,
+};
+ 
 static u64 current_sessionid = 1;
 
 #define ZERO_STATEID(stateid) (!memcmp((stateid), &zero_stateid, sizeof(stateid_t)))
 #define ONE_STATEID(stateid)  (!memcmp((stateid), &one_stateid, sizeof(stateid_t)))
+#define CURRENT_STATEID(stateid) (!memcmp((stateid), &currentstateid, sizeof(stateid_t)))
 
 /* forward declarations */
 static int check_for_locks(struct nfs4_file *filp, struct nfs4_lockowner *lowner);
-- 
1.7.7.5

