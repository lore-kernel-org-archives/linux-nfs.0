Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.remote-ip=100.103.45.18
ARC-Seal: i=1; d=subspace.kernel.org; s=arc20261015; a=rsa-sha256; cv=none;
	t=1793820846;
	b=BPuFfi777/g5qht4UJhGDJbbQ0JReoQ0M7WJS3qsrGZEQsDlmVRmTRUqal2NJnJIIZxY
	 /16SHUVhczeFvg8vXWDuY+0PzihaenGhxHHuS5BgS2inG2n9os5TcXBumIWFr5ulSjc0D
	 l1IWXnLvussH/5qvNgf6SSx8/KIv9j1D2h/Z/ee5RsZtUEzShCTpnDtz8NzUIaMD4yqNA
	 61MABD5bmnwlRUOg5VpbCH5F8fn8N8qd5Mt5I76f7ROrysCZ+J3hYUl60Zp8PoPx4yl/4
	 eDexXDowFpkAFEftzUxTEzRbyxNMqEE+NbpPT+Lh5p0wNhGzaJ5eiIxSJoYD4w9xJBg==
ARC-Message-Signature: i=1; d=subspace.kernel.org; s=arc20261015;
	a=rsa-sha256; c=relaxed/relaxed; t=1793820846;
	h=Received:DKIM-Signature:From:To:Cc:Subject:Date:Message-ID:
	 In-Reply-To:References:MIME-Version:Content-Type:X-Mailer:
	 X-Developer-Signature:X-Developer-Key:Content-Transfer-Encoding;
	bh=wOiGbtXh+26P6cFgB3YXbnrWEhf8CPNBoutfZuqe0cI=;
	b=TXXFHfctN89FmLpkmorhKCy7+CfMKXkEyIWmsqRIgvEwUFfAY8wvSaLrdjnsUilXnMTI
	 EUzntCzx8GWeh8l1jz322iwCQSrGl2+2h66Q98+6n+wO5nUN7M9iEhqf8SHN4vt7GJaGE
	 wAL7XmDT6YW5CF9BTS34AbBhSLDCIFA0YDLYEefYb/UUSw+Z4qFU5aIm1TsvcoC9arIcv
	 9+zoA19xaMVzd0Uea5nVA5Ie8fkkktASW+Uyca3P+Zzc1WdCcOI5hiCPa35Mkiz4Qhnc1
	 Wo7m1v0h+XhjOkEHygz6x6z7n9Rk4R4NTDskKis5mqP7eW2gg/tddbmsvqRR5yXspPQ==
ARC-Authentication-Results: i=1; smtp.subspace.kernel.org; 
	dkim=pass header.d=kernel.org header.i=@kernel.org header.a=rsa-sha256 header.s=k20260515 header.b=GAUi2SUu;
	arc=none smtp.remote-ip=100.103.45.18
Received: from smtp.kernel.org (quasi.space.kernel.org [100.103.45.18])
	(using TLSv1.3 with cipher TLS_AES_256_GCM_SHA384 (256/256 bits)
	 key-exchange X25519 server-signature ECDSA (prime256v1))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 5DD0F607A7D6;
	Wed,  4 Nov 2026 19:34:05 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key, unprotected) header.d=kernel.org header.i=@kernel.org header.a=rsa-sha256 header.s=k20260515 header.b=GAUi2SUu
