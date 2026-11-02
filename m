Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.remote-ip=100.103.45.18
ARC-Seal: i=1; d=subspace.kernel.org; s=arc20261015; a=rsa-sha256; cv=none;
	t=1793633596;
	b=Q9Kmc4OJfGbsXwm+5RpvZNtZ5BGe/lpqlda/dpfR37vwfdwkgbzKXebYRE4Lqybbf7Q0
	 F/9tVfOk/xf/uaQprhYCUBsKiQmmxqmVKTLGfK44dWPrUnURVhY3BCxg/aBj8loeKVGIL
	 u0qAnAeN3vwrhEwErCWTvLPc5zkFvKdmiVnsGP+33gCbEj1wrRTKJdcXOs4cqJBZAATcz
	 xBy4tWBqztzq9Nlb2lDWBP5fzVRPnHTw7bv6NZWZxNqeoR73SIYEHjY8n8rT104HyehZH
	 /UA9/D85BbaddntEvQ9HlV5mUiE+i1GIjtOquSfwRaQnp9n7KDLXoiyijXvf4B6DeKA==
ARC-Message-Signature: i=1; d=subspace.kernel.org; s=arc20261015;
	a=rsa-sha256; c=relaxed/relaxed; t=1793633596;
	h=Received:DKIM-Signature:From:Date:Subject:MIME-Version:Content-Type:
	 Content-Transfer-Encoding:Message-Id:References:In-Reply-To:To:Cc:
	 X-Mailer:X-Developer-Signature:X-Developer-Key;
	bh=I87aXd9DKn5INMWxVGI3L3LJev8psccpA6qjKtl7++0=;
	b=k6m+u6SwSayyhoI6ku4z3b/5m54KVB2N+izyIdQbmdsnr9FghM5MLM224kcNJQalAtD/
	 pLR+NHKUlvVTfIEtcr6fuVd349eVTFgGZFJWasnThsIQl1jN5jXWx2o1wd2yEvkJxJ2jA
	 FBRsKo3eb06cIZCDY3G25XucoOP5aukDU8NWu18lF7RZJ+Xc/GhjAI6lVr4lDNON4RsPr
	 9kuqZQNeVlvKMaEBw3bsDdnk/dLvbX2Kl8Zb5Q+GbZgjJc5r/hBo2KH/DFlf9gtpSnKNO
	 T3rsBIbTlkn2VNhm5Q2wFlRznElOUPP0uzEIOk4bqEPYflrxOFgvXvnlyUk1C3h7jAw==
ARC-Authentication-Results: i=1; smtp.subspace.kernel.org; 
	dkim=pass header.d=kernel.org header.i=@kernel.org header.a=rsa-sha256 header.s=k20260515 header.b=lY4jcv6k;
	arc=none smtp.remote-ip=100.103.45.18
Received: from smtp.kernel.org (quasi.space.kernel.org [100.103.45.18])
	(using TLSv1.3 with cipher TLS_AES_256_GCM_SHA384 (256/256 bits)
	 key-exchange X25519 server-signature ECDSA (prime256v1))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id F11E8608A35C;
	Mon,  2 Nov 2026 15:33:15 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key, unprotected) header.d=kernel.org header.i=@kernel.org header.a=rsa-sha256 header.s=k20260515 header.b=lY4jcv6k
Received: by smtp.kernel.org (Postfix) with ESMTPSA id A99BA1F00A17;
	Mon,  2 Nov 2026 15:32:56 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=kernel.org;
	s=k20260515; t=1793633595;
	bh=I87aXd9DKn5INMWxVGI3L3LJev8psccpA6qjKtl7++0=;
	h=From:Date:Subject:References:In-Reply-To:To:Cc;
	b=lY4jcv6krIB7tSgezJZ0V+JS72cdUlJSNkPro3CnXcMDEMbA71z5fLxOwnxG5iNkC
	 rp3t+Brf19zrcUHbxB4mEw/GXvOdm1oi2xkw2hpPnVuKqF63DhYCdo+P7KrF0k9ySw
	 q3WnWWnNPvOQjnIIlISDoS4h+NGj1NrV2Jh1P/jEmiGYv49kocMRPrjiUdBmefuqET
	 1ShVqFtZ3SJTeboI3TL14lRgICjngxPE349v7hPpsjveDK6gezuIAK+69D9q6LdAv9
	 73twS08QrRhGo6PjTHEfdslbb4r0jzOEE8UMiaU6s9+19ZD/+9Ub+CAZVV3kngpDqS
	 WLDxb1Y0Pf41w==
