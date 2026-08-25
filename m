Received: from mx0b-00154904.pphosted.com (mx0b-00154904.pphosted.com [148.163.137.20])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id A8CC6263F5D;
	Tue, 25 Aug 2026 06:52:10 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=148.163.137.20
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1787640732; cv=none; b=sPn9RNOh+eu4h0Uv8+Opo6h0RHvtbuxbT5yb9fs5fakswrlGBhVzTHIZF4HTnS+SpS3dhz2U36dIzZhrVbIvcfkM1dt8eWsTU/ddX0/F95C8SyoqZtlwA600/lj7LhO7fCdC9ZvqTZk7oVw8dJkOAKyk1OF7Eg5aYarL9gCRFcw=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1787640732; c=relaxed/simple;
	bh=k3pQJebpZGPesuVRu/q7CgKG8NWzlzcTOvdVAKylpbs=;
	h=From:To:Cc:Subject:Date:Message-ID:In-Reply-To:References:
	 MIME-Version; b=bym+p4wEtBArVW81X5rcUH5wCZStykl7p6LrPtWowZVkwvRE7SSAqWv4FacEg6WmSClJ4WX5V5Vs9UxE/qGq1lhkNItWCU8jo/3Oc1cbk5DJXS7jYp1+AO6o1hJguX0pUv2+c0vFi7iSnRpttWPrmNLNhdAI/CZqHRI/oF8Y+FU=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dmarc=pass (p=reject dis=none) header.from=dell.com; spf=pass smtp.mailfrom=dell.com; dkim=pass (2048-bit key) header.d=dell.com header.i=@dell.com header.b=hRgJ+/vU; dkim=pass (2048-bit key) header.d=dell.com header.i=@dell.com header.b=hkr4/pcP; arc=none smtp.client-ip=148.163.137.20
Authentication-Results: smtp.subspace.kernel.org; dmarc=pass (p=reject dis=none) header.from=dell.com
Authentication-Results: smtp.subspace.kernel.org; spf=pass smtp.mailfrom=dell.com
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=dell.com header.i=@dell.com header.b="hRgJ+/vU";
	dkim=pass (2048-bit key) header.d=dell.com header.i=@dell.com header.b="hkr4/pcP"
Received: from pps.filterd (m0170397.ppops.net [127.0.0.1])
	by mx0b-00154904.pphosted.com (8.18.1.11/8.18.1.11) with ESMTP id 67P2RO4H1134761;
	Tue, 25 Aug 2026 02:52:02 -0400
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=dell.com; h=cc
	:content-transfer-encoding:date:from:in-reply-to:message-id
	:mime-version:references:subject:to; s=smtpout1; bh=nPaxhAG9XnlJ
	eq70/PMMa1IR+0nXXbC+grpgHYz+NXI=; b=hRgJ+/vUnlUGWXsTxFYX0FeH5R2F
	3sSlNWYwkXB0XfykNEN9uJMJpTrcGPY7xAhz1AfZBSyEG5K30nIdsI2dJhUJambR
	KG1YF6mOVCMC0HUU3Fto7y0h4rt4UzNxXgmkcV8tyNMeQpMSVsX6fKpwzINFrAeJ
	lLzAQ2RhExwUmIqRcMSlEAM38ZZW1AM7NL0vrpyzFk/6/kTXtBTeVzquRgcJ8wg1
	IC9M+/ndDmCN6o1/rUXSN0onUlz+cL08OHS4yAwoxWyGkyWs9EhksiSfUuKUjGy3
	wUZ8a739BIW5oAzHWxoAy0FMVrDlXtemlV4rU5qtj+C62zIZlG3F88kPdw==
Received: from mx0a-00154901.pphosted.com (mx0a-00154901.pphosted.com [67.231.149.39])
	by mx0b-00154904.pphosted.com (PPS) with ESMTPS id 4g74upj9ux-1
	(version=TLSv1.3 cipher=TLS_AES_256_GCM_SHA384 bits=256 verify=NOT);
	Tue, 25 Aug 2026 02:52:02 -0400 (EDT)
