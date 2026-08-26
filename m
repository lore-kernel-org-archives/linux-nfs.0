Received: from smtp.kernel.org (aws-us-west-2-korg-mail-alma10-1.taild15c8.ts.net [100.103.45.18])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 2C039490C0C
	for <linux-nfs@vger.kernel.org>; Wed, 26 Aug 2026 19:44:52 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=100.103.45.18
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1787773510; cv=none; b=lXYhbPsj2JBlEIbH2KN0pVLanltDKuVvUYqo4pbL/jZ43QqEQ9ZvhW24HEKbgQHnwtYx9ZX+rJ1d3xP6vFn17hiGtqtg6WQmYOHO1RlOkMDCxRrxWhZbZGabHCd2ut/HdSt9ZhCo49F8/G9FkXVQR6dGRFlLXdTJAtXrJExjPmY=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1787773510; c=relaxed/simple;
	bh=m7Ob3olpljDCCDWWy148CGNOzZnXUSC1FKtYresA8VQ=;
	h=From:To:Cc:Subject:Date:Message-ID:In-Reply-To:References:
	 MIME-Version; b=FI9j1oDgHVtMpwaO0rGv+dwx7NDJWNbQHY4rNBbWSzIB8E95ylV6vJeH3n8TwR9IFMvCCXbAK/8UFDSyLRGppssQJNEjHT4rVm/caCE7GnBo+3Rs9JxYr4pSknq7KlxLTxmL+W96RERSIZHlWQTCLibVqs0IaM0WYNjKB01kMFI=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.b=L4NTYCpK; arc=none smtp.client-ip=100.103.45.18
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.b="L4NTYCpK"
Received: by smtp.kernel.org (Postfix) with ESMTPSA id 00CA51F00A3A;
	Wed, 26 Aug 2026 19:44:45 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=kernel.org;
	s=k20260515; t=1787773486;
	bh=ahTZW8AKZ2paZ7qQ9JAqpdNaUJ9B/G8jOBM2zoMcVTc=;
	h=From:To:Cc:Subject:Date:In-Reply-To:References;
	b=L4NTYCpKU1VNZSga74SqIs7pmQrxp1iTzfP6pAZRWpgiXZGRCZ+QGoHo8RlWLe+1c
	 by7FVmIqB1OMaQbAUJ4wxKCcQ/T3U02HtupSJahjY80G/oSFofnQCUknIfHBcK5wVC
	 YFPugiYFkHgSAuuktdtki59e+jKP/eWTGeTSwBKMLkYFNcHisuZWidjPIuvMNE+7Fa
	 Z0zl5NbiJ94VurSNAwnUXxz091QdWjn50RkBGSmKyJ4WTc2D5yiXPp+a2AgIMYYV4N
	 ys2o2zIzokcDNPvRZG9kGjWG4n9wSfLPp7osjOHEzzkRmdHfHML7QSsxjfCDnmNw1+
	 Id/jn4lAsBo/Q==
From: Chuck Lever <cel@kernel.org>
To: NeilBrown <neil@brown.name>,
	Jeff Layton <jlayton@kernel.org>,
	Olga Kornievskaia <okorniev@redhat.com>,
	Dai Ngo <dai.ngo@oracle.com>,
	Tom Talpey <tom@talpey.com>
Cc: <linux-nfs@vger.kernel.org>
Subject: [PATCH 2/2] NFSD: Rework be32 nfserr definitions
Date: Wed, 26 Aug 2026 15:44:44 -0400
Message-ID: <20260826194444.148243-2-cel@kernel.org>
X-Mailer: git-send-email 2.55.0
In-Reply-To: <20260826194444.148243-1-cel@kernel.org>
References: <20260826194444.148243-1-cel@kernel.org>
Precedence: bulk
X-Mailing-List: linux-nfs@vger.kernel.org
List-Id: <linux-nfs.vger.kernel.org>
List-Subscribe: <mailto:linux-nfs+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:linux-nfs+unsubscribe@vger.kernel.org>
MIME-Version: 1.0
Content-Transfer-Encoding: 8bit

