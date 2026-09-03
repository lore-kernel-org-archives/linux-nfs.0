Received: from mx0b-00154904.pphosted.com (mx0b-00154904.pphosted.com [148.163.137.20])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id C6C5F35C1AD
	for <linux-nfs@vger.kernel.org>; Thu,  3 Sep 2026 05:31:51 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=148.163.137.20
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1788413513; cv=none; b=rEuUsVyTnpdtFH8A8yjBQt/y/9nlWCjIfjtWGdd7HUmnHNbmsR1T2ltYanMkymjaJxT9FYWEj00GH/+4nzs9qhtRxpW7krqcsoi/ntGghqWarm1oWxxZz6Lz6cG7eTFa7gNVLYNb2JqXEyqyQ7+X1ubOD0kTPiAcQtxMxfrLcP0=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1788413513; c=relaxed/simple;
	bh=cnqnOxj4IYCuEClRTHmckYA80ZmjsOQ4tPONT+MWSng=;
	h=From:To:Cc:Subject:Date:Message-ID:In-Reply-To:References:
	 MIME-Version; b=cnQPNfprYXWFrKyIbNZIq970mKe0DQ7dlbv4tDmdvUUZ1UNCDtZvFrxF7O0jF//hiJzU6eDvlQh2dItL/aqFc8dA3cDydtudWwNhmYQGJ63vgAey91DfgQ7lOeO1HVHG4KdJA5zJ2KLJglYM17FIq3o4ou1NOTphcmDq4UM1sLw=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dmarc=pass (p=reject dis=none) header.from=dell.com; spf=pass smtp.mailfrom=dell.com; dkim=pass (2048-bit key) header.d=dell.com header.i=@dell.com header.b=Aaj0SC+F; dkim=pass (2048-bit key) header.d=dell.com header.i=@dell.com header.b=I/z3ITrW; arc=none smtp.client-ip=148.163.137.20
Authentication-Results: smtp.subspace.kernel.org; dmarc=pass (p=reject dis=none) header.from=dell.com
Authentication-Results: smtp.subspace.kernel.org; spf=pass smtp.mailfrom=dell.com
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=dell.com header.i=@dell.com header.b="Aaj0SC+F";
	dkim=pass (2048-bit key) header.d=dell.com header.i=@dell.com header.b="I/z3ITrW"
Received: from pps.filterd (m0170396.ppops.net [127.0.0.1])
	by mx0b-00154904.pphosted.com (8.18.1.11/8.18.1.11) with ESMTP id 6832vldh2796270
	for <linux-nfs@vger.kernel.org>; Thu, 3 Sep 2026 01:31:50 -0400
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=dell.com; h=cc
	:content-transfer-encoding:date:from:in-reply-to:message-id
	:mime-version:references:subject:to; s=smtpout1; bh=9lY5qoCmIZXZ
	ZvUzs7H0h5b2o5pEMn1+LQhJ2UDnKzE=; b=Aaj0SC+FNj6Es1cztqtk7seibbRm
	1Wk/HqyY4TBg4Bg8DtBcU24lFgsTGGQhI8oVK953RLH7wta8VkDIYIpuYkEJ9LFw
	oUo+RYnDLHHK1Lthe4NiXIqiP2EbFT4NeUgBwas2BYvxr0jct1GmcMgVNb6hLWWS
	AlMqRqcoW5zPlLRrU82I6RF2N8Hg3F1h50gJKFMbCKoEfgTel/IeO5lqc+3S7QQ6
	/gZQG5ngP9KBnIOk+0Cxt/XqgWh3tr23jyAihXW9dMYePJhhxLJWnkdTiuRdznTK
	LLa2EWFvLXGrTUaAk1gO5H582Zmz5aFXlqCplGtsnzlClaokmyBq1NQe3w==
Received: from mx0a-00154901.pphosted.com (mx0a-00154901.pphosted.com [67.231.149.39])
	by mx0b-00154904.pphosted.com (PPS) with ESMTPS id 4gbu8t52qk-1
	(version=TLSv1.3 cipher=TLS_AES_256_GCM_SHA384 bits=256 verify=NOT)
	for <linux-nfs@vger.kernel.org>; Thu, 03 Sep 2026 01:31:50 -0400 (EDT)
