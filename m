Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.remote-ip=100.103.45.18
ARC-Seal: i=1; d=subspace.kernel.org; s=arc20261015; a=rsa-sha256; cv=none;
	t=1793631631;
	b=obzRgc+mYG71wSy2vGKVF9iYSm4107RPosdiqp/bFjHamAooJaCedBMygmPJkNlaOH9H
	 pgm23JmWZvH+jJLXgql8U542IOyUdEdiZfsBVZtTu6atfeVOlIyjWxqaZ4OvbnZlE412R
	 qmKDCFaLvXxLDi5DSM8svZFT5nXsGBC7DT74LItCVR4BKuonolCVdGmB6cF3aA+gjTRlM
	 vr6miiZHL1Ioqtc1F92KlEFaTAd9YYD4HGPESoqjrojhM6ELY8rejykcl69PjjetcLHr4
	 RKFsyyHe2XgPjCBXXmmEK3UREJvDzqnXS2Mo0P0J4uyHg8ULUAMAgyTESsm6jIkXRww==
ARC-Message-Signature: i=1; d=subspace.kernel.org; s=arc20261015;
	a=rsa-sha256; c=relaxed/relaxed; t=1793631631;
	h=Received:DKIM-Signature:From:Date:Subject:MIME-Version:Content-Type:
	 Content-Transfer-Encoding:Message-Id:References:In-Reply-To:To:Cc:
	 X-Mailer;
	bh=U5mZzHxukjxLRr+A+lD/tdwf1LEzGDGeSNZ2whis+uo=;
	b=Cxwq5LcK5nyN1AxAF7Mpp6vcKN770BAGGK4ys8Dm9xzBifehCa1b6J9kYP9ByVX7y9U4
	 gkdshyVMm1l+TqFH8W4nbwXZc9Ca3AQKdvUPIjd59804LvMTsJSMHRTtprcjbL2a5DZA6
	 Vq4PeoZ1ezrmTU826ymHDezxGf3aYiOus/fhu5glTxUVvytS2sTvmHeZtOPIsZ8fRuzrd
	 E450xiyJikSvq5ax7w+LU16x4W8Y39n2Xx3QCfvXDz8hKHgzr7ln2MKD/ritheezUWBPZ
	 n4QMb9L1qnc+4mUdsF9yddGm2hdM6PN3mrlgjF0IKOUgfL95chJy50d/pqvuVoL/qNQ==
ARC-Authentication-Results: i=1; smtp.subspace.kernel.org; 
	dkim=pass header.d=kernel.org header.i=@kernel.org header.a=rsa-sha256 header.s=k20260515 header.b=Zz1tW5Xt;
	arc=none smtp.remote-ip=100.103.45.18
Received: from smtp.kernel.org (quasi.space.kernel.org [100.103.45.18])
	(using TLSv1.3 with cipher TLS_AES_256_GCM_SHA384 (256/256 bits)
	 key-exchange X25519 server-signature ECDSA (prime256v1))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 439D2606C57A;
	Mon,  2 Nov 2026 15:00:31 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key, unprotected) header.d=kernel.org header.i=@kernel.org header.a=rsa-sha256 header.s=k20260515 header.b=Zz1tW5Xt
Received: by smtp.kernel.org (Postfix) with ESMTPSA id 77BAA1F00A1C;
	Mon,  2 Nov 2026 15:00:12 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=kernel.org;
	s=k20260515; t=1793631630;
	bh=U5mZzHxukjxLRr+A+lD/tdwf1LEzGDGeSNZ2whis+uo=;
	h=From:Date:Subject:References:In-Reply-To:To:Cc;
	b=Zz1tW5XtBNM/d+mjny8hcfR/4iAYkqcmlWTYxYCIV7g+aVhufWqrhGEyT8Boi/IPr
	 JAIhXXD2RZm1G/CwC3/k02VHwHpNmTGSwd58veF7P4Hq6KJ4HMsr676Nx+bEEKxATq
	 iUFuGrohuVqI1/y4vsPsNthNYQa/3J6IWcjlYAzxjO6QCdHTRUmPXk5rHb5Q5ioFFC
	 yxLID907OAltPHkASDThMZJnoOSO6Q2vNdDW9bRzv1zTDIkcRj/iT6nZCscjiI9JnT
	 20N+6mGEl6lWOxyXpc9zj8jxJRlwSu+rkfjx2zSBxlgxaxdGqi0nBTrjzJmljxNfiC
	 CQmDZtgOP8SFw==
From: Christian Brauner <brauner@kernel.org>
Date: Mon, 02 Nov 2026 15:48:55 +0100
Subject: [PATCH RFC 15/16] proc: let procfs copy ioctl arguments in and out
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
Message-Id: <20261102-work-procfs-core-v1-15-75df35e4f8b8@kernel.org>
References: <20261102-work-procfs-core-v1-0-75df35e4f8b8@kernel.org>
In-Reply-To: <20261102-work-procfs-core-v1-0-75df35e4f8b8@kernel.org>
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

