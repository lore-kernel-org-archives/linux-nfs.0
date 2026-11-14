Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.remote-ip=100.103.45.18
ARC-Seal: i=1; d=subspace.kernel.org; s=arc20261015; a=rsa-sha256; cv=none;
	t=1794661808;
	b=Cyn7+g7FN2kBStctaXGZETfP45wDKxS4J9XD0Zhryum6LJH1rlVffqSpBo3y2ha41nd4
	 TDxWHmMvji2m693D7/hgcQXyGEN9hko5E0jzxOCs7UCfUzcJk45CRs+wstwKif6QPQMZO
	 BUw8v9E/wRiDIiG5UC6+YGF5BniTorCimdC6x1OyPfmNs5n9F05kA5rCBuZx42NBfcceq
	 3oOREv4POfL2AOxcqWVNtaRierJn3sFc8eQhOKbWs4UbAm0HGAzoedfXj5AN5TNLbHR/b
	 MtqNQwOMAxc4jW0WnfNUlM6jHxgH//dDLdOgtsetdI4sqbm4nOR4Fv9JJ+ni+Cd4l7g==
ARC-Message-Signature: i=1; d=subspace.kernel.org; s=arc20261015;
	a=rsa-sha256; c=relaxed/relaxed; t=1794661808;
	h=Received:DKIM-Signature:From:Date:Subject:MIME-Version:Content-Type:
	 Content-Transfer-Encoding:Message-Id:References:In-Reply-To:To:Cc:
	 X-Mailer:X-Developer-Signature:X-Developer-Key;
	bh=CSBUELtQKf2EG5AQcZbSbpFUNRQ3ThMifteDUnUw1To=;
	b=fx04ccOJxWrUky+IWI8cjwSnaTH1utDs4ERySFjKLQtPYUGz745I6xsvADLBBOQ8HvQv
	 fRvQYlll2ZAcQ5ERVUdpZEX0z+SZSBEMk0r1zeGWep0kUx3+Ib3Ao9rgAGCQuH5NtZ5bC
	 aP6qD3aetZqVOHq2ZS/4THfCveLbeUAxdV9R5PY+5G8D9aw5HaymSH+Er6ngZcHxUhUpj
	 UdvF4Z9gL4qqr4m+sSDItEKDhFdGVJzUBHOO+6/N8jRoHljYRFuwy3TVdkZ/v29/khIeJ
	 5BXUwugXBltfBO6ZLwfRXmxvqwi8LN54G53uh9XFew+QLCIpgG9I37fHjUGTCBgiqAg==
ARC-Authentication-Results: i=1; smtp.subspace.kernel.org; 
	dkim=pass header.d=kernel.org header.i=@kernel.org header.a=rsa-sha256 header.s=k20260515 header.b="RV9gmw/I";
	arc=none smtp.remote-ip=100.103.45.18
Received: from smtp.kernel.org (quasi.space.kernel.org [100.103.45.18])
	(using TLSv1.3 with cipher TLS_AES_256_GCM_SHA384 (256/256 bits)
	 key-exchange X25519 server-signature ECDSA (prime256v1))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 418F8606D2A4;
	Sat, 14 Nov 2026 13:10:07 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.a=rsa-sha256 header.s=k20260515 header.b=RV9gmw/I
Received: by smtp.kernel.org (Postfix) with ESMTPSA id 96F8C1F000C5;
	Sat, 14 Nov 2026 13:10:01 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=kernel.org;
	s=k20260515; t=1794661807;
	bh=CSBUELtQKf2EG5AQcZbSbpFUNRQ3ThMifteDUnUw1To=;
	h=From:Date:Subject:References:In-Reply-To:To:Cc;
	b=RV9gmw/IAOoiKg4/iNqtweBRGlddT1o/Yqe6wuzCyD8VZR+CWkIVawaw49hfqSOgZ
	 LctRgRWk47GTCBDiGaQYXyx3osf9jFCWVX6/4A243zHKRAFMEnHt6oSDZPt1Q3OYJI
	 xwKdwDdCk5AwpGruPZr1Wf6+rhKPq/Z1HobRzMCY/khSkDIxOYcv9lqM943DQjUUM8
	 lWTa+bTex+LmfRUrVehDn39PrMRQDaO+u0L/y3vRLKndUFxbnRtH82CVr7tByoSsCi
	 Y0BYSO/bZGoiFG49r3hOvHcCTFZi1rD/XiyUYUN+nayOXVbZE4ZmNi6jzymzv9U5rG
	 8O5DHkba2DaXA==
