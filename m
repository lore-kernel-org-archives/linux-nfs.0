Received: from smtp.kernel.org (aws-us-west-2-korg-mail-alma10-1.taild15c8.ts.net [100.103.45.18])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id CAFAA372071
	for <linux-nfs@vger.kernel.org>; Wed, 16 Sep 2026 00:42:45 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=100.103.45.18
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1789519379; cv=none; b=kP+h5/ZZ7Mxk9P1/c7ynUbkiTFU0IOXmDvgzanMNXTJ+IsQnEQyf7EIm7JVCbI5XDP/pX4/L3ItGG+LrmNTM5gwawnKpE9hPgduc4MoPA4eNs/mEsviq/Vk/EzM+urtuql7k3703ZydHwLQD7FV7fS/RuTIH35ufSb3yeysRZks=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1789519379; c=relaxed/simple;
	bh=eg92+rdkT5NkVIjCZxxt5AnVenF5H91ZDIYkBpTDtDY=;
	h=From:To:Cc:Subject:Date:Message-ID:In-Reply-To:References:
	 MIME-Version; b=lmust9Z446i6M1Pe5XGIgQhjuKP8t4E63BZAmB11W01Q6uoUTkMRElycQXIt5UcC7VRIS+i8Prhg1y7N3ei4kzgS/fmt1z64SRVt+6GYgqrNYuJY1diIUwJJfmUou+nR70tS5E81IGd59ajfiJI+2n/fCbHtCVwOlDW5vYQwdkM=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.b=m7uMfk0w; arc=none smtp.client-ip=100.103.45.18
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.b="m7uMfk0w"
Received: by smtp.kernel.org (Postfix) with ESMTPSA id D6B4D1F00899;
	Wed, 16 Sep 2026 00:42:41 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=kernel.org;
	s=k20260515; t=1789519362;
	bh=ldU5/XjFZXtZ920vcFyRMM5y0Ud2HHuglx1rljGgCxw=;
	h=From:To:Cc:Subject:Date:In-Reply-To:References;
	b=m7uMfk0wvcPP9BLmhhx6J/vw4Kt4Dj8J5yrtcVDivff6dDkV11yF5EHz86TXZo75x
	 enT7wa5CaHh1Kp3yewpHwf/h3XfrMQN6+hEGqXWRheJ8OaaQRl4wsHnbEO5usjTgNm
	 zS1o4fwNB79yS7PujnfOuIrv458AnKYPqXwZc1y7z+yXVxP2E1wE+iddC4kGvQgVnr
	 7ZhS/eiPN/dBRR9iTDl+xECq+COuaiPpXLaMRkjaZ0FREyfsFgK67pj16W1YPF6/uy
	 MFFgG2AjyPVWB7RIWapwe0qHUOmBQ9q2kKR9Y4F2Zn8CCOGeVSKAPFyTUPsZrcxotC
	 OwomJJ2RRwcuA==
From: Chuck Lever <cel@kernel.org>
To: NeilBrown <neil@brown.name>,
	Jeff Layton <jlayton@kernel.org>,
	Olga Kornievskaia <okorniev@redhat.com>,
	Dai Ngo <dai.ngo@oracle.com>,
	Tom Talpey <tom@talpey.com>
Cc: <linux-nfs@vger.kernel.org>
Subject: [PATCH v1 2/2] NFSD: map fh_verify() status codes for NFS_ACLv3 replies
Date: Tue, 15 Sep 2026 20:42:40 -0400
Message-ID: <20260916004240.141975-2-cel@kernel.org>
X-Mailer: git-send-email 2.55.0
In-Reply-To: <20260916004240.141975-1-cel@kernel.org>
References: <20260916004240.141975-1-cel@kernel.org>
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

