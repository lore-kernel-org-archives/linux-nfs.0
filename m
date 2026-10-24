Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.remote-ip=100.103.45.18
ARC-Seal: i=1; d=subspace.kernel.org; s=arc20261015; a=rsa-sha256; cv=none;
	t=1792838335;
	b=ogBtLBpMkX1iU1jrNC2ISCCU2F1LQpthnQ+vRO7ZfGo2Gq/u1miQrV8xqSGmxZ70ALsQ
	 LPQxGGrgk9jaEYHC10lLgOJ5lAfk6KQkzoPd52buUAZUMyGWfdq9AEMXIxNMRVksPSSlo
	 9pEzh80KyiBNDOxbnlUDMoii9iZ0cWbtrTfdb4r4WGKvYgPqE6y6Ny1JASW8em2E/QFxm
	 63IPfsTT3JwNCX7uqAKlkMVSE5YRv+2JfXjx27LtsjsboUvKO2J/hccICgJHvKyovWbsU
	 Y1CN6yW0xMMhY0O7Lb6ct04o0CWQJ7+2BJej/AvT9noYv9OTAlGn2UqOY9zLW0Ertmg==
ARC-Message-Signature: i=1; d=subspace.kernel.org; s=arc20261015;
	a=rsa-sha256; c=relaxed/relaxed; t=1792838335;
	h=Received:DKIM-Signature:From:Date:Subject:MIME-Version:Content-Type:
	 Content-Transfer-Encoding:Message-Id:References:In-Reply-To:To:Cc:
	 X-Mailer:X-Developer-Signature:X-Developer-Key;
	bh=obbBsg8M7cjyeL0jui4mdzYuykuYamVHb+dGvBctifs=;
	b=naC7oaEQSS2JD5gbt3QP06zxfDm4SWxoYJrsEkUWMsZ2vpzIubMFqu51Poe3/BQyjNge
	 pVMs0fgd4kTyLMHSKFsqr7m3qR99emvCYaG3JsFK43Di84/CN6P2DdIat8MvQYvJsgp9O
	 uhNLSTHxRK2JekUfwsAnBad5O1NMN+3KMIkCOrLAJwfX5Wuf2A9k2CClQeYTrVZitrW7x
	 uAVJbE5aW7kKwtx2se6u3GykCb0lalAv+fXpuFbjCxFjOHPVVyGd+8NgKpkmIRAwksfNj
	 450FZUrSTAE0fVxgz6mAxKcj8bLa7MpXG1NGJhNNd6ewJWy/yTzTnQNeZdnSsrEIpiw==
ARC-Authentication-Results: i=1; smtp.subspace.kernel.org; 
	dkim=pass header.d=kernel.org header.i=@kernel.org header.a=rsa-sha256 header.s=k20260515 header.b=G4ySOftq;
	arc=none smtp.remote-ip=100.103.45.18
Received: from smtp.kernel.org (quasi.space.kernel.org [100.103.45.18])
	(using TLSv1.3 with cipher TLS_AES_256_GCM_SHA384 (256/256 bits)
	 key-exchange X25519 server-signature ECDSA (prime256v1))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id C51D7606A32C;
	Sat, 24 Oct 2026 10:38:54 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key, unprotected) header.d=kernel.org header.i=@kernel.org header.a=rsa-sha256 header.s=k20260515 header.b=G4ySOftq
Received: by smtp.kernel.org (Postfix) with ESMTPSA id AD5821F031E0;
	Sat, 24 Oct 2026 10:38:52 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=kernel.org;
	s=k20260515; t=1792838334;
	bh=obbBsg8M7cjyeL0jui4mdzYuykuYamVHb+dGvBctifs=;
	h=From:Date:Subject:References:In-Reply-To:To:Cc;
	b=G4ySOftqpWJgO35rq/YhRfyTCLcOgtZaamjwQge+LsmLbT+ZPVgVa81RhTlJdy1BR
	 FF99AtwUoastb4SijORjAIBvcSt1bfDRqZ8ocOZTjr/jlN3Rms97W046ncXv7gF4S8
	 8JfzuSU7NP47mMP1/CS7BIKdFGHSN4vMNyVmYJyfM33lHWA6tUuEkRscsiWYRSYbXR
	 B0uDFuYsivsGMZM6ix2ExMtQcqWuz4/BHMeDrITNuhEhcW09nkldQhBwsertVlUcrE
	 +h7iQi2bWYdNcThT4vCLmbLRBxfTOP/XgKrnw1inFwpD3yBgCz6fto6qtMmTUS0WNB
	 4OqKZrl3z5e5g==
