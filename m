Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.remote-ip=100.103.45.18
ARC-Seal: i=1; d=subspace.kernel.org; s=arc20261015; a=rsa-sha256; cv=none;
	t=1793822347;
	b=PRRHNmKVCLCV5q5Ske3koVxLZQQ6G9rfLtefwnDxSX7/0tUkzXDsOlUCFSeJBBlGj6TQ
	 eBqFv2EhqfO5cu8HWvuktZQ483F5MwtZaRAynJYDkfA6Y4nUvIeVn9bQOAOAHCW5Hez4S
	 D7aVcOWWhC6RTCL4Jmw5WcwRfrF0N9FMXu9wfUD6o7Y+3e7EgYE9sFQ7kwOSgI7mLxb03
	 D1boqAr4LNiFqLrNhYylWJc/YYNsjcTRc7kucVad5ZPeEhYdT26z+MW3J/qj1HIu8KA2L
	 XbltU2OK/JXKA6VaLJlOSZrHgXz+BqSqxIbVkjI2CYA5MDKOnLhWlHVO7fEJR1MNbLQ==
ARC-Message-Signature: i=1; d=subspace.kernel.org; s=arc20261015;
	a=rsa-sha256; c=relaxed/relaxed; t=1793822347;
	h=Received:DKIM-Signature:From:To:Cc:Subject:Date:Message-ID:
	 In-Reply-To:References:MIME-Version:Content-Type:X-Mailer:
	 X-Developer-Signature:X-Developer-Key:Content-Transfer-Encoding;
	bh=Q3KuHwYfVxA2BKW9aXWNrUpzpjPKgJiiNONww6sd1HY=;
	b=MOo4mr9fCiKjuEPLqzhXypaJCSYc7sK8pyq8Z1GaOiNgzOPHuutaxHP2faFRRntbdgDc
	 b7Rr7CyCOaEvGytRSjFlDKgXvC3MhAkcnaKHKYRRNV3DY9VEUgMyuixuu0hHK0XI/byAA
	 37Bwho1hSRalylx8zqsjYAO5KzIZYsyVbUJPDWocJzNtrHmOlhcOrzoqwJ4v9EwU/xNtd
	 T77oFS9cCUDHD93YlcU08VLwA17fD7Z6IIlFkMbujmZg4MJTQNR90h9IvpeYFpP3Wh9Gr
	 DX3++OqHtg9RcEMYVJLPHz40MjE2+u7Tc4HOFYZCd/1skHIPjVFus4GCtyO19qaCeKQ==
ARC-Authentication-Results: i=1; smtp.subspace.kernel.org; 
	dkim=pass header.d=kernel.org header.i=@kernel.org header.a=rsa-sha256 header.s=k20260515 header.b=KuEw75ZJ;
	arc=none smtp.remote-ip=100.103.45.18
Received: from smtp.kernel.org (quasi.space.kernel.org [100.103.45.18])
	(using TLSv1.3 with cipher TLS_AES_256_GCM_SHA384 (256/256 bits)
	 key-exchange X25519 server-signature ECDSA (prime256v1))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 27CA760A3429;
	Wed,  4 Nov 2026 19:59:06 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key, unprotected) header.d=kernel.org header.i=@kernel.org header.a=rsa-sha256 header.s=k20260515 header.b=KuEw75ZJ
