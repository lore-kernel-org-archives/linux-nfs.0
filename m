Received: from smtp.kernel.org (aws-us-west-2-korg-mail-alma10-1.taild15c8.ts.net [100.103.45.18])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 9670041B8F6
	for <linux-nfs@vger.kernel.org>; Thu, 24 Sep 2026 17:10:19 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=100.103.45.18
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1790269821; cv=none; b=DSUT+DShfPmaqVQe/+Jhrc6dg2FhdolpGjaEWwXqO1UbqprSsC5JRze4SYHBbpEZgG87XIGE8W6GxwE6hYQPWBdqWczMNkiA47JmHa2snz/3uwSrmjO2qQGJO4hd5CX6w5m3+a3fsRESRnkex2eEYKbNhyJfxPXF+YmXmoXY7hM=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1790269821; c=relaxed/simple;
	bh=BseKvuhqDBw02TuoZZkMqljiYQc2JbVeBNffRjrBtrY=;
	h=From:To:Cc:Subject:Date:Message-ID:In-Reply-To:References:
	 MIME-Version; b=UHqkRea/4+xJSzOiiGR7OlHghBu7uxb7ceNL8ysWpp9ZOvpycx8t5MoVcJJIPV+9aTOJjz7qgllZyg4cobyo/8lIC4fdNU4XRwhjhRvljeuOQnx5cBpwn9JCFzUI5nb6u6hE7fpFgl44JXOvLZMpAJ2AQwW9ximV83yI2nFJdrQ=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.b=LpyRMy78; arc=none smtp.client-ip=100.103.45.18
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.b="LpyRMy78"
Received: by smtp.kernel.org (Postfix) with ESMTPSA id DA4631F00893;
	Thu, 24 Sep 2026 17:10:18 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=kernel.org;
	s=k20260515; t=1790269819;
	bh=/q7umokvFoIGEF9yxtUewMRFMPSxLzlfs7fnYxZFqFg=;
	h=From:To:Cc:Subject:Date:In-Reply-To:References;
	b=LpyRMy782eVBxoqyFC4ip9WE01Rp5de+DT+hIduqwA1LdHSqP/qb3TuV0Ybqq/SNT
	 UkfHSG0BA98Xh+5zj/Gy7kS3EuXo/pgz+iqIOyd+NVYT+xl70TPRR9Z42gc8vcvoMp
	 v+/YhjL8holVGaZ3X3vTtjoQeNqGTZyAI2FMJUi+oBujRyzBlt7tpcMDRRzOlkL/Cx
	 UlJe3HCtYW/XXOdWo27odC/83wvHVUeLRGczGhB6t0B9/9ZHbPTMKGDO9/0ebMJczo
	 +tIWB+FZltEY7d5ueERvghTYoNwBhnrRKZZg/Lm0CITIoq46BDD7WfUxoWQVHowi72
	 24KHPvy+GriRw==
From: Chuck Lever <cel@kernel.org>
To: NeilBrown <neil@brown.name>,
	Jeff Layton <jlayton@kernel.org>,
	Olga Kornievskaia <okorniev@redhat.com>,
	Dai Ngo <dai.ngo@oracle.com>,
	Tom Talpey <tom@talpey.com>
Cc: <linux-nfs@vger.kernel.org>,
	Chuck Lever <chuck.lever@oracle.com>
Subject: [PATCH v2 05/33] NFSD: Replace the nfsd3_createres macro
Date: Thu, 24 Sep 2026 13:09:44 -0400
Message-ID: <20260924171012.3978-6-cel@kernel.org>
X-Mailer: git-send-email 2.55.0
In-Reply-To: <20260924171012.3978-1-cel@kernel.org>
References: <20260924171012.3978-1-cel@kernel.org>
Precedence: bulk
X-Mailing-List: linux-nfs@vger.kernel.org
List-Id: <linux-nfs.vger.kernel.org>
List-Subscribe: <mailto:linux-nfs+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:linux-nfs+unsubscribe@vger.kernel.org>
MIME-Version: 1.0
Content-Transfer-Encoding: 8bit

From: Chuck Lever <chuck.lever@oracle.com>

I'm about to use the name "nfsd3_createres" for a C struct,
so let's get rid of the macro to reduce confusion.

Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
---
 fs/nfsd/nfs3proc.c | 9 ++++-----
 1 file changed, 4 insertions(+), 5 deletions(-)

diff --git a/fs/nfsd/nfs3proc.c b/fs/nfsd/nfs3proc.c
index 223398ada3e3..200e084d749b 100644
--- a/fs/nfsd/nfs3proc.c
+++ b/fs/nfsd/nfs3proc.c
@@ -916,7 +916,6 @@ nfsd3_proc_commit(struct svc_rqst *rqstp)
 #define nfsd3_fhandleargs		nfsd_fhandle
 #define nfsd3_attrstatres		nfsd3_attrstat
 #define nfsd3_wccstatres		nfsd3_attrstat
-#define nfsd3_createres			nfsd3_diropres
 
 #define ST 1		/* status*/
 #define FH 17		/* filehandle with length */
@@ -1027,7 +1026,7 @@ static const struct svc_procedure nfsd_procedures3[22] = {
 		.pc_release = nfs3svc_release_fhandle2,
 		.pc_argsize = sizeof(struct nfsd3_createargs),
 		.pc_argzero = sizeof(struct nfsd3_createargs),
-		.pc_ressize = sizeof(struct nfsd3_createres),
+		.pc_ressize = sizeof(struct nfsd3_diropres),
 		.pc_cachetype = RC_REPLBUFF,
 		.pc_xdrressize = ST+(1+FH+pAT)+WC,
 		.pc_name = "CREATE",
@@ -1039,7 +1038,7 @@ static const struct svc_procedure nfsd_procedures3[22] = {
 		.pc_release = nfs3svc_release_fhandle2,
 		.pc_argsize = sizeof(struct nfsd3_mkdirargs),
 		.pc_argzero = sizeof(struct nfsd3_mkdirargs),
-		.pc_ressize = sizeof(struct nfsd3_createres),
+		.pc_ressize = sizeof(struct nfsd3_diropres),
 		.pc_cachetype = RC_REPLBUFF,
 		.pc_xdrressize = ST+(1+FH+pAT)+WC,
 		.pc_name = "MKDIR",
@@ -1051,7 +1050,7 @@ static const struct svc_procedure nfsd_procedures3[22] = {
 		.pc_release = nfs3svc_release_fhandle2,
 		.pc_argsize = sizeof(struct nfsd3_symlinkargs),
 		.pc_argzero = sizeof(struct nfsd3_symlinkargs),
-		.pc_ressize = sizeof(struct nfsd3_createres),
+		.pc_ressize = sizeof(struct nfsd3_diropres),
 		.pc_cachetype = RC_REPLBUFF,
 		.pc_xdrressize = ST+(1+FH+pAT)+WC,
 		.pc_name = "SYMLINK",
@@ -1063,7 +1062,7 @@ static const struct svc_procedure nfsd_procedures3[22] = {
 		.pc_release = nfs3svc_release_fhandle2,
 		.pc_argsize = sizeof(struct nfsd3_mknodargs),
 		.pc_argzero = sizeof(struct nfsd3_mknodargs),
-		.pc_ressize = sizeof(struct nfsd3_createres),
+		.pc_ressize = sizeof(struct nfsd3_diropres),
 		.pc_cachetype = RC_REPLBUFF,
 		.pc_xdrressize = ST+(1+FH+pAT)+WC,
 		.pc_name = "MKNOD",
-- 
2.55.0

