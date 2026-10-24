Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.remote-ip=100.103.45.18
ARC-Seal: i=1; d=subspace.kernel.org; s=arc20261015; a=rsa-sha256; cv=none;
	t=1792838328;
	b=uv5mT24Jp/VrWg1vg8cT8ZGj4/6nw/IGpNfea3DQdRF4uhzQkSA7q/XfJcVHU7WWtW0r
	 K02ElRSfnF5AwFupHpaCUtStTpWlfO9dcc2xZTER8MYxzObUG3C5mZyM19oJVX+0IxkSR
	 h8uf+U06MXlCMTjzCoIAhOH57D5m23rD2+4vOX33XLkTwnmCnTNnwtTAcvNLdo2S0V24U
	 sP7AYaZJPSBXdpniEBBUNSJueqKNexWNVjYvKHauFlOBB6sIKvbe3Os7ZJ5wZQvJXP/MS
	 NTLiHLK8jkRsrOpI9Uz/jFvs+jxJ/qTHZX5Kkv7flsJVl+2R177crrIlqFjEZuQIM6w==
ARC-Message-Signature: i=1; d=subspace.kernel.org; s=arc20261015;
	a=rsa-sha256; c=relaxed/relaxed; t=1792838328;
	h=Received:DKIM-Signature:From:Date:Subject:MIME-Version:Content-Type:
	 Content-Transfer-Encoding:Message-Id:References:In-Reply-To:To:Cc:
	 X-Mailer:X-Developer-Signature:X-Developer-Key;
	bh=sXodnFMdq0P0MxpAQHlPP6y5dA9ltED1V+HSlKENf2Q=;
	b=OHSbFDwV5r+1DLhJXas6+XXQPXc6Kq1858lz/I69gqyMB1afm6ahLu7LjGFJQIMQQc1W
	 o5Y9Djv0EINXoI83OoidAnNu67oYWwfhoSDZ6f6O245xUWMQ4AELUYOd3uv8kK2PYtfgP
	 qUAVZiJtxxiqFIjpiRL4UokVenlAIZ7Rvxs8Ipu+pzEQKnISPvILEkTiJq9r5eqvXJpLx
	 JTVh83CmSBDEFxnzI3qR0WaKIBEga+e6HXmJGcxDhSkODvs36iYv9PpaGBsbebsStvP/N
	 V1Il73TfD13z9s3DJqO58awcWIy0PJxmF4ZM/GgCrGKe+M+aTI45J0q7slJAFBynOPA==
ARC-Authentication-Results: i=1; smtp.subspace.kernel.org; 
	dkim=pass header.d=kernel.org header.i=@kernel.org header.a=rsa-sha256 header.s=k20260515 header.b=VgyS6mqQ;
	arc=none smtp.remote-ip=100.103.45.18
Received: from smtp.kernel.org (quasi.space.kernel.org [100.103.45.18])
	(using TLSv1.3 with cipher TLS_AES_256_GCM_SHA384 (256/256 bits)
	 key-exchange X25519 server-signature ECDSA (prime256v1))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 635E6606A31E;
	Sat, 24 Oct 2026 10:38:48 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key, unprotected) header.d=kernel.org header.i=@kernel.org header.a=rsa-sha256 header.s=k20260515 header.b=VgyS6mqQ
Received: by smtp.kernel.org (Postfix) with ESMTPSA id 4DC9F1F01825;
	Sat, 24 Oct 2026 10:38:46 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=kernel.org;
	s=k20260515; t=1792838328;
	bh=sXodnFMdq0P0MxpAQHlPP6y5dA9ltED1V+HSlKENf2Q=;
	h=From:Date:Subject:References:In-Reply-To:To:Cc;
	b=VgyS6mqQpZY5LufmLVJv+UgMUebZBuNfDazazEI17Y3Pk5WnhpI1Iyvol5q5Bc/dH
	 k7FVfAUvyokxAJ4/ii5DtUVnVHvV+Hmg7ECwPD8PVlf+izF5sLo6LnoMkbK4twluiE
	 DOlKK5EF6CZgtuQ2ml2FUiaGHf3x/b35lt62xAZjY3uCV9eiJOhCHQVcW1hcsHLKRD
	 YOkcNC47FzuMrHGNB3YgjPDV6Fv24LCBzPNLMegArq6JuBrnbekGHLUBgDZNzHSlfS
	 S0KEw/bvwpkkI6WWPJ8FoHBMWwwHK8AzRDRmMT0DxImmMweIJ1PaT/GMgI8qEFuw0+
	 AwEuwuRUeTpYg==
