Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.remote-ip=100.103.45.18
ARC-Seal: i=1; d=subspace.kernel.org; s=arc20261015; a=rsa-sha256; cv=none;
	t=1793632830;
	b=5fdiGbtyJGEIe44PJ70Wrqg15UGikdNvDRbusnad64aUWxexkj7GuddbJT7FzpOsBGdC
	 gt8wc72EBitUWKn40doBSCLqt84nSIQedcU6ncslEifjab4NX3Xdji7cBZX1RmOHuqxyO
	 IdCRQmnnkYzkOS+grBDt3pzraEah0tCjuJhUjOAXsMA2a1RKt036e5eEVviwVqIjc+/Ug
	 AhyJ+BKJ37/oMEnezlEYg4O9qOUsDHuzvZ7AkfFpL1Km5bZm3L534MbOadEdCBwb3Jppe
	 9V5s7KQxa0hfqd/8nnQxeb4euVz84vrjIxankhEAWZuV0lyQ6cvinzTQ3aJkm2iJQjg==
ARC-Message-Signature: i=1; d=subspace.kernel.org; s=arc20261015;
	a=rsa-sha256; c=relaxed/relaxed; t=1793632830;
	h=Received:DKIM-Signature:From:Date:Subject:MIME-Version:Content-Type:
	 Content-Transfer-Encoding:Message-Id:References:In-Reply-To:To:Cc:
	 X-Mailer:X-Developer-Signature:X-Developer-Key;
	bh=yfb68sR2lkv/WstwrNi2kV1cVJpZCk5/QcENUoLv//k=;
	b=unkcPFsNa2+3HcYh0LAfiTowMru1F1Qp4HuyQlB+blcxtVML0fb+B+gx2htZQSES9mWe
	 S8A/dMGga6gSBvea+wSH+QmoIIPL+ZtbP+LN5DDub99hjrR2Z8rIuLp98zK9vQwINtvru
	 onuIWdT8fWQ2/FXeQ4bOva5R1IQwrhiXDB/LRMi3AIb84KpMZ/kCYK7lxIce5tsskfIKR
	 cZr+L//yxZW0mmklMZCyc2vTtR0ZfDEhCgSBnEOS3MOacw+Dca72jJAkgPe6NVK88Davn
	 mGwemVBk7xWV4e2IyFerazL05fUAg7DZdRLi+V2nYnlcCeJfIam08I7soOjt/gx5fSA==
ARC-Authentication-Results: i=1; smtp.subspace.kernel.org; 
	dkim=pass header.d=kernel.org header.i=@kernel.org header.a=rsa-sha256 header.s=k20260515 header.b=BN1DryDe;
	arc=none smtp.remote-ip=100.103.45.18
Received: from smtp.kernel.org (quasi.space.kernel.org [100.103.45.18])
	(using TLSv1.3 with cipher TLS_AES_256_GCM_SHA384 (256/256 bits)
	 key-exchange X25519 server-signature ECDSA (prime256v1))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 0D170609622F;
	Mon,  2 Nov 2026 15:20:29 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key, unprotected) header.d=kernel.org header.i=@kernel.org header.a=rsa-sha256 header.s=k20260515 header.b=BN1DryDe
Received: by smtp.kernel.org (Postfix) with ESMTPSA id D70991F00A18;
	Mon,  2 Nov 2026 15:20:12 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=kernel.org;
	s=k20260515; t=1793632829;
	bh=yfb68sR2lkv/WstwrNi2kV1cVJpZCk5/QcENUoLv//k=;
	h=From:Date:Subject:References:In-Reply-To:To:Cc;
	b=BN1DryDe3qV+C4aWHJuIRcQk7/grenL2yY2/u1V9RuZ76eccMjBgLsEcUTNnhaGbx
	 eXhhwX7Vgu+zR+JmG/2wvin1dOiYZvsWSYg6kfl1F4CTtJJewyZhllNVl1QPSHankI
	 Y/8n3DCOX6o11uevej4+0kaVGNpGzwrrLFwkHxO8Xf20op7zpFONM4MND0dOsyrGS9
	 lt+VjVHm27V5kG1yhzDMUWKDR0YRqKdDimg5wHtncjttH7DdkNFA88vxAFcS8nd5HC
	 WE2enuopE0QMfUuIQi9FBTnJNj/5vBq/jOfhCbxPWlMeXV21MywGi2MtjhSPk+gxJF
	 /V1HSYuIItaBw==
