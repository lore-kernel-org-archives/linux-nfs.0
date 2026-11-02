Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.remote-ip=100.103.45.18
ARC-Seal: i=1; d=subspace.kernel.org; s=arc20261015; a=rsa-sha256; cv=none;
	t=1793632613;
	b=ybhTDJrEBPwFO54VdVJbTq8EN/+sS6e9roZI6DP+3IXoGS2+w+kLOHbGFTAj2+/YTeSX
	 CNZAIEYsKgVjtgWECKUsyO/HMFKDdV4TOkGnZEiLwbwvc8i8b7wIm+PcZVrsRMRuPqakw
	 Hr0QzEcPSMTWdp7lt1NK6M/fw/MPORlOFzxZ0jVyCQUbCfkNe9DgVK1Nx8/H4v6cBnGTq
	 KIBbLMMrkJ2KlwjHcGnexgs3thS/AEkkPxuzczHq1RUZsDSuHR2ygUj6IH4YK9GmOHfKu
	 jkwIsY0BnLrV6lIUM7Lu6bnQnWNaYSPlgQ2TxUrnk+Xg+pbM9IEOEn5ebtYbpBTsMhQ==
ARC-Message-Signature: i=1; d=subspace.kernel.org; s=arc20261015;
	a=rsa-sha256; c=relaxed/relaxed; t=1793632613;
	h=Received:DKIM-Signature:From:Date:Subject:MIME-Version:Content-Type:
	 Content-Transfer-Encoding:Message-Id:References:In-Reply-To:To:Cc:
	 X-Mailer:X-Developer-Signature:X-Developer-Key;
	bh=IWME5YXmp+uBTllQI4bmngqtIL2M/ij2LxSZ5nW/iXQ=;
	b=oCT+wavU0vbRcL0bD39QUqPMkFmpAUa1rIpIKiQnHOKDBqSJtz7xmNDt/8hjXztuv6hp
	 7eyKwLe8DmV42MX8sjsExzEgcjkaZ9494weXoFcwst4CgatSnVgxk7BHBKGGejOwQGsi+
	 i8s2yqXvprSrJ0080WZr6lOOrFhPxdNWSe/8W239BfJNEXFo57TyF6mGnCxiVxc8tfY6t
	 p5fg4287Fmv/QGWbDuJGV9MXG3M8zOyqHMr/cxK8yJ7QHiiLsmnOKBXTJivwdNYq2xH7m
	 N2qE/sI9PuSEmfc+Sb13hgHZ7Vvi5Re8BZgcmQdpDfM3qJ+aFDoTp+3PtccE5GabFqA==
ARC-Authentication-Results: i=1; smtp.subspace.kernel.org; 
	dkim=pass header.d=kernel.org header.i=@kernel.org header.a=rsa-sha256 header.s=k20260515 header.b=he+g2nWN;
	arc=none smtp.remote-ip=100.103.45.18
Received: from smtp.kernel.org (quasi.space.kernel.org [100.103.45.18])
	(using TLSv1.3 with cipher TLS_AES_256_GCM_SHA384 (256/256 bits)
	 key-exchange X25519 server-signature ECDSA (prime256v1))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id D1DA5606A338;
	Mon,  2 Nov 2026 15:16:52 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key, unprotected) header.d=kernel.org header.i=@kernel.org header.a=rsa-sha256 header.s=k20260515 header.b=he+g2nWN
Received: by smtp.kernel.org (Postfix) with ESMTPSA id 45A681F00A1B;
	Mon,  2 Nov 2026 15:16:36 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=kernel.org;
	s=k20260515; t=1793632612;
	bh=IWME5YXmp+uBTllQI4bmngqtIL2M/ij2LxSZ5nW/iXQ=;
	h=From:Date:Subject:References:In-Reply-To:To:Cc;
	b=he+g2nWN2axpHrzARSjuGxsrot205DCjbsjks2Uy9TZYl0RHdg/P9KBOh5oGD9JND
	 DVayfm5Hfkeg2m/r223WtfRPwcGKlWcjL6gYiHh273PXIhoEhxNZiDNavPF6Cbag50
	 rPSzGmz5EtQ1p1vq/YpFygUITCoUKTT249ouaHForUJOn3MhYmmCCKyIX0biE13ady
	 0Xf3M/tsk29ygP+6Atj+xx/0LarrE/V/7VcEpc9Mo2h1gkeCSTTvoKfOUhKqdH7Eyh
	 0y2lDzckjbfLpnh9+FD/2sWiSUe/HNZYfhNhwqWfP/i5T/FrHXFUuf714grP6oMM1K
	 gpSJo+mPThsHQ==
