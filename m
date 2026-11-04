Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.remote-ip=100.103.45.18
ARC-Seal: i=1; d=subspace.kernel.org; s=arc20261015; a=rsa-sha256; cv=none;
	t=1793826831;
	b=jNhvVbXQRN1558IC4fjziO2l2SEGpINRjiVxPaPegM9LjBRIty6RH0QTqaQ1DvhY+sx9
	 1zqYoo1mmk/q4U9a5D4NWN0cm//5gWFZ+AA1y4ku/f+9777xj56eLfICIUKS6zgDfxVsw
	 LPmh4I0xFbq6SbpiMqBDnxK8C+LonL/V7PMJtlAvVVEIi/bEvP82CMB1jbsz89Es5dQLP
	 O8adDgSNO8XkwVoU284Dfzu+4mTu1LYnjUV+sIEKBaXjGpi9o2oztbshoPUMEE9GwVs3U
	 TxCPDyX8C29tTYNmjTdCTByxADxFVPK8fseba5R21+0TdS6o76Z8/K4FEhBML7Plu6g==
ARC-Message-Signature: i=1; d=subspace.kernel.org; s=arc20261015;
	a=rsa-sha256; c=relaxed/relaxed; t=1793826831;
	h=Received:DKIM-Signature:From:To:Cc:Subject:Date:Message-ID:
	 In-Reply-To:References:MIME-Version:Content-Type:X-Mailer:
	 X-Developer-Signature:X-Developer-Key:Content-Transfer-Encoding;
	bh=1MxYRYKjXg/+oT1B67MpjVjXxOUB68rY8isEKfXqK2M=;
	b=E9xtwCou4ZB54/yt7/3/86vFLoaK5TO6k6WEXE0kea3J91VM4jHB5+meYFByzK4wO3Zp
	 HuafphyZ07tiAX+kW6aem2Lr054TZc2hf9F57zRPJmPDVg63DCEUv+Lew1jB93P/G/aKu
	 Lnet2DVtu04aNBwvfOcfncFPn4Ok53qUupERIhF3RgpkOC9vbennkrxIw/7XTC+csvz5y
	 5cRa6PDokTtUFRUKl+RQ0lPacP/QqygOsyEo4pqXQbXtV/oiwkXXRPEFFh55sYc0v5GzP
	 3teRFKtsKgBNTJR9W+Bgn3JDZSHkxeH0feY/kpLgi9T05qg7O3LQ2S0Vv2u//oKTBRQ==
ARC-Authentication-Results: i=1; smtp.subspace.kernel.org; 
	dkim=pass header.d=kernel.org header.i=@kernel.org header.a=rsa-sha256 header.s=k20260515 header.b=ETQGuZ5m;
	arc=none smtp.remote-ip=100.103.45.18
Received: from smtp.kernel.org (quasi.space.kernel.org [100.103.45.18])
	(using TLSv1.3 with cipher TLS_AES_256_GCM_SHA384 (256/256 bits)
	 key-exchange X25519 server-signature ECDSA (prime256v1))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 8C2466071AFB;
	Wed,  4 Nov 2026 21:13:51 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key, unprotected) header.d=kernel.org header.i=@kernel.org header.a=rsa-sha256 header.s=k20260515 header.b=ETQGuZ5m
Received: by smtp.kernel.org (Postfix) with ESMTPSA id D9FDB1F000C1;
	Wed,  4 Nov 2026 21:13:39 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=kernel.org;
	s=k20260515; t=1793826831;
	bh=1MxYRYKjXg/+oT1B67MpjVjXxOUB68rY8isEKfXqK2M=;
	h=From:To:Cc:Subject:Date:In-Reply-To:References;
	b=ETQGuZ5mWrJaw5vMCNoxKDTP6j6Ov//pzU7UV0re+JQ/fOVwqabIgrja5LMlvIx3R
	 mBlsuHBCVE8oDvKETlbRqL1mhIdq3tD2pozrg28w+TtoHjgYEwWMJ4CIpaO1h6KvxQ
	 V3ufmOQrumr5xp/6TYUAYOVWxzXCl9UAFw/i9yKn1dgBRAbUrpnmTDlh+YdGCs76Yl
	 EsaKk9QvFagOgFekDjd3Lf3WCADE6zYjwBULe2sa8XrpB7drKPKJkJrEFpU3FefsUh
	 RzD53Gz+X/bLDWxUAm40hLd+bK3dqFI/hYSlTDpB/hxhYfKzRFrbamvLaNX4sWezYW
	 AXz5pXYWXwUog==
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
Subject: [PATCH RESEND v2 10/13] SUNRPC: let procfs own the wait queue of the procfs channel files
Date: Wed,  4 Nov 2026 22:13:37 +0100
Message-ID: <20261104-work-procfs-net-v2-10-221e2437fed1@kernel.org>
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
X-Developer-Signature: v=1; a=openpgp-sha256; l=3889; i=brauner@kernel.org; h=from:subject:message-id; bh=QPerLLDMXFlA+1II+fYpDsDcCxwkLoYz0L35dMx6y10=; b=owGbwMvMwCU28Zj0gdSKO4sYT6slMWS97tPPWss1reVowb5lm3abTz0rMjlm2gkBvWsyExf/X HRC4GaxZEcpC4MYF4OsmCKLQ7tJuNxynorNRpkaMHNYmUCGMHBxCsBEVukwMuzjjI+PiJCdw3+7 2mPbsYasgi9fNtZwRVfcuHZVTzg6v42R4eTzNOM3P9YXtbtlPnjWlcQ/W1jsYVuwd/jiwx3zgv1 CmAE=
X-Developer-Key: i=brauner@kernel.org; a=openpgp; fpr=4880B8C9BD0E5106FC070F4F7B3C391EFEA93624
Content-Transfer-Encoding: 8bit

