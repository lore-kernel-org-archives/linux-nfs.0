Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.remote-ip=209.85.210.47
ARC-Seal: i=1; d=subspace.kernel.org; s=arc20261015; a=rsa-sha256; cv=none;
	t=1793202978;
	b=4tFLyoo4NzEtSgxRjCYbU3N1UtbNqoGZUEPDAKraasLJ94l59ZFaTxMLDfvsnHwjIwTX
	 tYI2j89/tvrS4+z2xDh8PjM6om3J2FBu+BvW+UDM5xR8w7r40QrF59TaeeTk+koAXR0O/
	 K3q3vSrW/1OpDe++kcDhQt65DRhqpWZ5XbP27etbKXJzjfFU5YTGoEKs6eusNXFMIF2Lv
	 aXDP43053VL/2ioWwwU3MPRHru0q/QHVj1OvLq8HVudC2dWRL4+jPcGLVsUqyoFbCqDth
	 qHeuPZSJjKrzGyXok3CFdITLFFTWGx4IXBdR4/tx9s6ijSh9Q+JT9PQVo3+bJiXBU3w==
ARC-Message-Signature: i=1; d=subspace.kernel.org; s=arc20261015;
	a=rsa-sha256; c=relaxed/relaxed; t=1793202978;
	h=DMARC-Filter:Received:DKIM-Signature:X-Google-DKIM-Signature:
	 X-Gm-Message-State:X-Gm-Gg:X-Received:Received:From:To:Cc:Subject:
	 Date:Message-ID:X-Mailer:MIME-Version:Content-Transfer-Encoding;
	bh=TwQ0+8ZvdUT1O3GPDhpAHooDamQzPq6EqiTfiCc09AA=;
	b=blmQ8odB7R5nbX8JwPhUtZDcTPhLJxXzVYYmzsmgN5kWcfvmklMEKrLGEzUfT87TIGqa
	 a+eCv5RBbpsjPFkyOYA6IHURDWjGag95xIAzohdvLYxtmWBOMqbcSBcH/DZDlyjq9O0sU
	 8YyY56x7euUeOxqhctiObmw88NpBshXGnX5E5swZRLgOovuwlbRBegTZ54KE+9Y302Puq
	 6FI+esI36SSW7Nfk0HGyqfH5bF37SRRPfZJTI8sHobj8vY5A3gIbngiiqkBgx00cI76vB
	 xuO1BYrFVV1WeWOfwRCrLKWsMGRw/pNhrYArDPloh+R/mP9ePSbcDxw2/UyVlXmh4rA==
ARC-Authentication-Results: i=1; smtp.subspace.kernel.org; 
	dmarc=pass header.from=hammerspace.com;
	spf=pass smtp.mailfrom=hammerspace.com;
	dkim=pass header.d=hammerspace.com header.i=@hammerspace.com header.a=rsa-sha256 header.s=google header.b=oApL3Q7W;
	arc=none smtp.remote-ip=209.85.210.47
Received: from mail-ot1-f47.google.com (mail-ot1-f47.google.com [209.85.210.47])
	(using TLSv1.3 with cipher TLS_AES_128_GCM_SHA256 (128/128 bits)
	 key-exchange X25519 server-signature ECDSA (prime256v1) server-digest SHA256)
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id D2F14606A336
	for <linux-nfs@vger.kernel.org>; Wed, 28 Oct 2026 15:56:10 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.4.2 smtp.subspace.kernel.org D2F14606A336