From: Christian Brauner <brauner@kernel.org>
Date: Sat, 14 Nov 2026 14:02:20 +0100
Subject: [PATCH RFC v2 39/42] usb: gadget: f_mass_storage: refuse files on
 pseudo filesystems
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
Message-Id: <20261114-work-loop-pseudo-v2-39-98639a2286fb@kernel.org>
References: <20261114-work-loop-pseudo-v2-0-98639a2286fb@kernel.org>
In-Reply-To: <20261114-work-loop-pseudo-v2-0-98639a2286fb@kernel.org>
To: linux-fsdevel@vger.kernel.org
Cc: Jann Horn <jannh@google.com>, Chris Mason <mason@kernel.org>, 
 Josef Bacik <josef@toxicpanda.com>, Christoph Hellwig <hch@lst.de>, 
 linux-block@vger.kernel.org, linux-kernel@vger.kernel.org, 
 linux-nvme@lists.infradead.org, Alexander Viro <viro@zeniv.linux.org.uk>, 
 Jan Kara <jack@suse.cz>, linux-scsi@vger.kernel.org, 
 target-devel@vger.kernel.org, driver-core@lists.linux.dev, 
 linux-mm@kvack.org, bpf@vger.kernel.org, 
 linux-security-module@vger.kernel.org, selinux@vger.kernel.org, 
 apparmor@lists.ubuntu.com, linux-nfs@vger.kernel.org, 
 netdev@vger.kernel.org, fuse-devel@lists.linux.dev, 
 linux-efi@vger.kernel.org, xen-devel@lists.xenproject.org, 
 ocfs2-devel@lists.linux.dev, linux-s390@vger.kernel.org, 
 linuxppc-dev@lists.ozlabs.org, linux-usb@vger.kernel.org, 
 Amir Goldstein <amir73il@gmail.com>, linux-erofs@lists.ozlabs.org, 
 linux-kselftest@vger.kernel.org, 
 "Christian Brauner (Amutable)" <brauner@kernel.org>
X-Mailer: b4 0.17-dev-ce4c1
X-Developer-Signature: v=1; a=openpgp-sha256; l=2103; i=brauner@kernel.org;
 h=from:subject:message-id; bh=p2zQzeeQYbSmjPnrcL8CGIlIEeUTXjBe/VYk5piLT0g=;
 b=owGbwMvMwCU28Zj0gdSKO4sYT6slMWT9iJl8gOHaSbHg71O3XtvEHKC99CeXwV5LY9vXtX6Hy
 0KahV4t6ShlYRDjYpAVU2RxaDcJl1vOU7HZKFMDZg4rE8gQBi5OAZiIzxKG/wUnFu/4dONOSFWW
 9v51fvWagq8WCV5ltWn4+rNn0faMRVaMDKtNI9Ywyv1ozvo9gdHGVF3Q3tJHcOL89Ukvd63+Yhe
 QzQ8A
X-Developer-Key: i=brauner@kernel.org; a=openpgp;
 fpr=4880B8C9BD0E5106FC070F4F7B3C391EFEA93624

fsg_lun_open() takes any regular file as the backing file of a LUN. The
file-storage kthread then reads and writes it with kernel_read() and
kernel_write() on behalf of the USB host. With a procfs or sysfs file
behind a LUN the host gets to read and write kernel interfaces with
kernel credentials. Refuse files on pseudo filesystems just like loop
does by switching to file_check_backing().

The helper also does the file type and readability checks. So the
messages for an unsuitable backing file become one. It looks at the
inode of the file instead of the host of ->f_mapping. For regular files
and block devices both have the same type. It also wants ->read_iter()
where FMODE_CAN_READ was enough so far. But kernel_read() never worked
without ->read_iter() anyway.

Signed-off-by: Christian Brauner (Amutable) <brauner@kernel.org>
---
 drivers/usb/gadget/function/storage_common.c | 11 +++--------
 1 file changed, 3 insertions(+), 8 deletions(-)

diff --git a/drivers/usb/gadget/function/storage_common.c b/drivers/usb/gadget/function/storage_common.c
index 75831f2c7abeb..af0c37a9fe029 100644
--- a/drivers/usb/gadget/function/storage_common.c
+++ b/drivers/usb/gadget/function/storage_common.c
@@ -205,23 +205,18 @@ int fsg_lun_open(struct fsg_lun *curlun, const char *filename)
 	if (!(filp->f_mode & FMODE_WRITE))
 		ro = 1;
 
-	inode = filp->f_mapping->host;
-	if ((!S_ISREG(inode->i_mode) && !S_ISBLK(inode->i_mode))) {
-		LINFO(curlun, "invalid file type: %s\n", filename);
-		goto out;
-	}
-
 	/*
 	 * If we can't read the file, it's no good.
 	 * If we can't write the file, use it read-only.
 	 */
-	if (!(filp->f_mode & FMODE_CAN_READ)) {
-		LINFO(curlun, "file not readable: %s\n", filename);
+	if (file_check_backing(filp, FMODE_READ, S_IFBLK)) {
+		LINFO(curlun, "invalid backing file: %s\n", filename);
 		goto out;
 	}
 	if (!(filp->f_mode & FMODE_CAN_WRITE))
 		ro = 1;
 
+	inode = filp->f_mapping->host;
 	size = i_size_read(inode);
 	if (size < 0) {
 		LINFO(curlun, "unable to find file size: %s\n", filename);

-- 
2.53.0

