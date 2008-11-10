From: Benny Halevy <bhalevy@panasas.com>
Subject: [RFC 06/51] nfsd41: define nfs41 error codes
Date: Mon, 10 Nov 2008 22:42:39 +0200
Message-ID: <1226349759-10318-1-git-send-email-bhalevy@panasas.com>
References: <491895A0.3040809@panasas.com>
Cc: pnfs@linux-nfs.org, linux-nfs@vger.kernel.org
To: " J. Bruce Fields" <bfields@fieldses.org>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from DSL212-235-53-3.bb.netvision.net.il ([212.235.53.3]:57188 "EHLO
	bh-buildlin1.bhalevy.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752143AbYKJUmv (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 10 Nov 2008 15:42:51 -0500
In-Reply-To: <491895A0.3040809@panasas.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

From: Marc Eshel <eshel@almaden.ibm.com>

Signed-off-by: Benny Halevy <bhalevy@panasas.com>
---
 include/linux/nfsd/nfsd.h |   16 ++++++++++++++++
 1 files changed, 16 insertions(+), 0 deletions(-)

diff --git a/include/linux/nfsd/nfsd.h b/include/linux/nfsd/nfsd.h
index 2126940..9703540 100644
--- a/include/linux/nfsd/nfsd.h
+++ b/include/linux/nfsd/nfsd.h
@@ -251,6 +251,22 @@ void		nfsd_lockd_shutdown(void);
 #define	nfserr_locked		__constant_htonl(NFSERR_LOCKED)
 #define	nfserr_wrongsec		__constant_htonl(NFSERR_WRONGSEC)
 #define	nfserr_replay_me	__constant_htonl(NFSERR_REPLAY_ME)
+#define	nfserr_badiomode	__constant_htonl(NFSERR_BADIOMODE)
+#define	nfserr_badlayout	__constant_htonl(NFSERR_BADLAYOUT)
+#define nfserr_bad_session_digest	__constant_htonl(NFSERR_BAD_SESSION_DIGEST)
+#define nfserr_badsession	__constant_htonl(NFSERR_BADSESSION)
+#define nfserr_badslot	__constant_htonl(NFSERR_BADSLOT)
+#define nfserr_complete_already	__constant_htonl(NFSERR_COMPLETE_ALREADY)
+#define nfserr_conn_not_bound_to_session	__constant_htonl(NFSERR_CONN_NOT_BOUND_TO_SESSION)
+#define nfserr_deleg_already_wanted	__constant_htonl(NFSERR_DELEG_ALREADY_WANTED)
+#define nfserr_dirdeleg_unavail	__constant_htonl(NFSERR_DIRDELEG_UNAVAIL)
+#define	nfserr_layouttrylater		__constant_htonl(NFSERR_LAYOUTTRYLATER)
+#define	nfserr_layoutunavailable	__constant_htonl(NFSERR_LAYOUTUNAVAILABLE)
+#define	nfserr_nomatching_layout	__constant_htonl(NFSERR_NOMATCHING_LAYOUT)
+#define nfserr_recallconflict	__constant_htonl(NFSERR_RECALLCONFLICT)
+#define	nfserr_unknown_layouttype	__constant_htonl(NFSERR_UNKNOWN_LAYOUTTYPE)
+#define	nfserr_seq_misordered		__constant_htonl(NFSERR_SEQ_MISORDERED)
+#define nfserr_sequence_pos	__constant_htonl(NFSERR_SEQUENCE_POS)
 
 /* error codes for internal use */
 /* if a request fails due to kmalloc failure, it gets dropped.
-- 
1.6.0.2

