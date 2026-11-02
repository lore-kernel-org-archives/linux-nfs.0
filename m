Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.remote-ip=100.103.45.18
ARC-Seal: i=1; d=subspace.kernel.org; s=arc20261015; a=rsa-sha256; cv=none;
	t=1793633464;
	b=SmziQuQzeZc5596GKewkecS8D34GyMa6baxvX6e+ryt/WWSoAkMI0rmgZL1oIa4/Z+ER
	 AdYrJ/sZnGfcu3B7iOMu7d+2AiJ/SkRgbvtW8PStoEyAdXtpTEUTCoXqi2nv5boQBzXHp
	 9xP3OWKq6f+n+nruRbDUWdiFDmZ24MTYdk0j8UXN7cCprwYdUGmJOl8kDLrOzBYhQNMiG
	 4DpBJs58Wr/mVJsu4yxvjFMFd9K+WgChUtmARYt2iYJ5uBaW7NLOUxcBvVcwyYXlJ7Vh1
	 kou+sjruNyMi1BJFkMA6S6ANTStsAaR02hlgg90s8U0k0L+FKmKdhYZNfnjV4OKtZTg==
ARC-Message-Signature: i=1; d=subspace.kernel.org; s=arc20261015;
	a=rsa-sha256; c=relaxed/relaxed; t=1793633464;
	h=Received:DKIM-Signature:From:Date:Subject:MIME-Version:Content-Type:
	 Content-Transfer-Encoding:Message-Id:References:In-Reply-To:To:Cc:
	 X-Mailer:X-Developer-Signature:X-Developer-Key;
	bh=8JYviDqoWsEGN3uNb5Mh66eaw6snQ2TUUnHcmJoMJ80=;
	b=sKxucAwjEUciMP69dc3xN67OjLMuzJSKtWfN0aeukZJ+BMyr50y2pf86IF0KVebHRrxs
	 frOja9U4kFQCieiVVseM1AaGTRtkT1yzXkoJm2F5pgiQS+CpNdHDUrEmr2wOcfbAyBR9/
	 yky4pcSfuEYXSF1KvkMOV6k7BBwUIHbucJGq+Iru+pcD9iIjuJwgMBpDx2O+xVFKmPyuL
	 VlHZAAJ1nCyW6u3K7uINXpN+Ynb2+mM1QA16751ycK3oDxjYVuZN83dXREhdUpGvdoYsI
	 8cyieD4URxNXxKE21RH5dhoXpm4SybGpY3dXrUll43SAzZUPARoRgBIUa3QoYq4Perw==
ARC-Authentication-Results: i=1; smtp.subspace.kernel.org; 
	dkim=pass header.d=kernel.org header.i=@kernel.org header.a=rsa-sha256 header.s=k20260515 header.b=ScTRyul4;
	arc=none smtp.remote-ip=100.103.45.18
Received: from smtp.kernel.org (quasi.space.kernel.org [100.103.45.18])
	(using TLSv1.3 with cipher TLS_AES_256_GCM_SHA384 (256/256 bits)
	 key-exchange X25519 server-signature ECDSA (prime256v1))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id D6746606ABB3;
	Mon,  2 Nov 2026 15:31:03 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key, unprotected) header.d=kernel.org header.i=@kernel.org header.a=rsa-sha256 header.s=k20260515 header.b=ScTRyul4
Received: by smtp.kernel.org (Postfix) with ESMTPSA id A6FC01F00A16;
	Mon,  2 Nov 2026 15:30:42 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=kernel.org;
	s=k20260515; t=1793633463;
	bh=8JYviDqoWsEGN3uNb5Mh66eaw6snQ2TUUnHcmJoMJ80=;
	h=From:Date:Subject:References:In-Reply-To:To:Cc;
	b=ScTRyul4UqS1mWJvOzmwvwPQ//Itx9TsdsxsJwGYb3Gmm/J0WkPfUMLBfXwRwQRsr
	 Nim+Y+d24g3hKICsmz4+hJ76wRo71Zgu8JYSNQex1bY6jYxc4yR4NIKTkU/b0bzekF
	 oTZ8Mqaf/qJiOTrQ3fVHdV5XUUZFZ9Rv79SVAaVRi4pTwuCDqET0rxCczTm7RhsOI9
	 GL2XYnYI3rKEga2Ls6G2iIhPzet32Cl17pJvVFcx5D8ihh7MkSTm+FLpZqjgFDVWCL
	 7PucMdluq4M256zUScAZVO6B7k8GrovbDY4lddqqcnnXFtmxqpelNIoflJ7mv/9GqF
	 EQVHm3m/21Cfg==
