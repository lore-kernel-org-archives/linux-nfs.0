Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.remote-ip=100.103.45.18
ARC-Seal: i=1; d=subspace.kernel.org; s=arc20261015; a=rsa-sha256; cv=none;
	t=1793821218;
	b=L4C1EroY5doNStlN7REalePt1UKH5qj75ITDy1An2uY262iyexLEjTloNhfOQvAnnJLP
	 kMZD6kChEn5m4ExeKheivR6GrXiNq9oKwnD+cmoqaF2wweR5DVwEgBdQZ83VROz3gg9A8
	 J1VvMYtj51eh+9KALGs5ZquB4SEHvXLFf7fc3jX1oL+81HUs1tcIDUnA7bBMb99Gc26QK
	 GckQgZAOnxIeNuxzQFkZ9qMZFeh5pbMDKYR5AktLc0YlkCHdN5jh78JgP2GJXoiz0JYeB
	 9ET1xzRvuQ220vpEjYWGHOVFBcEB7SbRayK6fMrqRsW+1MTvhvgInABQeHE1BKovtqA==
ARC-Message-Signature: i=1; d=subspace.kernel.org; s=arc20261015;
	a=rsa-sha256; c=relaxed/relaxed; t=1793821218;
	h=Received:DKIM-Signature:From:To:Cc:Subject:Date:Message-ID:
	 In-Reply-To:References:MIME-Version:Content-Type:X-Mailer:
	 X-Developer-Signature:X-Developer-Key:Content-Transfer-Encoding;
	bh=Jqve5dom8G0YagWg0DUi21Qt2CUJnz11dMCfHhOCDkM=;
	b=HMr+jJmKiHvzfXHZnFMVW5+qxT27uo55DVdWVSYZ0WyBUSj8uyZs4CWQ4e+4taSRasHn
	 9a2z/EBStMiL3fo25o31c4aAXRhdvxxbDLwchI8KZPD3P9a8hM+UlREFE6jlrfNkWlxdw
	 nYY8UezF1f3PZunRQvdABbDq12iXQp9ye5w2dHOr1HArZ7wQ507uj0al0E212wSEQLPnX
	 l3rhexC6Q5rqXSv0UqPTn3ntSguTezm8DAnKC0ESDdhRLgJrX5yi6ixvAbMpg3IOtzkfM
	 N/Dx3vQCaeMqgUe23Bp4rBcD6qqVxbU3nggpqzq4O5GnIgy6F/SbNW9WKiWAzn5z7cA==
ARC-Authentication-Results: i=1; smtp.subspace.kernel.org; 
	dkim=pass header.d=kernel.org header.i=@kernel.org header.a=rsa-sha256 header.s=k20260515 header.b=DS3z8fo4;
	arc=none smtp.remote-ip=100.103.45.18
Received: from smtp.kernel.org (quasi.space.kernel.org [100.103.45.18])
	(using TLSv1.3 with cipher TLS_AES_256_GCM_SHA384 (256/256 bits)
	 key-exchange X25519 server-signature ECDSA (prime256v1))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 5A2596071A18;
	Wed,  4 Nov 2026 19:40:18 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key, unprotected) header.d=kernel.org header.i=@kernel.org header.a=rsa-sha256 header.s=k20260515 header.b=DS3z8fo4
