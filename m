Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.remote-ip=100.103.45.18
ARC-Seal: i=1; d=subspace.kernel.org; s=arc20261015; a=rsa-sha256; cv=none;
	t=1793814937;
	b=p0/c0wTUw9g8cRR66G5k2Is9hD4UWjW8YPYEj3gsAlDZLdvtBOD+KMttsc7671MGycjK
	 noIscCStBNVIfmZOgWg6lZUcfJm6zuC49W4R3PQ52V4F5C/rWk1HCnhh0I624EA2Urth8
	 O1E90qq0VPuDEVt4hhGqBflNNBUi2P208R0S2OlYIaux0kwfBvzMKva8NgITnegDLdNvU
	 9rlrzuW4sjaM0vcBPNpxiY7Q2MyUv8S1N8owvb0EgkT1sj/tVTokZl29kh3M7jECKN7Of
	 ntQfmQL8dp8QThtQNox1C1kmcqkj65G8s/XDoNAGjUpAj7iK9sWW1dTYEq6G65auC/A==
ARC-Message-Signature: i=1; d=subspace.kernel.org; s=arc20261015;
	a=rsa-sha256; c=relaxed/relaxed; t=1793814937;
	h=Received:DKIM-Signature:From:To:Cc:Subject:Date:Message-ID:
	 In-Reply-To:References:MIME-Version:Content-Type:X-Mailer:
	 X-Developer-Signature:X-Developer-Key:Content-Transfer-Encoding;
	bh=89c02+ELWuX5+S2o66zdN47fZ8jrr3os6Vl1YJUNtuU=;
	b=m3Lq3wpv1j4fsJqMBLXZXC2aO8owjAnU0w+4ja8dCZiz+06GSA2jhLVw7YTaIgw2CKgF
	 hFUcMZTnEUt1RlDet1amEmCw1qfyTUfTh6KTijoJPV8OtovIer5a8Hoz04wzzyhNCjHUX
	 V9ltb02wg7uykF4xOEgrTHLv2c/gqERhtbqwDu9agYbL6d2pMnaTyPTQ/+Ngphay3EIIb
	 r2iCn8Ibh5OLLHvXvuVZoAnUoiU9FBmgVRTGJJlfTqOkpTaWmaGxrkyosEWOM1WuelKJX
	 YEDz7YegRiznl9pVZjdHs7KxrissJcgZ9b74SgJLXQj9RvTpx6+Doj7i0cNBwKCt1ew==
ARC-Authentication-Results: i=1; smtp.subspace.kernel.org; 
	dkim=pass header.d=kernel.org header.i=@kernel.org header.a=rsa-sha256 header.s=k20260515 header.b=lv3gFXSS;
	arc=none smtp.remote-ip=100.103.45.18
Received: from smtp.kernel.org (quasi.space.kernel.org [100.103.45.18])
	(using TLSv1.3 with cipher TLS_AES_256_GCM_SHA384 (256/256 bits)
	 key-exchange X25519 server-signature ECDSA (prime256v1))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 18357606A68A;
	Wed,  4 Nov 2026 17:55:37 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key, unprotected) header.d=kernel.org header.i=@kernel.org header.a=rsa-sha256 header.s=k20260515 header.b=lv3gFXSS
Received: by smtp.kernel.org (Postfix) with ESMTPSA id DD4DE1F00A16;
	Wed,  4 Nov 2026 17:55:12 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=kernel.org;
	s=k20260515; t=1793814936;
	bh=89c02+ELWuX5+S2o66zdN47fZ8jrr3os6Vl1YJUNtuU=;
	h=From:To:Cc:Subject:Date:In-Reply-To:References;
	b=lv3gFXSSZQ1eyeFxl4sMw4NV+sDGb399yJy5J5a617cu3SzjnnFfUG43Lfl/7N2wR
	 K+IhSwvXPWPYjM+q4YQ+IDJcS26tQY7yPe6vUEMgkrymmspdu0EotaGD42o6rpaRl9
	 0A3kHepPv/ApdT3/KV9Zp4gd4PPOjbWG6usoLl5/UMWpBcxegT2cBWuUjFbtBLH7mv
	 6ymbGGCGv3TrMbwp1kdSSvCMr+6QGHtpTwZWaklXV25iOtzvIgzYNxKq9awhT/uEik
	 dFy+Ax1siZAlHQyp0vw3cAsPNd4lTDPGDdUR7g3JwRgFyHgFv3m15tZ2mAVMcDLMbJ
	 1KqqoJMCmMAiQ==
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
Subject: [PATCH v2 35/51] proc: warn about entries left in /proc/net of a dying namespace
Date: Wed,  4 Nov 2026 18:47:21 +0100
Message-ID: <20261104-work-procfs-bugfixes-v2-35-bbf7d5546809@kernel.org>
In-Reply-To: <20261104-work-procfs-bugfixes-v2-0-bbf7d5546809@kernel.org>
References: <20261104-work-procfs-bugfixes-v2-0-bbf7d5546809@kernel.org>
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
X-Developer-Signature: v=1; a=openpgp-sha256; l=1410; i=brauner@kernel.org; h=from:subject:message-id; bh=WtI/bNxyA4ZViPTNrsQhWLRSUjQUZ6M8VP3x2XTkww0=; b=owGbwMvMwCU28Zj0gdSKO4sYT6slMWS9znslLxak6zXzI89Tlobt8x2XHObOOr/+XjXLr/wSD pcMiUNGHaUsDGJcDLJiiiwO7Sbhcst5KjYbZWrAzGFlAhnCwMUpABOZcIHhv9PR9Kbfsr9EuEwS 1OuN4o2O2Xfx2elLdO/WqT/FzfBsLsMfvrrlGXyfnU+ePfxJ5/kd5mMSt0XZXSfwl/mEMKZnOc9 mAwA=
X-Developer-Key: i=brauner@kernel.org; a=openpgp; fpr=4880B8C9BD0E5106FC070F4F7B3C391EFEA93624
Content-Transfer-Encoding: 8bit

proc_net_ns_exit() runs after all the other pernet exits and frees
net->proc_net right after removing "stat" from it. An entry that some
pernet exit forgot to remove is left with a freed ->parent, and so
PDE_NET() hands seq_open_net() and single_open_net() a freed struct net
when the entry is opened through a file descriptor that someone kept.

There is no such entry in the tree that we know of, but nothing would
tell us about one either. So warn about it like remove_proc_entry()
does for a directory that isn't empty.

Reported-by: Chris Mason <mason@kernel.org>
Fixes: e9720acd728a ("[NET]: Make /proc/net a symlink on /proc/self/net (v3)")
Signed-off-by: Christian Brauner (Amutable) <brauner@kernel.org>
---
 fs/proc/proc_net.c | 6 ++++++
 1 file changed, 6 insertions(+)

diff --git a/fs/proc/proc_net.c b/fs/proc/proc_net.c
index dbcf87a257e1..df5484813d5d 100644
--- a/fs/proc/proc_net.c
+++ b/fs/proc/proc_net.c
@@ -410,7 +410,13 @@ out:
 
 static __net_exit void proc_net_ns_exit(struct net *net)
 {
+	struct proc_dir_entry *left;
+
 	remove_proc_entry("stat", net->proc_net);
+	/* Whatever is left still points at net->proc_net and so at net. */
+	left = rb_entry_safe(rb_first(&net->proc_net->subdir),
+			     struct proc_dir_entry, subdir_node);
+	WARN(left, "/proc/net: leaking at least '%s'\n", left->name);
 	pde_free(net->proc_net);
 }
 

-- 
2.53.0