Received: by smtp.kernel.org (Postfix) with ESMTPSA id 156601F00A02;
	Wed,  4 Nov 2026 19:33:52 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=kernel.org;
	s=k20260515; t=1793820844;
	bh=wOiGbtXh+26P6cFgB3YXbnrWEhf8CPNBoutfZuqe0cI=;
	h=From:To:Cc:Subject:Date:In-Reply-To:References;
	b=GAUi2SUug0UxPlfFUUONWwiBaqhW+CPwHi9ROt2tgHXEeUA5HnhKW49vg0h//eRek
	 19VdBVnFuVj0FumboOxOLM8ZGbD/sXZJ18BizGNDqR7bU1rcpq9wqzj03DLTrZxycb
	 xCZzycJdxDPLJft+HIdgBnsg1C2coUbbb6sFjgx+Z90PctyxTbRw87FiQL/EAfCnsD
	 wiHtGkQ2vyZTUstIsghXbyaDluDmFswvpSimcZ+xR5fteGCZrQT/i14tZH1sOvmBSc
	 l6QV3ryMIU8G+gcr/NG5UtajUyb9hEoWX8DYhdTOTtqkDHMl0qtdUHBBmVhxDrFDpD
	 alh7bcK12D7bg==
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
Subject: [PATCH RESEND v2 19/23] proc: pin the entry around the vm_operations of its mappings
Date: Wed,  4 Nov 2026 20:33:50 +0100
Message-ID: <20261104-work-procfs-core-v2-19-76ace653a773@kernel.org>
In-Reply-To: <20261104-work-procfs-core-v2-0-76ace653a773@kernel.org>
References: <20261104-work-procfs-core-v2-0-76ace653a773@kernel.org>
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
X-Developer-Signature: v=1; a=openpgp-sha256; l=11693; i=brauner@kernel.org; h=from:subject:message-id; bh=1Gn60dKTBgMHLZNNt783bvPpMphe5Oyiwe1oBT0VS+Y=; b=owGbwMvMwCU28Zj0gdSKO4sYT6slMWS9bu+QKEs7mSWU5xnOGc8epSacpjzTovXorKiOP1wfa q7krTrcUcrCIMbFICumyOLQbhIut5ynYrNRpgbMHFYmkCEMXJwCMJFbTYwMF/JeHn5hJ2XP5f3c W3fLzrrjN1YX6loYlbr2VRpwJ074xfCH43/Y586lty6++81yYZFC6JEJB84FLxQ6q3urlnveMrt 2bgA=
X-Developer-Key: i=brauner@kernel.org; a=openpgp; fpr=4880B8C9BD0E5106FC070F4F7B3C391EFEA93624
Content-Transfer-Encoding: 8bit

proc_reg_mmap() pins the entry around ->proc_mmap() and that's it. What
the entry hands out lives on without the pin: the vm_operations it put
on the mapping run on every fault, on every write to a read-only page
and on every ptrace access with the entry unpinned, and the mapping
itself survives remove_proc_entry(). For /proc/vmcore that means the
fault handler runs after vmcore_cleanup() freed what it looks at, and a
mapping of the old memory keeps pointing at it after fadump gave that
memory back to the page allocator. /proc/bus/pci has the same problem
when a device goes away.

So do what kernfs does for the mappings of sysfs files. procfs puts
vm_operations of its own on the mapping. They pin the entry around its
->open(), ->fault(), ->page_mkwrite() and ->access() and fail with
SIGBUS, or do nothing, once the entry is gone. The entry's
vm_operations are kept in its open node, so every mapping of an entry
has to use the same ones, like kernfs asks that of every mapping of an
open file. ->close() can't be wrapped, it runs when the mapping goes
away and that can be after the entry is gone, so a mapping that has
one is refused.

When the entry is removed procfs unmaps the mappings of every open file
of an entry that has been mapped before it calls ->proc_release(), so a
fault into one of them finds the entry gone. That unmaps the entry's
own address space, the way kernfs_drain_open_files() does it.
/proc/bus/pci maps through the iomem address space that /dev/mem and
the sysfs resource files share, see iomem_get_mapping(), and
unmapping that would take every /dev/mem and BAR mapping on the system
with it. So those mappings are left alone, like the sysfs resource
files leave theirs, and keep pointing at the BAR of a device that is
gone. To know the files an entry that can be mapped gets an open node
like an entry with a ->proc_release() has one. The mapping is linked
into the file's address space only after ->mmap() returned, so a
removal that runs in between doesn't find it. kernfs has the same
window.

