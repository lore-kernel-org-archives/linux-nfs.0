Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.remote-ip=100.103.45.18
ARC-Seal: i=1; d=subspace.kernel.org; s=arc20261015; a=rsa-sha256; cv=none;
	t=1793820140;
	b=bOBICy6Dj9CTXnEceF7geiRFDBpifes08k3ES2WYEqPEAw6qaiXhKbAh2nIradIFKDkc
	 v3ri/bBvMrl/jHgl4NwDX7V+QMPXAsBW6iVPCbzmIlfB1n/W/T72Wzzx4fIKcoKHkbh6U
	 48dRQhqHwnStOTIe9bTuZ2u4t+j9Y66/kd0Ou/82mCi9S65H1wiGLslXiIdSfBkUSLm+h
	 gh1dlwRw7N0fCngxooiih6fO5Fl4aPkLNsrlVvRgcXdi/3VzZ+vN2eAc0UIhLqEqhQfWZ
	 CtM1iOCxd47VrJvwRf2KaivxpxTxHzO/ejrKcyLVKU5T8nyL74dp0Bd+enBYWqMMdVw==
ARC-Message-Signature: i=1; d=subspace.kernel.org; s=arc20261015;
	a=rsa-sha256; c=relaxed/relaxed; t=1793820140;
	h=Received:DKIM-Signature:From:To:Cc:Subject:Date:Message-ID:
	 In-Reply-To:References:MIME-Version:Content-Type:X-Mailer:
	 X-Developer-Signature:X-Developer-Key:Content-Transfer-Encoding;
	bh=frXlYovGKxKiSN/Oj3/IY9GUET6etUhHzbC1M94LuG8=;
	b=VK1v6kiQLzDMhP8FLgkq9jFO1jbWsvNnQau/9r+BkkqS/ZdeHoQCQN8xzI/lFNrPmIh3
	 lGtIgPbeco2nDTMset394w1hlXByTTVzEWiAL7oIsoKDGsJYfW3J2RJowCDSTrAnYCHB7
	 SZ5AbThqK3PU7A/PLZZ8+sKzluXuuRSkX7sV8Qx3vIIPIe6t+tLPvlfiEYkODcdHo2yj2
	 /vbiapFCZzep0o4KWhAl9EhkLxGtiAyaK9C6ucdxITfvPCLwbERf0TGCF4RXEdH5rSQB2
	 bqV0qC86DFTh961Kjo7cQPxxZ1BIeTP2H0ixR7WysA4kEHK1L6hrXMvbQuFgkq66C2w==
ARC-Authentication-Results: i=1; smtp.subspace.kernel.org; 
	dkim=pass header.d=kernel.org header.i=@kernel.org header.a=rsa-sha256 header.s=k20260515 header.b=m4qlh5ad;
	arc=none smtp.remote-ip=100.103.45.18
Received: from smtp.kernel.org (quasi.space.kernel.org [100.103.45.18])
	(using TLSv1.3 with cipher TLS_AES_256_GCM_SHA384 (256/256 bits)
	 key-exchange X25519 server-signature ECDSA (prime256v1))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id BB963606B2C9;
	Wed,  4 Nov 2026 19:22:19 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key, unprotected) header.d=kernel.org header.i=@kernel.org header.a=rsa-sha256 header.s=k20260515 header.b=m4qlh5ad
Received: by smtp.kernel.org (Postfix) with ESMTPSA id 8A39E1F000C1;
	Wed,  4 Nov 2026 19:22:07 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=kernel.org;
	s=k20260515; t=1793820139;
	bh=frXlYovGKxKiSN/Oj3/IY9GUET6etUhHzbC1M94LuG8=;
	h=From:To:Cc:Subject:Date:In-Reply-To:References;
	b=m4qlh5adzIihmnlMCPV3MfzvM9clEODdoNPI2uMqY4fs5tXjOCWDUSzu6mv2JPcnd
	 rIPr1zKO2U3CjW3V1MIfmNbgfh1n07E+bfpMs8tk02/3DnE87bHvJw3d0jbyRKMVJD
	 IyG1TCJ8IDfIKO9zXzTPhcHA+ABY+MPRa3JEdRoY9H5TpyzNGzOxFD39D4e/nEzri/
	 xV3khedTdJnJfO/uoKUxMN3c9AMOVj129ZcQ4wKqGT6ApGnU+0jvS+ZI/4rijimnGb
	 2/KGqEkHg6aA14vgzVafdv5HLYM59RkWvexV7pVOwnU2YNnoy7SUAi1RAXlTmBHVKt
	 aZyeLWcmGYS+Q==
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
Subject: [PATCH RESEND v2 25/51] wifi: libipw: don't return 0 from writes to debug_level
Date: Wed,  4 Nov 2026 20:22:05 +0100
Message-ID: <20261104-work-procfs-bugfixes-v2-25-021c84d852e0@kernel.org>
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
X-Developer-Signature: v=1; a=openpgp-sha256; l=1059; i=brauner@kernel.org; h=from:subject:message-id; bh=PSZyn/5j7f+UAGnOkF9zGJ8rErtLF7uTzeHltQyv5ig=; b=owGbwMvMwCU28Zj0gdSKO4sYT6slMWS9bny1/eaz260dbT8unLZwrN5tXTy3yfvErX9TPsXMM V8nc4f3WkcpC4MYF4OsmCKLQ7tJuNxynorNRpkaMHNYmUCGMHBxCsBEjHoY/iffUCphqBDzD6jS 3KKZ9/nt+Yxbx7kDk6dL8t/4/j9YjZmR4beq8vlDlkeLZQ/dKD+x8ZzFnrPzDR5/5vD+ZfFD7WF 3CS8A
X-Developer-Key: i=brauner@kernel.org; a=openpgp; fpr=4880B8C9BD0E5106FC070F4F7B3C391EFEA93624
Content-Transfer-Encoding: 8bit

debug_level_proc_write() returns the length of the string it parsed. A
write that starts with a NUL byte thus returns 0 and writers that use
stdio retry it forever. Return the number of bytes that were written
instead, which also stops writes longer than the 11 bytes it looks at
from coming up short.

Fixes: b453872c35cf ("[NET] ieee80211 subsystem")
Signed-off-by: Christian Brauner (Amutable) <brauner@kernel.org>
---
 drivers/net/wireless/intel/ipw2x00/libipw_module.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/drivers/net/wireless/intel/ipw2x00/libipw_module.c b/drivers/net/wireless/intel/ipw2x00/libipw_module.c
index 22358b2c2ecd..552c8ff3928b 100644
--- a/drivers/net/wireless/intel/ipw2x00/libipw_module.c
+++ b/drivers/net/wireless/intel/ipw2x00/libipw_module.c
@@ -236,7 +236,7 @@ static ssize_t debug_level_proc_write(struct file *file,
 	else
 		libipw_debug_level = val;
 
-	return strnlen(buf, len);
+	return count;
 }
 
 static const struct proc_ops debug_level_proc_ops = {

-- 
2.53.0

