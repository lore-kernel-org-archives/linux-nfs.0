Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.remote-ip=100.103.45.18
ARC-Seal: i=1; d=subspace.kernel.org; s=arc20261015; a=rsa-sha256; cv=none;
	t=1794827469;
	b=s6KCguraidFQ8ywG4cN0Xi4MxJKpL8n9Dh3jflZe2MIlXKDyHa/4+DjPwOlU8eYCIALR
	 dGl6TB2x4M1enZIHqha1c4oBnPlIefnD1qc7wrsoGl39wKo/Z7V300isl7y8gQuBynqXw
	 maLreMdNtE7vY6Ngw3Aqe8waY45dn0kkjyow8lHMpTfkiybyRVQ4VyqGUA/KCbpMStRbA
	 M4oGMU80lpA1rJHqsabW11F6GarQuZvsQ/3/dY01LJIXsMYnvjViocrV0JQDDAlML6CCF
	 O+9dX9uWD3AI6NPS6e8GiVuVl06zd6+dVvsv7/mCit1ld9DrbsSzq/tIh8XRJpilzoQ==
ARC-Message-Signature: i=1; d=subspace.kernel.org; s=arc20261015;
	a=rsa-sha256; c=relaxed/relaxed; t=1794827469;
	h=Received:DKIM-Signature:From:Date:Subject:MIME-Version:Content-Type:
	 Content-Transfer-Encoding:Message-Id:References:In-Reply-To:To:Cc:
	 X-Mailer:X-Developer-Signature:X-Developer-Key;
	bh=OTEjlmIJyKpC5NfEWKTxGQBI4o98SYAhIwo6Ai+LDGM=;
	b=gv29WwJIZ4Ici7x4rS5ECFkszg4r8i1nSn9z/gqWVkdCymMZEV2nQMkEHoYCLHRFyEba
	 Mcx/zWfgIsn0KB3dT2EqmYO8+jWcnS162tUlCcnUHB/zvmVZz7N4Eochc5fV52v/hxeLX
	 n8lj5VAHtMzR3UuDPJbzLCcVtLqerWODaGGqEq/qZNDIuIllLHe1dY8rCHZIyU6GToeEt
	 4abY0SveDJoRBPREXxzXK8HttG3FYkjbAEE3XrzJLdhMrH5Unc3SRych4H1kfr19eIqYE
	 S59kHA5DODNotcx5mrM9UUg6BbVSR47PjXQe0BaC9AS7WvXe9b2WrMKEDTikp3sCfbg==
ARC-Authentication-Results: i=1; smtp.subspace.kernel.org; 
	dkim=pass header.d=kernel.org header.i=@kernel.org header.a=rsa-sha256 header.s=k20260515 header.b=b8+ShhPz;
	arc=none smtp.remote-ip=100.103.45.18
Received: from smtp.kernel.org (quasi.space.kernel.org [100.103.45.18])
	(using TLSv1.3 with cipher TLS_AES_256_GCM_SHA384 (256/256 bits)
	 key-exchange X25519 server-signature ECDSA (prime256v1))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 50CB46071B36;
	Mon, 16 Nov 2026 11:11:08 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.a=rsa-sha256 header.s=k20260515 header.b=b8+ShhPz
Received: by smtp.kernel.org (Postfix) with ESMTPSA id B90BD1F000C4;
	Mon, 16 Nov 2026 11:11:01 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=kernel.org;
	s=k20260515; t=1794827468;
	bh=OTEjlmIJyKpC5NfEWKTxGQBI4o98SYAhIwo6Ai+LDGM=;
	h=From:Date:Subject:References:In-Reply-To:To:Cc;
	b=b8+ShhPzXQ5lKArD/6+ZRe9DOjMyoKKAtnYUlLtEIbco9DLALBR0Fd2WDzfzWc/xq
	 +KykUFg8yMY6Kd78+glVS3d4yeckJ0NZgym4qTmABG1DSqtV08TKvEgKTSRPYYc8FP
	 3A/zUYyTBLJdxk3fLBWngqH38gEefnGvMYwPDcaoLTEerXzCHabY1vE4quu1HkYEqI
	 xK7UXhuJplVmiu7BnozU6NuKxVhigBCbUzntJkdDKhMU1U4LXEjJVGGRKv6uioBtRs
	 sd3pKHijxRAVRCt9esuvtmGbmGhGQspe3OfnCiNM1Ut6Q2kagZYzQsqGYzonRHSJSV
	 uP0mNwhmOYf2A==
From: Christian Brauner <brauner@kernel.org>
Date: Mon, 16 Nov 2026 12:05:14 +0100
Subject: [PATCH RFC v3 41/44] usb: gadget: f_mass_storage: refuse files on
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
Message-Id: <20261116-work-loop-pseudo-v3-41-8cbbea1cf34f@kernel.org>
References: <20261116-work-loop-pseudo-v3-0-8cbbea1cf34f@kernel.org>
In-Reply-To: <20261116-work-loop-pseudo-v3-0-8cbbea1cf34f@kernel.org>
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
 "Christian Brauner (Amutable)" <brauner@kernel.org>, 
 Alexander Mikhalitsyn <alex@amutable.com>, 
 Chris Down <chris@chrisdown.name>
X-Mailer: b4 0.17-dev-ce4c1
X-Developer-Signature: v=1; a=openpgp-sha256; l=2207; i=brauner@kernel.org;
 h=from:subject:message-id; bh=9yOpMEvSpwTZ88CI4cJoJKFDpbu7ZmjHFE7v8Gz8hhc=;
 b=owGbwMvMwCU28Zj0gdSKO4sYT6slMWT9etynd0NX1vPeFOdEtq9nL7ydJOxr3SZTcqJWrC/8P
 8+eTSY8HaUsDGJcDLJiiiwO7Sbhcst5KjYbZWrAzGFlAhnCwMUpABNpsmJk2P/2xMUG9fKOCS+q
 pmtt5+OefHRG0P2je5ZsqZU7vHHpSW+GvxKn1gcduJD7d9+yy53iOseiZErr8u6GsuasXRM//eL
 OvXwA
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

Reviewed-by: Alexander Mikhalitsyn <alex@amutable.com>
Reviewed-by: Chris Down <chris@chrisdown.name>
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