proc_reg_unlocked_ioctl() pins the entry and calls ->proc_ioctl() which
copies its argument from and to userspace itself. Like for reads and
writes, an ioctl can make a page fault in those copies take as long as
it wants and remove_proc_entry() waits for it.

The command number doesn't reliably say what an ioctl copies. Some of
the procfs ones aren't encoded at all, like the PCI ones or esas2r's,
and i8k's encode the wrong sizes. So do what DRM does instead and list
what each command copies. An entry that implements ->proc_ioctl_buf()
lists its commands in ->proc_ioctl_args with the number of bytes that
go in and that come back out. procfs copies the argument in before it
pins the entry, calls ->proc_ioctl_buf() with that kernel copy and
copies it back out after unpinning the entry if the ioctl succeeded. A
command that copies neither gets its argument as is, a command that
isn't in the table fails with -ENOTTY. PROC_IOCTL_IOC() fills in an
entry from a command that encodes its argument.

Note that, like for writes, procfs copies the argument in before the
entry's own checks run, permission checks included. So a bad pointer
fails with -EFAULT where the entry used to say -EPERM first.

The table lives with the proc_ops, which go away with the entry, so
procfs pins the entry to look the command up and lets go of it again
before it copies anything. 32-bit tasks go through the same table with
their pointer converted by compat_ptr(). An entry that implements
->proc_ioctl_buf() and still has a ->proc_ioctl() fails to register, and
so does one that lists commands without implementing it or implements
it without listing any.

No users yet.

Signed-off-by: Christian Brauner (Amutable) <brauner@kernel.org>
---
 fs/proc/generic.c       | 12 ++++++++++
 fs/proc/inode.c         | 58 +++++++++++++++++++++++++++++++++++++++++++++++++
 fs/proc/internal.h      |  5 +++++
 include/linux/proc_fs.h | 35 +++++++++++++++++++++++++++++
 4 files changed, 110 insertions(+)

diff --git a/fs/proc/generic.c b/fs/proc/generic.c
index fc4d10c92d7c..35dd745a0357 100644
--- a/fs/proc/generic.c
+++ b/fs/proc/generic.c
@@ -485,6 +485,18 @@ static int pde_set_flags(struct proc_dir_entry *pde)
 		if (proc_ops->proc_flags & PROC_ENTRY_FULL_READS)
 			pde->flags |= PROC_ENTRY_FULL_READS;
 	}
+	if (proc_ops->proc_ioctl_buf) {
+		if (WARN_ON_ONCE(proc_ops->proc_ioctl))
+			return -EINVAL;
+		/* the table says what procfs copies, see pde_ioctl_arg() */
+		if (WARN_ON_ONCE(!proc_ops->proc_ioctl_args ||
+				 !proc_ops->proc_nr_ioctl_args))
+			return -EINVAL;
+		pde->flags |= PROC_ENTRY_proc_ioctl_buf;
+	} else if (WARN_ON_ONCE(proc_ops->proc_ioctl_args ||
+				proc_ops->proc_nr_ioctl_args)) {
+		return -EINVAL;
+	}
 	return 0;
 }
 
diff --git a/fs/proc/inode.c b/fs/proc/inode.c
index 3f29a1663d26..7e4ca5751abb 100644
--- a/fs/proc/inode.c
+++ b/fs/proc/inode.c
@@ -6,6 +6,7 @@
  */
 
 #include <linux/cache.h>
+#include <linux/compat.h>
 #include <linux/time.h>
 #include <linux/proc_fs.h>
 #include <linux/kernel.h>
@@ -571,11 +572,66 @@ static long pde_ioctl(struct proc_dir_entry *pde, struct file *file, unsigned in
 	return -ENOTTY;
 }
 
