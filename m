Received: from mx0b-00154904.pphosted.com (mx0b-00154904.pphosted.com [148.163.137.20])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id B69553D9058;
	Mon, 31 Aug 2026 09:27:43 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=148.163.137.20
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1788168465; cv=none; b=sXjcMuCgSsakgL9UVFYAHoaUCPEYu1K2VB5RlBs46cIQynzkT3By+xK4F4I6kB3igf9d58ubxOHQbZ9MTMV/h8WAZVBxJ3bN6Fo8Md3tltMIaSZc4K277jQ1GHvqiLNNQvXy79VpgWqJdDYVknv2u2ZbjvcPgDN1nG6V/6UKIa0=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1788168465; c=relaxed/simple;
	bh=migEuetFDTPATquKTaiV4RsjX01wB7EL37ptgTGHXYs=;
	h=From:To:Cc:Subject:Date:Message-ID:In-Reply-To:References:
	 MIME-Version; b=StN4m1iSmSvhtL1uKuVA9yjJ5WiMqc8mzecQ4LyPDqBKPT2BvvuaP/fR6A9CUAw7+SoQRzhJUiY9KcGfaogJLYGMJaH3lIcoU/NvUdZv/VCH4zZH3zKaSW2TiRxRTlDx/6bq4U0RJ9lVsVduBos9ChVPH2ArGsfYqcadaOh48F8=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dmarc=pass (p=reject dis=none) header.from=dell.com; spf=pass smtp.mailfrom=dell.com; dkim=pass (2048-bit key) header.d=dell.com header.i=@dell.com header.b=tFsSOB6r; dkim=pass (2048-bit key) header.d=dell.com header.i=@dell.com header.b=AbC5y7kV; arc=none smtp.client-ip=148.163.137.20
Authentication-Results: smtp.subspace.kernel.org; dmarc=pass (p=reject dis=none) header.from=dell.com
Authentication-Results: smtp.subspace.kernel.org; spf=pass smtp.mailfrom=dell.com
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=dell.com header.i=@dell.com header.b="tFsSOB6r";
	dkim=pass (2048-bit key) header.d=dell.com header.i=@dell.com header.b="AbC5y7kV"
Received: from pps.filterd (m0170397.ppops.net [127.0.0.1])
	by mx0b-00154904.pphosted.com (8.18.1.11/8.18.1.11) with ESMTP id 67V7xF0L2856402;
	Mon, 31 Aug 2026 05:27:37 -0400
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=dell.com; h=cc
	:content-transfer-encoding:date:from:in-reply-to:message-id
	:mime-version:references:subject:to; s=smtpout1; bh=Iw2Id/4Lh5Bf
	UD3UaiAkkbDf9aQwcW+rBGeZip2C3OU=; b=tFsSOB6rUfZ8kV9ERFkXpyOSyqKh
	EpXqDFT138ffotry56eZcIU9/E7aW+wmyoo8gXHjhmOyTHpLnktMcvaCJUNdQCed
	dXeTHDIsvnqKufXditgV/dxZFjtwxQLAHLyOzDIvHHFRKoVo3iaEuTnjVPvsZmtq
	YGIrkSfZanpBivdbAy9eoPtwdfyv3Zw4b6xgFtGiUDhYQz2ISKPGMJxaNLUST09U
	n0i5sTnd7CObEqbK4BO9Da9Ye9G7L59E4ytPWjvix2a9HiWrZwhGVCIciA1wnpGs
	UpwndHQJVXnmrOZwN534YV1tsG0tT2/bnsReKIIq9VuqccM8TtlCH5vORQ==
Received: from mx0b-00154901.pphosted.com (mx0b-00154901.pphosted.com [67.231.157.37])
	by mx0b-00154904.pphosted.com (PPS) with ESMTPS id 4gbrgq5e7k-1
	(version=TLSv1.3 cipher=TLS_AES_256_GCM_SHA384 bits=256 verify=NOT);
	Mon, 31 Aug 2026 05:27:37 -0400 (EDT)
Received: from pps.filterd (m0144104.ppops.net [127.0.0.1])
	by mx0b-00154901.pphosted.com (8.18.1.11/8.18.1.11) with ESMTP id 67V8Xvhe4129725;
	Mon, 31 Aug 2026 05:27:36 -0400
