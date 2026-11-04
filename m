Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.remote-ip=100.103.45.18
ARC-Seal: i=1; d=subspace.kernel.org; s=arc20261015; a=rsa-sha256; cv=none;
	t=1793820051;
	b=XjJ9mkuOaLVYpbqba57I4oGy90vhbz22Gj+BFkYBzGgneIIgydNTYOdxEPD8c1+weuI2
	 4jCbIuYFxA9CHb1QCwbPH4BxRkRc5ZhFgpHOl3w7ESi20zHGoHSx0KvMbaUsG1+Amc21m
	 GC7ZmmpX7Mi3Vgj3DOpwVX5qIibnmaCiLjctsHy3PhThosWcbrkE7iJD2J+9Xr19pr2H2
	 TVIh6Fzhz+PU1c2ZK1hzjOEV1D+oqBZjRX88z1DBnt1R1T2gGz2bs0TA+9KijF9jfnAE5
	 imBUYhQwyCGLhhUeEgAYNXLUQRnZHJeP7xQP0zy7PxzeIr7izdN0bjbu2jd6WKiZv/Q==
ARC-Message-Signature: i=1; d=subspace.kernel.org; s=arc20261015;
	a=rsa-sha256; c=relaxed/relaxed; t=1793820051;
	h=Received:DKIM-Signature:From:To:Cc:Subject:Date:Message-ID:
	 In-Reply-To:References:MIME-Version:Content-Type:X-Mailer:
	 X-Developer-Signature:X-Developer-Key:Content-Transfer-Encoding;
	bh=weMUCFn2uihXk/tOxGBDEw27Pws++kgwJ6Tcia3ltcw=;
	b=d4TZ9EA5ac/vKq7YzMwa8eBrW/BER6lUvPd/qXpRs8szPRLreuKG1JAUPWRJdFChi/cf
	 Aatc0JxO6AHqoC0jQ/Chg/Gpvr/VOQL7GpauuA8E7NuWcuYgb0HchmPcOTrw0QQUpIuw6
	 ZWfCBj2/dzZ0FKPsWpgnBLyEEdDqqQT8ceVob3hB7oRgcgf+mBJyrN0O7i7dYehs8I/h0
	 hXB27+X4JJ04oEvkclb0xQ6UAdpJSke4Scmd5lQfChE4bc5QRAEsSlXHa+md85mSYTFp0
	 cOUXe4d/7WKzAja5APBphUbwAAz6wzWrc6eims3VUBw13GIGtMpHLQKYPHAVR7ZZmLA==
ARC-Authentication-Results: i=1; smtp.subspace.kernel.org; 
	dkim=pass header.d=kernel.org header.i=@kernel.org header.a=rsa-sha256 header.s=k20260515 header.b=HRxCl+Bf;
	arc=none smtp.remote-ip=100.103.45.18
Received: from smtp.kernel.org (quasi.space.kernel.org [100.103.45.18])
	(using TLSv1.3 with cipher TLS_AES_256_GCM_SHA384 (256/256 bits)
	 key-exchange X25519 server-signature ECDSA (prime256v1))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 30D5E6070314;
	Wed,  4 Nov 2026 19:20:51 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key, unprotected) header.d=kernel.org header.i=@kernel.org header.a=rsa-sha256 header.s=k20260515 header.b=HRxCl+Bf
Received: by smtp.kernel.org (Postfix) with ESMTPSA id D9ED11F0093A;
	Wed,  4 Nov 2026 19:20:38 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=kernel.org;
	s=k20260515; t=1793820051;
	bh=weMUCFn2uihXk/tOxGBDEw27Pws++kgwJ6Tcia3ltcw=;
	h=From:To:Cc:Subject:Date:In-Reply-To:References;
	b=HRxCl+Bf2TmTIdvOsOeyzhK8jV+Bfm/AfD9cI3ivj92Dd3pOYsACEhtqy21kBrGn/
	 w5dZIxEHBlkGPyiksDR2eeyKB2QwqkCs8BxVbPOrva8f8+0RyiF4g2ftBS4+38Deq2
	 ECW+IMt2f5f3W9mcjTW+c3CS4ThGnFOYG1d7M9XEv+5D9eIa8f3cQr1EJ+w9iQ/rUC
	 XqEw7LR3pXX6IXRIprFLgivWh1G2NDVohugAan8ecdIvDwRxpUYWViMOW6AbNVUMfk
	 FUYGNVRL6tdh+iW8t1JOxMZYVBhZSDKN5vzmr7c/IALhlwuE9VxTB484IK+SvnVk+v
	 mX/CkL30zPq5w==
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
	Chuck Lever <cel@kernel.org>,
	stable@vger.kernel.org
