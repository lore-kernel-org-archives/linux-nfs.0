Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.remote-ip=100.103.45.18
ARC-Seal: i=1; d=subspace.kernel.org; s=arc20261015; a=rsa-sha256; cv=none;
	t=1793633859;
	b=NnCCRcntIeugJXJzMHtI+N9Hfer60dPbkZ/N0u8Udh2hfY1SUQjfpy+t3nh1EB0pZssP
	 UDp48xywjP7gybce7l8815IHjSF9uQbSbmShs3ivEJqL6+dRYLMANk+0COED8B1GqrpV8
	 6ZXVtZWPmO0VIup8RcKC2i4CVLx2GTIDa6X4F9emQuxYKAVMXAaUSEs+H4FIj52sndUs7
	 iE/1fhOVJqavgSI2QZ2jw1Yk+sa13CIut3BMsOdXUVkohJDCvhPs1PhW7WDtNlQVIERcd
	 3K5N8us8Px351vfOUVpsxJk/pwOgb73lLp3RORvmkOlx4o8wkZutMVB6dHu+m6Nbszw==
ARC-Message-Signature: i=1; d=subspace.kernel.org; s=arc20261015;
	a=rsa-sha256; c=relaxed/relaxed; t=1793633859;
	h=Received:DKIM-Signature:From:Date:Subject:MIME-Version:Content-Type:
	 Content-Transfer-Encoding:Message-Id:References:In-Reply-To:To:Cc:
	 X-Mailer:X-Developer-Signature:X-Developer-Key;
	bh=7VN5a+2bJrdNn51jpKajD/Qsm4zUSFksOGLezW4Sr4Y=;
	b=BUWlo2hKD280IvIUDl31WgqS8FRzOIoEXgM45JQL4uTfbZbPaFNVR7cjc2ZBMbuxPGTy
	 YKCQ4AJjO6VS/jGnXvdmfn3Hb1wokYq/AcRroYZTayEnJlVOcFh1AF2pscWIEtCns2c7Q
	 NhPQmCLSvkzGUZ5o3njaLURErgrsX4YEYCRpXIj2xSosbAQce7aHnxRxy2pcd/UL3tFrN
	 Ar6S1mdvgEP7keuhxPvBZmLX7d7p3LFdUJrdtvgAESqHwXYGgvpVPmkNk8wPXSjCOSvY4
	 2MsDBehOF2vQmDWkllhzq2uvkPnj0kze/LvSOBa2QxwLaMM9BMvr9w85KEM/Rn52jQQ==
ARC-Authentication-Results: i=1; smtp.subspace.kernel.org; 
	dkim=pass header.d=kernel.org header.i=@kernel.org header.a=rsa-sha256 header.s=k20260515 header.b=FdBJ3Y4a;
	arc=none smtp.remote-ip=100.103.45.18
Received: from smtp.kernel.org (quasi.space.kernel.org [100.103.45.18])
	(using TLSv1.3 with cipher TLS_AES_256_GCM_SHA384 (256/256 bits)
	 key-exchange X25519 server-signature ECDSA (prime256v1))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id D449C606B0E7;
	Mon,  2 Nov 2026 15:37:38 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key, unprotected) header.d=kernel.org header.i=@kernel.org header.a=rsa-sha256 header.s=k20260515 header.b=FdBJ3Y4a
Received: by smtp.kernel.org (Postfix) with ESMTPSA id 7C8791F00A1A;
	Mon,  2 Nov 2026 15:37:21 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=kernel.org;
	s=k20260515; t=1793633858;
	bh=7VN5a+2bJrdNn51jpKajD/Qsm4zUSFksOGLezW4Sr4Y=;
	h=From:Date:Subject:References:In-Reply-To:To:Cc;
	b=FdBJ3Y4aXzOouE8+rS/3kfppCzSrRlPdOc9e8AbKFPirKDOpesVZvV3apBrr4q1W2
	 7i9x6e/4nlIqf7VEqcLaJ8lVHIubbTWTruesJIT1uv5Wd1BSlt0fvwfdTYZpkxB+xa
	 tzDtrroDlsdYf6nt2ox6IV0EzOE+8Ggojte1HH715OIfqAqysvJSh6mUOmhXciqlQh
	 5CDLjPZuqaP4174Qx2KqVjXzRClnI5SKQ++aEkXNCTtvXnu0PXK+fry7QvvNUCHLU4
	 nSYTjhsZ59xADkAM59fw7qXElmdOfpifV2gHTJL6JuFzlQniLGouKddY3s/OkGUqYq
	 VM/NczBEWCtFg==
From: Christian Brauner <brauner@kernel.org>
Date: Mon, 02 Nov 2026 16:15:58 +0100
Subject: [PATCH RFC 5/5] proc: drop the _buf suffix from the new methods
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
Message-Id: <20261102-work-procfs-cleanup-v1-5-c40014bc12f5@kernel.org>
References: <20261102-work-procfs-cleanup-v1-0-c40014bc12f5@kernel.org>
In-Reply-To: <20261102-work-procfs-cleanup-v1-0-c40014bc12f5@kernel.org>
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
X-Developer-Signature: v=1; a=openpgp-sha256; l=58715; i=brauner@kernel.org;
 h=from:subject:message-id; bh=c90/sTtgkir5xu7DZvvAppiK8PunKChI4ZFVDaIkgEE=;
 b=owGbwMvMwCU28Zj0gdSKO4sYT6slMWS9WJn/WXTBLrELz46efXWStaDa5NPcmlpLXfm4/GePa
 3jfLl9X21HKwiDGxSArpsji0G4SLrecp2KzUaYGzBxWJpAhDFycAjCR+X6MDPO75AWW6nalpH3q
 jQt7kFPz612Tc8mh1wwnIiX+9WyLOMTI8MxRotXsbn3imhqvybe6Ek6r/uWTq+3x/FkruL7TZaE
 rJwA=
X-Developer-Key: i=brauner@kernel.org; a=openpgp;
 fpr=4880B8C9BD0E5106FC070F4F7B3C391EFEA93624

The _buf suffix told them apart from ->proc_write(), ->proc_read() and
->proc_ioctl(), which copied to and from userspace themselves. Those
are gone now, and the read methods that are left are only for
permanent entries and say so in their names. So drop the suffix.
->proc_write(), ->proc_read() and ->proc_ioctl() are the methods that
work on procfs' buffers from now on, which is what kernfs calls its
read and write as well.

Done with sed. The flags and helpers in fs/proc that go with them are
renamed to match.

No functional changes.

Signed-off-by: Christian Brauner (Amutable) <brauner@kernel.org>
---
 arch/alpha/kernel/srm_env.c                        |  2 +-
 arch/arm/kernel/atags_proc.c                       |  2 +-
 arch/arm/mm/alignment.c                            |  2 +-
 arch/m68k/kernel/bootinfo_proc.c                   |  2 +-
 arch/powerpc/kernel/proc_powerpc.c                 |  2 +-
 arch/powerpc/kernel/rtas-proc.c                    | 10 ++++----
 arch/powerpc/kernel/rtas_flash.c                   | 16 ++++++------
 arch/powerpc/kernel/rtasd.c                        |  2 +-
 arch/powerpc/platforms/pseries/lpar.c              |  4 +--
 arch/powerpc/platforms/pseries/lparcfg.c           |  2 +-
 arch/powerpc/platforms/pseries/reconfig.c          |  2 +-
 arch/sh/mm/alignment.c                             |  2 +-
 arch/sparc/kernel/led.c                            |  2 +-
 arch/um/drivers/mconsole_kern.c                    |  2 +-
 arch/um/kernel/exitcode.c                          |  2 +-
 arch/x86/kernel/cpu/mtrr/if.c                      |  4 +--
 arch/xtensa/platforms/iss/simdisk.c                |  4 +--
 drivers/acpi/proc.c                                |  2 +-
 drivers/hwmon/dell-smm-hwmon.c                     |  2 +-
 drivers/macintosh/via-pmu.c                        |  2 +-
 drivers/net/wireless/intel/ipw2x00/libipw_module.c |  2 +-
 drivers/pci/proc.c                                 |  6 ++---
 drivers/platform/x86/lenovo/thinkpad_acpi.c        |  2 +-
 drivers/platform/x86/toshiba_acpi.c                |  8 +++---
 drivers/pnp/isapnp/proc.c                          |  2 +-
 drivers/pnp/pnpbios/proc.c                         |  2 +-
 drivers/s390/block/dasd_proc.c                     |  2 +-
 drivers/s390/cio/blacklist.c                       |  2 +-
 drivers/s390/cio/css.c                             |  2 +-
 drivers/scsi/esas2r/esas2r_main.c                  |  2 +-
 drivers/scsi/scsi_devinfo.c                        |  2 +-
 drivers/scsi/scsi_proc.c                           |  4 +--
 drivers/scsi/sg.c                                  |  4 +--
 drivers/tty/sysrq.c                                |  2 +-
 drivers/usb/gadget/function/rndis.c                |  2 +-
 drivers/video/fbdev/via/viafbdev.c                 | 14 +++++-----
 drivers/zorro/proc.c                               |  2 +-
 fs/jfs/jfs_debug.c                                 |  2 +-
 fs/lockd/procfs.c                                  |  4 +--
 fs/ntfs3/super.c                                   |  2 +-
 fs/proc/generic.c                                  | 12 ++++-----
 fs/proc/inode.c                                    | 30 +++++++++++-----------
 fs/proc/internal.h                                 | 12 ++++-----
 fs/proc/proc_net.c                                 |  4 +--
 fs/proc/vmcore.c                                   |  2 +-
 fs/smb/client/cifs_debug.c                         | 16 ++++++------
 fs/smb/client/dfs_cache.c                          |  2 +-
 include/linux/proc_fs.h                            | 22 ++++++++--------
 kernel/configs.c                                   |  2 +-
 kernel/irq/proc.c                                  |  6 ++---
 kernel/latencytop.c                                |  2 +-
 kernel/locking/lockdep_proc.c                      |  2 +-
 kernel/profile.c                                   |  2 +-
 kernel/sched/psi.c                                 |  8 +++---
 lib/dynamic_debug.c                                |  2 +-
 mm/alloc_tag.c                                     |  2 +-
 net/atm/proc.c                                     |  2 +-
 net/core/pktgen.c                                  |  6 ++---
 net/netfilter/xt_recent.c                          |  2 +-
 net/sunrpc/auth_gss/svcauth_gss.c                  |  6 ++---
 net/sunrpc/cache.c                                 |  8 +++---
 samples/kfifo/bytestream-example.c                 |  4 +--
 samples/kfifo/inttype-example.c                    |  4 +--
 samples/kfifo/record-example.c                     |  4 +--
 sound/core/info.c                                  |  6 ++---
 65 files changed, 152 insertions(+), 152 deletions(-)

