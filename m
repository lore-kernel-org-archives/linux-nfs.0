Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.remote-ip=100.103.45.18
ARC-Seal: i=1; d=subspace.kernel.org; s=arc20261015; a=rsa-sha256; cv=none;
	t=1793629406;
	b=Sf27/VLbpAO9SzYUvnND6VHOAJ/hWsqesL9vX2v6N9NPSUyNUkZvCCK+4jNJZJmM+UuM
	 ZOqFmgOKewInW4+zJ2/cdpyHcLTstOKAO2INj+g/9Sga6qZYchRckEXmBEmLvdHh38njZ
	 Z+phxVM/o2t8ZAfa9Z9xEqTDWcRUZZnSlUuQ0qyQtGeAn0G18dOcbAaCVnTdeYoEailoI
	 ujPVc0/YmnzBlL7JQ/gDDhZ70PNS0sWqR6BOFnkhBVrFypp3Ki/Cs2KBlU2SDSgNzqqB3
	 ZZWMhhn6TTi6483okZjw4JOqpmn5Dyv+xxwZOqsvLvFxvhxNklpcUVsEzFQZMqY2Bdw==
ARC-Message-Signature: i=1; d=subspace.kernel.org; s=arc20261015;
	a=rsa-sha256; c=relaxed/relaxed; t=1793629406;
	h=Received:DKIM-Signature:From:Date:Subject:MIME-Version:Content-Type:
	 Content-Transfer-Encoding:Message-Id:References:In-Reply-To:To:Cc:
	 X-Mailer:X-Developer-Signature:X-Developer-Key;
	bh=Ayyh3GSY9IX8l/NxmtUwOJrSt8ohKQ1xsnTJeKuAZFg=;
	b=qZXGiu+UrDk0afyENWgb/KVUTqpXFnqUoJSlYONBLuWXnJ0znW/7C5LYnKoonC/F2RQN
	 7XnIcLb+vEcB5bi1E64dzm4+amgoGBSc5Ey43WOYiSBtEqBFkBGMnWl0OMwmhBaGSRPl3
	 cRhKdPdwj8KUyi6wsku52b/JlOq/aoEG1XYPkI4ExG3VD6YccpKWOVKkIldxzY41Mht4R
	 3AJ6hq1LAdhU2hDaLcRUZcSPonRAm+eTlVL2iR8WHwkRTZ1j2z7EuOeG0MwR5Q83Wpt5e
	 s2kMdNHhMVphb79IyCMXuvIIh2fNxAj2lbrT/jKOb+nwDh8Hvtu+E1DVOlR4z4XMVfw==
ARC-Authentication-Results: i=1; smtp.subspace.kernel.org; 
	dkim=pass header.d=kernel.org header.i=@kernel.org header.a=rsa-sha256 header.s=k20260515 header.b=Tw8JvCxX;
	arc=none smtp.remote-ip=100.103.45.18
Received: from smtp.kernel.org (quasi.space.kernel.org [100.103.45.18])
	(using TLSv1.3 with cipher TLS_AES_256_GCM_SHA384 (256/256 bits)
	 key-exchange X25519 server-signature ECDSA (prime256v1))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id EDF4E606D807;
	Mon,  2 Nov 2026 14:23:25 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key, unprotected) header.d=kernel.org header.i=@kernel.org header.a=rsa-sha256 header.s=k20260515 header.b=Tw8JvCxX
Received: by smtp.kernel.org (Postfix) with ESMTPSA id 48C471F00A18;
	Mon,  2 Nov 2026 14:23:12 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=kernel.org;
	s=k20260515; t=1793629405;
	bh=Ayyh3GSY9IX8l/NxmtUwOJrSt8ohKQ1xsnTJeKuAZFg=;
	h=From:Date:Subject:References:In-Reply-To:To:Cc;
	b=Tw8JvCxX+km1KBPRoMXNm8sioLL/SiBihZfuVNjDsAkWtVzRRNmE5Cc7zY4ut+0X5
	 Rl0KHYQi1x1Sz9PF1RgpgzXpUFQuZfg50HWRXxjw+hQiC/PXAgk/eR8W2vWm2wLiWv
	 tvpKqETwrDFgD85oMKX9xozlc6S0OZ/W5Nh9uZD5F+uNOl4/1vY/ZNRsBNo6TVAbtO
	 9xct4ES9MUcb8Lk4gqF+MaFsGvGgcXWCF6AdUApSp4FQtJeMZ864LzSIASS1Tvf3o+
	 oWd+nrIhC/gdzolHINRzQeTdVxMRiw3oiAWCylK9VGym+o8EZsK7NBzyrg6pK/30lF
	 lKmpkvKak5tHQ==
From: Christian Brauner <brauner@kernel.org>
Date: Mon, 02 Nov 2026 15:21:22 +0100
Subject: [PATCH RFC 07/38] powerpc/rtas_flash: don't read past the validate
 message
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
Message-Id: <20261102-work-procfs-bugfixes-v1-7-59422ed3e465@kernel.org>
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
X-Developer-Signature: v=1; a=openpgp-sha256; l=1303; i=brauner@kernel.org;
 h=from:subject:message-id; bh=7JHU1Fe1PUKfNakrIeb+3f7MU5rT/9SRwlQjBFg57NM=;
 b=owGbwMvMwCU28Zj0gdSKO4sYT6slMWS9mJN1X2VyVJzM0zaD4pd5IsePH+N4ZpyQLfS98+Jal
 7bIPwn8HaUsDGJcDLJiiiwO7Sbhcst5KjYbZWrAzGFlAhnCwMUpADf5CyPDy8QjOeKy0icXe9kL
 dWRVXnzVHu/eWiK//28XY7LslJsLGf4XMiSre1zfdibVUb/UVG51TJRjtezPFx79q/9o//kddZk
 LAA==
X-Developer-Key: i=brauner@kernel.org; a=openpgp;
 fpr=4880B8C9BD0E5106FC070F4F7B3C391EFEA93624

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

