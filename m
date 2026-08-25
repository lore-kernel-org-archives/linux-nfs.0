Received: from mx0b-00154904.pphosted.com (mx0b-00154904.pphosted.com [148.163.137.20])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 629D33CF1F9;
	Tue, 25 Aug 2026 06:52:13 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=148.163.137.20
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1787640735; cv=none; b=qDGOLKaAitOnDQXvC1n+aXJSFkPg51LLVcolsCevU4l1ypiiggqmnpWKUBhDjqsn09EsgRsL2y3FW394pOf/zKdG2UA7NopH77QkdGK4eHtZENPjPcYZTMZGY4EMN6u7FwBhBl7IWiHp9pSlr2B/XHo3tJksw1RDM7PTgd61Hbw=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1787640735; c=relaxed/simple;
	bh=E+dKF71NFjds38t5hc0LkKgCqKsXkmz3y63QTXY+YZk=;
	h=From:To:Cc:Subject:Date:Message-ID:In-Reply-To:References:
	 MIME-Version; b=P1bXGIsqV16MVDsH/CQMLtWIzM1Ok5nftLZFLdGjSSBuUfydi5HndVDsJNRwh0VhixEALGa/Kq7X3mDpP7aL1CinrKNNMAloNInG8Eik7locZ8Hzum630URvaCIfwPrH47nWtxnmBz7B1CpkqplROw7afFzxxQTilLkK0ISuMyE=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dmarc=pass (p=reject dis=none) header.from=dell.com; spf=pass smtp.mailfrom=dell.com; dkim=pass (2048-bit key) header.d=dell.com header.i=@dell.com header.b=RvGb2Sn/; dkim=pass (2048-bit key) header.d=dell.com header.i=@dell.com header.b=OsAlwkhW; arc=none smtp.client-ip=148.163.137.20
Authentication-Results: smtp.subspace.kernel.org; dmarc=pass (p=reject dis=none) header.from=dell.com
Authentication-Results: smtp.subspace.kernel.org; spf=pass smtp.mailfrom=dell.com
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=dell.com header.i=@dell.com header.b="RvGb2Sn/";
	dkim=pass (2048-bit key) header.d=dell.com header.i=@dell.com header.b="OsAlwkhW"
Received: from pps.filterd (m0170395.ppops.net [127.0.0.1])
	by mx0b-00154904.pphosted.com (8.18.1.11/8.18.1.11) with ESMTP id 67P2RNXw1438105;
	Tue, 25 Aug 2026 02:52:06 -0400
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=dell.com; h=cc
	:content-transfer-encoding:date:from:in-reply-to:message-id
	:mime-version:references:subject:to; s=smtpout1; bh=Wn7gjBS6uQ38
	2HqFdF+VtWXb/8VPHvRjM1GM4BY055U=; b=RvGb2Sn/nAENTVz7bout7DMeEAvV
	11KVZ2dXS1YQBHs7MiMbU+2FY88043mnM9ihBuDpfKmVWxq6IFwhPIcc/b9m9GJb
	z34WIQIO/y/FNX3750YxsOWTdiwsJzyr0DROu2/RgTRi0jdlNdD4TZVaoLJlcr4z
	dESx6PXVlYa/iM10/6PiTio5NDACOjydep4UK3mWuZeDyvXS6kFs1hCijiIVVCDQ
	zDElbbY0HbWrf5cpwHS/nlOlLsJoJKgvY162aUl9vD50eR4L108+JP7eKwSabiGz
	W+nvx8lflcyPNxxrO6llLka3xM3AruIEj+7Hlsd4lFldkAKuE320Dybpkw==
Received: from mx0a-00154901.pphosted.com (mx0a-00154901.pphosted.com [67.231.149.39])
	by mx0b-00154904.pphosted.com (PPS) with ESMTPS id 4g78egstdn-1
	(version=TLSv1.3 cipher=TLS_AES_256_GCM_SHA384 bits=256 verify=NOT);
	Tue, 25 Aug 2026 02:52:05 -0400 (EDT)
Received: from pps.filterd (m0133268.ppops.net [127.0.0.1])
	by mx0a-00154901.pphosted.com (8.18.1.11/8.18.1.11) with ESMTP id 67P6UCvH2872376;
	Tue, 25 Aug 2026 02:52:05 -0400