Received: from esapsmtplv05.us.dell.com (esapsmtplv05.us.dell.com [143.166.203.153])
	by mx0b-00154901.pphosted.com (PPS) with ESMTPS id 4gd67b8h8c-2
	(version=TLSv1.3 cipher=TLS_AES_256_GCM_SHA384 bits=256 verify=FAIL);
	Mon, 31 Aug 2026 05:27:36 -0400 (EDT)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
  d=dell.com; i=@dell.com; q=dns/txt; s=smtpdev1;
  t=1788168456; x=1819704456;
  h=from:to:cc:subject:date:message-id:in-reply-to:
   references:mime-version:content-transfer-encoding;
  bh=Iw2Id/4Lh5BfUD3UaiAkkbDf9aQwcW+rBGeZip2C3OU=;
  b=AbC5y7kVFlHred5tHm0Z0cTwNvQE1TCmvGVnwcP98yaGnsc8Kbq2jHpb
   dyuKXAq8M11341Q/GdGRwQN+H14YzhW9onmvHJOnjKqZ5SAwoYtDh5KzC
   3PRpK3TxtAQRY91K9jNi/pr/AytSTqNBSOxWjQQbEEpx/41xGiQIEq9/X
   hzYaQ6ehrIK33hTMGVTcBL2QWzBFdFVkfRTTv5MQ6xI+k/RpCxR3iZGeo
   KpVoNxQkq9YB2s1ssxUbd9o60WdydJNU5D4iQlSPAU3vtPQzjE3qW95tv
   Kv1hZtP23sucdV2Q2ptfKi4RNEpDXiKr6XKbTuMyJudJswUybsvjvTcv4
   A==;
X-CSE-ConnectionGUID: XAOlMNK1QH6o3sPIgymZcQ==
X-CSE-MsgGUID: 2fVi26KkRXeWpeRpc6iphA==
X-LoopCount0: from 10.94.8.206
X-MS-Exchange-CrossPremises-AuthAs: Internal
Received: from w-96j1th4.apac.dell.com (HELO W-96J1TH4.blr.amer.dell.com) ([10.94.8.206])
  by esapsmtplv05.us.dell.com with ESMTP/TLS/TLS_AES_256_GCM_SHA384; 31 Aug 2026 09:27:32 +0000
From: Prabhakar Pujeri <prabhakar.pujeri@dell.com>
To: cel@kernel.org, jlayton@kernel.org
Cc: Prabhakar Pujeri <prabhakar.pujeri@dell.com>, neil@brown.name,
        okorniev@redhat.com, Dai.Ngo@oracle.com, tom@talpey.com,
        donald.hunter@gmail.com, kuba@kernel.org, linux-nfs@vger.kernel.org,
        linux-kernel@vger.kernel.org
Subject: [PATCH v2 1/2] nfsd: add a Netlink dump of NFSv4 clients
Date: Mon, 31 Aug 2026 09:27:23 +0000
Message-ID: <2d682b47dca234b5c270b0b1ea03022c28bbeaa3.1787988917.git.prabhakar.pujeri@dell.com>
X-Mailer: git-send-email 2.53.0
In-Reply-To: <cover.1787988917.git.prabhakar.pujeri@dell.com>
References: <cover.1787988917.git.prabhakar.pujeri@dell.com>
Precedence: bulk
X-Mailing-List: linux-nfs@vger.kernel.org
List-Id: <linux-nfs.vger.kernel.org>
List-Subscribe: <mailto:linux-nfs+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:linux-nfs+unsubscribe@vger.kernel.org>
MIME-Version: 1.0
Content-Transfer-Encoding: 8bit
X-Proofpoint-Virus-Version: vendor=baseguard
 engine=ICAP:2.0.293,Aquarius:18.0.1176,Hydra:6.1.134,FMLib:17.12.100.49
 definitions=2026-08-31_03,2026-08-27_02,2025-10-01_01
X-Proofpoint-Spam-Details: rule=outbound_notspam policy=outbound score=0
 priorityscore=1501 bulkscore=0 adultscore=0 phishscore=0 clxscore=1015
 malwarescore=0 spamscore=0 lowpriorityscore=0 suspectscore=0 impostorscore=0
 classifier=typeunknown authscore=0 authtc= authcc= route=outbound adjust=0
 reason=mlx scancount=1 engine=8.22.0-2606150000 definitions=main-2608310080