+/* the table lives in proc_ops, which goes away with the entry */
+static bool pde_ioctl_arg(struct proc_dir_entry *pde, unsigned int cmd,
+			  struct proc_ioctl_arg *arg)
+{
+	const struct proc_ops *proc_ops = pde->proc_ops;
+	bool found = false;
+
+	if (!pde_pin(pde))
+		return false;
+	for (unsigned int i = 0; i < proc_ops->proc_nr_ioctl_args; i++) {
+		if (proc_ops->proc_ioctl_args[i].cmd == cmd) {
+			*arg = proc_ops->proc_ioctl_args[i];
+			found = true;
+			break;
+		}
+	}
+	pde_unpin(pde);
+	return found;
+}
+
+/*
+ * procfs copies the argument in before it pins the entry and copies it back
+ * out after unpinning it. An ioctl that faults on its argument then doesn't
+ * hold up remove_proc_entry().
+ */
+static long pde_ioctl_buf(struct proc_dir_entry *pde, struct file *file,
+			  unsigned int cmd, void __user *uarg, unsigned long arg)
+{
+	void *buf __free(kvfree) = NULL;
+	struct proc_ioctl_arg a;
+	size_t size;
+	long rv;
+
+	if (!pde_ioctl_arg(pde, cmd, &a))
+		return -ENOTTY;
+	size = max(a.in, a.out);
+	if (size) {
+		buf = kvzalloc(size, GFP_KERNEL);
+		if (!buf)
+			return -ENOMEM;
+		if (copy_from_user(buf, uarg, a.in))
+			return -EFAULT;
+	}
+
+	if (!pde_pin(pde))
+		return -ENOTTY;
+	rv = pde->proc_ops->proc_ioctl_buf(file, cmd, buf ?: (void *)arg);
+	pde_unpin(pde);
+	if (rv >= 0 && copy_to_user(uarg, buf, a.out))
+		return -EFAULT;
+	return rv;
+}
+
 static long proc_reg_unlocked_ioctl(struct file *file, unsigned int cmd, unsigned long arg)
 {
 	struct proc_dir_entry *pde = PDE(file_inode(file));
 	long rv;
 
+	if (pde_has_proc_ioctl_buf(pde))
+		return pde_ioctl_buf(pde, file, cmd, (void __user *)arg, arg);
 	if (!pde_pin(pde))
 		return -ENOTTY;
 	rv = pde_ioctl(pde, file, cmd, arg);
@@ -597,6 +653,8 @@ static long proc_reg_compat_ioctl(struct file *file, unsigned int cmd, unsigned
 	struct proc_dir_entry *pde = PDE(file_inode(file));
 	long rv;
 
+	if (pde_has_proc_ioctl_buf(pde))
+		return pde_ioctl_buf(pde, file, cmd, compat_ptr(arg), arg);
 	if (!pde_pin(pde))
 		return -ENOTTY;
 	rv = pde_compat_ioctl(pde, file, cmd, arg);
diff --git a/fs/proc/internal.h b/fs/proc/internal.h
index 11bd3fa07705..93d20995b6fe 100644
--- a/fs/proc/internal.h
+++ b/fs/proc/internal.h
@@ -129,6 +129,11 @@ static inline bool pde_has_full_reads(const struct proc_dir_entry *pde)
 	return pde->flags & PROC_ENTRY_FULL_READS;
 }
 
+static inline bool pde_has_proc_ioctl_buf(const struct proc_dir_entry *pde)
+{
+	return pde->flags & PROC_ENTRY_proc_ioctl_buf;
+}
+
 /* procfs owns the seq_file, see pde_seq_ops */
 static inline bool pde_is_seq_file(const struct proc_dir_entry *pde)
 {
diff --git a/include/linux/proc_fs.h b/include/linux/proc_fs.h
index 0f0997898ba3..2ba4e4a39e13 100644
--- a/include/linux/proc_fs.h
+++ b/include/linux/proc_fs.h
@@ -8,6 +8,7 @@
 #include <linux/compiler.h>
 #include <linux/types.h>
 #include <linux/fs.h>
+#include <linux/ioctl.h>
 
 struct proc_dir_entry;
 struct seq_file;
@@ -45,8 +46,29 @@ enum {
 	 * coming up short.
 	 */
 	PROC_ENTRY_FULL_READS		= 1U << 11,
+	PROC_ENTRY_proc_ioctl_buf	= 1U << 12,
 };
 
+/*
+ * How many bytes of the argument of @cmd procfs copies in before calling
+ * ->proc_ioctl_buf() and copies back out after it. A command that copies
+ * neither gets its argument as is.
+ */
+struct proc_ioctl_arg {
+	unsigned int cmd;
+	unsigned int in;
+	unsigned int out;
+};
+
+#define PROC_IOCTL_ARG(_cmd, _in, _out) \
+	{ .cmd = (_cmd), .in = (_in), .out = (_out) }
+
+/* A command that encodes the size and direction of its argument. */
+#define PROC_IOCTL_IOC(_cmd)						\
+	PROC_IOCTL_ARG(_cmd,						\
+		       (_IOC_DIR(_cmd) & _IOC_WRITE) ? _IOC_SIZE(_cmd) : 0, \
+		       (_IOC_DIR(_cmd) & _IOC_READ) ? _IOC_SIZE(_cmd) : 0)
+
 struct proc_ops {
 	unsigned int proc_flags;
 	int	(*proc_open)(struct inode *, struct file *);
@@ -100,6 +122,19 @@ struct proc_ops {
 	 */
 	ssize_t	(*proc_read_buf)(struct file *, char *, size_t, loff_t *);
 	unsigned int proc_read_size;
+	/*
+	 * procfs looks the command up in ->proc_ioctl_args, copies in what it
+	 * passes before pinning the entry, calls ->proc_ioctl_buf() with that
+	 * copy and copies out what it returns after unpinning the entry.
+	 * Commands that aren't in the table fail with -ENOTTY. 32-bit tasks
+	 * go through the same table. The copy is zeroed and as large as the
+	 * larger of the two sizes, it only goes back out if the ioctl
+	 * succeeded, and a command that copies neither gets its argument as
+	 * is.
+	 */
+	long	(*proc_ioctl_buf)(struct file *, unsigned int, void *);
+	const struct proc_ioctl_arg *proc_ioctl_args;
+	unsigned int proc_nr_ioctl_args;
 } __randomize_layout;
 
 /* definitions for hide_pid field */

-- 
2.53.0

