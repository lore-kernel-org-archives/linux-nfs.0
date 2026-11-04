Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.remote-ip=100.103.45.18
ARC-Seal: i=1; d=subspace.kernel.org; s=arc20261015; a=rsa-sha256; cv=none;
	t=1793813470;
	b=VSjWUUTKasgAvyxwLb5hCOJHeiy8BqABuxhS5mHZBxQrxNriMjW8z/Ohk6CXVSBPtJpA
	 oe3mPQc4ofbtaRddaLISY4E6GbhKcpn3NLaGkUf26aGl0PesIjjNQyiF/eY4IHVaO+WWd
	 jF9JUNd2SuEjFmlZn18MQRASUfst1rOd+SwKE91X2T/8Yw3hbgzrcZiAdGhqsJ4N9ezXe
	 H1bygdcW0edPto2WsUydpIxBjM4LU7K56oiMLAqX+s2hQSxav2+4ipWaf3+IVrMMEK3RT
	 g0O5O/4gE9FMqjjgmSg3n7+vSbGGOYFCm/rjIR/rBq+Bqbl8wrRIJfIqizmTiBaziig==
ARC-Message-Signature: i=1; d=subspace.kernel.org; s=arc20261015;
	a=rsa-sha256; c=relaxed/relaxed; t=1793813470;
	h=Received:DKIM-Signature:From:Date:Subject:MIME-Version:Content-Type:
	 Content-Transfer-Encoding:Message-Id:References:In-Reply-To:To:Cc:
	 X-Mailer:X-Developer-Signature:X-Developer-Key;
	bh=88D9snc5Fvfzc1+bIGylCXCzBagXIGxBtzK0BL7vNTc=;
	b=CUZCU8dXTJ0mVKU2okASl3XxgJDnlZDhSm38CX1Sz6+v/qKtiNyqgMWDxPLd/QIdC15R
	 7qyLbh9yt3QIKDYLA5d7WmccAGPkjWs4Vf6i76TcAbdMIGX4wx84oI+M/zWNVy9240lc9
	 9LsLLwNjS4ObAhvXi+TK7S7KYt1iZ6bYqZXvtlkrf/564642msTvZAm03EILTokkNbGAN
	 1WkAD/T8AUMYmQDMQBBhCWJRQOd+mYk1C6ezv50dxomu6fP/TAjOjUGWvSYLVdwEysZAv
	 xU16PgauFiz0dUryV6yUcsRBBSSNq1XgquLgCHiPtnzrMd3qUeYwHKm3jDx6Q9EmsDA==
ARC-Authentication-Results: i=1; smtp.subspace.kernel.org; 
	dkim=pass header.d=kernel.org header.i=@kernel.org header.a=rsa-sha256 header.s=k20260515 header.b=iXWQB5YV;
	arc=none smtp.remote-ip=100.103.45.18
Received: from smtp.kernel.org (quasi.space.kernel.org [100.103.45.18])
	(using TLSv1.3 with cipher TLS_AES_256_GCM_SHA384 (256/256 bits)
	 key-exchange X25519 server-signature ECDSA (prime256v1))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id BB6A5606D82C;
	Wed,  4 Nov 2026 17:31:09 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key, unprotected) header.d=kernel.org header.i=@kernel.org header.a=rsa-sha256 header.s=k20260515 header.b=iXWQB5YV
Received: by smtp.kernel.org (Postfix) with ESMTPSA id B4B1D1F00A1A;
	Wed,  4 Nov 2026 17:30:56 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=kernel.org;
	s=k20260515; t=1793813469;
	bh=88D9snc5Fvfzc1+bIGylCXCzBagXIGxBtzK0BL7vNTc=;
	h=From:Date:Subject:References:In-Reply-To:To:Cc;
	b=iXWQB5YV7Kg3RUIa93AFETN1SWavnlv7A2+KZO2N+8yOFr8Nxzd0awnAdzvrIJxvb
	 iwsd7/OXYpIIPoZK/zUDKbVBITgvtCbvRQFx8uTJc/yHlxoEsUDPjmLWXFVoYRwB+8
	 bO30Hh/TGyjWLlo74Zlkba+soU5l3Xz8vC5ijD1rLCYQM6eOaon/FPI6bnSWWK8jej
	 tu9UAUvRhODWIvMSMgtdBEbC7EPtC8P3EjAe6KdJiEatnSukLFtVejwpJye5oyaiRy
	 wq31IKuon20SWlj10PyNweaP+Lu1uhJgSBnAqLcp9bykPHQNRISX1eYd4dr2KLd0HB
	 SFAF9fcqUvWgQ==
From: Christian Brauner <brauner@kernel.org>
Date: Wed, 04 Nov 2026 18:27:28 +0100
Subject: [PATCH v2 11/51] sparc: led: consume the whole write
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
Message-Id: <20261104-work-procfs-bugfixes-v2-11-bbf7d5546809@kernel.org>
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
 Chuck Lever <cel@kernel.org>
X-Mailer: b4 0.17-dev
X-Developer-Signature: v=1; a=openpgp-sha256; l=1161; i=brauner@kernel.org;
 h=from:subject:message-id; bh=5p0zMz40BbKdivFQo1NNbyIz4tkvEi3yC5tXL4aXaeU=;
 b=owGbwMvMwCU28Zj0gdSKO4sYT6slMWS9zmaz+l255/dcMbeVTrFanCknSsvkc1YVB3m43Lw5N
 drx0iaxjlIWBjEuBlkxRRaHdpNwueU8FZuNMjVg5rAygQxh4OIUgIkI32BkeHvU6KWe6gWDSokM
 AXPh+UdezXsoZMqyb+L5Puufyec6zBkZ1nYtn1J1+eNm5X8arkoP+O5vXXg4NDqzfr7dM//7HjX
 /+QA=
X-Developer-Key: i=brauner@kernel.org; a=openpgp;
 fpr=4880B8C9BD0E5106FC070F4F7B3C391EFEA93624

led_proc_write() looks at the first eight bytes of a write and returns
that many, so a writer that loops until everything is written, stdio
does, sends the rest as a second command. That one is unknown and
switches the LED off. Return the whole count, the rest is ignored.

Fixes: ee1858d3122d ("[SPARC]: Add sun4m LED driver.")
Signed-off-by: Christian Brauner (Amutable) <brauner@kernel.org>
---
 arch/sparc/kernel/led.c | 3 ++-
 1 file changed, 2 insertions(+), 1 deletion(-)

diff --git a/arch/sparc/kernel/led.c b/arch/sparc/kernel/led.c
index 9b53ac1fe533..a1478de9fe5d 100644
--- a/arch/sparc/kernel/led.c
+++ b/arch/sparc/kernel/led.c
@@ -68,6 +68,7 @@ static int led_proc_open(struct inode *inode, struct file *file)
 static ssize_t led_proc_write(struct file *file, const char __user *buffer,
 			      size_t count, loff_t *ppos)
 {
+	size_t len = count;
 	char *buf = NULL;
 
 	if (count > LED_MAX_LENGTH)
@@ -102,7 +103,7 @@ static ssize_t led_proc_write(struct file *file, const char __user *buffer,
 
 	kfree(buf);
 
-	return count;
+	return len;
 }
 
 static const struct proc_ops led_proc_ops = {

-- 
2.53.0

