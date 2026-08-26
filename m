Received: from oss.cyber.gouv.fr (oss.cyber.gouv.fr [51.159.188.251])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id DF52B379C32;
	Wed, 26 Aug 2026 08:10:05 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=51.159.188.251
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1787731808; cv=none; b=EFr0000J5ICO0ln+9GRKf7YIFPvSckmpUlJZ9fpNvyMNtpLq+t0pINfIyuM36ldbUfM01/vYstACvrZDCV4aqPFHZpjDG78G2nvqygN3I+7Xk9vWF67dnS75OOEOPLuBq8JWSBLjaasfSwALVs9RTes4RbSfYkqnSI793eFZgo4=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1787731808; c=relaxed/simple;
	bh=VH0JTq0aUrXxVeMX8ruxn6wUXJjklTvxhu+0AZ6/8kk=;
	h=From:To:Cc:Subject:Date:Message-ID:MIME-Version:Content-Type; b=UYfJ2CaAU5yq6xAGef982JDGIPKATbe14x6lA6uqfjrBXlLDvfHx2wpUtJnbdhSATJVKckldTn7AMK1BVQ3cEhsmt9BpZ+A2CQCAus9wzAnkUxZCsq1yojIjR+zBu3ITKAv8CiksaaYUNVb+g2v4tkBJBfNJfgiwp2K7Lh8gmn0=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dmarc=pass (p=none dis=none) header.from=oss.cyber.gouv.fr; spf=pass smtp.mailfrom=oss.cyber.gouv.fr; dkim=pass (2048-bit key) header.d=oss.cyber.gouv.fr header.i=@oss.cyber.gouv.fr header.b=mjh5KFAN; arc=none smtp.client-ip=51.159.188.251
Authentication-Results: smtp.subspace.kernel.org; dmarc=pass (p=none dis=none) header.from=oss.cyber.gouv.fr
Authentication-Results: smtp.subspace.kernel.org; spf=pass smtp.mailfrom=oss.cyber.gouv.fr
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=oss.cyber.gouv.fr header.i=@oss.cyber.gouv.fr header.b="mjh5KFAN"
DKIM-Signature: v=1; a=rsa-sha256; q=dns/txt; c=relaxed/relaxed;
	d=oss.cyber.gouv.fr; s=default; h=Content-Transfer-Encoding:Content-Type:
	MIME-Version:Message-ID:Date:Subject:Cc:To:From:Sender:Reply-To:Content-ID:
	Content-Description:Resent-Date:Resent-From:Resent-Sender:Resent-To:Resent-Cc
	:Resent-Message-ID:In-Reply-To:References:List-Id:List-Help:List-Unsubscribe:
	List-Subscribe:List-Post:List-Owner:List-Archive;
	bh=wjPblfhFmT5W5g5QCeEjBcrjlEX/rBTw3prM8FktCbY=; b=mjh5KFANvm6pRco1PfkkrjyiyD
	/0BPtlwAQ9QFj09H34h3R26+rd9/tf7OsegFtS4KxdRzuG/k+eecIO8jRowFz8Ohp/v+jd3lMcA3D
	My8mn9feRIJeJXLfuQunn8QATBJ80ctGYnoHLNqwiS8+pEozxl1ke13+xr5alpqy8TJUmMske1xSQ
	ElrdzIUoUE2kpi2ueJEjBSfLI4AD04dDbxaBDtzn0oj+8YopmoDMKWdAHsbkdOdnxw7IMFW74nj29
	5B++UaAfjkeeyTuwetYAUYOkr/XI2ZZfb3O3qaf17x++YzQH/H7vZsB+K7HoRvDa8T3fcEBpnuWQu
	PclOFbbA==;
Received: from [151.115.150.205] (port=59492 helo=gepetto..)
	by pf-012.whm.fr-par.scw.cloud with esmtpsa  (TLS1.3) tls TLS_AES_256_GCM_SHA384
	(Exim 4.99.5)
	(envelope-from <Jeremy.Jean@oss.cyber.gouv.fr>)
	id 1wz8hp-0000000EKrJ-2uLv;
	Wed, 26 Aug 2026 10:09:57 +0200
From: =?UTF-8?q?J=C3=A9r=C3=A9my=20Jean?= <Jeremy.Jean@oss.cyber.gouv.fr>
To: Trond Myklebust <trondmy@kernel.org>,
	Anna Schumaker <anna@kernel.org>
Cc: linux-nfs@vger.kernel.org,
	linux-kernel@vger.kernel.org,
	=?UTF-8?q?J=C3=A9r=C3=A9my=20Jean?= <Jeremy.Jean@oss.cyber.gouv.fr>,
	stable@vger.kernel.org
