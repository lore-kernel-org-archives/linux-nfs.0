Received: from mx0b-00154904.pphosted.com (mx0b-00154904.pphosted.com [148.163.137.20])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id B6A513D9525;
	Mon, 31 Aug 2026 09:27:43 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=148.163.137.20
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1788168465; cv=none; b=gJec9EcMP4Mgjl9fD35Y/e43T6XNsBL1VozSmybI/KA2Cuuwb06nx8eWODoGUQ2jwIFWcQ0YEXLE5GHPl7hqQb8UGcHxX7Vg5zoGTxu3XtiSC7fQrXR94FPK2cOABM5C56/omP+Lzf5299wXo6EFi56pOpifjiG0fWo6vdE7+GA=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1788168465; c=relaxed/simple;
	bh=fI51M00Qb2d+AcSFd+4NiQ19GMpB3Q9vDVBwLvoSVJU=;
	h=From:To:Cc:Subject:Date:Message-ID:In-Reply-To:References:
	 MIME-Version; b=UeNF4ng4baPkqJM4a3qDveIYTrm458lLTExGnyJzfBxdHhznZwiTyQpKjYYLS5MPQZoDj73jlFmKYzQ/lHUc3D3iXKEGjMj8A9436cpt7TOfGC6N1vcR+SyC7ycJTAFfRFwz3U69RNHc4MW4GZEL1CQ2gaNQzz3q/LF69pQYp8o=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dmarc=pass (p=reject dis=none) header.from=dell.com; spf=pass smtp.mailfrom=dell.com; dkim=pass (2048-bit key) header.d=dell.com header.i=@dell.com header.b=L+FZGBzn; dkim=pass (2048-bit key) header.d=dell.com header.i=@dell.com header.b=KdShtvr6; arc=none smtp.client-ip=148.163.137.20
Authentication-Results: smtp.subspace.kernel.org; dmarc=pass (p=reject dis=none) header.from=dell.com
Authentication-Results: smtp.subspace.kernel.org; spf=pass smtp.mailfrom=dell.com
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=dell.com header.i=@dell.com header.b="L+FZGBzn";
	dkim=pass (2048-bit key) header.d=dell.com header.i=@dell.com header.b="KdShtvr6"
Received: from pps.filterd (m0170397.ppops.net [127.0.0.1])
	by mx0b-00154904.pphosted.com (8.18.1.11/8.18.1.11) with ESMTP id 67V7xLHW2856541;
	Mon, 31 Aug 2026 05:27:42 -0400
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=dell.com; h=cc
	:content-transfer-encoding:date:from:in-reply-to:message-id
	:mime-version:references:subject:to; s=smtpout1; bh=uqD4Gx6drFbo
	TrBGNjwFOJgyn6EElclwTEU+Otve/f0=; b=L+FZGBznYRnfveXP1+ofBy5onobm
	47QmaMZMQgiW5qFmIBNAbHJ0W3oUHJfPDYZrRNZqv3gbbFaRQClHu0tygOnewYEA
	PGcLeFjMZgrU4j4o2CdajRkFuOUqM1d/LSr6RdyYnustmOsrao6JLo6Q6u4SWS+2
	uO1u/b7LBbaTFl6yXAAMuple5xJUuO9+DeA41e5N3Pq5iAlNFoZlz8pP6kzabVbW
	96PqKKFa9FhItdHESUwojRdC+XetJjC71jsvcgMIUS/0yeo58YpFUL07CAPMiK0N
	ktqAAo3VwOs2OannZMA5kjIZyrzrDHElenzS4w0BoYbuIcRXmdb4pWGQPg==
Received: from mx0b-00154901.pphosted.com (mx0b-00154901.pphosted.com [67.231.157.37])
	by mx0b-00154904.pphosted.com (PPS) with ESMTPS id 4gbrgq5e83-1
	(version=TLSv1.3 cipher=TLS_AES_256_GCM_SHA384 bits=256 verify=NOT);
	Mon, 31 Aug 2026 05:27:42 -0400 (EDT)