fs/nfsd/nfserr.h builds NFSD's internal __be32 nfserr_* values
by wrapping the version-agnostic NFSERR_* status codes from
uapi/linux/nfs.h in cpu_to_be32(), which it reaches through its
include of linux/nfs.h.

A subsequent patch replaces that include with the xdrgen-generated
linux/sunrpc/xdrgen/nfs2.h. The generated header re-supplies
only the eighteen NFSv2 status codes; the NFSv3 and NFSv4 codes
that nfserr.h also uses (NFSERR_INVAL, NFSERR_JUKEBOX,
NFSERR_RESOURCE, and the rest) would be left undeclared.

Respell those definitions in terms of the version-specific
NFS3ERR_* and NFS4ERR_* codes from linux/nfs3.h and linux/nfs4.h,
and switch the one bare NFSERR_MOVED in nfs4xdr.c to NFS4ERR_MOVED.
The wire values are unchanged; NFSD no longer depends on the
version-agnostic NFSv3 and NFSv4 names.

Signed-off-by: Chuck Lever <cel@kernel.org>
---
 fs/nfsd/nfs4xdr.c |   2 +-
 fs/nfsd/nfserr.h  | 129 +++++++++++++++++++++++-----------------------
 2 files changed, 66 insertions(+), 65 deletions(-)

diff --git a/fs/nfsd/nfs4xdr.c b/fs/nfsd/nfs4xdr.c
index 5bfbeb87394e..00ddaac499c6 100644
--- a/fs/nfsd/nfs4xdr.c
+++ b/fs/nfsd/nfs4xdr.c
@@ -3213,7 +3213,7 @@ static __be32 fattr_handle_absent_fs(u32 *bmval0, u32 *bmval1, u32 *bmval2, u32
 	    *bmval1 & ~WORD1_ABSENT_FS_ATTRS) {
 		if (*bmval0 & FATTR4_WORD0_RDATTR_ERROR ||
 	            *bmval0 & FATTR4_WORD0_FS_LOCATIONS)
-			*rdattr_err = NFSERR_MOVED;
+			*rdattr_err = NFS4ERR_MOVED;
 		else
 			return nfserr_moved;
 	}
diff --git a/fs/nfsd/nfserr.h b/fs/nfsd/nfserr.h
index 9b9df7aab220..d1c434b834b2 100644
--- a/fs/nfsd/nfserr.h
+++ b/fs/nfsd/nfserr.h
@@ -11,76 +11,77 @@
 #define LINUX_NFSD_NFSERR_H
 
 #include <linux/nfs.h>
+#include <linux/nfs3.h>
 #include <linux/nfs4.h>
 
 /*
  * These macros provide pre-xdr'ed values for faster operation.
  */
