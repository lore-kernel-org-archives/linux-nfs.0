Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.remote-ip=100.103.45.18
ARC-Seal: i=1; d=subspace.kernel.org; s=arc20261015; a=rsa-sha256; cv=none;
	t=1793633173;
	b=VaVo5jV5cnuK8YHipLzgHxNwI9Qg1OAtl+B0Ad3HdqgPHB6MCXN8O56m+hyS8wIqK7DV
	 oOd/hNR70qLBXddUTz9pYKbFJmHPhI1YJctFYBcTCPWxg/saCnYmAmUduXfhXlSx1WgjJ
	 OqjvYiy7iXZWBOKudTzWdz2RsUGMnleW1Z7U9Xf0w88Hq2vxtiEeXV0wkf2sLsgbPrCmG
	 99qLvu3KJUcp16HE2HMI9z7/pJejrTjjuvXU2HpyVSGgRL5TilYRslxJ60pQZWJegaiC/
	 FXrcuOpag7fCq4wKgI9q9tXjr6d1rDgUjaiRyOJsBe8aP6QvYg0kBBnQAfaRkdv7AyA==
ARC-Message-Signature: i=1; d=subspace.kernel.org; s=arc20261015;
	a=rsa-sha256; c=relaxed/relaxed; t=1793633173;
	h=Received:DKIM-Signature:From:Date:Subject:MIME-Version:Content-Type:
	 Content-Transfer-Encoding:Message-Id:References:In-Reply-To:To:Cc:
	 X-Mailer:X-Developer-Signature:X-Developer-Key;
	bh=B1LcgTjI6osh59ZzieUt8cHCAfIdiXhMZk2FTOpmVb0=;
	b=zsgDu7MjfGpQfsd52LZ5d+s1PS+A4Ci5V0Nz3t9iIl9xoSbE0vbZa2q5DgdJnB5PR8M5
	 oOwBILflqiDTeZ7BLsZ0fVVHwXsvbiu8g46pt5ZltBzZd7GhPh6D0hdThv0XEhVb0AL5G
	 AQoy3MKkKcc7rm28yzeor23/dUQhfcIM0hiWtFSfCLVZhg+OdMLEYsW7KmKRm4yEYuw4s
	 neBjYQrxQemEaJXqpw7qBVZnQKRYqsns5PA/kM4FUkrQNufEeWcsdqo081jLZv81JFnSR
	 SXP9XVmfTNK7+qJk81ihyeV1vJvUdHXg1dl3mRqeDxKQ3KSeM+xyB0L5AeH03XAHMTw==
ARC-Authentication-Results: i=1; smtp.subspace.kernel.org; 
	dkim=pass header.d=kernel.org header.i=@kernel.org header.a=rsa-sha256 header.s=k20260515 header.b=aDk6OKCI;
	arc=none smtp.remote-ip=100.103.45.18
Received: from smtp.kernel.org (quasi.space.kernel.org [100.103.45.18])
	(using TLSv1.3 with cipher TLS_AES_256_GCM_SHA384 (256/256 bits)
	 key-exchange X25519 server-signature ECDSA (prime256v1))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 8A27F609A731;
	Mon,  2 Nov 2026 15:26:13 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key, unprotected) header.d=kernel.org header.i=@kernel.org header.a=rsa-sha256 header.s=k20260515 header.b=aDk6OKCI
Received: by smtp.kernel.org (Postfix) with ESMTPSA id 72E611F00A16;
	Mon,  2 Nov 2026 15:25:55 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=kernel.org;
	s=k20260515; t=1793633173;
	bh=B1LcgTjI6osh59ZzieUt8cHCAfIdiXhMZk2FTOpmVb0=;
	h=From:Date:Subject:References:In-Reply-To:To:Cc;
	b=aDk6OKCI0ar0R/BnCnovLiGiUgsQiS5cX2Iwq/bm/oxbS1/IImKGdug7FdOjvklfD
	 64oCwGAK6j+ynLF1muOCW0FEO0ciDHlSkU3IC2ugiIhQRfFVM/NQ0oqazBDBhOY57h
	 sJCWDt4wqHqEb5aSyBD/+EPtWOITuneefzTGQ8mUGHB8tDqm3gA+4PZZ3S4JIuMiZc
	 GXmPDubR+xVQwezYvxsVrQArwRXqg2mHgtAgwVyPXxzSE4iifxjtpH179wLH+qs5l+
	 IW4VUxjdneaQ8roktcSnrLzCGbyg0Xatn3vQmPJgGEy5D/5zzbKmwEEMZ7lOT8pEwl
	 qwtHvgii6pE7g==
