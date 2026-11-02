Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.remote-ip=100.103.45.18
ARC-Seal: i=1; d=subspace.kernel.org; s=arc20261015; a=rsa-sha256; cv=none;
	t=1793629489;
	b=KGYSkkcegaoYgUkblu0yaM2Sqj1eJBbGCAQcO1vYZD7/PUx8zKsBZYlyYJC80pJeFfrb
	 22aBwqkEguaoPxbuOK7IUDPhaswnVbq1puqdJgxzL9vAP1UXzxfzKy4bpZ+lnNaFq64Gh
	 qvkIz9OuX96w9cqCpgE7Sa+1mmftJVBIGRWHG/e4HcW1hF/C8sadiAcFv7gtJL6rzeSWF
	 goYsnr1Zw4n7gwTl0hlTBbFiPaVLp6Ooz+UsnFr74v9AUSA+9O/Qma7N+1mfiTUSsyULB
	 yws+PNILAPM2E3PbmqBTc+miOPkJVqtEeWAwOvqmDNOnG8WuMJpQwUE4JGNO3obxUrA==
ARC-Message-Signature: i=1; d=subspace.kernel.org; s=arc20261015;
	a=rsa-sha256; c=relaxed/relaxed; t=1793629489;
	h=Received:DKIM-Signature:From:Date:Subject:MIME-Version:Content-Type:
	 Content-Transfer-Encoding:Message-Id:References:In-Reply-To:To:Cc:
	 X-Mailer:X-Developer-Signature:X-Developer-Key;
	bh=S8IXtzTL1USde6aV/lVKsFPWulIUW0ciUvC5Tm4lMm4=;
	b=YXI3j26QaQtxs0P08ZpzQGa0RtvYBhbxskyuDQ9TaEeo/Fgovnp+/aROSxz8CYog3jM1
	 Ug7YxW6maW+1TUqE8YlzKWAtHaJn2RBUKFjFV6YIDPqPopreG1D9gpkAPubuD5Lp9+GHr
	 070d5ZprFc2Z48fzDRjiPQP/mtD+ZIY4/cNWIU940ESBeaLzooFRKhfLPJHUNkAOUt9w2
	 Samyk33rz8XFFXnlAT46B1ndl0uEX81+nmR/Xp1mMfRuRlNAwUXXPucHtCBJiPJDgfj7R
	 qp0VX1jMb4gJp2r1fqrQOb2jmsMAwShLEQ7MrqMFiMsml5HkiherCHqd8dbN3a7bitA==
ARC-Authentication-Results: i=1; smtp.subspace.kernel.org; 
	dkim=pass header.d=kernel.org header.i=@kernel.org header.a=rsa-sha256 header.s=k20260515 header.b=eItiv4ZS;
	arc=none smtp.remote-ip=100.103.45.18
Received: from smtp.kernel.org (quasi.space.kernel.org [100.103.45.18])
	(using TLSv1.3 with cipher TLS_AES_256_GCM_SHA384 (256/256 bits)
	 key-exchange X25519 server-signature ECDSA (prime256v1))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 2A3466070CAF;
	Mon,  2 Nov 2026 14:24:48 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key, unprotected) header.d=kernel.org header.i=@kernel.org header.a=rsa-sha256 header.s=k20260515 header.b=eItiv4ZS
Received: by smtp.kernel.org (Postfix) with ESMTPSA id A91FA1F00A17;
	Mon,  2 Nov 2026 14:24:35 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=kernel.org;
	s=k20260515; t=1793629488;
	bh=S8IXtzTL1USde6aV/lVKsFPWulIUW0ciUvC5Tm4lMm4=;
	h=From:Date:Subject:References:In-Reply-To:To:Cc;
	b=eItiv4ZSsA0o29cJddRhknzQ/bhOslnikosU7shAbLsc6vTsBfmDsItQHBMrbvVWd
	 iPZbUolyR+DqkWlaAa0X2CnLcF2jyDfURGxamilT7KyJvcn1fKmbflZQF9mZNYHiZO
	 V0ITbrToBCzB7hRC4b/UItl9wr2159FfzOymbnfHnOF2rwSD+IUlNRm9Mg0cMAS2zm
	 5gwJPTLnvktaVBDt4cpf/GZOkyIf5vc3Gnqu0sv5l4CtGAi/V20ChSZvsil7rMsNnM
	 0OhXFaQi0hOR9dRoU2RCfw23JXyWpcHF2yT6L1CDbIcvCpMbQZH6dQmQwY5xG0/KbE
	 t+ML1xiLi3rHQ==
From: Christian Brauner <brauner@kernel.org>
Date: Mon, 02 Nov 2026 15:21:28 +0100
Subject: [PATCH RFC 13/38] scsi: core: NUL-terminate what is written to the
 host proc files
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
Message-Id: <20261102-work-procfs-bugfixes-v1-13-59422ed3e465@kernel.org>
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
X-Developer-Signature: v=1; a=openpgp-sha256; l=1011; i=brauner@kernel.org;
 h=from:subject:message-id; bh=jBwXVCCRpDjmnAajxR/zAvEvmAtZKAE0jCj6+Cnx3v0=;
 b=owGbwMvMwCU28Zj0gdSKO4sYT6slMWS9mJOt8KzyxT3HqTxz47pOZlhlreHadWzKU9ECZ1HJM
 /eTjxsd7ShlYRDjYpAVU2RxaDcJl1vOU7HZKFMDZg4rE8gQBi5OAZjInBpGhnblJ+n8i6QvucrH
 3L3hMeP2tqzHWnkyxe8aQsOergg+85jhr/wPVbOd51/rtnu/jeqzYHXMzjH9s/7NWaZa++nPtf+
 38wEA
X-Developer-Key: i=brauner@kernel.org; a=openpgp;
 fpr=4880B8C9BD0E5106FC070F4F7B3C391EFEA93624

proc_scsi_host_write() copies what is written into a page and hands it
to ->write_info() without terminating it. ppa and imm parse it with
strncmp() and simple_strtoul(), which read on past what was written into
whatever the page held before. Terminate the copy. A write is at most
PROC_BLOCK_SIZE bytes, so the page always has room for that.

Fixes: 1da177e4c3f4 ("Linux-2.6.12-rc2")
Cc: stable@vger.kernel.org
Signed-off-by: Christian Brauner (Amutable) <brauner@kernel.org>
---
 drivers/scsi/scsi_proc.c | 1 +
 1 file changed, 1 insertion(+)

diff --git a/drivers/scsi/scsi_proc.c b/drivers/scsi/scsi_proc.c
index fdc355d783da..dbd03360b5a4 100644
--- a/drivers/scsi/scsi_proc.c
+++ b/drivers/scsi/scsi_proc.c
@@ -80,6 +80,7 @@ static ssize_t proc_scsi_host_write(struct file *file, const char __user *buf,
 		ret = -EFAULT;
 		if (copy_from_user(page, buf, count))
 			goto out;
+		page[count] = '\0';
 		ret = shost->hostt->write_info(shost, page, count);
 	}
 out:

-- 
2.53.0

