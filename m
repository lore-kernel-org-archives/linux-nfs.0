Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.remote-ip=74.125.82.171
ARC-Seal: i=1; d=subspace.kernel.org; s=arc20261015; a=rsa-sha256; cv=none;
	t=1793011963;
	b=W6PBDAnE9aSDjuSv0eXk2v2iZ8WOggmO6FUVul25Vj3dP5FTsJueCxFSO1vPKCE/tMaP
	 dEWINL/FCYiqXQGTyEDq1QQK3Zut/IgPWZREDDrkutOkWIXHULJVFAwUAxPgssxxkuJIs
	 2+5dTJ7gMXWDYBjWIwa39TvU/svCyOTPb1aVNQ0SLPXGXCWGDUSUxyam8TQH//FMjcA91
	 pYWGayzejINnmxivFKaenCWsP/sCQ5nEYI5q8zi3n2mWZ3/sqG5UuDFwdBgDDrJQc29hZ
	 4cmHP0gZjwiYdreBBpu8wQLx8vSbk4JB/icqV+V243ZbYQTdobHRdAdX7VUZq6c3OBA==
ARC-Message-Signature: i=1; d=subspace.kernel.org; s=arc20261015;
	a=rsa-sha256; c=relaxed/relaxed; t=1793011963;
	h=DMARC-Filter:Received:DKIM-Signature:X-Google-DKIM-Signature:
	 X-Gm-Message-State:X-Gm-Gg:X-Received:Received:From:To:Cc:Subject:
	 Date:Message-Id:X-Mailer:MIME-Version:Content-Type:
	 Content-Transfer-Encoding;
	bh=3Em7THwSHsQndbMmwUsL9yOCeRU0YR5E1djj6NAjXMU=;
	b=CQtZiFXI6dzEs4zRuU2WZaSry7p3FwvKPgFJggUiUdiZHiEuKGa7CwXfHKtPGcgbIFHH
	 XLEHDEAh/esp0V6Pz9YgugwYYW+al9Sbdbu8XGVjw/OyEFaIV5dCPNKQgvZjS4sY2PBwY
	 SNwJTiPwwZd/zyEkIRjdks97rbcl2u+BGmtFc+DNr4xKIgd6yzaKPFbKek9ZSnDlfxDQx
	 cMFnoNha4RjVnL/JP0xz9HnVPt3I5vpp/aZPWhXL2fQhtSBuZQL6vwegG5Xl1SThZoeCj
	 ztFRroTls5BJVFRELWwBXgy8SzR93+mBW4TGz4GgcNB4TXjhlnFzT1z93tmBnecBURg==
ARC-Authentication-Results: i=1; smtp.subspace.kernel.org; 
	dmarc=pass header.from=gmail.com;
	spf=pass smtp.mailfrom=gmail.com;
	dkim=pass header.d=gmail.com header.i=@gmail.com header.a=rsa-sha256 header.s=20251104 header.b=RLJySYeS;
	arc=none smtp.remote-ip=74.125.82.171
Received: from mail-dy1-f171.google.com (mail-dy1-f171.google.com [74.125.82.171])
	(using TLSv1.3 with cipher TLS_AES_128_GCM_SHA256 (128/128 bits)
	 key-exchange X25519 server-signature ECDSA (prime256v1) server-digest SHA256)
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id A8DF5606A31A
	for <linux-nfs@vger.kernel.org>; Mon, 26 Oct 2026 10:52:42 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.4.2 smtp.subspace.kernel.org A8DF5606A31A