Subject: [PATCH RESEND v2 19/51] xtensa: simdisk: don't read the file name without the lock
Date: Wed,  4 Nov 2026 20:20:36 +0100
Message-ID: <20261104-work-procfs-bugfixes-v2-19-021c84d852e0@kernel.org>
In-Reply-To: <20261104-work-procfs-bugfixes-v2-0-021c84d852e0@kernel.org>
References: <20261104-work-procfs-bugfixes-v2-0-021c84d852e0@kernel.org>
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
X-Developer-Signature: v=1; a=openpgp-sha256; l=1811; i=brauner@kernel.org; h=from:subject:message-id; bh=wpJfI2N0Y4TYbGny8B/EWcsaN47/8hdz2WKuRaZg6Os=; b=owGbwMvMwCU28Zj0gdSKO4sYT6slMWS9bny056pefW1bw+0G9QWxvIVyC3XrvoZ2bGCV5J46b YcBi0tqRykLgxgXg6yYIotDu0m43HKeis1GmRowc1iZQIYwcHEKwETc3jIyPJ21usJ4wx/59rrj 73oYXwhfmLvodau6v+vZpyZ2wYlGEowMHzItDeUOXp9h3ywj4N1/bRkvB++3BTNNjTf/8um/cn0 /OwA=
X-Developer-Key: i=brauner@kernel.org; a=openpgp; fpr=4880B8C9BD0E5106FC070F4F7B3C391EFEA93624
Content-Transfer-Encoding: 8bit

proc_read_simdisk() looks at dev->filename without holding dev->lock. A
write to the same file detaches the disk and frees the name under the
lock, so a concurrent reader can copy out freed memory. Copy the name
with the lock held.

Fixes: b6c7e873daf7 ("xtensa: ISS: add host file-based simulated disk")
Cc: stable@vger.kernel.org
Signed-off-by: Christian Brauner (Amutable) <brauner@kernel.org>
---
 arch/xtensa/platforms/iss/simdisk.c | 25 ++++++++++++-------------
 1 file changed, 12 insertions(+), 13 deletions(-)

diff --git a/arch/xtensa/platforms/iss/simdisk.c b/arch/xtensa/platforms/iss/simdisk.c
index e51edb8cf872..1248d960e5d3 100644
--- a/arch/xtensa/platforms/iss/simdisk.c
+++ b/arch/xtensa/platforms/iss/simdisk.c
@@ -238,22 +238,21 @@ static ssize_t proc_read_simdisk(struct file *file, char __user *buf,
 			size_t size, loff_t *ppos)
 {
 	struct simdisk *dev = pde_data(file_inode(file));
-	const char *s = dev->filename;
-	if (s) {
-		ssize_t len = strlen(s);
-		char *temp = kmalloc(len + 2, GFP_KERNEL);
+	ssize_t len;
+	char *temp;
 
-		if (!temp)
-			return -ENOMEM;
+	/* a write sets at most a page, see proc_write_simdisk() */
+	temp = kmalloc(PAGE_SIZE + 2, GFP_KERNEL);
+	if (!temp)
+		return -ENOMEM;
 
-		len = scnprintf(temp, len + 2, "%s\n", s);
-		len = simple_read_from_buffer(buf, size, ppos,
-					      temp, len);
+	spin_lock(&dev->lock);
+	len = scnprintf(temp, PAGE_SIZE + 2, "%s\n", dev->filename ?: "");
+	spin_unlock(&dev->lock);
 
-		kfree(temp);
-		return len;
-	}
-	return simple_read_from_buffer(buf, size, ppos, "\n", 1);
+	len = simple_read_from_buffer(buf, size, ppos, temp, len);
+	kfree(temp);
+	return len;
 }
 
 static ssize_t proc_write_simdisk(struct file *file, const char __user *buf,

-- 
2.53.0