From: Christian Brauner <brauner@kernel.org>
Date: Mon, 02 Nov 2026 16:07:26 +0100
Subject: [PATCH RFC 19/23] tty: sysrq: let procfs copy in writes to
 /proc/sysrq-trigger
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
Message-Id: <20261102-work-procfs-drivers-v1-19-a994bd4d3b1a@kernel.org>
References: <20261102-work-procfs-drivers-v1-0-a994bd4d3b1a@kernel.org>
In-Reply-To: <20261102-work-procfs-drivers-v1-0-a994bd4d3b1a@kernel.org>
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
X-Developer-Signature: v=1; a=openpgp-sha256; l=1516; i=brauner@kernel.org;
 h=from:subject:message-id; bh=izKwZpZInQuHEIn3CG+CtVNE9UBdLWUqDQ+VPsYIx8o=;
 b=owGbwMvMwCU28Zj0gdSKO4sYT6slMWS9WG6YzB/Ns2fpXStd8VP3V2XLLXvKV1i9aZtRzvQP/
 3g8wg9e7ihlYRDjYpAVU2RxaDcJl1vOU7HZKFMDZg4rE8gQBi5OAZjIx3iG/04To6e1njQ6Mb9X
 dZKjsZxt3pH1lyYLZmw6XzB9b7lNLCvDfwcOT28tyyr+0J58PqZfrU9bfa+80lv3Xmue0ZOQ3RL
 BDAA=
X-Developer-Key: i=brauner@kernel.org; a=openpgp;
 fpr=4880B8C9BD0E5106FC070F4F7B3C391EFEA93624

Implement ->proc_write_buf() so procfs copies in what is written before
it pins the entry, and handle the keys from that copy. Writes larger
than PAGE_SIZE - 1 bytes fail with -EINVAL now. They used to trigger the
first key, or all of them in bulk mode. procfs allocates the copy, which
is as small as the write, opening the file allocated as much already.

Signed-off-by: Christian Brauner (Amutable) <brauner@kernel.org>
---
 drivers/tty/sysrq.c | 9 +++------
 1 file changed, 3 insertions(+), 6 deletions(-)

diff --git a/drivers/tty/sysrq.c b/drivers/tty/sysrq.c
index f4571d05b496..99363e1b59ed 100644
--- a/drivers/tty/sysrq.c
+++ b/drivers/tty/sysrq.c
@@ -1200,17 +1200,14 @@ EXPORT_SYMBOL(unregister_sysrq_key);
  * However, if the first character is an underscore,
  * all characters are processed.
  */
-static ssize_t write_sysrq_trigger(struct file *file, const char __user *buf,
+static ssize_t write_sysrq_trigger(struct file *file, char *buf,
 				   size_t count, loff_t *ppos)
 {
 	bool bulk = false;
 	size_t i;
 
 	for (i = 0; i < count; i++) {
-		char c;
-
-		if (get_user(c, buf + i))
-			return -EFAULT;
+		char c = buf[i];
 
 		if (c == '_')
 			bulk = true;
@@ -1225,7 +1222,7 @@ static ssize_t write_sysrq_trigger(struct file *file, const char __user *buf,
 }
 
 static const struct proc_ops sysrq_trigger_proc_ops = {
-	.proc_write	= write_sysrq_trigger,
+	.proc_write_buf	= write_sysrq_trigger,
 	.proc_lseek	= noop_llseek,
 };
 

-- 
2.53.0

