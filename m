Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.remote-ip=100.103.45.18
ARC-Seal: i=1; d=subspace.kernel.org; s=arc20261015; a=rsa-sha256; cv=none;
	t=1793821866;
	b=4eEokNWp6HZIKPnQBbbE0exeDxdYL2LkjV+aVEl072MIgkYVrGH2Qd7Bzt1dnO+4d3fr
	 7lpsnULBn9QDirYTsb4PRp9ZMLdaqZ2Tk3+xBZyYbjAilZ3FwXMajL/Utzle4ziGKRUts
	 eL9HvG6azgS4FjIEsrYxIk9f6ynlNVGQAVVdUjdDfvArMMrAzYwF4DRKnSQ8OmxNJJg+j
	 sBFTPOfT6LdVsjQaz3R7QQfjCtUSflpH6svXWVj8NC8u6hGM9tkY3emgrgP7sGh37l59Z
	 VGhunzERI7HgSqqdtEmDYmPgnIF6Hn6l74UasatzASp9P2+sT9rfrgnb0jiSiV6BgKg==
ARC-Message-Signature: i=1; d=subspace.kernel.org; s=arc20261015;
	a=rsa-sha256; c=relaxed/relaxed; t=1793821866;
	h=Received:DKIM-Signature:From:To:Cc:Subject:Date:Message-ID:
	 In-Reply-To:References:MIME-Version:Content-Type:X-Mailer:
	 X-Developer-Signature:X-Developer-Key:Content-Transfer-Encoding;
	bh=nEQe0uyLMhpY0v6D+NYVpfdWFgM7DE6SumWpafCq12g=;
	b=DmUQzX+uhxC73RSUT75Hz61XxufgTKqE4bCgFlTCCDqZVHX90Odyi72nRJ+brNPf8Q7B
	 0Q+cLxHZ1Y6m+FjGNCCFcRC8YDBTfgPmfbAA2pcK+esfVWKdJHtHyiv/VaNvh9EYmfpYF
	 jnY/K+ddYV18Klxc5Q4ERClD1HagD2rfQwbMk/E4Q8UpkqSbfyMOhEny8QAbehF7yMA4U
	 lqotrZvsJ1hxHtixePUsSodKc6rypwZ0A3nj/0rhiUN8GWndEhKeVJ4HPq7CuQMXmv/od
	 RujJ6uRQ8JTCRIu8v23rQ1jij+FAjNfdcR+wP5U9Wzk1CKsBLhm0BxPJCM35DHMt3Fg==
ARC-Authentication-Results: i=1; smtp.subspace.kernel.org; 
	dkim=pass header.d=kernel.org header.i=@kernel.org header.a=rsa-sha256 header.s=k20260515 header.b=PNR1RL0M;
	arc=none smtp.remote-ip=100.103.45.18
Received: from smtp.kernel.org (quasi.space.kernel.org [100.103.45.18])
	(using TLSv1.3 with cipher TLS_AES_256_GCM_SHA384 (256/256 bits)
	 key-exchange X25519 server-signature ECDSA (prime256v1))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 21A196092BD2;
	Wed,  4 Nov 2026 19:51:05 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key, unprotected) header.d=kernel.org header.i=@kernel.org header.a=rsa-sha256 header.s=k20260515 header.b=PNR1RL0M
Received: by smtp.kernel.org (Postfix) with ESMTPSA id 7FE711F000C1;
	Wed,  4 Nov 2026 19:50:53 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=kernel.org;
	s=k20260515; t=1793821865;
	bh=nEQe0uyLMhpY0v6D+NYVpfdWFgM7DE6SumWpafCq12g=;
	h=From:To:Cc:Subject:Date:In-Reply-To:References;
	b=PNR1RL0MdGjcQerL1pRweO0sDyx5srKRXEN8HDA+Rakv7ORmxGv0M2c4pYe9RS1TQ
	 0hEIzB+5FOF0UCUZDy2W4t4c7HuYIzaQJTIIdmOzZYD7DdxjyO4UPMNhgtsSPIcilP
	 VKQkCD781my0Xdy0OOhH6pW79rQPVmEqRIUUxd2NdY92712CXUTz6e3VpbB0hBPCek
	 OuNQy8Ti5KEKBVAOmNI7xjQ/es+OJejnGIOCcQv3TLP2VhuvJQoptNjkpFmMJ9AFiD
	 0pSOj7vYCxBvgAkRaIbFsX+qFB2wBAEL9TsIawHW/SCRe0fGQn34mw49XBQgFh27d6
	 NX3UXBJy8hndg==