Received: from pps.filterd (m0134746.ppops.net [127.0.0.1])
	by mx0a-00154901.pphosted.com (8.18.1.11/8.18.1.11) with ESMTP id 6833wteD3474327
	for <linux-nfs@vger.kernel.org>; Thu, 3 Sep 2026 01:31:49 -0400
Received: from esapsmtplv06.us.dell.com (esapsmtplv06.us.dell.com [143.166.203.146])
	by mx0a-00154901.pphosted.com (PPS) with ESMTPS id 4gf1fa0u7k-2
	(version=TLSv1.3 cipher=TLS_AES_256_GCM_SHA384 bits=256 verify=FAIL)
	for <linux-nfs@vger.kernel.org>; Thu, 03 Sep 2026 01:31:48 -0400 (EDT)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
  d=dell.com; i=@dell.com; q=dns/txt; s=smtpdev1;
  t=1788413509; x=1819949509;
  h=from:to:cc:subject:date:message-id:in-reply-to:
   references:mime-version:content-transfer-encoding;
  bh=9lY5qoCmIZXZZvUzs7H0h5b2o5pEMn1+LQhJ2UDnKzE=;
  b=I/z3ITrW3Y9k7HSYlJ4llL0KWcauZSxj4dj5tr/LqdNc/AElQzgxzN7j
   7ovzsAXTwKIsWs30RA6//dLkSbm5hKXhExXG4rjjZ5ASdkKb10goKGx/j
   MSqvnLk5DaWWXkIJkybo2N8a//wtxCRJQ0WGtwQsvC00cuv6y8Vkf1MAk
   scVizl9lOUxdhMCaeTAQJ/Dt6hV18eTb39Ss1zb+bs7rmQ1fmQkix6v3T
   4qNxETZzhbwABXxEHDeyW5Oa4a6Ni16+zYp96r+m8WH5dKygt0kacMkHf
   cYZ1fiLt4XG9ImeiGFcYM5wOodiEYQXyB37QcWWx188A8v8dOiBxxAtJK
   w==;
X-CSE-ConnectionGUID: Hktm5MPvSUeFEA/ZX0aSMA==
X-CSE-MsgGUID: xs7orKqeR4SP9WOkitMFSw==
X-LoopCount0: from 10.94.14.196
X-MS-Exchange-CrossPremises-AuthAs: Internal
Received: from w-96j1th4.apac.dell.com (HELO W-96J1TH4.blr.amer.dell.com) ([10.94.14.196])
  by esapsmtplv06.us.dell.com with ESMTP/TLS/TLS_AES_256_GCM_SHA384; 03 Sep 2026 05:31:47 +0000
From: Prabhakar Pujeri <prabhakar.pujeri@dell.com>
To: linux-nfs@vger.kernel.org
Cc: jlayton@kernel.org, chuck.lever@oracle.com,
        Prabhakar Pujeri <prabhakar.pujeri@dell.com>
Subject: [PATCH v3 1/2] nfsd: add a Netlink dump of NFSv4 clients
Date: Thu,  3 Sep 2026 05:31:40 +0000
Message-ID: <20260903053141.1241-2-prabhakar.pujeri@dell.com>
X-Mailer: git-send-email 2.53.0
In-Reply-To: <20260903053141.1241-1-prabhakar.pujeri@dell.com>
References: <20260903053141.1241-1-prabhakar.pujeri@dell.com>
Precedence: bulk
X-Mailing-List: linux-nfs@vger.kernel.org
List-Id: <linux-nfs.vger.kernel.org>
List-Subscribe: <mailto:linux-nfs+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:linux-nfs+unsubscribe@vger.kernel.org>
MIME-Version: 1.0
Content-Transfer-Encoding: 8bit
X-Proofpoint-Virus-Version: vendor=baseguard
 engine=ICAP:2.0.293,Aquarius:18.0.1176,Hydra:6.1.134,FMLib:17.12.100.49
 definitions=2026-09-03_01,2026-09-02_04,2025-10-01_01
X-Proofpoint-Spam-Details: rule=outbound_notspam policy=outbound score=0
 lowpriorityscore=0 priorityscore=1501 suspectscore=0 clxscore=1015
 phishscore=0 bulkscore=0 adultscore=0 impostorscore=0 spamscore=0
 malwarescore=0 classifier=typeunknown authscore=0 authtc= authcc=
 route=outbound adjust=0 reason=mlx scancount=1 engine=8.22.0-2606150000
 definitions=main-2609030046
