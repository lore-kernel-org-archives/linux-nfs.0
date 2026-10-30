Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.remote-ip=209.85.160.47
ARC-Seal: i=1; d=subspace.kernel.org; s=arc20261015; a=rsa-sha256; cv=none;
	t=1793374231;
	b=FO/Ij6XfNwacxTtJnjrYdQQNQ3EhV+cJz4N6bIgsdisGA9JaHo6RX26K1LYdtfJdGRuQ
	 0QdqJeMlVi0DMALIdVtxjL078THBrxmGslAIpaCfAJQJH8v3azm5HUEvWndNj9m3F/Jol
	 HTvrV4DvByMvt5mLeSM0LiAs7H+CpqjGFxgmEiHBsqWaXSyCAJ78Dku9Q3P+d4KFXPKwk
	 4WZFJbgoyA2tZcWdrxJ/wuZq6i6SHInFdvzWkGDZTY98Go6FX/F9DV0gZJICYfJV0NjTD
	 asOwj0McYyRz25/8NPmwYUVCURtljK7+BLUeEO1EjrklYnWvK8uxgOAjTb0NWAsqvoQ==
ARC-Message-Signature: i=1; d=subspace.kernel.org; s=arc20261015;
	a=rsa-sha256; c=relaxed/relaxed; t=1793374231;
	h=DMARC-Filter:Received:DKIM-Signature:X-Google-DKIM-Signature:
	 X-Gm-Message-State:X-Gm-Gg:X-Received:Received:From:To:Cc:Subject:
	 Date:Message-ID:X-Mailer:In-Reply-To:References:MIME-Version:
	 Content-Transfer-Encoding;
	bh=x15Ozw8jvCC+DXOGPLG8S9OeJi7RPRgz1f1lR6BZmMA=;
	b=sr2fY8bh17YydEfwUfPVyECwh9dB4Xgwr2kWDw7bhpznP54Ps5c8OLtjJ8jb5YcDdxEU
	 UKxOHcJRwOL1MNz7rLizNIT3WaWrP5Xhwmo8NGmUT/5bA6UoOgDPgvZ5w6MEchjcA8gvK
	 GyZHKNsYO+coo8PYtZw68l7sRDwM2fBMiJYnfQQy1iwMNZBPyFSERlVMT9gqi8QfXhG4s
	 kBA/pgsSyDKeUuIapJW7vmx0iWc2YlFk5AqbwXgb0tHlvCPuX3g321fHbdS3EgBam/mxL
	 cGSJafqqllL79xOqoNtau7farqybBXeEsDNy0hU2qfe/nfv9ePE+9oEgC2tciaMmpLw==
ARC-Authentication-Results: i=1; smtp.subspace.kernel.org; 
	dmarc=pass header.from=hammerspace.com;
	spf=pass smtp.mailfrom=hammerspace.com;
	dkim=pass header.d=hammerspace.com header.i=@hammerspace.com header.a=rsa-sha256 header.s=google header.b=mn5IcA2x;
	arc=none smtp.remote-ip=209.85.160.47
Received: from mail-oa1-f47.google.com (mail-oa1-f47.google.com [209.85.160.47])
	(using TLSv1.3 with cipher TLS_AES_128_GCM_SHA256 (128/128 bits)
	 key-exchange X25519 server-signature ECDSA (prime256v1) server-digest SHA256)
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 6A26D606A321
	for <linux-nfs@vger.kernel.org>; Fri, 30 Oct 2026 15:30:31 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.4.2 smtp.subspace.kernel.org 6A26D606A321
