Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.remote-ip=100.103.45.18
ARC-Seal: i=1; d=subspace.kernel.org; s=arc20261015; a=rsa-sha256; cv=none;
	t=1792838332;
	b=UyXqMKFJBtn+1cwuPxm40ON0skKCCI5QciubcPYid/LgRHtq49CmfJFynSgcND60cS/1
	 iBlP57gDq16Cj7tjWyv2H7JnQ+hR4ruEObyK58SoYV3Kb0YDbAJdTr6hhdThUezDLiELM
	 CJCF3RqaEA2ZWnFZwDTag5Vdf6mI04iCyUOJur39SpcUSUZCt6e8twAux//EjwVfYfeCY
	 96GvEQ8+z+UGZkQV4x0BRFOhCmAjjzmIWSXIWUVec1+o1E6GopufzyjzpUUb8I8cpO/AY
	 9hnsipRxHwZwywetreQm9zptZVmM3dxnO1GgvWj6WP0Y8zDsS/9K2pveGLXN9D2eXgw==
ARC-Message-Signature: i=1; d=subspace.kernel.org; s=arc20261015;
	a=rsa-sha256; c=relaxed/relaxed; t=1792838332;
	h=Received:DKIM-Signature:From:Date:Subject:MIME-Version:Content-Type:
	 Content-Transfer-Encoding:Message-Id:References:In-Reply-To:To:Cc:
	 X-Mailer:X-Developer-Signature:X-Developer-Key;
	bh=H8XkWCqJdc7RSUT1dOBMBhcNYheB5ow0vU6a9eX9bgk=;
	b=BF+qMF6qDEtBTdlHXS1KHgciDhwdfZMISxEL960JUzlXQyjv3oYXYA24ZHHHp9BMjH8W
	 XNwiJtzHsbPsqZF9TGFfXO/VGoFSLZsGUV3wphthphaEt6DpRU3Uf5WTosYkFhow/nLKL
	 tJMxMD8NKLMPHr64o6Cs+QpG7aek8kE0/qt6OTZKrgtntGNuOpOtGBCEJhAuTmLnjBx6G
	 2fakc1nI0h4E+jxvauCtk8j1Yy/5Kwxd0qne/buF7iKUlJjEJciU5DKaAAncoOXDz6EFv
	 Qy32Xh66fUEoYncQIT82R3oqtiqUqItkRKGdB+xuNuh4WJ5+Moh/7ot+x4fOInz4kOA==
ARC-Authentication-Results: i=1; smtp.subspace.kernel.org; 
	dkim=pass header.d=kernel.org header.i=@kernel.org header.a=rsa-sha256 header.s=k20260515 header.b="U3ehif/j";
	arc=none smtp.remote-ip=100.103.45.18
Received: from smtp.kernel.org (quasi.space.kernel.org [100.103.45.18])
	(using TLSv1.3 with cipher TLS_AES_256_GCM_SHA384 (256/256 bits)
	 key-exchange X25519 server-signature ECDSA (prime256v1))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id A2939606A328;
	Sat, 24 Oct 2026 10:38:52 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key, unprotected) header.d=kernel.org header.i=@kernel.org header.a=rsa-sha256 header.s=k20260515 header.b=U3ehif/j
Received: by smtp.kernel.org (Postfix) with ESMTPSA id 8F8871F031E1;
	Sat, 24 Oct 2026 10:38:50 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=kernel.org;
	s=k20260515; t=1792838332;
	bh=H8XkWCqJdc7RSUT1dOBMBhcNYheB5ow0vU6a9eX9bgk=;
	h=From:Date:Subject:References:In-Reply-To:To:Cc;
	b=U3ehif/jNmbcBiVF8TvsJ1Eg5pXM+VYwckpdy8IC1m7K3rTuJQQBjX5FR5peSRovT
	 6Bm3PfGw+dKEk2yJlNjQoo+EPOW+rm1Bl+pKdjM+6NPKb2p4WYGU13w4CYwFl9ZSy5
	 nKRPh4FalumDZAa6AmwEUu4S662jVL5a09qTAl7Uah0vnNCNKr2EHWzGAd6m6zIukM
	 S4b4Vwv9f0Q25mwQVJJMkpAOXnjYi+0iNVhHKdCP5/J//SEiV9WRfp6wlbBdfwYsAL
	 SrCn9pv1tWbFsaMQWEPh92+97jwuMoJpxmipfsWaMmCE4z9pWP835Gp8gJtvmCnh+q
	 si8vzrhvBk7SQ==
From: Christian Brauner <brauner@kernel.org>
Date: Sat, 24 Oct 2026 12:38:30 +0200
Subject: [PATCH 4/7] afs: create /proc/fs/afs with proc_self_symlink()
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
Message-Id: <20261024-work-procfs-fixes-v1-4-46b03c3a8fac@kernel.org>
References: <20261024-work-procfs-fixes-v1-0-46b03c3a8fac@kernel.org>
In-Reply-To: <20261024-work-procfs-fixes-v1-0-46b03c3a8fac@kernel.org>
To: linux-fsdevel@vger.kernel.org
Cc: linux-afs@lists.infradead.org, linux-nfs@vger.kernel.org, 
 Alexander Viro <viro@zeniv.linux.org.uk>, Jan Kara <jack@suse.cz>, 
 Aleksa Sarai <cyphar@cyphar.com>, Chris Mason <mason@kernel.org>, 
 "Christian Brauner (Amutable)" <brauner@kernel.org>
X-Mailer: b4 0.17-dev-ce4c1
X-Developer-Signature: v=1; a=openpgp-sha256; l=719; i=brauner@kernel.org;
 h=from:subject:message-id; bh=Cj+Piyz/PQ8jMuA9wSZCnecU6jcGJqmha+PwIZOKMu0=;
 b=kA0DAAoWkcYbwGV43KIByyZiAGrciq/ILvUFtq8LQ809fOStW8AEDKc0EyBeKHQbHaEzogqmg
 Ih1BAAWCgAdFiEEQIc0Vx6nDHizMmkokcYbwGV43KIFAmrciq8ACgkQkcYbwGV43KKjuAEAkkQp
 QECm47dK934cWanFCCXP0071LZbNZC+ZvL5lMPcBAJgeiDDw2CthfcYulv0zy6FxQo5Am0Zs9TM
 WGJrdG24B
X-Developer-Key: i=brauner@kernel.org; a=openpgp;
 fpr=4880B8C9BD0E5106FC070F4F7B3C391EFEA93624

/proc/fs/afs points into /proc/self/net. Create it with
proc_self_symlink() so nothing can be mounted on the link itself.

Signed-off-by: Christian Brauner (Amutable) <brauner@kernel.org>
---
 fs/afs/main.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/fs/afs/main.c b/fs/afs/main.c
index 7a883c59976f..b12725f1d3d5 100644
--- a/fs/afs/main.c
+++ b/fs/afs/main.c
@@ -188,7 +188,7 @@ static int __init afs_init(void)
 	if (ret < 0)
 		goto error_fs;
 
-	afs_proc_symlink = proc_symlink("fs/afs", NULL, "../self/net/afs");
+	afs_proc_symlink = proc_self_symlink("fs/afs", NULL, "../self/net/afs");
 	if (!afs_proc_symlink) {
 		ret = -ENOMEM;
 		goto error_proc;

-- 
2.53.0

