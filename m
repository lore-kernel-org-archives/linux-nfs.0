Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.remote-ip=100.103.45.18
ARC-Seal: i=1; d=subspace.kernel.org; s=arc20261015; a=rsa-sha256; cv=none;
	t=1793632873;
	b=FoGZ2Iwt85b/P0lyaHdch4LlMrYRCHRKOS9eqCL9F2yynF52kiykrhA+lBIrTUFYRG5u
	 VrGcAhmqspu3eNa536cAM/8DA/SK6UdGNnz3pR6N7RR7FIp/ZmdlU6fbXhtcnIz7MOC/M
	 aY3kLTM3WEMKoQm0WP10Lp7lY/p5+03beJslP6Ib3k+wyXZEhTm3He4gzvxsbmPEUsNyQ
	 b06NcosPLNo7fUvDfY6oNUx5TOUC4rBSphQPmeXFKZohmbH1dfqltuKGCQCO3iYL2A1ZQ
	 8VkgncytOYBOMaGRTZDAekGgZgj1eKOTIcZAHrSTx0dqA5a2QmCZaumiQehUZzf9tBg==
ARC-Message-Signature: i=1; d=subspace.kernel.org; s=arc20261015;
	a=rsa-sha256; c=relaxed/relaxed; t=1793632873;
	h=Received:DKIM-Signature:From:Date:Subject:MIME-Version:Content-Type:
	 Content-Transfer-Encoding:Message-Id:References:In-Reply-To:To:Cc:
	 X-Mailer:X-Developer-Signature:X-Developer-Key;
	bh=Qv+c+5TDu4Q/teEIdzSpkmAL+eEuuwslAw9ahtaZFXA=;
	b=5Zvw9qEZbUQ6Uw7v5Sd8fj3mtz10UyGenb9FfcA4bUoq2EiZKWq660RzGcYpUGtd3X97
	 EelJce9aPhrjqLWDATae9Ca7Xd/X5S4Bw3mi2YE2BbwGDree4eg/fkYCev/QQWeKk4uuu
	 5sJ32iIDBnSKGut6QL/BWlCOh/7wGJOix3uZwB+vIducNDTZA8gplr9++zqlqy8fxqhYB
	 xJG+0Gu9oqy04+WZrCDxAocjBUMKxHnxwtOGuDtP2AZ/eDiZkxiyM2Y7ctAb7gfAKsnr6
	 XXXaj6eEqpSPfEXZ3xfS2/VVEyCsfQ4uGYezqrD5qHTbKhZmPDIqZa2qiYUtQcYLYcQ==
ARC-Authentication-Results: i=1; smtp.subspace.kernel.org; 
	dkim=pass header.d=kernel.org header.i=@kernel.org header.a=rsa-sha256 header.s=k20260515 header.b=DbhUJFDn;
	arc=none smtp.remote-ip=100.103.45.18
Received: from smtp.kernel.org (quasi.space.kernel.org [100.103.45.18])
	(using TLSv1.3 with cipher TLS_AES_256_GCM_SHA384 (256/256 bits)
	 key-exchange X25519 server-signature ECDSA (prime256v1))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id E2CE56070C9B;
	Mon,  2 Nov 2026 15:21:12 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key, unprotected) header.d=kernel.org header.i=@kernel.org header.a=rsa-sha256 header.s=k20260515 header.b=DbhUJFDn
Received: by smtp.kernel.org (Postfix) with ESMTPSA id D31E81F00A1A;
	Mon,  2 Nov 2026 15:20:53 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=kernel.org;
	s=k20260515; t=1793632872;
	bh=Qv+c+5TDu4Q/teEIdzSpkmAL+eEuuwslAw9ahtaZFXA=;
	h=From:Date:Subject:References:In-Reply-To:To:Cc;
	b=DbhUJFDnO++WjegqV6sjnyS3otcl2/2sebZdDMTR095f4hFRZkMTGJyBlkuj94zIa
	 oSP3D1Ac7j4cfaoTs/YOZ/3HD4OntLtKpa0LwpNCh1+JLKi4UfYnGiwu0CoVUtic+M
	 /EOwTs/jPaQwpILuGPGbb/lTH5xfB3ImCVRAHdrO8lvkKmi+OSz4QkxvnUntYfmDLy
	 qsb4GyhuZqoOiqLcQKRlgK+Q8Z7rBL8ybky3VU6Bckc3xoq03qdnURR13NFJolGiGN
	 NMeI9G1ZGK8/Pa0iYX2UzAKoC/oKZ8aXViZ1ZRVWwt4iYelFx979KqrM1W3LPfQRZF
	 /OPD4WdSZcZVw==
