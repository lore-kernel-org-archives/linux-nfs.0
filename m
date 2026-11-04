Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.remote-ip=100.103.45.18
ARC-Seal: i=1; d=subspace.kernel.org; s=arc20261015; a=rsa-sha256; cv=none;
	t=1793822391;
	b=LArGfP2NOthhmClwrIzK0PPLzpxe+EOVvCSn1m7DWJi5qFZcW9HZVDaFZ1/97YVLgg30
	 ugPUdOwOfRyXUOWs6K+oPr8wFfUmVBDkQnitCDAwpxkgTvx89qG3HkZ2/zq3MtMcE5VhM
	 MBSLj+dtf+Zr0J+RiqOvRh1X5dkBnjw14HuGGdJ1QfhdEk0ymUXQ5iYrgj3AhO1DgWL4N
	 3cyJBerFjutkFhT4cFKAEInzyPGpEr5PEUKbq2R9f/snQwhEndJlI4Zp5orgbskhtWohd
	 LIU9fS/nyGr7osXBXcFOMo7yFniYD8sVUm9vh2PK9vLjGd0ekAlyhLYS6UscolywPUA==
ARC-Message-Signature: i=1; d=subspace.kernel.org; s=arc20261015;
	a=rsa-sha256; c=relaxed/relaxed; t=1793822391;
	h=Received:DKIM-Signature:From:To:Cc:Subject:Date:Message-ID:
	 In-Reply-To:References:MIME-Version:Content-Type:X-Mailer:
	 X-Developer-Signature:X-Developer-Key:Content-Transfer-Encoding;
	bh=TK360Q0J9loLLBJN1fCdf93Od8lfv7JQwcxqeqOSWBU=;
	b=e3dNc5tVrtgAimNx1sbp/Ipii1ZO+/LBDMm9gBf3b3jNqzWjkAu9DyzEqUOrR6MvwRfS
	 82fusI4D+LKvIWU3+tUWNJGIJfkPagjHZNz+o8Uo8rI3AhglHEDjOVtT2o9GJtAtpODmG
	 9Zv32jhMiU05nTNhsrcehQyIrlt3dzkkEwsjCaWL/hq7fmicL7SYPJaiCrKr5ssMLcc75
	 Ik016TeXr2wn0fTseUZlXYJ1U204tJauRf8wNDEg+pW5hqLG6GtK/XU2RjUXw5+DTqUE0
	 0CpsXhR+l9p257f8QZ6XIyAr23At12MvFnyuWDI6K0L/8o6VnxA5bw5OejH6pL3DcMA==
ARC-Authentication-Results: i=1; smtp.subspace.kernel.org; 
	dkim=pass header.d=kernel.org header.i=@kernel.org header.a=rsa-sha256 header.s=k20260515 header.b="HsZHTl/C";
	arc=none smtp.remote-ip=100.103.45.18
Received: from smtp.kernel.org (quasi.space.kernel.org [100.103.45.18])
	(using TLSv1.3 with cipher TLS_AES_256_GCM_SHA384 (256/256 bits)
	 key-exchange X25519 server-signature ECDSA (prime256v1))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id DF553606E4EC;
	Wed,  4 Nov 2026 19:59:50 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key, unprotected) header.d=kernel.org header.i=@kernel.org header.a=rsa-sha256 header.s=k20260515 header.b=HsZHTl/C