X-Proofpoint-Spam-Info: AW1haW4tMjYwOTAzMDA0OCBTYWx0ZWRfXyrgcPYamIVkJ
 TziWcPpvCEVFWB80+wiWrN8q5d4sBSIwwXwQdZaMz6+6N4z9sSHYLQEEl0wAPtbwikOkXbhkcHA
 U6gk3DMPqhPKVraMkcjFaHvLir5qnKg=
X-Proofpoint-GUID: vIKJzLhfq6V6KSHCrsY-JH78ZB_T-LQl
X-Authority-Analysis: v=2.4 cv=cLTQdFeN c=1 sm=1 tr=0 ts=6a990646 cx=c_pps
 a=j0++y401J6f/BxNAf5EDow==:117 a=in+AvElAwLqdjTPPAWhuvg==:17
 a=VdqzKS8jKosA:10 a=ke5jqHz-1hQA:10 a=VkNPw1HP01LnGYTKEx00:22
 a=6gNNCFAoQcIphELLPWWu:22 a=fe1keu9KhAX5AoWrZvs2:22 a=VwQbUJbxAAAA:8
 a=iLNU1ar6AAAA:8 a=OVjXNipTxiPnIKYvOGEA:9 a=gbU3OgOOxF9bX48Letew:22
X-Proofpoint-ORIG-GUID: vIKJzLhfq6V6KSHCrsY-JH78ZB_T-LQl
X-Proofpoint-Spam-Details-Enc: AW1haW4tMjYwOTAzMDA0OCBTYWx0ZWRfXzpCoE7C3KHPi
 nutWMDKMtqQS6cTBHd/1Om9iHgkS1oS1y1gj1n2JYKVftHhEsejtDWG/Kz6ZUMCxmp2qVw7ENpp
 5jaMYuIlLzo4MX0ofuxD761St5apr5bdKudTw/Jehfb/gFt5YNE8XnTdt2g8RVVO+GahvvGanKc
 s0eZFlgVR9XVlArrZ6LN0y8DNK1sEKIfU4g79a4N3gqgdKHQ7I9fWAryo+VcTFUo467AXr94TjT
 Lx8nC+FEFvaBawihxVOYUjy50nvfF6ZXckx0jPKzOT7LfOiB9QfVPfPrW4wcPiOEOASIF/Ck7GJ
 zarYs1MdWl4MYn9jqm/+A/rN81IUM+Z0RSO3/xI6PTfv4vv3lv3ROE5a9TjFx6KevNUZv9dO4dQ
 +hvOkg9hBqDaq6IAROfnhgTmEVVzWcwYYPvsT4JrcqIyBBFp91W6/gIKs9FBFuyV/2Onx0r6WX5
 fMnRACZ6fEsikV+0F2w==
X-Proofpoint-Spam-Details: rule=notspam policy=default score=0 spamscore=0
 clxscore=1015 phishscore=0 adultscore=0 malwarescore=0 priorityscore=1501
 impostorscore=0 bulkscore=0 lowpriorityscore=0 suspectscore=0
 classifier=typeunknown authscore=0 authtc= authcc= route=outbound adjust=0
 reason=mlx scancount=1 engine=8.22.0-2606150000 definitions=main-2609030048

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

Signed-off-by: Prabhakar Pujeri <prabhakar.pujeri@dell.com>
---
Changes since v2 (feedback from Jeff Layton):

  - rename the client lookup helper to nfsd_nl_find_client()
  - validate the client-table argument explicitly instead of aliasing
    NFSD4_NL_CLIENT_DONE to "unconfirmed"
  - rename nfsd4_nl_client_put_address() to
    nfsd4_nl_client_marshal_address()
  - document the confirmed-then-unconfirmed table ordering in the dump
    loop comments

Changes since v1:

  - split raw sockaddr data into address, port, and scope-ID attributes
  - detect client-table churn with a generation counter and
    NLM_F_DUMP_INTR