Authentication-Results: smtp.subspace.kernel.org; dmarc=pass (p=quarantine dis=none) header.from=hammerspace.com
Authentication-Results: smtp.subspace.kernel.org; spf=pass smtp.mailfrom=hammerspace.com
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key, unprotected) header.d=hammerspace.com header.i=@hammerspace.com header.a=rsa-sha256 header.s=google header.b=mn5IcA2x
Received: by mail-oa1-f47.google.com with SMTP id 586e51a60fabf-4a85c656c58so535657fac.3
        for <linux-nfs@vger.kernel.org>; Fri, 30 Oct 2026 08:30:31 -0700 (PDT)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=hammerspace.com; s=google; t=1793374230; x=1793979030; darn=vger.kernel.org;
        h=content-transfer-encoding:mime-version:references:in-reply-to
         :message-id:date:subject:cc:to:from:from:to:cc:subject:date
         :message-id:reply-to:content-type;
        bh=x15Ozw8jvCC+DXOGPLG8S9OeJi7RPRgz1f1lR6BZmMA=;
        b=mn5IcA2x0aNpso3L1ZQPxUeTNGz8eZdXYOsCtOOudsGV/6yuJLIA38ZcjqnyfGLtFr
         cM8m/F0/5QuDoh1q6qgUKMybGKeS6qu0rxKs0xZq0veafoIFQZqRzsz6BkkTTP1WmV21
         apcJmdqVCMpcVEMZcss5WlWBP+6Orp9S7EgiNh5hbRq4mztaQBGnmA7VV2rltWbSV5Lk
         mZnnSdCDgIfBlHg920uhBnbZpKE9NAM49deD2XJTSnx+UDEqE15eZhxGDGR/xGTTIgn6
         TX1ZB5IMdA0RVXp7QESfY3M9aoqlVpK/l+/qq8MZ1uJL/2fS/WoCPtI2TfnMSkrxP83W
         33tA==
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20260707; t=1793374230; x=1793979030;
        h=content-transfer-encoding:mime-version:references:in-reply-to
         :message-id:date:subject:cc:to:from:x-gm-gg:x-gm-message-state:from
         :to:cc:subject:date:message-id:reply-to:content-type;
        bh=x15Ozw8jvCC+DXOGPLG8S9OeJi7RPRgz1f1lR6BZmMA=;
        b=EwYtGcIWTGX0kGi6KH6qzq/st1ZG+6r8JF8xr59gcygGAS1hF/5MAZ+lB5f6lWUN1C
         QRJtv3DPaMeSa7+3YJ8BMbUz0Vd5TYiQzWD2yUByq6BuWN51DGSlWEq00VvBf4XuNpnm
         HsbXv+vof0cwTKHlZPt6LUdQJP7M2Wx4aSnSW2bEq7oiG3Jtc2WvSQiLswd5zw31weom
         X/apzhgSNMkjUnyVX5ZjdE8Dni0Z0p/eumA8CRC535pxYKxah1qh1e7QzC6N+n5IIgl0
         QSctXMOnYZNpT0mcVfBxNaqCipLX2x4llio/OBfG7P1YQEuz5zBSh0/3Xbt2klGC5JDI
         dwRA==
X-Gm-Message-State: AFq9FYKGj5ghZg9w4Po/b+vuyNxV2GI+tOoCYqK4zEgXmoTBHkzD2NLf
	BasK72H7s7zoKHTCZCTHWNBH8C8T1fwQiUFnO0oSWStZyxAQcKPsPPelCRzZf+AvTy4=
X-Gm-Gg: AYBFou3cK7DmX+CSbFalWNf3YCm22JWdQnAnkQIQPAz0kkyXNDNtZlkuZyXT3P4CMev
	OiqgYPrm6lEXUbuqGcRNizJnPgBgwN69Vu+j4oU/a8mxHUTx9ZrHZ7IxyRwVzoW/wxDHVC7/gzz
	V3reLqBO8bqiofwZSFrlv6a5FvRkrN/0aQfzXDEqNTKGT9WDksYrIxBnSL6YsKTf8nFMyodxrct
	5Z/UF8ZFT977qRSzHxZa/IMEYXd7EOnStcoOy33i1t8FsZ+P44sx3RiaEc/yAC9hkyjFs5l9tJg
	aSsqUAV2Wi1LJGlyL4pqX8VxKtRs3IHLj5owmtoivR6vv4JXk7OBZlF7REDDUptxFdwsObekEyx
	Y3jyfgeXRbuqLGjEMsZLN0eBC99wlvusHgBXTkotpCTlm/RNK7U59h7NGVP9QiLuF8h6s+oueO6
	4ENrMx2ePxhs9lMEQJS3WL3ZpZq9V1Mc9zgeFFmPe4rk8iocINTh37F66VNhvoBCi83WBdwmNpQ
	f0we/mvf/q2VSgt3V3h2c/j7Ybfw6/e1FgBfJSBPbgnyDfscTWe6Yk6/qUbmZYHMIUuPQchD3rY
	D+Yyd6nGbCs0J4cFJDy01YXmdqeis1B5+ZhQ6vP/XIXUPGdtBMffPkeSLs57KWXOiG9c5ctaGEh
	pxtJD27wSIPsnfcB77N++9us/G6S8j0A=
X-Received: by 2002:a05:6808:3c48:b0:4f4:d7:b16d with SMTP id 5614622812f47-5640de8713amr1841802b6e.60.1793374230287;
        Fri, 30 Oct 2026 08:30:30 -0700 (PDT)
Received: from bcodding.csb.hammerspace.com (219.sub-174-201-19.myvzw.com. [174.201.19.219])
        by smtp.gmail.com with ESMTPSA id 5614622812f47-5640fe0fda0sm1840376b6e.13.2026.10.30.08.30.29
        (version=TLS1_3 cipher=TLS_AES_256_GCM_SHA384 bits=256/256);
        Fri, 30 Oct 2026 08:30:29 -0700 (PDT)
From: Benjamin Coddington <ben.coddington@hammerspace.com>
To: Trond Myklebust <trondmy@kernel.org>,
	Anna Schumaker <anna@kernel.org>,
	Mike Snitzer <snitzer@kernel.org>