Authentication-Results: smtp.subspace.kernel.org; dmarc=pass (p=none dis=none) header.from=gmail.com
Authentication-Results: smtp.subspace.kernel.org; spf=pass smtp.mailfrom=gmail.com
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key, unprotected) header.d=gmail.com header.i=@gmail.com header.a=rsa-sha256 header.s=20251104 header.b=RLJySYeS
Received: by mail-dy1-f171.google.com with SMTP id 5a478bee46e88-35d0be18c71so4726641eec.1
        for <linux-nfs@vger.kernel.org>; Mon, 26 Oct 2026 03:52:42 -0700 (PDT)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=gmail.com; s=20251104; t=1793011962; x=1793616762; darn=vger.kernel.org;
        h=content-transfer-encoding:content-type:mime-version:message-id:date
         :subject:cc:to:from:from:to:cc:subject:date:message-id:reply-to
         :content-type;
        bh=3Em7THwSHsQndbMmwUsL9yOCeRU0YR5E1djj6NAjXMU=;
        b=RLJySYeS0BQzTg9o9qO1xD/c5MAamNT+UD+2xN9Z+O05l/Av3gsWFchNwa7tQatxX+
         c7BuZqBIeWfC4XCHIypjcL12Rf9wShN/qjN8EHf5Sifu5uU5Gu65k5fhjLfDId6s2j6q
         1Bty0VjzgEDUe1SqrhnScGnTOB9bFQ6Wq2OeBeh84Bqe0r6HuhWR0aybhUZb3DrcP95w
         8ieeeWrrrXr/3oQqHJbTuy0aDB2I+E8wrDeXRbT2KsvcC5xbFpS31ds8tNlKwtVf7MFF
         Y9Inrm03hhOEaPsSo7I63KeSFeSCHw91s4Lh8A4k/KT2vApbN3rAruLE9fWZ2OttXAUK
         51sw==
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20260707; t=1793011962; x=1793616762;
        h=content-transfer-encoding:content-type:mime-version:message-id:date
         :subject:cc:to:from:x-gm-gg:x-gm-message-state:from:to:cc:subject
         :date:message-id:reply-to:content-type;
        bh=3Em7THwSHsQndbMmwUsL9yOCeRU0YR5E1djj6NAjXMU=;
        b=kbpw+s7PnFcobYREy1g/+QNTYQfHMasOOPiC/MET6BPzQAZxBto+9OcCGX1tUEe2Ak
         SpzNRxd1hM8XA4dtBfrKlJEGxWZh6HUaebpmcREDgniWBjRuyr6PVyGBqthuOMqWdsXm
         wi7q1yIzeIYusOsde1pWvAdLMbIUsMvLNxR/6LxNvZbClJe6rbT6w8Oh46IwjED1YT4D
         W5biLWVkgJMJHwa3RCHaaFC4lyQDq52EpXniP3+ScNtXF3igOjdY9ew+TdIQM6GtkGdM
         FFEXaMJOBRNmJiXMR8KkTThScCiCvfRHJB/HAJVVuqvgfsduy2TQ5jqeQyZtVA5Q6Loz
         STXw==
X-Gm-Message-State: AFq9FYIpPxbkVk61m/mh9my0N0wXIfFHA1RKDlVwUtGr6PQni76HLGMj
	AxfTwl9yRstKmF7BNg5dUY6rd6lycxKBVhmwGKcfbYylq/9a0ks7aS9QncX+LcXFjBU=
X-Gm-Gg: AYBFou0zZ+InmmGoVlZkglVdWq9nCmrHCicEsFEbKr18IeHxv/HFk8RDBAqjRRitjMI
	EDBnaXz4nxF/mfccyCQvpSZ4YZMhSa6p4DLBXeKrNIbtACgcR5R6UzIj/FT+owpT4qp3CscMoky
	6aNmkP1FAiurTgFDVZtJxjSL3qtbC6nkTO5k3qdnkiZRBa9lXXvOhQI/g+kUJpqh8A4qPABPBGt
	Q+K0A308z2MiXDnS6vsUQuytkg4TCPg4RUKbFmAH6yvggC9q+vbCpiKQSLMDb4Qn9h6G34vmDUS
	MgrxJuLL9goSJ8rE9BOuEUKofYL1oku3Wg6zoEetU+UEmZEQnD1n/TzuDBh6BV7JohVpnGEVrbC
	sz1kRSyqZYJFp5u6LfE0buVpE2x0HE0YcLghD0KQx8bTLcpTuTsVkVlRgBGzijbIo+ChlTyretA
	hpsz5sWmMD1FY6cwZMZL61Vi4lYLp8Y+yqImerd+qiy3hE8cGGzRhP+NqA98zYwTT4mF61HRqyN
	H2Ks9mELWb+XzTk23rsW+Zz61hFu9wIaLC5jq7Bs8XuxkjO2qxngAZc99PUfUt/W8IGcxHOK6WR
	UwsfQ+7oZGDAvLUq9W3kAOnf0E4qXN6/eaUD0kOO
X-Received: by 2002:a05:693c:69c3:b0:35f:ab1:4792 with SMTP id 5a478bee46e88-369e8484992mr8381446eec.6.1793011961611;
        Mon, 26 Oct 2026 03:52:41 -0700 (PDT)
Received: from youngkk-vm.localdomain (67.216.200.102.16clouds.com. [67.216.200.102])
        by smtp.gmail.com with ESMTPSA id 5a478bee46e88-369e8db7b23sm33875226eec.19.2026.10.26.03.52.38
        (version=TLS1_3 cipher=TLS_AES_256_GCM_SHA384 bits=256/256);
        Mon, 26 Oct 2026 03:52:40 -0700 (PDT)
From: Cheng Yongkang <teel4res@gmail.com>
To: Trond Myklebust <trondmy@kernel.org>,
	Anna Schumaker <anna@kernel.org>
Cc: linux-nfs@vger.kernel.org,
	linux-kernel@vger.kernel.org,
	stable@vger.kernel.org
