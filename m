From: Benny Halevy <bhalevy@panasas.com>
Subject: [PATCH v2 04/47] nfs41: common protocol definitions
Date: Sat, 28 Mar 2009 11:31:01 +0300
Message-ID: <1238229061-8176-1-git-send-email-bhalevy@panasas.com>
References: <49CDDFC2.4070402@panasas.com>
Cc: linux-nfs@vger.kernel.org, pnfs@linux-nfs.org
To: " J. Bruce Fields" <bfields@fieldses.org>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from gw-ca.panasas.com ([209.116.51.66]:15550 "EHLO
	laguna.int.panasas.com" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1754194AbZC1IbG (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Sat, 28 Mar 2009 04:31:06 -0400
In-Reply-To: <49CDDFC2.4070402@panasas.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Define all NFSv4.1 common operation and error code constants.

Note that some of the definitions are used by both the nfs41 client
and the server code. This patch is duplicated in the nfs41 and nfsd41
sessions patchset.

Signed-off-by: Andy Adamson<andros@netapp.com>
Signed-off-by: Benny Halevy <bhalevy@panasas.com>
[nfs41: add exchange id flags]
Signed-off-by: Mike Sager <sager@netapp.com>
Signed-off-by: Benny Halevy <bhalevy@panasas.com>
[removed server-only hunk changing NFSERR_REPLAY_ME]
Signed-off-by: Benny Halevy <bhalevy@panasas.com>
[nfs41: add SEQ4_XX to nfs41-common-protocol]
Signed-off-by: Andy Adamson <andros@netapp.com>
Signed-off-by: Benny Halevy <bhalevy@panasas.com>
[nfs41: generic error code update]
Signed-off-by: Benny Halevy <bhalevy@panasas.com>
---
 include/linux/nfs4.h |  128 +++++++++++++++++++++++++++++++++++++++++++++++++-
 1 files changed, 127 insertions(+), 1 deletions(-)

diff --git a/include/linux/nfs4.h b/include/linux/nfs4.h
index b912311..a34683e 100644
--- a/include/linux/nfs4.h
+++ b/include/linux/nfs4.h
@@ -21,6 +21,7 @@
 #define NFS4_FHSIZE		128
 #define NFS4_MAXPATHLEN		PATH_MAX
 #define NFS4_MAXNAMLEN		NAME_MAX
+#define NFS4_MAX_SESSIONID_LEN	16
 
 #define NFS4_ACCESS_READ        0x0001
 #define NFS4_ACCESS_LOOKUP      0x0002
@@ -38,6 +39,7 @@
 #define NFS4_OPEN_RESULT_CONFIRM 0x0002
 #define NFS4_OPEN_RESULT_LOCKTYPE_POSIX 0x0004
 
+#define NFS4_SHARE_ACCESS_MASK	0x000F
 #define NFS4_SHARE_ACCESS_READ	0x0001
 #define NFS4_SHARE_ACCESS_WRITE	0x0002
 #define NFS4_SHARE_ACCESS_BOTH	0x0003
@@ -45,6 +47,19 @@
 #define NFS4_SHARE_DENY_WRITE	0x0002
 #define NFS4_SHARE_DENY_BOTH	0x0003
 
+/* nfs41 */
+#define NFS4_SHARE_WANT_MASK		0xFF00
+#define NFS4_SHARE_WANT_NO_PREFERENCE	0x0000
+#define NFS4_SHARE_WANT_READ_DELEG	0x0100
+#define NFS4_SHARE_WANT_WRITE_DELEG	0x0200
+#define NFS4_SHARE_WANT_ANY_DELEG	0x0300
+#define NFS4_SHARE_WANT_NO_DELEG	0x0400
+#define NFS4_SHARE_WANT_CANCEL		0x0500
+
+#define NFS4_SHARE_WHEN_MASK		0xF0000
+#define NFS4_SHARE_SIGNAL_DELEG_WHEN_RESRC_AVAIL	0x10000
+#define NFS4_SHARE_PUSH_DELEG_WHEN_UNCONTENDED		0x20000
+
 #define NFS4_SET_TO_SERVER_TIME	0
 #define NFS4_SET_TO_CLIENT_TIME	1
 
@@ -88,6 +103,31 @@
 #define NFS4_ACE_GENERIC_EXECUTE              0x001200A0
 #define NFS4_ACE_MASK_ALL                     0x001F01FF
 
+#define EXCHGID4_FLAG_SUPP_MOVED_REFER		0x00000001
+#define EXCHGID4_FLAG_SUPP_MOVED_MIGR		0x00000002
+#define EXCHGID4_FLAG_USE_NON_PNFS		0x00010000
+#define EXCHGID4_FLAG_USE_PNFS_MDS		0x00020000
+#define EXCHGID4_FLAG_USE_PNFS_DS		0x00040000
+#define EXCHGID4_FLAG_UPD_CONFIRMED_REC_A	0x40000000
+#define EXCHGID4_FLAG_CONFIRMED_R		0x80000000
+/*
+ * Since the validity of these bits depends on whether
+ * they're set in the argument or response, have separate
+ * invalid flag masks for arg (_A) and resp (_R).
+ */
+#define EXCHGID4_INVAL_FLAG_MASK_A		0xBFF8FFFC
+#define EXCHGID4_INVAL_FLAG_MASK_R		0x7FF8FFFC
+
+#define SEQ4_STATUS_CB_PATH_DOWN		0x00000001
+#define SEQ4_STATUS_CB_GSS_CONTEXTS_EXPIRING	0x00000002
+#define SEQ4_STATUS_CB_GSS_CONTEXTS_EXPIRED	0x00000004
+#define SEQ4_STATUS_EXPIRED_ALL_STATE_REVOKED	0x00000008
+#define SEQ4_STATUS_EXPIRED_SOME_STATE_REVOKED	0x00000010
+#define SEQ4_STATUS_ADMIN_STATE_REVOKED		0x00000020
+#define SEQ4_STATUS_RECALLABLE_STATE_REVOKED	0x00000040
+#define SEQ4_STATUS_LEASE_MOVED			0x00000080
+#define SEQ4_STATUS_RESTART_RECLAIM_NEEDED	0x00000100
+
 #define NFS4_MAX_UINT64	(~(u64)0)
 
 enum nfs4_acl_whotype {
@@ -154,6 +194,28 @@ enum nfs_opnum4 {
 	OP_VERIFY = 37,
 	OP_WRITE = 38,
 	OP_RELEASE_LOCKOWNER = 39,
+
+	/* nfs41 */
+	OP_BACKCHANNEL_CTL = 40,
+	OP_BIND_CONN_TO_SESSION = 41,
+	OP_EXCHANGE_ID = 42,
+	OP_CREATE_SESSION = 43,
+	OP_DESTROY_SESSION = 44,
+	OP_FREE_STATEID = 45,
+	OP_GET_DIR_DELEGATION = 46,
+	OP_GETDEVICEINFO = 47,
+	OP_GETDEVICELIST = 48,
+	OP_LAYOUTCOMMIT = 49,
+	OP_LAYOUTGET = 50,
+	OP_LAYOUTRETURN = 51,
+	OP_SECINFO_NO_NAME = 52,
+	OP_SEQUENCE = 53,
+	OP_SET_SSV = 54,
+	OP_TEST_STATEID = 55,
+	OP_WANT_DELEGATION = 56,
+	OP_DESTROY_CLIENTID = 57,
+	OP_RECLAIM_COMPLETE = 58,
+
 	OP_ILLEGAL = 10044,
 };
 
@@ -230,7 +292,48 @@ enum nfsstat4 {
 	NFS4ERR_DEADLOCK = 10045,
 	NFS4ERR_FILE_OPEN = 10046,
 	NFS4ERR_ADMIN_REVOKED = 10047,
-	NFS4ERR_CB_PATH_DOWN = 10048
+	NFS4ERR_CB_PATH_DOWN = 10048,
+
+	/* nfs41 */
+	NFS4ERR_BADIOMODE	= 10049,
+	NFS4ERR_BADLAYOUT	= 10050,
+	NFS4ERR_BAD_SESSION_DIGEST = 10051,
+	NFS4ERR_BADSESSION	= 10052,
+	NFS4ERR_BADSLOT		= 10053,
+	NFS4ERR_COMPLETE_ALREADY = 10054,
+	NFS4ERR_CONN_NOT_BOUND_TO_SESSION = 10055,
+	NFS4ERR_DELEG_ALREADY_WANTED = 10056,
+	NFS4ERR_BACK_CHAN_BUSY	= 10057,	/* backchan reqs outstanding */
+	NFS4ERR_LAYOUTTRYLATER	= 10058,
+	NFS4ERR_LAYOUTUNAVAILABLE = 10059,
+	NFS4ERR_NOMATCHING_LAYOUT = 10060,
+	NFS4ERR_RECALLCONFLICT	= 10061,
+	NFS4ERR_UNKNOWN_LAYOUTTYPE = 10062,
+	NFS4ERR_SEQ_MISORDERED = 10063, 	/* unexpected seq.id in req */
+	NFS4ERR_SEQUENCE_POS	= 10064,	/* [CB_]SEQ. op not 1st op */
+	NFS4ERR_REQ_TOO_BIG	= 10065,	/* request too big */
+	NFS4ERR_REP_TOO_BIG	= 10066,	/* reply too big */
+	NFS4ERR_REP_TOO_BIG_TO_CACHE = 10067,	/* rep. not all cached */
+	NFS4ERR_RETRY_UNCACHED_REP = 10068,	/* retry & rep. uncached */
+	NFS4ERR_UNSAFE_COMPOUND = 10069,	/* retry/recovery too hard */
+	NFS4ERR_TOO_MANY_OPS	= 10070,	/* too many ops in [CB_]COMP */
+	NFS4ERR_OP_NOT_IN_SESSION = 10071,	/* op needs [CB_]SEQ. op */
+	NFS4ERR_HASH_ALG_UNSUPP = 10072,	/* hash alg. not supp. */
+						/* Error 10073 is unused. */
+	NFS4ERR_CLIENTID_BUSY	= 10074,	/* clientid has state */
+	NFS4ERR_PNFS_IO_HOLE	= 10075,	/* IO to _SPARSE file hole */
+	NFS4ERR_SEQ_FALSE_RETRY	= 10076,	/* retry not origional */
+	NFS4ERR_BAD_HIGH_SLOT	= 10077,	/* sequence arg bad */
+	NFS4ERR_DEADSESSION	= 10078,	/* persistent session dead */
+	NFS4ERR_ENCR_ALG_UNSUPP = 10079,	/* SSV alg mismatch */
+	NFS4ERR_PNFS_NO_LAYOUT	= 10080,	/* direct I/O with no layout */
+	NFS4ERR_NOT_ONLY_OP	= 10081,	/* bad compound */
+	NFS4ERR_WRONG_CRED	= 10082,	/* permissions:state change */
+	NFS4ERR_WRONG_TYPE	= 10083,	/* current operation mismatch */
+	NFS4ERR_DIRDELEG_UNAVAIL = 10084,	/* no directory delegation */
+	NFS4ERR_REJECT_DELEG	= 10085,	/* on callback */
+	NFS4ERR_RETURNCONFLICT	= 10086,	/* outstanding layoutreturn */
+	NFS4ERR_DELEG_REVOKED	= 10087,	/* deleg./layout revoked */
 };
 
 /*
@@ -391,6 +494,29 @@ enum {
 	NFSPROC4_CLNT_GETACL,
 	NFSPROC4_CLNT_SETACL,
 	NFSPROC4_CLNT_FS_LOCATIONS,
+
+	/* nfs41 */
+	NFSPROC4_CLNT_EXCHANGE_ID,
+	NFSPROC4_CLNT_CREATE_SESSION,
+	NFSPROC4_CLNT_DESTROY_SESSION,
+	NFSPROC4_CLNT_SEQUENCE,
+	NFSPROC4_CLNT_GET_LEASE_TIME,
+};
+
+/* nfs41 types */
+struct nfs4_sessionid {
+	unsigned char data[NFS4_MAX_SESSIONID_LEN];
+};
+
+/* Create Session Flags */
+#define SESSION4_PERSIST	 0x001
+#define SESSION4_BACK_CHAN 	 0x002
+#define SESSION4_RDMA		 0x004
+
+enum state_protect_how4 {
+	SP4_NONE	= 0,
+	SP4_MACH_CRED	= 1,
+	SP4_SSV		= 2
 };
 
 #endif
-- 
1.6.2.1

