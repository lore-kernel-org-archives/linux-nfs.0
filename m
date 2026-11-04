Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.remote-ip=100.103.45.18
ARC-Seal: i=1; d=subspace.kernel.org; s=arc20261015; a=rsa-sha256; cv=none;
	t=1793819877;
	b=i6IwoLXOYGB9R0MzEU6gfsfciydFAJzdCF1JqM73AcLYi2aevhk+cg1mMrE43kKIgv5g
	 ipeAvkGBbTn6oSIGFkKnT3Nw1FKW2qwHiDNBRZ7PAly/SQ1eRhnafp1aW2YQhve7BVKYq
	 PaXdCWC90zcItTkWzQNWeZ2wcInyVdzqLr3wMRRsaj2RJBhPytMaDVXAqDT2aVR1rRmP6
	 hzgMdztXgKXJ7ue0QF9Y3sE1X/3S1KuQkM6LTKkqy9IXpn/PDTpW3pJevo+D2Fg8DjNJh
	 T6KYD03zXx5V9AXNaUQQtdAWpjxJ7/gLEeMw9zreHkLFl/kojLuQ6OlftGHbRlTLViQ==
ARC-Message-Signature: i=1; d=subspace.kernel.org; s=arc20261015;
	a=rsa-sha256; c=relaxed/relaxed; t=1793819877;
	h=Received:DKIM-Signature:From:To:Cc:Subject:Date:Message-ID:
	 In-Reply-To:References:MIME-Version:Content-Type:X-Mailer:
	 X-Developer-Signature:X-Developer-Key:Content-Transfer-Encoding;
	bh=Bp2DPgSMAVNPpocNHMMHSMxcgQhQwNKqaFQNAmEUdgU=;
	b=OUDzRoUgvlJlHy8+hS3IX8VXzQGZ7hwVqij1GjH70oJCJMH2KJQn8gK9p1AwA3FAAX1I
	 CeKVH49VRTUItuTc9jgeeKW0ViChP+RwW43A91o7b21BvHOfnKenlRq3w30rjF9iTEt44
	 rFVw6W0nd4vdo9bIQLSLklod0kqtxXDJx2yeBBGAAHxtgxwR1oi3AZV99ZbtHxhKgP9ZA
	 8B5mMe085cSdPyls/PiJ2jSRbn1dBpxM/LkXaC0W8RyrIomWfCMvlFDQ6RkfKXbe3koxx
	 FO2il5XjAfTaEk0V9F9LiJFoJ08Y62Cw9zq3n7YZz4DjFyjCdmICm3pnhfC1mV451MQ==
ARC-Authentication-Results: i=1; smtp.subspace.kernel.org; 
	dkim=pass header.d=kernel.org header.i=@kernel.org header.a=rsa-sha256 header.s=k20260515 header.b="onbfdV/H";
	arc=none smtp.remote-ip=100.103.45.18
Received: from smtp.kernel.org (quasi.space.kernel.org [100.103.45.18])
	(using TLSv1.3 with cipher TLS_AES_256_GCM_SHA384 (256/256 bits)
	 key-exchange X25519 server-signature ECDSA (prime256v1))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 30D4B606A334;
	Wed,  4 Nov 2026 19:17:57 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key, unprotected) header.d=kernel.org header.i=@kernel.org header.a=rsa-sha256 header.s=k20260515 header.b=onbfdV/H
Received: by smtp.kernel.org (Postfix) with ESMTPSA id 496051F000C1;
	Wed,  4 Nov 2026 19:17:45 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=kernel.org;
	s=k20260515; t=1793819877;
	bh=Bp2DPgSMAVNPpocNHMMHSMxcgQhQwNKqaFQNAmEUdgU=;
	h=From:To:Cc:Subject:Date:In-Reply-To:References;
	b=onbfdV/HTacMnVbqXJ+FWmQQPtyp9R0J4UgJy9QwpRXMNAUpXq4U5MgLOpJJmdqil
	 A0IpzV3lIP35dJV6mQZjczsBbIm16npn5PD8YgolOlJ1tMWq4drLkt1BRme9A6hdpk
	 hU7if+GjyblRW+XhOHwJUvOM5bncZ4wy7T8dJkSSmoqVJFYODR5oteYh/K8C4sjSv7
	 T90fJXFV4MCDOisGIN4JIrvvLoPWPs3/TneCCv2v3EeHxNcbD6g2Laj9xr6GhUYSzJ
	 UbZZpN0HIrsvDaR+/nImX8hLuzR+la3jElQ0/AQag/TzZMVgu2cf2gdOENudtrxOC7
	 u98wrpF2+gfGQ==
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
Subject: [PATCH RESEND v2 07/51] lockd: don't hand out the terminator of nlm_end_grace
Date: Wed,  4 Nov 2026 20:17:43 +0100
Message-ID: <20261104-work-procfs-bugfixes-v2-7-021c84d852e0@kernel.org>
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
X-Developer-Signature: v=1; a=openpgp-sha256; l=879; i=brauner@kernel.org; h=from:subject:message-id; bh=tKzHzMLxBoW/zY681xcBM67Jqe2y1s4JEAk9OycZ8F8=; b=owGbwMvMwCU28Zj0gdSKO4sYT6slMWS9brz82W5pn1bu8jVTxGdEXE56r5qmzRPmKXZbfpl5N e9UmTVSHaUsDGJcDLJiiiwO7Sbhcst5KjYbZWrAzGFlAhnCwMUpABN5aMHwv1BmWTKrQaW1pau+ y7lc/V6hFSvly7z1GnL9Bfe/by3pYGSYdlT+a0yoMVdMgqbeooRHhxKrFq9gfqp47glfRsvFU/e YAQ==
X-Developer-Key: i=brauner@kernel.org; a=openpgp; fpr=4880B8C9BD0E5106FC070F4F7B3C391EFEA93624
Content-Transfer-Encoding: 8bit

nlm_end_grace_read() answers with "Y\n" or "N\n" from a three byte
buffer and hands out all three bytes, the terminating NUL included.
Leave the NUL out.

Fixes: d68e3c4aa416 ("lockd: add a /proc/fs/lockd/nlm_end_grace file")
Signed-off-by: Christian Brauner (Amutable) <brauner@kernel.org>
---
 fs/lockd/procfs.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/fs/lockd/procfs.c b/fs/lockd/procfs.c
index a01f08c8c2f3..74f7ab77535a 100644
--- a/fs/lockd/procfs.c
+++ b/fs/lockd/procfs.c
@@ -57,7 +57,7 @@ nlm_end_grace_read(struct file *file, char __user *buf, size_t size,
 	resp[1] = '\n';
 	resp[2] = '\0';
 
-	return simple_read_from_buffer(buf, size, pos, resp, sizeof(resp));
+	return simple_read_from_buffer(buf, size, pos, resp, sizeof(resp) - 1);
 }
 
 static const struct proc_ops lockd_end_grace_proc_ops = {

-- 
2.53.0