Authentication-Results: smtp.subspace.kernel.org; dmarc=pass (p=quarantine dis=none) header.from=hammerspace.com
Authentication-Results: smtp.subspace.kernel.org; spf=pass smtp.mailfrom=hammerspace.com
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key, unprotected) header.d=hammerspace.com header.i=@hammerspace.com header.a=rsa-sha256 header.s=google header.b=oApL3Q7W
Received: by mail-ot1-f47.google.com with SMTP id 46e09a7af769-823b938464fso788078a34.2
        for <linux-nfs@vger.kernel.org>; Wed, 28 Oct 2026 08:56:10 -0700 (PDT)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=hammerspace.com; s=google; t=1793202970; x=1793807770; darn=vger.kernel.org;
        h=content-transfer-encoding:mime-version:message-id:date:subject:cc
         :to:from:from:to:cc:subject:date:message-id:reply-to:content-type;
        bh=TwQ0+8ZvdUT1O3GPDhpAHooDamQzPq6EqiTfiCc09AA=;
        b=oApL3Q7W5ylq5BLgCO8at4e4Oa7bQTrQazQyO3s4IrwroRBscKdwNEfffQ8IJLIG/V
         mwJwQscDtS3Q5UWKIyKgHnDQEaTY8e8x1AkjRzJkeRwYVRmlp8u1CleycOCYvLAuc3to
         IYa7eyujOo9sPAmfYyQ43riLmy1BdbEUZimH+eChjaqinkg9zIzwpgy3/0jE+H/TrlDz
         NDhwuxhB5i422icJv9UKcK2z4OzuwwH+uj5XBk7ywhqzaViwYWXAQVLscyHKMmexjk3Z
         recxDlIMrxpwPRq8TQjv2QNQKOAoKYTwjFW8FSUhjfmuY9xpw90+VUgC2ruSFKsHeMXf
         U2sA==
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20260707; t=1793202970; x=1793807770;
        h=content-transfer-encoding:mime-version:message-id:date:subject:cc
         :to:from:x-gm-gg:x-gm-message-state:from:to:cc:subject:date
         :message-id:reply-to:content-type;
        bh=TwQ0+8ZvdUT1O3GPDhpAHooDamQzPq6EqiTfiCc09AA=;
        b=P3P6+cwT/+zopkkiu06HeJ+V0jQUpW3MZfKFgMVfKsqmE4EWU18XmH/0lYIfb/rE/z
         WWSZAcQp+ER+o9reFFRPZvSu2CV3rZYeMDQAYJ66/6wbCcqtqH/I1nmawl1pzdoGa7YQ
         PtHZZNX0t9AAFbqgyocBvy0/53BNQPm31QLHii6Z9lc6+Fm/Mvt7RRUhWSHnKnD47slN
         03WUQxFq1qv+ItRnQgaIoHwHxWqP5mDABnNyhkdnfSTUI4BF1GTU2q6OYnjUAp+C67yl
         iLqVDVKOofz8ZC94eSACHwtRY3gZ8bfVnj83KJXvmooWmwPXTWQLKelY/Z5QzPdu0tA6
         74Jw==
X-Gm-Message-State: AFq9FYLZiMBXG18epsBHLv2CEHrF1aDGeMh/xaw9pAq6lWOxd/HWw/S5
	xWrMNTQiYylo6nvHRNtfODFd71M/hFXZfiYaOIodpyL0KqKCYvLGGcCyJuqugLc0NqgyAW1irwX
	6jXMj
X-Gm-Gg: AYBFou3mW4bHVQx5MLsayA/keXVzblqQqojxiPUsjXDuGVgJ6wEW481keqU9o+/JvD1
	h6XN9mFEBgYbaVxxTffSS+El2HFNMPx5tkjvy83dYARplvrSV7/ps0BTVmpoktf85RGu3Tymx2y
	ZWNGKLA0IHdNGaN5qtuqSXhFPx1t88BU7UVh5BI+Sq+SxysZQ1XnGkCcIQ04z4AcnzwC9V5BlFr
	nphXu7DvabHI/ce4CnoOzzwpr0SBQZJOWtQKsp0xFueMjTL36rqb8qNTNVnmcknWz8J+GSEFQfv
	yfLT8JXKUsD3xUTMK8mahVG87oSdfObKk0jERjMVEWFpnnxc16fGP+rRRiq0hZTCLF84oy51HBy
	i5rA8vRfEDhpZn+Br7U7Fi9EQYXIvP84YTE3WgnDVgyIadT2IbJZQjhCr782T06FTbKzRe4pRT6
	GeA/vjvc/kZqSeZClkoTkiOgjUkym6XHE/6PEScp3NlzNC1aZt6LBgHlHGcoxkEmmBwd+vb1/Bp
	kYeOm0sm9o7Pmcq9zaWSzs87Q432LnkmoZ7CwidRos727u1TadS7nMJ1paFLTLfeXav3MGAnSAb
	BZwFj4erdRwmNyoQmEAilU74yyBW+O7tBW61lIrbTsFENlj6UNo/RiKfVVxHQyPzDOZqreEY8aC
	t
