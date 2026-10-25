Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.remote-ip=100.103.45.18
ARC-Seal: i=1; d=subspace.kernel.org; s=arc20261015; a=rsa-sha256; cv=none;
	t=1793050586;
	b=WkTis+Utp+0bxC5se6jHF+e5y6sHHP/J6F9Fw8p1Sg59ufUkmVUvIHAYtdvzmfPTZ4ce
	 CSsH2RAtcj2M1ZLsgkfYrJdevnE4EOCbH9+4kmEM1/jaHL8uBW2f9YwDAxvu1poW08ewn
	 x+MxHBxcQR0owH/NA6PkiIkGoVS1qrczTuj2QeT559w9m9b+dSfCYtVFDkDM4uo7poBvI
	 8HgudhYAME1KbRNUfYH9SV1tnf2TOWavOSpazrpeFnd0qaRQWka+eO4xBYGqtM61FkMYZ
	 XeagynmHkGc/m4nEu0i3Q/1LExeQkFbc5WUnyWJpaOZTq2Wo+BqBtYzq38w/81pIBog==
ARC-Message-Signature: i=1; d=subspace.kernel.org; s=arc20261015;
	a=rsa-sha256; c=relaxed/relaxed; t=1793050586;
	h=Received:DKIM-Signature:From:To:Cc:Subject:Date:Message-ID:X-Mailer:
	 In-Reply-To:References:MIME-Version:Content-Transfer-Encoding;
	bh=x3kQgfw5HsBg/uSB5FJ4JVxrkNcg/Dte9m7ipnT3ryY=;
	b=WfyIy9THz9m7vLtW5U7s50mR0nlokFKS5X3PX5/cHsIetNZEGgGMjcY9d4GSZqxYLy1b
	 nK77lpaT0K8ojcQgqZATNAGqiUMMfkvV9Q65eb2cOQWJbOFAgqbl1+T1zhf350q1MFDg9
	 eJztAdrDItCwsu2ZMGdtem+xaXEqiqORdMyPSh/4F4GLVpBe2/Uw106F3mz7j+/2LggGU
	 ncErKM4yks6Uh/ZzgQ2D38mfmd1hEfvi6YyZv3rWnbSqCAGAonk78S04kSlVMAw3J3xuW
	 a4NpDV9nJOTq5h2BWlPQsrkGWSvHqflAXcFRui3dOWMRXDFOA59jk02rHdhNgqdrpfw==
ARC-Authentication-Results: i=1; smtp.subspace.kernel.org; 
	dkim=pass header.d=kernel.org header.i=@kernel.org header.a=rsa-sha256 header.s=k20260515 header.b=h5ESrtl+;
	arc=none smtp.remote-ip=100.103.45.18
Received: from smtp.kernel.org (quasi.space.kernel.org [100.103.45.18])
	(using TLSv1.3 with cipher TLS_AES_256_GCM_SHA384 (256/256 bits)
	 key-exchange X25519 server-signature ECDSA (prime256v1))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 85371606A330
	for <linux-nfs@vger.kernel.org>; Mon, 26 Oct 2026 21:36:26 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key, unprotected) header.d=kernel.org header.i=@kernel.org header.a=rsa-sha256 header.s=k20260515 header.b=h5ESrtl+
Received: by smtp.kernel.org (Postfix) with ESMTPSA id 6AF561F031EC;
	Mon, 26 Oct 2026 21:36:25 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=kernel.org;
	s=k20260515; t=1793050586;
	bh=x3kQgfw5HsBg/uSB5FJ4JVxrkNcg/Dte9m7ipnT3ryY=;
	h=From:To:Cc:Subject:Date:In-Reply-To:References;
	b=h5ESrtl+LUuWUO3N9WRRpJS0wm+dF8rmaqQizxXuw97FTjWRHjD3fY90CgLEYa+RH
	 IXOua5jcZ0pH68ayjSKf8/MHHwMGR9JXk7w8jGHYaVe61v8j5yGIOrVVK8W0jKP2iK
	 VVikWiPUsl0BzMiSKlS0RWueoMeKW86Rpk3RRWIgIKX9BFL/zi8u74sCCdAzfqiq7p
	 doQxrWIC/YLU9tdkWMXMUb4pGXYYfKsbxbgOxXb88Frm51lgo3xkHLx9U/ByQbYoG1
	 mhdQHytPWa5hL2TZdFSiWyxAaQJCkW/ip7YTewzlB238fOmvfvHEgR6KUhphWt/dW/
	 LfYgRo7qEdYgQ==