From: Christian Brauner <brauner@kernel.org>
Date: Mon, 02 Nov 2026 16:07:21 +0100
Subject: [PATCH RFC 07/11] SUNRPC: let procfs copy in writes
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
Message-Id: <20261102-work-procfs-net-v1-7-982104a4f592@kernel.org>
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
X-Developer-Signature: v=1; a=openpgp-sha256; l=6349; i=brauner@kernel.org;
 h=from:subject:message-id; bh=qIHvvtDF4hd5tLnMryapPJOuLcFfYH/7YZBGB4Dja6Y=;
 b=owGbwMvMwCU28Zj0gdSKO4sYT6slMWS9WG7CdjuxYNKH1PsxikWnjN8tZPqx7Tq7i8/lCrHdJ
 97HOtSLdZSyMIhxMciKKbI4tJuEyy3nqdhslKkBM4eVCWQIAxenAExE8xXD/9jUmsqIIw9en38y
 Z8Vu48gvWjue7r2yq9U2dybrZ1vjReyMDFdXTv0uWTl90SWl4+aLZwnG1ttwHbg+V1jiwIy/pZo
 V97kA
X-Developer-Key: i=brauner@kernel.org; a=openpgp;
 fpr=4880B8C9BD0E5106FC070F4F7B3C391EFEA93624

Implement ->proc_write_buf() for the procfs channel, flush and
use-gss-proxy files so procfs copies in what is written before it pins
the entry. The channel file parses the downcall from that copy and the
flush files share the parsing with rpc_pipefs in do_write_flush(). The
rpc_pipefs files keep copying in themselves.

CACHE_DOWNCALL_MAX and CACHE_FLUSH_MAX name the limits both sides
enforce, procfs through ->proc_write_size. The procfs files are removed
when the network namespace goes away and that no longer waits for a
writer that faults on its buffer.

Signed-off-by: Christian Brauner (Amutable) <brauner@kernel.org>
---
 net/sunrpc/auth_gss/svcauth_gss.c | 10 +++----
 net/sunrpc/cache.c                | 63 +++++++++++++++++++++++++++------------
 2 files changed, 48 insertions(+), 25 deletions(-)

diff --git a/net/sunrpc/auth_gss/svcauth_gss.c b/net/sunrpc/auth_gss/svcauth_gss.c
index 43839e805531..8d105cd900d4 100644
--- a/net/sunrpc/auth_gss/svcauth_gss.c
+++ b/net/sunrpc/auth_gss/svcauth_gss.c
@@ -1408,8 +1408,8 @@ svcauth_gss_proc_init(struct svc_rqst *rqstp, struct rpc_gss_wire_cred *gc)
 
 #ifdef CONFIG_PROC_FS
 
