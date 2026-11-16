Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.remote-ip=100.103.45.18
ARC-Seal: i=1; d=subspace.kernel.org; s=arc20261015; a=rsa-sha256; cv=none;
	t=1794827411;
	b=MNhDb+MEc9q1nvHr6cfKPnbvqRYgBZUtnnNMvboZU+D657IYlzWtT/rWVFfiSNHf5ptg
	 kjYI249hE9iaLycKVt2fVfFU60eR1+npAiWkJBZrNEqx3q0OqozK4HpnebCkYbO5Ki9gn
	 Lg03hH3HFjB+NWV1NBNLIGeMU4GtaGq2kciBFH04uYzT1QDJay3Birw0AWszI5Ntpt3SP
	 hAQluVQOxLzoOxIqe8PNdTxZlKnjhwknKPwEzeV2GSleijZ0xKZcdcRNqVhH6hofQcqE1
	 pet7/v2U5j9RfqMVRrnGqKgufasW5+LfdjdjymMXdA8fICYhpKTOqjbKY9O5jkIn2BA==
ARC-Message-Signature: i=1; d=subspace.kernel.org; s=arc20261015;
	a=rsa-sha256; c=relaxed/relaxed; t=1794827411;
	h=Received:DKIM-Signature:From:Date:Subject:MIME-Version:Content-Type:
	 Content-Transfer-Encoding:Message-Id:References:In-Reply-To:To:Cc:
	 X-Mailer:X-Developer-Signature:X-Developer-Key;
	bh=64fy1ZrurHksDYaEdeBVzwJEogDQqSWMHixC8IXM43k=;
	b=aLXKYrOLWkNvXZOjk0aARiycFw62u44DaKqoeNRPkT4xmpI20tNl2qvYcOauqf3wfCYl
	 gKPGS0Oyb1qMHfg0xxC1RtrkU72JFJrZ6AAXBOiBu+lNY56ejii54xchzq+KKdAbCvhOn
	 KZTEIcvZaB6pgTahl76jkR8xnbCUwj8o47vLaB9IlmpTwp/ICVgpM0CVw/p68hNolWZSR
	 nU8nvVRvL8XT0PeiaJHwlnRb9PWWCBXtefzZTjB/CnIOMdXneRFFXyUxfytKWwWMCJNMa
	 J/5urWB1jgzHpSXjLMR/ZPiitY9dx67Mga6t20Al/+bqPJ01PF3GooUfyNhXHMmIWRA==
ARC-Authentication-Results: i=1; smtp.subspace.kernel.org; 
	dkim=pass header.d=kernel.org header.i=@kernel.org header.a=rsa-sha256 header.s=k20260515 header.b=XFkCPZLO;
	arc=none smtp.remote-ip=100.103.45.18
Received: from smtp.kernel.org (quasi.space.kernel.org [100.103.45.18])
	(using TLSv1.3 with cipher TLS_AES_256_GCM_SHA384 (256/256 bits)
	 key-exchange X25519 server-signature ECDSA (prime256v1))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id ED72B606FDBF;
	Mon, 16 Nov 2026 11:10:10 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.a=rsa-sha256 header.s=k20260515 header.b=XFkCPZLO
Received: by smtp.kernel.org (Postfix) with ESMTPSA id 483D51F000C5;
	Mon, 16 Nov 2026 11:10:04 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=kernel.org;
	s=k20260515; t=1794827410;
	bh=64fy1ZrurHksDYaEdeBVzwJEogDQqSWMHixC8IXM43k=;
	h=From:Date:Subject:References:In-Reply-To:To:Cc;
	b=XFkCPZLOyT6temTwAkvo4voI/JBsg/Z4henG9tv1l4AP+unIyDGq5gVd+SYbfTNkW
	 J2q+A4W9ncbFM3o2CJeB1KlGFOQOyWo8ySYnVIO/5YximXo+mSB8h+1obwLjCcGEvW
	 A1UXSeiotXqdUuyPaAj9hOORnO/ihLGR8bgH8DCMlnoWpdtPxHllMf91dA7wxs97Eq
	 yjHuVmibG1NowwYf+Q8JcoJLbSPOUKYKONh6M5SqznmTuA/gM7dxnMZNsRN9PfbJft
	 +J4kIRFgBCIHj5EPRzp5FFbIDcQ2AbpmpaJCmFvcccbVtq7fFVdRiQ+kdhPCTlwHV7
	 761XGVhpeq4Nw==