Subject: [PATCH v2] NFS: defer access-cache entry and group_info free past RCU
Date: Mon, 26 Oct 2026 03:52:30 -0700
Message-Id: <20261026105230.1150218-1-teel4res@gmail.com>
X-Mailer: git-send-email 2.34.1
X-Mailing-List: linux-nfs@vger.kernel.org
List-Id: <linux-nfs.vger.kernel.org>
List-Post: <mailto:linux-nfs@vger.kernel.org>
List-Help: <mailto:linux-nfs+help@vger.kernel.org>
List-Subscribe: <mailto:linux-nfs+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:linux-nfs+unsubscribe@vger.kernel.org>
List-Owner: <mailto:linux-nfs+owner@vger.kernel.org>
Precedence: list
MIME-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 8bit

nfs_access_free_entry() drops the group_info reference synchronously
while the nfs_access_entry itself is only freed after an RCU grace
period.  The lockless lookup path (nfs_access_get_cached_rcu() ->
access_cmp()) can still be walking group_info->ngroups/gid[] after the
entry was replaced and unlinked, so put_group_info() can reach
groups_free() -> kvfree() under a reader and free the array it is
reading: a slab-use-after-free read.

put_group_info() may end in kvfree(), so it cannot run from a plain RCU
callback.  Defer both the group_info reference drop and the entry free
to process context after a grace period with queue_rcu_work() on
nfsiod_workqueue.  The entry accounting (nfs_access_nr_entries) and all
call-site locking are unchanged; the work only drops the reference and
frees the entry.

On a 7.3 KASAN kernel, the following workload triggers the report: a
userspace NFSv3 server plus eight readers doing faccessat() with 2048
supplementary gids, and serialized credential replacements that detach
the previous killer's group_info reference.

 BUG: KASAN: use-after-free in nfs_access_get_cached+0xb8f/0xf80
 Read of size 4 at addr ... by task poc/9552
 Call Trace:
  nfs_access_get_cached
  nfs_do_access
  nfs_permission
  inode_permission
  do_faccessat
 Page last allocated by task ...:
  __kvmalloc_node_noprof
  __se_sys_setgroups
 Page last freed by task ...:
  nfs_access_free_entry
  nfs_access_add_cache
  nfs_do_access

The trigger needs CAP_SETGID in the guest for the setgroups-based
credential churn; the faulty read path is the ordinary access(2) /
faccessat(2) path used by any NFS user.

Link: https://lore.kernel.org/all/20261025180329.349613-1-teel4res@gmail.com/
Fixes: 6238aec83f3f ("NFS: don't store 'struct cred *' in struct nfs_access_entry")
Cc: stable@vger.kernel.org
Assisted-by: LLM
Signed-off-by: Cheng Yongkang <teel4res@gmail.com>
---
v2: add Link, Fixes and stable tags, and remove local validation details from the
commit message.

 fs/nfs/dir.c           | 21 +++++++++++++++++----
 include/linux/nfs_fs.h |  3 ++-
 2 files changed, 19 insertions(+), 5 deletions(-)

diff --git a/fs/nfs/dir.c b/fs/nfs/dir.c
--- a/fs/nfs/dir.c
+++ b/fs/nfs/dir.c
@@ -2898,10 +2898,25 @@
 module_param(nfs_access_max_cachesize, ulong, 0644);
 MODULE_PARM_DESC(nfs_access_max_cachesize, "NFS access maximum total cache length");

-static void nfs_access_free_entry(struct nfs_access_entry *entry)
+static void nfs_access_free_entry_work(struct work_struct *work)
 {
+	struct nfs_access_entry *entry =
+		container_of(to_rcu_work(work), struct nfs_access_entry, rcu_work);
+
 	put_group_info(entry->group_info);
-	kfree_rcu(entry, rcu_head);
+	kfree(entry);
+}
+
+static void nfs_access_free_entry(struct nfs_access_entry *entry)
+{
+	/*
+	 * The entry can still be reached by RCU readers that dereference
+	 * its group_info in access_cmp().  Drop the group_info reference
+	 * only after a grace period, in process context because
+	 * put_group_info() may end in kvfree().
+	 */
+	INIT_RCU_WORK(&entry->rcu_work, nfs_access_free_entry_work);
+	queue_rcu_work(nfsiod_workqueue, &entry->rcu_work);
 	smp_mb__before_atomic();
 	atomic_long_dec(&nfs_access_nr_entries);
 	smp_mb__after_atomic();
diff --git a/include/linux/nfs_fs.h b/include/linux/nfs_fs.h
--- a/include/linux/nfs_fs.h
+++ b/include/linux/nfs_fs.h
@@ -26,6 +26,7 @@
 #include <linux/refcount.h>
 #include <linux/rwsem.h>
 #include <linux/wait.h>
+#include <linux/workqueue.h>

 #include <linux/sunrpc/debug.h>
 #include <linux/sunrpc/auth.h>
@@ -65,7 +66,7 @@
 	struct group_info	*group_info;
 	u64			timestamp;
 	__u32			mask;
-	struct rcu_head		rcu_head;
+	struct rcu_work		rcu_work;
 };

 struct nfs_lock_context {
