Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.remote-ip=100.103.45.18
ARC-Seal: i=1; d=subspace.kernel.org; s=arc20261015; a=rsa-sha256; cv=none;
	t=1794827181;
	b=PfdSFc4fEZiQ7/MKEtSZbzU6R9KSF/Svbe6DSgg0s4pDN9zB/S7nndMp24nS6pJVoY1h
	 /dcNb+CGJz27+qm9j1F4ipx9dvituwOI5otjougZGN/4fA/6+J6PqCvhLynbB7+sZrL/Y
	 qDBPNHujmkv+rYSb+D4TbXPu2Wwr9oSRVE2K/Aq7ZA4vgHDkxyYw3GU46tPHKG7n/FX/F
	 JGQQXO8FydG67F828dhkrxXeLiEq1uQD35PQcNUSy9CMW2Is2M9+1LDB61t2qVglN1Fbv
	 TXxwliwoJyFTLd1pWCe5DVDjHLR+4C/A2lJ0/cGawCw7pwjiA6u6MBexj7N9pBwjNdg==
ARC-Message-Signature: i=1; d=subspace.kernel.org; s=arc20261015;
	a=rsa-sha256; c=relaxed/relaxed; t=1794827181;
	h=Received:DKIM-Signature:From:Date:Subject:MIME-Version:Content-Type:
	 Content-Transfer-Encoding:Message-Id:References:In-Reply-To:To:Cc:
	 X-Mailer:X-Developer-Signature:X-Developer-Key;
	bh=VWUjc/lm6IOzTKu/XrjxEXkA+3TDHZe6UgBZOCqPWKg=;
	b=CAzEvNRd2NQIAaIOQEzfl3v6Bq8tDUKsQK71rNUnccUFwNZDfN0VOQadVimUCpfaqnBE
	 RBVLc+z7szscfB6hO9VDH8op3ry2RwFH+2xgwBjTCr9DqXM25WgTZ94efmouC38etWysn
	 IeM6dzTm3mzvMs0EK8gGZSRG23UzFc8AT6QtGYtR8KDxf92uIZl+X6Eam2VJBmshFPi0i
	 DY95qrLRALKtp3Jd9E3vjP3wrSkOh0TtvBdy9MVmxNyHfjnGTWvfyq97RZy5l4PpZfojc
	 j/4ztbVzC2Mtp42IfWV+IrDMfgGgWixLnXmt0WxoR2diEI0wLRCvEdxpAI1XUJcIZzw==
ARC-Authentication-Results: i=1; smtp.subspace.kernel.org; 
	dkim=pass header.d=kernel.org header.i=@kernel.org header.a=rsa-sha256 header.s=k20260515 header.b=gqYeWMoi;
	arc=none smtp.remote-ip=100.103.45.18
Received: from smtp.kernel.org (quasi.space.kernel.org [100.103.45.18])
	(using TLSv1.3 with cipher TLS_AES_256_GCM_SHA384 (256/256 bits)
	 key-exchange X25519 server-signature ECDSA (prime256v1))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 1BC3F606AB6A;
	Mon, 16 Nov 2026 11:06:20 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.a=rsa-sha256 header.s=k20260515 header.b=gqYeWMoi
Received: by smtp.kernel.org (Postfix) with ESMTPSA id B1CE11F000C4;
	Mon, 16 Nov 2026 11:06:13 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=kernel.org;
	s=k20260515; t=1794827180;
	bh=VWUjc/lm6IOzTKu/XrjxEXkA+3TDHZe6UgBZOCqPWKg=;
	h=From:Date:Subject:References:In-Reply-To:To:Cc;
	b=gqYeWMoiimKnvtxsZfDhW+FmTOi7BTYxF7bo1d97YCVIcFzQE/1quY4S5XouMi3vB
	 mIvfX8HLza9wbhVfQveoZSPNYa7EZm6PUCmHQ7skz2lmq1+o5ujqB3Qz/i2/xmyuvR
	 0b4/gWtXnDtYIY3WrioVdCD8nsc4XHXOdDDcY2gKhZ/KosrpWqVHiN6+7kfAXc2Ahu
	 If9E+wIs0Kg08YhaHkaKtxLqpKU3MXnTXiDfJS25gkPWQfrBhMW81NVuUjfaEMsu6P
	 vgEPDQeb4sn9onP21h80NsMHJnf9A+r8P+Co4bTECH6PFFrHeRa5TxSI1gVwQGLhtT
	 OalR/X8sFsCZQ==
