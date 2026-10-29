Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.remote-ip=209.85.167.173
ARC-Seal: i=1; d=subspace.kernel.org; s=arc20261015; a=rsa-sha256; cv=none;
	t=1793299323;
	b=u+YQEpHht8xJf+ofluQfS7E2gYheE6SZqy0HTblIR90AY4Ak3q/2vJeQQX6vDIKK6s37
	 ZdUjnC5S0XKnAM50m+2RG5x/4qIB/gt7OfTAuwHXjyWClegrFs20vL5K95IORvEpdy7WI
	 HIrpKnPhrIhspOajebg2wwC3jFWHlq8XlzIZtQT/9KstGAi/HSUiKyveqOqAFIMCLJsp4
	 vkF8AxOJvk8TPW0d0aoU5lob+oTtlb8+5/kCNQQWjzyrz4KcJ9+cpQe6nvXyplMY8JwjE
	 dInniLjtAiF7JyAtAbMQPTfB9StZzs54j+fAS6+CbUF1t5SIToz80PWryKdiFVN9ssA==
ARC-Message-Signature: i=1; d=subspace.kernel.org; s=arc20261015;
	a=rsa-sha256; c=relaxed/relaxed; t=1793299323;
	h=DMARC-Filter:Received:DKIM-Signature:X-Google-DKIM-Signature:
	 X-Gm-Message-State:X-Gm-Gg:X-Received:Received:From:To:Cc:Subject:
	 Date:Message-ID:X-Mailer:In-Reply-To:References:MIME-Version:
	 Content-Transfer-Encoding;
	bh=tV4RBjTx7Wl4ZN6hdiO9tQ1/KM9uIacPIvMREM6GoSI=;
	b=PkdVLvY7mn8j8iI6uYs+hgh08Z+4f/ENFDBqQ8GRtcBeo6h+P4sQ3Q9N8qbBs5YRLnn/
	 8w4Se0IjXR4pztLXz0s7rHZF1LPBz2uaPleDIvkfiU6Xy2t4tPztdCkq4ah46/KdejGgL
	 PoMhSU86ocVCZ98/83gNm3MQamlYJkeGbYn0mzcYV5x9DoUpcjK69/h6dgemhQPc+7WrE
	 Tcbk08kdh3EBp3Fj3j60iMzRnzl1FCwajReTA2VsluoQhkDBMkpAmBxuY6uZhUBM5vn4N
	 HUfyIGUtzKXbWWMDE6pS7fkH0J/fgKVNZ3xsHgEIbxZlClwE0KpIXMp6f6odloQ5bJg==
ARC-Authentication-Results: i=1; smtp.subspace.kernel.org; 
	dmarc=pass header.from=hammerspace.com;
	spf=pass smtp.mailfrom=hammerspace.com;
	dkim=pass header.d=hammerspace.com header.i=@hammerspace.com header.a=rsa-sha256 header.s=google header.b=pzAdM5K1;
	arc=none smtp.remote-ip=209.85.167.173
Received: from mail-oi1-f173.google.com (mail-oi1-f173.google.com [209.85.167.173])
	(using TLSv1.3 with cipher TLS_AES_128_GCM_SHA256 (128/128 bits)
	 key-exchange X25519 server-signature ECDSA (prime256v1) server-digest SHA256)
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 40173606A31E
	for <linux-nfs@vger.kernel.org>; Thu, 29 Oct 2026 18:42:03 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.4.2 smtp.subspace.kernel.org 40173606A31E
Authentication-Results: smtp.subspace.kernel.org; dmarc=pass (p=quarantine dis=none) header.from=hammerspace.com
Authentication-Results: smtp.subspace.kernel.org; spf=pass smtp.mailfrom=hammerspace.com
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key, unprotected) header.d=hammerspace.com header.i=@hammerspace.com header.a=rsa-sha256 header.s=google header.b=pzAdM5K1
Received: by mail-oi1-f173.google.com with SMTP id 5614622812f47-4b21f71613fso1674467b6e.2
        for <linux-nfs@vger.kernel.org>; Thu, 29 Oct 2026 11:42:03 -0700 (PDT)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=hammerspace.com; s=google; t=1793299322; x=1793904122; darn=vger.kernel.org;
        h=content-transfer-encoding:mime-version:references:in-reply-to
         :message-id:date:subject:cc:to:from:from:to:cc:subject:date
         :message-id:reply-to:content-type;
        bh=tV4RBjTx7Wl4ZN6hdiO9tQ1/KM9uIacPIvMREM6GoSI=;
        b=pzAdM5K11rultecKwJxU7KS0kmSBNjf/jA+der/8rhj7/ULblUoCH2IlYRurpXHjuD
         H1vAQ6Wn2OjflOW4VWCKZSq9a0fit56S8azVG+R5SC9nlmIQrD2Zb6odGzt/Tjecck0R
         IjNoBkyHNpEgGr37L3a4aJIAhy03F81AnXL7beuBAcIFQAdieef69XjAcszbCCocFcFm
         tBzgeR7CobEE4CHMXgwJlVeZid3k/QG5ewZwVfKmXeRqkgz1kjnd82brPpafpJFXBEkq
         AxoL2ksdU69ymttzcqPP6mbWvWDnNUANhZ76Rd+I79hfF9g2qf0iOGdzA7YeztEx7q7O
         2cfw==
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20260707; t=1793299322; x=1793904122;
        h=content-transfer-encoding:mime-version:references:in-reply-to
         :message-id:date:subject:cc:to:from:x-gm-gg:x-gm-message-state:from
         :to:cc:subject:date:message-id:reply-to:content-type;
        bh=tV4RBjTx7Wl4ZN6hdiO9tQ1/KM9uIacPIvMREM6GoSI=;
        b=y+mWJmRllDb9UBezI+CNvxjQH6FyJ9KPdTF8OyJQBa51ioASZbWLCRnD/pAbTEOZuC
         cZN0lDR/F6k7Dat1q1fVq1FjcxXhvyxYSGDW0rsBmB+KfBdJ4It5T0bfF8fZjWD6rTu9
         msH7E3gZ5UJ1aBetU8fxh070j/NJ3LdqCBe9GEn0NfKAzcrKXhq9tGGlQr6JAP9ZtTln
         9YIXAqcL7BAoZ9i4FLaoxMoIOIF1EkNIX+XmVEWc/Nz+DY8WdacFXRoNGPKCBuVncqt5
         wKIPudaeDPsUJWK33dJzppC7u0jS1CqPMw34w2WAhxJBK1MkNMXFfiKHCmfv+3v88bDl
         r/qg==
