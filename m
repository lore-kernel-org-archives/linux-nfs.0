Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.remote-ip=100.103.45.18
ARC-Seal: i=1; d=subspace.kernel.org; s=arc20261015; a=rsa-sha256; cv=none;
	t=1793629434;
	b=v7/cdcIqfJgssN5m/4cca2D31tMm+4EtXKuYvnVw9EiI/+q0NulGl37HnWp9MSB63s48
	 0hsDhDP76I1k6MrXo9PumbfUqASV6i5kghvMvCSpfAL9wqWwz0T2Z0HJ15Z3PQ9dU8YXE
	 Auh7WJvXv3jVMuC7mTT0X77A9dOgDWqlTc1FZdBTvVchRuIN/Hbyb6azLO1UU8TuVLbtR
	 Vh+E4782XtGunjIYKg/nEfUVnY30fBFxtq6tgIBARENZlkbynU2zk2VuY/mM0zgY2O6UZ
	 /+9MfiJojaNk1xJ7P9n8T59CQslUO3eRSpwPhug2cX6lnw4BasTiJWbW6QGlnUO+c6g==
ARC-Message-Signature: i=1; d=subspace.kernel.org; s=arc20261015;
	a=rsa-sha256; c=relaxed/relaxed; t=1793629434;
	h=Received:DKIM-Signature:From:Date:Subject:MIME-Version:Content-Type:
	 Content-Transfer-Encoding:Message-Id:References:In-Reply-To:To:Cc:
	 X-Mailer:X-Developer-Signature:X-Developer-Key;
	bh=5idTO632MfTOh8DHBwsM5N+e4TPz7tW3oLCXLVOM1bU=;
	b=YeCQswliBl/EYY09kmoNIxUImcYvu37SWsLxtxBJY4+cFBGOXbunKy0IusfA92+fScco
	 6Kw5B1HEhGZqm4frGBneIN8M1UxLaDiLf+zh6SOJKwbYnunL+oN2gq5CLuOmplnXOoaYl
	 LoS5Vta9KjvUZ6YEq6B/FOAEPS6glEAouPeP0LwIFuu0E6ayDCounI7jXpvBOKO0OW5RX
	 7rXw5PTjNwX8s82I8NMT7dLqaguY1pG9JO0J7REdHSH6yoqhp+ixkGOFxrTkKbZ+23kCy
	 4zj/LnLCbCyStHjzy+QwMrFpJDkV1NG2p77bQNXpzZaLg8U6h5KAwHJG9AsIsM0kd/w==
ARC-Authentication-Results: i=1; smtp.subspace.kernel.org; 
	dkim=pass header.d=kernel.org header.i=@kernel.org header.a=rsa-sha256 header.s=k20260515 header.b=bTZqC8ZG;
	arc=none smtp.remote-ip=100.103.45.18
Received: from smtp.kernel.org (quasi.space.kernel.org [100.103.45.18])
	(using TLSv1.3 with cipher TLS_AES_256_GCM_SHA384 (256/256 bits)
	 key-exchange X25519 server-signature ECDSA (prime256v1))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 45951606A5A3;
	Mon,  2 Nov 2026 14:23:54 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key, unprotected) header.d=kernel.org header.i=@kernel.org header.a=rsa-sha256 header.s=k20260515 header.b=bTZqC8ZG
Received: by smtp.kernel.org (Postfix) with ESMTPSA id 09FB41F00A17;
	Mon,  2 Nov 2026 14:23:39 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=kernel.org;
	s=k20260515; t=1793629433;
	bh=5idTO632MfTOh8DHBwsM5N+e4TPz7tW3oLCXLVOM1bU=;
	h=From:Date:Subject:References:In-Reply-To:To:Cc;
	b=bTZqC8ZGdXxcFQd/3hUg3IW0rejRlM5K7QNfkjVY794R3YHFyVPBjLRGBUayKfnuB
	 o4SatPA8T6TNXjcltzn1X/uXTJRuPb2Rlfe8Ay7Lihwlip36LKfkuZzZ2uLD6o1lsn
	 vWG9sGTbL522XI7qvpHjUHz0MjvfEW17lvoFh1SmnCSdWAreu8wFgjZqF1c34Gdkms
	 8WxYyheLECrp0gW7AmhDwmWf847MgsFNk7fCgXMkAYJi+8MwP0s9Ehv9+slB77KTjN
	 Sw08w8UDfVr3lkJvosLxlggPqTYkDbchMzBmGfJx4chWnQ4NiIdZtKUt6Nf2GmPnXa
	 Jl4P8fqea13Rw==
From: Christian Brauner <brauner@kernel.org>
Date: Mon, 02 Nov 2026 15:21:24 +0100
Subject: [PATCH RFC 09/38] ALSA: info: don't write past the end of a data
 entry
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
Message-Id: <20261102-work-procfs-bugfixes-v1-9-59422ed3e465@kernel.org>
References: <20261102-work-procfs-bugfixes-v1-0-59422ed3e465@kernel.org>
In-Reply-To: <20261102-work-procfs-bugfixes-v1-0-59422ed3e465@kernel.org>
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
X-Developer-Signature: v=1; a=openpgp-sha256; l=1286; i=brauner@kernel.org;
 h=from:subject:message-id; bh=QDMkZvLaF3IWyPhoUUb9QYkcrNtI4YpDxPIetQD5jl0=;
 b=owGbwMvMwCU28Zj0gdSKO4sYT6slMWS9mJOVdu4T53QO71keyQs+h0u8P+U2ReHO2uq+t72Xn
 8zfu3i/eUcpC4MYF4OsmCKLQ7tJuNxynorNRpkaMHNYmUCGMHBxCsBE2h8x/M+p1jq63Xz2BXau
 4IAvwU63lx9v/bDSeMfWNnHlszsNnwsyMhyxXa9lwZT9csfJKq+qsC5mVf35X28Ym77fVPdQjT/
 rICMA
X-Developer-Key: i=brauner@kernel.org; a=openpgp;
 fpr=4880B8C9BD0E5106FC070F4F7B3C391EFEA93624

snd_info_entry_write() clamps the count to what is left of the entry
by computing entry->size - pos as a size_t. For a position past the end
that wraps and the write goes to the driver unclamped, for opl4 into
sample memory outside of what the entry covers. At the end of the entry
the driver gets a count of 0 and vmalloc(0) warns. Before the clamp
moved into the common code the driver ignored such writes. Fail them
with -ENOSPC instead, like a block device does at the end of the
device. Returning 0 would make writers that use stdio retry forever.

Fixes: d97e1b78239c ("ALSA: info - Check file position validity in common layer")
Cc: stable@vger.kernel.org
Signed-off-by: Christian Brauner (Amutable) <brauner@kernel.org>
---
 sound/core/info.c | 2 ++
 1 file changed, 2 insertions(+)

diff --git a/sound/core/info.c b/sound/core/info.c
index c4d57d0809ad..982087bc8575 100644
--- a/sound/core/info.c
+++ b/sound/core/info.c
@@ -171,6 +171,8 @@ static ssize_t snd_info_entry_write(struct file *file, const char __user *buffer
 	pos = *offset;
 	if (!valid_pos(pos, count))
 		return -EIO;
+	if (pos >= entry->size)
+		return count ? -ENOSPC : 0;
 	if (count > 0) {
 		size_t maxsize = entry->size - pos;
 		count = min(count, maxsize);

-- 
2.53.0

