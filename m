Received: from smtp.kernel.org (aws-us-west-2-korg-mail-alma10-1.taild15c8.ts.net [100.103.45.18])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id BC3B047FAFF
	for <linux-nfs@vger.kernel.org>; Wed, 26 Aug 2026 19:44:54 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=100.103.45.18
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1787773503; cv=none; b=FR+8wqIdputHuz9mzJvaEHhdTMPTO5J1t/gIxtZD9Z/69AzFjFye5Jnx+GjGEv+exUpIaDUibweuvM/HYw6okcrhFHaslaaQiOtxtzLkMdVMhcYrgUkMrZ2dQ4GLIYYSivLncUkhmpwjzw2u729F75tqadwRE9/Jzpt+SrDHE0k=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1787773503; c=relaxed/simple;
	bh=gabtukkNs5Tpll5Bo7g6fc3iX2C8vkwvPgB/gmvOW04=;
	h=From:To:Cc:Subject:Date:Message-ID:MIME-Version; b=eS8U6gJg0UOtflxyn/T0WPide4bSy6yZ9zLlJOS2TKRvZih9LzTZv62f3n+Mn/1W7R74yylxJ3GIUJO66lt1K6Shd/MQ0IB2FXpGyHocB4Yad7wmafZ6Dbasr0J8XiBr8dh53Kb3RsWRLZuYwS7B9FTat+sqcFwav+WLDm/Fvog=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.b=APTZK/bX; arc=none smtp.client-ip=100.103.45.18
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.b="APTZK/bX"
Received: by smtp.kernel.org (Postfix) with ESMTPSA id 3CE9E1F000E9;
	Wed, 26 Aug 2026 19:44:45 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=kernel.org;
	s=k20260515; t=1787773485;
	bh=EsIe9P1lLvum9Gd4r6dFfoLL42Rwtn2k1BvlaHlqYN4=;
	h=From:To:Cc:Subject:Date;
	b=APTZK/bXAJXjsv0c6C9exMw7+hdh5H1BoE/unK8Af+0e8g629iTJMF5soCUypt1Pj
	 44LdxHb6GWs2zFxzRaHfSc4Ku4ftpCMJ+Z14OzslJg0gz+ebHCz9YT1JHfzohNm1/R
	 3I5NiFTNo0FZkJ961AfHUGwOf0HXOaUCVZgcIJXsyAWHmedgZ91AcYLXxOTy03Dff2
	 FZuKTQ6l+8vwg2o+qQFLxlpz1MyWUz8A7SHOBbLmqoa5+G4tSII7kaNwYgDM7K/T6L
	 o2+hFbG9CS43NCzazMg3TSD7sTb9TwMBYKkkilSisycVpQ691KvNvV2RohLayndqI3
	 8d0u1I2Imyq2w==
From: Chuck Lever <cel@kernel.org>
To: NeilBrown <neil@brown.name>,
	Jeff Layton <jlayton@kernel.org>,
	Olga Kornievskaia <okorniev@redhat.com>,
	Dai Ngo <dai.ngo@oracle.com>,
	Tom Talpey <tom@talpey.com>
Cc: <linux-nfs@vger.kernel.org>
Subject: [PATCH 1/2] NFS: Import NFS3ERR definitions
Date: Wed, 26 Aug 2026 15:44:43 -0400
Message-ID: <20260826194444.148243-1-cel@kernel.org>
X-Mailer: git-send-email 2.55.0
Precedence: bulk
X-Mailing-List: linux-nfs@vger.kernel.org
List-Id: <linux-nfs.vger.kernel.org>
List-Subscribe: <mailto:linux-nfs+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:linux-nfs+unsubscribe@vger.kernel.org>
MIME-Version: 1.0
Content-Transfer-Encoding: 8bit

enum nfs_stat in uapi/linux/nfs.h collects the on-the-wire status
codes for every NFS version under version-agnostic NFSERR_* names.
The in-kernel NFS client and server reference these names
internally, which drags uapi/linux/nfs.h into many translation
units that need nothing else from that header.

xdrgen conversion will provide spec-based definitions of the NFS
status enum constants. Replacing the existing internal references
with version-specific names requires a version-specific spelling
for each code that NFSD uses.

linux/nfs4.h already supplies the NFSv4 codes, but NFSv3 has no
counterpart header, and not every NFSv3 code has an NFS4ERR_*
spelling: NFSERR_NOT_SYNC (10002) and NFSERR_REMOTE (71) have no
NFSv4 equivalent at all, and NFSERR_JUKEBOX (10008) appears in
NFSv4 as NFS4ERR_DELAY.

Introduce the NFSv3 status codes as NFS3ERR_* in linux/nfs3.h so a
subsequent patch can respell NFSD's status definitions without
relying on uapi/linux/nfs.h.

Signed-off-by: Chuck Lever <cel@kernel.org>
---
 include/linux/nfs3.h | 35 +++++++++++++++++++++++++++++++++++
 1 file changed, 35 insertions(+)

diff --git a/include/linux/nfs3.h b/include/linux/nfs3.h
index 1d18da0860d5..b6539a75edea 100644
--- a/include/linux/nfs3.h
+++ b/include/linux/nfs3.h
@@ -7,6 +7,41 @@
 
 #include <uapi/linux/nfs3.h>
 
+/*
+ * NFSv3 error status values.
+ * See RFC 1813 Section 2.5
+ */
+enum {
+	NFS3ERR_PERM		= 1,
+	NFS3ERR_NOENT		= 2,
+	NFS3ERR_IO		= 5,
+	NFS3ERR_NXIO		= 6,
+	NFS3ERR_ACCES		= 13,
+	NFS3ERR_EXIST		= 17,
+	NFS3ERR_XDEV		= 18,
+	NFS3ERR_NODEV		= 19,
+	NFS3ERR_NOTDIR		= 20,
+	NFS3ERR_ISDIR		= 21,
+	NFS3ERR_INVAL		= 22,
+	NFS3ERR_FBIG		= 27,
+	NFS3ERR_NOSPC		= 28,
+	NFS3ERR_ROFS		= 30,
+	NFS3ERR_MLINK		= 31,
+	NFS3ERR_NAMETOOLONG	= 63,
+	NFS3ERR_NOTEMPTY	= 66,
+	NFS3ERR_DQUOT		= 69,
+	NFS3ERR_STALE		= 70,
+	NFS3ERR_REMOTE		= 71,
+	NFS3ERR_BADHANDLE	= 10001,
+	NFS3ERR_NOT_SYNC	= 10002,
+	NFS3ERR_BAD_COOKIE	= 10003,
+	NFS3ERR_NOTSUPP		= 10004,
+	NFS3ERR_TOOSMALL	= 10005,
+	NFS3ERR_SERVERFAULT	= 10006,
+	NFS3ERR_BADTYPE		= 10007,
+	NFS3ERR_JUKEBOX		= 10008,
+};
+
 enum nfs3_stable_how {
 	NFS_UNSTABLE = 0,
 	NFS_DATA_SYNC = 1,
-- 
2.55.0