Received: from pps.filterd (m0133268.ppops.net [127.0.0.1])
	by mx0a-00154901.pphosted.com (8.18.1.11/8.18.1.11) with ESMTP id 67P6UCvG2872376;
	Tue, 25 Aug 2026 02:52:01 -0400
Received: from esapsmtpat10.us.dell.com (esapsmtpat10.us.dell.com [143.166.211.153])
	by mx0a-00154901.pphosted.com (PPS) with ESMTPS id 4g91j0jy3f-3
	(version=TLSv1.3 cipher=TLS_AES_256_GCM_SHA384 bits=256 verify=FAIL);
	Tue, 25 Aug 2026 02:52:01 -0400 (EDT)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
  d=dell.com; i=@dell.com; q=dns/txt; s=smtpdev1;
  t=1787640722; x=1819176722;
  h=from:to:cc:subject:date:message-id:in-reply-to:
   references:mime-version:content-transfer-encoding;
  bh=nPaxhAG9XnlJeq70/PMMa1IR+0nXXbC+grpgHYz+NXI=;
  b=hkr4/pcPyIb7YNJmKghdJjkwemF6FI/sLBeBwXGzUS9x+AuqNKQVIiJK
   qF0rvuyNaQpL4zd9vWqRtI8U3LI8MbD3kQ1PxUBP3okyJcXDSX0qf62SN
   Ne1Mk5MOT9+pVUaF3jpwAzOxofta9hU+WM1d/I/JIgLkPH4UOctFZ2Ww9
   d0yrCeHqtAC7Id4gF7GRI/q3do7gSDY/KTcctHypvPVEAOTxwZtZElHl/
   YtGK3Qlt7xStquvZUDMQ5J7Au9WEIbVpJliHT8fKm+p11K+jliMuWprbO
   /WKAx1zDQkBQee5fEMX0HultplsN0wBBwSAOufoafiMz4ZfQ6vhFalrEW
   g==;
X-CSE-ConnectionGUID: Kv3tDSn/TsCtb74XsIWo+Q==
X-CSE-MsgGUID: XMTik6iFQF6RfGtKNrobDw==
X-LoopCount0: from 10.94.13.48
X-MS-Exchange-CrossPremises-AuthAs: Internal
Received: from w-96j1th4.apac.dell.com (HELO W-96J1TH4.blr.amer.dell.com) ([10.94.13.48])
  by esapsmtpat10.us.dell.com with ESMTP/TLS/TLS_AES_256_GCM_SHA384; 25 Aug 2026 06:51:57 +0000
From: Prabhakar Pujeri <prabhakar.pujeri@dell.com>
To: cel@kernel.org, jlayton@kernel.org
Cc: neil@brown.name, okorniev@redhat.com, Dai.Ngo@oracle.com, tom@talpey.com,
        donald.hunter@gmail.com, kuba@kernel.org, linux-nfs@vger.kernel.org,
        linux-kernel@vger.kernel.org,
        Prabhakar Pujeri <prabhakar.pujeri@dell.com>
Subject: [PATCH v1 2/3] nfsd: add a Netlink dump of NFSv4 clients
Date: Tue, 25 Aug 2026 06:51:46 +0000
Message-ID: <6b42a390ce3ea9a5930e2704137fd435c6f7d27e.1787638668.git.prabhakar.pujeri@dell.com>
X-Mailer: git-send-email 2.53.0
In-Reply-To: <cover.1787638668.git.prabhakar.pujeri@dell.com>
References: <cover.1787638668.git.prabhakar.pujeri@dell.com>
Precedence: bulk
X-Mailing-List: linux-nfs@vger.kernel.org
List-Id: <linux-nfs.vger.kernel.org>
List-Subscribe: <mailto:linux-nfs+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:linux-nfs+unsubscribe@vger.kernel.org>
MIME-Version: 1.0
Content-Transfer-Encoding: 8bit
X-Proofpoint-Virus-Version: vendor=baseguard
 engine=ICAP:2.0.293,Aquarius:18.0.1176,Hydra:6.1.134,FMLib:17.12.100.49
 definitions=2026-08-25_01,2026-08-24_01,2025-10-01_01