From: Christian Brauner <brauner@kernel.org>
Date: Mon, 16 Nov 2026 12:04:35 +0100
Subject: [PATCH RFC v3 02/44] nvmet: check that the file backend supports
 ->{read,write}_iter
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
Message-Id: <20261116-work-loop-pseudo-v3-2-8cbbea1cf34f@kernel.org>
References: <20261116-work-loop-pseudo-v3-0-8cbbea1cf34f@kernel.org>
In-Reply-To: <20261116-work-loop-pseudo-v3-0-8cbbea1cf34f@kernel.org>
To: linux-fsdevel@vger.kernel.org
Cc: Jann Horn <jannh@google.com>, Chris Mason <mason@kernel.org>, 
 Josef Bacik <josef@toxicpanda.com>, Christoph Hellwig <hch@lst.de>, 
 linux-block@vger.kernel.org, linux-kernel@vger.kernel.org, 
 linux-nvme@lists.infradead.org, Alexander Viro <viro@zeniv.linux.org.uk>, 
 Jan Kara <jack@suse.cz>, linux-scsi@vger.kernel.org, 
 target-devel@vger.kernel.org, driver-core@lists.linux.dev, 
 linux-mm@kvack.org, bpf@vger.kernel.org, 
 linux-security-module@vger.kernel.org, selinux@vger.kernel.org, 
 apparmor@lists.ubuntu.com, linux-nfs@vger.kernel.org, 
 netdev@vger.kernel.org, fuse-devel@lists.linux.dev, 
 linux-efi@vger.kernel.org, xen-devel@lists.xenproject.org, 
 ocfs2-devel@lists.linux.dev, linux-s390@vger.kernel.org, 
 linuxppc-dev@lists.ozlabs.org, linux-usb@vger.kernel.org, 
 Amir Goldstein <amir73il@gmail.com>, linux-erofs@lists.ozlabs.org, 
 linux-kselftest@vger.kernel.org, 
 "Christian Brauner (Amutable)" <brauner@kernel.org>, 
 Chris Down <chris@chrisdown.name>
X-Mailer: b4 0.17-dev-ce4c1
X-Developer-Signature: v=1; a=openpgp-sha256; l=1339; i=brauner@kernel.org;
 h=from:subject:message-id; bh=EG8EaOiS0vQgTkKg5XSiMzmkRFf0paS6Df2fYJxqpSs=;
 b=owGbwMvMwCU28Zj0gdSKO4sYT6slMWT9epzAcWr709tb5k+1mZtXOrOoKe7FjPPX93rnL01cc
 mp3sNpj3o5SFgYxLgZZMUUWh3aTcLnlPBWbjTI1YOawMoEMYeDiFICJxH1n+Ke3fG/p7vfHb83W
 Mp77jIfTTjdGPfuMqexdx60Xbl2XDD/E8D9576foPweu5yU+nf3y9bU/t+YHf7W8oOhp5cy3bNl
 qq+9cAA==
X-Developer-Key: i=brauner@kernel.org; a=openpgp;
 fpr=4880B8C9BD0E5106FC070F4F7B3C391EFEA93624

The file backend calls ->read_iter() and ->write_iter() of the backing
file directly but never checks that they exist. Everything that isn't a
block device ends up in the file backend. So a namespace pointing to a
file without them calls a NULL pointer on its first I/O. Only
buffered_io=1 gets that far as the O_DIRECT open fails for such files.

Refuse them when the namespace is enabled the same way zloop does since
commit 0c10f8a1a7ae ("zloop: check that the zone backing file support
->{read,write}_iter").

Fixes: d5eff33ee6f8 ("nvmet: add simple file backed ns support")
Reviewed-by: Jan Kara <jack@suse.cz>
Reviewed-by: Christoph Hellwig <hch@lst.de>
Reviewed-by: Chris Down <chris@chrisdown.name>
Signed-off-by: Christian Brauner (Amutable) <brauner@kernel.org>
---
 drivers/nvme/target/io-cmd-file.c | 5 +++++
 1 file changed, 5 insertions(+)

diff --git a/drivers/nvme/target/io-cmd-file.c b/drivers/nvme/target/io-cmd-file.c
index 695963dd932ee..dfa8aa46188c8 100644
--- a/drivers/nvme/target/io-cmd-file.c
+++ b/drivers/nvme/target/io-cmd-file.c
@@ -47,6 +47,11 @@ int nvmet_file_ns_enable(struct nvmet_ns *ns)
 		return ret;
 	}
 
+	if (!ns->file->f_op->read_iter || !ns->file->f_op->write_iter) {
+		ret = -EINVAL;
+		goto err;
+	}
+
 	nvmet_file_ns_revalidate(ns);
 
 	/*

-- 
2.53.0