Received: from esapsmtpat10.us.dell.com (esapsmtpat10.us.dell.com [143.166.211.153])
	by mx0a-00154901.pphosted.com (PPS) with ESMTPS id 4g91j0jy3f-4
	(version=TLSv1.3 cipher=TLS_AES_256_GCM_SHA384 bits=256 verify=FAIL);
	Tue, 25 Aug 2026 02:52:04 -0400 (EDT)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
  d=dell.com; i=@dell.com; q=dns/txt; s=smtpdev1;
  t=1787640725; x=1819176725;
  h=from:to:cc:subject:date:message-id:in-reply-to:
   references:mime-version:content-transfer-encoding;
  bh=Wn7gjBS6uQ382HqFdF+VtWXb/8VPHvRjM1GM4BY055U=;
  b=OsAlwkhWPUi40wGkPRqy8RSSqFP5GvZdiDzxs/brXhd2b5xQDYSq4nbN
   HyPfq2XdJx1JirpeAqDeElkI2IBQmj0OnhLny9/qB9ZZxuVitdumTXRHG
   2S0h8sAkrStAOBRWA7ioHml1tkYXsIRnZDUfpD7T4M4KEJYGfnu+QLoyN
   QzPykmbLXnIvaAjo3HsAG4+/6tbMXCY/6nFF2J1sKWPeJPv3HWkVuMZil
   +x9tpbJc6zVCyJbHH6CGXLQKPjyiLrcMrcPcSMRE3eJfy9paSoa3wYt8F
   chyOOIEa85bm1K2xwa2LLd+xixybGi4+1qeJ/Df4aczFjGl5/xz8/hT5t
   g==;
X-CSE-ConnectionGUID: uZekLzY/S7mspt8QAKnHGg==
X-CSE-MsgGUID: D43lxPSSTIq2Ig6m/kswTQ==
X-LoopCount0: from 10.94.13.48
X-MS-Exchange-CrossPremises-AuthAs: Internal
Received: from w-96j1th4.apac.dell.com (HELO W-96J1TH4.blr.amer.dell.com) ([10.94.13.48])
  by esapsmtpat10.us.dell.com with ESMTP/TLS/TLS_AES_256_GCM_SHA384; 25 Aug 2026 06:52:01 +0000
From: Prabhakar Pujeri <prabhakar.pujeri@dell.com>
To: cel@kernel.org, jlayton@kernel.org
Cc: neil@brown.name, okorniev@redhat.com, Dai.Ngo@oracle.com, tom@talpey.com,
        donald.hunter@gmail.com, kuba@kernel.org, linux-nfs@vger.kernel.org,
        linux-kernel@vger.kernel.org,
        Prabhakar Pujeri <prabhakar.pujeri@dell.com>
Subject: [PATCH v1 3/3] nfsd: report per-client NFSv4 state usage through Netlink
Date: Tue, 25 Aug 2026 06:51:47 +0000
Message-ID: <245a1ee42d054e280629c9640c8d8225b45639d0.1787638668.git.prabhakar.pujeri@dell.com>
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
X-Proofpoint-ORIG-GUID: lHa2ODKiB1iiX5lFoLWMMGuyYVOw0zmN
X-Proofpoint-Spam-Info: AW1haW4tMjYwODI1MDA1NyBTYWx0ZWRfX3l1I51h/KkYB
 mwg1moL2vkqs+Koygkmj03Ku+qsWcjPpVb/M0BMpytK2LU7LocO55conz/FvKP1wZnOmBmKPAdF
 WqhhA44N+iI+fr9zkGVsfoDaLn1tvOQ=
X-Proofpoint-GUID: lHa2ODKiB1iiX5lFoLWMMGuyYVOw0zmN
X-Proofpoint-Spam-Details-Enc: AW1haW4tMjYwODI1MDA1NyBTYWx0ZWRfX6IHVlKmlwI3I
 xfQr7IbnjiaOuySbBKyAwGZg9OBuYEg3F5n/rABTRyGCJ85r8QLw64FUOM8COv4rHQPvayoGbNd
 pwxGMcoxM6B9vO5rsDPa6At66x4jdv+4sFv7KrItoWOd4iiNHRufD2oDTY7C9VYUCv/2b7+paqq
 c24m4kM5RjmhbtbzgAGyN+UX/O/sxZmeiMzhyhcWOaOAVbO/ogkUJVRgUgASaezz3hkkw2oZnRa
 vH/D/0P40iTMneAdp4p0CjHXSFK1v6XnHuBhNei9MR0z3ZwffZNWz9vViRpPAYXZQiuisWB6It7
 TddxVvYBsNYXf+7oDzlkCxRqZz9TtHhEh+u+cStsAlMrOw/UdOh+Utw8cYXxaD4x8IdGB8Y3dGW
 EhYU0zklOCQfYPqZfsiIJgv7bX+jz0qrEJImHc52L/VlPm+8+1kWgrAde4RqtNXb8Mio9+9gcap
 ZjfHsK3ZL1f1qzSj2BQ==
