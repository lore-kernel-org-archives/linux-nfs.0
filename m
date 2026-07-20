Received: from smtp.kernel.org (aws-us-west-2-korg-mail-alma10-1.taild15c8.ts.net [100.103.45.18])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 64CFA25228C
	for <linux-nfs@vger.kernel.org>; Mon, 20 Jul 2026 14:14:47 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=100.103.45.18
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1784556888; cv=none; b=JjMFGHWB9O2YHPGvId05JQBMtgEoEjP+KFYexcFg+/ZX9RhsjRDLoi1/QZ4Z+s16dDhZb0UijXOVrtxGwXcgjznDwZ+ORUhSc9EPC9aRgypy69VAdO2/aKobnB5KyWgdi3euu7a+imUzW41hDARrPoJTPlNueqofDpYTNEL93Q4=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1784556888; c=relaxed/simple;
	bh=92ybayLMCREM3TxAdcTQ8hF4Y10r5nhmb0HkhnEINsE=;
	h=From:To:Cc:Subject:Date:Message-ID:In-Reply-To:References:
	 MIME-Version; b=lfgrlACNyO6TZw+QmBfEYdJq3f3pnnt6TDqMu0rwPEX/TC7RrnowXrYjY+pDx+whhRCoph8s1NHO8WpchBBZPViMzGVsrX5gYko4rbYXXETws8DyTzntMVIS8KXJgQrNnY36n27QNbJs4eENAPTw5gH+53ZWCp/jms6CYqid9KE=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.b=T5xGTvnd; arc=none smtp.client-ip=100.103.45.18
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.b="T5xGTvnd"
Received: by smtp.kernel.org (Postfix) with ESMTPSA id 7C9DD1F00A3A;
	Mon, 20 Jul 2026 14:14:46 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=kernel.org;
	s=k20260515; t=1784556887;
	bh=R4YrV76xN1ob1+4T6T9jAjkLi6dPUsJsvxPYoFSsSns=;
	h=From:To:Cc:Subject:Date:In-Reply-To:References;
	b=T5xGTvndIrWj0dTJiMqI2mHLZ0yBhFYccubhygO+JJp78OoF88h+qPCOO4rp8TtbG
	 GeF1gFCFZoAOSuREqMqk/xy4VltxBSCp/to2Adrcx0rEXHPSaw6zXFsDOrepb3kWRa
	 ioqH9wTBLMZpr3rmYA/Y21zRDqLN8RbmwEHh/yGWklycYfOlZi23G/avHTzM90+SMZ
	 3Fbkv41llGjQl1XWkk1JXeen9e8A8sE3lucmyx7bi5iXjuk6I5+nEE4tg4WDvoWnjJ
	 MWgJPf2UrN8ia/zowaHaIxUDOGzxyJ0wXgzdTTcDa7CyBmdbZ6qzcvZGKF1nnM6Xji
	 eckeHYwS+NR6A==
From: Chuck Lever <cel@kernel.org>
To: NeilBrown <neil@brown.name>,
	Jeff Layton <jlayton@kernel.org>,
	Olga Kornievskaia <okorniev@redhat.com>,
	Dai Ngo <dai.ngo@oracle.com>,
	Tom Talpey <tom@talpey.com>
Cc: <linux-nfs@vger.kernel.org>,
	Thomas Haynes <loghyr@hammerspace.com>
Subject: [PATCH 3/3] NFSD: Use struct knfsd_fh in struct pnfs_ff_layout
Date: Mon, 20 Jul 2026 10:14:42 -0400
Message-ID: <20260720141442.783935-4-cel@kernel.org>
X-Mailer: git-send-email 2.54.0
In-Reply-To: <20260720141442.783935-1-cel@kernel.org>
References: <20260720141442.783935-1-cel@kernel.org>
Precedence: bulk
X-Mailing-List: linux-nfs@vger.kernel.org
List-Id: <linux-nfs.vger.kernel.org>
List-Subscribe: <mailto:linux-nfs+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:linux-nfs+unsubscribe@vger.kernel.org>
MIME-Version: 1.0
Content-Transfer-Encoding: 8bit