X-Proofpoint-Spam-Details: rule=outbound_notspam policy=outbound score=0
 priorityscore=1501 suspectscore=0 adultscore=0 spamscore=0 lowpriorityscore=0
 phishscore=0 malwarescore=0 clxscore=1015 bulkscore=0 impostorscore=0
 classifier=typeunknown authscore=0 authtc= authcc= route=outbound adjust=0
 reason=mlx scancount=1 engine=8.22.0-2606150000 definitions=main-2608250056
X-Proofpoint-Spam-Details-Enc: AW1haW4tMjYwODI1MDA1NyBTYWx0ZWRfXwoHVuYPdwuM0
 5xQ9XOR4D//GrLiwo4sCRJr7pcgQV0Igm5aMwKV9q5he1uiUc1yJvmnOQd/p/ztNVPEVWoF/QVy
 0DkHU2j5YjhO7qfGhgjo+CCXXWJfs0PdErSs8tbUtQqMZZUNy7st7sHBNCA2/QMtZRR8vinNXah
 tMZ/xW6rfyQt5lxP9DjFvlOgPVgGudhG/hHtAkczRR9WF/cMyf0PtdXZrElVeCUaawUS7V98sM1
 UYoXhcjehyD5zlrZTnG4JHhGEAk7oFin0NUJHA4gTOwA0ebHQ5iNA3oIrw1SRU6SlUn1FhgAzxD
 slJs7S5JTTjFeewFPmhQrTw00XXYhUWqhs01Eqy9k9LgsEsGUzFxSUK61nDBCEMio25JLln2Qkr
 6F/MoJDGxZwySJdmpH+i2I5cjtek99OXgGf0NYq0FmnYL7H0GPtM+GFv8IfKzxEcEwI4mBxe+N0
 ZkIaPhxYuPLg0qHNXsg==
X-Proofpoint-GUID: XiTf5o7TXopADOlBAcZygqPyYtsXkh_G
X-Proofpoint-ORIG-GUID: XiTf5o7TXopADOlBAcZygqPyYtsXkh_G
X-Authority-Analysis: v=2.4 cv=dtDrzVg4 c=1 sm=1 tr=0 ts=6a8d3b92 cx=c_pps
 a=j0++y401J6f/BxNAf5EDow==:117 a=zctdXvwhg3EK6xEvKeLW8g==:17
 a=Sv0fKeRqtYgA:10 a=ke5jqHz-1hQA:10 a=VkNPw1HP01LnGYTKEx00:22
 a=6gNNCFAoQcIphELLPWWu:22 a=U3ti1ie9CgboSd2qXsAw:22 a=iLNU1ar6AAAA:8
 a=Qh7K5O9fiLzXO3WRn7YA:9 a=gbU3OgOOxF9bX48Letew:22
X-Proofpoint-Spam-Info: AW1haW4tMjYwODI1MDA1NyBTYWx0ZWRfX3YAFWc1a08ZP
 0CBRg7zvbSps7ACvUUqqH05Xb/286pLZ++65cl0/oE+lnZ2t4wCfupyMiy/crUsgNdBrt2/VcEF
 8jIfwCC4MgtncYYVVt2FJcDrjsMWfTw=
X-Proofpoint-Spam-Details: rule=notspam policy=default score=0
 lowpriorityscore=0 priorityscore=1501 bulkscore=0 clxscore=1015 adultscore=0
 spamscore=0 malwarescore=0 suspectscore=0 impostorscore=0 phishscore=0
 classifier=typeunknown authscore=0 authtc= authcc= route=outbound adjust=0
 reason=mlx scancount=1 engine=8.22.0-2606150000 definitions=main-2608250057

Administrators currently have to walk one nfsd filesystem directory per
client to correlate basic NFSv4 identity, lease, and callback
information. That interface is useful for detailed inspection, but it
is awkward for monitoring tools and provides no atomic way to enumerate
the client set.

Add a privileged client-get dump to the nfsd Generic Netlink family.
Emit one bounded message per confirmed or unconfirmed client with its
server-generated client ID, peer address, minor version, client and
callback states, signed lease time remaining, and RECLAIM_COMPLETE
status.