Received: by smtp.kernel.org (Postfix) with ESMTPSA id 224F31F000C1;
	Wed,  4 Nov 2026 19:40:05 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=kernel.org;
	s=k20260515; t=1793821218;
	bh=Jqve5dom8G0YagWg0DUi21Qt2CUJnz11dMCfHhOCDkM=;
	h=From:To:Cc:Subject:Date:In-Reply-To:References;
	b=DS3z8fo4+XcVun7qDjz2NB285oy50w37ZhabVQ+2KTyYBD2yK9k0cv1ydfdyDbb2G
	 F2kOHfTeVzmbTPa9e/WdAD70pmv8wAUop1Anni0EzwRVSbumICFkMK1x1F9P4tYZIC
	 c3MZ0Kd/4HbFldytGX1vHUsdhINZ5NpZWDpvM+t0Z5wHT/E+VFr+t/6p+AttFRpI6Z
	 mwCDXmDky64VEy6slIdAHdiThaCm746BEvz4eDgLL3BHUTx/IA08z0BMxgO0LJmQyT
	 NF1MhcwXbC2axzqG1STp/J698+gtyVKqI7HYsWuCQMJlP4fOePGgiGm6vAX9LAFZim
	 TqL2Dw1DliqSQ==
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
Subject: [PATCH RESEND v2 18/23] ACPI: proc: let procfs copy in writes to /proc/acpi/wakeup
Date: Wed,  4 Nov 2026 20:40:03 +0100
Message-ID: <20261104-work-procfs-arch-v2-18-2aeb952c9597@kernel.org>
In-Reply-To: <20261104-work-procfs-arch-v2-0-2aeb952c9597@kernel.org>
References: <20261104-work-procfs-arch-v2-0-2aeb952c9597@kernel.org>
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
X-Developer-Signature: v=1; a=openpgp-sha256; l=1423; i=brauner@kernel.org; h=from:subject:message-id; bh=IJsID2u9MwR2UWiBoMaBlflke6dvKtZBVcAIKZfI9/A=; b=owGbwMvMwCU28Zj0gdSKO4sYT6slMWS97mTSWXVefuGeEyelmfYp78ycWKUkyn49ZGWQk+eRL 0tjb5df7ShlYRDjYpAVU2RxaDcJl1vOU7HZKFMDZg4rE8gQBi5OAZjIXhmGf+a115bOnrtr8gHR +0o1t4SK21/t283HxHqtW0P5SrNTrxYjQ6Pi/sVHc5622fk3Tnk5Q7znZtAi0aS07pWzZjY9Od9 YwQ0A
X-Developer-Key: i=brauner@kernel.org; a=openpgp; fpr=4880B8C9BD0E5106FC070F4F7B3C391EFEA93624
Content-Transfer-Encoding: 8bit

Implement ->proc_write_buf() so procfs copies in what is written before
it pins the entry, and take the device name from that copy. Writes
larger than PAGE_SIZE - 1 bytes fail with -EINVAL now.

Signed-off-by: Christian Brauner (Amutable) <brauner@kernel.org>
---
 drivers/acpi/proc.c | 7 +++----
 1 file changed, 3 insertions(+), 4 deletions(-)

diff --git a/drivers/acpi/proc.c b/drivers/acpi/proc.c
index b8a0bd4580e0..feb8283fd855 100644
--- a/drivers/acpi/proc.c
+++ b/drivers/acpi/proc.c
@@ -86,7 +86,7 @@ static void physical_device_enable_wakeup(struct acpi_device *adev)
 
 static ssize_t
 acpi_system_write_wakeup_device(struct file *file,
-				const char __user * buffer,
+				char *buffer,
 				size_t count, loff_t * ppos)
 {
 	struct acpi_device *dev, *tmp;
@@ -96,8 +96,7 @@ acpi_system_write_wakeup_device(struct file *file,
 	if (count > 4)
 		count = 4;
 
-	if (copy_from_user(strbuf, buffer, count))
-		return -EFAULT;
+	memcpy(strbuf, buffer, count);
 	strbuf[count] = '\0';
 	sscanf(strbuf, "%s", str);
 
@@ -123,7 +122,7 @@ acpi_system_write_wakeup_device(struct file *file,
 
 static const struct proc_ops acpi_system_wakeup_device_proc_ops = {
 	.proc_show	= acpi_system_wakeup_device_seq_show,
-	.proc_write	= acpi_system_write_wakeup_device,
+	.proc_write_buf	= acpi_system_write_wakeup_device,
 };
 
 void __init acpi_sleep_proc_init(void)

-- 
2.53.0