cache_poll() sleeps the poller on queue_wait, which went back to being
a static queue so that a poll() on a procfs channel file can't be left
on the queue of a cache_detail that its network namespace freed. procfs
owns the queue poll() uses now and it outlives the file, so the procfs
channel files leave the poll_wait() to procfs and an upcall wakes their
pollers through proc_poll_notify(). The channel entry is remembered in
the cache_detail for that and forgotten before the entries are removed.
The rpc_pipefs files keep sleeping on queue_wait, procfs has nothing to
do with them.

Signed-off-by: Christian Brauner (Amutable) <brauner@kernel.org>
---
 include/linux/sunrpc/cache.h |  2 ++
 net/sunrpc/cache.c           | 20 +++++++++++---------
 2 files changed, 13 insertions(+), 9 deletions(-)

diff --git a/include/linux/sunrpc/cache.h b/include/linux/sunrpc/cache.h
index bf4fc543e1e5..9d508205ebb2 100644
--- a/include/linux/sunrpc/cache.h
+++ b/include/linux/sunrpc/cache.h
@@ -129,6 +129,8 @@ struct cache_detail {
 		struct proc_dir_entry	*procfs;
 		struct dentry		*pipefs;
 	};
+	/* the channel file in @procfs, for proc_poll_notify() */
+	struct proc_dir_entry	*procfs_channel;
 	struct net		*net;
 };
 
diff --git a/net/sunrpc/cache.c b/net/sunrpc/cache.c
index d242b6f33cbc..f220a3036b6e 100644
--- a/net/sunrpc/cache.c
+++ b/net/sunrpc/cache.c
@@ -970,20 +970,18 @@ out:
 }
 
 /*
- * Not in struct cache_detail: poll and epoll waiters stay queued until
- * their file is closed, but a channel file in procfs can stay open after
- * the cache_detail of its dying network namespace has been freed.
+ * For the rpc_pipefs channel files. Not in struct cache_detail: poll and
+ * epoll waiters stay queued until their file is closed, which can be after
+ * the cache_detail is gone. The procfs channel files are polled on the wait
+ * queue procfs owns for them instead, see proc_poll_notify().
  */
 static DECLARE_WAIT_QUEUE_HEAD(queue_wait);
 
-static __poll_t cache_poll(struct file *filp, poll_table *wait,
-			       struct cache_detail *cd)
+static __poll_t cache_poll(struct file *filp, struct cache_detail *cd)
 {
 	__poll_t mask;
 	struct cache_reader *rp = filp->private_data;
 
-	poll_wait(filp, &queue_wait, wait);
-
 	/* alway allow write */
 	mask = EPOLLOUT | EPOLLWRNORM;
 
@@ -1248,6 +1246,7 @@ static int cache_do_upcall(struct cache_detail *detail, struct cache_head *h)
 	if (ret != -EAGAIN && detail->cache_notify)
 		detail->cache_notify(detail, h);
 	wake_up(&queue_wait);
+	proc_poll_notify(detail->procfs_channel);
 	if (ret == -EAGAIN) {
 		kfree(buf);
 		kfree(crq);
@@ -1593,7 +1592,7 @@ static __poll_t cache_poll_procfs(struct file *filp, poll_table *wait)
 {
 	struct cache_detail *cd = pde_data(file_inode(filp));
 
-	return cache_poll(filp, wait, cd);
+	return cache_poll(filp, cd);
 }
 
 static int cache_open_procfs(struct inode *inode, struct file *filp)
@@ -1690,6 +1689,7 @@ static const struct proc_ops cache_flush_proc_ops = {
 static void remove_cache_proc_entries(struct cache_detail *cd)
 {
 	if (cd->procfs) {
+		cd->procfs_channel = NULL;
 		proc_remove(cd->procfs);
 		cd->procfs = NULL;
 	}
@@ -1718,6 +1718,7 @@ static int create_cache_proc_entries(struct cache_detail *cd, struct net *net)
 				     &cache_channel_proc_ops, cd);
 		if (p == NULL)
 			goto out_nomem;
+		cd->procfs_channel = p;
 	}
 	if (cd->cache_show) {
 		p = proc_create_data("content", S_IFREG | 0400, cd->procfs,
@@ -1806,7 +1807,8 @@ static __poll_t cache_poll_pipefs(struct file *filp, poll_table *wait)
 {
 	struct cache_detail *cd = RPC_I(file_inode(filp))->private;
 
-	return cache_poll(filp, wait, cd);
+	poll_wait(filp, &queue_wait, wait);
+	return cache_poll(filp, cd);
 }
 
 static long cache_ioctl_pipefs(struct file *filp,

-- 
2.53.0