From: Christian Brauner <brauner@kernel.org>
Date: Sat, 24 Oct 2026 12:38:28 +0200
Subject: [PATCH 2/7] proc: don't let /proc/self and /proc/thread-self be
 mountpoints
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
Message-Id: <20261024-work-procfs-fixes-v1-2-46b03c3a8fac@kernel.org>
References: <20261024-work-procfs-fixes-v1-0-46b03c3a8fac@kernel.org>
In-Reply-To: <20261024-work-procfs-fixes-v1-0-46b03c3a8fac@kernel.org>
To: linux-fsdevel@vger.kernel.org
Cc: linux-afs@lists.infradead.org, linux-nfs@vger.kernel.org, 
 Alexander Viro <viro@zeniv.linux.org.uk>, Jan Kara <jack@suse.cz>, 
 Aleksa Sarai <cyphar@cyphar.com>, Chris Mason <mason@kernel.org>, 
 "Christian Brauner (Amutable)" <brauner@kernel.org>
X-Mailer: b4 0.17-dev-ce4c1
X-Developer-Signature: v=1; a=openpgp-sha256; l=1542; i=brauner@kernel.org;
 h=from:subject:message-id; bh=GymrroAnGNh475bQ1tWnOZq0e6I6+VtHGEMxiEdv290=;
 b=owGbwMvMwCU28Zj0gdSKO4sYT6slMWTd6VoX5LvUgKtmucuWbeoBcu+ezFxx66ilm+Ovc53+e
 8N+z+xa3VHKwiDGxSArpsji0G4SLrecp2KzUaYGzBxWJpAhDFycAjCRFwsY/gqsvLxxhfS3DK36
 p68fOi5lP7PQ3FerP9jyy9eDfnE6fx0Z/vu9v8vwzbmm0GAOm+dsn9NJvS4RvS/TvXXXXt7zQt2
 1hAEA
X-Developer-Key: i=brauner@kernel.org; a=openpgp;
 fpr=4880B8C9BD0E5106FC070F4F7B3C391EFEA93624

/proc/self and /proc/thread-self resolve to a different directory for
every process that walks through them. A mount on one of the links
itself is crossed by every lookup of /proc/self/... in that mount
namespace, so it redirects all processes at once, not just the one that
created the mount. There's no good reason to ever do that.

Mark both links with dont_mount() before they become visible.

Signed-off-by: Christian Brauner (Amutable) <brauner@kernel.org>
---
 fs/proc/self.c        | 2 ++
 fs/proc/thread_self.c | 2 ++
 2 files changed, 4 insertions(+)

diff --git a/fs/proc/self.c b/fs/proc/self.c
index 56adf1c68f7a..63120ab7704c 100644
--- a/fs/proc/self.c
+++ b/fs/proc/self.c
@@ -48,6 +48,8 @@ int proc_setup_self(struct super_block *s)
 			inode->i_uid = GLOBAL_ROOT_UID;
 			inode->i_gid = GLOBAL_ROOT_GID;
 			inode->i_op = &proc_self_inode_operations;
+			/* a mount here would redirect every process */
+			dont_mount(self);
 			d_make_persistent(self, inode);
 			ret = 0;
 		}
diff --git a/fs/proc/thread_self.c b/fs/proc/thread_self.c
index 61ac62c3fd9f..a4f803daf589 100644
--- a/fs/proc/thread_self.c
+++ b/fs/proc/thread_self.c
@@ -48,6 +48,8 @@ int proc_setup_thread_self(struct super_block *s)
 			inode->i_uid = GLOBAL_ROOT_UID;
 			inode->i_gid = GLOBAL_ROOT_GID;
 			inode->i_op = &proc_thread_self_inode_operations;
+			/* a mount here would redirect every thread */
+			dont_mount(thread_self);
 			d_make_persistent(thread_self, inode);
 			ret = 0;
 		}

-- 
2.53.0

