Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.remote-ip=100.103.45.18
ARC-Seal: i=1; d=subspace.kernel.org; s=arc20261015; a=rsa-sha256; cv=none;
	t=1793633364;
	b=kEjQtkioXQ2j+4WCDamUu9G4KMql2qaQeOkZxdh2BOovGB6wyEmu3x4XRcQu5FPp4KH/
	 Twm4EKY2z9mbZjRFeMOesSla4MYIhjtPdLGviDBjl/3HlSf4/bedfBmHXP8BOiTJhy9Na
	 U2gDvsaofTbBON9++kwgs57HlUOgiduTtZOXC4wGYJ8Pwx7QAdmPbCL4oJDxwWr9oEiUr
	 0LCbNTfgklEyLszolKAB9qtHy+6A9gULGi7+Bdhzmlp1RPB2UfoSywkaP8sccgkP1o1Pr
	 Nl87AIW54T+uhy7HPfK1eYNVPNSHRAOJ5O8hJ0b0hU7ua/X5gUKjCef0jvzky42TtNQ==
ARC-Message-Signature: i=1; d=subspace.kernel.org; s=arc20261015;
	a=rsa-sha256; c=relaxed/relaxed; t=1793633364;
	h=Received:DKIM-Signature:From:Date:Subject:MIME-Version:Content-Type:
	 Content-Transfer-Encoding:Message-Id:References:In-Reply-To:To:Cc:
	 X-Mailer:X-Developer-Signature:X-Developer-Key;
	bh=jhlUxShJ2PAnaFYEGZj/acNyvX4jU2/JMVjl8Ac9zMQ=;
	b=G7VVuwx6DIS5cO6Q+lpgkjy0SILW5utxeAQ2Z/OfAEIZU/s0vaCRS4deiGIUtPLhC/We
	 KB7b18S+dInMEf87BJ7verfZWRAqNXmajchtfM47Tjc5zvK46s3zEAi4udX9wFA0Enwll
	 GffsfHwoqiPyIBTZ+kmpwDG1ucjXqZWExjV+nGGllCIjCtEl3u+9A6a+bTojCR2Tj9Vgw
	 Hna/ovRumKJ/qlN+3VVfQJ9jiIWT7v2khEbxWwflN0NU4ZBz5Gnj1w7eKzE02Jcgc4DXc
	 drVvf/LlMx6ijvzM1SvY+zkH+ECWugDnCPkAsnsTtRAKOwCaIg45Jkt38sjjp06opmA==
ARC-Authentication-Results: i=1; smtp.subspace.kernel.org; 
	dkim=pass header.d=kernel.org header.i=@kernel.org header.a=rsa-sha256 header.s=k20260515 header.b=bEpjay2C;
	arc=none smtp.remote-ip=100.103.45.18
Received: from smtp.kernel.org (quasi.space.kernel.org [100.103.45.18])
	(using TLSv1.3 with cipher TLS_AES_256_GCM_SHA384 (256/256 bits)
	 key-exchange X25519 server-signature ECDSA (prime256v1))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 1C386609CDBF;
	Mon,  2 Nov 2026 15:29:23 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key, unprotected) header.d=kernel.org header.i=@kernel.org header.a=rsa-sha256 header.s=k20260515 header.b=bEpjay2C
Received: by smtp.kernel.org (Postfix) with ESMTPSA id 8429A1F00A17;
	Mon,  2 Nov 2026 15:29:06 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=kernel.org;
	s=k20260515; t=1793633363;
	bh=jhlUxShJ2PAnaFYEGZj/acNyvX4jU2/JMVjl8Ac9zMQ=;
	h=From:Date:Subject:References:In-Reply-To:To:Cc;
	b=bEpjay2CbnfGJBHly978mQVKfOK9NOWk818hauqaL6bJ1R9S6y4K750VMrYinkjRZ
	 UJYMQ5lPJt9EqbCkMQJHIEzuAVhA0uBBsY3SQ52htvtKFFvqoAARzwAqIQhqo0yDks
	 27SjH2upRcJP3c6/Pe085axMXe6Pi9Arnrh7pZAVs3x5e/XE9jaVeyQ0qsr8Qkyfkq
	 yc1WiGpYMVgd0fNpip1lkFOhbQga6TG73wT6BHy5m4PYoCpETxzGPsM53biago4TWh
	 aXiE38bqIKzr3MTvUNm540DqItq0eT865nVxWPsH4BWXKPHJwP7owlsDAuHhhrBWTO
	 HoE9gxpbWNrtQ==
From: Christian Brauner <brauner@kernel.org>
Date: Mon, 02 Nov 2026 16:07:36 +0100
Subject: [PATCH RFC 26/27] kernel/configs: let procfs copy out reads of
 /proc/config.gz
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
Message-Id: <20261102-work-procfs-fs-v1-26-d09a996317b3@kernel.org>
References: <20261102-work-procfs-fs-v1-0-d09a996317b3@kernel.org>
In-Reply-To: <20261102-work-procfs-fs-v1-0-d09a996317b3@kernel.org>
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
X-Developer-Signature: v=1; a=openpgp-sha256; l=1297; i=brauner@kernel.org;
 h=from:subject:message-id; bh=IZ5Jauw3jeCJbbKJV7DoExBPgNJSSia5o6c0KJSA0oY=;
 b=owGbwMvMwCU28Zj0gdSKO4sYT6slMWS9WG68W/dM+SnW3p+PHz9Nr9SdtujbqdmGuR8kWUNv6
 Ra5lWq6dpSyMIhxMciKKbI4tJuEyy3nqdhslKkBM4eVCWQIAxenAEzk9kRGhpbCF9v7uDqqLS5v
 Fwy4tydWj4HvRde9J5lu+/I9+Jmacxj+ijqWtebXBD78UxAm+sZz3pqzV2uF96jusDvBcuLcpOk
 H+QA=
X-Developer-Key: i=brauner@kernel.org; a=openpgp;
 fpr=4880B8C9BD0E5106FC070F4F7B3C391EFEA93624

Implement ->proc_read_buf() so procfs copies what is read to userspace
after it unpinned the entry. Unloading configs.ko then no longer waits
for a reader that faults on its buffer. /proc/config.gz asks for
PROC_ENTRY_FULL_READS so that reading all of it at once keeps working.

Signed-off-by: Christian Brauner (Amutable) <brauner@kernel.org>
---
 kernel/configs.c | 7 ++++---
 1 file changed, 4 insertions(+), 3 deletions(-)

diff --git a/kernel/configs.c b/kernel/configs.c
index a28c79c5f713..05b12c440168 100644
--- a/kernel/configs.c
+++ b/kernel/configs.c
@@ -38,17 +38,18 @@ extern char kernel_config_data;
 extern char kernel_config_data_end;
 
 static ssize_t
-ikconfig_read_current(struct file *file, char __user *buf,
+ikconfig_read_current(struct file *file, char *buf,
 		      size_t len, loff_t * offset)
 {
-	return simple_read_from_buffer(buf, len, offset,
+	return memory_read_from_buffer(buf, len, offset,
 				       &kernel_config_data,
 				       &kernel_config_data_end -
 				       &kernel_config_data);
 }
 
 static const struct proc_ops config_gz_proc_ops = {
-	.proc_read	= ikconfig_read_current,
+	.proc_flags	= PROC_ENTRY_FULL_READS,
+	.proc_read_buf	= ikconfig_read_current,
 	.proc_lseek	= default_llseek,
 };
 

-- 
2.53.0