X-Proofpoint-GUID: LxQ2NvTlWWXpXzx4kpsMEUdv8i4UdxXy
X-Proofpoint-Spam-Details-Enc: AW1haW4tMjYwODMxMDA4MSBTYWx0ZWRfX/0Ne+A5Aj4AG
 VMP4zyfC1nSfuPe+amdBEyr/iX7jty2FCzb7ZQNb3R3H7LQcdgzI2YA361MQv1Pdj65GyEFIgGh
 z7VyT3KfASuVuvjLvlLaCSibLyWNbrSqQ7P/sFG8wRys77VU16/aVIcBAq3voCT94YTXTyEaao1
 tMZl0bOM3dPZh/sBNMst0dGL1cwbQ1pHJjBY+fbxTaKiFekvm1Qrabnk7qh5qHFGNjhs3lr5yCL
 UxJxMRw1DkNUlSo031UOyjjQCtZzIOEbtcz8WvVccwJxOyLieHzzKLV2hzycfIzfAus0jMs6HGd
 6f0d3aMQEUdKQWTlxSjVfySF3zFwWW2/K9rgx64PT2HgTGh8Xg7sKGcXv2Oojtr4NKt2SW1/89q
 gUy3VbNCTfcwvQKahNCwWiawB9M2WKzo+bK0Gc+vyszIE61PQWICwCXpWAGIgYBDdTq5B5pKRhd
 +VqNd4wXLELGkBi/c/w==
X-Proofpoint-ORIG-GUID: LxQ2NvTlWWXpXzx4kpsMEUdv8i4UdxXy
X-Proofpoint-Spam-Info: AW1haW4tMjYwODMxMDA4MSBTYWx0ZWRfX11quSOwBdEYD
 Ndz+QLWKSw6lQIdnnVgzVwZh8LXXsiH5wwJaG8dMJm9t8j5dKtooKDdcw/oINcIZs//JFACNj9J
 7WF0T0k3/DXys6Yr6B/FVhirvKWXgYc=
X-Authority-Analysis: v=2.4 cv=IoQutr/g c=1 sm=1 tr=0 ts=6a954909 cx=c_pps
 a=Z2e5DKjA+8LiMDv5v6mwwA==:117 a=t4Iba6VQkoKuxR139xjPXA==:17
 a=Sv0fKeRqtYgA:10 a=ke5jqHz-1hQA:10 a=VkNPw1HP01LnGYTKEx00:22
 a=6gNNCFAoQcIphELLPWWu:22 a=U3ti1ie9CgboSd2qXsAw:22 a=VwQbUJbxAAAA:8
 a=iLNU1ar6AAAA:8 a=XlFk0G5EGmSmlJYGYJkA:9 a=hlJyneSgMmFPbskH-t2w:22
X-Proofpoint-Spam-Details: rule=notspam policy=default score=0 malwarescore=0
 spamscore=0 phishscore=0 clxscore=1015 impostorscore=0 suspectscore=0
 adultscore=0 bulkscore=0 lowpriorityscore=0 priorityscore=1501
 classifier=typeunknown authscore=0 authtc= authcc= route=outbound adjust=0
 reason=mlx scancount=1 engine=8.22.0-2606150000 definitions=main-2608310081

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

Represent the peer as separate IPv4 or IPv6 address, port, and optional
scope-ID attributes instead of exposing a raw sockaddr structure.

Pin each client while taking a snapshot, protect mutable lease and
confirmation fields with the per-net client lock, and serialize against
server shutdown with nfsd_mutex. Track client-table changes with a
nonzero generation counter and use genl_dump_check_consistent() so a
dump that can skip or repeat a client is marked NLM_F_DUMP_INTR. Leave
the existing nfsd filesystem interface unchanged.

Assisted-by: LLM sparse
Signed-off-by: Prabhakar Pujeri <prabhakar.pujeri@dell.com>
---
Changes since v1:

  - split raw sockaddr data into address, port, and scope-ID attributes
  - detect client-table churn with a generation counter and
    NLM_F_DUMP_INTR

v1: https://lore.kernel.org/r/6b42a390ce3ea9a5930e2704137fd435c6f7d27e.1787638668.git.prabhakar.pujeri@dell.com

 .../admin-guide/nfs/nfsd-admin-interfaces.rst |  16 ++
 Documentation/netlink/specs/nfsd.yaml         |  93 +++++++
 fs/nfsd/netlink.c                             |   5 +
 fs/nfsd/netlink.h                             |   1 +
 fs/nfsd/netns.h                               |   1 +
 fs/nfsd/nfs4ctl.h                             |  10 +
 fs/nfsd/nfs4state.c                           | 248 ++++++++++++++++++
 fs/nfsd/nfsctl.c                              |  13 +
 include/uapi/linux/nfsd_netlink.h             |  38 +++
 9 files changed, 425 insertions(+)