Entries that are never removed aren't wrapped, procfs never pins them.

Signed-off-by: Christian Brauner (Amutable) <brauner@kernel.org>
---
 fs/proc/generic.c       |   6 +--
 fs/proc/inode.c         | 126 ++++++++++++++++++++++++++++++++++++++++++++----
 fs/proc/internal.h      |   9 ++--
 include/linux/proc_fs.h |  15 ++++++
 4 files changed, 140 insertions(+), 16 deletions(-)

diff --git a/fs/proc/generic.c b/fs/proc/generic.c
index 1bad3b068d53..81a6cb560c75 100644
--- a/fs/proc/generic.c
+++ b/fs/proc/generic.c
@@ -505,14 +505,14 @@ static int pde_set_flags(struct proc_dir_entry *pde)
 
 /*
  * procfs has to know the open files of an entry whose ->proc_release() it
- * calls at removal. A permanent entry is never removed and skips all that,
- * see proc_reg_open().
+ * calls at removal and whose mappings it undoes then. A permanent entry is
+ * never removed and skips all that, see proc_reg_open().
  */
 static bool pde_needs_open_node(const struct proc_dir_entry *pde)
 {
 	if (!S_ISREG(pde->mode) || pde_is_permanent(pde))
 		return false;
-	return pde->proc_ops->proc_release;
+	return pde->proc_ops->proc_release || pde->proc_ops->proc_mmap;
 }
 
 /*
diff --git a/fs/proc/inode.c b/fs/proc/inode.c
index 717cbaad65df..5e423bcad278 100644
--- a/fs/proc/inode.c
+++ b/fs/proc/inode.c
@@ -312,7 +312,8 @@ static void pde_seq_release(struct proc_dir_entry *pde, struct inode *inode,
  *
  * PDE is locked on entry, unlocked on exit.
  */