Received: by smtp.kernel.org (Postfix) with ESMTPSA id 7C4F11F00A1A;
	Wed,  4 Nov 2026 19:59:38 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=kernel.org;
	s=k20260515; t=1793822390;
	bh=TK360Q0J9loLLBJN1fCdf93Od8lfv7JQwcxqeqOSWBU=;
	h=From:To:Cc:Subject:Date:In-Reply-To:References;
	b=HsZHTl/CdmWyGe8xt7+n2y+V0Zxd4BVan3QtszkbfH+aM/LFOr4MxXy9YK1/s5czs
	 +uRkz05vFWtYUCaU7pPh8gj3GmgDMXdfISwaLxI3vX06w+My06KWNnliBRg5AsGOdX
	 Xx125EeC0wJoETAjZn8krCURNEVFn42PtwrobiAl6l6KcP0xYnXH6wuPz+ElscfREc
	 FdSFabwVoqWgLI+qt5Nl7K99WB8phk6fHiY1iEvhA19UVwEv2ahgR0X4myjp9uDRzY
	 e1CPpMwajhom9FvgOXKfxujK1+HvI3Qo1ESfmOqFwvfrH+E1uuu+sdr5U3pD03FzMf
	 h4KBsvAbrCoqw==
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
Subject: [PATCH RESEND v2 08/13] SUNRPC: let procfs copy out reads
Date: Wed,  4 Nov 2026 20:59:36 +0100
Message-ID: <20261104-work-procfs-net-v2-8-221e2437fed1@kernel.org>
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
X-Developer-Signature: v=1; a=openpgp-sha256; l=8375; i=brauner@kernel.org; h=from:subject:message-id; bh=a9MpcCErAr+XLynuyr8Lv5es65Jw33sURzMgM9R8Toc=; b=owGbwMvMwCU28Zj0gdSKO4sYT6slMWS97tPZk3Bgttr+L5ZtyXFXQ5NzY40SRHlzIt1DVPuXO Jz6ypXVUcLCIMbFICumyOLQbhIut5ynYrNRpgbMHFYmkCEMXJwCMJFvzQzf1D41f32TsHX91fUG d6W//1059etk7lNBKk9Pxc1WvSstxvDP4nnhKd4PC6PMj18/vupH7+yrLDnzZaeYs2kp7Z18s2o POwA=
X-Developer-Key: i=brauner@kernel.org; a=openpgp; fpr=4880B8C9BD0E5106FC070F4F7B3C391EFEA93624
Content-Transfer-Encoding: 8bit

Implement ->proc_read_buf() for the procfs channel, flush,
use-gss-proxy and gss_krb5_enctypes files so procfs copies what is read
to userspace after it unpinned the entry.

cache_read() takes an iov_iter now. The rpc_pipefs channel file passes
one for the user buffer and behaves like before. The procfs one passes
one for procfs' buffer, and a read still hands out at most one request.
A reader of the procfs channel file whose copy out fails, a readv()
with a bad later segment included, loses what was handed out, since the
request moves on before procfs copies it out. If that was only part of
a request the next read returns the rest of it. Both flush files share
flush_time_text().

The procfs files are removed when the network namespace goes away and
that no longer waits for a reader that faults on its buffer.

Signed-off-by: Christian Brauner (Amutable) <brauner@kernel.org>
---
 net/sunrpc/auth_gss/svcauth_gss.c | 24 ++++++-------------
 net/sunrpc/cache.c                | 50 +++++++++++++++++++++++----------------
 2 files changed, 36 insertions(+), 38 deletions(-)

diff --git a/net/sunrpc/auth_gss/svcauth_gss.c b/net/sunrpc/auth_gss/svcauth_gss.c
index 8d105cd900d4..67e086a7127c 100644
--- a/net/sunrpc/auth_gss/svcauth_gss.c
+++ b/net/sunrpc/auth_gss/svcauth_gss.c
@@ -1442,32 +1442,22 @@ static ssize_t write_gssp(struct file *file, char *buf, size_t count,
 	return count;
 }
 
-static ssize_t read_gssp(struct file *file, char __user *buf,
+static ssize_t read_gssp(struct file *file, char *buf,
 			 size_t count, loff_t *ppos)
 {
 	struct net *net = pde_data(file_inode(file));
 	struct sunrpc_net *sn = net_generic(net, sunrpc_net_id);
-	unsigned long p = *ppos;
 	char tbuf[10];
 	size_t len;
 
-	snprintf(tbuf, sizeof(tbuf), "%d\n", sn->use_gss_proxy);
-	len = strlen(tbuf);
-	if (p >= len)
-		return 0;
-	len -= p;
-	if (len > count)
-		len = count;
-	if (copy_to_user(buf, (void *)(tbuf+p), len))
-		return -EFAULT;
-	*ppos += len;
-	return len;
+	len = snprintf(tbuf, sizeof(tbuf), "%d\n", sn->use_gss_proxy);
+	return memory_read_from_buffer(buf, count, ppos, tbuf, len);
 }
 
 static const struct proc_ops use_gss_proxy_proc_ops = {
 	.proc_open	= nonseekable_open,
 	.proc_write_buf	= write_gssp,
-	.proc_read	= read_gssp,
+	.proc_read_buf	= read_gssp,
 };
 
 static int create_use_gss_proxy_proc_entry(struct net *net)
@@ -1494,7 +1484,7 @@ static void destroy_use_gss_proxy_proc_entry(struct net *net)
 	}
 }
 