X-Gm-Message-State: AFq9FYL0ma5XXMahCh8eiFrkNGTQPG0kJo73tH9v+TcDqje9wRRT26+g
	VbZGIN6Ch1VBO/ValIFZiyJL20SNbyvQlE5lR5Gwb34Xe518h1iKHD9xbaEKZ6j44EfxoSIijva
	P113J
X-Gm-Gg: AYBFou1Si3T4QMWCJFZEyC+CwiP3DsMW3dd+ZJ1nCUyzyU0rXl7BfKnGodn+atVjJdC
	hWFWfWnFbw6UbYDlK+wx1FDp+yQyGZ9Od64goxSeqRG0UNxcqURFQpttiPeYirVDl1tjPGHKJCg
	t7TMvzvmfen+QE2S4EYlliq2o9fySq6Dbg4GbrDUQX84ECr6ZYc/ppt/fGaNSqbaSFnZxtY0Ryh
	OfNCEFtx8kY2Ww3aO5XViDlpWkjSa1C35pvA8YikpNSmD1qsBVy6/aV8t77cY4BC9WD/YtfxGzL
	2WBBOCL7X4Hy3uQc73IuPEkT2c8Qi/o9b6H2T7lTV4eBVqns0C2RT/XGTQIDaMy8PxF2l0DlfQ0
	ycfHQ1lkVxbb8Z/YiNANWJCE3kCSSY3DCAU9KhHTFzi3ddUXm/bgquRZyaWoSNA7Taqp5uZf1s/
	lgCNdHCs9twt4+khBQeKOjS+6NYSZJO9wAlwjyYOx/gAlLvZNdsf7nKVg474Zza/u8NXvC3Sy5n
	fZOea43g0uKMUS8jECgNWze2/6Y3829Votpr+3Kqnxk3LQv2/YG7rBRuPUvgPv90BrGaUyos8dL
	1oMw9NC+Um6a0vCsPhHC50IG7EIdBjB3DZLzWZ8mKC/XNtNG2fCijO7bNq+EiWNjrgYj6jsiJ7k
	M
X-Received: by 2002:a05:6808:23c2:b0:4f4:7dda:99bb with SMTP id 5614622812f47-5640df7573dmr51028b6e.33.1793299322119;
        Thu, 29 Oct 2026 11:42:02 -0700 (PDT)
Received: from bcodding.csb.hammerspace.com ([12.117.181.174])
        by smtp.gmail.com with ESMTPSA id 5614622812f47-5640e23b76asm7161b6e.11.2026.10.29.11.42.00
        (version=TLS1_3 cipher=TLS_AES_256_GCM_SHA384 bits=256/256);
        Thu, 29 Oct 2026 11:42:01 -0700 (PDT)
From: Benjamin Coddington <ben.coddington@hammerspace.com>
To: Trond Myklebust <trondmy@kernel.org>,
	Anna Schumaker <anna@kernel.org>,
	Mike Snitzer <snitzer@kernel.org>
Cc: linux-nfs@vger.kernel.org
Subject: [PATCH 4/6] pNFS: don't send _NOMATCHING_LAYOUT if still doing IO on a layout
Date: Thu, 29 Oct 2026 14:41:52 -0400
Message-ID: <eaeab1fde6122edd52878588bf9d130aac16295a.1793298149.git.bcodding@hammerspace.com>
X-Mailer: git-send-email 2.53.0
In-Reply-To: <cover.1793298149.git.bcodding@hammerspace.com>
References: <cover.1793298149.git.bcodding@hammerspace.com>
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
index 5ba3ea23354d..70b3429726c9 100644
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