diff --git a/arch/alpha/kernel/srm_env.c b/arch/alpha/kernel/srm_env.c
index 6a1742b09a82..2817bf78742a 100644
--- a/arch/alpha/kernel/srm_env.c
+++ b/arch/alpha/kernel/srm_env.c
@@ -110,7 +110,7 @@ static ssize_t srm_env_proc_write(struct file *file, char *buffer,
 
 static const struct proc_ops srm_env_proc_ops = {
 	.proc_show	= srm_env_proc_show,
-	.proc_write_buf	= srm_env_proc_write,
+	.proc_write	= srm_env_proc_write,
 };
 
 static int __init
diff --git a/arch/arm/kernel/atags_proc.c b/arch/arm/kernel/atags_proc.c
index ff28bf24dd30..ff6fb346d3ee 100644
--- a/arch/arm/kernel/atags_proc.c
+++ b/arch/arm/kernel/atags_proc.c
@@ -18,7 +18,7 @@ static ssize_t atags_read(struct file *file, char *buf,
 }
 
 static const struct proc_ops atags_proc_ops = {
-	.proc_read_buf	= atags_read,
+	.proc_read	= atags_read,
 	.proc_lseek	= default_llseek,
 };
 
diff --git a/arch/arm/mm/alignment.c b/arch/arm/mm/alignment.c
index 11ceefdfa388..2d27b8bbb3b3 100644
--- a/arch/arm/mm/alignment.c
+++ b/arch/arm/mm/alignment.c
@@ -159,7 +159,7 @@ static ssize_t alignment_proc_write(struct file *file, char *buffer,
 
 static const struct proc_ops alignment_proc_ops = {
 	.proc_show	= alignment_proc_show,
-	.proc_write_buf	= alignment_proc_write,
+	.proc_write	= alignment_proc_write,
 };
 #endif /* CONFIG_PROC_FS */
 
diff --git a/arch/m68k/kernel/bootinfo_proc.c b/arch/m68k/kernel/bootinfo_proc.c
index 4936cf44e86a..f65555ddb7d3 100644
--- a/arch/m68k/kernel/bootinfo_proc.c
+++ b/arch/m68k/kernel/bootinfo_proc.c
@@ -27,7 +27,7 @@ static ssize_t bootinfo_read(struct file *file, char *buf,
 }
 
 static const struct proc_ops bootinfo_proc_ops = {
-	.proc_read_buf	= bootinfo_read,
+	.proc_read	= bootinfo_read,
 	.proc_lseek	= default_llseek,
 };
 
diff --git a/arch/powerpc/kernel/proc_powerpc.c b/arch/powerpc/kernel/proc_powerpc.c
index 46bc914d74b9..ca43a5dfe623 100644
--- a/arch/powerpc/kernel/proc_powerpc.c
+++ b/arch/powerpc/kernel/proc_powerpc.c
@@ -43,7 +43,7 @@ static int page_map_mmap( struct file *file, struct vm_area_struct *vma )
 
 static const struct proc_ops page_map_proc_ops = {
 	.proc_lseek	= page_map_seek,
-	.proc_read_buf	= page_map_read,
+	.proc_read	= page_map_read,
 	.proc_mmap	= page_map_mmap,
 };
 
diff --git a/arch/powerpc/kernel/rtas-proc.c b/arch/powerpc/kernel/rtas-proc.c
index 9598866f11cb..76eddbb8d94d 100644
--- a/arch/powerpc/kernel/rtas-proc.c
+++ b/arch/powerpc/kernel/rtas-proc.c
@@ -156,27 +156,27 @@ static int ppc_rtas_rmo_buf_show(struct seq_file *m, void *v);
 
 static const struct proc_ops ppc_rtas_poweron_proc_ops = {
 	.proc_show	= ppc_rtas_poweron_show,
-	.proc_write_buf	= ppc_rtas_poweron_write,
+	.proc_write	= ppc_rtas_poweron_write,
 };
 
 static const struct proc_ops ppc_rtas_progress_proc_ops = {
 	.proc_show	= ppc_rtas_progress_show,
-	.proc_write_buf	= ppc_rtas_progress_write,
+	.proc_write	= ppc_rtas_progress_write,
 };
 
 static const struct proc_ops ppc_rtas_clock_proc_ops = {
 	.proc_show	= ppc_rtas_clock_show,
-	.proc_write_buf	= ppc_rtas_clock_write,
+	.proc_write	= ppc_rtas_clock_write,
 };
 
 static const struct proc_ops ppc_rtas_tone_freq_proc_ops = {
 	.proc_show	= ppc_rtas_tone_freq_show,
-	.proc_write_buf	= ppc_rtas_tone_freq_write,
+	.proc_write	= ppc_rtas_tone_freq_write,
 };
 
 static const struct proc_ops ppc_rtas_tone_volume_proc_ops = {
 	.proc_show	= ppc_rtas_tone_volume_show,
-	.proc_write_buf	= ppc_rtas_tone_volume_write,
+	.proc_write	= ppc_rtas_tone_volume_write,
 };
 
 static int ppc_rtas_find_all_sensors(void);
diff --git a/arch/powerpc/kernel/rtas_flash.c b/arch/powerpc/kernel/rtas_flash.c
index 5ebaee7683ef..e8ccfa614b19 100644
--- a/arch/powerpc/kernel/rtas_flash.c
+++ b/arch/powerpc/kernel/rtas_flash.c
@@ -623,8 +623,8 @@ static const struct rtas_flash_file rtas_flash_files[] = {
 		.handle		= RTAS_FN_IBM_UPDATE_FLASH_64_AND_REBOOT,
 		.status		= &rtas_update_flash_data.status,
 		.ops.proc_flags	= PROC_ENTRY_SHORT_WRITES,
-		.ops.proc_read_buf = rtas_flash_read_msg,
-		.ops.proc_write_buf = rtas_flash_write,
+		.ops.proc_read = rtas_flash_read_msg,
+		.ops.proc_write = rtas_flash_write,
 		.ops.proc_write_size = RTAS_BLK_SIZE,
 		.ops.proc_release = rtas_flash_release,
 		.ops.proc_lseek	= default_llseek,
@@ -634,8 +634,8 @@ static const struct rtas_flash_file rtas_flash_files[] = {
 		.handle		= RTAS_FN_IBM_UPDATE_FLASH_64_AND_REBOOT,
 		.status		= &rtas_update_flash_data.status,
 		.ops.proc_flags	= PROC_ENTRY_SHORT_WRITES,
-		.ops.proc_read_buf = rtas_flash_read_num,
-		.ops.proc_write_buf = rtas_flash_write,
+		.ops.proc_read = rtas_flash_read_num,
+		.ops.proc_write = rtas_flash_write,
 		.ops.proc_write_size = RTAS_BLK_SIZE,
 		.ops.proc_release = rtas_flash_release,
 		.ops.proc_lseek	= default_llseek,
@@ -645,8 +645,8 @@ static const struct rtas_flash_file rtas_flash_files[] = {
 		.handle		= RTAS_FN_IBM_VALIDATE_FLASH_IMAGE,
 		.status		= &rtas_validate_flash_data.status,
 		.ops.proc_flags	= PROC_ENTRY_SHORT_WRITES,
-		.ops.proc_read_buf = validate_flash_read,
-		.ops.proc_write_buf = validate_flash_write,
+		.ops.proc_read = validate_flash_read,
+		.ops.proc_write = validate_flash_write,
 		.ops.proc_write_size = VALIDATE_BUF_SIZE,
 		.ops.proc_release = validate_flash_release,
 		.ops.proc_lseek	= default_llseek,
@@ -655,8 +655,8 @@ static const struct rtas_flash_file rtas_flash_files[] = {
 		.filename	= "powerpc/rtas/" MANAGE_FLASH_NAME,
 		.handle		= RTAS_FN_IBM_MANAGE_FLASH_IMAGE,
 		.status		= &rtas_manage_flash_data.status,
-		.ops.proc_read_buf = manage_flash_read,
-		.ops.proc_write_buf = manage_flash_write,
+		.ops.proc_read = manage_flash_read,
+		.ops.proc_write = manage_flash_write,
 		.ops.proc_lseek	= default_llseek,
 	}
 };
diff --git a/arch/powerpc/kernel/rtasd.c b/arch/powerpc/kernel/rtasd.c
index 360ed2e30fd5..a6e3091c793e 100644
--- a/arch/powerpc/kernel/rtasd.c
+++ b/arch/powerpc/kernel/rtasd.c
@@ -350,7 +350,7 @@ static __poll_t rtas_log_poll(struct file *file, poll_table * wait)
 }
 
 static const struct proc_ops rtas_log_proc_ops = {
-	.proc_read_buf	= rtas_log_read,
+	.proc_read	= rtas_log_read,
 	.proc_poll	= rtas_log_poll,
 	.proc_open	= rtas_log_open,
 	.proc_release	= rtas_log_release,
diff --git a/arch/powerpc/platforms/pseries/lpar.c b/arch/powerpc/platforms/pseries/lpar.c
index dfd027cc9047..8147129ecd59 100644
--- a/arch/powerpc/platforms/pseries/lpar.c
+++ b/arch/powerpc/platforms/pseries/lpar.c
@@ -585,7 +585,7 @@ static int vcpudispatch_stats_display(struct seq_file *p, void *v)
 
 static const struct proc_ops vcpudispatch_stats_proc_ops = {
 	.proc_show	= vcpudispatch_stats_display,
-	.proc_write_buf	= vcpudispatch_stats_write,
+	.proc_write	= vcpudispatch_stats_write,
 };
 
 static ssize_t vcpudispatch_stats_freq_write(struct file *file,
@@ -620,7 +620,7 @@ static int vcpudispatch_stats_freq_display(struct seq_file *p, void *v)
 
 static const struct proc_ops vcpudispatch_stats_freq_proc_ops = {
 	.proc_show	= vcpudispatch_stats_freq_display,
-	.proc_write_buf	= vcpudispatch_stats_freq_write,
+	.proc_write	= vcpudispatch_stats_freq_write,
 };
 
 static int __init vcpudispatch_stats_procfs_init(void)
diff --git a/arch/powerpc/platforms/pseries/lparcfg.c b/arch/powerpc/platforms/pseries/lparcfg.c
index 43af7f820fab..e63a2701a319 100644
--- a/arch/powerpc/platforms/pseries/lparcfg.c
+++ b/arch/powerpc/platforms/pseries/lparcfg.c
@@ -798,7 +798,7 @@ static int lparcfg_data(struct seq_file *m, void *v)
 }
 
 static const struct proc_ops lparcfg_proc_ops = {
-	.proc_write_buf	= lparcfg_write,
+	.proc_write	= lparcfg_write,
 	.proc_show	= lparcfg_data,
 };
 
diff --git a/arch/powerpc/platforms/pseries/reconfig.c b/arch/powerpc/platforms/pseries/reconfig.c
index f406e826a03e..bbbd8503e0d2 100644
--- a/arch/powerpc/platforms/pseries/reconfig.c
+++ b/arch/powerpc/platforms/pseries/reconfig.c
@@ -390,7 +390,7 @@ static ssize_t ofdt_write(struct file *file, char *kbuf, size_t count,
 }
 
 static const struct proc_ops ofdt_proc_ops = {
-	.proc_write_buf	= ofdt_write,
+	.proc_write	= ofdt_write,
 	/* what memdup_user_nul() could copy in */
 	.proc_write_size = KMALLOC_MAX_SIZE - 1,
 	.proc_lseek	= noop_llseek,
diff --git a/arch/sh/mm/alignment.c b/arch/sh/mm/alignment.c
index d832249a8e18..d76596820a6f 100644
--- a/arch/sh/mm/alignment.c
+++ b/arch/sh/mm/alignment.c
@@ -148,7 +148,7 @@ static ssize_t alignment_proc_write(struct file *file,
 
 static const struct proc_ops alignment_proc_ops = {
 	.proc_show	= alignment_proc_show,
-	.proc_write_buf	= alignment_proc_write,
+	.proc_write	= alignment_proc_write,
 };
 
 /*
diff --git a/arch/sparc/kernel/led.c b/arch/sparc/kernel/led.c
index 01449b056cdd..32fca52e198d 100644
--- a/arch/sparc/kernel/led.c
+++ b/arch/sparc/kernel/led.c
@@ -95,7 +95,7 @@ static ssize_t led_proc_write(struct file *file, char *buf,
 
 static const struct proc_ops led_proc_ops = {
 	.proc_show	= led_proc_show,
-	.proc_write_buf	= led_proc_write,
+	.proc_write	= led_proc_write,
 };
 #endif
 
diff --git a/arch/um/drivers/mconsole_kern.c b/arch/um/drivers/mconsole_kern.c
index a4370470286f..882c6f30a3c2 100644
--- a/arch/um/drivers/mconsole_kern.c
+++ b/arch/um/drivers/mconsole_kern.c
@@ -776,7 +776,7 @@ static ssize_t mconsole_proc_write(struct file *file,
 }
 
 static const struct proc_ops mconsole_proc_ops = {
-	.proc_write_buf	= mconsole_proc_write,
+	.proc_write	= mconsole_proc_write,
 	.proc_lseek	= noop_llseek,
 };
 
diff --git a/arch/um/kernel/exitcode.c b/arch/um/kernel/exitcode.c
index 8f76e3b20c18..15b114fbaa05 100644
--- a/arch/um/kernel/exitcode.c
+++ b/arch/um/kernel/exitcode.c
@@ -47,7 +47,7 @@ static ssize_t exitcode_proc_write(struct file *file,
 
 static const struct proc_ops exitcode_proc_ops = {
 	.proc_show	= exitcode_proc_show,
-	.proc_write_buf	= exitcode_proc_write,
+	.proc_write	= exitcode_proc_write,
 };
 
 static int make_proc_exitcode(void)
diff --git a/arch/x86/kernel/cpu/mtrr/if.c b/arch/x86/kernel/cpu/mtrr/if.c
index 9c33c0428dfe..e0f0257cba32 100644
--- a/arch/x86/kernel/cpu/mtrr/if.c
+++ b/arch/x86/kernel/cpu/mtrr/if.c
@@ -410,8 +410,8 @@ static const struct proc_ioctl_arg mtrr_ioctl_args[] = {
 static const struct proc_ops mtrr_proc_ops = {
 	.proc_show		= mtrr_seq_show,
 	.proc_open		= mtrr_open,
-	.proc_write_buf		= mtrr_write,
-	.proc_ioctl_buf		= mtrr_ioctl,
+	.proc_write		= mtrr_write,
+	.proc_ioctl		= mtrr_ioctl,
 	.proc_ioctl_args	= mtrr_ioctl_args,
 	.proc_nr_ioctl_args	= ARRAY_SIZE(mtrr_ioctl_args),
 	.proc_release		= mtrr_close,
diff --git a/arch/xtensa/platforms/iss/simdisk.c b/arch/xtensa/platforms/iss/simdisk.c
index b597d8642e8a..33108e043cc9 100644
--- a/arch/xtensa/platforms/iss/simdisk.c
+++ b/arch/xtensa/platforms/iss/simdisk.c
@@ -280,8 +280,8 @@ static ssize_t proc_write_simdisk(struct file *file, char *buf,
 }
 
 static const struct proc_ops simdisk_proc_ops = {
-	.proc_read_buf	= proc_read_simdisk,
-	.proc_write_buf	= proc_write_simdisk,
+	.proc_read	= proc_read_simdisk,
+	.proc_write	= proc_write_simdisk,
 	.proc_write_size = PAGE_SIZE,
 	.proc_lseek	= default_llseek,
 };
diff --git a/drivers/acpi/proc.c b/drivers/acpi/proc.c
index feb8283fd855..4b5ca9300e9d 100644
--- a/drivers/acpi/proc.c
+++ b/drivers/acpi/proc.c
@@ -122,7 +122,7 @@ acpi_system_write_wakeup_device(struct file *file,
 
 static const struct proc_ops acpi_system_wakeup_device_proc_ops = {
 	.proc_show	= acpi_system_wakeup_device_seq_show,
-	.proc_write_buf	= acpi_system_write_wakeup_device,
+	.proc_write	= acpi_system_write_wakeup_device,
 };
 
 void __init acpi_sleep_proc_init(void)
diff --git a/drivers/hwmon/dell-smm-hwmon.c b/drivers/hwmon/dell-smm-hwmon.c
index 67b8c6e5752f..529386faa6a5 100644
--- a/drivers/hwmon/dell-smm-hwmon.c
+++ b/drivers/hwmon/dell-smm-hwmon.c
@@ -694,7 +694,7 @@ static int i8k_proc_show(struct seq_file *seq, void *offset)
 
 static const struct proc_ops i8k_proc_ops = {
 	.proc_show	= i8k_proc_show,
-	.proc_ioctl_buf	= i8k_ioctl,
+	.proc_ioctl	= i8k_ioctl,
 	.proc_ioctl_args = i8k_ioctl_args,
 	.proc_nr_ioctl_args = ARRAY_SIZE(i8k_ioctl_args),
 };
diff --git a/drivers/macintosh/via-pmu.c b/drivers/macintosh/via-pmu.c
index 079c085be5d2..397a1c68cb04 100644
--- a/drivers/macintosh/via-pmu.c
+++ b/drivers/macintosh/via-pmu.c
@@ -957,7 +957,7 @@ static ssize_t pmu_options_proc_write(struct file *file,
 
 static const struct proc_ops pmu_options_proc_ops = {
 	.proc_show	= pmu_options_proc_show,
-	.proc_write_buf	= pmu_options_proc_write,
+	.proc_write	= pmu_options_proc_write,
 };
 #endif
 
diff --git a/drivers/net/wireless/intel/ipw2x00/libipw_module.c b/drivers/net/wireless/intel/ipw2x00/libipw_module.c
index 08cc0d7f57c1..e4061a4e2254 100644
--- a/drivers/net/wireless/intel/ipw2x00/libipw_module.c
+++ b/drivers/net/wireless/intel/ipw2x00/libipw_module.c
@@ -235,7 +235,7 @@ static ssize_t debug_level_proc_write(struct file *file,
 
 static const struct proc_ops debug_level_proc_ops = {
 	.proc_show	= debug_level_proc_show,
-	.proc_write_buf	= debug_level_proc_write,
+	.proc_write	= debug_level_proc_write,
 };
 #endif				/* CONFIG_LIBIPW_DEBUG */
 
diff --git a/drivers/pci/proc.c b/drivers/pci/proc.c
index 6b0cb5bcbea3..bae43df6e4ac 100644
--- a/drivers/pci/proc.c
+++ b/drivers/pci/proc.c
@@ -331,10 +331,10 @@ static const struct proc_ioctl_arg proc_bus_pci_ioctl_args[] = {
 static const struct proc_ops proc_bus_pci_ops = {
 	.proc_flags	= PROC_ENTRY_SHORT_WRITES,
 	.proc_lseek	= proc_bus_pci_lseek,
-	.proc_read_buf	= proc_bus_pci_read,
-	.proc_write_buf	= proc_bus_pci_write,
+	.proc_read	= proc_bus_pci_read,
+	.proc_write	= proc_bus_pci_write,
 	.proc_write_size = PCI_CFG_SPACE_EXP_SIZE,
-	.proc_ioctl_buf	= proc_bus_pci_ioctl,
+	.proc_ioctl	= proc_bus_pci_ioctl,
 	.proc_ioctl_args = proc_bus_pci_ioctl_args,
 	.proc_nr_ioctl_args = ARRAY_SIZE(proc_bus_pci_ioctl_args),
 #ifdef HAVE_PCI_MMAP
diff --git a/drivers/platform/x86/lenovo/thinkpad_acpi.c b/drivers/platform/x86/lenovo/thinkpad_acpi.c
index b4f253da9536..72d26e7438c9 100644
--- a/drivers/platform/x86/lenovo/thinkpad_acpi.c
+++ b/drivers/platform/x86/lenovo/thinkpad_acpi.c
@@ -899,7 +899,7 @@ static ssize_t dispatch_proc_write(struct file *file,
 
 static const struct proc_ops dispatch_proc_ops = {
 	.proc_show	= dispatch_proc_show,
-	.proc_write_buf	= dispatch_proc_write,
+	.proc_write	= dispatch_proc_write,
 };
 
 /****************************************************************************
diff --git a/drivers/platform/x86/toshiba_acpi.c b/drivers/platform/x86/toshiba_acpi.c
index 895e321ada03..98c91463baf0 100644
--- a/drivers/platform/x86/toshiba_acpi.c
+++ b/drivers/platform/x86/toshiba_acpi.c
@@ -1504,7 +1504,7 @@ static ssize_t lcd_proc_write(struct file *file, char *buf,
 
 static const struct proc_ops lcd_proc_ops = {
 	.proc_show	= lcd_proc_show,
-	.proc_write_buf	= lcd_proc_write,
+	.proc_write	= lcd_proc_write,
 };
 
 /* Video-Out */
@@ -1592,7 +1592,7 @@ static ssize_t video_proc_write(struct file *file, char *buf,
 
 static const struct proc_ops video_proc_ops = {
 	.proc_show	= video_proc_show,
-	.proc_write_buf	= video_proc_write,
+	.proc_write	= video_proc_write,
 };
 
 /* Fan status */
@@ -1660,7 +1660,7 @@ static ssize_t fan_proc_write(struct file *file, char *buf,
 
 static const struct proc_ops fan_proc_ops = {
 	.proc_show	= fan_proc_show,
-	.proc_write_buf	= fan_proc_write,
+	.proc_write	= fan_proc_write,
 };
 
 /* Fan RPM */
@@ -1718,7 +1718,7 @@ static ssize_t keys_proc_write(struct file *file, char *buf,
 
 static const struct proc_ops keys_proc_ops = {
 	.proc_show	= keys_proc_show,
-	.proc_write_buf	= keys_proc_write,
+	.proc_write	= keys_proc_write,
 };
 
 static int __maybe_unused version_proc_show(struct seq_file *m, void *v)
diff --git a/drivers/pnp/isapnp/proc.c b/drivers/pnp/isapnp/proc.c
index 152fd5bfbc06..c6198bf3fa9c 100644
--- a/drivers/pnp/isapnp/proc.c
+++ b/drivers/pnp/isapnp/proc.c
@@ -43,7 +43,7 @@ static ssize_t isapnp_proc_bus_read(struct file *file, char *buf,
 
 static const struct proc_ops isapnp_proc_bus_proc_ops = {
 	.proc_lseek	= isapnp_proc_bus_lseek,
-	.proc_read_buf	= isapnp_proc_bus_read,
+	.proc_read	= isapnp_proc_bus_read,
 };
 
 static int isapnp_proc_attach_device(struct pnp_dev *dev)
diff --git a/drivers/pnp/pnpbios/proc.c b/drivers/pnp/pnpbios/proc.c
index 00163aedd738..6441212f7fe7 100644
--- a/drivers/pnp/pnpbios/proc.c
+++ b/drivers/pnp/pnpbios/proc.c
@@ -204,7 +204,7 @@ out:
 
 static const struct proc_ops pnpbios_proc_ops = {
 	.proc_show	= pnpbios_proc_show,
-	.proc_write_buf	= pnpbios_proc_write,
+	.proc_write	= pnpbios_proc_write,
 };
 
 int pnpbios_interface_attach_device(struct pnp_bios_node *node)
diff --git a/drivers/s390/block/dasd_proc.c b/drivers/s390/block/dasd_proc.c
index 6c3bbb7dfe85..002e2d2d498c 100644
--- a/drivers/s390/block/dasd_proc.c
+++ b/drivers/s390/block/dasd_proc.c
@@ -307,7 +307,7 @@ out_error:
 
 static const struct proc_ops dasd_stats_proc_ops = {
 	.proc_show	= dasd_stats_proc_show,
-	.proc_write_buf	= dasd_stats_proc_write,
+	.proc_write	= dasd_stats_proc_write,
 };
 
 /*
diff --git a/drivers/s390/cio/blacklist.c b/drivers/s390/cio/blacklist.c
index 1ec7915be6b3..d8a22c83626b 100644
--- a/drivers/s390/cio/blacklist.c
+++ b/drivers/s390/cio/blacklist.c
@@ -386,7 +386,7 @@ static const struct proc_ops cio_ignore_proc_ops = {
 	.proc_flags	= PROC_ENTRY_SHORT_WRITES,
 	.proc_seq_ops	= &cio_ignore_proc_seq_ops,
 	.proc_state_size = sizeof(struct ccwdev_iter),
-	.proc_write_buf	= cio_ignore_write,
+	.proc_write	= cio_ignore_write,
 	.proc_write_size = SZ_64K,
 };
 
diff --git a/drivers/s390/cio/css.c b/drivers/s390/cio/css.c
index efd3df3e90ba..1813074c8c72 100644
--- a/drivers/s390/cio/css.c
+++ b/drivers/s390/cio/css.c
@@ -1292,7 +1292,7 @@ static ssize_t cio_settle_write(struct file *file, char *buf,
 
 static const struct proc_ops cio_settle_proc_ops = {
 	.proc_open	= nonseekable_open,
-	.proc_write_buf	= cio_settle_write,
+	.proc_write	= cio_settle_write,
 };
 
 static int __init cio_settle_init(void)
diff --git a/drivers/scsi/esas2r/esas2r_main.c b/drivers/scsi/esas2r/esas2r_main.c
index 720be2a0907d..5effad56bb39 100644
--- a/drivers/scsi/esas2r/esas2r_main.c
+++ b/drivers/scsi/esas2r/esas2r_main.c
@@ -653,7 +653,7 @@ static const struct proc_ioctl_arg esas2r_proc_ioctl_args[] = {
 
 static const struct proc_ops esas2r_proc_ops = {
 	.proc_lseek		= default_llseek,
-	.proc_ioctl_buf		= esas2r_proc_ioctl_buf,
+	.proc_ioctl		= esas2r_proc_ioctl_buf,
 	.proc_ioctl_args	= esas2r_proc_ioctl_args,
 	.proc_nr_ioctl_args	= ARRAY_SIZE(esas2r_proc_ioctl_args),
 };
diff --git a/drivers/scsi/scsi_devinfo.c b/drivers/scsi/scsi_devinfo.c
index d9093851b23e..6667661ca62d 100644
--- a/drivers/scsi/scsi_devinfo.c
+++ b/drivers/scsi/scsi_devinfo.c
@@ -690,7 +690,7 @@ static ssize_t proc_scsi_devinfo_write(struct file *file,
 
 static const struct proc_ops scsi_devinfo_proc_ops = {
 	.proc_seq_ops	= &scsi_devinfo_seq_ops,
-	.proc_write_buf	= proc_scsi_devinfo_write,
+	.proc_write	= proc_scsi_devinfo_write,
 	.proc_write_size = PAGE_SIZE,
 };
 #endif /* CONFIG_SCSI_PROC_FS */
diff --git a/drivers/scsi/scsi_proc.c b/drivers/scsi/scsi_proc.c
index 5962e671cc83..efc393fe9047 100644
--- a/drivers/scsi/scsi_proc.c
+++ b/drivers/scsi/scsi_proc.c
@@ -130,7 +130,7 @@ EXPORT_SYMBOL_GPL(scsi_template_proc_dir);
 static const struct proc_ops proc_scsi_ops = {
 	.proc_show	= proc_scsi_show,
 	.proc_open	= proc_scsi_host_open,
-	.proc_write_buf	= proc_scsi_host_write
+	.proc_write	= proc_scsi_host_write
 };
 
 /**
@@ -495,7 +495,7 @@ static const struct seq_operations scsi_seq_ops = {
 
 static const struct proc_ops scsi_scsi_proc_ops = {
 	.proc_seq_ops	= &scsi_seq_ops,
-	.proc_write_buf	= proc_scsi_write,
+	.proc_write	= proc_scsi_write,
 	.proc_write_size = PAGE_SIZE,
 };
 
diff --git a/drivers/scsi/sg.c b/drivers/scsi/sg.c
index 87569e302f26..36d046f05c64 100644
--- a/drivers/scsi/sg.c
+++ b/drivers/scsi/sg.c
@@ -2291,14 +2291,14 @@ static ssize_t sg_proc_write_adio(struct file *filp, char *buffer,
 			          size_t count, loff_t *off);
 static const struct proc_ops adio_proc_ops = {
 	.proc_show	= sg_proc_seq_show_int,
-	.proc_write_buf	= sg_proc_write_adio,
+	.proc_write	= sg_proc_write_adio,
 };
 
 static ssize_t sg_proc_write_dressz(struct file *filp, 
 		char *buffer, size_t count, loff_t *off);
 static const struct proc_ops dressz_proc_ops = {
 	.proc_show	= sg_proc_seq_show_int,
-	.proc_write_buf	= sg_proc_write_dressz,
+	.proc_write	= sg_proc_write_dressz,
 };
 
 static int sg_proc_seq_show_version(struct seq_file *s, void *v);
diff --git a/drivers/tty/sysrq.c b/drivers/tty/sysrq.c
index 99363e1b59ed..d6000c9c3cbe 100644
--- a/drivers/tty/sysrq.c
+++ b/drivers/tty/sysrq.c
@@ -1222,7 +1222,7 @@ static ssize_t write_sysrq_trigger(struct file *file, char *buf,
 }
 
 static const struct proc_ops sysrq_trigger_proc_ops = {
-	.proc_write_buf	= write_sysrq_trigger,
+	.proc_write	= write_sysrq_trigger,
 	.proc_lseek	= noop_llseek,
 };
 
diff --git a/drivers/usb/gadget/function/rndis.c b/drivers/usb/gadget/function/rndis.c
index e05e0c6ae8fb..ef70d7bc1f0d 100644
--- a/drivers/usb/gadget/function/rndis.c
+++ b/drivers/usb/gadget/function/rndis.c
@@ -1184,7 +1184,7 @@ static ssize_t rndis_proc_write(struct file *file, char *buffer,
 
 static const struct proc_ops rndis_proc_ops = {
 	.proc_show	= rndis_proc_show,
-	.proc_write_buf	= rndis_proc_write,
+	.proc_write	= rndis_proc_write,
 };
 
 #define	NAME_TEMPLATE "driver/rndis-%03d"
diff --git a/drivers/video/fbdev/via/viafbdev.c b/drivers/video/fbdev/via/viafbdev.c
index 94b303006915..7732a5eea857 100644
--- a/drivers/video/fbdev/via/viafbdev.c
+++ b/drivers/video/fbdev/via/viafbdev.c
@@ -1168,7 +1168,7 @@ static ssize_t viafb_dvp0_proc_write(struct file *file,
 
 static const struct proc_ops viafb_dvp0_proc_ops = {
 	.proc_show	= viafb_dvp0_proc_show,
-	.proc_write_buf	= viafb_dvp0_proc_write,
+	.proc_write	= viafb_dvp0_proc_write,
 };
 
 static int viafb_dvp1_proc_show(struct seq_file *m, void *v)
@@ -1223,7 +1223,7 @@ static ssize_t viafb_dvp1_proc_write(struct file *file,
 
 static const struct proc_ops viafb_dvp1_proc_ops = {
 	.proc_show	= viafb_dvp1_proc_show,
-	.proc_write_buf	= viafb_dvp1_proc_write,
+	.proc_write	= viafb_dvp1_proc_write,
 };
 
 static int viafb_dfph_proc_show(struct seq_file *m, void *v)
@@ -1249,7 +1249,7 @@ static ssize_t viafb_dfph_proc_write(struct file *file,
 
 static const struct proc_ops viafb_dfph_proc_ops = {
 	.proc_show	= viafb_dfph_proc_show,
-	.proc_write_buf	= viafb_dfph_proc_write,
+	.proc_write	= viafb_dfph_proc_write,
 };
 
 static int viafb_dfpl_proc_show(struct seq_file *m, void *v)
@@ -1275,7 +1275,7 @@ static ssize_t viafb_dfpl_proc_write(struct file *file,
 
 static const struct proc_ops viafb_dfpl_proc_ops = {
 	.proc_show	= viafb_dfpl_proc_show,
-	.proc_write_buf	= viafb_dfpl_proc_write,
+	.proc_write	= viafb_dfpl_proc_write,
 };
 
 static int viafb_vt1636_proc_show(struct seq_file *m, void *v)
@@ -1401,7 +1401,7 @@ static ssize_t viafb_vt1636_proc_write(struct file *file,
 
 static const struct proc_ops viafb_vt1636_proc_ops = {
 	.proc_show	= viafb_vt1636_proc_show,
-	.proc_write_buf	= viafb_vt1636_proc_write,
+	.proc_write	= viafb_vt1636_proc_write,
 };
 
 #endif /* CONFIG_FB_VIA_DIRECT_PROCFS */
@@ -1469,7 +1469,7 @@ static ssize_t viafb_iga1_odev_proc_write(struct file *file,
 
 static const struct proc_ops viafb_iga1_odev_proc_ops = {
 	.proc_show	= viafb_iga1_odev_proc_show,
-	.proc_write_buf	= viafb_iga1_odev_proc_write,
+	.proc_write	= viafb_iga1_odev_proc_write,
 };
 
 static int viafb_iga2_odev_proc_show(struct seq_file *m, void *v)
@@ -1500,7 +1500,7 @@ static ssize_t viafb_iga2_odev_proc_write(struct file *file,
 
 static const struct proc_ops viafb_iga2_odev_proc_ops = {
 	.proc_show	= viafb_iga2_odev_proc_show,
-	.proc_write_buf	= viafb_iga2_odev_proc_write,
+	.proc_write	= viafb_iga2_odev_proc_write,
 };
 
 #define IS_VT1636(lvds_chip)	((lvds_chip).lvds_chip_name == VT1636_LVDS)
diff --git a/drivers/zorro/proc.c b/drivers/zorro/proc.c
index 4e4ba04752ea..af6a2d1f059d 100644
--- a/drivers/zorro/proc.c
+++ b/drivers/zorro/proc.c
@@ -57,7 +57,7 @@ proc_bus_zorro_read(struct file *file, char *buf, size_t nbytes, loff_t *ppos)
 
 static const struct proc_ops bus_zorro_proc_ops = {
 	.proc_lseek	= proc_bus_zorro_lseek,
-	.proc_read_buf	= proc_bus_zorro_read,
+	.proc_read	= proc_bus_zorro_read,
 };
 
 static void * zorro_seq_start(struct seq_file *m, loff_t *pos)
diff --git a/fs/jfs/jfs_debug.c b/fs/jfs/jfs_debug.c
index e1c0211a6a32..a1fec8e51c7d 100644
--- a/fs/jfs/jfs_debug.c
+++ b/fs/jfs/jfs_debug.c
@@ -37,7 +37,7 @@ static ssize_t jfs_loglevel_proc_write(struct file *file, char *buffer,
 
 static const struct proc_ops jfs_loglevel_proc_ops = {
 	.proc_show	= jfs_loglevel_proc_show,
-	.proc_write_buf	= jfs_loglevel_proc_write,
+	.proc_write	= jfs_loglevel_proc_write,
 };
 #endif
 
diff --git a/fs/lockd/procfs.c b/fs/lockd/procfs.c
index 34a7c3705bb6..0b6d404e83c3 100644
--- a/fs/lockd/procfs.c
+++ b/fs/lockd/procfs.c
@@ -55,8 +55,8 @@ nlm_end_grace_read(struct file *file, char *buf, size_t size,
 }
 
 static const struct proc_ops lockd_end_grace_proc_ops = {
-	.proc_write_buf	= nlm_end_grace_write,
-	.proc_read_buf	= nlm_end_grace_read,
+	.proc_write	= nlm_end_grace_write,
+	.proc_read	= nlm_end_grace_read,
 	.proc_lseek	= default_llseek,
 };
 
diff --git a/fs/ntfs3/super.c b/fs/ntfs3/super.c
index fca73d2766c0..0a0004936a22 100644
--- a/fs/ntfs3/super.c
+++ b/fs/ntfs3/super.c
@@ -566,7 +566,7 @@ static const struct proc_ops ntfs3_volinfo_fops = {
 
 static const struct proc_ops ntfs3_label_fops = {
 	.proc_show = ntfs3_label_show,
-	.proc_write_buf = ntfs3_label_write,
+	.proc_write = ntfs3_label_write,
 };
 
 static void ntfs_create_procdir(struct super_block *sb)
diff --git a/fs/proc/generic.c b/fs/proc/generic.c
index 4bcec5a29b5f..693c0867889c 100644
--- a/fs/proc/generic.c
+++ b/fs/proc/generic.c
@@ -474,28 +474,28 @@ static int pde_set_flags(struct proc_dir_entry *pde)
 		if (proc_ops->proc_lseek)
 			pde->flags |= PROC_ENTRY_proc_lseek;
 	}
-	if (proc_ops->proc_write_buf) {
-		pde->flags |= PROC_ENTRY_proc_write_buf;
+	if (proc_ops->proc_write) {
+		pde->flags |= PROC_ENTRY_proc_write;
 		pde->write_size = proc_ops->proc_write_size ?: PAGE_SIZE - 1;
 		if (proc_ops->proc_flags & PROC_ENTRY_SHORT_WRITES)
 			pde->flags |= PROC_ENTRY_SHORT_WRITES;
 	}
-	if (proc_ops->proc_read_buf) {
+	if (proc_ops->proc_read) {
 		if (WARN_ON_ONCE(pde_is_seq_file(pde) ||
 				 proc_ops->proc_permanent_read ||
 				 proc_ops->proc_permanent_read_iter))
 			return -EINVAL;
-		pde->flags |= PROC_ENTRY_proc_read_buf;
+		pde->flags |= PROC_ENTRY_proc_read;
 		pde->read_size = proc_ops->proc_read_size ?: PAGE_SIZE;
 		if (proc_ops->proc_flags & PROC_ENTRY_FULL_READS)
 			pde->flags |= PROC_ENTRY_FULL_READS;
 	}
-	if (proc_ops->proc_ioctl_buf) {
+	if (proc_ops->proc_ioctl) {
 		/* the table says what procfs copies, see pde_ioctl_arg() */
 		if (WARN_ON_ONCE(!proc_ops->proc_ioctl_args ||
 				 !proc_ops->proc_nr_ioctl_args))
 			return -EINVAL;
-		pde->flags |= PROC_ENTRY_proc_ioctl_buf;
+		pde->flags |= PROC_ENTRY_proc_ioctl;
 	} else if (WARN_ON_ONCE(proc_ops->proc_ioctl_args ||
 				proc_ops->proc_nr_ioctl_args)) {
 		return -EINVAL;
diff --git a/fs/proc/inode.c b/fs/proc/inode.c
index 16d8f00bfc26..3b38672c0a0c 100644
--- a/fs/proc/inode.c
+++ b/fs/proc/inode.c
@@ -408,7 +408,7 @@ static loff_t proc_reg_llseek(struct file *file, loff_t offset, int whence)
  * unpinning the entry. A reader that faults on its buffer then doesn't hold
  * up remove_proc_entry().
  */
-static ssize_t pde_read_buf(struct proc_dir_entry *pde, struct kiocb *iocb,
+static ssize_t pde_read(struct proc_dir_entry *pde, struct kiocb *iocb,
 			    struct iov_iter *iter)
 {
 	struct file *file = iocb->ki_filp;
@@ -435,7 +435,7 @@ static ssize_t pde_read_buf(struct proc_dir_entry *pde, struct kiocb *iocb,
 			rv = -EIO;
 			break;
 		}
-		rv = pde->proc_ops->proc_read_buf(file, buf, count, &pos);
+		rv = pde->proc_ops->proc_read(file, buf, count, &pos);
 		pde_unpin(pde);
 		if (rv <= 0)
 			break;
@@ -461,8 +461,8 @@ static ssize_t proc_reg_read_iter(struct kiocb *iocb, struct iov_iter *iter)
 {
 	struct proc_dir_entry *pde = PDE(file_inode(iocb->ki_filp));
 
-	if (pde_has_proc_read_buf(pde))
-		return pde_read_buf(pde, iocb, iter);
+	if (pde_has_proc_read(pde))
+		return pde_read(pde, iocb, iter);
 	/* only permanent entries have one, see pde_set_flags() */
 	return pde->proc_ops->proc_permanent_read_iter(iocb, iter);
 }
@@ -484,7 +484,7 @@ static ssize_t proc_reg_read(struct file *file, char __user *buf, size_t count,
  * procfs copies in what is written before it pins the entry. A writer that
  * faults on its buffer then doesn't hold up remove_proc_entry().
  */
-static ssize_t pde_write_buf(struct proc_dir_entry *pde, struct file *file,
+static ssize_t pde_write(struct proc_dir_entry *pde, struct file *file,
 			     const char __user *ubuf, size_t count, loff_t *ppos)
 {
 	char *buf __free(kvfree) = NULL;
@@ -506,7 +506,7 @@ static ssize_t pde_write_buf(struct proc_dir_entry *pde, struct file *file,
 
 	if (!pde_pin(pde))
 		return -EIO;
-	rv = pde->proc_ops->proc_write_buf(file, buf, count, ppos);
+	rv = pde->proc_ops->proc_write(file, buf, count, ppos);
 	pde_unpin(pde);
 	return rv;
 }
@@ -515,8 +515,8 @@ static ssize_t proc_reg_write(struct file *file, const char __user *buf, size_t
 {
 	struct proc_dir_entry *pde = PDE(file_inode(file));
 
-	if (pde_has_proc_write_buf(pde))
-		return pde_write_buf(pde, file, buf, count, ppos);
+	if (pde_has_proc_write(pde))
+		return pde_write(pde, file, buf, count, ppos);
 	return -EIO;
 }
 
@@ -565,7 +565,7 @@ static bool pde_ioctl_arg(struct proc_dir_entry *pde, unsigned int cmd,
  * out after unpinning it. An ioctl that faults on its argument then doesn't
  * hold up remove_proc_entry().
  */
-static long pde_ioctl_buf(struct proc_dir_entry *pde, struct file *file,
+static long pde_ioctl(struct proc_dir_entry *pde, struct file *file,
 			  unsigned int cmd, void __user *uarg, unsigned long arg)
 {
 	void *buf __free(kvfree) = NULL;
@@ -586,7 +586,7 @@ static long pde_ioctl_buf(struct proc_dir_entry *pde, struct file *file,
 
 	if (!pde_pin(pde))
 		return -ENOTTY;
-	rv = pde->proc_ops->proc_ioctl_buf(file, cmd, buf ?: (void *)arg);
+	rv = pde->proc_ops->proc_ioctl(file, cmd, buf ?: (void *)arg);
 	pde_unpin(pde);
 	if (rv >= 0 && copy_to_user(uarg, buf, a.out))
 		return -EFAULT;
@@ -597,8 +597,8 @@ static long proc_reg_unlocked_ioctl(struct file *file, unsigned int cmd, unsigne
 {
 	struct proc_dir_entry *pde = PDE(file_inode(file));
 
-	if (pde_has_proc_ioctl_buf(pde))
-		return pde_ioctl_buf(pde, file, cmd, (void __user *)arg, arg);
+	if (pde_has_proc_ioctl(pde))
+		return pde_ioctl(pde, file, cmd, (void __user *)arg, arg);
 	return -ENOTTY;
 }
 
@@ -607,8 +607,8 @@ static long proc_reg_compat_ioctl(struct file *file, unsigned int cmd, unsigned
 {
 	struct proc_dir_entry *pde = PDE(file_inode(file));
 
-	if (pde_has_proc_ioctl_buf(pde))
-		return pde_ioctl_buf(pde, file, cmd, compat_ptr(arg), arg);
+	if (pde_has_proc_ioctl(pde))
+		return pde_ioctl(pde, file, cmd, compat_ptr(arg), arg);
 	return -ENOTTY;
 }
 #else
@@ -881,7 +881,7 @@ struct inode *proc_get_inode(struct super_block *sb, struct proc_dir_entry *de)
 		if (pde_is_seq_file(de))
 			inode->i_fop = &proc_seq_file_ops;
 		else if (pde_has_proc_permanent_read_iter(de) ||
-			 pde_has_proc_read_buf(de))
+			 pde_has_proc_read(de))
 			inode->i_fop = &proc_iter_file_ops;
 		else
 			inode->i_fop = &proc_reg_file_ops;
diff --git a/fs/proc/internal.h b/fs/proc/internal.h
index f4677815ebfa..00f7c0bbb82b 100644
--- a/fs/proc/internal.h
+++ b/fs/proc/internal.h
@@ -110,9 +110,9 @@ static inline bool pde_has_proc_show(const struct proc_dir_entry *pde)
 	return pde->flags & PROC_ENTRY_proc_show;
 }
 
-static inline bool pde_has_proc_write_buf(const struct proc_dir_entry *pde)
+static inline bool pde_has_proc_write(const struct proc_dir_entry *pde)
 {
-	return pde->flags & PROC_ENTRY_proc_write_buf;
+	return pde->flags & PROC_ENTRY_proc_write;
 }
 
 static inline bool pde_has_short_writes(const struct proc_dir_entry *pde)
@@ -120,9 +120,9 @@ static inline bool pde_has_short_writes(const struct proc_dir_entry *pde)
 	return pde->flags & PROC_ENTRY_SHORT_WRITES;
 }
 
-static inline bool pde_has_proc_read_buf(const struct proc_dir_entry *pde)
+static inline bool pde_has_proc_read(const struct proc_dir_entry *pde)
 {
-	return pde->flags & PROC_ENTRY_proc_read_buf;
+	return pde->flags & PROC_ENTRY_proc_read;
 }
 
 static inline bool pde_has_full_reads(const struct proc_dir_entry *pde)
@@ -130,9 +130,9 @@ static inline bool pde_has_full_reads(const struct proc_dir_entry *pde)
 	return pde->flags & PROC_ENTRY_FULL_READS;
 }
 
-static inline bool pde_has_proc_ioctl_buf(const struct proc_dir_entry *pde)
+static inline bool pde_has_proc_ioctl(const struct proc_dir_entry *pde)
 {
-	return pde->flags & PROC_ENTRY_proc_ioctl_buf;
+	return pde->flags & PROC_ENTRY_proc_ioctl;
 }
 
 /* procfs owns the seq_file, see pde_seq_ops */
diff --git a/fs/proc/proc_net.c b/fs/proc/proc_net.c
index cdeb2e025d2e..fa485581d05e 100644
--- a/fs/proc/proc_net.c
+++ b/fs/proc/proc_net.c
@@ -77,7 +77,7 @@ static int seq_release_net(struct inode *ino, struct file *f)
 
 static const struct proc_ops proc_net_seq_ops = {
 	.proc_open	= seq_open_net,
-	.proc_write_buf	= proc_simple_write,
+	.proc_write	= proc_simple_write,
 	.proc_release	= seq_release_net,
 };
 
@@ -186,7 +186,7 @@ static int single_release_net(struct inode *ino, struct file *f)
 
 static const struct proc_ops proc_net_single_ops = {
 	.proc_open	= single_open_net,
-	.proc_write_buf	= proc_simple_write,
+	.proc_write	= proc_simple_write,
 	.proc_release	= single_release_net,
 };
 
diff --git a/fs/proc/vmcore.c b/fs/proc/vmcore.c
index 1c1e71231f4e..33af42dc9a6a 100644
--- a/fs/proc/vmcore.c
+++ b/fs/proc/vmcore.c
@@ -718,7 +718,7 @@ static const struct proc_ops vmcore_proc_ops = {
 	.proc_flags	= PROC_ENTRY_FULL_READS,
 	.proc_open	= open_vmcore,
 	.proc_release	= release_vmcore,
-	.proc_read_buf	= read_vmcore,
+	.proc_read	= read_vmcore,
 	.proc_read_size	= SZ_128K,
 	.proc_lseek	= default_llseek,
 	.proc_mmap	= mmap_vmcore,
diff --git a/fs/smb/client/cifs_debug.c b/fs/smb/client/cifs_debug.c
index fb1323bf44c7..df449f6f5282 100644
--- a/fs/smb/client/cifs_debug.c
+++ b/fs/smb/client/cifs_debug.c
@@ -390,7 +390,7 @@ static ssize_t cifs_debug_dirs_proc_write(struct file *file, char *buffer,
 
 static const struct proc_ops cifs_debug_dirs_proc_ops = {
 	.proc_show	= cifs_debug_dirs_proc_show,
-	.proc_write_buf	= cifs_debug_dirs_proc_write,
+	.proc_write	= cifs_debug_dirs_proc_write,
 };
 #endif /* CONFIG_CIFS_DEBUG */
 
@@ -854,7 +854,7 @@ static int cifs_stats_proc_show(struct seq_file *m, void *v)
 
 static const struct proc_ops cifs_stats_proc_ops = {
 	.proc_show	= cifs_stats_proc_show,
-	.proc_write_buf	= cifs_stats_proc_write,
+	.proc_write	= cifs_stats_proc_write,
 };
 
 #ifdef CONFIG_CIFS_SMB_DIRECT
@@ -876,7 +876,7 @@ static int name##_proc_show(struct seq_file *m, void *v) \
 \
 static const struct proc_ops cifs_##name##_proc_fops = { \
 	.proc_show	= name##_proc_show, \
-	.proc_write_buf	= name##_write, \
+	.proc_write	= name##_write, \
 }
 
 PROC_FILE_DEFINE(rdma_readwrite_threshold);
@@ -1008,7 +1008,7 @@ static ssize_t cifsFYI_proc_write(struct file *file, char *buffer,
 
 static const struct proc_ops cifsFYI_proc_ops = {
 	.proc_show	= cifsFYI_proc_show,
-	.proc_write_buf	= cifsFYI_proc_write,
+	.proc_write	= cifsFYI_proc_write,
 };
 
 static int cifs_linux_ext_proc_show(struct seq_file *m, void *v)
@@ -1031,7 +1031,7 @@ static ssize_t cifs_linux_ext_proc_write(struct file *file, char *buffer,
 
 static const struct proc_ops cifs_linux_ext_proc_ops = {
 	.proc_show	= cifs_linux_ext_proc_show,
-	.proc_write_buf	= cifs_linux_ext_proc_write,
+	.proc_write	= cifs_linux_ext_proc_write,
 };
 
 static int cifs_lookup_cache_proc_show(struct seq_file *m, void *v)
@@ -1054,7 +1054,7 @@ static ssize_t cifs_lookup_cache_proc_write(struct file *file, char *buffer,
 
 static const struct proc_ops cifs_lookup_cache_proc_ops = {
 	.proc_show	= cifs_lookup_cache_proc_show,
-	.proc_write_buf	= cifs_lookup_cache_proc_write,
+	.proc_write	= cifs_lookup_cache_proc_write,
 };
 
 static int traceSMB_proc_show(struct seq_file *m, void *v)
@@ -1077,7 +1077,7 @@ static ssize_t traceSMB_proc_write(struct file *file, char *buffer,
 
 static const struct proc_ops traceSMB_proc_ops = {
 	.proc_show	= traceSMB_proc_show,
-	.proc_write_buf	= traceSMB_proc_write,
+	.proc_write	= traceSMB_proc_write,
 };
 
 static int cifs_security_flags_proc_show(struct seq_file *m, void *v)
@@ -1166,7 +1166,7 @@ static ssize_t cifs_security_flags_proc_write(struct file *file,
 
 static const struct proc_ops cifs_security_flags_proc_ops = {
 	.proc_show	= cifs_security_flags_proc_show,
-	.proc_write_buf	= cifs_security_flags_proc_write,
+	.proc_write	= cifs_security_flags_proc_write,
 };
 
 /* To make it easier to debug, can help to show mount params */
diff --git a/fs/smb/client/dfs_cache.c b/fs/smb/client/dfs_cache.c
index a6aa05430b15..8b5781e828b4 100644
--- a/fs/smb/client/dfs_cache.c
+++ b/fs/smb/client/dfs_cache.c
@@ -208,7 +208,7 @@ static ssize_t dfscache_proc_write(struct file *file, char *buffer,
 
 const struct proc_ops dfscache_proc_ops = {
 	.proc_show	= dfscache_proc_show,
-	.proc_write_buf	= dfscache_proc_write,
+	.proc_write	= dfscache_proc_write,
 };
 
 #ifdef CONFIG_CIFS_DEBUG2
diff --git a/include/linux/proc_fs.h b/include/linux/proc_fs.h
index 4db79f1ab97e..c27def365beb 100644
--- a/include/linux/proc_fs.h
+++ b/include/linux/proc_fs.h
@@ -35,26 +35,26 @@ enum {
 	PROC_ENTRY_proc_show		= 1U << 5,
 
 	PROC_ENTRY_FORCE_LOOKUP		= 1U << 7,
-	PROC_ENTRY_proc_write_buf	= 1U << 8,
+	PROC_ENTRY_proc_write	= 1U << 8,
 
 	/*
 	 * Writes larger than ->proc_write_size come up short instead of
 	 * failing with -EINVAL.
 	 */
 	PROC_ENTRY_SHORT_WRITES		= 1U << 9,
-	PROC_ENTRY_proc_read_buf	= 1U << 10,
+	PROC_ENTRY_proc_read	= 1U << 10,
 
 	/*
 	 * Reads larger than ->proc_read_size are filled in pieces instead of
 	 * coming up short.
 	 */
 	PROC_ENTRY_FULL_READS		= 1U << 11,
-	PROC_ENTRY_proc_ioctl_buf	= 1U << 12,
+	PROC_ENTRY_proc_ioctl	= 1U << 12,
 };
 
 /*
  * How many bytes of the argument of @cmd procfs copies in before calling
- * ->proc_ioctl_buf() and copies back out after it. A command that copies
+ * ->proc_ioctl() and copies back out after it. A command that copies
  * neither gets its argument as is.
  */
 struct proc_ioctl_arg {
@@ -77,7 +77,7 @@ struct proc_ops {
 	int	(*proc_open)(struct inode *, struct file *);
 	/*
 	 * These two are only for PROC_ENTRY_PERMANENT entries. Everything else
-	 * uses ->proc_read_buf().
+	 * uses ->proc_read().
 	 */
 	ssize_t	(*proc_permanent_read)(struct file *, char __user *, size_t,
 				       loff_t *);
@@ -108,26 +108,26 @@ struct proc_ops {
 	unsigned int proc_state_size;
 	/*
 	 * procfs copies what is written into a kernel buffer and calls
-	 * ->proc_write_buf() with it. The buffer is NUL-terminated and holds
+	 * ->proc_write() with it. The buffer is NUL-terminated and holds
 	 * at most ->proc_write_size bytes, PAGE_SIZE - 1 if that's 0. Larger
 	 * writes fail with -EINVAL unless the entry asks for
 	 * PROC_ENTRY_SHORT_WRITES. The position is NULL for a stream, like
 	 * for ->write().
 	 */
-	ssize_t	(*proc_write_buf)(struct file *, char *, size_t, loff_t *);
+	ssize_t	(*proc_write)(struct file *, char *, size_t, loff_t *);
 	unsigned int proc_write_size;
 	/*
-	 * procfs calls ->proc_read_buf() to fill a kernel buffer of at most
+	 * procfs calls ->proc_read() to fill a kernel buffer of at most
 	 * ->proc_read_size bytes, PAGE_SIZE if that's 0, and copies it to
 	 * userspace afterwards. Larger reads come up short unless the entry
 	 * asks for PROC_ENTRY_FULL_READS. The position the entry moves to only
 	 * sticks if the copy works.
 	 */
-	ssize_t	(*proc_read_buf)(struct file *, char *, size_t, loff_t *);
+	ssize_t	(*proc_read)(struct file *, char *, size_t, loff_t *);
 	unsigned int proc_read_size;
 	/*
 	 * procfs looks the command up in ->proc_ioctl_args, copies in what it
-	 * passes before pinning the entry, calls ->proc_ioctl_buf() with that
+	 * passes before pinning the entry, calls ->proc_ioctl() with that
 	 * copy and copies out what it returns after unpinning the entry.
 	 * Commands that aren't in the table fail with -ENOTTY. 32-bit tasks
 	 * go through the same table. The copy is zeroed and as large as the
@@ -135,7 +135,7 @@ struct proc_ops {
 	 * succeeded, and a command that copies neither gets its argument as
 	 * is.
 	 */
-	long	(*proc_ioctl_buf)(struct file *, unsigned int, void *);
+	long	(*proc_ioctl)(struct file *, unsigned int, void *);
 	const struct proc_ioctl_arg *proc_ioctl_args;
 	unsigned int proc_nr_ioctl_args;
 } __randomize_layout;
diff --git a/kernel/configs.c b/kernel/configs.c
index 05b12c440168..6ce19fa7ad44 100644
--- a/kernel/configs.c
+++ b/kernel/configs.c
@@ -49,7 +49,7 @@ ikconfig_read_current(struct file *file, char *buf,
 
 static const struct proc_ops config_gz_proc_ops = {
 	.proc_flags	= PROC_ENTRY_FULL_READS,
-	.proc_read_buf	= ikconfig_read_current,
+	.proc_read	= ikconfig_read_current,
 	.proc_lseek	= default_llseek,
 };
 
diff --git a/kernel/irq/proc.c b/kernel/irq/proc.c
index fe683457a088..4caf10e05e03 100644
--- a/kernel/irq/proc.c
+++ b/kernel/irq/proc.c
@@ -194,13 +194,13 @@ static ssize_t irq_affinity_list_proc_write(struct file *file,
 
 static const struct proc_ops irq_affinity_proc_ops = {
 	.proc_show	= irq_affinity_proc_show,
-	.proc_write_buf	= irq_affinity_proc_write,
+	.proc_write	= irq_affinity_proc_write,
 	.proc_write_size = IRQ_AFFINITY_WRITE_SIZE,
 };
 
 static const struct proc_ops irq_affinity_list_proc_ops = {
 	.proc_show	= irq_affinity_list_proc_show,
-	.proc_write_buf	= irq_affinity_list_proc_write,
+	.proc_write	= irq_affinity_list_proc_write,
 	.proc_write_size = IRQ_AFFINITY_WRITE_SIZE,
 };
 
@@ -255,7 +255,7 @@ out:
 
 static const struct proc_ops default_affinity_proc_ops = {
 	.proc_show	= default_affinity_show,
-	.proc_write_buf	= default_affinity_write,
+	.proc_write	= default_affinity_write,
 	.proc_write_size = IRQ_AFFINITY_WRITE_SIZE,
 };
 
diff --git a/kernel/latencytop.c b/kernel/latencytop.c
index 35f73ca07656..e90b1801f9b4 100644
--- a/kernel/latencytop.c
+++ b/kernel/latencytop.c
@@ -276,7 +276,7 @@ lstats_write(struct file *file, char *buf, size_t count, loff_t *offs)
 
 static const struct proc_ops lstats_proc_ops = {
 	.proc_show	= lstats_show,
-	.proc_write_buf	= lstats_write,
+	.proc_write	= lstats_write,
 };
 
 static int __init init_lstats_procfs(void)
diff --git a/kernel/locking/lockdep_proc.c b/kernel/locking/lockdep_proc.c
index 2a66ea09c2aa..0a95786bba88 100644
--- a/kernel/locking/lockdep_proc.c
+++ b/kernel/locking/lockdep_proc.c
@@ -699,7 +699,7 @@ static int lock_stat_release(struct inode *inode, struct file *file)
 static const struct proc_ops lock_stat_proc_ops = {
 	.proc_seq_ops	= &lockstat_ops,
 	.proc_open	= lock_stat_open,
-	.proc_write_buf	= lock_stat_write,
+	.proc_write	= lock_stat_write,
 	.proc_release	= lock_stat_release,
 };
 #endif /* CONFIG_LOCK_STAT */
diff --git a/kernel/profile.c b/kernel/profile.c
index 72e30bb30396..ff1377f39e9c 100644
--- a/kernel/profile.c
+++ b/kernel/profile.c
@@ -208,7 +208,7 @@ static ssize_t write_profile(struct file *file, char *buf, size_t count,
 static const struct proc_ops profile_proc_ops = {
 	.proc_flags	= PROC_ENTRY_PERMANENT,
 	.proc_permanent_read = read_profile,
-	.proc_write_buf	= write_profile,
+	.proc_write	= write_profile,
 	.proc_lseek	= default_llseek,
 };
 
diff --git a/kernel/sched/psi.c b/kernel/sched/psi.c
index 9811c3b705eb..68a57058b98a 100644
--- a/kernel/sched/psi.c
+++ b/kernel/sched/psi.c
@@ -1624,7 +1624,7 @@ static int psi_fop_release(struct inode *inode, struct file *file)
 static const struct proc_ops psi_io_proc_ops = {
 	.proc_flags	= PROC_ENTRY_PERMANENT,
 	.proc_show	= psi_io_show,
-	.proc_write_buf	= psi_io_write,
+	.proc_write	= psi_io_write,
 	.proc_poll	= psi_fop_poll,
 	.proc_release	= psi_fop_release,
 };
@@ -1632,7 +1632,7 @@ static const struct proc_ops psi_io_proc_ops = {
 static const struct proc_ops psi_memory_proc_ops = {
 	.proc_flags	= PROC_ENTRY_PERMANENT,
 	.proc_show	= psi_memory_show,
-	.proc_write_buf	= psi_memory_write,
+	.proc_write	= psi_memory_write,
 	.proc_poll	= psi_fop_poll,
 	.proc_release	= psi_fop_release,
 };
@@ -1640,7 +1640,7 @@ static const struct proc_ops psi_memory_proc_ops = {
 static const struct proc_ops psi_cpu_proc_ops = {
 	.proc_flags	= PROC_ENTRY_PERMANENT,
 	.proc_show	= psi_cpu_show,
-	.proc_write_buf	= psi_cpu_write,
+	.proc_write	= psi_cpu_write,
 	.proc_poll	= psi_fop_poll,
 	.proc_release	= psi_fop_release,
 };
@@ -1660,7 +1660,7 @@ static ssize_t psi_irq_write(struct file *file, char *buf, size_t nbytes,
 static const struct proc_ops psi_irq_proc_ops = {
 	.proc_flags	= PROC_ENTRY_PERMANENT,
 	.proc_show	= psi_irq_show,
-	.proc_write_buf	= psi_irq_write,
+	.proc_write	= psi_irq_write,
 	.proc_poll	= psi_fop_poll,
 	.proc_release	= psi_fop_release,
 };
diff --git a/lib/dynamic_debug.c b/lib/dynamic_debug.c
index 1d6012c9eb41..1f5076b05242 100644
--- a/lib/dynamic_debug.c
+++ b/lib/dynamic_debug.c
@@ -1205,7 +1205,7 @@ static const struct file_operations ddebug_proc_fops = {
 static const struct proc_ops proc_fops = {
 	.proc_seq_ops = &ddebug_proc_seqops,
 	.proc_state_size = sizeof(struct ddebug_iter),
-	.proc_write_buf = ddebug_proc_write_buf,
+	.proc_write = ddebug_proc_write_buf,
 	.proc_write_size = USER_BUF_PAGE - 1,
 };
 
diff --git a/mm/alloc_tag.c b/mm/alloc_tag.c
index 1734705e2990..45be07af102f 100644
--- a/mm/alloc_tag.c
+++ b/mm/alloc_tag.c
@@ -460,7 +460,7 @@ static const struct proc_ops allocinfo_proc_ops = {
 	.proc_state_size	= sizeof(struct allocinfo_private),
 	.proc_open		= allocinfo_open,
 	.proc_release		= allocinfo_release,
-	.proc_ioctl_buf		= allocinfo_ioctl,
+	.proc_ioctl		= allocinfo_ioctl,
 	.proc_ioctl_args	= allocinfo_ioctl_args,
 	.proc_nr_ioctl_args	= ARRAY_SIZE(allocinfo_ioctl_args),
 };
diff --git a/net/atm/proc.c b/net/atm/proc.c
index cea930b4b840..032adae4bf75 100644
--- a/net/atm/proc.c
+++ b/net/atm/proc.c
@@ -34,7 +34,7 @@ static ssize_t proc_dev_atm_read(struct file *file, char *buf,
 				 size_t count, loff_t *pos);
 
 static const struct proc_ops atm_dev_proc_ops = {
-	.proc_read_buf	= proc_dev_atm_read,
+	.proc_read	= proc_dev_atm_read,
 	.proc_lseek	= noop_llseek,
 };
 
diff --git a/net/core/pktgen.c b/net/core/pktgen.c
index 84f4db86a5b0..ac17a15102e3 100644
--- a/net/core/pktgen.c
+++ b/net/core/pktgen.c
@@ -545,7 +545,7 @@ static ssize_t pgctrl_write(struct file *file, char *buf, size_t count,
 
 static const struct proc_ops pktgen_proc_ops = {
 	.proc_show	= pgctrl_show,
-	.proc_write_buf	= pgctrl_write,
+	.proc_write	= pgctrl_write,
 };
 
 static int pktgen_if_show(struct seq_file *seq, void *v)
@@ -1829,7 +1829,7 @@ static ssize_t pktgen_if_write(struct file *file, char *user_buffer,
 
 static const struct proc_ops pktgen_if_proc_ops = {
 	.proc_show	= pktgen_if_show,
-	.proc_write_buf	= pktgen_if_write,
+	.proc_write	= pktgen_if_write,
 };
 
 static int pktgen_thread_show(struct seq_file *seq, void *v)
@@ -1958,7 +1958,7 @@ out:
 
 static const struct proc_ops pktgen_thread_proc_ops = {
 	.proc_show	= pktgen_thread_show,
-	.proc_write_buf	= pktgen_thread_write,
+	.proc_write	= pktgen_thread_write,
 };
 
 /* Think find or remove for NN */
diff --git a/net/netfilter/xt_recent.c b/net/netfilter/xt_recent.c
index 306557f25daf..fa25500dc897 100644
--- a/net/netfilter/xt_recent.c
+++ b/net/netfilter/xt_recent.c
@@ -623,7 +623,7 @@ static const struct proc_ops recent_mt_proc_ops = {
 	.proc_seq_ops	= &recent_seq_ops,
 	.proc_state_size = sizeof(struct recent_iter_state),
 	.proc_open	= recent_seq_open,
-	.proc_write_buf	= recent_mt_proc_write,
+	.proc_write	= recent_mt_proc_write,
 };
 
 static int __net_init recent_proc_net_init(struct net *net)
diff --git a/net/sunrpc/auth_gss/svcauth_gss.c b/net/sunrpc/auth_gss/svcauth_gss.c
index 67e086a7127c..e21c4d326384 100644
--- a/net/sunrpc/auth_gss/svcauth_gss.c
+++ b/net/sunrpc/auth_gss/svcauth_gss.c
@@ -1456,8 +1456,8 @@ static ssize_t read_gssp(struct file *file, char *buf,
 
 static const struct proc_ops use_gss_proxy_proc_ops = {
 	.proc_open	= nonseekable_open,
-	.proc_write_buf	= write_gssp,
-	.proc_read_buf	= read_gssp,
+	.proc_write	= write_gssp,
+	.proc_read	= read_gssp,
 };
 
 static int create_use_gss_proxy_proc_entry(struct net *net)
@@ -1511,7 +1511,7 @@ static ssize_t read_gss_krb5_enctypes(struct file *file, char *buf,
 
 static const struct proc_ops gss_krb5_enctypes_proc_ops = {
 	.proc_open	= nonseekable_open,
-	.proc_read_buf	= read_gss_krb5_enctypes,
+	.proc_read	= read_gss_krb5_enctypes,
 };
 
 static int create_krb5_enctypes_proc_entry(struct net *net)
diff --git a/net/sunrpc/cache.c b/net/sunrpc/cache.c
index d242b6f33cbc..6229a3fec413 100644
--- a/net/sunrpc/cache.c
+++ b/net/sunrpc/cache.c
@@ -1611,8 +1611,8 @@ static int cache_release_procfs(struct inode *inode, struct file *filp)
 }
 
 static const struct proc_ops cache_channel_proc_ops = {
-	.proc_read_buf	= cache_read_procfs,
-	.proc_write_buf	= cache_write_procfs,
+	.proc_read	= cache_read_procfs,
+	.proc_write	= cache_write_procfs,
 	.proc_write_size = CACHE_DOWNCALL_MAX,
 	.proc_poll	= cache_poll_procfs,
 	.proc_open	= cache_open_procfs,
@@ -1681,8 +1681,8 @@ static ssize_t write_flush_procfs(struct file *filp, char *buf, size_t count,
 
 static const struct proc_ops cache_flush_proc_ops = {
 	.proc_open	= open_flush_procfs,
-	.proc_read_buf	= read_flush_procfs,
-	.proc_write_buf	= write_flush_procfs,
+	.proc_read	= read_flush_procfs,
+	.proc_write	= write_flush_procfs,
 	.proc_write_size = CACHE_FLUSH_MAX,
 	.proc_release	= release_flush_procfs,
 };
diff --git a/samples/kfifo/bytestream-example.c b/samples/kfifo/bytestream-example.c
index 214e46a64cc1..efb7ee0a3c56 100644
--- a/samples/kfifo/bytestream-example.c
+++ b/samples/kfifo/bytestream-example.c
@@ -141,8 +141,8 @@ static ssize_t fifo_read(struct file *file, char *buf,
 }
 
 static const struct proc_ops fifo_proc_ops = {
-	.proc_read_buf	= fifo_read,
-	.proc_write_buf	= fifo_write,
+	.proc_read	= fifo_read,
+	.proc_write	= fifo_write,
 	.proc_lseek	= noop_llseek,
 };
 
diff --git a/samples/kfifo/inttype-example.c b/samples/kfifo/inttype-example.c
index 8384d7f8de6c..ce9111f59986 100644
--- a/samples/kfifo/inttype-example.c
+++ b/samples/kfifo/inttype-example.c
@@ -136,8 +136,8 @@ static ssize_t fifo_read(struct file *file, char *buf,
 }
 
 static const struct proc_ops fifo_proc_ops = {
-	.proc_read_buf	= fifo_read,
-	.proc_write_buf	= fifo_write,
+	.proc_read	= fifo_read,
+	.proc_write	= fifo_write,
 	.proc_lseek	= noop_llseek,
 };
 
diff --git a/samples/kfifo/record-example.c b/samples/kfifo/record-example.c
index 29d08e90a63d..399dc07d9438 100644
--- a/samples/kfifo/record-example.c
+++ b/samples/kfifo/record-example.c
@@ -148,8 +148,8 @@ static ssize_t fifo_read(struct file *file, char *buf,
 }
 
 static const struct proc_ops fifo_proc_ops = {
-	.proc_read_buf	= fifo_read,
-	.proc_write_buf	= fifo_write,
+	.proc_read	= fifo_read,
+	.proc_write	= fifo_write,
 	.proc_lseek	= noop_llseek,
 	/* kfifo_from_user() cut a record to what its length byte holds */
 	.proc_flags	= PROC_ENTRY_SHORT_WRITES,
diff --git a/sound/core/info.c b/sound/core/info.c
index 639554bb17c8..089d169a9d39 100644
--- a/sound/core/info.c
+++ b/sound/core/info.c
@@ -267,8 +267,8 @@ static const struct proc_ops snd_info_entry_operations =
 {
 	.proc_flags	= PROC_ENTRY_SHORT_WRITES | PROC_ENTRY_FULL_READS,
 	.proc_lseek	= snd_info_entry_llseek,
-	.proc_read_buf	= snd_info_entry_read,
-	.proc_write_buf	= snd_info_entry_write,
+	.proc_read	= snd_info_entry_read,
+	.proc_write	= snd_info_entry_write,
 	.proc_write_size = PAGE_SIZE,
 	.proc_poll	= snd_info_entry_poll,
 	.proc_mmap	= snd_info_entry_mmap,
@@ -393,7 +393,7 @@ static const struct proc_ops snd_info_text_entry_ops =
 	.proc_show	= snd_info_seq_show,
 	.proc_open	= snd_info_text_entry_open,
 	.proc_release	= snd_info_text_entry_release,
-	.proc_write_buf	= snd_info_text_entry_write,
+	.proc_write	= snd_info_text_entry_write,
 	.proc_write_size = SND_INFO_TEXT_WRITE_MAX,
 };
 

-- 
2.53.0