From: Christian Brauner <brauner@kernel.org>
Date: Sat, 24 Oct 2026 12:38:31 +0200
Subject: [PATCH 5/7] nfs: create the /proc/fs/nfsfs links with
 proc_self_symlink()
X-Mailing-List: linux-nfs@vger.kernel.org
List-Id: <linux-nfs.vger.kernel.org>
List-Post: <mailto:linux-nfs@vger.kernel.org>
List-Help: <mailto:linux-nfs+help@vger.kernel.org>
List-Subscribe: <mailto:linux-nfs+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:linux-nfs+unsubscribe@vger.kernel.org>
List-Owner: <mailto:linux-nfs+owner@vger.kernel.org>
Precedence: list
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Message-Id: <20261024-work-procfs-fixes-v1-5-46b03c3a8fac@kernel.org>
References: <20261024-work-procfs-fixes-v1-0-46b03c3a8fac@kernel.org>
In-Reply-To: <20261024-work-procfs-fixes-v1-0-46b03c3a8fac@kernel.org>
To: linux-fsdevel@vger.kernel.org
Cc: linux-afs@lists.infradead.org, linux-nfs@vger.kernel.org, 
 Alexander Viro <viro@zeniv.linux.org.uk>, Jan Kara <jack@suse.cz>, 
 Aleksa Sarai <cyphar@cyphar.com>, Chris Mason <mason@kernel.org>, 
 "Christian Brauner (Amutable)" <brauner@kernel.org>
X-Mailer: b4 0.17-dev-ce4c1
X-Developer-Signature: v=1; a=openpgp-sha256; l=1035; i=brauner@kernel.org;
 h=from:subject:message-id; bh=dTAGUjYXMrITdwfSsOq8T68J+z1OiJPsf8fIDAIiU0I=;
 b=owGbwMvMwCU28Zj0gdSKO4sYT6slMWTd6VrPq3Fwc0i3v6LD2v4FPOp/tFNr3HaaFE1Vkj5r7
 il4/97kjlIWBjEuBlkxRRaHdpNwueU8FZuNMjVg5rAygQxh4OIUgIm49TD8d5P1e/oyfu7li8E/
 r5Wvs9PdNkt3D2/Kkhxu7uSE6IurchgZ1my4/pObbSuf6nMWmaccpzq/vai6+2yym8PL7M5987j
 TGAE=
X-Developer-Key: i=brauner@kernel.org; a=openpgp;
 fpr=4880B8C9BD0E5106FC070F4F7B3C391EFEA93624

/proc/fs/nfsfs/servers and /proc/fs/nfsfs/volumes resolve through
/proc/net into /proc/self/net. Create them with proc_self_symlink() so
nothing can be mounted on the links themselves.

Signed-off-by: Christian Brauner (Amutable) <brauner@kernel.org>
---
 fs/nfs/client.c | 4 ++--
 1 file changed, 2 insertions(+), 2 deletions(-)

diff --git a/fs/nfs/client.c b/fs/nfs/client.c
index 60386330aeec..97e363ac7a3e 100644
--- a/fs/nfs/client.c
+++ b/fs/nfs/client.c
@@ -1528,11 +1528,11 @@ int __init nfs_fs_proc_init(void)
 		goto error_0;
 
 	/* a file of servers with which we're dealing */
-	if (!proc_symlink("fs/nfsfs/servers", NULL, "../../net/nfsfs/servers"))
+	if (!proc_self_symlink("fs/nfsfs/servers", NULL, "../../net/nfsfs/servers"))
 		goto error_1;
 
 	/* a file of volumes that we have mounted */
-	if (!proc_symlink("fs/nfsfs/volumes", NULL, "../../net/nfsfs/volumes"))
+	if (!proc_self_symlink("fs/nfsfs/volumes", NULL, "../../net/nfsfs/volumes"))
 		goto error_1;
 
 	return 0;

-- 
2.53.0

