Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.remote-ip=100.103.45.18
ARC-Seal: i=1; d=subspace.kernel.org; s=arc20261015; a=rsa-sha256; cv=none;
	t=1793629782;
	b=LTaZeHeP7N9meta7cXWp8k61d6Et5N49o+X4Nj1QUJ/fNuciVzcLrY+EnLGDiZmi6XS3
	 TfNTNdJ+byaBtsAnC73F424x6+9npCpqxpSV8p49z1qWqqWHeZ6oVLHMsQwFcUmjRSuW8
	 A0vyRVD1ajJ4EYlhpt/6gaxk9oBVxgolcptMIDRAGd6f9ZfQr2lamcitjNtM/WFrehgiy
	 /FRnhUGASJTBmr0TXoyslX3xZjrZMf97cwBPI55zChfSvNnJC2xeX/TIQcO65HC5mxB1L
	 2Vo/ioO1Dvx4FEYt9rbjPjqEr0KwkKQTq6F6pVpO1SK6i9uVAo1/cZPp7fex8npBVhQ==
ARC-Message-Signature: i=1; d=subspace.kernel.org; s=arc20261015;
	a=rsa-sha256; c=relaxed/relaxed; t=1793629782;
	h=Received:DKIM-Signature:From:Date:Subject:MIME-Version:Content-Type:
	 Content-Transfer-Encoding:Message-Id:References:In-Reply-To:To:Cc:
	 X-Mailer:X-Developer-Signature:X-Developer-Key;
	bh=ic+85LCmRwOCXD9XrptIkWWgbAusIpJ/j/j/KpoPCSM=;
	b=AT3Dxqy1Xs8RMXWAkHlebE42OXK/mL3rU0I+V0u8V6DLNfgqe0NJocLYoYo8Tn8gte8Q
	 3wb1dccdVwYTBUus9lJPdOjl04236/o9MM0IOYjzy6Sg1v1q+atJ8pt+nqXYC2JCNY63x
	 W901KoAs4/cgKryV2XmXVVIKn0KOD8jm7X56hmy3L0vRYeQ00RESJEaJU5KbEzx49gsce
	 hD5oqEOQ3Tmh+n72HDOkxwRZLuIHLvtymkvW5Y/W6hSDtAIq2UkqOFGeAW+HFIy9hC5e+
	 cmkfTI1LKbx4Qj0zXGkOsGc7qZ5bHhjomfusBxbBD9z3tnP+IgpSg9BWoQlwhJsvUMg==
ARC-Authentication-Results: i=1; smtp.subspace.kernel.org; 
	dkim=pass header.d=kernel.org header.i=@kernel.org header.a=rsa-sha256 header.s=k20260515 header.b=cpiq3IqJ;
	arc=none smtp.remote-ip=100.103.45.18
Received: from smtp.kernel.org (quasi.space.kernel.org [100.103.45.18])
	(using TLSv1.3 with cipher TLS_AES_256_GCM_SHA384 (256/256 bits)
	 key-exchange X25519 server-signature ECDSA (prime256v1))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 2144B6070C80;
	Mon,  2 Nov 2026 14:29:41 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key, unprotected) header.d=kernel.org header.i=@kernel.org header.a=rsa-sha256 header.s=k20260515 header.b=cpiq3IqJ
Received: by smtp.kernel.org (Postfix) with ESMTPSA id 3A15B1F00A16;
	Mon,  2 Nov 2026 14:29:26 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=kernel.org;
	s=k20260515; t=1793629781;
	bh=ic+85LCmRwOCXD9XrptIkWWgbAusIpJ/j/j/KpoPCSM=;
	h=From:Date:Subject:References:In-Reply-To:To:Cc;
	b=cpiq3IqJzE0jLDTsXK0hhQpT+1tSBJ0m7UHl7jwVgF1Fv4mj9x0h0BFZHMrAfCVa5
	 iewk6s7JCm0+gwRTm/kjqgkW4YiueXz1TIntYMKngDzC+ACNgbHQBWvInviI1KRtgv
	 oJz0vOiQG4c8Pbk4iFmvmDh2ZQ6QwxvGwZS6AAmLbVz1ZAlyFcC8D8rCv7m/yTSEu4
	 1vD4TCJ+dg9PvxhYYplMdQDJY8+AFuovGaLfiL4La8TbkUrkcL9SeYhMCfsPHBpZLk
	 c+TBML64gtkfFA/ZyGQfZtD060MB4GYjnWd84w2qELeu1iAHFSJ2lpD4cFIe3OBakQ
	 pRII2n9i/Aq1w==
From: Christian Brauner <brauner@kernel.org>
Date: Mon, 02 Nov 2026 15:21:48 +0100
Subject: [PATCH RFC 33/38] proc: sysctl: copy to and from userspace without
 holding the table
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
Message-Id: <20261102-work-procfs-bugfixes-v1-33-59422ed3e465@kernel.org>
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
X-Developer-Signature: v=1; a=openpgp-sha256; l=3702; i=brauner@kernel.org;
 h=from:subject:message-id; bh=OKHYY6G5p6tdI3fThR8iqjZq4Cu2ed8jbKwsRQr4+FI=;
 b=owGbwMvMwCU28Zj0gdSKO4sYT6slMWS9mJOjqsfwdP26aUFGgi5C6r2yG2bHan4r+X3s7GyXV
 WxXvQoDOkpZGMS4GGTFFFkc2k3C5ZbzVGw2ytSAmcPKBDKEgYtTACYy4TIjw7uI6fuc5flCf+Zm
 5zW+q5zWPcdB1K3g9IT5Dob+Sj9nMTD8M73HuT7LtvqMxe4/c10XFfduOPPAQlnpxaaCg3+5lgu
 KcwAA