Received: from pps.filterd (m0144104.ppops.net [127.0.0.1])
	by mx0b-00154901.pphosted.com (8.18.1.11/8.18.1.11) with ESMTP id 67V8Xvhg4129725;
	Mon, 31 Aug 2026 05:27:42 -0400
Received: from esapsmtplv05.us.dell.com (esapsmtplv05.us.dell.com [143.166.203.153])
	by mx0b-00154901.pphosted.com (PPS) with ESMTPS id 4gd67b8h8c-3
	(version=TLSv1.3 cipher=TLS_AES_256_GCM_SHA384 bits=256 verify=FAIL);
	Mon, 31 Aug 2026 05:27:40 -0400 (EDT)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
  d=dell.com; i=@dell.com; q=dns/txt; s=smtpdev1;
  t=1788168460; x=1819704460;
  h=from:to:cc:subject:date:message-id:in-reply-to:
   references:mime-version:content-transfer-encoding;
  bh=uqD4Gx6drFboTrBGNjwFOJgyn6EElclwTEU+Otve/f0=;
  b=KdShtvr6l/J51fdDY248nXbS5jj+0n2wMGlXI8sVHcY/C/k84I0sWJtL
   zc++vAWY2UbPgt0Jc6wwvp1e8YgdJOdFGrIy3xywkqv6T5E+ng0+sooLJ
   aG1DvLW1wa4l+Hte1oVv90Xhw8n+Q43+jdBEoqKCXecRMVnjl49+284LP
   4elODfpdmnkvQ7LHhkFWFjBAhXS+63bCkm7lZGVl7uUnGQUBecf8PPyHT
   FxH2FLUh2zFGqjrMgNe0i1/Tw8HAUH/jies9wd5M1HMG3Anfu/zpBm1h5
   X/s1SDDYdzOxSk5noZOIuxfTCyt44MNGFOfUz46o9At/Je/lQdzDTr+jH
   w==;
X-CSE-ConnectionGUID: PagYx6iURaa/aH9O1p/7tg==
X-CSE-MsgGUID: F/YtRZayT4quXyzxnkPoyA==
X-LoopCount0: from 10.94.8.206
X-MS-Exchange-CrossPremises-AuthAs: Internal
Received: from w-96j1th4.apac.dell.com (HELO W-96J1TH4.blr.amer.dell.com) ([10.94.8.206])
  by esapsmtplv05.us.dell.com with ESMTP/TLS/TLS_AES_256_GCM_SHA384; 31 Aug 2026 09:27:36 +0000
From: Prabhakar Pujeri <prabhakar.pujeri@dell.com>
To: cel@kernel.org, jlayton@kernel.org
Cc: Prabhakar Pujeri <prabhakar.pujeri@dell.com>, neil@brown.name,
        okorniev@redhat.com, Dai.Ngo@oracle.com, tom@talpey.com,
        donald.hunter@gmail.com, kuba@kernel.org, linux-nfs@vger.kernel.org,
        linux-kernel@vger.kernel.org