Pin each client while taking a snapshot, protect mutable lease and
confirmation fields with the per-net client lock, and serialize against
server shutdown with nfsd_mutex. Netlink dump cursors track the table,
bucket, and position; client churn can still cause a best-effort
snapshot, which is documented. Leave the existing nfsd filesystem
interface unchanged.

Signed-off-by: Prabhakar Pujeri <prabhakar.pujeri@dell.com>
---
 .../admin-guide/nfs/nfsd-admin-interfaces.rst |  15 ++
 Documentation/netlink/specs/nfsd.yaml         |  75 +++++++
 fs/nfsd/netlink.c                             |   5 +
 fs/nfsd/netlink.h                             |   1 +
 fs/nfsd/nfs4ctl.h                             |  10 +
 fs/nfsd/nfs4state.c                           | 200 ++++++++++++++++++
 fs/nfsd/nfsctl.c                              |  13 ++
 include/uapi/linux/nfsd_netlink.h             |  35 +++
 8 files changed, 354 insertions(+)

diff --git a/Documentation/admin-guide/nfs/nfsd-admin-interfaces.rst b/Documentation/admin-guide/nfs/nfsd-admin-interfaces.rst
index 35c174000ab3..bd7a8f71592c 100644
--- a/Documentation/admin-guide/nfs/nfsd-admin-interfaces.rst
+++ b/Documentation/admin-guide/nfs/nfsd-admin-interfaces.rst
@@ -32,6 +32,21 @@ Between startup and shutdown, the number of threads may be adjusted up
 or down by additional writes to nfsd/threads or by writes to
 nfsd/pool_threads.
 
+NFSv4 client visibility
+=======================
+
+The privileged ``client-get`` dump in the ``nfsd`` Generic Netlink family
+emits one message for each NFSv4 client.  Each message identifies the client
+by its server-generated client ID and transport address, then reports its
+minor version, client and callback states, signed lease time remaining, and
+whether an NFSv4.1 or later client sent RECLAIM_COMPLETE.
+
+The dump is a best-effort snapshot; clients can change between messages.
+
+The existing ``/proc/fs/nfsd/clients/`` files remain available for inspection.
+The ``states`` file contains individual stateids, and writing ``expire`` to
+``ctl`` forcibly removes the client and all state it owns.
+
 For more detail about files under nfsd/ and what they control, see
 fs/nfsd/nfsctl.c; most of them have detailed comments.
 
diff --git a/Documentation/netlink/specs/nfsd.yaml b/Documentation/netlink/specs/nfsd.yaml
index d01d93f39392..5df329ebe0b1 100644
--- a/Documentation/netlink/specs/nfsd.yaml
+++ b/Documentation/netlink/specs/nfsd.yaml
@@ -42,6 +42,24 @@ definitions:
       - none
       - tls
       - mtls
+  -
+    type: enum
+    name: client-state
+    doc: State of an NFSv4 client record.
+    entries:
+      - unconfirmed
+      - active
+      - courtesy
+      - expirable
+  -
+    type: enum
+    name: callback-state
+    doc: State of an NFSv4 client's callback channel.
+    entries:
+      - up
+      - unknown
+      - down
+      - fault
 
 attribute-sets:
   -
@@ -420,6 +438,48 @@ attribute-sets:
         type: nest
         nested-attributes: server-proc-entry
         multi-attr: true
+  -
+    name: client
+    attributes:
+      -
+        name: clientid
+        type: u64
+        doc: >-
+          Server-generated NFSv4 client ID, with the boot value in the upper
+          32 bits and the per-boot ID in the lower 32 bits.
+      -
+        name: pad
+        type: pad
+      -
+        name: address
+        type: binary
+        doc: >-
+          Transport peer address recorded when the client was created, as
+          struct sockaddr_in or struct sockaddr_in6.
+        checks:
+          min-len: 16
+      -
+        name: minor-version
+        type: u32
+        doc: Negotiated NFSv4 minor version.
+      -
+        name: state
+        type: u32
+        enum: client-state
+        doc: Confirmation and courtesy-state status of the client record.
+      -
+        name: lease-remaining
+        type: s64
+        doc: Signed seconds until the client's lease expires; negative means overdue.
+      -
+        name: reclaim-complete
+        type: flag
+        doc: The NFSv4.1 or later client sent RECLAIM_COMPLETE.
+      -
+        name: callback-state
+        type: u32
+        enum: callback-state
+        doc: Health of the client's callback channel.
 
 operations:
   list:
