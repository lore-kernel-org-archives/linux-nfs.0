Received: from smtp.kernel.org (aws-us-west-2-korg-mail-alma10-1.taild15c8.ts.net [100.103.45.18])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 7E5CB4F4D14
	for <linux-nfs@vger.kernel.org>; Tue, 13 Oct 2026 12:49:19 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=100.103.45.18
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1791895760; cv=none; b=kwcPYEeZ+nlcXR2nTLrxuprf0DoBmqrGAlYoylCrXASlwwykiOQd158hCqBSu2y0ySoSehtS/ajKC5hQaxKqWU1yqWimTqbbP3rHjwHMySxnerufp9OKXTujnpML/Rr1uS8yyvoPpgW5gWX2zvjeMhrjL9nzXLk0vxqQpCTHOT4=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1791895760; c=relaxed/simple;
	bh=BseKvuhqDBw02TuoZZkMqljiYQc2JbVeBNffRjrBtrY=;
	h=From:To:Cc:Subject:Date:Message-ID:In-Reply-To:References:
	 MIME-Version; b=FZeoNiC9q2L21UH5CNr++CXMe89OvRG4eqSIKbOFqCd3aqPU5dvYg5NKRnhfuPLo+h2iR88+gucZ6tVH/YSLf+x0hQzrqOO9aZPVo4qAsB1jQ01SD3lR9CjJv9sXdz3u/ve3RI5ftUBhasa8OkNskjQmbudn4e15LCDmsT0UH7o=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.b=XDh3u0QD; arc=none smtp.client-ip=100.103.45.18
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.b="XDh3u0QD"
Received: by smtp.kernel.org (Postfix) with ESMTPSA id B28AE1F00898;
	Tue, 13 Oct 2026 12:49:18 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=kernel.org;
	s=k20260515; t=1791895759;
	bh=/q7umokvFoIGEF9yxtUewMRFMPSxLzlfs7fnYxZFqFg=;
	h=From:To:Cc:Subject:Date:In-Reply-To:References;
	b=XDh3u0QDHG2jESKrnB8+cJYfArOB1AhuW4nfHzuluzVvwSxybYmHizHtog4r4yPIN
	 WNBKeWu0gUGd0wNl1YpMsTJL2uVQznlsoWPH6GH9N2tQKOVTPfuF8gS9BZORM7OYRZ
	 dOBnl2VvA+t6YJD3a5W8TC481JCN3aMeveTM2e53W7QNLl10Hg5/Bekxw/Dt2ueIgt
	 7meKHQDK62T3RH0FiMt6ZoMj6RGSIYPYYRuasVEdaHzg9OY34P8MPBXsAmDkKYcCSu
	 XMUX9ZdJv95FWB2gHMcU0eXb/XMwH3v58drMnagowHq14CTZWaDApPznciLjYmccgT
	 QKsSBDNOwmyMQ==
From: Chuck Lever <cel@kernel.org>
To: NeilBrown <neil@brown.name>,
	Jeff Layton <jlayton@kernel.org>,
	Olga Kornievskaia <okorniev@redhat.com>,
	Dai Ngo <dai.ngo@oracle.com>,
	Tom Talpey <tom@talpey.com>
Cc: <linux-nfs@vger.kernel.org>,
	Chuck Lever <chuck.lever@oracle.com>
Subject: [PATCH v3 05/34] NFSD: Replace the nfsd3_createres macro
Date: Tue, 13 Oct 2026 08:49:09 -0400
Message-ID: <20261013124913.316726-4-cel@kernel.org>
X-Mailer: git-send-email 2.55.0
In-Reply-To: <20261013124913.316726-1-cel@kernel.org>
References: <20261013124913.316726-1-cel@kernel.org>
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

