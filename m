Received: from mail-oi1-f177.google.com (mail-oi1-f177.google.com [209.85.167.177])
	(using TLSv1.2 with cipher ECDHE-RSA-AES128-GCM-SHA256 (128/128 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id ABE482931CC
	for <linux-nfs@vger.kernel.org>; Tue, 15 Sep 2026 12:22:31 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=209.85.167.177
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1789474953; cv=none; b=YLXqJbBJPZEV/zqYW8yWgWLjaq2N37XYEZsq0Hziv41hMUKGFdV3ilWn/tjkC82MkrT+JEHy6UtKWNqusbhe9JzJeyfDlDCNr27P63dqdmbzicx+bxXpEJMJSA0LHsqKd+q5Ew5ZZjoVxOM4im2FRq7mWqPA1PTYIZ6oc6umqI8=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1789474953; c=relaxed/simple;
	bh=UL8KFNWk7lNJYm0ZnrWATxloH4b6T+ed7rGFAQbjp/k=;
	h=From:To:Cc:Subject:Date:Message-ID:In-Reply-To:References:
	 MIME-Version; b=jzXe66ZHlR8AuOIobzeeJJEwqoF+WGzK15ktCrtDbDDHBkr737p1PaxIjb0ef6nsMtP+w0mJgEPce5Nb2LCSI2CId9jiZ7rrwPNrq4SMmXYBWNcMZO6bR/FGLhkPbHp01tcQXdtV5fv4la1WSzHRRSlsLLQBInrOpomkx2xPTQ0=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dmarc=pass (p=quarantine dis=none) header.from=hammerspace.com; spf=pass smtp.mailfrom=hammerspace.com; dkim=pass (2048-bit key) header.d=hammerspace.com header.i=@hammerspace.com header.b=jeBD781P; arc=none smtp.client-ip=209.85.167.177
Authentication-Results: smtp.subspace.kernel.org; dmarc=pass (p=quarantine dis=none) header.from=hammerspace.com
Authentication-Results: smtp.subspace.kernel.org; spf=pass smtp.mailfrom=hammerspace.com
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=hammerspace.com header.i=@hammerspace.com header.b="jeBD781P"
Received: by mail-oi1-f177.google.com with SMTP id 5614622812f47-4be07e7c54dso677924b6e.1
        for <linux-nfs@vger.kernel.org>; Tue, 15 Sep 2026 05:22:31 -0700 (PDT)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=hammerspace.com; s=google; t=1789474950; x=1790079750; darn=vger.kernel.org;
        h=content-transfer-encoding:mime-version:references:in-reply-to
         :message-id:date:subject:cc:to:from:from:to:cc:subject:date
         :message-id:reply-to:content-type;
        bh=oHQ8BbMYCaCngVy3DUvFYsHhavmNY+fsgd9aZs+DdME=;
        b=jeBD781P0t+wdtljZe7vC1Hz5ciZHp7/HWQY9ow2R7XbIwFaEwgviAWakTZ9hWDvuZ
         6C8Q5CVsmEf0geVH2bIA6J63RaGGvq1p+Gq9GamoZZmHp0UJtMJlisbfunFNMFSx8cer
         itt4X4IkJffEpMpI0UHXC7Mye2RnsiOdsuQl1VxH4zfzJPVl+NkD7eFGf13Br6vmmJf2
         hnbKXceCAOHdpXzQSHOKFGuit6o5gksqfOR3N5tfwbIa2toZn8ViYsunTTx7lCsbtAwn
         9W4APoRDEaWb7/+KLgrEJyRz5CZ8TbHknqPXgRqANWSJ2SipqHE3iUA6982o00wgPR3+
         Qysw==
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20260707; t=1789474950; x=1790079750;
        h=content-transfer-encoding:mime-version:references:in-reply-to
         :message-id:date:subject:cc:to:from:x-gm-gg:x-gm-message-state:from
         :to:cc:subject:date:message-id:reply-to:content-type;
        bh=oHQ8BbMYCaCngVy3DUvFYsHhavmNY+fsgd9aZs+DdME=;
        b=CFrOTpJMlZp8ec18ILg2GF0pXF0A3CHG3BjsALfxAYDzKkocvA61X9d8IFXtc6mq+b
         3YKocMksmvCZTD/QEcSAXq0JehBA2/i8/QRuX1TdC1bjNgwnCv55n4aLdTqLVrrr3cq4
         FVulg7luQ40gb2IAneFCcUrXJdArFjAVceXMcSqAOSPdPt43BNw50RRNxToFBc8crrKI
         w8TD5rv24UVgFmrfjJsz2rM79N+eH8sCdwTbKMsia44sJnmCvwGuPLIscZ5VGEZLfhCn
         SpLqSrAIPp6zpo0A3MEQ1aA5OX48ncEYxuMwiha8msKqPEBuEaKb4AgsAvy5Ovz3LeAG
         xwow==
X-Gm-Message-State: AFuF++kMcD/ARBbpQ2u/5TAlxDG1VdTvZGwF5lCQKLWGmyNJlt9Gdfyh
	0Pn1J93Zii77cs9lyGUuJ0qGyEsmelo07Yo6LBN1wHnaPTM9cHnveKB+ygf0uPk2Rh0=
X-Gm-Gg: AYBFou0PZwzz5etKVm3WMtvFLLUA7WnmYlouwGbHB2vMPXHBgzhOFNgWInJZxv3Q+Tj
	0J2OOYhhAiGHLGxr4pf7UDZd2dbKLczFiqc45MDz7D6raQmUS2K+B5Outv2BqMoemK4SMNFPPiZ
	Kx3I/oSkVShuLwxxUWRImuEdFSfzkHesBXrDHuWDOy7YJyDiVe2zQU4FK+YkHIrUeCHw75sz6z+
	6hw7vshbdfQfQoTfDT2AKOG4OdGBF1wTF5UYh2V+l6U4BAUPwJmKLMa/2UBMUAA1J5vbWLcThAG
	XJE6lWRbakbm7Z2Z6ZJ/gQ/VSBn40gyyWNcRgLlr/mJEr1YlTyi08TeB8SVvykuUlgB/01TgbWS
	uVaYs2jBBg01qtHSx7EvwegrbXYYmpMhtfCJnrgvIjPJyJYF5EppOGaqspYTr3tJl2E6Seujwd2
	222tFYpVsCwAwGfjZ38Xa9VxOWYHm8jmQUEPOQD7IasuNEwPa2/vGi4mgJraCX1RnG7oJZfzSWf
	0IlB/w7qOM+QBVtW+MIuBGoS5BYS1ww06Y=
X-Received: by 2002:a05:6808:1482:b0:4af:9364:b5a9 with SMTP id 5614622812f47-4c89ef83e00mr1743349b6e.6.1789474950362;
        Tue, 15 Sep 2026 05:22:30 -0700 (PDT)
Received: from bcodding.csb.hammerspace.com ([66.97.168.37])
        by smtp.gmail.com with ESMTPSA id 5614622812f47-4c32eb4274dsm13058260b6e.1.2026.09.15.05.22.29
        (version=TLS1_3 cipher=TLS_AES_256_GCM_SHA384 bits=256/256);
        Tue, 15 Sep 2026 05:22:30 -0700 (PDT)
From: Benjamin Coddington <ben.coddington@hammerspace.com>
X-Google-Original-From: Benjamin Coddington <bcodding@hammerspace.com>
To: Trond Myklebust <trondmy@kernel.org>,
	Anna Schumaker <anna@kernel.org>
Cc: linux-nfs@vger.kernel.org,
	Jonathan Curley <jcurley@purestorage.com>,
	Mike Snitzer <snitzer@kernel.org>,
	Jeff Layton <jlayton@kernel.org>,
	Junrui Luo <moonafterrain@outlook.com>
Subject: [PATCH v4 01/24] NFSv4/pnfs: Free the netid when draining a data-server address list
Date: Tue, 15 Sep 2026 08:22:03 -0400
Message-ID: <a632abafa316914b7e4f979e6cc3b83d42341137.1789474702.git.bcodding@hammerspace.com>
X-Mailer: git-send-email 2.53.0
In-Reply-To: <cover.1789474702.git.bcodding@hammerspace.com>
References: <cover.1789474702.git.bcodding@hammerspace.com>
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