X-Received: by 2002:a05:6808:1b06:b0:53c:af69:84dd with SMTP id 5614622812f47-563821793camr1813628b6e.12.1793202969693;
        Wed, 28 Oct 2026 08:56:09 -0700 (PDT)
Received: from bcodding.csb.hammerspace.com ([12.117.181.174])
        by smtp.gmail.com with ESMTPSA id 5614622812f47-563ee386839sm198427b6e.0.2026.10.28.08.56.08
        (version=TLS1_3 cipher=TLS_AES_256_GCM_SHA384 bits=256/256);
        Wed, 28 Oct 2026 08:56:09 -0700 (PDT)
From: Benjamin Coddington <ben.coddington@hammerspace.com>
To: Trond Myklebust <trondmy@kernel.org>,
	Anna Schumaker <anna@kernel.org>
Cc: linux-nfs@vger.kernel.org
Subject: [PATCH v2] pNFS: don't send _NOMATCHING_LAYOUT if still doing IO on a layout
Date: Wed, 28 Oct 2026 11:56:07 -0400
Message-ID: <2e7ae55d6eacf80d2b65f7231933460dd198ae49.1793134903.git.bcodding@hammerspace.com>
X-Mailer: git-send-email 2.53.0
X-Mailing-List: linux-nfs@vger.kernel.org
List-Id: <linux-nfs.vger.kernel.org>
List-Post: <mailto:linux-nfs@vger.kernel.org>
List-Help: <mailto:linux-nfs+help@vger.kernel.org>
List-Subscribe: <mailto:linux-nfs+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:linux-nfs+unsubscribe@vger.kernel.org>
List-Owner: <mailto:linux-nfs+owner@vger.kernel.org>
Precedence: list
MIME-Version: 1.0
Content-Transfer-Encoding: 8bit

From: Benjamin Coddington <bcodding@hammerspace.com>

When a bulk CB_LAYOUTRECALL finds layout segments still referenced by
outstanding I/O, pnfs_layout_free_bulk_destroy_list() invalidates the
layout stateid, sets NFS_LAYOUT_BULK_RECALL, and the client replies
NFS4ERR_DELAY.  If the server resends the recall, then
pnfs_layout_bulk_destroy_byserver_locked() can skip layouts with an invalid
stateid, so the resend finds nothing and the client replies
NFS4ERR_NOMATCHING_LAYOUT with the I/O still in flight.  The server then
treats the layout as gone, and that I/O can reach the storage device after
the recall has completed.

When answering a bulk recall, don't skip an invalid layout that still has
NFS_LAYOUT_BULK_RECALL set.  pnfs_mark_layout_stateid_invalid() reports its
remaining segments, and the recall is answered with NFS4ERR_DELAY until the
last segment is freed and the flag is cleared.

The other walkers, reboot recovery and lease expiry, keep skipping these
layouts.  They send no reply to the server, and reboot recovery would
otherwise retry on -EAGAIN without sleeping until the I/O completed.

Fixes: b85f562049cc ("pNFS: Skip invalid stateids when doing a bulk destroy")
Signed-off-by: Benjamin Coddington <bcodding@hammerspace.com>
---
v2: only revisit these layouts when answering a bulk recall, so that
    reboot recovery doesn't loop on -EAGAIN while the I/O is outstanding.