X-Developer-Key: i=brauner@kernel.org; a=openpgp;
 fpr=4880B8C9BD0E5106FC070F4F7B3C391EFEA93624

proc_sys_call_handler() grabs the table, copies in what is written,
calls the handler and copies what it produced out to userspace before
it lets go of the table again. Unregistering a table waits until nobody
uses it anymore. So a reader or writer whose copy faults for as long as
it wants, with userfaultfd or a stalled FUSE mapping, keeps
unregister_sysctl_table() waiting, and its callers like to hold locks
while they do that. addrconf unregisters the ipv6 sysctls of a device
with RTNL held, so a stalled read of /proc/sys/net/ipv6/conf/<dev>/mtu
holds up every RTNL user until the reader gives up.

Copy in before grabbing the table and copy out after letting go of it,
like procfs and kernfs do for their files. The buffer is ours, nothing
needs the table for the copies.

That moves the allocation and the copy in before the permission check.
A write that can't be copied in, or a request that is too large, now
fails with -EFAULT or -ENOMEM where it used to fail with -EPERM.

Fixes: 330d57fb98a9 ("[PATCH] Fix sysctl unregistration oops (CVE-2005-2709)")
Cc: stable@vger.kernel.org
Signed-off-by: Christian Brauner (Amutable) <brauner@kernel.org>
---
 fs/proc/proc_sysctl.c | 50 ++++++++++++++++++++++++++++----------------------
 1 file changed, 28 insertions(+), 22 deletions(-)

diff --git a/fs/proc/proc_sysctl.c b/fs/proc/proc_sysctl.c
index 38b61887b59c..2150cf842919 100644
--- a/fs/proc/proc_sysctl.c
+++ b/fs/proc/proc_sysctl.c
@@ -602,14 +602,36 @@ static ssize_t proc_sys_call_handler(struct kiocb *iocb, struct iov_iter *iter,
 		int write)
 {
 	struct inode *inode = file_inode(iocb->ki_filp);
-	struct ctl_table_header *head = grab_header(inode);
 	const struct ctl_table *table = PROC_I(inode)->sysctl_entry;
+	struct ctl_table_header *head;
 	size_t count = iov_iter_count(iter);
 	char *kbuf;
 	ssize_t error;
 
-	if (IS_ERR(head))
-		return PTR_ERR(head);
+	/* don't even try if the size is too large */
+	if (count >= KMALLOC_MAX_SIZE)
+		return -ENOMEM;
+	kbuf = kvzalloc(count + 1, GFP_KERNEL);
+	if (!kbuf)
+		return -ENOMEM;
+
+	/*
+	 * Copy in before grabbing the table and copy out after letting go of
+	 * it. Unregistering the table waits for us and a copy that faults can
+	 * take as long as userspace wants.
+	 */
+	if (write) {
+		error = -EFAULT;
+		if (!copy_from_iter_full(kbuf, count, iter))
+			goto out_free_buf;
+		kbuf[count] = '\0';
+	}
+
+	head = grab_header(inode);
+	if (IS_ERR(head)) {
+		error = PTR_ERR(head);
+		goto out_free_buf;
+	}
 
 	/*
 	 * At this point we know that the sysctl was not unregistered
@@ -624,28 +646,15 @@ static ssize_t proc_sys_call_handler(struct kiocb *iocb, struct iov_iter *iter,
 	if (!table->proc_handler)
 		goto out;
 
-	/* don't even try if the size is too large */
-	error = -ENOMEM;
-	if (count >= KMALLOC_MAX_SIZE)
-		goto out;
-	kbuf = kvzalloc(count + 1, GFP_KERNEL);
-	if (!kbuf)
-		goto out;
-
-	if (write) {
-		error = -EFAULT;
-		if (!copy_from_iter_full(kbuf, count, iter))
-			goto out_free_buf;
-		kbuf[count] = '\0';
-	}
-
 	error = BPF_CGROUP_RUN_PROG_SYSCTL(head, table, write, &kbuf, &count,
 					   &iocb->ki_pos);
 	if (error)
-		goto out_free_buf;
+		goto out;
 
 	/* careful: calling conventions are nasty here */
 	error = table->proc_handler(table, write, kbuf, &count, &iocb->ki_pos);
+out:
+	sysctl_head_finish(head);
 	if (error)
 		goto out_free_buf;
 
@@ -658,9 +667,6 @@ static ssize_t proc_sys_call_handler(struct kiocb *iocb, struct iov_iter *iter,
 	error = count;
 out_free_buf:
 	kvfree(kbuf);
-out:
-	sysctl_head_finish(head);
-
 	return error;
 }
 

-- 
2.53.0