v1: https://lore.kernel.org/r/6b42a390ce3ea9a5930e2704137fd435c6f7d27e.1787638668.git.prabhakar.pujeri@dell.com
v2: https://lore.kernel.org/r/2d682b47dca234b5c270b0b1ea03022c28bbeaa3.1787988917.git.prabhakar.pujeri@dell.com

 .../admin-guide/nfs/nfsd-admin-interfaces.rst |  16 ++
 Documentation/netlink/specs/nfsd.yaml         |  93 +++++++
 fs/nfsd/netlink.c                             |   5 +
 fs/nfsd/netlink.h                             |   1 +
 fs/nfsd/netns.h                               |   1 +
 fs/nfsd/nfs4ctl.h                             |  10 +
 fs/nfsd/nfs4state.c                           | 260 ++++++++++++++++++
 fs/nfsd/nfsctl.c                              |  13 +
 include/uapi/linux/nfsd_netlink.h             |  38 +++
 9 files changed, 437 insertions(+)

diff --git a/Documentation/admin-guide/nfs/nfsd-admin-interfaces.rst b/Documentation/admin-guide/nfs/nfsd-admin-interfaces.rst
index c05926f7905..de2a5402587 100644
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
index 642268819c6..9207a96fe59 100644
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
index eba8b353f41..48bc499136b 100644
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
index 027e2953db2..de7593e6408 100644
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
index 0ce7da20aba..d30af86cf78 100644
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
index bcec4c4ef1d..44cbb0fac58 100644
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
index ae0af9490fb..f947ac20eed 100644
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
@@ -3232,6 +3242,253 @@ static const char *cb_state2str(int state)
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
+nfsd_nl_find_client(struct nfsd_net *nn, enum nfsd4_nl_client_table table,
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
+	switch (table) {
+	case NFSD4_NL_CLIENT_CONFIRMED:
+		head = &nn->conf_id_hashtbl[bucket];
+		break;
+	case NFSD4_NL_CLIENT_UNCONFIRMED:
+		head = &nn->unconf_id_hashtbl[bucket];
+		break;
+	default:
+		return NULL;
+	}
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
+nfsd4_nl_client_marshal_address(struct sk_buff *skb,
+				const struct sockaddr_storage *address)
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
+	    nfsd4_nl_client_marshal_address(skb, &client->address) ||
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
+	/*
+	 * Table values are ordered: confirmed clients first, then
+	 * unconfirmed, then done. cb->args[0] tracks which table the
+	 * dump is visiting, args[1] the hash bucket in it, and args[2]
+	 * the client's offset within that bucket.
+	 */
+	while (cb->args[0] < NFSD4_NL_CLIENT_DONE) {
+		if (cb->args[1] >= CLIENT_HASH_SIZE) {
+			cb->args[0]++;
+			cb->args[1] = 0;
+			cb->args[2] = 0;
+			continue;
+		}
+
+		clp = nfsd_nl_find_client(nn, cb->args[0], cb->args[1],
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
@@ -4026,6 +4283,7 @@ add_to_unconfirmed(struct nfs4_client *clp)
 	add_clp_to_name_tree(clp, &nn->unconf_name_tree);
 	idhashval = clientid_hashval(clp->cl_clientid.cl_id);
 	list_add(&clp->cl_idhash, &nn->unconf_id_hashtbl[idhashval]);
+	nfsd4_bump_client_generation(nn);
 	renew_client_locked(clp);
 }
 
@@ -4038,6 +4296,7 @@ move_to_confirmed(struct nfs4_client *clp)
 	lockdep_assert_held(&nn->client_lock);
 
 	list_move(&clp->cl_idhash, &nn->conf_id_hashtbl[idhashval]);
+	nfsd4_bump_client_generation(nn);
 	rb_erase(&clp->cl_namenode, &nn->unconf_name_tree);
 	add_clp_to_name_tree(clp, &nn->conf_name_tree);
 	set_bit(NFSD4_CLIENT_CONFIRMED, &clp->cl_flags);
@@ -10160,6 +10419,7 @@ static int nfs4_state_create_net(struct net *net)
 	INIT_LIST_HEAD(&nn->del_recall_lru);
 	spin_lock_init(&nn->deleg_lock);
 	spin_lock_init(&nn->client_lock);
+	nn->nfs4_client_generation = 1;
 	spin_lock_init(&nn->s2s_cp_lock);
 	idr_init(&nn->s2s_cp_stateids);
 	atomic_set(&nn->pending_async_copies, 0);
diff --git a/fs/nfsd/nfsctl.c b/fs/nfsd/nfsctl.c
index c6f6bc3b128..4d11592cdf8 100644
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
index 87da1d0bb21..715acb4104c 100644
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
2.55.0

