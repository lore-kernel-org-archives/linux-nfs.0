Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.remote-ip=100.103.45.18
ARC-Seal: i=1; d=subspace.kernel.org; s=arc20261015; a=rsa-sha256; cv=none;
	t=1793820066;
	b=jixBtQ/xcJ/aBoyMMRjgn2l2G8tHeXPuDhzYl4FB6VoGN0lJO4rFgvkOEJzdBDRDyI1h
	 rSVVsghuQifC8aMpDiPDBJzhKJwRf69IB6hKQUluvRWoBvt/y7FzLMViaV3emqh9ONzSE
	 q8ueeTSJGieTtFYomhRd+05tIudRDby577Gpw4P0y5lqaxGKIgktVvoAFUV3AqwBKPiNE
	 /muO4j3N6KZFKtazvfLIetzxvO2iilErrfsBZgKyUqdfgtUyISDaKDMdg3redto1kv2U8
	 1v5Lt3eYkZ7LfvX1g1/0jGKrXljanwc1UD5+hDc8P1pw5IiJgay3zD7oHluA1c0V3UQ==
ARC-Message-Signature: i=1; d=subspace.kernel.org; s=arc20261015;
	a=rsa-sha256; c=relaxed/relaxed; t=1793820066;
	h=Received:DKIM-Signature:From:To:Cc:Subject:Date:Message-ID:
	 In-Reply-To:References:MIME-Version:Content-Type:X-Mailer:
	 X-Developer-Signature:X-Developer-Key:Content-Transfer-Encoding;
	bh=Ayyh3GSY9IX8l/NxmtUwOJrSt8ohKQ1xsnTJeKuAZFg=;
	b=Ibfu+P5DN7bTtQV7dsCp2KoCumrUOajWGMvzLgLpfilwozo53rCOF5gLEqNo1UFbqz+W
	 qiLfVr+cGrxCjEcTmrq33AhzIgEoUyV0IBFE9u+8mGwPJFFDvZOB7iDau+rXWUNqsswKV
	 c7foFvIDpZgtp2oS4efwZTV8bKFokYQiEqmwuRVJ4LFBo9YZmy4x650jLDzmx9vVYpfU3
	 x3iHgDMdR8R36Err+tAqaO0dHvuqRw6FMaglcNE1BbKGZBzk5CNOnLukPDOF+NL/Jikw7
	 5AXtIHD7KbSijyVbcVJG9UDe6AuNh18nKhR7MH0idWObhrpkdGBgOAXlzkmG0MBvPJQ==
ARC-Authentication-Results: i=1; smtp.subspace.kernel.org; 
	dkim=pass header.d=kernel.org header.i=@kernel.org header.a=rsa-sha256 header.s=k20260515 header.b=PMovg2oc;
	arc=none smtp.remote-ip=100.103.45.18
Received: from smtp.kernel.org (quasi.space.kernel.org [100.103.45.18])
	(using TLSv1.3 with cipher TLS_AES_256_GCM_SHA384 (256/256 bits)
	 key-exchange X25519 server-signature ECDSA (prime256v1))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 16CCF6070A9F;
	Wed,  4 Nov 2026 19:21:05 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key, unprotected) header.d=kernel.org header.i=@kernel.org header.a=rsa-sha256 header.s=k20260515 header.b=PMovg2oc
Received: by smtp.kernel.org (Postfix) with ESMTPSA id 806C21F000C1;
	Wed,  4 Nov 2026 19:20:53 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=kernel.org;
	s=k20260515; t=1793820065;
	bh=Ayyh3GSY9IX8l/NxmtUwOJrSt8ohKQ1xsnTJeKuAZFg=;
	h=From:To:Cc:Subject:Date:In-Reply-To:References;
	b=PMovg2ocC+6+72mN+MPUqHUmY8Gh6jGtgFhxfGrbKQmCA+LwwQyl3c6SAd7ODK0Un
	 TeSpRqADQ9Kqhq1oQjD9vPlOAPX0N4L6G2Yq972WfVK0QyS2eoZkVjrC7gXV2Wp9AD
	 CUv1f8DxJzlMPkll9V0KMpG8czJ1Cdjc1NusWgGh651UisUDwupbe65VXluiYLVRKq
	 bmTGqSa/cBkfg+tO9lwTlkqyyX8ntnHu3rqhgeRlRLNSz2FtgHHB11uhlH75pZze0J
	 a0y9Qbx+5R9AkShgQfuaWjn2D8HWZ6fFJZRJfSSM3b8p5Slumunw5NJkGXiVuTlwsj
	 o0bkzl5ZAaHdA==
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
Subject: [PATCH RESEND v2 20/51] powerpc/rtas_flash: don't read past the validate message
Date: Wed,  4 Nov 2026 20:20:51 +0100
Message-ID: <20261104-work-procfs-bugfixes-v2-20-021c84d852e0@kernel.org>
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
X-Developer-Signature: v=1; a=openpgp-sha256; l=1303; i=brauner@kernel.org; h=from:subject:message-id; bh=7JHU1Fe1PUKfNakrIeb+3f7MU5rT/9SRwlQjBFg57NM=; b=owGbwMvMwCU28Zj0gdSKO4sYT6slMWS9bnzclOH/9YSeueXTgCsviu6+YT3ptfO90YO+xGe3o vXy9vC4dpSyMIhxMciKKbI4tJuEyy3nqdhslKkBM4eVCWQIAxenAEzkEwsjw/ZKfvGdFYG8TydZ OMpPUCz4mPFg57VZEq4Ws+oPejxnmMPI8PHqDVmb3Q9X/9/a4700i1N297SNPI27n4dcu7jAKU/ qBTMA
X-Developer-Key: i=brauner@kernel.org; a=openpgp; fpr=4880B8C9BD0E5106FC070F4F7B3C391EFEA93624
Content-Transfer-Encoding: 8bit

get_validate_flash_msg() adds up what snprintf() returns, which is the
length of the whole string and not what fit into msg. If the update
results the firmware hands back don't fit into what is left of the 256
bytes, the length ends up larger than msg and validate_flash_read()
copies whatever follows it on the stack to userspace. Use scnprintf().

Fixes: a94a14720eaf ("powerpc/rtas_flash: Fix validate_flash buffer overflow issue")
Cc: stable@vger.kernel.org
Signed-off-by: Christian Brauner (Amutable) <brauner@kernel.org>
---
 arch/powerpc/kernel/rtas_flash.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/arch/powerpc/kernel/rtas_flash.c b/arch/powerpc/kernel/rtas_flash.c
index 722dbfb6fbf8..f1cd105f7426 100644
--- a/arch/powerpc/kernel/rtas_flash.c
+++ b/arch/powerpc/kernel/rtas_flash.c
@@ -448,7 +448,7 @@ static int get_validate_flash_msg(struct rtas_validate_flash_t *args_buf,
 		n = sprintf(msg, "%d\n", args_buf->update_results);
 		if ((args_buf->update_results >= VALIDATE_CUR_UNKNOWN) ||
 		    (args_buf->update_results == VALIDATE_TMP_UPDATE))
-			n += snprintf(msg + n, msglen - n, "%s\n",
+			n += scnprintf(msg + n, msglen - n, "%s\n",
 					args_buf->buf);
 	} else {
 		n = sprintf(msg, "%d\n", args_buf->status);

-- 
2.53.0