Subject: [PATCH] NFS: blocklayout: reject oversized SCSI designators
Date: Wed, 26 Aug 2026 08:07:37 +0000
Message-ID: <20260826080736.1431809-2-Jeremy.Jean@oss.cyber.gouv.fr>
X-Mailer: git-send-email 2.47.3
Precedence: bulk
X-Mailing-List: linux-nfs@vger.kernel.org
List-Id: <linux-nfs.vger.kernel.org>
List-Subscribe: <mailto:linux-nfs+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:linux-nfs+unsubscribe@vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 8bit
X-AntiAbuse: This header was added to track abuse, please include it with any abuse report
X-AntiAbuse: Primary Hostname - pf-012.whm.fr-par.scw.cloud
X-AntiAbuse: Original Domain - vger.kernel.org
X-AntiAbuse: Originator/Caller UID/GID - [47 12] / [47 12]
X-AntiAbuse: Sender Address Domain - oss.cyber.gouv.fr
X-Get-Message-Sender-Via: pf-012.whm.fr-par.scw.cloud: authenticated_id: jeremy.jean@oss.cyber.gouv.fr
X-Authenticated-Sender: pf-012.whm.fr-par.scw.cloud: jeremy.jean@oss.cyber.gouv.fr
X-Source: 
X-Source-Args: 
X-Source-Dir: 

A SCSI GETDEVICEINFO reply can encode designator_len as 0xffffffff.  The
current signed field turns that into -1, so the size check is bypassed and
the value is converted to SIZE_MAX for xdr_inline_decode() and memcpy().

The attacker model considers a controlled NFSv4.1+ server and a client
already mounted to that server. An OOB read can be triggered in the client
on a file read. KASAN reports:

  BUG: KASAN: out-of-bounds in bl_alloc_deviceid_node+0x616/0x1110
  Read of size 18446744073709551615
  ...
  __asan_memcpy+0x23/0x60
  bl_alloc_deviceid_node+0x616/0x1110
  nfs4_find_get_deviceid+0x565/0x810
  bl_alloc_lseg+0x638/0x12d0
  pnfs_layout_process+0x2b6/0xcf0
  nfs4_proc_layoutget+0x4b3/0xd30


The fix stores the length as u32 and reject oversized values before decoding.
The check is moved up before the call to xdr_inline_decode().

Fixes: d9186c039765 ("nfs/blocklayout: add SCSI layout support")
Cc: stable@vger.kernel.org
Assisted-by: Codex:gpt-5
Signed-off-by: Jérémy Jean <Jeremy.Jean@oss.cyber.gouv.fr>
---
 fs/nfs/blocklayout/blocklayout.h | 2 +-
 fs/nfs/blocklayout/dev.c         | 8 ++++----
 2 files changed, 5 insertions(+), 5 deletions(-)

diff --git a/fs/nfs/blocklayout/blocklayout.h b/fs/nfs/blocklayout/blocklayout.h
index 6da40ca19570..db81ef3f9811 100644
--- a/fs/nfs/blocklayout/blocklayout.h
+++ b/fs/nfs/blocklayout/blocklayout.h
@@ -84,7 +84,7 @@ struct pnfs_block_volume {
 		struct {
 			enum scsi_code_set		code_set;
 			enum scsi_designator_type	designator_type;
-			int				designator_len;
+			u32				designator_len;
 			u8				designator[256];
 			u64				pr_key;
 		} scsi;
diff --git a/fs/nfs/blocklayout/dev.c b/fs/nfs/blocklayout/dev.c
index 368d20daf67b..1e6141e79f3f 100644
--- a/fs/nfs/blocklayout/dev.c
+++ b/fs/nfs/blocklayout/dev.c
@@ -203,11 +203,11 @@ nfs4_block_decode_volume(struct xdr_stream *xdr, struct pnfs_block_volume *b)
 		b->scsi.code_set = be32_to_cpup(p++);
 		b->scsi.designator_type = be32_to_cpup(p++);
 		b->scsi.designator_len = be32_to_cpup(p++);
+		if (b->scsi.designator_len > sizeof(b->scsi.designator))
+			return -EIO;
 		p = xdr_inline_decode(xdr, b->scsi.designator_len);
 		if (!p)
 			return -EIO;
-		if (b->scsi.designator_len > 256)
-			return -EIO;
 		memcpy(&b->scsi.designator, p, b->scsi.designator_len);
 		p = xdr_inline_decode(xdr, 8);
 		if (!p)
@@ -345,14 +345,14 @@ bl_validate_designator(struct pnfs_block_volume *v)
 	case PS_DESIGNATOR_T10:
 	case PS_DESIGNATOR_NAME:
 		pr_err("pNFS: unsupported designator "
-			"(code set %d, type %d, len %d.\n",
+			"(code set %d, type %d, len %u.\n",
 			v->scsi.code_set,
 			v->scsi.designator_type,
 			v->scsi.designator_len);
 		return false;
 	default:
 		pr_err("pNFS: invalid designator "
-			"(code set %d, type %d, len %d.\n",
+			"(code set %d, type %d, len %u.\n",
 			v->scsi.code_set,
 			v->scsi.designator_type,
 			v->scsi.designator_len);
-- 
2.47.3
