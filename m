Received: from smtp.kernel.org (aws-us-west-2-korg-mail-alma10-1.taild15c8.ts.net [100.103.45.18])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 6261943D51D
	for <linux-nfs@vger.kernel.org>; Mon, 20 Jul 2026 16:37:28 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=100.103.45.18
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1784565450; cv=none; b=T7J0kTo+U+sRp14JgijXlyMifjWj2/JxuKBwhdf7DkPditM/ssaxqsVLKN+S4McNvVX3FEIIFRUIYF+sF1687o4noArQKYSRJBC01/4ISl8A78mZkNGjMk7EPiMhIDPgqTaTZAUSTpxkrrPP20MlSqfnWTJ1JthLU958hDbd2HY=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1784565450; c=relaxed/simple;
	bh=ynKmHC3UhCUt8ykrd0i+kdygMcYJkheqRtJ85SkGIA0=;
	h=From:To:Cc:Subject:Date:Message-ID:MIME-Version; b=QojaB17Q+B66eJp+nDHWbK/oHuHD6syCKBgeOI1n9Fjry/p+XbIxyjuwSKCTTsfsOi7FMxarIySrHOCLcpjAsk68xNn36iVZIzIqS3geyH/1isYrg72+81BIlizU2uYLFdsropipTrdpQTKf+lUqsI7Qn+/+9dvKhUl5VS/Tcco=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.b=EtSj7QGL; arc=none smtp.client-ip=100.103.45.18
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.b="EtSj7QGL"
Received: by smtp.kernel.org (Postfix) with ESMTPSA id 3C6F41F000E9;
	Mon, 20 Jul 2026 16:37:27 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=kernel.org;
	s=k20260515; t=1784565447;
	bh=UVCgC83Rgx/r2gW34A5B4Ejv6F6LEcbWm0RJbqevSzE=;
	h=From:To:Cc:Subject:Date;
	b=EtSj7QGL8pxVcfPeRePENCOEb2qRhgwHgxTyKRvhgM6OeHu5+rYcYJfxVxA/ELJsa
	 23IbSClGWdhj+yK2U+hfGed1cmJ9LXk/09QowZRW6BvJhdm6Xg7LYZF67fQ7w1sqbn
	 DONIzbO+pbb2SjX3Q0N+WU/Rj/iuWtmmGrhvTeGi0qgc8xlk1seRszkF3B9ejnWKf0
	 9tNJq9jUSNgi9L4A6JyBXAA4gS9M5xvHasjhsz2KlcTb7L36O3aeTNzcLtKhMYP3IT
	 F15XXrduaee4s8PmqGDSNQFiXGtaPnl6SGiU4fOVffuV0z4izowCys3lwlMo1MtZuB
	 Ur6etthdUUcEA==
From: Chuck Lever <cel@kernel.org>
To: NeilBrown <neil@brown.name>,
	Jeff Layton <jlayton@kernel.org>,
	Olga Kornievskaia <okorniev@redhat.com>,
	Dai Ngo <dai.ngo@oracle.com>,
	Tom Talpey <tom@talpey.com>
Cc: <linux-nfs@vger.kernel.org>,
	sashiko-bot <sashiko-bot@kernel.org>
Subject: [PATCH] NFSD: Map flex file layout IDs through the request's user namespace
Date: Mon, 20 Jul 2026 12:37:24 -0400
Message-ID: <20260720163724.810227-1-cel@kernel.org>
X-Mailer: git-send-email 2.54.0
Precedence: bulk
X-Mailing-List: linux-nfs@vger.kernel.org
List-Id: <linux-nfs.vger.kernel.org>
List-Subscribe: <mailto:linux-nfs+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:linux-nfs+unsubscribe@vger.kernel.org>
MIME-Version: 1.0
Content-Transfer-Encoding: 8bit

nfsd4_ff_proc_layoutget() and nfsd4_ff_encode_layoutget() translate
the file's owner and group with init_user_ns, but every other identity
nfsd places on the wire goes through nfsd_user_namespace(). When the
transport carries a credential from a non-initial user namespace, the
flex file layout reports host-global IDs. The client copies those IDs
into the AUTH_SYS credential it presents to the data server, and
svcauth_unix_accept() resolves that credential in the transport's
namespace, so data server I/O runs under an identity unrelated to the
file's owner.

Switching to the request's namespace introduces a second hazard.
from_kuid() returns (uid_t)-1 when the target namespace has no
mapping for the owner, and the IOMODE_READ arm adds one to that
result to derive an identity for which the data server denies
writes. The addition would wrap to zero, handing the client uid 0
instead of an identity distinct from the owner.

Translate both IDs in nfsd4_ff_proc_layoutget(), which has the
svc_rqst, and carry the wire values in struct pnfs_ff_layout.
from_kuid_munged() substitutes overflowuid for an unmapped owner and
thus never returns (uid_t)-1, so the increment cannot wrap to zero.

