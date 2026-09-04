Received: from mail-qk1-f173.google.com (mail-qk1-f173.google.com [209.85.222.173])
	(using TLSv1.2 with cipher ECDHE-RSA-AES128-GCM-SHA256 (128/128 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 934F64FC8D5
	for <linux-nfs@vger.kernel.org>; Fri,  4 Sep 2026 16:53:27 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=209.85.222.173
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1788540809; cv=none; b=lpX/NOmgvzDAuQ3tcvKPtTPoYI3cZCQpZVYH8CCXRgeR01jIZsJW3kr/9jnwd18gQh/7U6aggk2OIesUxHmyvviyTZ3kgGrg9mU7zxUpSRxBm6r7Ct5079FsGOnCqmg0oqPv0139i5Elu0IdKDgPwCqB778w4gvg/UlctRfamS4=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1788540809; c=relaxed/simple;
	bh=UL8KFNWk7lNJYm0ZnrWATxloH4b6T+ed7rGFAQbjp/k=;
	h=From:To:Cc:Subject:Date:Message-ID:In-Reply-To:References:
	 MIME-Version; b=bbqfkNgRced2YR/T/l7ducEsblQttT2+GWFcaQVdPdrGvBzahlIYINCOuTkiCa+gmE1red7Or2/G1C5/yBd2A4sOi3R9E44p0P+/fVut0upbz6HYbmb0G7jZ94HzIB+/irjNlE5PXeIeRPUOdQStEsN12NPwCsbvyWyO8eyNvUA=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dmarc=pass (p=quarantine dis=none) header.from=hammerspace.com; spf=pass smtp.mailfrom=hammerspace.com; dkim=pass (2048-bit key) header.d=hammerspace.com header.i=@hammerspace.com header.b=hEtNUww8; arc=none smtp.client-ip=209.85.222.173
Authentication-Results: smtp.subspace.kernel.org; dmarc=pass (p=quarantine dis=none) header.from=hammerspace.com
Authentication-Results: smtp.subspace.kernel.org; spf=pass smtp.mailfrom=hammerspace.com
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=hammerspace.com header.i=@hammerspace.com header.b="hEtNUww8"
Received: by mail-qk1-f173.google.com with SMTP id af79cd13be357-936623c6dd3so280159985a.0
        for <linux-nfs@vger.kernel.org>; Fri, 04 Sep 2026 09:53:27 -0700 (PDT)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=hammerspace.com; s=google; t=1788540806; x=1789145606; darn=vger.kernel.org;
        h=content-transfer-encoding:mime-version:references:in-reply-to
         :message-id:date:subject:cc:to:from:from:to:cc:subject:date
         :message-id:reply-to:content-type;
        bh=oHQ8BbMYCaCngVy3DUvFYsHhavmNY+fsgd9aZs+DdME=;
        b=hEtNUww8yCunkUeyslxI07Z/yyGiXXipwfLb9RuQGeUpdPQYKS/HOI6O2rOsLfZn5q
         i+THFKG5IkaChgEWTNhwvbwjiGjPMrsXGrUn1FBsbbqien/9dOqBd0FjGPF5yfKq1i69
         UMz9+Ca/3qRwhiTT+nzDUChsVFywQjZYMZsqg7EPUiHneAoWF4ZRvGVrhOtxTjQp3iKR
         B/0tunHqzXlf1tOrMWwYMJSoAGVmQrEyHzw6AFkI4TqKDXjFfrVvDHNvbVDngzoC+law
         MqBTV066NEQiwIa9o+m18yz9AplDNhWDIRm8HJrrxNXyHo2Ur+XqfJ48pEiXwNzAQzom
         3Sew==
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20251104; t=1788540806; x=1789145606;
        h=content-transfer-encoding:mime-version:references:in-reply-to
         :message-id:date:subject:cc:to:from:x-gm-gg:x-gm-message-state:from
         :to:cc:subject:date:message-id:reply-to:content-type;
        bh=oHQ8BbMYCaCngVy3DUvFYsHhavmNY+fsgd9aZs+DdME=;
        b=fRNA9LJUuCpOTFjmnPXcjjzIuFFwOtcFAtvqN7DCdPBqwKfphQksPEi+hIcYXliHpG
         2z2q1OhZZUHNKLwTedVZuB5d/3U+i+oC48AZd4p9RaK/P4hlRU6vJTS31goLakXbEq7w
         rAp1Xvt08ni6NLBqZFf5eCQotey80PYWl+lYfMHrkq/08/z5p/Ksvfx4osgvZ2bb9hna
         mwMtIFyG58YF7Jwz+6zk+d1R9/lOxQNpEhASZTLY7TTOopgEqr1JeiCfzkCDIKMngxnZ
         ExvNqSJEY60DuFZJbyoQ7tFDYZpsxmD//5uSX849+kydLl4DuwTfQxNVVYCHgBOR2CQt
         OrjQ==
X-Gm-Message-State: AFuF++mr528Vff/LpbWeIuSF0Y80WoQFry/wvzcvr/bHOZDT6xFjMhAS
	523b6pBd4iay5dl0kDX4ObLj/2Mu5XEPqcqwPBeIHtfYuAFp1zt2wE0LUkHVNoyakR4=
X-Gm-Gg: AYBFou3MgaoSL9pSolOqZ6dHwuzhsv/BC86aczVMMcfVgx/2k4NKcsjpaw18N+FxcSL
	hqGIEQsvEZOmUZayVXT4r7GoElV8YspfWfWrez92rigUWs9sRVJ1rCY8yDrifXILRnakZWaaNrF
	vuZzJiZdZ6BlMDCvbDBOmFgU8WiaIEsfWKaZ7wwyu1rzdLECN+w0ROlbSIa9cb7rDkP/HmL3TLe
	XAUwC/yuEangy1P3JVsMMUiglUv/sPD06RTi3FZrVCqsktuGmhNeY7n2npKHr+PKcuDH543LQXy
	cBWFMAOWDz1/wslBoUOpiorBtDjl2dH81uCSg4+tj+qMNV5yv3Hfwgy2Q+0/crtYx40T2Xh7p9C
	jswNlT198cSlck0By2mTHF/YAHzNi+fhArbMA3RldDAb2jcikvA8LvuqeYlFzgR65rY4/Z5cTBJ
	9ULtKl5Bc1FJEvbD+O/5vrUelo52n40Tr5mAWNKeq39eAZ5VUbXR7yCsXsK8s7O9IYuZZS4sZcZ
	qgVaj7uYIJ7JZuafaevDxFe/xSDadDAQSE=
X-Received: by 2002:a05:620a:6085:b0:936:9253:897a with SMTP id af79cd13be357-939814a15dfmr602664185a.9.1788540806325;
        Fri, 04 Sep 2026 09:53:26 -0700 (PDT)
Received: from bcodding.csb.hammerspace.com ([66.97.168.37])
        by smtp.gmail.com with ESMTPSA id af79cd13be357-9397fbf7c78sm248145485a.47.2026.09.04.09.53.25
        (version=TLS1_3 cipher=TLS_AES_256_GCM_SHA384 bits=256/256);
        Fri, 04 Sep 2026 09:53:26 -0700 (PDT)
From: Benjamin Coddington <ben.coddington@hammerspace.com>
X-Google-Original-From: Benjamin Coddington <bcodding@hammerspace.com>
To: Trond Myklebust <trondmy@kernel.org>,
	Anna Schumaker <anna@kernel.org>
Cc: linux-nfs@vger.kernel.org,
	Jonathan Curley <jcurley@purestorage.com>,
	Mike Snitzer <snitzer@kernel.org>,
	Jeff Layton <jlayton@kernel.org>,
	Junrui Luo <moonafterrain@outlook.com>
Subject: [PATCH v3 01/24] NFSv4/pnfs: Free the netid when draining a data-server address list
Date: Fri,  4 Sep 2026 12:53:00 -0400
Message-ID: <a632abafa316914b7e4f979e6cc3b83d42341137.1788530385.git.bcodding@hammerspace.com>
X-Mailer: git-send-email 2.53.0
In-Reply-To: <cover.1788530385.git.bcodding@hammerspace.com>
References: <cover.1788530385.git.bcodding@hammerspace.com>
Precedence: bulk
X-Mailing-List: linux-nfs@vger.kernel.org
List-Id: <linux-nfs.vger.kernel.org>
List-Subscribe: <mailto:linux-nfs+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:linux-nfs+unsubscribe@vger.kernel.org>
MIME-Version: 1.0
Content-Transfer-Encoding: 8bit

nfs4_pnfs_ds_addr_free() releases all three of an address entry's
allocations, but the four sites that drain a decoded list before it
reaches a data server open-code the loop and free only da_remotestr and
the entry, leaking da_netid.  Both layout drivers drain that list when
nfs4_pnfs_ds_add() returned a data server already in the cache, and
again on their error exits.

Lift the drain into nfs4_pnfs_ds_addr_list_free() so an address list has
one owner.  A striping mount reaches the cached case on nearly every
GETDEVICEINFO, since many deviceIDs name the same data servers.

Fixes: 4be78d26810b ("NFSv4/pNFS: Store the transport type in struct nfs4_pnfs_ds_addr")
Cc: stable@vger.kernel.org
Assisted-by: Claude:claude-opus-5
Signed-off-by: Benjamin Coddington <bcodding@hammerspace.com>
---
 fs/nfs/filelayout/filelayoutdev.c         | 17 ++---------------
 fs/nfs/flexfilelayout/flexfilelayoutdev.c | 17 ++---------------
 fs/nfs/pnfs.h                             |  1 +
 fs/nfs/pnfs_nfs.c                         | 21 +++++++++++++--------
 4 files changed, 18 insertions(+), 38 deletions(-)

diff --git a/fs/nfs/filelayout/filelayoutdev.c b/fs/nfs/filelayout/filelayoutdev.c
index 88bc79ec3459..57e0654cd98c 100644
--- a/fs/nfs/filelayout/filelayoutdev.c
+++ b/fs/nfs/filelayout/filelayoutdev.c
@@ -177,27 +177,14 @@ nfs4_fl_alloc_deviceid_node(struct nfs_server *server, struct pnfs_device *pdev,
 		trace_fl_getdevinfo(server, &pdev->dev_id, dsaddr->ds_list[i]->ds_remotestr);
 
 		/* If DS was already in cache, free ds addrs */
-		while (!list_empty(&dsaddrs)) {
-			da = list_first_entry(&dsaddrs,
-					      struct nfs4_pnfs_ds_addr,
-					      da_node);
-			list_del_init(&da->da_node);
-			kfree(da->da_remotestr);
-			kfree(da);
-		}
+		nfs4_pnfs_ds_addr_list_free(&dsaddrs);
 	}
 
 	folio_put(scratch);
 	return dsaddr;
 
 out_err_drain_dsaddrs:
-	while (!list_empty(&dsaddrs)) {
-		da = list_first_entry(&dsaddrs, struct nfs4_pnfs_ds_addr,
-				      da_node);
-		list_del_init(&da->da_node);
-		kfree(da->da_remotestr);
-		kfree(da);
-	}
+	nfs4_pnfs_ds_addr_list_free(&dsaddrs);
 out_err_free_deviceid:
 	nfs4_fl_free_deviceid(dsaddr);
 	/* stripe_indicies was part of dsaddr */
diff --git a/fs/nfs/flexfilelayout/flexfilelayoutdev.c b/fs/nfs/flexfilelayout/flexfilelayoutdev.c
index 5c0216bd5fce..6cd3859d4a24 100644
--- a/fs/nfs/flexfilelayout/flexfilelayoutdev.c
+++ b/fs/nfs/flexfilelayout/flexfilelayoutdev.c
@@ -159,26 +159,13 @@ nfs4_ff_alloc_deviceid_node(struct nfs_server *server, struct pnfs_device *pdev,
 		goto out_err_drain_dsaddrs;
 
 	/* If DS was already in cache, free ds addrs */
-	while (!list_empty(&dsaddrs)) {
-		da = list_first_entry(&dsaddrs,
-				      struct nfs4_pnfs_ds_addr,
-				      da_node);
-		list_del_init(&da->da_node);
-		kfree(da->da_remotestr);
-		kfree(da);
-	}
+	nfs4_pnfs_ds_addr_list_free(&dsaddrs);
 
 	folio_put(scratch);
 	return new_ds;
 
 out_err_drain_dsaddrs:
-	while (!list_empty(&dsaddrs)) {
-		da = list_first_entry(&dsaddrs, struct nfs4_pnfs_ds_addr,
-				      da_node);
-		list_del_init(&da->da_node);
-		kfree(da->da_remotestr);
-		kfree(da);
-	}
+	nfs4_pnfs_ds_addr_list_free(&dsaddrs);
 
 	kfree(ds_versions);
 out_scratch:
diff --git a/fs/nfs/pnfs.h b/fs/nfs/pnfs.h
index 70d20f779678..5725ea06efc2 100644
--- a/fs/nfs/pnfs.h
+++ b/fs/nfs/pnfs.h
@@ -427,6 +427,7 @@ int nfs4_pnfs_ds_connect(struct nfs_server *mds_srv, struct nfs4_pnfs_ds *ds,
 struct nfs4_pnfs_ds_addr *nfs4_decode_mp_ds_addr(struct net *net,
 						 struct xdr_stream *xdr,
 						 gfp_t gfp_flags);
+void nfs4_pnfs_ds_addr_list_free(struct list_head *dsaddrs);
 void pnfs_layout_mark_request_commit(struct nfs_page *req,
 				     struct pnfs_layout_segment *lseg,
 				     struct nfs_commit_info *cinfo,
diff --git a/fs/nfs/pnfs_nfs.c b/fs/nfs/pnfs_nfs.c
index 93d63f75a355..5bd014b981bf 100644
--- a/fs/nfs/pnfs_nfs.c
+++ b/fs/nfs/pnfs_nfs.c
@@ -633,23 +633,28 @@ static void nfs4_pnfs_ds_addr_free(struct nfs4_pnfs_ds_addr *da)
 	kfree(da);
 }
 
-static void destroy_ds(struct nfs4_pnfs_ds *ds)
+void nfs4_pnfs_ds_addr_list_free(struct list_head *dsaddrs)
 {
 	struct nfs4_pnfs_ds_addr *da;
 
+	while (!list_empty(dsaddrs)) {
+		da = list_first_entry(dsaddrs, struct nfs4_pnfs_ds_addr,
+				      da_node);
+		list_del_init(&da->da_node);
+		nfs4_pnfs_ds_addr_free(da);
+	}
+}
+EXPORT_SYMBOL_GPL(nfs4_pnfs_ds_addr_list_free);
+
+static void destroy_ds(struct nfs4_pnfs_ds *ds)
+{
 	dprintk("--> %s\n", __func__);
 	ifdebug(FACILITY)
 		print_ds(ds);
 
 	nfs_put_client(ds->ds_clp);
 
-	while (!list_empty(&ds->ds_addrs)) {
-		da = list_first_entry(&ds->ds_addrs,
-				      struct nfs4_pnfs_ds_addr,
-				      da_node);
-		list_del_init(&da->da_node);
-		nfs4_pnfs_ds_addr_free(da);
-	}
+	nfs4_pnfs_ds_addr_list_free(&ds->ds_addrs);
 
 	kfree(ds->ds_remotestr);
 	kfree(ds);
-- 
2.53.0