-#define	nfs_ok			cpu_to_be32(NFS_OK)
-#define	nfserr_perm		cpu_to_be32(NFSERR_PERM)
-#define	nfserr_noent		cpu_to_be32(NFSERR_NOENT)
-#define	nfserr_io		cpu_to_be32(NFSERR_IO)
-#define	nfserr_nxio		cpu_to_be32(NFSERR_NXIO)
-#define	nfserr_acces		cpu_to_be32(NFSERR_ACCES)
-#define	nfserr_exist		cpu_to_be32(NFSERR_EXIST)
-#define	nfserr_xdev		cpu_to_be32(NFSERR_XDEV)
-#define	nfserr_nodev		cpu_to_be32(NFSERR_NODEV)
-#define	nfserr_notdir		cpu_to_be32(NFSERR_NOTDIR)
-#define	nfserr_isdir		cpu_to_be32(NFSERR_ISDIR)
-#define	nfserr_inval		cpu_to_be32(NFSERR_INVAL)
-#define	nfserr_fbig		cpu_to_be32(NFSERR_FBIG)
-#define	nfserr_nospc		cpu_to_be32(NFSERR_NOSPC)
-#define	nfserr_rofs		cpu_to_be32(NFSERR_ROFS)
-#define	nfserr_mlink		cpu_to_be32(NFSERR_MLINK)
-#define	nfserr_nametoolong	cpu_to_be32(NFSERR_NAMETOOLONG)
-#define	nfserr_notempty		cpu_to_be32(NFSERR_NOTEMPTY)
-#define	nfserr_dquot		cpu_to_be32(NFSERR_DQUOT)
-#define	nfserr_stale		cpu_to_be32(NFSERR_STALE)
-#define	nfserr_remote		cpu_to_be32(NFSERR_REMOTE)
-#define	nfserr_wflush		cpu_to_be32(NFSERR_WFLUSH)
-#define	nfserr_badhandle	cpu_to_be32(NFSERR_BADHANDLE)
-#define	nfserr_notsync		cpu_to_be32(NFSERR_NOT_SYNC)
-#define	nfserr_badcookie	cpu_to_be32(NFSERR_BAD_COOKIE)
-#define	nfserr_notsupp		cpu_to_be32(NFSERR_NOTSUPP)
-#define	nfserr_toosmall		cpu_to_be32(NFSERR_TOOSMALL)
-#define	nfserr_serverfault	cpu_to_be32(NFSERR_SERVERFAULT)
-#define	nfserr_badtype		cpu_to_be32(NFSERR_BADTYPE)
-#define	nfserr_jukebox		cpu_to_be32(NFSERR_JUKEBOX)
-#define	nfserr_denied		cpu_to_be32(NFSERR_DENIED)
-#define	nfserr_deadlock		cpu_to_be32(NFSERR_DEADLOCK)
-#define nfserr_expired          cpu_to_be32(NFSERR_EXPIRED)
-#define	nfserr_bad_cookie	cpu_to_be32(NFSERR_BAD_COOKIE)
-#define	nfserr_same		cpu_to_be32(NFSERR_SAME)
-#define	nfserr_clid_inuse	cpu_to_be32(NFSERR_CLID_INUSE)
-#define	nfserr_stale_clientid	cpu_to_be32(NFSERR_STALE_CLIENTID)
-#define	nfserr_resource		cpu_to_be32(NFSERR_RESOURCE)
-#define	nfserr_moved		cpu_to_be32(NFSERR_MOVED)
-#define	nfserr_nofilehandle	cpu_to_be32(NFSERR_NOFILEHANDLE)
-#define	nfserr_minor_vers_mismatch	cpu_to_be32(NFSERR_MINOR_VERS_MISMATCH)
-#define nfserr_share_denied	cpu_to_be32(NFSERR_SHARE_DENIED)
-#define nfserr_stale_stateid	cpu_to_be32(NFSERR_STALE_STATEID)
-#define nfserr_old_stateid	cpu_to_be32(NFSERR_OLD_STATEID)
-#define nfserr_bad_stateid	cpu_to_be32(NFSERR_BAD_STATEID)
-#define nfserr_bad_seqid	cpu_to_be32(NFSERR_BAD_SEQID)
-#define	nfserr_symlink		cpu_to_be32(NFSERR_SYMLINK)
-#define	nfserr_not_same		cpu_to_be32(NFSERR_NOT_SAME)
-#define nfserr_lock_range	cpu_to_be32(NFSERR_LOCK_RANGE)
-#define	nfserr_restorefh	cpu_to_be32(NFSERR_RESTOREFH)
-#define	nfserr_attrnotsupp	cpu_to_be32(NFSERR_ATTRNOTSUPP)
-#define	nfserr_bad_xdr		cpu_to_be32(NFSERR_BAD_XDR)
-#define	nfserr_openmode		cpu_to_be32(NFSERR_OPENMODE)
-#define	nfserr_badowner		cpu_to_be32(NFSERR_BADOWNER)
-#define	nfserr_locks_held	cpu_to_be32(NFSERR_LOCKS_HELD)
-#define	nfserr_op_illegal	cpu_to_be32(NFSERR_OP_ILLEGAL)
-#define	nfserr_grace		cpu_to_be32(NFSERR_GRACE)
-#define	nfserr_no_grace		cpu_to_be32(NFSERR_NO_GRACE)
-#define	nfserr_reclaim_bad	cpu_to_be32(NFSERR_RECLAIM_BAD)
-#define	nfserr_badname		cpu_to_be32(NFSERR_BADNAME)
-#define	nfserr_admin_revoked	cpu_to_be32(NFS4ERR_ADMIN_REVOKED)
-#define	nfserr_cb_path_down	cpu_to_be32(NFSERR_CB_PATH_DOWN)
-#define	nfserr_locked		cpu_to_be32(NFSERR_LOCKED)
-#define	nfserr_wrongsec		cpu_to_be32(NFSERR_WRONGSEC)
+#define	nfs_ok				cpu_to_be32(NFS_OK)
+#define	nfserr_perm			cpu_to_be32(NFSERR_PERM)
+#define	nfserr_noent			cpu_to_be32(NFSERR_NOENT)
+#define	nfserr_io			cpu_to_be32(NFSERR_IO)
+#define	nfserr_nxio			cpu_to_be32(NFSERR_NXIO)
+#define	nfserr_acces			cpu_to_be32(NFSERR_ACCES)
+#define	nfserr_exist			cpu_to_be32(NFSERR_EXIST)
+#define	nfserr_xdev			cpu_to_be32(NFS3ERR_XDEV)
+#define	nfserr_nodev			cpu_to_be32(NFSERR_NODEV)
+#define	nfserr_notdir			cpu_to_be32(NFSERR_NOTDIR)
+#define	nfserr_isdir			cpu_to_be32(NFSERR_ISDIR)
+#define	nfserr_inval			cpu_to_be32(NFS3ERR_INVAL)
+#define	nfserr_fbig			cpu_to_be32(NFSERR_FBIG)
+#define	nfserr_nospc			cpu_to_be32(NFSERR_NOSPC)
+#define	nfserr_rofs			cpu_to_be32(NFSERR_ROFS)
+#define	nfserr_mlink			cpu_to_be32(NFS3ERR_MLINK)
+#define	nfserr_nametoolong		cpu_to_be32(NFSERR_NAMETOOLONG)
+#define	nfserr_notempty			cpu_to_be32(NFSERR_NOTEMPTY)
+#define	nfserr_dquot			cpu_to_be32(NFSERR_DQUOT)
+#define	nfserr_stale			cpu_to_be32(NFSERR_STALE)
+#define	nfserr_remote			cpu_to_be32(NFS3ERR_REMOTE)
+#define	nfserr_wflush			cpu_to_be32(NFSERR_WFLUSH)
+#define	nfserr_badhandle		cpu_to_be32(NFS3ERR_BADHANDLE)
+#define	nfserr_notsync			cpu_to_be32(NFS3ERR_NOT_SYNC)
+#define	nfserr_badcookie		cpu_to_be32(NFS3ERR_BAD_COOKIE)
+#define	nfserr_notsupp			cpu_to_be32(NFS3ERR_NOTSUPP)
+#define	nfserr_toosmall			cpu_to_be32(NFS3ERR_TOOSMALL)
+#define	nfserr_serverfault		cpu_to_be32(NFS3ERR_SERVERFAULT)
+#define	nfserr_badtype			cpu_to_be32(NFS3ERR_BADTYPE)
+#define	nfserr_jukebox			cpu_to_be32(NFS3ERR_JUKEBOX)
 #define nfserr_delay			cpu_to_be32(NFS4ERR_DELAY)