Fixes: 9b9960a0ca47 ("nfsd: Add a super simple flex file server")
Reported-by: sashiko-bot <sashiko-bot@kernel.org>
Closes: https://sashiko.dev/#/patchset/20260720141442.783935-1-cel@kernel.org?part=3
Signed-off-by: Chuck Lever <cel@kernel.org>
---
 fs/nfsd/flexfilelayout.c    | 20 ++++++++++++--------
 fs/nfsd/flexfilelayoutxdr.c |  4 ++--
 fs/nfsd/flexfilelayoutxdr.h |  5 +++--
 3 files changed, 17 insertions(+), 12 deletions(-)

diff --git a/fs/nfsd/flexfilelayout.c b/fs/nfsd/flexfilelayout.c
index 9f532418cac8..c6e6b9106a83 100644
--- a/fs/nfsd/flexfilelayout.c
+++ b/fs/nfsd/flexfilelayout.c
@@ -15,6 +15,7 @@
 
 #include "nfserr.h"
 #include "flexfilelayoutxdr.h"
+#include "auth.h"
 #include "pnfs.h"
 #include "vfs.h"
 
@@ -24,10 +25,10 @@ static __be32
 nfsd4_ff_proc_layoutget(struct svc_rqst *rqstp, struct inode *inode,
 		const struct svc_fh *fhp, struct nfsd4_layoutget *args)
 {
+	struct user_namespace *userns = nfsd_user_namespace(rqstp);
 	struct nfsd4_layout_seg *seg = &args->lg_seg;
 	u32 device_generation = 0;
 	int error;
-	uid_t u;
 
 	struct pnfs_ff_layout *fl;
 
@@ -50,13 +51,16 @@ nfsd4_ff_proc_layoutget(struct svc_rqst *rqstp, struct inode *inode,
 	fl->flags = FF_FLAGS_NO_LAYOUTCOMMIT | FF_FLAGS_NO_IO_THRU_MDS |
 		    FF_FLAGS_NO_READ_IO;
 
-	/* Do not allow a IOMODE_READ segment to have write pemissions */
-	if (seg->iomode == IOMODE_READ) {
-		u = from_kuid(&init_user_ns, inode->i_uid) + 1;
-		fl->uid = make_kuid(&init_user_ns, u);
-	} else
-		fl->uid = inode->i_uid;
-	fl->gid = inode->i_gid;
+	fl->uid = from_kuid_munged(userns, inode->i_uid);
+	fl->gid = from_kgid_munged(userns, inode->i_gid);
+
+	/*
+	 * Do not allow an IOMODE_READ segment to have write permissions.
+	 * The group is left intact so group-readable files stay readable;
+	 * nfsd_setuser() squashes an unmapped uid to the export's anon ID.
+	 */
+	if (seg->iomode == IOMODE_READ)
+		fl->uid++;
 
 	error = nfsd4_set_deviceid(&fl->deviceid, fhp, device_generation);
 	if (error)
diff --git a/fs/nfsd/flexfilelayoutxdr.c b/fs/nfsd/flexfilelayoutxdr.c
index 97d8a28dd3a0..c12bb7c371b0 100644
--- a/fs/nfsd/flexfilelayoutxdr.c
+++ b/fs/nfsd/flexfilelayoutxdr.c
@@ -33,8 +33,8 @@ nfsd4_ff_encode_layoutget(struct xdr_stream *xdr,
 
 	fh_len = 4 + xdr_align_size(fl->fh.size);
 
-	uid.len = sprintf(uid.buf, "%u", from_kuid(&init_user_ns, fl->uid));
-	gid.len = sprintf(gid.buf, "%u", from_kgid(&init_user_ns, fl->gid));
+	uid.len = sprintf(uid.buf, "%u", fl->uid);
+	gid.len = sprintf(gid.buf, "%u", fl->gid);
 
 	/* data server entry: deviceid + efficiency + stateid + fh list +
 	 * user + group + flags + stats_collect_hint
diff --git a/fs/nfsd/flexfilelayoutxdr.h b/fs/nfsd/flexfilelayoutxdr.h
index 6d5a1066a903..3e1876d49db2 100644
--- a/fs/nfsd/flexfilelayoutxdr.h
+++ b/fs/nfsd/flexfilelayoutxdr.h
@@ -35,8 +35,9 @@ struct pnfs_ff_device_addr {
 struct pnfs_ff_layout {
 	u32				flags;
 	u32				stats_collect_hint;
-	kuid_t				uid;
-	kgid_t				gid;
+	/* Values to encode; nfsd4_ff_proc_layoutget() has mapped these */
+	u32				uid;
+	u32				gid;
 	struct nfsd4_deviceid		deviceid;
 	stateid_t			stateid;
 	struct nfs_fh			fh;
-- 
2.54.0