Subject: [PATCH v2 2/2] nfsd: report per-client NFSv4 state usage through Netlink
Date: Mon, 31 Aug 2026 09:27:24 +0000
Message-ID: <f028a8839133f52e3ff04d5e4645308e63ce8dc6.1787988917.git.prabhakar.pujeri@dell.com>
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
X-Proofpoint-GUID: 5sYCbr3NYqX49N-obrliEIC8l6VOFF_O
X-Proofpoint-Spam-Details-Enc: AW1haW4tMjYwODMxMDA4MSBTYWx0ZWRfX+f3Iw8WMgDbL
 hwAMAceUuVw4PilgI8Rgo6fS4J1oKatPh0qoCdd4/hL1D7+LtfuX/MTAjFP5KaLkZQhQshlE/bn
 KwWSl6VHHCdni4z7Crn+Zy1Mfdf8X6SDCqClx+i5TREq8trQhSSpD5jM8RxlmxAD2FSItGqmTDK
 EvuwXj0MPKwnPNOsnrtF9UaXa/b5D+UnCSzCbPVXgM1jYKQzrJKTG+PCQa4UUVoqdUFf6MjpEjE
 mt4+GS19KUX0LvUfoiK+cO4sHbV4f+S2YVKzN76iuRZc8k2F1CNreX2i8myMVloko1IcI5cBLsi
 qRQ9Ae1WnVoCqDNd1NutCOxB+BILXnRa7HEvhj1EkfS4GlFki81i/tyGThFYz12g8bdFhzrktSG
 +rJ4e4YKgDsb4LtqZdzHplj+cGQNnO3OS468CrwWL15MPRhhZ+wEFxVhjejOjl0Qlr1uTh5kxad
 L1mSaANqXJUFDMHyXRQ==
X-Proofpoint-ORIG-GUID: 5sYCbr3NYqX49N-obrliEIC8l6VOFF_O
X-Proofpoint-Spam-Info: AW1haW4tMjYwODMxMDA4MSBTYWx0ZWRfX0eJVWZbku96Y
 ewxMQ+/Vh2odvwVFJR1EFzg4bgr4aesZZKjPDnXd82kvr6bzxt2d/cNVY/kOzg7nRAu+jvty6zL
 /+f+n6eETK7OZiVyqxFrNKnRsvOudmc=
X-Authority-Analysis: v=2.4 cv=IoQutr/g c=1 sm=1 tr=0 ts=6a95490e cx=c_pps
 a=Z2e5DKjA+8LiMDv5v6mwwA==:117 a=t4Iba6VQkoKuxR139xjPXA==:17
 a=Sv0fKeRqtYgA:10 a=ke5jqHz-1hQA:10 a=VkNPw1HP01LnGYTKEx00:22
 a=6gNNCFAoQcIphELLPWWu:22 a=U3ti1ie9CgboSd2qXsAw:22 a=VwQbUJbxAAAA:8
 a=iLNU1ar6AAAA:8 a=-OkFD1SPTiafkK0poIAA:9 a=hlJyneSgMmFPbskH-t2w:22
X-Proofpoint-Spam-Details: rule=notspam policy=default score=0 malwarescore=0
 spamscore=0 phishscore=0 clxscore=1015 impostorscore=0 suspectscore=0
 adultscore=0 bulkscore=0 lowpriorityscore=0 priorityscore=1501
 classifier=typeunknown authscore=0 authtc= authcc= route=outbound adjust=0
 reason=mlx scancount=1 engine=8.22.0-2606150000 definitions=main-2608310081

A client can retain substantial server-side state even when its lease
and callback channel look healthy. Monitoring tools need compact
per-client totals to identify which client owns that state before doing
a detailed inspection through the nfsd filesystem.

Extend client-get replies with separate counts for sessions and open,
lock, delegation, and layout stateid records. A lock stateid represents
a lock-owner/file pair and can cover multiple byte-range locks, so
document that these are record counts rather than protocol operation or
byte-range counts.

Maintain u64 counters under cl_lock at the existing session and stateid
publish and removal points. The dump takes an O(1) snapshot instead of
walking an unbounded per-client IDR while holding the spinlock. Stateid
counters are decremented only at final IDR removal, preserving the
existing record-count semantics for retained stateids.

Encode the counters as variable-width Netlink uint attributes, which use
four bytes for values that fit in u32 and eight bytes otherwise.

Assisted-by: LLM sparse
Signed-off-by: Prabhakar Pujeri <prabhakar.pujeri@dell.com>
---
Changes since v1:

  - replace unbounded session-list and stateid-IDR walks under cl_lock with
    maintained O(1) u64 counters
  - use variable-width Netlink uint attributes for the counters

