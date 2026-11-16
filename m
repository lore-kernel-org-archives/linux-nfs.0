Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.remote-ip=100.103.45.18
ARC-Seal: i=1; d=subspace.kernel.org; s=arc20261015; a=rsa-sha256; cv=none;
	t=1794827119;
	b=RdxYIoZKjNOB3iNt/FDlHJLvfaINHQw+E1Q8AsAwQtD823mGwyed3SjrZle2+CFql8Io
	 rssVF+wsXUN9Dk0yGLqabM9ZF1pXp3U640yQNocGppbXbYZeVeCVxxEF9QlH1wZS+qMUU
	 ARz6dASTGEMN55ALrgRXGayESlxRSRdthq83anXWhLB8hRzwdwa3+e4/JzCs5hs5hgAjA
	 AaNn7WJxHzN+f44H2SzmkNJUVAqioZEJcFb3fn+sgt4hf3jpySwxEQIyCTekzWEimKpg0
	 J4ySbAxKzAfEPDBK9AzHj7JL/HJ5QSdHCiGioZiKGxI/gUTqySs8Hld3040MASXnlRw==
ARC-Message-Signature: i=1; d=subspace.kernel.org; s=arc20261015;
	a=rsa-sha256; c=relaxed/relaxed; t=1794827119;
	h=Received:DKIM-Signature:From:Date:Subject:MIME-Version:Content-Type:
	 Content-Transfer-Encoding:Message-Id:References:In-Reply-To:To:Cc:
	 X-Mailer:X-Developer-Signature:X-Developer-Key;
	bh=iQwkLUdwk9b1HJi0bdxPWAy3VpDyPS0j6oQB4RnL5Xk=;
	b=YcvFpzbk/Gp3DFiHTjYrJV8JdfODcG1jGa+9cR9Sk8eya4LsjeV9Dk/xMsKNQKrN++aU
	 FeSdYWhZpZzeI4Qe72EhDzIfxguHEoxRMBDd2KGmS6XOR7pb1M8E0yMfxqCf1INwpbMu3
	 KQY74pt7B9TWvAnNWloKzdF6ylcxwWuj1fxE6nTM0sUSoshhYwzJuGO2GiycZy/RtXSp1
	 AK7d7eCVfBmEj91P+QNNAs9nxtOaiZEw3ojWxNZBTrNOMVKCo8aRaBouyFTwyEPVBxNe9
	 PkEmkFSts7m41zAbcjWRFA1rr2ifAg4Dwh6EpmboJWwQh21tGGQ0y9uK3Fgy28KziRg==
ARC-Authentication-Results: i=1; smtp.subspace.kernel.org; 
	dkim=pass header.d=kernel.org header.i=@kernel.org header.a=rsa-sha256 header.s=k20260515 header.b=TCGsMSU0;
	arc=none smtp.remote-ip=100.103.45.18
Received: from smtp.kernel.org (quasi.space.kernel.org [100.103.45.18])
	(using TLSv1.3 with cipher TLS_AES_256_GCM_SHA384 (256/256 bits)
	 key-exchange X25519 server-signature ECDSA (prime256v1))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 5371860A2629;
	Mon, 16 Nov 2026 11:05:19 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.a=rsa-sha256 header.s=k20260515 header.b=TCGsMSU0
Received: by smtp.kernel.org (Postfix) with ESMTPSA id 77D171F000C8;
	Mon, 16 Nov 2026 11:05:15 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=kernel.org;
	s=k20260515; t=1794827119;
	bh=iQwkLUdwk9b1HJi0bdxPWAy3VpDyPS0j6oQB4RnL5Xk=;
	h=From:Date:Subject:References:In-Reply-To:To:Cc;
	b=TCGsMSU0VLtPHC6d/+ESb62tB6A5OnT5thXMuSszj0X5SUrXTBlGJp1Uj+AYZe+b7
	 M6HysKQdgtmSCsAwgJMeEx7nwplOmGQG0k7sii/MZZCEhur/88d3NJPaUnDq/j9QkG
	 X+za0+knnV7BnsIiOWGJCFcT/hjb+uNPDTAzp/KopV2X6mnbRtgkBhso+/o9Wz8Emg
	 GLN0MTTmw1FY14Dtm1V9VE8Z320kaoSZDLv0wZWZR8TXN7H7cJiMzgITAI+YkJnZSI
	 H0oWS7BM5D3vYdjjNnCUwfJZ3AsAxv3uvegQseurk6gWMUJIHo37fMDP5z5z07M8tA
	 UrwymwOwwteqg==