---
 fs/nfs/pnfs.c | 18 +++++++++++-------
 1 file changed, 11 insertions(+), 7 deletions(-)

diff --git a/fs/nfs/pnfs.c b/fs/nfs/pnfs.c
index 4f9c0f639014..00acd9827395 100644
--- a/fs/nfs/pnfs.c
+++ b/fs/nfs/pnfs.c
@@ -845,7 +845,8 @@ pnfs_layout_add_bulk_destroy_list(struct inode *inode,
 static int
 pnfs_layout_bulk_destroy_byserver_locked(struct nfs_client *clp,
 		struct nfs_server *server,
-		struct list_head *layout_list)
+		struct list_head *layout_list,
+		enum pnfs_layout_destroy_mode mode)
 	__must_hold(&clp->cl_lock)
 	__must_hold(RCU)
 {
@@ -853,7 +854,9 @@ pnfs_layout_bulk_destroy_byserver_locked(struct nfs_client *clp,
 	struct inode *inode;
 
 	list_for_each_entry_safe(lo, next, &server->layouts, plh_layouts) {
-		if (test_bit(NFS_LAYOUT_INVALID_STID, &lo->plh_flags) ||
+		if ((test_bit(NFS_LAYOUT_INVALID_STID, &lo->plh_flags) &&
+		     (mode != PNFS_LAYOUT_BULK_RETURN ||
+		      !test_bit(NFS_LAYOUT_BULK_RECALL, &lo->plh_flags))) ||
 		    test_bit(NFS_LAYOUT_INODE_FREEING, &lo->plh_flags) ||
 		    !list_empty(&lo->plh_bulk_destroy))
 			continue;
@@ -932,7 +935,7 @@ int pnfs_layout_destroy_byfsid(struct nfs_client *clp, struct nfs_fsid *fsid,
 			continue;
 		if (pnfs_layout_bulk_destroy_byserver_locked(clp,
 				server,
-				&layout_list) != 0)
+				&layout_list, mode) != 0)
 			goto restart;
 	}
 	rcu_read_unlock();
@@ -942,7 +945,8 @@ int pnfs_layout_destroy_byfsid(struct nfs_client *clp, struct nfs_fsid *fsid,
 }
 
 static void pnfs_layout_build_destroy_list_byclient(struct nfs_client *clp,
-						    struct list_head *list)
+						    struct list_head *list,
+						    enum pnfs_layout_destroy_mode mode)
 {
 	struct nfs_server *server;
 
@@ -951,7 +955,7 @@ static void pnfs_layout_build_destroy_list_byclient(struct nfs_client *clp,
 restart:
 	list_for_each_entry_rcu(server, &clp->cl_superblocks, client_link) {
 		if (pnfs_layout_bulk_destroy_byserver_locked(clp, server,
-							     list) != 0)
+							     list, mode) != 0)
 			goto restart;
 	}
 	rcu_read_unlock();
@@ -962,7 +966,7 @@ static int pnfs_layout_do_destroy_byclid(struct nfs_client *clp,
 					 struct list_head *list,
 					 enum pnfs_layout_destroy_mode mode)
 {
-	pnfs_layout_build_destroy_list_byclient(clp, list);
+	pnfs_layout_build_destroy_list_byclient(clp, list, mode);
 	return pnfs_layout_free_bulk_destroy_list(list, mode);
 }
 
@@ -999,7 +1003,7 @@ static void pnfs_layout_build_recover_list_byclient(struct nfs_client *clp,
 		if (!(server->caps & NFS_CAP_REBOOT_LAYOUTRETURN))
 			continue;
 		if (pnfs_layout_bulk_destroy_byserver_locked(clp, server,
-							     list) != 0)
+					list, PNFS_LAYOUT_INVALIDATE) != 0)
 			goto restart;
 	}
 	rcu_read_unlock();
-- 
2.53.0

