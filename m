Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.remote-ip=100.103.45.18
ARC-Seal: i=1; d=subspace.kernel.org; s=arc20261015; a=rsa-sha256; cv=none;
	t=1793633193;
	b=YFXPPo6EdJI+wwuCe3VAWOhnA+WG+8UKour0ybzwprgNGauOs3Zr2YfZhA63lNbSLG/Y
	 M5LqbPu7kFDgG0AuMgJi29mv556K4yNnAtTeAfueoq/Av1AYl0cCiCBiY2yj79B0Dl2rU
	 YHt4/4KCyqNS8UvEijbcx2Is6oEpjom5f3yaD8V50K9HyGEFJiTjF/2pItAFmLexu5lni
	 rhq4AZIilAgGJNMlXsd5n+hUEP2xfBRYKbmr+THiJPvQGBoObZhLypXlBllPJyjJRG/SV
	 DnyzKnUC0DJQcOSjQZJvAgx3LgeXDgIFEQAg3PHoZbNW0Yugi5exqWQN2he3lBc9QHQ==
ARC-Message-Signature: i=1; d=subspace.kernel.org; s=arc20261015;
	a=rsa-sha256; c=relaxed/relaxed; t=1793633193;
	h=Received:DKIM-Signature:From:Date:Subject:MIME-Version:Content-Type:
	 Content-Transfer-Encoding:Message-Id:References:In-Reply-To:To:Cc:
	 X-Mailer:X-Developer-Signature:X-Developer-Key;
	bh=R1VqjUGL5+J0t5hj5seZeRe1Maiv3S9hp7Jj5OG0/0s=;
	b=g1zhUEHnQNG2C5NNskomrOOCO9DmdTN4BPO/owuhVm2XrTavaNc6Yz851nskw5di9VH7
	 kIfH4zlQdd3gpOl6MlWAqQioIggbxCFO6boz/lZOeTPPILRgaIJP3KzPSXvK2tJc7cPRu
	 jJsHR15/LQcnA5RutiVubHQO+df9qshrflP0QkMW1WSJK6ZlINS0H/PPm6hdWSenVOjHr
	 2Px0uPSuNYNQlhlMUG0zxUTSX16Kgb0hfxBAHmJtxgMrvnOgVMsIW5dRMMdh+s3vJHv9l
	 Y9ExMjzL+MeIrfqnLc+RxuaO2p1kSNdz4NvCHujdSd+9ed5UfFbfx1O/hbV0qxKA7Rw==
ARC-Authentication-Results: i=1; smtp.subspace.kernel.org; 
	dkim=pass header.d=kernel.org header.i=@kernel.org header.a=rsa-sha256 header.s=k20260515 header.b=LPntUaej;
	arc=none smtp.remote-ip=100.103.45.18
Received: from smtp.kernel.org (quasi.space.kernel.org [100.103.45.18])
	(using TLSv1.3 with cipher TLS_AES_256_GCM_SHA384 (256/256 bits)
	 key-exchange X25519 server-signature ECDSA (prime256v1))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 171F06083601;
	Mon,  2 Nov 2026 15:26:33 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key, unprotected) header.d=kernel.org header.i=@kernel.org header.a=rsa-sha256 header.s=k20260515 header.b=LPntUaej
Received: by smtp.kernel.org (Postfix) with ESMTPSA id 3D7DB1F00A16;
	Mon,  2 Nov 2026 15:26:16 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=kernel.org;
	s=k20260515; t=1793633192;
	bh=R1VqjUGL5+J0t5hj5seZeRe1Maiv3S9hp7Jj5OG0/0s=;
	h=From:Date:Subject:References:In-Reply-To:To:Cc;
	b=LPntUaejzzAUOTRvUNS0Y1GMbnPApCWQqcTwI13UUCKXze90UPLxxpRnGW90okaRN
	 /SIo51jvsTdg8UsLHm4uePjBeYyLPk3KVJ4wuqLBYJhjSGrlhysCaMmn5I/CkJ1pd9
	 ZHTI/3+dLOQ6JzTqFxt6SjCj+4pjEdhhbPGoo6W+bAjQGlPVV4SQHQDv7/I/vWQIJ6
	 /fi/xyM0dOZwYg9ycwAhjjdk4lSHA97j+wFr9FXI3WUCvPAnDgHJoyNjjrjgyn1Ef4
	 i8wvejafrNc0aiVo0X6lBeVv6XILV8EgxhSfBWL+BkF8M9XALmyKKUOR1IJtwGwMO0
	 zz5ZY6ZT8QG2Q==
From: Christian Brauner <brauner@kernel.org>
Date: Mon, 02 Nov 2026 16:07:29 +0100
Subject: [PATCH RFC 19/27] kallsyms: let procfs own the seq_file of
 /proc/kallsyms
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
Message-Id: <20261102-work-procfs-fs-v1-19-d09a996317b3@kernel.org>
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
X-Developer-Signature: v=1; a=openpgp-sha256; l=1331; i=brauner@kernel.org;
 h=from:subject:message-id; bh=X1hXUo+P6dAEkQI4HVxBka/iuP3neD063cymPGxvXEU=;
 b=owGbwMvMwCU28Zj0gdSKO4sYT6slMWS9WG7E86Wn6bItX8PRGc932QRueyvG/7r7fdz1LQabT
 jt31lYxdZSyMIhxMciKKbI4tJuEyy3nqdhslKkBM4eVCWQIAxenAEwkdQkjQ2/ojiqupX4S/zNi
 eAuad2pzvL4hu4l32d2bRa7rPvysnMjIcOC061HJ9ce7zeXr+fWZln6azCZ4Zf56HXH9smbnqy8
 vsQMA
X-Developer-Key: i=brauner@kernel.org; a=openpgp;
 fpr=4880B8C9BD0E5106FC070F4F7B3C391EFEA93624

Declare the seq_operations and the size of the iterator and let procfs
open and free the seq_file. ->proc_open() only initializes the iterator
now.

Signed-off-by: Christian Brauner (Amutable) <brauner@kernel.org>
---
 kernel/kallsyms.c | 12 +++++-------
 1 file changed, 5 insertions(+), 7 deletions(-)

diff --git a/kernel/kallsyms.c b/kernel/kallsyms.c
index aec2f06858af..2d309fcee730 100644
--- a/kernel/kallsyms.c
+++ b/kernel/kallsyms.c
@@ -888,10 +888,9 @@ static int kallsyms_open(struct inode *inode, struct file *file)
 	 * s_start from where we left off, so we avoid doing
 	 * using get_symbol_offset for every symbol.
 	 */
-	struct kallsym_iter *iter;
-	iter = __seq_open_private(file, &kallsyms_op, sizeof(*iter));
-	if (!iter)
-		return -ENOMEM;
+	struct seq_file *m = file->private_data;
+	struct kallsym_iter *iter = m->private;
+
 	reset_iter(iter, 0);
 
 	/*
@@ -923,10 +922,9 @@ const char *kdb_walk_kallsyms(loff_t *pos)
 #endif	/* CONFIG_KGDB_KDB */
 
 static const struct proc_ops kallsyms_proc_ops = {
+	.proc_seq_ops	= &kallsyms_op,
+	.proc_state_size = sizeof(struct kallsym_iter),
 	.proc_open	= kallsyms_open,
-	.proc_read	= seq_read,
-	.proc_lseek	= seq_lseek,
-	.proc_release	= seq_release_private,
 };
 
 static int __init kallsyms_init(void)

-- 
2.53.0

