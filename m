Received: from smtp.kernel.org (aws-us-west-2-korg-mail-alma10-1.taild15c8.ts.net [100.103.45.18])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 522C929992A
	for <linux-nfs@vger.kernel.org>; Sun,  6 Sep 2026 18:41:42 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=100.103.45.18
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1788720104; cv=none; b=hYEByBAqoElyfGBUfozbzqW+FEMDgTr0avsRziM4iZSvWz5UwMTuUzH5Mm8y290Vma/f+iU6NIndHZJDsoFw1eDLNdSm3k4nsrGejyD8ozDzz0bVijVt1n0Y7JwG/oLrq/QO0FSkMXz8WmP4y9ZuVAYioiNAZupbSdc9XSdPi3Q=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1788720104; c=relaxed/simple;
	bh=Fyx1UPuMGwCAtLO7isJ89yIg4qJj3/Rx5OW6cPjIHz8=;
	h=From:To:Cc:Subject:Date:Message-ID:MIME-Version; b=SkefoEvSLD21tBJQ3JsssYaQoASmh/Y5b85/fdSDkXMjSwIko3LYLL4Ld3ojwFQBQSVWFNaZM68+7AMx1+LqFeZT9dwEh6W4TiMZVJHd/jL0P61OdJr/vlMFLdbBued23Oakxe3hbdOvxL73AfAwhmT8LOkrLjXCpDUIwU4rZ24=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.b=CuP5M4kt; arc=none smtp.client-ip=100.103.45.18
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.b="CuP5M4kt"
Received: by smtp.kernel.org (Postfix) with ESMTPSA id 1A0201F00A3A;
	Sun,  6 Sep 2026 18:41:42 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=kernel.org;
	s=k20260515; t=1788720102;
	bh=JnBnO+xAKz56QXsfnbZUQ+hvYq9cRfG6xztJjuIB6qg=;
	h=From:To:Cc:Subject:Date;
	b=CuP5M4ktejocDsz7RMdTm1rj6qjWHj2AHadAbKY25c/uPGraT3jeitacdaydSHILv
	 pAm1IkVB/4JHv6h6hNk1xeAA6OXPvOfwEa5PxZOMZofMK56ZevzEkYpOX/OLCqPHdu
	 ACZofG2DJOzBFEXwzCULUYL5QwBZuqp5ZKOwuwYd8i9B1YX4UTjoEnuA94qqFcCoba
	 jqmDJYguSIEQBCWISDq/E5yvGMooTYTYQxf5+Lp0RP+UM1zvrWPZJ3SlcsI+bJX9lV
	 5JmDKUraBTWX+ZHNxxUxlToLivaubp17hfq3PYEMRa5Fi8G6QhuP94oVYNIxuhc8pu
	 qphjpd8olf6vA==
From: Chuck Lever <cel@kernel.org>
To: NeilBrown <neilb@ownmail.net>
Cc: Jeff Layton <jlayton@kernel.org>,
	Olga Kornievskaia <okorniev@redhat.com>,
	Dai Ngo <dai.ngo@oracle.com>,
	Tom Talpey <tom@talpey.com>,
	<linux-nfs@vger.kernel.org>
Subject: [PATCH v1] NFSD: return NFS4ERR_EXIST for a guarded OPEN of a non-regular object
Date: Sun,  6 Sep 2026 14:41:41 -0400
Message-ID: <20260906184141.3453309-1-cel@kernel.org>
X-Mailer: git-send-email 2.54.0
Precedence: bulk
X-Mailing-List: linux-nfs@vger.kernel.org
List-Id: <linux-nfs.vger.kernel.org>
List-Subscribe: <mailto:linux-nfs+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:linux-nfs+unsubscribe@vger.kernel.org>
MIME-Version: 1.0
Content-Transfer-Encoding: 8bit

Commit db8b567ffa98 ("nfsd: (almost) always open file in
nfsd4_create_file()") moved the regular-file type check ahead of the
createmode logic. A GUARDED4, EXCLUSIVE4, or EXCLUSIVE4_1 OPEN that
finds a directory or symbolic link under the requested name now fails
with NFS4ERR_ISDIR or NFS4ERR_SYMLINK instead of NFS4ERR_EXIST.

RFC 8881 Section 18.16.3 requires NFS4ERR_EXIST when a guarded create
finds any object under that name, or when an exclusive create's
verifier does not match. The type-specific errors in Section 18.16.4
apply to opening an existing file, which only UNCHECKED4 does.

Fixes: db8b567ffa98 ("nfsd: (almost) always open file in nfsd4_create_file()")
Signed-off-by: Chuck Lever <cel@kernel.org>
---
 fs/nfsd/nfs4proc.c | 12 +++++++++++-
 1 file changed, 11 insertions(+), 1 deletion(-)

Neil, I'll apply this to nfsd-testing. It should be in time to get
into nfsd-next before v7.4.


diff --git a/fs/nfsd/nfs4proc.c b/fs/nfsd/nfs4proc.c
index bb74eef43938..3a82af381a8d 100644
--- a/fs/nfsd/nfs4proc.c
+++ b/fs/nfsd/nfs4proc.c
@@ -430,7 +430,17 @@ nfsd4_create_file(struct svc_rqst *rqstp, struct svc_fh *fhp,
 				       oflags,
 				       open->op_iattr.ia_mode);
 	if (IS_ERR(open->op_filp)) {
-		status = nfserrno(PTR_ERR(open->op_filp));
+		int hosterr = PTR_ERR(open->op_filp);
+
+		if (open->op_createmode != NFS4_CREATE_UNCHECKED) {
+			switch (hosterr) {
+			case -EISDIR:
+			case -ELOOP:
+			case -EFTYPE:
+				hosterr = -EEXIST;
+			}
+		}
+		status = nfserrno(hosterr);
 		open->op_filp = NULL;
 		if (status == nfserr_noent && create_status)
 			status = create_status;
-- 
2.54.0

