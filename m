Return-Path: linux-nfs-owner@vger.kernel.org
Received: from smtp-out-2.desy.de ([131.169.56.85]:57799 "EHLO
	smtp-out-2.desy.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753262Ab1LDMLf (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Sun, 4 Dec 2011 07:11:35 -0500
Received: from smtp-map-2.desy.de (smtp-map-2.desy.de [131.169.56.67])
	by smtp-out-2.desy.de (DESY_OUT_1) with ESMTP id 70A73E3F
	for <linux-nfs@vger.kernel.org>; Sun,  4 Dec 2011 13:02:23 +0100 (MET)
Received: from ZITSWEEP2.win.desy.de (zitsweep2.win.desy.de [131.169.97.96])
	by smtp-map-2.desy.de (DESY_MAP_2) with ESMTP id 663FEE3A
	for <linux-nfs@vger.kernel.org>; Sun,  4 Dec 2011 13:02:23 +0100 (MET)
Received: from smtp-intra-2.desy.de (lb-40-26.desy.de) by ZITSWEEP2.win.desy.de
 (Clearswift SMTPRS 5.4.1) with ESMTP id <Ta11593d13283a961601330@ZITSWEEP2.win.desy.de> for <linux-nfs@vger.kernel.org>;
 Sun, 4 Dec 2011 13:02:23 +0100
From: tigran.mkrtchyan@desy.de
To: linux-nfs@vger.kernel.org
Cc: Tigran Mkrtchyan <tigran.mkrtchyan@desy.de>
Subject: [PATCH 1/2] nfsv41: add current stateid into compound_state
Date: Sun,  4 Dec 2011 13:03:56 +0100
Message-Id: <1323000237-13565-2-git-send-email-tigran.mkrtchyan@desy.de>
In-Reply-To: <1323000237-13565-1-git-send-email-tigran.mkrtchyan@desy.de>
References: <1323000237-13565-1-git-send-email-tigran.mkrtchyan@desy.de>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

From: Tigran Mkrtchyan <tigran.mkrtchyan@desy.de>


Signed-off-by: Tigran Mkrtchyan <tigran.mkrtchyan@desy.de>
---
 fs/nfsd/xdr4.h |    1 +
 1 files changed, 1 insertions(+), 0 deletions(-)

diff --git a/fs/nfsd/xdr4.h b/fs/nfsd/xdr4.h
index 2364747..7f26edd 100644
--- a/fs/nfsd/xdr4.h
+++ b/fs/nfsd/xdr4.h
@@ -54,6 +54,7 @@ struct nfsd4_compound_state {
 	size_t			iovlen;
 	u32			minorversion;
 	u32			status;
+	stateid_t		current_stateid;
 };
 
 static inline bool nfsd4_has_session(struct nfsd4_compound_state *cs)
-- 
1.7.7.3