v1: https://lore.kernel.org/r/245a1ee42d054e280629c9640c8d8225b45639d0.1787638668.git.prabhakar.pujeri@dell.com

 .../admin-guide/nfs/nfsd-admin-interfaces.rst |  6 ++
 Documentation/netlink/specs/nfsd.yaml         | 27 +++++-
 fs/nfsd/nfs4layouts.c                         |  2 +-
 fs/nfsd/nfs4state.c                           | 95 +++++++++++++++++--
 fs/nfsd/state.h                               |  7 ++
 include/uapi/linux/nfsd_netlink.h             |  5 +
 6 files changed, 130 insertions(+), 12 deletions(-)

diff --git a/Documentation/admin-guide/nfs/nfsd-admin-interfaces.rst b/Documentation/admin-guide/nfs/nfsd-admin-interfaces.rst
index de2a54025874..199141923159 100644
--- a/Documentation/admin-guide/nfs/nfsd-admin-interfaces.rst
+++ b/Documentation/admin-guide/nfs/nfsd-admin-interfaces.rst
@@ -38,6 +38,12 @@ by its server-generated client ID and transport address, then reports its
 minor version, client and callback states, signed lease time remaining, and
 whether an NFSv4.1 or later client sent RECLAIM_COMPLETE.
 
+The dump also reports separate counts for sessions and open, lock, delegation,
+and layout stateids.  A lock stateid represents state for one lock owner and
+file, not necessarily one byte-range lock.  NFSD maintains these counters as
+state changes, so reporting a client does not walk its session or stateid
+tables.
+
 Clients can change between messages.  If that can make the dump skip or repeat
 a record, the kernel sets ``NLM_F_DUMP_INTR`` and userspace should retry.
 
diff --git a/Documentation/netlink/specs/nfsd.yaml b/Documentation/netlink/specs/nfsd.yaml
index 9207a96fe594..8fa1d6925515 100644
--- a/Documentation/netlink/specs/nfsd.yaml
+++ b/Documentation/netlink/specs/nfsd.yaml
@@ -490,6 +490,26 @@ attribute-sets:
         type: u32
         enum: callback-state
         doc: Health of the client's callback channel.
+      -
+        name: sessions
+        type: uint
+        doc: Number of NFSv4.1 or later sessions owned by the client.
+      -
+        name: open-stateids
+        type: uint
+        doc: Number of open stateid records owned by the client.
+      -
+        name: lock-stateids
+        type: uint
+        doc: Number of lock-owner/file stateid records, not byte-range locks.
+      -
+        name: delegation-stateids
+        type: uint
+        doc: Number of delegation stateid records owned by the client.
+      -
+        name: layout-stateids
+        type: uint
+        doc: Number of pNFS layout stateid records owned by the client.
 
 operations:
   list:
@@ -704,7 +724,7 @@ operations:
             - proc4cb-ops
     -
       name: client-get
-      doc: dump NFSv4 clients
+      doc: dump NFSv4 clients and their current state usage
       attribute-set: client
       flags: [admin-perm]
       dump:
@@ -720,6 +740,11 @@ operations:
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
diff --git a/fs/nfsd/nfs4layouts.c b/fs/nfsd/nfs4layouts.c
index 4187202f9acc..adb9f33ef7ae 100644
--- a/fs/nfsd/nfs4layouts.c
+++ b/fs/nfsd/nfs4layouts.c
@@ -272,7 +272,7 @@ nfsd4_alloc_layout_stateid(struct nfsd4_compound_state *cstate,
 	}
 
 	spin_lock(&clp->cl_lock);
-	stp->sc_type = SC_TYPE_LAYOUT;
+	nfs4_set_stid_type_locked(stp, SC_TYPE_LAYOUT);
 	list_add(&ls->ls_perclnt, &clp->cl_lo_states);
 	spin_unlock(&clp->cl_lock);
 