From: Christian Brauner <brauner@kernel.org>
Date: Mon, 02 Nov 2026 16:07:13 +0100
Subject: [PATCH RFC 03/27] lockd: let procfs copy in writes to
 nlm_end_grace
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
Message-Id: <20261102-work-procfs-fs-v1-3-d09a996317b3@kernel.org>
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
X-Developer-Signature: v=1; a=openpgp-sha256; l=1756; i=brauner@kernel.org;
 h=from:subject:message-id; bh=yoBjzpwXPCFL2mmsMcO6fDyZh19yBZX5M0Ko6zu/SW0=;
 b=owGbwMvMwCU28Zj0gdSKO4sYT6slMWS9WG4otvP03RvTPvA6+q/2CHm77dh8jlWRxmva3p208
 Ze+9//u4Y5SFgYxLgZZMUUWh3aTcLnlPBWbjTI1YOawMoEMYeDiFICJzFzD8JNRYNGmuUuv5fXJ
 SixnOtLlrT9xxidJDp7+ycnCGRxRXQ8Z/qlce21cuoK5yfPMxbQIy6ar6sn9zobuoRNUY3eHqBs
 eYwQA
X-Developer-Key: i=brauner@kernel.org; a=openpgp;
 fpr=4880B8C9BD0E5106FC070F4F7B3C391EFEA93624

Implement ->proc_write_buf() so procfs copies in what is written before
it pins the entry. simple_transaction_get() was only used to get a copy
of what was written, so look at procfs' copy instead and drop the
transaction. A second write to the same file doesn't fail with -EBUSY
anymore. Writes larger than PAGE_SIZE - 1 bytes fail with -EINVAL from
procfs instead of -EFBIG from simple_transaction_get(), which refused a
few bytes less.

Signed-off-by: Christian Brauner (Amutable) <brauner@kernel.org>
---
 fs/lockd/procfs.c | 13 +++----------
 1 file changed, 3 insertions(+), 10 deletions(-)

diff --git a/fs/lockd/procfs.c b/fs/lockd/procfs.c
index a01f08c8c2f3..47949bec7a09 100644
--- a/fs/lockd/procfs.c
+++ b/fs/lockd/procfs.c
@@ -18,21 +18,15 @@
  * We only allow strings that start with 'Y', 'y', or '1'.
  */
 static ssize_t
-nlm_end_grace_write(struct file *file, const char __user *buf, size_t size,
-		    loff_t *pos)
+nlm_end_grace_write(struct file *file, char *buf, size_t size, loff_t *pos)
 {
-	char *data;
 	struct lockd_net *ln = net_generic(current->nsproxy->net_ns,
 					   lockd_net_id);
 
 	if (size < 1)
 		return -EINVAL;
 
-	data = simple_transaction_get(file, buf, size);
-	if (IS_ERR(data))
-		return PTR_ERR(data);
-
-	switch(data[0]) {
+	switch(buf[0]) {
 	case 'Y':
 	case 'y':
 	case '1':
@@ -61,10 +55,9 @@ nlm_end_grace_read(struct file *file, char __user *buf, size_t size,
 }
 
 static const struct proc_ops lockd_end_grace_proc_ops = {
-	.proc_write	= nlm_end_grace_write,
+	.proc_write_buf	= nlm_end_grace_write,
 	.proc_read	= nlm_end_grace_read,
 	.proc_lseek	= default_llseek,
-	.proc_release	= simple_transaction_release,
 };
 
 int __init

-- 
2.53.0

