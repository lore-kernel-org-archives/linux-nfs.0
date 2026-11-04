Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.remote-ip=100.103.45.18
ARC-Seal: i=1; d=subspace.kernel.org; s=arc20261015; a=rsa-sha256; cv=none;
	t=1793813417;
	b=gfD/6DFNjvtXO3CzdoPYk/Yhrx34a7WH6I8zYXExCVOeZ03BpvGvgfRHfVR3zo07NWrn
	 bUhqQGFn/i+qftNnPMXf0iHSxU6Bv37N7+lSQn7zKDGmBd+Js1F8wSXdPzjxZhUQ24X9h
	 CyRigXNadd5djExY0se9oCZlV07jQsv6ymIVi1d6DLxgRsnk7DX2W+A14nGd3p8z7RgBf
	 4VP0CUFThFqf1sLg0eVlnKfJSHmYNjswPCwN+wLZdSc/3sNtduZjPDmPc6zKE8qyrqdKg
	 aezBV4JQrMSvFMtjOcfL7Wu+1Jf0ps+/wgmmG4ehgPE7UImEqIVQY3XrHA9tNaBTRDw==
ARC-Message-Signature: i=1; d=subspace.kernel.org; s=arc20261015;
	a=rsa-sha256; c=relaxed/relaxed; t=1793813417;
	h=Received:DKIM-Signature:From:Date:Subject:MIME-Version:Content-Type:
	 Content-Transfer-Encoding:Message-Id:References:In-Reply-To:To:Cc:
	 X-Mailer:X-Developer-Signature:X-Developer-Key;
	bh=Bp2DPgSMAVNPpocNHMMHSMxcgQhQwNKqaFQNAmEUdgU=;
	b=LrYdNKvw8Ajr9ZccflA4DgKTvoJcBlFTfahxAS8hbD/J4++chd3qo9VQuc3FGBYvLLNS
	 P+BQqVg5dhbJ4mg2ozWn+TfzPOXELefMnjOm4ivTzubI9gGDRyoNZpKmf5LmihGfKN/gF
	 9ggfTDPWlgEg3Loaqd9U2YYHH6rH7im5YM+npjuOi4Wv00YnbG2ktDAUc7zqzgTaWBMdB
	 9rB9Ns9nZV7ZGxZ7G+Q3lnOy61YGCOkuMcQBaHqyDvFmVCLC94n0hnl+HwN3OAQYCNOhm
	 YL8nGnV3ZtOCp3HKrAPBT4tA2Xry282K0pXktQ9FLCxdtleiK22y/YzPkqB+qJ5p4Ng==
ARC-Authentication-Results: i=1; smtp.subspace.kernel.org; 
	dkim=pass header.d=kernel.org header.i=@kernel.org header.a=rsa-sha256 header.s=k20260515 header.b=g5u712B9;
	arc=none smtp.remote-ip=100.103.45.18
Received: from smtp.kernel.org (quasi.space.kernel.org [100.103.45.18])
	(using TLSv1.3 with cipher TLS_AES_256_GCM_SHA384 (256/256 bits)
	 key-exchange X25519 server-signature ECDSA (prime256v1))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id B6D69606A92F;
	Wed,  4 Nov 2026 17:30:16 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key, unprotected) header.d=kernel.org header.i=@kernel.org header.a=rsa-sha256 header.s=k20260515 header.b=g5u712B9
Received: by smtp.kernel.org (Postfix) with ESMTPSA id 70FBE1F000C1;
	Wed,  4 Nov 2026 17:30:03 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=kernel.org;
	s=k20260515; t=1793813416;
	bh=Bp2DPgSMAVNPpocNHMMHSMxcgQhQwNKqaFQNAmEUdgU=;
	h=From:Date:Subject:References:In-Reply-To:To:Cc;
	b=g5u712B9uyY/EHBMvMcIJjwX1Q9oNafVwZZdSTe+wWNmne5PBjIRnbjMdNBKEaIP4
	 4sN1akBTM0upEXPMnrPesATu9t0mv+J9tGR4BfcCUQnJpzUcbcj+IvUqAQlpKvEFAP
	 maIQiS285xRthBs8kUjqLULi7ZlP9EZaMs6jvYgyfDdyykDtrKuOIUKXiUE5xq8j0K
	 rnPkE+GVlVCE8ozm0404SgO7RYqyMkzZKzwWo1p+WxGQXY8MTkERhkp4+WNxvZiOYe
	 CguRECqkxpVtUS2A9kODUDoxnBc90vENA1/MJjeZ4tQ9xNPhj1ug3QG1Rnyknyga3s
	 5rdxM+QnpKA9g==
From: Christian Brauner <brauner@kernel.org>
Date: Wed, 04 Nov 2026 18:27:24 +0100
Subject: [PATCH v2 07/51] lockd: don't hand out the terminator of
 nlm_end_grace
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
Message-Id: <20261104-work-procfs-bugfixes-v2-7-bbf7d5546809@kernel.org>
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
X-Developer-Signature: v=1; a=openpgp-sha256; l=879; i=brauner@kernel.org;
 h=from:subject:message-id; bh=tKzHzMLxBoW/zY681xcBM67Jqe2y1s4JEAk9OycZ8F8=;
 b=owGbwMvMwCU28Zj0gdSKO4sYT6slMWS9zma88mPSwzMZES8ZvfsaK7K5NIr2+azZ3b+Xc1Xpm
 7Wz/9nbdJSyMIhxMciKKbI4tJuEyy3nqdhslKkBM4eVCWQIAxenAExkbT3DP623G/ymh8nr95bL
 Sj1ZqVz5I/v5xTDO2LLF07okt9w1Ws/wP0bKWD8yk0Xj8wP2OJmbXq1N7z9lRV6ZFj3BvzE/x+E
 BNwA=
X-Developer-Key: i=brauner@kernel.org; a=openpgp;
 fpr=4880B8C9BD0E5106FC070F4F7B3C391EFEA93624

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

