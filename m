Received: from mail-oi1-f169.google.com (mail-oi1-f169.google.com [209.85.167.169])
	(using TLSv1.2 with cipher ECDHE-RSA-AES128-GCM-SHA256 (128/128 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 61DDC36C0DC
	for <linux-nfs@vger.kernel.org>; Thu, 13 Aug 2026 20:43:44 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=209.85.167.169
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1786653825; cv=none; b=VhgKIpbUwmAhzzFG35dS+LT1CRr4bhDZ4dBaHMoo+D0qgyOLmkghf2hZ4/661j/WWDHXbeRT4CIffrt7eNRqpin8lpj1WDXxhlmXBb5iFPCsfzd88ekVZZOUJe3f8IZLPb2f9YhaecmMhuUgdmpwfbPAil4q7mwIXqvP0mrjJ4I=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1786653825; c=relaxed/simple;
	bh=Kjj0VqCI0HOeHmRenQJT+viPorRftZDN9no9Yjhfei0=;
	h=From:To:Cc:Subject:Date:Message-ID:In-Reply-To:References:
	 MIME-Version; b=YOHvBe05Q1x9qmfngaACg8bNlB3oBDcopk6TYCMo1vKVw0OmbyxgMiAbwBRdVsnXfJkn+VKhA8aYXfDt15C7Zr2GIF6nAL8DC80DhJQVzhhWIueqxRp4/DE00N3M9EgdJc/ZSsj6a0TDgKe2x/Whr+akp7O9sM8z7S3IKYRl19g=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dmarc=pass (p=quarantine dis=none) header.from=hammerspace.com; spf=pass smtp.mailfrom=hammerspace.com; dkim=pass (2048-bit key) header.d=hammerspace.com header.i=@hammerspace.com header.b=VXbv3+nP; arc=none smtp.client-ip=209.85.167.169
Authentication-Results: smtp.subspace.kernel.org; dmarc=pass (p=quarantine dis=none) header.from=hammerspace.com
Authentication-Results: smtp.subspace.kernel.org; spf=pass smtp.mailfrom=hammerspace.com
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=hammerspace.com header.i=@hammerspace.com header.b="VXbv3+nP"
Received: by mail-oi1-f169.google.com with SMTP id 5614622812f47-4af173320f9so141125b6e.2
        for <linux-nfs@vger.kernel.org>; Thu, 13 Aug 2026 13:43:44 -0700 (PDT)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=hammerspace.com; s=google; t=1786653823; x=1787258623; darn=vger.kernel.org;
        h=content-transfer-encoding:mime-version:references:in-reply-to
         :message-id:date:subject:cc:to:from:from:to:cc:subject:date
         :message-id:reply-to:content-type;
        bh=xXn6B+UpqgbRpA3wE7MRGrBHdJeXXyegz1MoFmnhtCo=;
        b=VXbv3+nPVG2Eu5qQo8zPHkYOtke9QtqZVXF/qnp31+Xpqa154FZb4IdbleY2rqkbNd
         ym6kTWU9rRi6eChRVI3OKReDiG625nUaoyvS+zMNeIr8FGX7nEr1lgtDdMRpzbBJUzSC
         4C9Ffr6LN2hxLSVDiCRNApLn/BW6stck0F9SJpb1e75VT6He75TnyQEliLG5vQSM7fii
         clm5E5AZ2nZwEoE3UUIa2ESSoaq+jmR3zfX9t3Bnkad+iq3BVuC0JIuwCJqnG62GH6GB
         dkF6lIc6EBCZz2jyRMvsWoOTT71Ro/velUfGf2i7rdP2No3kG7B5Pa8HS3L4SVNt7nMb
         m5Dg==
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20251104; t=1786653823; x=1787258623;
        h=content-transfer-encoding:mime-version:references:in-reply-to
         :message-id:date:subject:cc:to:from:x-gm-gg:x-gm-message-state:from
         :to:cc:subject:date:message-id:reply-to:content-type;
        bh=xXn6B+UpqgbRpA3wE7MRGrBHdJeXXyegz1MoFmnhtCo=;
        b=YKiZkM6q7+mf7rbvM3Wa+84KWyyxJlVeQbnOSLfginVajZlsrjkP1V537AfUSZULTs
         52sp9ufXHdb3SgC4qJRLYo+pfuUz5GBltSdaRsnf04tSQsIv2bx1uavjEMCYn3KCOpIc
         pvxjlu1IHKUMgp7D+Hi6zly9fZrQSUJYEcSrJ0qCEC9YVd419+n3wrP7MF2GGotcpTHD
         fW5SXWFjSqwZIK+gc1106TCKGfuKJ+TZvGbLI36XcEN9A7tpYK1ACU8fmMqNxWVpR1cP
         Ol3jYzB+GFKZ+diiL4uLk+2H/yNYlkN/rZ4Vf2SIIgpabqY00jBM+D1W2EAZpbpfOggR
         /ftg==
X-Gm-Message-State: AOJu0Yyqfy1iXVtgUZwZnVI4AL1FXYPq7NiS5uUo78SFVINh5dzMd05O
	vmZjcgyJIybPBuLevsJmzq9cnZKk6b5LEWAs+lMcsiVhU9QI0fvMIesEbG0IJYetNbI=
X-Gm-Gg: AR+sD12Pz0K5/Br8zAWnShZnBwPF5Arw8CPCyVtI1mziCNzpr4o9tldiSSVLKas8XCi
	cEpd5v1F03KsP/oA7FL8IAK+gncadiud0FbJHBva0hfN4HSDb7Mbdalfdyeh+hAUJmJyZ6oFr/V
	nXbrgoC/A2KK1WsivFHP5Lhu6w3QJqIhXxh6MW1r7q5lQliBBdf0tAkKBrJcR5N/COZgKBmuDYC
	aCbF6AIFK20px6rBuC/j3Bz5uYH9YvIfgZzRkNvU7jU6Gr5ZwV3czKzKGxeMelBmpfdwY0nbagv
	GIcdjHZzP12w8HyW3ELzc9FSah4/OBN4ZA5ALz88LQuKKAKpbRdlhVm8SMxJFayyZY69RJDbosg
	mkIl1tVQvGnq9WcI8SvNTp83Stg+7VRzr7yWKAKYSulel53D2IS550WAOEbMjiaSn9EAzOrDJY3
	YDWW3VN3HPQNxXQD1X/GZItmyVr/cOr22BRA11f3FYj/5kCANJIy7giXhZ75vf4aBm3c9S5ubkf
	uqe9QDRTbw0OrTKMR7XSyvl
X-Received: by 2002:a05:6808:1a0e:b0:4a4:88ab:126f with SMTP id 5614622812f47-4b241e719c5mr646555b6e.21.1786653823083;
        Thu, 13 Aug 2026 13:43:43 -0700 (PDT)
Received: from bcodding.csb.hammerspace.com ([66.97.168.37])
        by smtp.gmail.com with ESMTPSA id 5614622812f47-4b22c8c09e4sm2484254b6e.0.2026.08.13.13.43.42
        (version=TLS1_3 cipher=TLS_AES_256_GCM_SHA384 bits=256/256);
        Thu, 13 Aug 2026 13:43:42 -0700 (PDT)
From: Benjamin Coddington <ben.coddington@hammerspace.com>
X-Google-Original-From: Benjamin Coddington <bcodding@hammerspace.com>
To: Trond Myklebust <trondmy@kernel.org>,
	Anna Schumaker <anna@kernel.org>
Cc: linux-nfs@vger.kernel.org,
	Jonathan Curley <jcurley@purestorage.com>,
	Mike Snitzer <snitzer@kernel.org>,
	Jeff Layton <jlayton@kernel.org>
Subject: [PATCH 16/21] NFSv4/pnfs: Confirm a deviceID delete via GETDEVICEINFO
Date: Thu, 13 Aug 2026 16:43:12 -0400
Message-ID: <f0c494531a4097aebcd7c11af94224c544ad64ac.1786653063.git.bcodding@hammerspace.com>
X-Mailer: git-send-email 2.53.0
In-Reply-To: <cover.1786653063.git.bcodding@hammerspace.com>
References: <cover.1786653063.git.bcodding@hammerspace.com>
Precedence: bulk
X-Mailing-List: linux-nfs@vger.kernel.org
List-Id: <linux-nfs.vger.kernel.org>
List-Subscribe: <mailto:linux-nfs+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:linux-nfs+unsubscribe@vger.kernel.org>
MIME-Version: 1.0
Content-Transfer-Encoding: 8bit

RFC 8881 Section 18.40.4: if TEST_STATEID says at least one layout
referring to the deleted deviceID is still valid, the delete cannot
be trusted -- verify it with GETDEVICEINFO.  The device really being
gone while the server also considers a referring layout valid means
the server is faulty; recover by re-establishing the client ID
(nfs4_schedule_lease_recovery drives the prescribed EXCHANGE_ID) and
drop the cached device.  Any other answer -- including the device
existing, i.e. an erroneous DELETE -- keeps the cached device and
the layout intact.

The raw-status probe calls nfs4_proc_getdeviceinfo() directly
because nfs4_get_device_info() swallows the RPC status and cannot
distinguish NFS4ERR_NOENT from a transient failure.  A one-page
reply buffer is enough: a device too large for it fails with
something other than -ENOENT, which still proves existence.

Still nothing enqueues suspects; no behavior change.

Assisted-by: Claude:claude-fable-5
Signed-off-by: Benjamin Coddington <bcodding@hammerspace.com>
---
 fs/nfs/nfs4proc.c | 57 +++++++++++++++++++++++++++++++++++++++++------
 1 file changed, 50 insertions(+), 7 deletions(-)

diff --git a/fs/nfs/nfs4proc.c b/fs/nfs/nfs4proc.c
index aa1414d2d891..13dc6d5ee904 100644
--- a/fs/nfs/nfs4proc.c
+++ b/fs/nfs/nfs4proc.c
@@ -10441,6 +10441,36 @@ static int nfs41_free_stateid(struct nfs_server *server,
 	return ret;
 }
 
+/*
+ * Ask the server whether a deviceID exists, surfacing the raw status
+ * (nfs4_get_device_info() swallows it).  A one-page reply buffer is
+ * enough for the answer: a device too large for it fails with
+ * something other than -ENOENT, which still proves existence.
+ */
+static int nfs4_deviceid_validate(struct nfs_server *server,
+		const struct pnfs_layoutdriver_type *ld,
+		const struct nfs4_deviceid *id, const struct cred *cred)
+{
+	struct pnfs_device pdev;
+	struct page *page;
+	int status;
+
+	page = alloc_page(GFP_KERNEL);
+	if (!page)
+		return -ENOMEM;
+
+	memset(&pdev, 0, sizeof(pdev));
+	memcpy(&pdev.dev_id, id, sizeof(pdev.dev_id));
+	pdev.layout_type = ld->id;
+	pdev.pages = &page;
+	pdev.pglen = PAGE_SIZE;
+	pdev.maxcount = PAGE_SIZE - nfs41_maxgetdevinfo_overhead;
+
+	status = nfs4_proc_getdeviceinfo(server, &pdev, cred);
+	__free_page(page);
+	return status;
+}
+
 /*
  * A CB_NOTIFY_DEVICEID DELETE named a deviceID that live layouts still
  * referenced -- a conformant server never does this (RFC 8881 Section
@@ -10449,16 +10479,21 @@ static int nfs41_free_stateid(struct nfs_server *server,
  * invalid, free the lsegs, FREE_STATEID).  If every referring layout
  * turned out revoked, the delete is confirmed by the revocations and
  * the cached device is dropped.  A layout the server still considers
- * valid means the delete cannot be trusted; leave the device cached.
+ * valid means the delete cannot be trusted: verify it with
+ * GETDEVICEINFO.  The device really being gone under a valid layout
+ * means the server is faulty -- recover by re-establishing the client
+ * ID (Section 18.40.4 prescribes EXCHANGE_ID).  Any other answer
+ * (including the device existing: an erroneous DELETE) keeps the
+ * cached device.
  */
 static void nfs4_deviceid_delete_recover(struct nfs_client *clp,
 		const struct pnfs_layoutdriver_type *ld,
 		const struct nfs4_deviceid *id)
 {
 	LIST_HEAD(layouts);
-	struct nfs4_deviceid_ref *ref;
+	struct nfs4_deviceid_ref *ref, *confirm = NULL;
 	bool revoked = false;
-	bool referenced = false;
+	int status;
 
 	pnfs_layout_collect_deviceid_refs(clp, ld, id, &layouts);
 
@@ -10466,13 +10501,13 @@ static void nfs4_deviceid_delete_recover(struct nfs_client *clp,
 		struct pnfs_layout_hdr *lo = ref->lo;
 		struct inode *inode = ref->inode;
 		LIST_HEAD(head);
-		int status;
 
 		status = nfs41_test_stateid(NFS_SERVER(inode), &ref->stateid,
 					    ref->cred);
 		switch (status) {
 		case NFS_OK:
-			referenced = true;
+			if (!confirm)
+				confirm = ref;
 			break;
 		case -NFS4ERR_ADMIN_REVOKED:
 		case -NFS4ERR_DELEG_REVOKED:
@@ -10494,10 +10529,18 @@ static void nfs4_deviceid_delete_recover(struct nfs_client *clp,
 			break;
 		}
 	}
-	pnfs_layout_put_deviceid_refs(&layouts);
 
-	if (revoked && !referenced)
+	if (confirm) {
+		status = nfs4_deviceid_validate(NFS_SERVER(confirm->inode),
+						ld, id, confirm->cred);
+		if (status == -ENOENT) {
+			nfs4_schedule_lease_recovery(clp);
+			nfs4_delete_deviceid(ld, clp, id);
+		}
+	} else if (revoked) {
 		nfs4_delete_deviceid(ld, clp, id);
+	}
+	pnfs_layout_put_deviceid_refs(&layouts);
 }
 
 void nfs4_deviceid_delete_recover_run(struct nfs_client *clp)
-- 
2.53.0