diff --git a/Documentation/admin-guide/nfs/nfsd-admin-interfaces.rst b/Documentation/admin-guide/nfs/nfsd-admin-interfaces.rst
index c05926f79054..de2a54025874 100644
--- a/Documentation/admin-guide/nfs/nfsd-admin-interfaces.rst
+++ b/Documentation/admin-guide/nfs/nfsd-admin-interfaces.rst
@@ -29,6 +29,22 @@ Between startup and shutdown, the number of threads may be adjusted up
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
+Clients can change between messages.  If that can make the dump skip or repeat
+a record, the kernel sets ``NLM_F_DUMP_INTR`` and userspace should retry.
+
+The existing ``/proc/fs/nfsd/clients/`` files remain available for inspection.
+The ``states`` file contains individual stateids, and writing ``expire`` to
+``ctl`` forcibly removes the client and all state it owns.
+
 For more detail about files under nfsd/ and what they control, see
 fs/nfsd/nfsctl.c; most of them have detailed comments.
 
diff --git a/Documentation/netlink/specs/nfsd.yaml b/Documentation/netlink/specs/nfsd.yaml
index 642268819c6f..9207a96fe594 100644
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
@@ -415,6 +433,63 @@ attribute-sets:
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
+        name: address4
+        type: u32
+        byte-order: big-endian
+        display-hint: ipv4
+        doc: IPv4 peer address recorded when the client was created.
+      -
+        name: address6
+        type: binary
+        byte-order: big-endian
+        display-hint: ipv6
+        checks:
+          exact-len: 16
+        doc: IPv6 peer address recorded when the client was created.
+      -
+        name: address-port
+        type: u16
+        byte-order: big-endian
+        doc: Transport peer port recorded when the client was created.
+      -
+        name: address-scope-id
+        type: u32
+        doc: IPv6 scope ID recorded when the client was created, when nonzero.
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
@@ -627,6 +702,24 @@ operations:
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
+            - address4
+            - address6
+            - address-port
+            - address-scope-id
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
diff --git a/fs/nfsd/netns.h b/fs/nfsd/netns.h
index 0ce7da20aba3..d30af86cf78a 100644
--- a/fs/nfsd/netns.h
+++ b/fs/nfsd/netns.h
@@ -105,6 +105,7 @@ struct nfsd_net {
 	struct list_head *unconf_id_hashtbl;
 	struct rb_root unconf_name_tree;
 	struct list_head *sessionid_hashtbl;
+	u32 nfs4_client_generation;	/* protected by client_lock, never zero */
 	/*
 	 * client_lru holds client queue ordered by nfs4_client.cl_time
 	 * for lease renewal.
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
index a4a75a512e9f..d96e73275b74 100644
--- a/fs/nfsd/nfs4state.c
+++ b/fs/nfsd/nfs4state.c
@@ -59,6 +59,7 @@
 #include "pnfs.h"
 #include "filecache.h"
 #include "nfs4xdr_gen.h"
+#include "netlink.h"
 #include "trace.h"
 
 #define NFSDDBG_FACILITY                NFSDDBG_PROC
@@ -2842,6 +2843,14 @@ free_client(struct nfs4_client *clp)
 	nfsd4_put_client(clp);
 }
 
+static void nfsd4_bump_client_generation(struct nfsd_net *nn)
+{
+	lockdep_assert_held(&nn->client_lock);
+
+	if (++nn->nfs4_client_generation == 0)
+		nn->nfs4_client_generation++;
+}
+
 /* must be called under the client_lock */
 static void
 unhash_client_locked(struct nfs4_client *clp)
@@ -2856,6 +2865,7 @@ unhash_client_locked(struct nfs4_client *clp)
 	/* Make it invisible */
 	if (!list_empty(&clp->cl_idhash)) {
 		list_del_init(&clp->cl_idhash);
+		nfsd4_bump_client_generation(nn);
 		if (test_bit(NFSD4_CLIENT_CONFIRMED, &clp->cl_flags))
 			rb_erase(&clp->cl_namenode, &nn->conf_name_tree);
 		else
@@ -3232,6 +3242,241 @@ static const char *cb_state2str(int state)
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
+		    unsigned long bucket, unsigned long skip,
+		    struct netlink_callback *cb)
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
+	cb->seq = nn->nfs4_client_generation;
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
+static int
+nfsd4_nl_client_put_address(struct sk_buff *skb,
+			    const struct sockaddr_storage *address)
+{
+	switch (address->ss_family) {
+	case AF_INET: {
+		const struct sockaddr_in *sin =
+			(const struct sockaddr_in *)address;
+
+		if (nla_put_in_addr(skb, NFSD_A_CLIENT_ADDRESS4,
+				    sin->sin_addr.s_addr) ||
+		    nla_put_be16(skb, NFSD_A_CLIENT_ADDRESS_PORT,
+				 sin->sin_port))
+			return -EMSGSIZE;
+		break;
+	}
+	case AF_INET6: {
+		const struct sockaddr_in6 *sin6 =
+			(const struct sockaddr_in6 *)address;
+
+		if (nla_put_in6_addr(skb, NFSD_A_CLIENT_ADDRESS6,
+				     &sin6->sin6_addr) ||
+		    nla_put_be16(skb, NFSD_A_CLIENT_ADDRESS_PORT,
+				 sin6->sin6_port) ||
+		    (sin6->sin6_scope_id &&
+		     nla_put_u32(skb, NFSD_A_CLIENT_ADDRESS_SCOPE_ID,
+				 sin6->sin6_scope_id)))
+			return -EMSGSIZE;
+		break;
+	}
+	}
+	return 0;
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
+	genl_dump_check_consistent(cb, hdr);
+
+	if (nla_put_u64_64bit(skb, NFSD_A_CLIENT_CLIENTID, client->clientid,
+			      NFSD_A_CLIENT_PAD) ||
+	    nfsd4_nl_client_put_address(skb, &client->address) ||
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
+ * table, hash bucket, and offset within that bucket. Client table changes can
+ * cause an object to be skipped or repeated between calls; in that case the
+ * affected message or NLMSG_DONE is marked with NLM_F_DUMP_INTR.
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
+					  cb->args[2], cb);
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
@@ -4026,6 +4271,7 @@ add_to_unconfirmed(struct nfs4_client *clp)
 	add_clp_to_name_tree(clp, &nn->unconf_name_tree);
 	idhashval = clientid_hashval(clp->cl_clientid.cl_id);
 	list_add(&clp->cl_idhash, &nn->unconf_id_hashtbl[idhashval]);
+	nfsd4_bump_client_generation(nn);
 	renew_client_locked(clp);
 }
 
@@ -4038,6 +4284,7 @@ move_to_confirmed(struct nfs4_client *clp)
 	lockdep_assert_held(&nn->client_lock);
 
 	list_move(&clp->cl_idhash, &nn->conf_id_hashtbl[idhashval]);
+	nfsd4_bump_client_generation(nn);
 	rb_erase(&clp->cl_namenode, &nn->unconf_name_tree);
 	add_clp_to_name_tree(clp, &nn->conf_name_tree);
 	set_bit(NFSD4_CLIENT_CONFIRMED, &clp->cl_flags);
@@ -10154,6 +10401,7 @@ static int nfs4_state_create_net(struct net *net)
 	INIT_LIST_HEAD(&nn->del_recall_lru);
 	spin_lock_init(&nn->deleg_lock);
 	spin_lock_init(&nn->client_lock);
+	nn->nfs4_client_generation = 1;
 	spin_lock_init(&nn->s2s_cp_lock);
 	idr_init(&nn->s2s_cp_stateids);
 	atomic_set(&nn->pending_async_copies, 0);
diff --git a/fs/nfsd/nfsctl.c b/fs/nfsd/nfsctl.c
index 5331b89c4281..fe060029ed5f 100644
--- a/fs/nfsd/nfsctl.c
+++ b/fs/nfsd/nfsctl.c
@@ -1649,6 +1649,19 @@ int nfsd_nl_rpc_status_get_dumpit(struct sk_buff *skb,
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
index 87da1d0bb21e..715acb4104c1 100644
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
 
@@ -260,6 +280,23 @@ enum {
 	NFSD_A_SERVER_STATS_MAX = (__NFSD_A_SERVER_STATS_MAX - 1)
 };
 
+enum {
+	NFSD_A_CLIENT_CLIENTID = 1,
+	NFSD_A_CLIENT_PAD,
+	NFSD_A_CLIENT_ADDRESS4,
+	NFSD_A_CLIENT_ADDRESS6,
+	NFSD_A_CLIENT_ADDRESS_PORT,
+	NFSD_A_CLIENT_ADDRESS_SCOPE_ID,
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
@@ -280,6 +317,7 @@ enum {
 	NFSD_CMD_UNLOCK_FILESYSTEM,
 	NFSD_CMD_UNLOCK_EXPORT,
 	NFSD_CMD_SERVER_STATS_GET,
+	NFSD_CMD_CLIENT_GET,
 
 	__NFSD_CMD_MAX,
 	NFSD_CMD_MAX = (__NFSD_CMD_MAX - 1)
-- 
2.54.0
