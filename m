Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.remote-ip=100.103.45.18
ARC-Seal: i=1; d=subspace.kernel.org; s=arc20261015; a=rsa-sha256; cv=none;
	t=1793814525;
	b=u/xP9CieB8CFcjvH6YQ5AZxbw+eeqouUvvUqg1xcMCHNGN3h4EYvZkpyV9ahmHSMNhG6
	 29KZI2j8vjWBLqdrWemVs5tkQKgqm1HgOeB1KU91LS05VjdlGYfucruSF68DEycw0mXmR
	 j8lxYN5QLJukjGiZ1n+FOiBPnfFpfW9Uo54DvLlx7eJPINmXGUAZsAd8mIe6eDJM6rdmu
	 AzyJpg97UChMGiBueDQ9eUdr228jdgwRP7QAbtiFiCag+5r7GJi3hvce7xz/HMDgs1jl4
	 doPMTrg+k3m8KiLyaBTeB40UtQtZo9BUn23QwcHmBV8LXHp7Zxk/OwgkKko3uIafvDA==
ARC-Message-Signature: i=1; d=subspace.kernel.org; s=arc20261015;
	a=rsa-sha256; c=relaxed/relaxed; t=1793814525;
	h=Received:DKIM-Signature:From:To:Cc:Subject:Date:Message-ID:
	 In-Reply-To:References:MIME-Version:Content-Type:X-Mailer:
	 X-Developer-Signature:X-Developer-Key:Content-Transfer-Encoding;
	bh=0oFqdYtQQ93hmf66Xu9P3kJmoMCkLJeiEqd5UgVqoAA=;
	b=atIeio7gOLlyBIiIi7kPz4Hh4yK1MzmM4Hntohc3wdjL4D++C3BEB8IjwEmNJ//Ceks/
	 6xUESH27mpoOykPnKix+L3Fw4suFIZKvkgkIPM3Q7zfnGKSJ7sjW9tCRik5LuAczv9RFO
	 pcXQpEnFQTw2Wo24ewlsIbwLbG4W4n3NAdXiJKhpzZneggNejjnqm+KMtKe5Bk7SmH01v
	 PHU+VONw6qIA12dhmilBxO24cbPFljIY6Yk3xVLiIU2g7Mt8ICBVP0FHgCGPGUyJUa2yh
	 WstKDHO9pdERNR8qYO4eBg3vkw26Wba2/iRdHq0njA1FjehoLgWdOU6ZrXPoXD1jF5g==
ARC-Authentication-Results: i=1; smtp.subspace.kernel.org; 
	dkim=pass header.d=kernel.org header.i=@kernel.org header.a=rsa-sha256 header.s=k20260515 header.b=noCFKCgL;
	arc=none smtp.remote-ip=100.103.45.18
Received: from smtp.kernel.org (quasi.space.kernel.org [100.103.45.18])
	(using TLSv1.3 with cipher TLS_AES_256_GCM_SHA384 (256/256 bits)
	 key-exchange X25519 server-signature ECDSA (prime256v1))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 875B7606EE89;
	Wed,  4 Nov 2026 17:48:45 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key, unprotected) header.d=kernel.org header.i=@kernel.org header.a=rsa-sha256 header.s=k20260515 header.b=noCFKCgL