-static ssize_t read_gss_krb5_enctypes(struct file *file, char __user *buf,
+static ssize_t read_gss_krb5_enctypes(struct file *file, char *buf,
 				      size_t count, loff_t *ppos)
 {
 	struct rpcsec_gss_oid oid = {
@@ -1512,7 +1502,7 @@ static ssize_t read_gss_krb5_enctypes(struct file *file, char __user *buf,
 		return 0;
 	}
 
-	ret = simple_read_from_buffer(buf, count, ppos,
+	ret = memory_read_from_buffer(buf, count, ppos,
 				      mech->gm_upcall_enctypes,
 				      strlen(mech->gm_upcall_enctypes));
 	gss_mech_put(mech);
@@ -1521,7 +1511,7 @@ static ssize_t read_gss_krb5_enctypes(struct file *file, char __user *buf,
 
 static const struct proc_ops gss_krb5_enctypes_proc_ops = {
 	.proc_open	= nonseekable_open,
-	.proc_read	= read_gss_krb5_enctypes,
+	.proc_read_buf	= read_gss_krb5_enctypes,
 };
 
 static int create_krb5_enctypes_proc_entry(struct net *net)
diff --git a/net/sunrpc/cache.c b/net/sunrpc/cache.c
index a257598768fa..81a3f0068f36 100644
--- a/net/sunrpc/cache.c
+++ b/net/sunrpc/cache.c
@@ -28,6 +28,7 @@
 #include <linux/workqueue.h>
 #include <linux/mutex.h>
 #include <linux/pagemap.h>
+#include <linux/uio.h>
 #include <asm/ioctls.h>
 #include <linux/sunrpc/types.h>
 #include <linux/sunrpc/cache.h>
@@ -837,9 +838,10 @@ cache_next_request(struct cache_detail *cd, u64 seqno)
 	return NULL;
 }
 
-static ssize_t cache_read(struct file *filp, char __user *buf, size_t count,
-			  loff_t *ppos, struct cache_detail *cd)
+static ssize_t cache_read(struct file *filp, struct iov_iter *to,
+			  struct cache_detail *cd)
 {
+	size_t count = iov_iter_count(to);
 	struct cache_reader *rp = filp->private_data;
 	struct cache_request *rq;
 	struct inode *inode = file_inode(filp);
@@ -878,7 +880,7 @@ static ssize_t cache_read(struct file *filp, char __user *buf, size_t count,
 		if (rp->offset + count > rq->len)
 			count = rq->len - rp->offset;
 		err = -EFAULT;
-		if (copy_to_user(buf, rq->buf + rp->offset, count))
+		if (copy_to_iter(rq->buf + rp->offset, count, to) != count)
 			goto out;
 		rp->offset += count;
 		if (rp->offset >= rq->len) {
@@ -1499,16 +1501,11 @@ static int release_flush(struct inode *inode, struct file *file,
 	return 0;
 }
 
-static ssize_t read_flush(struct file *file, char __user *buf,
-			  size_t count, loff_t *ppos,
-			  struct cache_detail *cd)
+/* what reading the flush files returns */
+static size_t flush_time_text(struct cache_detail *cd, char *tbuf, size_t size)
 {
-	char tbuf[22];
-	size_t len;
-
-	len = snprintf(tbuf, sizeof(tbuf), "%llu\n",
+	return snprintf(tbuf, size, "%llu\n",
 			convert_to_wallclock(cd->flush_time));
-	return simple_read_from_buffer(buf, count, ppos, tbuf, len);
 }
 
 /* longest number the flush files take */
@@ -1564,12 +1561,15 @@ static ssize_t write_flush(struct file *file, const char __user *buf,
 	return do_write_flush(tbuf, count, ppos, cd);
 }
 
-static ssize_t cache_read_procfs(struct file *filp, char __user *buf,
-				 size_t count, loff_t *ppos)
+static ssize_t cache_read_procfs(struct file *filp, char *buf, size_t count,
+				 loff_t *ppos)
 {
 	struct cache_detail *cd = pde_data(file_inode(filp));
+	struct kvec kvec = { .iov_base = buf, .iov_len = count };
+	struct iov_iter to;
 
-	return cache_read(filp, buf, count, ppos, cd);
+	iov_iter_kvec(&to, ITER_DEST, &kvec, 1, count);
+	return cache_read(filp, &to, cd);
 }
 
 /* procfs copied in what was written */
@@ -1620,7 +1620,7 @@ static int cache_release_procfs(struct inode *inode, struct file *filp)
 }
 
 static const struct proc_ops cache_channel_proc_ops = {
-	.proc_read	= cache_read_procfs,
+	.proc_read_buf	= cache_read_procfs,
 	.proc_write_buf	= cache_write_procfs,
 	.proc_write_size = CACHE_DOWNCALL_MAX,
 	.proc_poll	= cache_poll_procfs,
@@ -1668,12 +1668,15 @@ static int release_flush_procfs(struct inode *inode, struct file *filp)
 	return release_flush(inode, filp, cd);
 }
 
-static ssize_t read_flush_procfs(struct file *filp, char __user *buf,
-			    size_t count, loff_t *ppos)
+static ssize_t read_flush_procfs(struct file *filp, char *buf, size_t count,
+				 loff_t *ppos)
 {
 	struct cache_detail *cd = pde_data(file_inode(filp));
+	char tbuf[22];
+	size_t len;
 
-	return read_flush(filp, buf, count, ppos, cd);
+	len = flush_time_text(cd, tbuf, sizeof(tbuf));
+	return memory_read_from_buffer(buf, count, ppos, tbuf, len);
 }
 
 static ssize_t write_flush_procfs(struct file *filp, char *buf, size_t count,
@@ -1688,7 +1691,7 @@ static ssize_t write_flush_procfs(struct file *filp, char *buf, size_t count,
 
 static const struct proc_ops cache_flush_proc_ops = {
 	.proc_open	= open_flush_procfs,
-	.proc_read	= read_flush_procfs,
+	.proc_read_buf	= read_flush_procfs,
 	.proc_write_buf	= write_flush_procfs,
 	.proc_write_size = CACHE_FLUSH_MAX,
 	.proc_release	= release_flush_procfs,
@@ -1795,8 +1798,10 @@ static ssize_t cache_read_pipefs(struct file *filp, char __user *buf,
 				 size_t count, loff_t *ppos)
 {
 	struct cache_detail *cd = RPC_I(file_inode(filp))->private;
+	struct iov_iter to;
 
-	return cache_read(filp, buf, count, ppos, cd);
+	iov_iter_ubuf(&to, ITER_DEST, buf, count);
+	return cache_read(filp, &to, cd);
 }
 
 static ssize_t cache_write_pipefs(struct file *filp, const char __user *buf,
@@ -1886,8 +1891,11 @@ static ssize_t read_flush_pipefs(struct file *filp, char __user *buf,
 			    size_t count, loff_t *ppos)
 {
 	struct cache_detail *cd = RPC_I(file_inode(filp))->private;
+	char tbuf[22];
+	size_t len;
 
-	return read_flush(filp, buf, count, ppos, cd);
+	len = flush_time_text(cd, tbuf, sizeof(tbuf));
+	return simple_read_from_buffer(buf, count, ppos, tbuf, len);
 }
 
 static ssize_t write_flush_pipefs(struct file *filp,

-- 
2.53.0