From: Christian Brauner <brauner@kernel.org>
Date: Mon, 02 Nov 2026 16:07:28 +0100
Subject: [PATCH RFC 18/27] sched/psi: mark the pressure files permanent
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
Message-Id: <20261102-work-procfs-fs-v1-18-d09a996317b3@kernel.org>
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
X-Developer-Signature: v=1; a=openpgp-sha256; l=2074; i=brauner@kernel.org;
 h=from:subject:message-id; bh=tXr5cu1BdmO0jHsjps1+bZ2IKVwDVWrseoizU64SWOY=;
 b=owGbwMvMwCU28Zj0gdSKO4sYT6slMWS9WG7kztYrxVWs4L7JrPOz+wSfbxdD3doWh3h9ivDfs
 j/t3nS+jlIWBjEuBlkxRRaHdpNwueU8FZuNMjVg5rAygQxh4OIUgIl8TmNk2OS7Of/7mXtnrpvY
 SWw+cDKm06eJnev5ArnA2Z7Kmpt18xn+O605/1eW86zoiteWxTHfRDjWzEmrUjjwJ+3Hhezzqf8
 qeAE=
X-Developer-Key: i=brauner@kernel.org; a=openpgp;
 fpr=4880B8C9BD0E5106FC070F4F7B3C391EFEA93624

/proc/pressure/* are created when psi initializes and never removed.
Say so with PROC_ENTRY_PERMANENT, procfs then calls into them without
pinning them, like it does for /proc/profile.

That also takes care of a rule the files bent. psi_write() takes the
seq_file's lock to serialize the triggers. A reader holds that lock
while it copies to userspace, and now that procfs owns the seq_file it
does that with the entry unpinned. So nothing that runs with the entry
pinned may wait for that lock, and psi_write() ran pinned. Nothing ever
waited for it since the files are never removed, but with the files
permanent nothing runs pinned at all.

Signed-off-by: Christian Brauner (Amutable) <brauner@kernel.org>
---
 kernel/sched/psi.c | 4 ++++
 1 file changed, 4 insertions(+)

diff --git a/kernel/sched/psi.c b/kernel/sched/psi.c
index 3132105bf382..9811c3b705eb 100644
--- a/kernel/sched/psi.c
+++ b/kernel/sched/psi.c
@@ -1622,6 +1622,7 @@ static int psi_fop_release(struct inode *inode, struct file *file)
 }
 
 static const struct proc_ops psi_io_proc_ops = {
+	.proc_flags	= PROC_ENTRY_PERMANENT,
 	.proc_show	= psi_io_show,
 	.proc_write_buf	= psi_io_write,
 	.proc_poll	= psi_fop_poll,
@@ -1629,6 +1630,7 @@ static const struct proc_ops psi_io_proc_ops = {
 };
 
 static const struct proc_ops psi_memory_proc_ops = {
+	.proc_flags	= PROC_ENTRY_PERMANENT,
 	.proc_show	= psi_memory_show,
 	.proc_write_buf	= psi_memory_write,
 	.proc_poll	= psi_fop_poll,
@@ -1636,6 +1638,7 @@ static const struct proc_ops psi_memory_proc_ops = {
 };
 
 static const struct proc_ops psi_cpu_proc_ops = {
+	.proc_flags	= PROC_ENTRY_PERMANENT,
 	.proc_show	= psi_cpu_show,
 	.proc_write_buf	= psi_cpu_write,
 	.proc_poll	= psi_fop_poll,
@@ -1655,6 +1658,7 @@ static ssize_t psi_irq_write(struct file *file, char *buf, size_t nbytes,
 }
 
 static const struct proc_ops psi_irq_proc_ops = {
+	.proc_flags	= PROC_ENTRY_PERMANENT,
 	.proc_show	= psi_irq_show,
 	.proc_write_buf	= psi_irq_write,
 	.proc_poll	= psi_fop_poll,

-- 
2.53.0