From: Christian Brauner <brauner@kernel.org>
Date: Mon, 02 Nov 2026 16:07:15 +0100
Subject: [PATCH RFC 01/11] atm: let procfs copy out reads of the device
 files
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
Message-Id: <20261102-work-procfs-net-v1-1-982104a4f592@kernel.org>
References: <20261102-work-procfs-net-v1-0-982104a4f592@kernel.org>
In-Reply-To: <20261102-work-procfs-net-v1-0-982104a4f592@kernel.org>
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
X-Developer-Signature: v=1; a=openpgp-sha256; l=1517; i=brauner@kernel.org;
 h=from:subject:message-id; bh=gPjf1XFsI8l/uiq7gtBYaOS5PIZm1WCyT/xvmcgXYrk=;
 b=owGbwMvMwCU28Zj0gdSKO4sYT6slMWS9WG78cE1u8seuk/K3unk+6P7jWeW5b87CvLufg14ar
 jS+H74/oKOUhUGMi0FWTJHFod0kXG45T8Vmo0wNmDmsTCBDGLg4BWAis2UYGeay2p/6sZbx0Dzp
 lNKfYqc/nLPyU7XaNW1f+AvTfu35FjsYGdonXm11v5fkNuWfeN7rc08f7rarf8sV6GTp9Xk23+y
 Xx3kB
X-Developer-Key: i=brauner@kernel.org; a=openpgp;
 fpr=4880B8C9BD0E5106FC070F4F7B3C391EFEA93624

Implement ->proc_read_buf() so procfs copies what is read from
/proc/net/atm/<dev> to userspace after it unpinned the entry. The
drivers' ->proc_read() keep filling their page.

Signed-off-by: Christian Brauner (Amutable) <brauner@kernel.org>
---
 net/atm/proc.c | 9 ++++-----
 1 file changed, 4 insertions(+), 5 deletions(-)

diff --git a/net/atm/proc.c b/net/atm/proc.c
index ca0fc6b90998..cea930b4b840 100644
--- a/net/atm/proc.c
+++ b/net/atm/proc.c
@@ -30,11 +30,11 @@
 #include "resources.h"
 #include "common.h" /* atm_proc_init prototype */
 
-static ssize_t proc_dev_atm_read(struct file *file, char __user *buf,
+static ssize_t proc_dev_atm_read(struct file *file, char *buf,
 				 size_t count, loff_t *pos);
 
 static const struct proc_ops atm_dev_proc_ops = {
-	.proc_read	= proc_dev_atm_read,
+	.proc_read_buf	= proc_dev_atm_read,
 	.proc_lseek	= noop_llseek,
 };
 
@@ -246,7 +246,7 @@ static const struct seq_operations vcc_seq_ops = {
 	.show	= vcc_seq_show,
 };
 
-static ssize_t proc_dev_atm_read(struct file *file, char __user *buf,
+static ssize_t proc_dev_atm_read(struct file *file, char *buf,
 				 size_t count, loff_t *pos)
 {
 	struct atm_dev *dev;
@@ -267,8 +267,7 @@ static ssize_t proc_dev_atm_read(struct file *file, char __user *buf,
 			length = -EINVAL;
 	}
 	if (length >= 0) {
-		if (copy_to_user(buf, (char *)page, length))
-			length = -EFAULT;
+		memcpy(buf, (char *)page, length);
 		(*pos)++;
 	}
 	free_page(page);

-- 
2.53.0