@@ -633,6 +693,21 @@ operations:
             - proc4-ops
             - proc4ops-ops
             - proc4cb-ops
+    -
+      name: client-get
+      doc: dump NFSv4 clients
+      attribute-set: client
+      flags: [admin-perm]
+      dump:
+        reply:
+          attributes:
+            - clientid
+            - address
+            - minor-version
+            - state
+            - lease-remaining
+            - reclaim-complete
+            - callback-state
 
 mcast-groups:
   list:
diff --git a/fs/nfsd/netlink.c b/fs/nfsd/netlink.c
index eba8b353f412..48bc499136b5 100644
--- a/fs/nfsd/netlink.c
+++ b/fs/nfsd/netlink.c
@@ -230,6 +230,11 @@ static const struct genl_split_ops nfsd_nl_ops[] = {
 		.dumpit	= nfsd_nl_server_stats_get_dumpit,
 		.flags	= GENL_CMD_CAP_DUMP,
 	},
+	{
+		.cmd	= NFSD_CMD_CLIENT_GET,
+		.dumpit	= nfsd_nl_client_get_dumpit,
+		.flags	= GENL_ADMIN_PERM | GENL_CMD_CAP_DUMP,
+	},
 };
 
 static const struct genl_multicast_group nfsd_nl_mcgrps[] = {
diff --git a/fs/nfsd/netlink.h b/fs/nfsd/netlink.h
index 027e2953db26..de7593e64082 100644
--- a/fs/nfsd/netlink.h
+++ b/fs/nfsd/netlink.h
@@ -44,6 +44,7 @@ int nfsd_nl_unlock_filesystem_doit(struct sk_buff *skb, struct genl_info *info);
 int nfsd_nl_unlock_export_doit(struct sk_buff *skb, struct genl_info *info);
 int nfsd_nl_server_stats_get_dumpit(struct sk_buff *skb,
 				    struct netlink_callback *cb);
+int nfsd_nl_client_get_dumpit(struct sk_buff *skb, struct netlink_callback *cb);
 
 enum {
 	NFSD_NLGRP_NONE,
diff --git a/fs/nfsd/nfs4ctl.h b/fs/nfsd/nfs4ctl.h
index bcec4c4ef1d5..44cbb0fac588 100644
--- a/fs/nfsd/nfs4ctl.h
+++ b/fs/nfsd/nfs4ctl.h
@@ -20,8 +20,10 @@
 struct net;
 struct inode;
 struct dentry;
+struct sk_buff;
 struct svc_rqst;
 struct nfsd_net;
+struct netlink_callback;
 
 #ifdef CONFIG_NFSD_V4
 extern unsigned long max_delegations;
@@ -37,6 +39,8 @@ bool nfsd4_spo_must_allow(struct svc_rqst *rqstp);
 int nfsd4_create_laundry_wq(void);
 void nfsd4_destroy_laundry_wq(void);
 bool nfsd_wait_for_delegreturn(struct svc_rqst *rqstp, struct inode *inode);
+int nfsd4_nl_client_get_dumpit(struct sk_buff *skb,
+			       struct netlink_callback *cb);
 
 extern int nfsd4_is_junction(struct dentry *dentry);
 extern int register_cld_notifier(void);
@@ -68,6 +72,12 @@ static inline bool nfsd_wait_for_delegreturn(struct svc_rqst *rqstp,
 	return false;
 }
 
+static inline int nfsd4_nl_client_get_dumpit(struct sk_buff *skb,
+					     struct netlink_callback *cb)
+{
+	return 0;
+}
+
 static inline int nfsd4_is_junction(struct dentry *dentry)
 {
 	return 0;
diff --git a/fs/nfsd/nfs4state.c b/fs/nfsd/nfs4state.c
index 2c1b8b2cbbb5..9add35dfb58b 100644
--- a/fs/nfsd/nfs4state.c
+++ b/fs/nfsd/nfs4state.c
@@ -59,6 +59,7 @@
 #include "pnfs.h"
 #include "filecache.h"
 #include "nfs4xdr_gen.h"
+#include "netlink.h"
 #include "trace.h"
 
 #define NFSDDBG_FACILITY                NFSDDBG_PROC
@@ -3232,6 +3233,205 @@ static const char *cb_state2str(int state)
 	return "UNDEFINED";
 }
 
+enum nfsd4_nl_client_table {
+	NFSD4_NL_CLIENT_CONFIRMED,
+	NFSD4_NL_CLIENT_UNCONFIRMED,
+	NFSD4_NL_CLIENT_DONE,
+};
+
+struct nfsd4_nl_client {
+	struct sockaddr_storage	address;
+	u64			clientid;
+	s64			lease_remaining;
+	u32			minor_version;
+	u32			state;
+	u32			callback_state;
+	bool			reclaim_complete;
+};
+
+static u32 nfsd4_nl_client_state(bool confirmed, unsigned int state)
+{
+	if (!confirmed)
+		return NFSD_CLIENT_STATE_UNCONFIRMED;
+
+	switch (state) {
+	case NFSD4_COURTESY:
+		return NFSD_CLIENT_STATE_COURTESY;
+	case NFSD4_EXPIRABLE:
+		return NFSD_CLIENT_STATE_EXPIRABLE;
+	default:
+		return NFSD_CLIENT_STATE_ACTIVE;
+	}
+}
+
+static u32 nfsd4_nl_callback_state(int state)
+{
+	switch (state) {
+	case NFSD4_CB_UP:
+		return NFSD_CALLBACK_STATE_UP;
+	case NFSD4_CB_DOWN:
+		return NFSD_CALLBACK_STATE_DOWN;
+	case NFSD4_CB_FAULT:
+		return NFSD_CALLBACK_STATE_FAULT;
+	default:
+		return NFSD_CALLBACK_STATE_UNKNOWN;
+	}
+}
+
+static struct nfs4_client *
+nfsd4_nl_get_client(struct nfsd_net *nn, enum nfsd4_nl_client_table table,
+		    unsigned long bucket, unsigned long skip)
+{
+	struct nfs4_client *clp = NULL;
+	struct nfs4_client *pos;
+	struct list_head *head;
+	unsigned long index = 0;
+
+	lockdep_assert_held(&nfsd_mutex);
+
+	if (table == NFSD4_NL_CLIENT_CONFIRMED)
+		head = &nn->conf_id_hashtbl[bucket];
+	else
+		head = &nn->unconf_id_hashtbl[bucket];
+
+	spin_lock(&nn->client_lock);
+	list_for_each_entry(pos, head, cl_idhash) {
+		if (index++ != skip)
+			continue;
+		kref_get(&pos->cl_nfsdfs.cl_ref);
+		clp = pos;
+		break;
+	}
+	spin_unlock(&nn->client_lock);
+	return clp;
+}
+
+static void nfsd4_nl_client_snapshot(struct nfsd_net *nn,
+				     struct nfs4_client *clp,
+				     struct nfsd4_nl_client *client)
+{
+	unsigned int state;
+	time64_t last_renew;
+	bool confirmed;
+
+	spin_lock(&nn->client_lock);
+	last_renew = clp->cl_time;
+	confirmed = test_bit(NFSD4_CLIENT_CONFIRMED, &clp->cl_flags);
+	state = READ_ONCE(clp->cl_state);
+	spin_unlock(&nn->client_lock);
+
+	memcpy(&client->address, &clp->cl_addr, sizeof(client->address));
+	client->clientid = (u64)clp->cl_clientid.cl_boot << 32 |
+			   clp->cl_clientid.cl_id;
+	client->lease_remaining = last_renew ?
+		last_renew + READ_ONCE(nn->nfsd4_lease) -
+		ktime_get_boottime_seconds() : 0;
+	client->minor_version = clp->cl_minorversion;
+	client->state = nfsd4_nl_client_state(confirmed, state);
+	client->callback_state =
+		nfsd4_nl_callback_state(READ_ONCE(clp->cl_cb_state));
+	client->reclaim_complete =
+		test_bit(NFSD4_CLIENT_RECLAIM_COMPLETE, &clp->cl_flags);
+}
+
+static int nfsd4_nl_client_compose_msg(struct sk_buff *skb,
+				       struct netlink_callback *cb,
+				       const struct nfsd4_nl_client *client)
+{
+	void *hdr;
+
+	hdr = genlmsg_put(skb, NETLINK_CB(cb->skb).portid,
+			  cb->nlh->nlmsg_seq, &nfsd_nl_family, NLM_F_MULTI,
+			  NFSD_CMD_CLIENT_GET);
+	if (!hdr)
+		return -EMSGSIZE;
+
+	if (nla_put_u64_64bit(skb, NFSD_A_CLIENT_CLIENTID, client->clientid,
+			      NFSD_A_CLIENT_PAD) ||
+	    nla_put(skb, NFSD_A_CLIENT_ADDRESS,
+		    svc_addr_len((const struct sockaddr *)&client->address),
+		    &client->address) ||
+	    nla_put_u32(skb, NFSD_A_CLIENT_MINOR_VERSION,
+			client->minor_version) ||
+	    nla_put_u32(skb, NFSD_A_CLIENT_STATE, client->state) ||
+	    nla_put_s64(skb, NFSD_A_CLIENT_LEASE_REMAINING,
+			client->lease_remaining, NFSD_A_CLIENT_PAD) ||
+	    (client->reclaim_complete &&
+	     nla_put_flag(skb, NFSD_A_CLIENT_RECLAIM_COMPLETE)) ||
+	    nla_put_u32(skb, NFSD_A_CLIENT_CALLBACK_STATE,
+			client->callback_state))
+		goto err_cancel;
+
+	genlmsg_end(skb, hdr);
+	return 0;
+
+err_cancel:
+	genlmsg_cancel(skb, hdr);
+	return -EMSGSIZE;
+}
+
+/**
+ * nfsd4_nl_client_get_dumpit - dump NFSv4 client information
+ * @skb: reply buffer
+ * @cb: netlink metadata and command arguments
+ *
+ * One netlink message is emitted for each client. cb->args tracks the client
+ * table, hash bucket, and offset within that bucket. The dump is a best-effort
+ * snapshot because clients can be added, confirmed, or removed between calls.
+ *
+ * Returns the size of the reply or a negative errno.
+ */
+int nfsd4_nl_client_get_dumpit(struct sk_buff *skb,
+			       struct netlink_callback *cb)
+{
+	struct nfsd4_nl_client client;
+	struct nfs4_client *clp;
+	struct nfsd_net *nn;
+	struct net *net;
+	int ret = 0;
+
+	net = sock_net(skb->sk);
+	nn = net_generic(net, nfsd_net_id);
+	mutex_lock(&nfsd_mutex);
+	if (!test_bit(NFSD_NET_UP, &nn->flags)) {
+		ret = -ENODEV;
+		goto out_unlock;
+	}
+
+	while (cb->args[0] < NFSD4_NL_CLIENT_DONE) {
+		if (cb->args[1] >= CLIENT_HASH_SIZE) {
+			cb->args[0]++;
+			cb->args[1] = 0;
+			cb->args[2] = 0;
+			continue;
+		}
+
+		clp = nfsd4_nl_get_client(nn, cb->args[0], cb->args[1],
+					  cb->args[2]);
+		if (!clp) {
+			cb->args[1]++;
+			cb->args[2] = 0;
+			continue;
+		}
+
+		memset(&client, 0, sizeof(client));
+		nfsd4_nl_client_snapshot(nn, clp, &client);
+		ret = nfsd4_nl_client_compose_msg(skb, cb, &client);
+		nfsd4_put_client(clp);
+		if (ret) {
+			if (skb->len)
+				ret = skb->len;
+			goto out_unlock;
+		}
+		cb->args[2]++;
+	}
+	ret = skb->len;
+
+out_unlock:
+	mutex_unlock(&nfsd_mutex);
+	return ret;
+}
+
 static int client_info_show(struct seq_file *m, void *v)
 {
 	struct inode *inode = file_inode(m->file);
diff --git a/fs/nfsd/nfsctl.c b/fs/nfsd/nfsctl.c
index 7ea865b372cc..5079f74d3d65 100644
--- a/fs/nfsd/nfsctl.c
+++ b/fs/nfsd/nfsctl.c
@@ -1634,6 +1634,19 @@ int nfsd_nl_rpc_status_get_dumpit(struct sk_buff *skb,
 	return ret;
 }
 
+/**
+ * nfsd_nl_client_get_dumpit - dump NFSv4 client information
+ * @skb: reply buffer
+ * @cb: netlink metadata and command arguments
+ *
+ * Returns the size of the reply or a negative errno.
+ */
+int nfsd_nl_client_get_dumpit(struct sk_buff *skb,
+			      struct netlink_callback *cb)
+{
+	return nfsd4_nl_client_get_dumpit(skb, cb);
+}
+
 /**
  * nfsd_nl_fh_key_set - helper to copy fh_key from userspace
  * @attr: nlattr NFSD_A_SERVER_FH_KEY
diff --git a/include/uapi/linux/nfsd_netlink.h b/include/uapi/linux/nfsd_netlink.h
index e1fc2db00046..ae495382092d 100644
--- a/include/uapi/linux/nfsd_netlink.h
+++ b/include/uapi/linux/nfsd_netlink.h
@@ -50,6 +50,26 @@ enum nfsd_xprtsec_mode {
 	NFSD_XPRTSEC_MODE_MTLS = 4,
 };
 
+/*
+ * State of an NFSv4 client record.
+ */
+enum nfsd_client_state {
+	NFSD_CLIENT_STATE_UNCONFIRMED,
+	NFSD_CLIENT_STATE_ACTIVE,
+	NFSD_CLIENT_STATE_COURTESY,
+	NFSD_CLIENT_STATE_EXPIRABLE,
+};
+
+/*
+ * State of an NFSv4 client's callback channel.
+ */
+enum nfsd_callback_state {
+	NFSD_CALLBACK_STATE_UP,
+	NFSD_CALLBACK_STATE_UNKNOWN,
+	NFSD_CALLBACK_STATE_DOWN,
+	NFSD_CALLBACK_STATE_FAULT,
+};
+
 enum {
 	NFSD_A_CACHE_NOTIFY_CACHE_TYPE = 1,
 
@@ -261,6 +281,20 @@ enum {
 	NFSD_A_SERVER_STATS_MAX = (__NFSD_A_SERVER_STATS_MAX - 1)
 };
 
+enum {
+	NFSD_A_CLIENT_CLIENTID = 1,
+	NFSD_A_CLIENT_PAD,
+	NFSD_A_CLIENT_ADDRESS,
+	NFSD_A_CLIENT_MINOR_VERSION,
+	NFSD_A_CLIENT_STATE,
+	NFSD_A_CLIENT_LEASE_REMAINING,
+	NFSD_A_CLIENT_RECLAIM_COMPLETE,
+	NFSD_A_CLIENT_CALLBACK_STATE,
+
+	__NFSD_A_CLIENT_MAX,
+	NFSD_A_CLIENT_MAX = (__NFSD_A_CLIENT_MAX - 1)
+};
+
 enum {
 	NFSD_CMD_RPC_STATUS_GET = 1,
 	NFSD_CMD_THREADS_SET,
@@ -281,6 +315,7 @@ enum {
 	NFSD_CMD_UNLOCK_FILESYSTEM,
 	NFSD_CMD_UNLOCK_EXPORT,
 	NFSD_CMD_SERVER_STATS_GET,
+	NFSD_CMD_CLIENT_GET,
 
 	__NFSD_CMD_MAX,
 	NFSD_CMD_MAX = (__NFSD_CMD_MAX - 1)
-- 
2.54.0