Received: by smtp.kernel.org (Postfix) with ESMTPSA id 044D51F00919;
	Wed,  4 Nov 2026 19:58:54 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=kernel.org;
	s=k20260515; t=1793822346;
	bh=Q3KuHwYfVxA2BKW9aXWNrUpzpjPKgJiiNONww6sd1HY=;
	h=From:To:Cc:Subject:Date:In-Reply-To:References;
	b=KuEw75ZJhJWFk4/5j/u2bOa+7AhH2+fwulBHYqhzPzRCBHuO79mUpmvrjD0ahvKTk
	 tMMZB0uhduFqD7adhZiOSmSX6H7pUU+Iz/7fWtjCvnMrG3tjuNjl57qfHN8JLiB+Oq
	 Rm3Oh0NCtCkqXkQz/53JQM+5nP4aVm6NoL6aw41ZGwVH+gIjQScKsibl7t28PMzX8J
	 Relz0swIFmj1/UzelogqSD10+6zvUTgti41r7AxT6l0SRAeqLuXeHIz+lQBCMEudJ8
	 D0gnjIUhzk1S8cbTK7duy1QIkzoOq9EjAM3ep+eRVQ08x7iwdviy9H2Isj/FwB5UIH
	 +hsUDCjAUPclg==
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
Subject: [PATCH RESEND v2 05/13] netfilter: xt_recent: let procfs copy in writes
Date: Wed,  4 Nov 2026 20:58:52 +0100
Message-ID: <20261104-work-procfs-net-v2-5-221e2437fed1@kernel.org>
In-Reply-To: <20261104-work-procfs-net-v2-0-221e2437fed1@kernel.org>
References: <20261104-work-procfs-net-v2-0-221e2437fed1@kernel.org>
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
X-Developer-Signature: v=1; a=openpgp-sha256; l=1724; i=brauner@kernel.org; h=from:subject:message-id; bh=gfCX4go650si/jmePs4ghyuoQlNEiWKnWuOHaoexE2I=; b=owGbwMvMwCU28Zj0gdSKO4sYT6slMWS97tPgfnpmuaqac2LLJosupqrIeQbiDbdNDT4dmvzo/ DFR21+WHaUsDGJcDLJiiiwO7Sbhcst5KjYbZWrAzGFlAhnCwMUpABPpn8vIMOlw/R+eP/7CM+xs f+8t/fr+Wv4HSZ077vpfLO+H/1bx0WL4n5Sf/jFhe7/3hinn+vZsSZ0htMuiNFR9e88x7jnfa+s e8QAA
X-Developer-Key: i=brauner@kernel.org; a=openpgp; fpr=4880B8C9BD0E5106FC070F4F7B3C391EFEA93624
Content-Transfer-Encoding: 8bit

Implement ->proc_write_buf() so procfs copies in what is written to
/proc/net/xt_recent/<table> before it pins the entry, and take the
address from that copy. The removal of a table runs under recent_mutex
and doesn't wait for a writer that faults on its buffer anymore. Writes
larger than PAGE_SIZE - 1 bytes fail with -EINVAL now.

Signed-off-by: Christian Brauner (Amutable) <brauner@kernel.org>
---
 net/netfilter/xt_recent.c | 8 +++-----
 1 file changed, 3 insertions(+), 5 deletions(-)

diff --git a/net/netfilter/xt_recent.c b/net/netfilter/xt_recent.c
index a43fff5308da..72407eeaa9a6 100644
--- a/net/netfilter/xt_recent.c
+++ b/net/netfilter/xt_recent.c
@@ -553,8 +553,7 @@ static int recent_seq_open(struct inode *inode, struct file *file)
 }
 
 static ssize_t
-recent_mt_proc_write(struct file *file, const char __user *input,
-		     size_t size, loff_t *loff)
+recent_mt_proc_write(struct file *file, char *input, size_t size, loff_t *loff)
 {
 	struct recent_table *t = pde_data(file_inode(file));
 	struct recent_entry *e;
@@ -568,8 +567,7 @@ recent_mt_proc_write(struct file *file, const char __user *input,
 		return 0;
 	if (size > sizeof(buf))
 		size = sizeof(buf);
-	if (copy_from_user(buf, input, size) != 0)
-		return -EFAULT;
+	memcpy(buf, input, size);
 
 	/* Strict protocol! */
 	if (*loff != 0)
@@ -625,7 +623,7 @@ static const struct proc_ops recent_mt_proc_ops = {
 	.proc_seq_ops	= &recent_seq_ops,
 	.proc_state_size = sizeof(struct recent_iter_state),
 	.proc_open	= recent_seq_open,
-	.proc_write	= recent_mt_proc_write,
+	.proc_write_buf	= recent_mt_proc_write,
 };
 
 static int __net_init recent_proc_net_init(struct net *net)

-- 
2.53.0

