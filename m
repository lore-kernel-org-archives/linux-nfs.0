Received: from smtp.kernel.org (aws-us-west-2-korg-mail-alma10-1.taild15c8.ts.net [100.103.45.18])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 3EF0B3876C9
	for <linux-nfs@vger.kernel.org>; Wed, 16 Sep 2026 16:29:03 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=100.103.45.18
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1789576145; cv=none; b=hYUoFH38P61t27FpDDvziIE1NRbbe+gT0L9cW/Cxht37D3DnJSHh3+l8xiylMw5wmvNDROfxNPSx/k8sEILAvK5iEQlbht8+EaaoCrUEOFc5by1hfHTVs68YkM4MzpBQWQuoCwduV3ZpsbM5Ugm0bGLDsVIJWmKDodnlEeJK08I=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1789576145; c=relaxed/simple;
	bh=eg92+rdkT5NkVIjCZxxt5AnVenF5H91ZDIYkBpTDtDY=;
	h=From:To:Cc:Subject:Date:Message-ID:In-Reply-To:References:
	 MIME-Version; b=Zzda2K2PnVnG2PVvyYnbZHzCetWrhj6txYyFMMTSL98n005R2cMHJm2RcFEwDmIe8a10Mc4c/1oIMEJMTCPnEU3tMdglRJO3AicNrM4eJQ3Cfd6+HmShh8EO3h1XkHgVrHzJyy0yQMa6JAHeiLusMenpyjsAxiardfwW8R2eVcc=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.b=AWSa6tWx; arc=none smtp.client-ip=100.103.45.18
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.b="AWSa6tWx"
Received: by smtp.kernel.org (Postfix) with ESMTPSA id 39A9C1F00899;
	Wed, 16 Sep 2026 16:29:03 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=kernel.org;
	s=k20260515; t=1789576143;
	bh=ldU5/XjFZXtZ920vcFyRMM5y0Ud2HHuglx1rljGgCxw=;
	h=From:To:Cc:Subject:Date:In-Reply-To:References;
	b=AWSa6tWxJGdR67ed5Irdkpg5lHq5TJW3mBJ5FLBYB8Lz1PbMnqkgkZb/VEs37cfJl
	 u6yo3c5JUOopu4d0Lb96AHzPim9NC6tPhnFWM8Gwlhh8lRL0ayxm09xmQGKO8kFGYg
	 sKZ2EbBxEQ3eUl3GMnmfmNVyWLNFeQzBFqREavarXcTPtU4CnUFibeYS6n7RGpdeh3
	 FyTQnDxTf2ff0DciKAwA81ukfemJWl8ByGhX3VK/CVjqzkakox7RJGEgQN7SbKAuct
	 xM3gkYLa5pmpilaUNORDLNMGefGLm3kWOuAj7KKJCMEplDf1keCMfbOP4ra/eOUh1H
	 T+HVvfWJ7K0iQ==
From: Chuck Lever <cel@kernel.org>
To: NeilBrown <neil@brown.name>,
	Jeff Layton <jlayton@kernel.org>,
	Olga Kornievskaia <okorniev@redhat.com>,
	Dai Ngo <dai.ngo@oracle.com>,
	Tom Talpey <tom@talpey.com>
Cc: <linux-nfs@vger.kernel.org>
Subject: [PATCH v1 2/2] NFSD: map fh_verify() status codes for NFS_ACLv3 replies
Date: Wed, 16 Sep 2026 12:28:33 -0400
Message-ID: <20260916162859.2051-5-cel@kernel.org>
X-Mailer: git-send-email 2.55.0
In-Reply-To: <20260916162859.2051-1-cel@kernel.org>
References: <20260916162859.2051-1-cel@kernel.org>
Precedence: bulk
X-Mailing-List: linux-nfs@vger.kernel.org
List-Id: <linux-nfs.vger.kernel.org>
List-Subscribe: <mailto:linux-nfs+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:linux-nfs+unsubscribe@vger.kernel.org>
MIME-Version: 1.0
Content-Transfer-Encoding: 8bit

The NFS_ACLv3 protocol shares its status code space with NFSv3,
which has NFS3ERR_BADHANDLE but no NFSERR_NOFILEHANDLE. An
NFS_ACLv3 GETACL or SETACL request that carries an empty file
handle gets a reply with status 10020, a value the client cannot
interpret.

Commit 1459ad57673b ("nfsd: Move error code mapping to per-version
proc code.") made fh_verify() return nfserr_nofilehandle for an
empty handle regardless of protocol version. The NFSv3 procedures
gained nfsd3_map_status() in exchange, but the NFS_ACLv3 procedures
did not, so the unmapped status reaches the encoder.

Add the same mapping to the NFS_ACLv3 procedures.

Fixes: 1459ad57673b ("nfsd: Move error code mapping to per-version proc code.")
Signed-off-by: Chuck Lever <cel@kernel.org>
---
 fs/nfsd/nfs3acl.c | 15 +++++++++++++++
 1 file changed, 15 insertions(+)

diff --git a/fs/nfsd/nfs3acl.c b/fs/nfsd/nfs3acl.c
index 7183995182ab..5219ec634587 100644
--- a/fs/nfsd/nfs3acl.c
+++ b/fs/nfsd/nfs3acl.c
@@ -14,6 +14,19 @@
 #include "xdr3.h"
 #include "vfs.h"
 
+static __be32 nfsd3_map_status(__be32 status)
+{
+	switch (status) {
+	case nfserr_nofilehandle:
+		status = nfserr_badhandle;
+		break;
+	case nfserr_wrongsec:
+		status = nfserr_acces;
+		break;
+	}
+	return status;
+}
+
 /*
  * NULL call.
  */
@@ -72,6 +85,7 @@ static __be32 nfsd3_proc_getacl(struct svc_rqst *rqstp)
 
 	/* resp->acl_{access,default} are released in nfs3svc_release_getacl. */
 out:
+	resp->status = nfsd3_map_status(resp->status);
 	return rpc_success;
 
 fail:
@@ -125,6 +139,7 @@ static __be32 nfsd3_proc_setacl(struct svc_rqst *rqstp)
 	resp->status = nfserrno(error);
 out:
 	/* argp->acl_{access,default} are released in nfs3svc_release_setacl. */
+	resp->status = nfsd3_map_status(resp->status);
 	return rpc_success;
 }
 
-- 
2.55.0