Received: by smtp.kernel.org (Postfix) with ESMTPSA id D05981F00A25;
	Wed,  4 Nov 2026 17:48:26 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=kernel.org;
	s=k20260515; t=1793814525;
	bh=0oFqdYtQQ93hmf66Xu9P3kJmoMCkLJeiEqd5UgVqoAA=;
	h=From:To:Cc:Subject:Date:In-Reply-To:References;
	b=noCFKCgLdEz18/sqF1FCWtVxsv/QyKV8mQTymoxWK+iiCMJtG9Zq8MeqLvY3hYEr3
	 hW0ksLKsCqDeUuyeCxIewkpGMAQxP5+SbkknINTi3v5SKU9g7u+iNy/q6EWBSY9M47
	 a1HQI18KNvLYtRt2WygIYuE3c2BaTAI19pyJSUQbaTz/JNG7KXivQ8k0SWqUWZ//Sp
	 Lzi0wOR/fuOZR0XnuR86I0XCuZc2sD6cH4+TLvQA7RQoawB8oy5aktiHmUQYq3Xkoz
	 UcEpl9KlnnxOyIAxi4Pq7KbGS/jLgYWdG338W7ywff7d3Gg7oQPjS/4lnVEktzCirU
	 mKurYZoNKsVQw==
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
Subject: [PATCH v2 15/51] PCI/proc: don't truncate the position of config space accesses
Date: Wed,  4 Nov 2026 18:47:01 +0100
Message-ID: <20261104-work-procfs-bugfixes-v2-15-bbf7d5546809@kernel.org>
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
X-Developer-Signature: v=1; a=openpgp-sha256; l=2714; i=brauner@kernel.org; h=from:subject:message-id; bh=57Zv3BgjxHPYJgAYtfWWUhWCD6jzurA4v7Zp2iJg+04=; b=owGbwMvMwCU28Zj0gdSKO4sYT6slMWS9zrv4QSS7QmxmKncEz+ddbFt2TmsVZdYQ90tKWuXxf jfnr3lMHaUsDGJcDLJiiiwO7Sbhcst5KjYbZWrAzGFlAhnCwMUpABMp/8jw39du2rR1IQ2zol85 T2Hk+y4ZopKb1hC0/t8rkxtned7ZfWVkaIoWnH59RriBT2Zy3NRn+o8WPb/8RpnjV+SftqXfD/1 8xQIA
X-Developer-Key: i=brauner@kernel.org; a=openpgp; fpr=4880B8C9BD0E5106FC070F4F7B3C391EFEA93624
Content-Transfer-Encoding: 8bit

proc_bus_pci_write() truncates the file position to an int. A pwrite()
at an offset like 0xfffff000 turns it negative, the check against the
size of the config space passes and the count it clamps to ends up
larger than what was written. The loop then reads past the end of the
caller's buffer and writes all of it into config space at negative
offsets, which pci_user_write_config_*() pass on to the config
accessors unchecked. The write also returns more than it was asked to
write.

An offset above 4G that truncates to a small positive value writes to
the start of config space instead. proc_bus_pci_read() keeps the
position in an unsigned int, so a read at such an offset returns the
start of config space instead of hitting EOF.

Check the position against the size of the config space before
narrowing it.

Fixes: 1da177e4c3f4 ("Linux-2.6.12-rc2")
Cc: stable@vger.kernel.org
Signed-off-by: Christian Brauner (Amutable) <brauner@kernel.org>
---
 drivers/pci/proc.c | 15 ++++++++-------
 1 file changed, 8 insertions(+), 7 deletions(-)

diff --git a/drivers/pci/proc.c b/drivers/pci/proc.c
index 3d7a9ed5fc22..e0dc70123f82 100644
--- a/drivers/pci/proc.c
+++ b/drivers/pci/proc.c
@@ -32,8 +32,7 @@ static ssize_t proc_bus_pci_read(struct file *file, char __user *buf,
 				 size_t nbytes, loff_t *ppos)
 {
 	struct pci_dev *dev = pde_data(file_inode(file));
-	unsigned int pos = *ppos;
-	unsigned int cnt, size;
+	unsigned int pos, cnt, size;
 
 	/*
 	 * Normal users can read only the standardized portion of the
@@ -51,8 +50,9 @@ static ssize_t proc_bus_pci_read(struct file *file, char __user *buf,
 	if (!nbytes)
 		return 0;
 
-	if (pos >= size)
+	if (*ppos >= size)
 		return 0;
+	pos = *ppos;
 	if (nbytes >= size)
 		nbytes = size;
 	if (pos + nbytes > size)
@@ -119,9 +119,8 @@ static ssize_t proc_bus_pci_write(struct file *file, const char __user *buf,
 {
 	struct inode *ino = file_inode(file);
 	struct pci_dev *dev = pde_data(ino);
-	int pos = *ppos;
 	int size = dev->cfg_size;
-	int cnt, ret;
+	int pos, cnt, ret;
 
 	ret = security_locked_down(LOCKDOWN_PCI_ACCESS);
 	if (ret)
@@ -130,14 +129,16 @@ static ssize_t proc_bus_pci_write(struct file *file, const char __user *buf,
 	if (!nbytes)
 		return 0;
 
+	if (*ppos >= size)
+		return 0;
+	pos = *ppos;
+
 	if (resource_is_exclusive(&dev->driver_exclusive_resource, pos, nbytes)) {
 		pci_warn_once(dev, "%s: Unexpected write to kernel-exclusive config offset %x",
 			      current->comm, pos);
 		add_taint(TAINT_USER, LOCKDEP_STILL_OK);
 	}
 
-	if (pos >= size)
-		return 0;
 	if (nbytes >= size)
 		nbytes = size;
 	if (pos + nbytes > size)

-- 
2.53.0