diff --git a/fs/nfsd/nfs4state.c b/fs/nfsd/nfs4state.c
index d96e73275b74..44a724ed05c0 100644
--- a/fs/nfsd/nfs4state.c
+++ b/fs/nfsd/nfs4state.c
@@ -984,6 +984,54 @@ struct nfs4_stid *nfs4_alloc_stid(struct nfs4_client *cl, struct kmem_cache *sla
 	return NULL;
 }
 
+static u64 *nfs4_stid_counter(struct nfs4_client *clp, unsigned short type)
+{
+	switch (type) {
+	case SC_TYPE_OPEN:
+		return &clp->cl_open_stateid_count;
+	case SC_TYPE_LOCK:
+		return &clp->cl_lock_stateid_count;
+	case SC_TYPE_DELEG:
+		return &clp->cl_delegation_stateid_count;
+	case SC_TYPE_LAYOUT:
+		return &clp->cl_layout_stateid_count;
+	default:
+		return NULL;
+	}
+}
+
+void nfs4_set_stid_type_locked(struct nfs4_stid *stid, unsigned short type)
+{
+	struct nfs4_client *clp = stid->sc_client;
+	u64 *counter;
+
+	lockdep_assert_held(&clp->cl_lock);
+
+	if (WARN_ON_ONCE(stid->sc_type))
+		return;
+
+	counter = nfs4_stid_counter(clp, type);
+	if (WARN_ON_ONCE(!counter && type != SC_TYPE_COPY))
+		return;
+
+	stid->sc_type = type;
+	if (counter)
+		(*counter)++;
+}
+
+static void nfs4_remove_stid_locked(struct nfs4_stid *stid)
+{
+	struct nfs4_client *clp = stid->sc_client;
+	u64 *counter;
+
+	lockdep_assert_held(&clp->cl_lock);
+
+	counter = nfs4_stid_counter(clp, stid->sc_type);
+	if (counter && !WARN_ON_ONCE(!*counter))
+		(*counter)--;
+	idr_remove(&clp->cl_stateids, stid->sc_stateid.si_opaque.so_id);
+}
+
 /*
  * Publish a COPY_NOTIFY stateid in nn->s2s_cp_stateids and link it onto the
  * parent's sc_cp_list. That IDR holds only COPY_NOTIFY stateids.
@@ -1046,9 +1094,11 @@ struct nfsd4_async_copy *nfs4_alloc_copy_stid(struct nfs4_client *clp)
 	stid = nfs4_alloc_stid(clp, async_copy_slab, nfsd4_free_async_copy_stid);
 	if (!stid)
 		return NULL;
-	stid->sc_type = SC_TYPE_COPY;
 	/* RFC 7862 Section 4.8: a copy offload stateid's seqid MUST NOT be 0 */
 	stid->sc_stateid.si_generation = 1;
+	spin_lock(&clp->cl_lock);
+	nfs4_set_stid_type_locked(stid, SC_TYPE_COPY);
+	spin_unlock(&clp->cl_lock);
 	return container_of(stid, struct nfsd4_async_copy, cp_stid);
 }
 
@@ -1386,7 +1436,7 @@ nfs4_put_stid(struct nfs4_stid *s)
 		wake_up_all(&close_wq);
 		return;
 	}
-	idr_remove(&clp->cl_stateids, s->sc_stateid.si_opaque.so_id);
+	nfs4_remove_stid_locked(s);
 	if (s->sc_status & SC_STATUS_ADMIN_REVOKED)
 		atomic_dec(&s->sc_client->cl_admin_revoked);
 	/* Read under cl_lock to serialize with drop_stid_export(). */
@@ -1530,7 +1580,7 @@ hash_delegation_locked(struct nfs4_delegation *dp, struct nfs4_file *fp)
 	if (nfs4_delegation_exists(clp, fp))
 		return -EAGAIN;
 	refcount_inc(&dp->dl_stid.sc_count);
