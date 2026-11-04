Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.remote-ip=100.103.45.18
ARC-Seal: i=1; d=subspace.kernel.org; s=arc20261015; a=rsa-sha256; cv=none;
	t=1793819848;
	b=ECI31XOGzY4YKONRoGeTfvEXPY17K1OA3PQG2dAFIHDUFuJSOFOPG/VOyduIkOam+P5h
	 beveG6Xp5tez6ek8HMCVM+qXuoytbexlvpGwV/0LzakSQFeioErI5tnK1LAGDShqhnzje
	 HabE/Q2ZuuaE+nQny0Xa1bI6vSe/qGsAxeUqPnJjM6WtpLyGs00ju1jnPj3Uiqg6B4oCj
	 fSDSsEumtnqTdbFmI0tzzud99BzsMxOo3rOEoVK0c5nLpkoe0YrDknRTfJ+pFBW890cpJ
	 VKpsjwDg7125+xkkzW1o0NqaoezOLu+PvzTT6NeNGLIun9gy1eJqq/b3yfUp5h/NrCw==
ARC-Message-Signature: i=1; d=subspace.kernel.org; s=arc20261015;
	a=rsa-sha256; c=relaxed/relaxed; t=1793819848;
	h=Received:DKIM-Signature:From:To:Cc:Subject:Date:Message-ID:
	 In-Reply-To:References:MIME-Version:Content-Type:X-Mailer:
	 X-Developer-Signature:X-Developer-Key:Content-Transfer-Encoding;
	bh=jP/hayhlpAKZdjJKk3r9BHeVVOYyvJcLU3d1z3kH9u8=;
	b=Lx3Bm7LWmseZ+lEI55iTshoXZh/FGfTEpF75sbPnpohDHXggSqCAHwrS5JeSdtiqA6Xt
	 /8drBxUJgoz/3wME6ulGCDqPX4GDh+g3zqyDZ1nWYACooU7SySVMWngwhf0RMHES2eM1c
	 whNav5yFNntennYfzFzR1II/eNjs/h9KIr3ClAB7lr8hVciABvDUjehrtdyCV9LP9Xnua
	 i9XIg0O4oe3GW4ij+sgLMUuzxKPKm9W1Pck8Pw+QaThe4emoYvfR6tO5e6qxXu13alZa6
	 bvIz707cc0oNrM0sG32/inAWlte8syFf0BUTEvGL7kzIsXHdxLZKealfc7ClEfRZ0zw==
ARC-Authentication-Results: i=1; smtp.subspace.kernel.org; 
	dkim=pass header.d=kernel.org header.i=@kernel.org header.a=rsa-sha256 header.s=k20260515 header.b=KpHzZpnF;
	arc=none smtp.remote-ip=100.103.45.18
Received: from smtp.kernel.org (quasi.space.kernel.org [100.103.45.18])
	(using TLSv1.3 with cipher TLS_AES_256_GCM_SHA384 (256/256 bits)
	 key-exchange X25519 server-signature ECDSA (prime256v1))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 8E7626083638;
	Wed,  4 Nov 2026 19:17:28 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key, unprotected) header.d=kernel.org header.i=@kernel.org header.a=rsa-sha256 header.s=k20260515 header.b=KpHzZpnF
Received: by smtp.kernel.org (Postfix) with ESMTPSA id 79C9F1F00A24;
	Wed,  4 Nov 2026 19:17:16 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=kernel.org;
	s=k20260515; t=1793819848;
	bh=jP/hayhlpAKZdjJKk3r9BHeVVOYyvJcLU3d1z3kH9u8=;
	h=From:To:Cc:Subject:Date:In-Reply-To:References;
	b=KpHzZpnFwT6+C0q0yRCi5k/OA66tRS7eBzT8lt1HaWQE8e8svE3VZCRBnfRHdCzx7
	 71y/CPv6HCeTe9zbap2gT5FJuzj5hekBtO1a4cjxKuetzIxGjHALxdRgkDffBvgqoN
	 /aj76OWmFdznND17QWfa+CPtL2LoFKokFbuci0W4IBDDUUsoZwEUSEMsIoP5ROVtaD
	 UYsfpJY8su6lg+vsurlkAT18SVCFHIc8HLWY3wDZz/GvQ7lhgYrpLIwR5WyV8knPdX
	 rwvwNGe1ypF9HhdxdQGkkPDxlpkOU61C82qjywHhkl5yTgB9ONziIAgGKfFuFYu0iv
	 y/71Zwy9XejIg==
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
Subject: [PATCH RESEND v2 05/51] xtensa: simdisk: remove the proc entry before the disk
Date: Wed,  4 Nov 2026 20:17:14 +0100
Message-ID: <20261104-work-procfs-bugfixes-v2-5-021c84d852e0@kernel.org>
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
X-Developer-Signature: v=1; a=openpgp-sha256; l=1246; i=brauner@kernel.org; h=from:subject:message-id; bh=f7Qg/00vnZM3tuJ138yAFxD6JPv6/GBN+HDx2x0z8gg=; b=owGbwMvMwCU28Zj0gdSKO4sYT6slMWS9brxQmmA/984KHvt9Xz1eFefxl8hqpieb9fosObahV 1Ne5l9gRwkLgxgXg6yYIotDu0m43HKeis1GmRowc1iZQIYwcHEKwERykxj+u2j/eB40M+7p2v17 /GMmXT/na+Ctz77txmH9Sb+NLH5yrWH4HpzAeT45SPnv5UMnF7jMebDmtMJKXyf/NT8uPWe+O7+ RBwA=
X-Developer-Key: i=brauner@kernel.org; a=openpgp; fpr=4880B8C9BD0E5106FC070F4F7B3C391EFEA93624
Content-Transfer-Encoding: 8bit

simdisk_teardown() frees the gendisk and only then removes
/proc/simdisk/<n>. A write to that entry in between attaches the file
that was written to the disk, and simdisk_attach() sets the capacity of
the gendisk that is gone. Remove the entry first, remove_proc_entry()
waits for a writer that is in the middle of that.

Fixes: b6c7e873daf7 ("xtensa: ISS: add host file-based simulated disk")
Cc: stable@vger.kernel.org
Signed-off-by: Christian Brauner (Amutable) <brauner@kernel.org>
---
 arch/xtensa/platforms/iss/simdisk.c | 3 ++-
 1 file changed, 2 insertions(+), 1 deletion(-)

diff --git a/arch/xtensa/platforms/iss/simdisk.c b/arch/xtensa/platforms/iss/simdisk.c
index a2ddb49c269d..e51edb8cf872 100644
--- a/arch/xtensa/platforms/iss/simdisk.c
+++ b/arch/xtensa/platforms/iss/simdisk.c
@@ -379,12 +379,13 @@ static void simdisk_teardown(struct simdisk *dev, int which,
 {
 	char tmp[2] = { '0' + which, 0 };
 
+	/* a write to the entry attaches a file to the disk, so it goes first */
+	remove_proc_entry(tmp, procdir);
 	simdisk_detach(dev);
 	if (dev->gd) {
 		del_gendisk(dev->gd);
 		put_disk(dev->gd);
 	}
-	remove_proc_entry(tmp, procdir);
 }
 
 static void __exit simdisk_exit(void)

-- 
2.53.0