Cc: linux-nfs@vger.kernel.org
Subject: [PATCH v2 4/6] pNFS: don't send _NOMATCHING_LAYOUT if still doing IO on a layout
Date: Fri, 30 Oct 2026 11:30:20 -0400
Message-ID: <11bd5962578d12aeed09eab7d5424bbc49447abc.1793373378.git.bcodding@hammerspace.com>
X-Mailer: git-send-email 2.53.0
In-Reply-To: <cover.1793373378.git.bcodding@hammerspace.com>
References: <cover.1793373378.git.bcodding@hammerspace.com>
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
the recall has completed.  The same happens on the first recall if another
path, such as a DS error, invalidated the layout stateid while I/O was
outstanding.

When answering a bulk recall, don't skip an invalid layout that still has
segments.  pnfs_mark_layout_stateid_invalid() reports them, and the recall
is answered with NFS4ERR_DELAY until the last segment is freed.
CB_RECALL_ANY takes the same path, so it also blocks LAYOUTGET on these
layouts until they drain.  This relies on "pNFS: clear
NFS_LAYOUT_BULK_RECALL when an invalid layout's last segment is freed"
to clear the flag once the layout drains.

The other walkers, used by reboot recovery and when recallable state is
revoked, keep skipping these layouts.  They send no reply to the server,
and reboot recovery would otherwise retry on -EAGAIN without sleeping
until the I/O completed.

Fixes: b85f562049cc ("pNFS: Skip invalid stateids when doing a bulk destroy")
Signed-off-by: Benjamin Coddington <bcodding@hammerspace.com>
---
v3: test for remaining segments instead of NFS_LAYOUT_BULK_RECALL, so a
    layout invalidated by another path with I/O outstanding is also
    answered with NFS4ERR_DELAY.
v2: only revisit these layouts when answering a bulk recall, so that
    reboot recovery doesn't loop on -EAGAIN while the I/O is outstanding.
---
 fs/nfs/pnfs.c | 18 +++++++++++-------
 1 file changed, 11 insertions(+), 7 deletions(-)

diff --git a/fs/nfs/pnfs.c b/fs/nfs/pnfs.c
index 393de479da3b..a23bcb8503be 100644
--- a/fs/nfs/pnfs.c
+++ b/fs/nfs/pnfs.c
@@ -846,7 +846,8 @@ pnfs_layout_add_bulk_destroy_list(struct inode *inode,
 static int
 pnfs_layout_bulk_destroy_byserver_locked(struct nfs_client *clp,
 		struct nfs_server *server,
-		struct list_head *layout_list)
+		struct list_head *layout_list,
+		enum pnfs_layout_destroy_mode mode)
 	__must_hold(&clp->cl_lock)
 	__must_hold(RCU)
 {
@@ -854,7 +855,9 @@ pnfs_layout_bulk_destroy_byserver_locked(struct nfs_client *clp,
 	struct inode *inode;
 
 	list_for_each_entry_safe(lo, next, &server->layouts, plh_layouts) {
-		if (test_bit(NFS_LAYOUT_INVALID_STID, &lo->plh_flags) ||
+		if ((test_bit(NFS_LAYOUT_INVALID_STID, &lo->plh_flags) &&
+		     (mode != PNFS_LAYOUT_BULK_RETURN ||
+		      list_empty(&lo->plh_segs))) ||
 		    test_bit(NFS_LAYOUT_INODE_FREEING, &lo->plh_flags) ||
 		    !list_empty(&lo->plh_bulk_destroy))
 			continue;
@@ -933,7 +936,7 @@ int pnfs_layout_destroy_byfsid(struct nfs_client *clp, struct nfs_fsid *fsid,
 			continue;
 		if (pnfs_layout_bulk_destroy_byserver_locked(clp,
 				server,
-				&layout_list) != 0)
+				&layout_list, mode) != 0)
 			goto restart;
 	}
 	rcu_read_unlock();
@@ -943,7 +946,8 @@ int pnfs_layout_destroy_byfsid(struct nfs_client *clp, struct nfs_fsid *fsid,
 }
 
 static void pnfs_layout_build_destroy_list_byclient(struct nfs_client *clp,
-						    struct list_head *list)
+						    struct list_head *list,
+						    enum pnfs_layout_destroy_mode mode)
 {
 	struct nfs_server *server;
 
@@ -952,7 +956,7 @@ static void pnfs_layout_build_destroy_list_byclient(struct nfs_client *clp,
 restart:
 	list_for_each_entry_rcu(server, &clp->cl_superblocks, client_link) {
 		if (pnfs_layout_bulk_destroy_byserver_locked(clp, server,
-							     list) != 0)
+							     list, mode) != 0)
 			goto restart;
 	}
 	rcu_read_unlock();
@@ -963,7 +967,7 @@ static int pnfs_layout_do_destroy_byclid(struct nfs_client *clp,
 					 struct list_head *list,
 					 enum pnfs_layout_destroy_mode mode)
 {
-	pnfs_layout_build_destroy_list_byclient(clp, list);
+	pnfs_layout_build_destroy_list_byclient(clp, list, mode);
 	return pnfs_layout_free_bulk_destroy_list(list, mode);
 }
 
@@ -1000,7 +1004,7 @@ static void pnfs_layout_build_recover_list_byclient(struct nfs_client *clp,
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