-	dp->dl_stid.sc_type = SC_TYPE_DELEG;
+	nfs4_set_stid_type_locked(&dp->dl_stid, SC_TYPE_DELEG);
 	list_add(&dp->dl_perfile, &fp->fi_delegations);
 	list_add(&dp->dl_perclnt, &clp->cl_delegations);
 	clp->cl_deleg_count++;
@@ -1814,7 +1864,7 @@ static void put_ol_stateid_locked(struct nfs4_ol_stateid *stp,
 		return;
 	}
 
-	idr_remove(&clp->cl_stateids, s->sc_stateid.si_opaque.so_id);
+	nfs4_remove_stid_locked(s);
 	if (s->sc_status & SC_STATUS_ADMIN_REVOKED)
 		atomic_dec(&s->sc_client->cl_admin_revoked);
 	list_add(&stp->st_locks, reaplist);
@@ -2634,6 +2684,7 @@ static void init_session(struct svc_rqst *rqstp, struct nfsd4_session *new, stru
 	list_add(&new->se_hash, &nn->sessionid_hashtbl[idx]);
 	spin_lock(&clp->cl_lock);
 	list_add(&new->se_perclnt, &clp->cl_sessions);
+	clp->cl_session_count++;
 	spin_unlock(&clp->cl_lock);
 
 	spin_lock(&nfsd_session_list_lock);
@@ -2707,9 +2758,11 @@ unhash_session(struct nfsd4_session *ses)
 	lockdep_assert_held(&nn->client_lock);
 
 	list_del(&ses->se_hash);
-	spin_lock(&ses->se_client->cl_lock);
+	spin_lock(&clp->cl_lock);
 	list_del(&ses->se_perclnt);
-	spin_unlock(&ses->se_client->cl_lock);
+	if (!WARN_ON_ONCE(!clp->cl_session_count))
+		clp->cl_session_count--;
+	spin_unlock(&clp->cl_lock);
 	spin_lock(&nfsd_session_list_lock);
 	list_del(&ses->se_all_sessions);
 	atomic_dec(&nfsd_total_sessions);
@@ -2822,9 +2875,9 @@ free_client(struct nfs4_client *clp)
 {
 	LIST_HEAD(reaplist);
 
-	/* client_info_show() walks cl_sessions under cl_lock */
 	spin_lock(&clp->cl_lock);
 	list_splice_init(&clp->cl_sessions, &reaplist);
+	clp->cl_session_count = 0;
 	spin_unlock(&clp->cl_lock);
 	while (!list_empty(&reaplist)) {
 		struct nfsd4_session *ses;
@@ -3255,6 +3308,11 @@ struct nfsd4_nl_client {
 	u32			minor_version;
 	u32			state;
 	u32			callback_state;
+	u64			sessions;
+	u64			open_stateids;
+	u64			lock_stateids;
+	u64			delegation_stateids;
+	u64			layout_stateids;
 	bool			reclaim_complete;
 };
 
@@ -3343,6 +3401,14 @@ static void nfsd4_nl_client_snapshot(struct nfsd_net *nn,
 		nfsd4_nl_callback_state(READ_ONCE(clp->cl_cb_state));
 	client->reclaim_complete =
 		test_bit(NFSD4_CLIENT_RECLAIM_COMPLETE, &clp->cl_flags);
+
+	spin_lock(&clp->cl_lock);
+	client->sessions = clp->cl_session_count;
+	client->open_stateids = clp->cl_open_stateid_count;
+	client->lock_stateids = clp->cl_lock_stateid_count;
+	client->delegation_stateids = clp->cl_delegation_stateid_count;
+	client->layout_stateids = clp->cl_layout_stateid_count;
+	spin_unlock(&clp->cl_lock);
 }
 
 static int
@@ -3403,7 +3469,16 @@ static int nfsd4_nl_client_compose_msg(struct sk_buff *skb,
 	    (client->reclaim_complete &&
 	     nla_put_flag(skb, NFSD_A_CLIENT_RECLAIM_COMPLETE)) ||
 	    nla_put_u32(skb, NFSD_A_CLIENT_CALLBACK_STATE,
-			client->callback_state))
+			client->callback_state) ||
+	    nla_put_uint(skb, NFSD_A_CLIENT_SESSIONS, client->sessions) ||
+	    nla_put_uint(skb, NFSD_A_CLIENT_OPEN_STATEIDS,
+			 client->open_stateids) ||
+	    nla_put_uint(skb, NFSD_A_CLIENT_LOCK_STATEIDS,
+			 client->lock_stateids) ||
+	    nla_put_uint(skb, NFSD_A_CLIENT_DELEGATION_STATEIDS,
+			 client->delegation_stateids) ||
+	    nla_put_uint(skb, NFSD_A_CLIENT_LAYOUT_STATEIDS,
+			 client->layout_stateids))
 		goto err_cancel;
 
 	genlmsg_end(skb, hdr);
@@ -6251,7 +6326,7 @@ init_open_stateid(struct nfs4_file *fp, struct nfsd4_open *open)
 
 	open->op_stp = NULL;
 	refcount_inc(&stp->st_stid.sc_count);
-	stp->st_stid.sc_type = SC_TYPE_OPEN;
+	nfs4_set_stid_type_locked(&stp->st_stid, SC_TYPE_OPEN);
 	INIT_LIST_HEAD(&stp->st_locks);
 	stp->st_stateowner = nfs4_get_stateowner(&oo->oo_owner);
 	get_nfs4_file(fp);
@@ -9533,7 +9608,7 @@ init_lock_stateid(struct nfs4_ol_stateid *stp, struct nfs4_lockowner *lo,
 	if (retstp)
 		goto out_found;
 	refcount_inc(&stp->st_stid.sc_count);
-	stp->st_stid.sc_type = SC_TYPE_LOCK;
+	nfs4_set_stid_type_locked(&stp->st_stid, SC_TYPE_LOCK);
 	stp->st_stateowner = nfs4_get_stateowner(&lo->lo_owner);
 	get_nfs4_file(fp);
 	stp->st_stid.sc_file = fp;
diff --git a/fs/nfsd/state.h b/fs/nfsd/state.h
index cd9294f024bb..3fe130ce5de2 100644
--- a/fs/nfsd/state.h
+++ b/fs/nfsd/state.h
@@ -610,6 +610,12 @@ struct nfs4_client {
 
 	/* for nfs41 */
 	struct list_head	cl_sessions;
+	/* State usage counters, protected by cl_lock. */
+	u64			cl_session_count;
+	u64			cl_open_stateid_count;
+	u64			cl_lock_stateid_count;
+	u64			cl_delegation_stateid_count;
+	u64			cl_layout_stateid_count;
 	struct nfsd4_clid_slot	cl_cs_slot;	/* create_session slot */
 	u32			cl_exchange_flags;
 	/* number of rpc's in progress over an associated session: */
@@ -923,6 +929,7 @@ __be32 nfsd4_lookup_stateid(struct nfsd4_compound_state *cstate,
 			    struct nfs4_stid **s, struct nfsd_net *nn);
 struct nfs4_stid *nfs4_alloc_stid(struct nfs4_client *cl, struct kmem_cache *slab,
 				  void (*sc_free)(struct nfs4_stid *));
+void nfs4_set_stid_type_locked(struct nfs4_stid *stid, unsigned short type);
 struct nfsd4_async_copy *nfs4_alloc_copy_stid(struct nfs4_client *clp);
 struct nfs4_cpntf_state *nfs4_alloc_init_cpntf_state(struct nfsd_net *nn,
 			struct nfs4_stid *p_stid);
diff --git a/include/uapi/linux/nfsd_netlink.h b/include/uapi/linux/nfsd_netlink.h
index 715acb4104c1..d97783335ac2 100644
--- a/include/uapi/linux/nfsd_netlink.h
+++ b/include/uapi/linux/nfsd_netlink.h
@@ -292,6 +292,11 @@ enum {
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