+#define	nfserr_same			cpu_to_be32(NFS4ERR_SAME)
+#define	nfserr_denied			cpu_to_be32(NFS4ERR_DENIED)
+#define	nfserr_deadlock			cpu_to_be32(NFS4ERR_DEADLOCK)
+#define	nfserr_expired			cpu_to_be32(NFS4ERR_EXPIRED)
+#define	nfserr_bad_cookie		cpu_to_be32(NFS4ERR_BAD_COOKIE)
+#define	nfserr_clid_inuse		cpu_to_be32(NFS4ERR_CLID_INUSE)
+#define	nfserr_stale_clientid		cpu_to_be32(NFS4ERR_STALE_CLIENTID)
+#define	nfserr_resource			cpu_to_be32(NFS4ERR_RESOURCE)
+#define	nfserr_moved			cpu_to_be32(NFS4ERR_MOVED)
+#define	nfserr_nofilehandle		cpu_to_be32(NFS4ERR_NOFILEHANDLE)
+#define	nfserr_minor_vers_mismatch	cpu_to_be32(NFS4ERR_MINOR_VERS_MISMATCH)
+#define nfserr_share_denied		cpu_to_be32(NFS4ERR_SHARE_DENIED)
+#define nfserr_stale_stateid		cpu_to_be32(NFS4ERR_STALE_STATEID)
+#define nfserr_old_stateid		cpu_to_be32(NFS4ERR_OLD_STATEID)
+#define nfserr_bad_stateid		cpu_to_be32(NFS4ERR_BAD_STATEID)
+#define nfserr_bad_seqid		cpu_to_be32(NFS4ERR_BAD_SEQID)
+#define	nfserr_symlink			cpu_to_be32(NFS4ERR_SYMLINK)
+#define	nfserr_not_same			cpu_to_be32(NFS4ERR_NOT_SAME)
+#define nfserr_lock_range		cpu_to_be32(NFS4ERR_LOCK_RANGE)
+#define	nfserr_restorefh		cpu_to_be32(NFS4ERR_RESTOREFH)
+#define	nfserr_attrnotsupp		cpu_to_be32(NFS4ERR_ATTRNOTSUPP)
+#define	nfserr_bad_xdr			cpu_to_be32(NFS4ERR_BADXDR)
+#define	nfserr_openmode			cpu_to_be32(NFS4ERR_OPENMODE)
+#define	nfserr_badowner			cpu_to_be32(NFS4ERR_BADOWNER)
+#define	nfserr_locks_held		cpu_to_be32(NFS4ERR_LOCKS_HELD)
+#define	nfserr_op_illegal		cpu_to_be32(NFS4ERR_OP_ILLEGAL)
+#define	nfserr_grace			cpu_to_be32(NFS4ERR_GRACE)
+#define	nfserr_no_grace			cpu_to_be32(NFS4ERR_NO_GRACE)
+#define	nfserr_reclaim_bad		cpu_to_be32(NFS4ERR_RECLAIM_BAD)
+#define	nfserr_badname			cpu_to_be32(NFS4ERR_BADNAME)
+#define	nfserr_admin_revoked		cpu_to_be32(NFS4ERR_ADMIN_REVOKED)
+#define	nfserr_cb_path_down		cpu_to_be32(NFS4ERR_CB_PATH_DOWN)
+#define	nfserr_locked			cpu_to_be32(NFS4ERR_LOCKED)
+#define	nfserr_wrongsec			cpu_to_be32(NFS4ERR_WRONGSEC)
 #define nfserr_badiomode		cpu_to_be32(NFS4ERR_BADIOMODE)
 #define nfserr_badlayout		cpu_to_be32(NFS4ERR_BADLAYOUT)
 #define nfserr_bad_session_digest	cpu_to_be32(NFS4ERR_BAD_SESSION_DIGEST)
-- 
2.55.0