-static ssize_t write_gssp(struct file *file, const char __user *buf,
-			 size_t count, loff_t *ppos)
+static ssize_t write_gssp(struct file *file, char *buf, size_t count,
+			  loff_t *ppos)
 {
 	struct net *net = pde_data(file_inode(file));
 	char tbuf[20];
@@ -1418,9 +1418,7 @@ static ssize_t write_gssp(struct file *file, const char __user *buf,
 
 	if (*ppos || count > sizeof(tbuf)-1)
 		return -EINVAL;
-	if (copy_from_user(tbuf, buf, count))
-		return -EFAULT;
-
+	memcpy(tbuf, buf, count);
 	tbuf[count] = 0;
 	res = kstrtoul(tbuf, 0, &i);
 	if (res)
@@ -1468,7 +1466,7 @@ static ssize_t read_gssp(struct file *file, char __user *buf,
 
 static const struct proc_ops use_gss_proxy_proc_ops = {
 	.proc_open	= nonseekable_open,
-	.proc_write	= write_gssp,
+	.proc_write_buf	= write_gssp,
 	.proc_read	= read_gssp,
 };
 
diff --git a/net/sunrpc/cache.c b/net/sunrpc/cache.c
index 007521e8a57f..a257598768fa 100644
--- a/net/sunrpc/cache.c
+++ b/net/sunrpc/cache.c
@@ -924,6 +924,9 @@ static ssize_t cache_do_downcall(char *kaddr, const char __user *buf,
 	return ret;
 }
 
+/* 32k is max userland buffer, lets check anyway */
+#define CACHE_DOWNCALL_MAX	(32768 - 1)
+
 static ssize_t cache_downcall(struct address_space *mapping,
 			      const char __user *buf,
 			      size_t count, struct cache_detail *cd)
@@ -931,7 +934,7 @@ static ssize_t cache_downcall(struct address_space *mapping,
 	char *write_buf;
 	ssize_t ret = -ENOMEM;
 
-	if (count >= 32768) { /* 32k is max userland buffer, lets check anyway */
+	if (count > CACHE_DOWNCALL_MAX) {
 		ret = -EINVAL;
 		goto out;
 	}
@@ -1508,19 +1511,15 @@ static ssize_t read_flush(struct file *file, char __user *buf,
 	return simple_read_from_buffer(buf, count, ppos, tbuf, len);
 }
 
-static ssize_t write_flush(struct file *file, const char __user *buf,
-			   size_t count, loff_t *ppos,
-			   struct cache_detail *cd)
+/* longest number the flush files take */
+#define CACHE_FLUSH_MAX		19
+
+static ssize_t do_write_flush(char *tbuf, size_t count, loff_t *ppos,
+			      struct cache_detail *cd)
 {
-	char tbuf[20];
 	char *ep;
 	time64_t now;
 
-	if (*ppos || count > sizeof(tbuf)-1)
-		return -EINVAL;
-	if (copy_from_user(tbuf, buf, count))
-		return -EFAULT;
-	tbuf[count] = 0;
 	simple_strtoul(tbuf, &ep, 0);
 	if (*ep && *ep != '\n')
 		return -EINVAL;
@@ -1551,6 +1550,20 @@ static ssize_t write_flush(struct file *file, const char __user *buf,
 	return count;
 }
 
+static ssize_t write_flush(struct file *file, const char __user *buf,
+			   size_t count, loff_t *ppos,
+			   struct cache_detail *cd)
+{
+	char tbuf[CACHE_FLUSH_MAX + 1];
+
+	if (*ppos || count > CACHE_FLUSH_MAX)
+		return -EINVAL;
+	if (copy_from_user(tbuf, buf, count))
+		return -EFAULT;
+	tbuf[count] = 0;
+	return do_write_flush(tbuf, count, ppos, cd);
+}
+
 static ssize_t cache_read_procfs(struct file *filp, char __user *buf,
 				 size_t count, loff_t *ppos)
 {
@@ -1559,12 +1572,21 @@ static ssize_t cache_read_procfs(struct file *filp, char __user *buf,
 	return cache_read(filp, buf, count, ppos, cd);
 }
 
-static ssize_t cache_write_procfs(struct file *filp, const char __user *buf,
-				  size_t count, loff_t *ppos)
+/* procfs copied in what was written */
+static ssize_t cache_write_procfs(struct file *filp, char *buf, size_t count,
+				  loff_t *ppos)
 {
 	struct cache_detail *cd = pde_data(file_inode(filp));
+	struct inode *inode = file_inode(filp);
+	ssize_t ret;
 
-	return cache_write(filp, buf, count, ppos, cd);
+	if (!cd->cache_parse || !count)
+		return -EINVAL;
+
+	inode_lock(inode);
+	ret = cd->cache_parse(cd, buf, count);
+	inode_unlock(inode);
+	return ret ? ret : count;
 }
 
 static __poll_t cache_poll_procfs(struct file *filp, poll_table *wait)
@@ -1599,7 +1621,8 @@ static int cache_release_procfs(struct inode *inode, struct file *filp)
 
 static const struct proc_ops cache_channel_proc_ops = {
 	.proc_read	= cache_read_procfs,
-	.proc_write	= cache_write_procfs,
+	.proc_write_buf	= cache_write_procfs,
+	.proc_write_size = CACHE_DOWNCALL_MAX,
 	.proc_poll	= cache_poll_procfs,
 	.proc_ioctl	= cache_ioctl_procfs, /* for FIONREAD */
 	.proc_open	= cache_open_procfs,
@@ -1653,19 +1676,21 @@ static ssize_t read_flush_procfs(struct file *filp, char __user *buf,
 	return read_flush(filp, buf, count, ppos, cd);
 }
 
-static ssize_t write_flush_procfs(struct file *filp,
-				  const char __user *buf,
-				  size_t count, loff_t *ppos)
+static ssize_t write_flush_procfs(struct file *filp, char *buf, size_t count,
+				  loff_t *ppos)
 {
 	struct cache_detail *cd = pde_data(file_inode(filp));
 
-	return write_flush(filp, buf, count, ppos, cd);
+	if (*ppos)
+		return -EINVAL;
+	return do_write_flush(buf, count, ppos, cd);
 }
 
 static const struct proc_ops cache_flush_proc_ops = {
 	.proc_open	= open_flush_procfs,
 	.proc_read	= read_flush_procfs,
-	.proc_write	= write_flush_procfs,
+	.proc_write_buf	= write_flush_procfs,
+	.proc_write_size = CACHE_FLUSH_MAX,
 	.proc_release	= release_flush_procfs,
 };
 

-- 
2.53.0

