Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.remote-ip=100.103.45.18
ARC-Seal: i=1; d=subspace.kernel.org; s=arc20261015; a=rsa-sha256; cv=none;
	t=1793814598;
	b=PpdAh/g9DaRqv7RhIHnl12JZMsmFhsfY41u1Yva34PE2+rnLr9+9LkDqldsH7Jgv/zbk
	 cAX/oxiCfrM5OZtJroqeG7LTFAqvowGBHrUAAVyoZSH/WQT/kyHziJQR5N+hFTTZVxp72
	 LOvlbGm14f1hHzKzWsCrw8Cy300ZGcaEZr3dRRzkrVb9dPRrGOGdso6irlg6jYEouiGff
	 QYBv3X7eV29W2+f+M/evx4PF0bAISEQTRZtXf5OqoTsVa7GzhepZYha5GXnBQFWHbz7Jd
	 s538N+u871hA3eWwxwoOnQIZqK+4bjhMJiXqm7yDZun7hO1Ng564HitkZ1lBIC1m1Sw==
ARC-Message-Signature: i=1; d=subspace.kernel.org; s=arc20261015;
	a=rsa-sha256; c=relaxed/relaxed; t=1793814598;
	h=Received:DKIM-Signature:From:To:Cc:Subject:Date:Message-ID:
	 In-Reply-To:References:MIME-Version:Content-Type:X-Mailer:
	 X-Developer-Signature:X-Developer-Key:Content-Transfer-Encoding;
	bh=weMUCFn2uihXk/tOxGBDEw27Pws++kgwJ6Tcia3ltcw=;
	b=HuP2tlnA7T3Ow1v0DcvJ4OJU+iIUzWKwWUgCPfXqeeIDPLwm0453h+EOCyk1aDqjJOyU
	 L5R3HdDSDCeNPz8v+PZU/B6RdqLw04wHH5mnFVTFJQfVFDVT+LvxgOb4t0vQk26+TxFB3
	 CVvRYsctDbn8QPLyFct7DfGqt9SaWCd/tn+tBF91ognW8jSzP4eiD3FUKJSYjBPL+V76i
	 7lTtXWJLIUY18o0Pw63DRKphUQWe8y1tPZEAVGqOAjeggWgscEyFKEID9LG0P65dXBy5E
	 PsBma/FzSVViMHOElcKZN7iEwRcwa0cfJVL0c0kkC5g7ijm8+w9uvSFTj0zZ9ON/ocA==
ARC-Authentication-Results: i=1; smtp.subspace.kernel.org; 
	dkim=pass header.d=kernel.org header.i=@kernel.org header.a=rsa-sha256 header.s=k20260515 header.b=TjKPb5Zz;
	arc=none smtp.remote-ip=100.103.45.18
Received: from smtp.kernel.org (quasi.space.kernel.org [100.103.45.18])
	(using TLSv1.3 with cipher TLS_AES_256_GCM_SHA384 (256/256 bits)
	 key-exchange X25519 server-signature ECDSA (prime256v1))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 5624E6082BFC;
	Wed,  4 Nov 2026 17:49:58 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key, unprotected) header.d=kernel.org header.i=@kernel.org header.a=rsa-sha256 header.s=k20260515 header.b=TjKPb5Zz
Received: by smtp.kernel.org (Postfix) with ESMTPSA id 77A9F1F000C1;
	Wed,  4 Nov 2026 17:49:40 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=kernel.org;
	s=k20260515; t=1793814597;
	bh=weMUCFn2uihXk/tOxGBDEw27Pws++kgwJ6Tcia3ltcw=;
	h=From:To:Cc:Subject:Date:In-Reply-To:References;
	b=TjKPb5ZzIiyiPgvuQdFoHuUkVx/a9GRzTloH+KR4l/JxBBb+Ol/moI3iP+vc7jhxh
	 Ps/jhLkGJWT4b45mLDzTmXs0Nq6ur+emr3Mnae7d+PkH9J0ghZeeOzUERLhCb/2x/I
	 Bwr8JHwweuJMSvPLSvB9rFxVcNiRrk8Nku+fNgyLtGVeEaDxUpEY6iJFDv9syz/nxS
	 a2j63GShxcJSlKeqquyWTJ1SJRA6a75PgRtqXfY4thvlg42TMO3Ay+5b5+IY0bEO1l
	 k3RvIz3DDBF5vn8/zalT+H7o+LqH0DwmSQZgpn2Tax7AQIoVLkHn44OG3fzujjSSY4
	 17TkLkudUusDA==
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
Subject: [PATCH v2 19/51] xtensa: simdisk: don't read the file name without the lock
Date: Wed,  4 Nov 2026 18:47:05 +0100
Message-ID: <20261104-work-procfs-bugfixes-v2-19-bbf7d5546809@kernel.org>
In-Reply-To: <20261104-work-procfs-bugfixes-v2-0-bbf7d5546809@kernel.org>
References: <20261104-work-procfs-bugfixes-v2-0-bbf7d5546809@kernel.org>
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
X-Developer-Signature: v=1; a=openpgp-sha256; l=1811; i=brauner@kernel.org; h=from:subject:message-id; bh=wpJfI2N0Y4TYbGny8B/EWcsaN47/8hdz2WKuRaZg6Os=; b=owGbwMvMwCU28Zj0gdSKO4sYT6slMWS9zrtmmihY93BLSLDu9Ie5rjb2qRU3I+zPe+3cqF86e 5KJ7eaZHaUsDGJcDLJiiiwO7Sbhcst5KjYbZWrAzGFlAhnCwMUpABNZeo6R4WJUn/qcs7t1vaJm L5zZ9iJOJiprB/f/Sr7aQnnr1cdmdDIy7M/18T9/7EByzmbvb0u/Gdlr8edumNMXNW0bh1H7s7O CzAA=
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