From: Christian Brauner <brauner@kernel.org>
Date: Mon, 16 Nov 2026 12:05:06 +0100
Subject: [PATCH RFC v3 33/44] ovl: refuse data-only layers on pseudo
 filesystems
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
Message-Id: <20261116-work-loop-pseudo-v3-33-8cbbea1cf34f@kernel.org>
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
 "Christian Brauner (Amutable)" <brauner@kernel.org>
X-Mailer: b4 0.17-dev-ce4c1
X-Developer-Signature: v=1; a=openpgp-sha256; l=1983; i=brauner@kernel.org;
 h=from:subject:message-id; bh=Smh6T1OxDytywEa5/SA4YQOn0qat/3OEFq2S8CKkHFQ=;
 b=owGbwMvMwCU28Zj0gdSKO4sYT6slMWT9etzKv1zn0/fF8VbJ056U/V2j8fZ05/RKp3DlWuv16
 b/0c+MfdZSyMIhxMciKKbI4tJuEyy3nqdhslKkBM4eVCWQIAxenAEzkkz0jw/FI3n9/PH4HhZ1d
 ys8rckDxnqnu2en5RiGRkRGiO5TUohkZnmV/WFDrXXLFbNEWtocf1uvk3Hommj2NYaaXF8OJCE4
 pHgA=
X-Developer-Key: i=brauner@kernel.org; a=openpgp;
 fpr=4880B8C9BD0E5106FC070F4F7B3C391EFEA93624

The data of a metacopy file can live in a data-only layer. overlayfs
doesn't look that data up when it looks up the file. It only remembers
the absolute redirect and looks up the data lazily the first time
someone needs it. So until then nothing can tell which filesystem holds
the data of such a file.

But a data-only layer has no business being a pseudo filesystem in the
first place. All it does is hold the data of metacopy files and the
regular files of a pseudo filesystem are kernel interfaces, not storage.
So let's refuse data-only layers on superblocks with SB_I_PSEUDO at
mount time.

Data-only layers can be added via the "::" separator in "lowerdir=" and
via "datadir+" by path or by file descriptor. All of them end up at the
end of ctx->lower. So a single check in ovl_get_lowerstack() covers all
of them.

Note that regular lower layers on pseudo filesystems are left alone.
Stacking overlayfs on top of sysfs keeps working.

Suggested-by: Amir Goldstein <amir73il@gmail.com>
Link: https://lore.kernel.org/all/CAOQ4uxhGxpBtMZ5kfuzR1tQAewiecoX7UjXQRo91QjJHH9T_Yw@mail.gmail.com
Signed-off-by: Christian Brauner (Amutable) <brauner@kernel.org>
---
 fs/overlayfs/super.c | 8 ++++++++
 1 file changed, 8 insertions(+)

diff --git a/fs/overlayfs/super.c b/fs/overlayfs/super.c
index 39d4d57dec230..719c2569dfeaf 100644
--- a/fs/overlayfs/super.c
+++ b/fs/overlayfs/super.c
@@ -1237,6 +1237,14 @@ static struct ovl_entry *ovl_get_lowerstack(struct super_block *sb,
 	for (i = 0; i < ctx->nr; i++) {
 		l = &ctx->lower[i];
 
+		/* Pseudo filesystems don't hold data for metacopy files. */
+		if (i >= ctx->nr - ctx->nr_data &&
+		    (l->path.dentry->d_sb->s_iflags & SB_I_PSEUDO)) {
+			pr_err("filesystem on %s not supported as data-only layer\n",
+			       l->name);
+			return ERR_PTR(-EINVAL);
+		}
+
 		err = ovl_lower_dir(l->name, &l->path, ofs, &sb->s_stack_depth);
 		if (err)
 			return ERR_PTR(err);

-- 
2.53.0

