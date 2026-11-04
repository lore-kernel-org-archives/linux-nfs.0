Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.remote-ip=100.103.45.18
ARC-Seal: i=1; d=subspace.kernel.org; s=arc20261015; a=rsa-sha256; cv=none;
	t=1793813430;
	b=VvpJDZAsLFsSynD+qInXJ5sh5ZKk4V1we0rlQ8cfmqVdc0uwLY4lnetx5nAN3/CiTgqv
	 7vPRhaEYAw4dCx/puDLUGN9Ii4ZUh/KsUVA45z0r/di1UyWEimGJYxp6+8x4l4u11pfdg
	 Jp1Cmmre3/jWoZG2DSE6BH63tRYeNUp8QUE5QG7fjIQBCkNyiIsEzMrDPBZEomDJnA1Z1
	 VYyUxcM4YFxom1gh7r5AOMAk5XwOJ3p4AnXlwrmqrYzk2W30AxBPQhtwrN0Kngu3DGJXA
	 1gb/FtcH3yQu5XUwIYwfmVR4hlT7iCiOMNqjW3odav5DtSgcJtmCQUwQ2EkYr5DBUIg==
ARC-Message-Signature: i=1; d=subspace.kernel.org; s=arc20261015;
	a=rsa-sha256; c=relaxed/relaxed; t=1793813430;
	h=Received:DKIM-Signature:From:Date:Subject:MIME-Version:Content-Type:
	 Content-Transfer-Encoding:Message-Id:References:In-Reply-To:To:Cc:
	 X-Mailer:X-Developer-Signature:X-Developer-Key;
	bh=gnzz2fT926tAung/y7Xzshf60AQanFXIqjFC5KSqJW4=;
	b=vwpbMmSzml903IPFA2a5qpxVcL1qG2ffAGrWMvI3zzmqcnZjWlZ+WeWaXA25ZVz7Gf+P
	 28QjpyCZvg13XJgN/LUe7mMxbASlI6oJS7M2F0f01YLslpczcds/BkuYEgzdqp1wgpavG
	 1MdtPOltxByLHDF9i4S2KqOpggQM1Yvp9JDDqA3m4N30boHfstK564KxiDQlm8IRX8xaB
	 ZyY+KE5KW7D0qHxeNMYZQdirM+tOfa8d1v9YVbD8hFhencl5r81Qw8q2Lpt0AGQTmv08g
	 sb0PdLWQF4HUGTvzAAwRa7AG/8xh++PRD1KNKezmizGwPhkgh5EjKv6wXOxSDXNalPg==
ARC-Authentication-Results: i=1; smtp.subspace.kernel.org; 
	dkim=pass header.d=kernel.org header.i=@kernel.org header.a=rsa-sha256 header.s=k20260515 header.b=bKrAUcOe;
	arc=none smtp.remote-ip=100.103.45.18
Received: from smtp.kernel.org (quasi.space.kernel.org [100.103.45.18])
	(using TLSv1.3 with cipher TLS_AES_256_GCM_SHA384 (256/256 bits)
	 key-exchange X25519 server-signature ECDSA (prime256v1))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 1F19E608361C;
	Wed,  4 Nov 2026 17:30:29 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key, unprotected) header.d=kernel.org header.i=@kernel.org header.a=rsa-sha256 header.s=k20260515 header.b=bKrAUcOe
Received: by smtp.kernel.org (Postfix) with ESMTPSA id D051B1F00A20;
	Wed,  4 Nov 2026 17:30:16 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=kernel.org;
	s=k20260515; t=1793813429;
	bh=gnzz2fT926tAung/y7Xzshf60AQanFXIqjFC5KSqJW4=;
	h=From:Date:Subject:References:In-Reply-To:To:Cc;
	b=bKrAUcOeVzlg83/euOIHnVFterm+vHdMFNuNi2Dt0LF9VzWRfSHdWlR7H5c2KTzRF
	 naRK5w+k54/QDDCRMfWgLxdTPqv4FCwBsr1kXOzQqhEOlC8vy1IWJ41ODhEZLno2LS
	 jjGH8/XSd1jADyBL1p3Hc3Qgb7ui9/GDGzwbwzjY67qrbN3GQL5NP2Jybx4qUpUZX3
	 CQMNjfOnMG5qtjvL2qoA6KmgJggxXjaC2t2PuKCscK2/RkukWsmgaXtZ0l6oKz5iz+
	 P64zZ0Jt2cdani8OUoo4/+XjtpVm+osPlwpgz43htAz/C7aUhFTjPEXATp/jT4GDYM
	 7OqOzge6sGwYQ==