-static void close_pdeo(struct proc_dir_entry *pde, struct pde_opener *pdeo)
+static void close_pdeo(struct proc_dir_entry *pde, struct pde_opener *pdeo,
+		       bool rundown)
 	__releases(&pde->pde_unload_lock)
 {
 	/*
@@ -336,7 +337,17 @@ static void close_pdeo(struct proc_dir_entry *pde, struct pde_opener *pdeo)
 		spin_unlock(&pde->pde_unload_lock);
 
 		file = pdeo->file;
-		pde->proc_ops->proc_release(file_inode(file), file);
+		/*
+		 * A mapping of a removed entry faults, see proc_vm_ops. Like
+		 * kernfs this unmaps the entry's own address space. A file
+		 * that maps through another one, /proc/bus/pci through the
+		 * iomem address space of /dev/mem, keeps its mappings like a
+		 * sysfs resource file does.
+		 */
+		if (rundown && pde->open->vm_ops)
+			unmap_mapping_range(file_inode(file)->i_mapping, 0, 0, 1);
+		if (pde->proc_ops->proc_release)
+			pde->proc_ops->proc_release(file_inode(file), file);
 
 		spin_lock(&pde->pde_unload_lock);
 		/* Strictly after ->proc_release, see above. */
@@ -362,7 +373,7 @@ void proc_entry_rundown(struct proc_dir_entry *de)
 	while (!list_empty(&de->open->files)) {
 		struct pde_opener *pdeo;
 		pdeo = list_first_entry(&de->open->files, struct pde_opener, lh);
-		close_pdeo(de, pdeo);
+		close_pdeo(de, pdeo, true);
 		spin_lock(&de->pde_unload_lock);
 	}
 	spin_unlock(&de->pde_unload_lock);
@@ -642,12 +653,106 @@ static long proc_reg_compat_ioctl(struct file *file, unsigned int cmd, unsigned
 #define proc_reg_compat_ioctl NULL
 #endif
 
-static int pde_mmap(struct proc_dir_entry *pde, struct file *file, struct vm_area_struct *vma)
+/*
+ * The vm_operations of an entry's mappings run with the entry pinned, like
+ * the entry's file methods do, and a mapping of a removed entry faults.
+ * proc_entry_rundown() unmaps the mappings of every open file and a fault
+ * after that finds the entry gone. Like kernfs_vm_ops, and like there only
+ * these four methods of the entry's vm_operations are called.
+ */
+static void proc_vma_open(struct vm_area_struct *vma)
+{
+	struct proc_dir_entry *pde = PDE(file_inode(vma->vm_file));
+	const struct vm_operations_struct *vm_ops = pde->open->vm_ops;
+
+	if (!pde_pin(pde))
+		return;
+	if (vm_ops->open)
+		vm_ops->open(vma);
+	pde_unpin(pde);
+}
+
+static vm_fault_t proc_vma_fault(struct vm_fault *vmf)
+{
+	struct proc_dir_entry *pde = PDE(file_inode(vmf->vma->vm_file));
+	const struct vm_operations_struct *vm_ops = pde->open->vm_ops;
+	vm_fault_t ret = VM_FAULT_SIGBUS;
+
+	if (!pde_pin(pde))
+		return VM_FAULT_SIGBUS;
+	if (vm_ops->fault)
+		ret = vm_ops->fault(vmf);
+	pde_unpin(pde);
+	return ret;
+}
+
+static vm_fault_t proc_vma_page_mkwrite(struct vm_fault *vmf)
+{
+	struct proc_dir_entry *pde = PDE(file_inode(vmf->vma->vm_file));
+	const struct vm_operations_struct *vm_ops = pde->open->vm_ops;
+	vm_fault_t ret = 0;
+
+	if (!pde_pin(pde))
+		return VM_FAULT_SIGBUS;
+	if (vm_ops->page_mkwrite)
+		ret = vm_ops->page_mkwrite(vmf);
+	else
+		file_update_time(vmf->vma->vm_file);
+	pde_unpin(pde);
+	return ret;
+}
+
+static int proc_vma_access(struct vm_area_struct *vma, unsigned long addr,
+			   void *buf, int len, int write)
+{
+	struct proc_dir_entry *pde = PDE(file_inode(vma->vm_file));
+	const struct vm_operations_struct *vm_ops = pde->open->vm_ops;
+	int ret = -EINVAL;
+
+	if (!pde_pin(pde))
+		return -EINVAL;
+	if (vm_ops->access)
+		ret = vm_ops->access(vma, addr, buf, len, write);
+	pde_unpin(pde);
+	return ret;
+}
+
+static const struct vm_operations_struct proc_vm_ops = {
+	.open		= proc_vma_open,
+	.fault		= proc_vma_fault,
+	.page_mkwrite	= proc_vma_page_mkwrite,
+	.access		= proc_vma_access,
+};
+
+static int pde_mmap(struct proc_dir_entry *pde, struct file *file,
+		    struct vm_area_struct *vma)
 {
 	const auto mmap = pde->proc_ops->proc_mmap;
-	if (mmap)
-		return mmap(file, vma);
-	return -EIO;
+	struct pde_open_node *on = pde->open;
+	int rv;
+
+	if (!mmap)
+		return -EIO;
+	rv = mmap(file, vma);
+	if (rv || pde_is_permanent(pde))
+		return rv;
+	/* the entry mapped something else, that isn't ours to wrap */
+	if (vma->vm_file != file)
+		return 0;
+	/*
+	 * ->close() can't be wrapped, it runs when the mapping goes away and
+	 * that can be after the entry is gone, see close_pdeo().
+	 */
+	if (!vma->vm_ops || vma->vm_ops->close)
+		return -EINVAL;
+
+	/* every mapping of an entry uses the same vm_operations, see above */
+	guard(spinlock)(&pde->pde_unload_lock);
+	if (on->vm_ops && on->vm_ops != vma->vm_ops)
+		return -EINVAL;
+	on->vm_ops = vma->vm_ops;
+	vma->vm_ops = &proc_vm_ops;
+	return 0;
 }
 
 static int proc_reg_mmap(struct file *file, struct vm_area_struct *vma)
@@ -743,8 +848,9 @@ static int proc_reg_open(struct inode *inode, struct file *file)
 	 * 2) rmmod isn't blocked by opening file in /proc and sitting on
 	 *    the descriptor (including "rmmod foo </proc/foo" scenario).
 	 *
-	 * Save every "struct file" with custom ->release hook. Those entries
-	 * have an open node, see proc_register().
+	 * Save every "struct file" with custom ->release hook, and every
+	 * one that can be mapped, proc_entry_rundown() unmaps those. Those
+	 * entries have an open node, see proc_register().
 	 */
 	if (!use_pde(pde))
 		return -ENOENT;
@@ -794,7 +900,7 @@ static int proc_reg_release(struct inode *inode, struct file *file)
 	spin_lock(&pde->pde_unload_lock);
 	list_for_each_entry(pdeo, &pde->open->files, lh) {
 		if (pdeo->file == file) {
-			close_pdeo(pde, pdeo);
+			close_pdeo(pde, pdeo, false);
 			goto out;
 		}
 	}
diff --git a/fs/proc/internal.h b/fs/proc/internal.h
index ae0f9779cf1b..0b1c0585d6a6 100644
--- a/fs/proc/internal.h
+++ b/fs/proc/internal.h
@@ -373,12 +373,15 @@ struct pde_opener {
 } __randomize_layout;
 
 /*
- * The open files of an entry whose ->proc_release() procfs has to call when
- * the entry is removed while they are still open. Allocated with the entry,
- * see proc_register().
+ * The open files of an entry whose ->proc_release() procfs has to call and
+ * whose mappings it has to undo when the entry is removed while they are
+ * still open, that is of an entry with a ->proc_release() or a
+ * ->proc_mmap(). Allocated with the entry, see proc_register().
  */
 struct pde_open_node {
 	struct list_head files;		/* who did ->open, but not ->release */
+	/* of its mappings, the same for all of them, see pde_mmap() */
+	const struct vm_operations_struct *vm_ops;
 };
 extern const struct inode_operations proc_link_inode_operations;
 extern const struct inode_operations proc_pid_link_inode_operations;
diff --git a/include/linux/proc_fs.h b/include/linux/proc_fs.h
index 2ba4e4a39e13..5bf039d20990 100644
--- a/include/linux/proc_fs.h
+++ b/include/linux/proc_fs.h
@@ -86,6 +86,21 @@ struct proc_ops {
 #ifdef CONFIG_COMPAT
 	long	(*proc_compat_ioctl)(struct file *, unsigned int, unsigned long);
 #endif
+	/*
+	 * procfs pins the entry around ->proc_mmap() and wraps the
+	 * vm_operations of the mapping so that ->open(), ->fault(),
+	 * ->page_mkwrite() and ->access() run with the entry pinned as well.
+	 * Nothing else of them is called, like for a kernfs file. Every
+	 * mapping of an entry has to use the same vm_operations. A ->close()
+	 * can't be wrapped, it runs when the mapping goes away and that can
+	 * be after the entry is gone, so a mapping that has one is refused.
+	 * Removing the entry unmaps the mappings in its own address space,
+	 * like kernfs does, and a fault into one of them is SIGBUS from then
+	 * on. A file that maps through another address space, /proc/bus/pci
+	 * through the one of /dev/mem, keeps its mappings like a sysfs
+	 * resource file does. The mappings of a permanent entry are left
+	 * alone.
+	 */
 	int	(*proc_mmap)(struct file *, struct vm_area_struct *);
 	unsigned long (*proc_get_unmapped_area)(struct file *, unsigned long, unsigned long, unsigned long, unsigned long);
 	/*

-- 
2.53.0