From: Christian Brauner <brauner@kernel.org>
To: linux-fsdevel@vger.kernel.org
Cc: Linus Torvalds <torvalds@linux-foundation.org>,
	Jann Horn <jannh@google.com>,
	Josef Bacik <josef@toxicpanda.com>,
	Chris Mason <mason@kernel.org>,
	Jeff Layton <jlayton@kernel.org>,
	NeilBrown <neil@brown.name>,
	Eric Dumazet <edumazet@kernel.org>,
	Thomas Gleixner <tglx@kernel.org>,
	Al Viro <viro@zeniv.linux.org.uk>,
	Jonathan Corbet <corbet@lwn.net>,
	Christoph Hellwig <hch@lst.de>,
	Greg Kroah-Hartman <gregkh@suse.de>,
	Joel Granados <joel.granados@kernel.org>,
	Kees Cook <kees@kernel.org>,
	Jan Kara <jack@suse.cz>,
	Jan Kara <jack@suse.com>,
	linux-kernel@vger.kernel.org,
	linux-nfs@vger.kernel.org,
	linux-acpi@vger.kernel.org,
	linux-kselftest@vger.kernel.org,
	linux-s390@vger.kernel.org,
	linux-scsi@vger.kernel.org,
	linux-um@lists.infradead.org,
	linux-wireless@vger.kernel.org,
	linuxppc-dev@lists.ozlabs.org,
	netdev@vger.kernel.org,
	ntfs3@lists.linux.dev,
	platform-driver-x86@vger.kernel.org,
	coreteam@netfilter.org,
	kexec@lists.infradead.org,
	linux-pci@vger.kernel.org,
	linux-sound@vger.kernel.org,
	netfilter-devel@vger.kernel.org,
	dri-devel@lists.freedesktop.org,
	ibm-acpi-devel@lists.sourceforge.net,
	jfs-discussion@lists.sourceforge.net,
	linux-alpha@vger.kernel.org,
	linux-arm-kernel@lists.infradead.org,
	linux-cifs@vger.kernel.org,
	linux-fbdev@vger.kernel.org,
	linux-hwmon@vger.kernel.org,
	linux-mm@kvack.org,
	linux-sh@vger.kernel.org,
	linux-usb@vger.kernel.org,
	samba-technical@lists.samba.org,
	sparclinux@vger.kernel.org,
	linux-m68k@lists.linux-m68k.org,
	linux-doc@vger.kernel.org,
	linux-serial@vger.kernel.org,
	linux-atm-general@lists.sourceforge.net,
	Takashi Iwai <tiwai@suse.de>,
	linux-input@vger.kernel.org,
	linux-raid@vger.kernel.org,
	linux-ext4@vger.kernel.org,
	linux-modules@vger.kernel.org,
	linux-debuggers@vger.kernel.org,
	"Christian Brauner (Amutable)" <brauner@kernel.org>,
	Chuck Lever <cel@kernel.org>
Subject: [PATCH RESEND v2 05/30] nfsd: factor out setting up the exports seq_file
Date: Wed,  4 Nov 2026 20:50:51 +0100
Message-ID: <20261104-work-procfs-fs-v2-5-319e0f9a8aae@kernel.org>
In-Reply-To: <20261104-work-procfs-fs-v2-0-319e0f9a8aae@kernel.org>
References: <20261104-work-procfs-fs-v2-0-319e0f9a8aae@kernel.org>
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
X-Mailer: b4 0.17-dev
X-Developer-Signature: v=1; a=openpgp-sha256; l=1726; i=brauner@kernel.org; h=from:subject:message-id; bh=vD80ghFjEqER+DW0z2Tx247oQHe2lrzCvRX/1X8RBv4=; b=owGbwMvMwCU28Zj0gdSKO4sYT6slMWS97jE4HGMmWSWebTGtb+f+qbf6t/93PO9leHL1HTEbl YAwmQUfO0pZGMS4GGTFFFkc2k3C5ZbzVGw2ytSAmcPKBDKEgYtTACayJpThr5Txruw7h8z+75d5 n1L9ZprSX0ON4zl3v9jMV5lvl7Zx8waG/4W80ze0KR4rWpY6/3hi66zKk8tmbsxvP1RSWORQnvT 3OCsA
X-Developer-Key: i=brauner@kernel.org; a=openpgp; fpr=4880B8C9BD0E5106FC070F4F7B3C391EFEA93624
Content-Transfer-Encoding: 8bit

Move setting up ->private and taking the reference to the network
namespace into exports_net_init() and dropping it into
exports_net_put(). The procfs file needs them without the seq_open()
and seq_release() around them.

No functional changes.

Acked-by: Chuck Lever <cel@kernel.org>
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