From: Christian Brauner <brauner@kernel.org>
Date: Mon, 16 Nov 2026 12:03:53 +0100
Subject: [PATCH v2 13/17] bpf: fs/xattr: take freeze protection in the
 xattr kfuncs
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
Message-Id: <20261116-work-fs-frozen_writes-v2-13-ecc4a2aac40e@kernel.org>
References: <20261116-work-fs-frozen_writes-v2-0-ecc4a2aac40e@kernel.org>
In-Reply-To: <20261116-work-fs-frozen_writes-v2-0-ecc4a2aac40e@kernel.org>
To: Jan Kara <jack@suse.cz>
Cc: Shakeel Butt <shakeel.butt@linux.dev>, 
 Alexander Viro <viro@zeniv.linux.org.uk>, Jens Axboe <axboe@kernel.dk>, 
 linux-fsdevel@vger.kernel.org, linux-kernel@vger.kernel.org, 
 io-uring@vger.kernel.org, Christoph Hellwig <hch@lst.de>, 
 linux-block@vger.kernel.org, linux-nvme@lists.infradead.org, 
 linux-scsi@vger.kernel.org, target-devel@vger.kernel.org, 
 linux-unionfs@vger.kernel.org, bpf@vger.kernel.org, 
 linux-nfs@vger.kernel.org, 
 "Christian Brauner (Amutable)" <brauner@kernel.org>, stable@vger.kernel.org
X-Mailer: b4 0.17-dev-ce4c1
X-Developer-Signature: v=1; a=openpgp-sha256; l=1908; i=brauner@kernel.org;
 h=from:subject:message-id; bh=NJMGFUseCC73mMaQQ+G2n/tqmaWyJnxTdoOaGvDxcf8=;
 b=owGbwMvMwCU28Zj0gdSKO4sYT6slMWT9eqyz4vOTvRd7PnScFlrJUFmSOf2LzNqtX3/pV02s/
 duVsbJ1S0cpC4MYF4OsmCKLQ7tJuNxynorNRpkaMHNYmUCGMHBxCsBEMsMY/nts27Bi0jnThyk3
 rgTkx0uv3JDduWHPlrVNT+w/7PRg5NnOyLD8w+6Pzpvr8jqZuHVV/N37WGys/62TCZGeMe1cfrW
 NOTcA
X-Developer-Key: i=brauner@kernel.org; a=openpgp;
 fpr=4880B8C9BD0E5106FC070F4F7B3C391EFEA93624

bpf_set_dentry_xattr() and bpf_remove_dentry_xattr() go through
__vfs_setxattr() and __vfs_removexattr() which leave freeze protection
to the caller. BPF LSM programs call them from sleepable hooks such as
file_open where nobody holds it. So a program can modify a frozen
filesystem.

The hook may already hold freeze protection or locks a frozen
filesystem would make us wait under. So don't wait for a thaw. Fail
with -EBUSY if the filesystem is frozen.

The _locked variants are only used from hooks that run inside setattr,
setxattr, removexattr, unlink and rmdir. Their callers hold freeze
protection already.

Fixes: 56467292794b ("bpf: fs/xattr: Add BPF kfuncs to set and remove xattrs")
Cc: stable@vger.kernel.org
Signed-off-by: Christian Brauner (Amutable) <brauner@kernel.org>
---
 fs/bpf_fs_kfuncs.c | 8 ++++++++
 1 file changed, 8 insertions(+)

diff --git a/fs/bpf_fs_kfuncs.c b/fs/bpf_fs_kfuncs.c
index 35ccd98a4de64..7f61e2efa08ba 100644
--- a/fs/bpf_fs_kfuncs.c
+++ b/fs/bpf_fs_kfuncs.c
@@ -295,9 +295,13 @@ __bpf_kfunc int bpf_set_dentry_xattr(struct dentry *dentry, const char *name__st
 	if (!inode)
 		return -EINVAL;
 
+	/* The hook may hold locks or freeze protection already. */
+	if (!sb_start_write_trylock(inode->i_sb))
+		return -EBUSY;
 	inode_lock(inode);
 	ret = bpf_set_dentry_xattr_locked(dentry, name__str, value_p, flags);
 	inode_unlock(inode);
+	sb_end_write(inode->i_sb);
 	return ret;
 }
 
@@ -323,9 +327,13 @@ __bpf_kfunc int bpf_remove_dentry_xattr(struct dentry *dentry, const char *name_
 	if (!inode)
 		return -EINVAL;
 
+	/* The hook may hold locks or freeze protection already. */
+	if (!sb_start_write_trylock(inode->i_sb))
+		return -EBUSY;
 	inode_lock(inode);
 	ret = bpf_remove_dentry_xattr_locked(dentry, name__str);
 	inode_unlock(inode);
+	sb_end_write(inode->i_sb);
 	return ret;
 }
 

-- 
2.53.0