From: Chuck Lever <cel@kernel.org>
To: NeilBrown <neil@brown.name>,
	Jeff Layton <jlayton@kernel.org>,
	Olga Kornievskaia <okorniev@redhat.com>,
	Dai Ngo <dai.ngo@oracle.com>,
	Tom Talpey <tom@talpey.com>
Cc: <linux-nfs@vger.kernel.org>
Subject: [PATCH v1 09/13] NFSD: Map every NFS_ACLv3 reply status into aclstat3
Date: Sun, 25 Oct 2026 11:16:18 -0400
Message-ID: <20261025151622.141025-10-cel@kernel.org>
X-Mailer: git-send-email 2.56.0
In-Reply-To: <20261025151622.141025-1-cel@kernel.org>
References: <20261025151622.141025-1-cel@kernel.org>
X-Mailing-List: linux-nfs@vger.kernel.org
List-Id: <linux-nfs.vger.kernel.org>
List-Post: <mailto:linux-nfs@vger.kernel.org>
List-Help: <mailto:linux-nfs+help@vger.kernel.org>
List-Subscribe: <mailto:linux-nfs+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:linux-nfs+unsubscribe@vger.kernel.org>
List-Owner: <mailto:linux-nfs+owner@vger.kernel.org>
Precedence: list
MIME-Version: 1.0
Content-Transfer-Encoding: 8bit

nfsd3_map_status() translates only the two fh_verify() statuses that
have no NFSv3 equivalent, so every other status reaches the encoder
unchanged. fh_verify() and fh_getattr() pass errno values through
nfserrno(), whose table produces NFSv3 status values that aclstat3
does not define. draft-ietf-nfsv4-nfs-acl Section 6.2 lists the
status values an NFS_ACLv3 server returns, and those are not among
them.

Pass through the statuses that are members of aclstat3 and map the
rest to ACL3ERR_SERVERFAULT, the status nfsd3_map_errno() already
uses for an unlisted errno. The existing NOFILEHANDLE and WRONGSEC
translations are unchanged.

Signed-off-by: Chuck Lever <cel@kernel.org>
---
 fs/nfsd/nfs3acl.c | 24 +++++++++++++++++++-----
 1 file changed, 19 insertions(+), 5 deletions(-)

diff --git a/fs/nfsd/nfs3acl.c b/fs/nfsd/nfs3acl.c
index 19f5a6127673..66bb650e99f4 100644
--- a/fs/nfsd/nfs3acl.c
+++ b/fs/nfsd/nfs3acl.c
@@ -124,14 +124,28 @@ static __be32 nfsd3_map_errno(int errno)
 static __be32 nfsd3_map_status(__be32 status)
 {
 	switch (status) {
+	case acl3_ok:
+	case acl3err_perm:
+	case acl3err_noent:
+	case acl3err_io:
+	case acl3err_acces:
+	case acl3err_inval:
+	case acl3err_nospc:
+	case acl3err_rofs:
+	case acl3err_dquot:
+	case acl3err_stale:
+	case acl3err_badhandle:
+	case acl3err_notsupp:
+	case acl3err_serverfault:
+	case acl3err_jukebox:
+		return status;
 	case cpu_to_be32(NFS4ERR_NOFILEHANDLE):
-		status = acl3err_badhandle;
-		break;
+		return acl3err_badhandle;
 	case cpu_to_be32(NFS4ERR_WRONGSEC):
-		status = acl3err_acces;
-		break;
+		return acl3err_acces;
+	default:
+		return acl3err_serverfault;
 	}
-	return status;
 }
 
 static bool
-- 
2.56.0