From: Christian Brauner <brauner@kernel.org>
Date: Mon, 02 Nov 2026 16:07:15 +0100
Subject: [PATCH RFC 05/27] nfsd: factor out setting up the exports seq_file
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
Message-Id: <20261102-work-procfs-fs-v1-5-d09a996317b3@kernel.org>
References: <20261102-work-procfs-fs-v1-0-d09a996317b3@kernel.org>
In-Reply-To: <20261102-work-procfs-fs-v1-0-d09a996317b3@kernel.org>
To: linux-fsdevel@vger.kernel.org
Cc: Linus Torvalds <torvalds@linux-foundation.org>, 
 Jann Horn <jannh@google.com>, Josef Bacik <josef@toxicpanda.com>, 
 Chris Mason <mason@kernel.org>, Jeff Layton <jlayton@kernel.org>, 
 NeilBrown <neil@brown.name>, Eric Dumazet <edumazet@kernel.org>, 
 Thomas Gleixner <tglx@kernel.org>, Al Viro <viro@zeniv.linux.org.uk>, 
 Jonathan Corbet <corbet@lwn.net>, Christoph Hellwig <hch@lst.de>, 
 Greg Kroah-Hartman <gregkh@suse.de>, 
 Joel Granados <joel.granados@kernel.org>, Kees Cook <kees@kernel.org>, 
 Jan Kara <jack@suse.cz>, Jan Kara <jack@suse.com>, 
 linux-kernel@vger.kernel.org, linux-nfs@vger.kernel.org, 
 linux-acpi@vger.kernel.org, linux-kselftest@vger.kernel.org, 
 linux-s390@vger.kernel.org, linux-scsi@vger.kernel.org, 
 linux-um@lists.infradead.org, linux-wireless@vger.kernel.org, 
 linuxppc-dev@lists.ozlabs.org, netdev@vger.kernel.org, 
 ntfs3@lists.linux.dev, platform-driver-x86@vger.kernel.org, 
 coreteam@netfilter.org, kexec@lists.infradead.org, 
 linux-pci@vger.kernel.org, linux-sound@vger.kernel.org, 
 netfilter-devel@vger.kernel.org, dri-devel@lists.freedesktop.org, 
 ibm-acpi-devel@lists.sourceforge.net, jfs-discussion@lists.sourceforge.net, 
 linux-alpha@vger.kernel.org, linux-arm-kernel@lists.infradead.org, 
 linux-cifs@vger.kernel.org, linux-fbdev@vger.kernel.org, 
 linux-hwmon@vger.kernel.org, linux-mm@kvack.org, linux-sh@vger.kernel.org, 
 linux-usb@vger.kernel.org, samba-technical@lists.samba.org, 
 sparclinux@vger.kernel.org, linux-m68k@lists.linux-m68k.org, 
 linux-doc@vger.kernel.org, linux-serial@vger.kernel.org, 
 linux-atm-general@lists.sourceforge.net, Takashi Iwai <tiwai@suse.de>, 
 linux-input@vger.kernel.org, linux-raid@vger.kernel.org, 
 linux-ext4@vger.kernel.org, linux-modules@vger.kernel.org, 
 linux-debuggers@vger.kernel.org, 
 "Christian Brauner (Amutable)" <brauner@kernel.org>, 
 Chuck Lever <cel@kernel.org>
X-Mailer: b4 0.17-dev
X-Developer-Signature: v=1; a=openpgp-sha256; l=1686; i=brauner@kernel.org;
 h=from:subject:message-id; bh=YYADF9o+HT3otr/TqTwRIyIlVsvmHiIwO/9qKSxr7WM=;
 b=owGbwMvMwCU28Zj0gdSKO4sYT6slMWS9WG74im2vw/SLgkcF9xwvCrAujmja3vZs6iUted4PB
 lv0d6u4dJSyMIhxMciKKbI4tJuEyy3nqdhslKkBM4eVCWQIAxenAEyk8jPDP8N52YHHueeITrga
 lFLZpu2/1M/v9c0uN21dk5DSny1CfowMx1f09ARf2fUkLZKFdYNHzvT2UqEvnn+41f65szhZbrL
 iBAA=
X-Developer-Key: i=brauner@kernel.org; a=openpgp;
 fpr=4880B8C9BD0E5106FC070F4F7B3C391EFEA93624

Move setting up ->private and taking the reference to the network
namespace into exports_net_init() and dropping it into
exports_net_put(). The procfs file needs them without the seq_open()
and seq_release() around them.

No functional changes.

Signed-off-by: Christian Brauner (Amutable) <brauner@kernel.org>
---
 fs/nfsd/nfsctl.c | 26 +++++++++++++++++---------
 1 file changed, 17 insertions(+), 9 deletions(-)

diff --git a/fs/nfsd/nfsctl.c b/fs/nfsd/nfsctl.c
index f32311f2d7cf..f8ce3c0fb077 100644
--- a/fs/nfsd/nfsctl.c
+++ b/fs/nfsd/nfsctl.c
@@ -143,28 +143,36 @@ static const struct file_operations transaction_ops = {
 	.llseek		= default_llseek,
 };
 
+static void exports_net_init(struct net *net, struct seq_file *seq)
+{
+	struct nfsd_net *nn = net_generic(net, nfsd_net_id);
+
+	seq->private = nn->svc_export_cache;
+	get_net(net);
+}
+
+static void exports_net_put(struct seq_file *seq)
+{
+	struct cache_detail *cd = seq->private;
+
+	put_net(cd->net);
+}
+
 static int exports_net_open(struct net *net, struct file *file)
 {
 	int err;
-	struct seq_file *seq;
-	struct nfsd_net *nn = net_generic(net, nfsd_net_id);
 
 	err = seq_open(file, &nfs_exports_op);
 	if (err)
 		return err;
 
-	seq = file->private_data;
-	seq->private = nn->svc_export_cache;
-	get_net(net);
+	exports_net_init(net, file->private_data);
 	return 0;
 }
 
 static int exports_release(struct inode *inode, struct file *file)
 {
-	struct seq_file *seq = file->private_data;
-	struct cache_detail *cd = seq->private;
-
-	put_net(cd->net);
+	exports_net_put(file->private_data);
 	return seq_release(inode, file);
 }
 

-- 
2.53.0