The file handle held in struct pnfs_ff_layout is copied directly out
of a struct svc_fh, whose fh_handle member is a struct knfsd_fh.
Storing the layout's copy as struct nfs_fh instead forced an
open-coded field-by-field copy between two unrelated structures.

Hold the layout's file handle in struct knfsd_fh so the copy uses the
canonical fh_copy_shallow() helper and server code no longer reaches
into a separate file handle representation.

Cc: Thomas Haynes <loghyr@hammerspace.com>
Signed-off-by: Chuck Lever <cel@kernel.org>
---
 fs/nfsd/flexfilelayout.c    | 3 +--
 fs/nfsd/flexfilelayoutxdr.c | 4 ++--
 fs/nfsd/flexfilelayoutxdr.h | 3 ++-
 3 files changed, 5 insertions(+), 5 deletions(-)

diff --git a/fs/nfsd/flexfilelayout.c b/fs/nfsd/flexfilelayout.c
index 9f532418cac8..89298e77daa6 100644
--- a/fs/nfsd/flexfilelayout.c
+++ b/fs/nfsd/flexfilelayout.c
@@ -62,8 +62,7 @@ nfsd4_ff_proc_layoutget(struct svc_rqst *rqstp, struct inode *inode,
 	if (error)
 		goto out_error;
 
-	fl->fh.size = fhp->fh_handle.fh_size;
-	memcpy(fl->fh.data, &fhp->fh_handle.fh_raw, fl->fh.size);
+	fh_copy_shallow(&fl->fh, &fhp->fh_handle);
 
 	/* Give whole file layout segments */
 	seg->offset = 0;
diff --git a/fs/nfsd/flexfilelayoutxdr.c b/fs/nfsd/flexfilelayoutxdr.c
index 97d8a28dd3a0..5c48d35f4bd8 100644
--- a/fs/nfsd/flexfilelayoutxdr.c
+++ b/fs/nfsd/flexfilelayoutxdr.c
@@ -31,7 +31,7 @@ nfsd4_ff_encode_layoutget(struct xdr_stream *xdr,
 	struct ff_idmap uid;
 	struct ff_idmap gid;
 
-	fh_len = 4 + xdr_align_size(fl->fh.size);
+	fh_len = 4 + xdr_align_size(fl->fh.fh_size);
 
 	uid.len = sprintf(uid.buf, "%u", from_kuid(&init_user_ns, fl->uid));
 	gid.len = sprintf(gid.buf, "%u", from_kgid(&init_user_ns, fl->gid));
@@ -69,7 +69,7 @@ nfsd4_ff_encode_layoutget(struct xdr_stream *xdr,
 				    sizeof(stateid_opaque_t));
 
 	*p++ = cpu_to_be32(1);			/* single file handle */
-	p = xdr_encode_opaque(p, fl->fh.data, fl->fh.size);
+	p = xdr_encode_opaque(p, fl->fh.fh_raw, fl->fh.fh_size);
 
 	p = xdr_encode_opaque(p, uid.buf, uid.len);
 	p = xdr_encode_opaque(p, gid.buf, gid.len);
diff --git a/fs/nfsd/flexfilelayoutxdr.h b/fs/nfsd/flexfilelayoutxdr.h
index 6d5a1066a903..92752092e2f8 100644
--- a/fs/nfsd/flexfilelayoutxdr.h
+++ b/fs/nfsd/flexfilelayoutxdr.h
@@ -6,6 +6,7 @@
 #define _NFSD_FLEXFILELAYOUTXDR_H 1
 
 #include <linux/inet.h>
+#include "nfsfh.h"
 #include "xdr4.h"
 
 #define FF_FLAGS_NO_LAYOUTCOMMIT 1
@@ -39,7 +40,7 @@ struct pnfs_ff_layout {
 	kgid_t				gid;
 	struct nfsd4_deviceid		deviceid;
 	stateid_t			stateid;
-	struct nfs_fh			fh;
+	struct knfsd_fh			fh;
 };
 
 __be32 nfsd4_ff_encode_getdeviceinfo(struct xdr_stream *xdr,
-- 
2.54.0