From: Christian Brauner <brauner@kernel.org>
Date: Wed, 04 Nov 2026 18:27:25 +0100
Subject: [PATCH v2 08/51] powerpc/pseries/lparcfg: don't drop the last byte
 of a write
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
Message-Id: <20261104-work-procfs-bugfixes-v2-8-bbf7d5546809@kernel.org>
References: <20261104-work-procfs-bugfixes-v2-0-bbf7d5546809@kernel.org>
In-Reply-To: <20261104-work-procfs-bugfixes-v2-0-bbf7d5546809@kernel.org>
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
 Chuck Lever <cel@kernel.org>, stable@vger.kernel.org
X-Mailer: b4 0.17-dev
X-Developer-Signature: v=1; a=openpgp-sha256; l=1293; i=brauner@kernel.org;
 h=from:subject:message-id; bh=N2rHHHUzfsZsGLUBvdMxa3o2qGAAPzh8wsvUFn8S2uA=;
 b=owGbwMvMwCU28Zj0gdSKO4sYT6slMWS9zmYqts+f6c771jBc691PB/aNiq5rYmuWq7o9SdKKM
 Ga7qdvUUcrCIMbFICumyOLQbhIut5ynYrNRpgbMHFYmkCEMXJwCMJFb8gz/a+f8MlT+0SWxMsTk
 QerGWIU8g/w227Ptd+ManyhO269pzsgwb7VmgtgD7UuXjjF+CvlTU3NkGv8+HhW+PC2DOSyTg2v
 5AQ==
X-Developer-Key: i=brauner@kernel.org; a=openpgp;
 fpr=4880B8C9BD0E5106FC070F4F7B3C391EFEA93624

lparcfg_write() terminates its copy of the write by overwriting the
last byte, so a write without a trailing newline loses its last
character: "partition_entitled_capacity=5" is parsed as an empty value
and fails with -EINVAL. Terminate behind the copy instead, and refuse a
write that fills the whole buffer, which can't be terminated.

Fixes: 1da177e4c3f4 ("Linux-2.6.12-rc2")
Cc: stable@vger.kernel.org
Signed-off-by: Christian Brauner (Amutable) <brauner@kernel.org>
---
 arch/powerpc/platforms/pseries/lparcfg.c | 5 ++---
 1 file changed, 2 insertions(+), 3 deletions(-)

diff --git a/arch/powerpc/platforms/pseries/lparcfg.c b/arch/powerpc/platforms/pseries/lparcfg.c
index 3280b7968cab..9882f98c0efb 100644
--- a/arch/powerpc/platforms/pseries/lparcfg.c
+++ b/arch/powerpc/platforms/pseries/lparcfg.c
@@ -699,13 +699,12 @@ static ssize_t lparcfg_write(struct file *file, const char __user * buf,
 	if (!firmware_has_feature(FW_FEATURE_SPLPAR))
 		return -EINVAL;
 
-	if (count == 0 || count > sizeof(kbuf))
+	if (count == 0 || count >= sizeof(kbuf))
 		return -EINVAL;
 
 	if (copy_from_user(kbuf, buf, count))
 		return -EFAULT;
-
-	kbuf[count - 1] = '\0';
+	kbuf[count] = '\0';
 	tmp = strchr(kbuf, '=');
 	if (!tmp)
 		return -EINVAL;

-- 
2.53.0