X-Authority-Analysis: v=2.4 cv=Z6Hc2nRA c=1 sm=1 tr=0 ts=6a8d3b96 cx=c_pps
 a=j0++y401J6f/BxNAf5EDow==:117 a=zctdXvwhg3EK6xEvKeLW8g==:17
 a=Sv0fKeRqtYgA:10 a=ke5jqHz-1hQA:10 a=VkNPw1HP01LnGYTKEx00:22
 a=6gNNCFAoQcIphELLPWWu:22 a=Qy6CKLcU0MZ4grw4BCWD:22 a=iLNU1ar6AAAA:8
 a=IUJZ_EN-PaMBYXuBGKEA:9 a=gbU3OgOOxF9bX48Letew:22
X-Proofpoint-Spam-Details: rule=notspam policy=default score=0 suspectscore=0
 clxscore=1015 priorityscore=1501 impostorscore=0 phishscore=0 bulkscore=0
 malwarescore=0 lowpriorityscore=0 adultscore=0 spamscore=0
 classifier=typeunknown authscore=0 authtc= authcc= route=outbound adjust=0
 reason=mlx scancount=1 engine=8.22.0-2606150000 definitions=main-2608250057

A client can retain substantial server-side state even when its lease
and callback channel look healthy. Monitoring tools need compact
per-client totals to identify which client owns that state before doing
a detailed inspection through the nfsd filesystem.

Extend client-get replies with separate counts for sessions and open,
lock, delegation, and layout stateid records. A lock stateid represents
a lock-owner/file pair and can cover multiple byte-range locks, so
document that these are record counts rather than protocol operation or
byte-range counts.

Walk both the session list and stateid IDR under cl_lock. free_client()
already detaches its session list under that lock, so a client pinned by
the dump cannot race this traversal with session teardown.

Signed-off-by: Prabhakar Pujeri <prabhakar.pujeri@dell.com>
---
 .../admin-guide/nfs/nfsd-admin-interfaces.rst |  4 ++
 Documentation/netlink/specs/nfsd.yaml         | 27 ++++++++++++-
 fs/nfsd/nfs4state.c                           | 40 ++++++++++++++++++-
 include/uapi/linux/nfsd_netlink.h             |  5 +++
 4 files changed, 73 insertions(+), 3 deletions(-)

diff --git a/Documentation/admin-guide/nfs/nfsd-admin-interfaces.rst b/Documentation/admin-guide/nfs/nfsd-admin-interfaces.rst
index bd7a8f71592c..076b20f4bf6a 100644
--- a/Documentation/admin-guide/nfs/nfsd-admin-interfaces.rst
+++ b/Documentation/admin-guide/nfs/nfsd-admin-interfaces.rst
@@ -41,6 +41,10 @@ by its server-generated client ID and transport address, then reports its
 minor version, client and callback states, signed lease time remaining, and
 whether an NFSv4.1 or later client sent RECLAIM_COMPLETE.
 
+The dump also reports separate counts for sessions and open, lock, delegation,
+and layout stateids.  A lock stateid represents state for one lock owner and
+file, not necessarily one byte-range lock.
+
 The dump is a best-effort snapshot; clients can change between messages.
 
 The existing ``/proc/fs/nfsd/clients/`` files remain available for inspection.
diff --git a/Documentation/netlink/specs/nfsd.yaml b/Documentation/netlink/specs/nfsd.yaml
index 5df329ebe0b1..1707de076d43 100644
--- a/Documentation/netlink/specs/nfsd.yaml
+++ b/Documentation/netlink/specs/nfsd.yaml
@@ -480,6 +480,26 @@ attribute-sets:
         type: u32
         enum: callback-state
         doc: Health of the client's callback channel.
+      -
+        name: sessions
+        type: u32
+        doc: Number of NFSv4.1 or later sessions owned by the client.
+      -
+        name: open-stateids
+        type: u32
+        doc: Number of open stateid records owned by the client.
+      -
+        name: lock-stateids
+        type: u32
+        doc: Number of lock-owner/file stateid records, not byte-range locks.
+      -
+        name: delegation-stateids
+        type: u32
+        doc: Number of delegation stateid records owned by the client.
+      -
+        name: layout-stateids
+        type: u32
+        doc: Number of pNFS layout stateid records owned by the client.
 
 operations:
   list:
@@ -695,7 +715,7 @@ operations:
             - proc4cb-ops
     -
       name: client-get
-      doc: dump NFSv4 clients
+      doc: dump NFSv4 clients and their current state usage
       attribute-set: client
       flags: [admin-perm]
       dump:
@@ -708,6 +728,11 @@ operations:
             - lease-remaining
             - reclaim-complete
             - callback-state
+            - sessions
+            - open-stateids
+            - lock-stateids
+            - delegation-stateids
+            - layout-stateids
 
 mcast-groups:
   list:
diff --git a/fs/nfsd/nfs4state.c b/fs/nfsd/nfs4state.c
index 9add35dfb58b..f023cfff818d 100644
--- a/fs/nfsd/nfs4state.c
+++ b/fs/nfsd/nfs4state.c
@@ -2822,7 +2822,7 @@ free_client(struct nfs4_client *clp)
 {
 	LIST_HEAD(reaplist);
 
-	/* client_info_show() walks cl_sessions under cl_lock */
+	/* Client reporting walks cl_sessions under cl_lock. */
 	spin_lock(&clp->cl_lock);
 	list_splice_init(&clp->cl_sessions, &reaplist);
 	spin_unlock(&clp->cl_lock);
@@ -3246,6 +3246,11 @@ struct nfsd4_nl_client {
 	u32			minor_version;
 	u32			state;
 	u32			callback_state;
+	u32			sessions;
+	u32			open_stateids;
+	u32			lock_stateids;
+	u32			delegation_stateids;
+	u32			layout_stateids;
 	bool			reclaim_complete;
 };
 
@@ -3310,6 +3315,8 @@ static void nfsd4_nl_client_snapshot(struct nfsd_net *nn,
 				     struct nfs4_client *clp,
 				     struct nfsd4_nl_client *client)
 {
+	struct nfs4_stid *stid;
+	unsigned long id, tmp;
 	unsigned int state;
 	time64_t last_renew;
 	bool confirmed;
@@ -3332,6 +3339,26 @@ static void nfsd4_nl_client_snapshot(struct nfsd_net *nn,
 		nfsd4_nl_callback_state(READ_ONCE(clp->cl_cb_state));
 	client->reclaim_complete =
 		test_bit(NFSD4_CLIENT_RECLAIM_COMPLETE, &clp->cl_flags);
+
+	spin_lock(&clp->cl_lock);
+	client->sessions = list_count_nodes(&clp->cl_sessions);
+	idr_for_each_entry_ul(&clp->cl_stateids, stid, tmp, id) {
+		switch (stid->sc_type) {
+		case SC_TYPE_OPEN:
+			client->open_stateids++;
+			break;
+		case SC_TYPE_LOCK:
+			client->lock_stateids++;
+			break;
+		case SC_TYPE_DELEG:
+			client->delegation_stateids++;
+			break;
+		case SC_TYPE_LAYOUT:
+			client->layout_stateids++;
+			break;
+		}
+	}
+	spin_unlock(&clp->cl_lock);
 }
 
 static int nfsd4_nl_client_compose_msg(struct sk_buff *skb,
@@ -3359,7 +3386,16 @@ static int nfsd4_nl_client_compose_msg(struct sk_buff *skb,
 	    (client->reclaim_complete &&
 	     nla_put_flag(skb, NFSD_A_CLIENT_RECLAIM_COMPLETE)) ||
 	    nla_put_u32(skb, NFSD_A_CLIENT_CALLBACK_STATE,
-			client->callback_state))
+			client->callback_state) ||
+	    nla_put_u32(skb, NFSD_A_CLIENT_SESSIONS, client->sessions) ||
+	    nla_put_u32(skb, NFSD_A_CLIENT_OPEN_STATEIDS,
+			client->open_stateids) ||
+	    nla_put_u32(skb, NFSD_A_CLIENT_LOCK_STATEIDS,
+			client->lock_stateids) ||
+	    nla_put_u32(skb, NFSD_A_CLIENT_DELEGATION_STATEIDS,
+			client->delegation_stateids) ||
+	    nla_put_u32(skb, NFSD_A_CLIENT_LAYOUT_STATEIDS,
+			client->layout_stateids))
 		goto err_cancel;
 
 	genlmsg_end(skb, hdr);
diff --git a/include/uapi/linux/nfsd_netlink.h b/include/uapi/linux/nfsd_netlink.h
index ae495382092d..49c9531a98b7 100644
--- a/include/uapi/linux/nfsd_netlink.h
+++ b/include/uapi/linux/nfsd_netlink.h
@@ -290,6 +290,11 @@ enum {
 	NFSD_A_CLIENT_LEASE_REMAINING,
 	NFSD_A_CLIENT_RECLAIM_COMPLETE,
 	NFSD_A_CLIENT_CALLBACK_STATE,
+	NFSD_A_CLIENT_SESSIONS,
+	NFSD_A_CLIENT_OPEN_STATEIDS,
+	NFSD_A_CLIENT_LOCK_STATEIDS,
+	NFSD_A_CLIENT_DELEGATION_STATEIDS,
+	NFSD_A_CLIENT_LAYOUT_STATEIDS,
 
 	__NFSD_A_CLIENT_MAX,
 	NFSD_A_CLIENT_MAX = (__NFSD_A_CLIENT_MAX - 1)
-- 
2.54.0

