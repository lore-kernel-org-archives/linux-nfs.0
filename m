Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.remote-ip=100.103.45.18
ARC-Seal: i=1; d=subspace.kernel.org; s=arc20261015; a=rsa-sha256; cv=none;
	t=1793820717;
	b=o1DywA4xhKKBZr1iZ3iuiP9W/ZSZWjyKZEKvqStePjmXHpu/eUSIel6crsuA8dUN8RVw
	 2lqt+l17mlVyYtZTZEhtZ0evXjMvfGYHy2zG5eTeEdktpOXlftCMBJHftYUEF7sBTeYX9
	 DiAriZYMCNcdKQumf5+KhGMCjFwB37O2W+NYvBi+tK8wVPsSQjOwJoiOq2wcDmBUR7ygR
	 vzEntAPg5OsJ5obtqNlQEc0FMmSJWS7ZBTlyjcsfah1xBvRRvrwPskwZzvciTKlTcUCKF
	 Dw7QXDIDEKanYzrjE8AlvToIkSTcnBdRsWQ48LElzZh81yOdpM3ggtlJfQ2caN7ZWvw==
ARC-Message-Signature: i=1; d=subspace.kernel.org; s=arc20261015;
	a=rsa-sha256; c=relaxed/relaxed; t=1793820717;
	h=Received:DKIM-Signature:From:To:Cc:Subject:Date:Message-ID:
	 In-Reply-To:References:MIME-Version:Content-Type:X-Mailer:
	 X-Developer-Signature:X-Developer-Key:Content-Transfer-Encoding;
	bh=rI+hH++7apIZJeSxVTlpoyUp+labJ/8VmRLdHKzA4sw=;
	b=N/wzXgnuUfgTy9o3xI3ZUqkoCjdgoI1XfO/mBIAGFQIgLo0mWqvHdIBvKo0JmGjBALhQ
	 wbtRqkl1Lu4WopAwORhQl0K+AHdguRCrTv3pmM7O53MqZEo0d20GGn6VXJbsiJu+7LA/b
	 EVcfzhDNE1qj9skqNkll4sksdFWF06Q6lSSPXWAdSSuJdIlPoAvPjNk7la8LzG/E47b8C
	 L9tHGD0vALjh2VHT2WCpUcFAA+GVhpSaj4iZ0BsH1ePU5+SQDKiYblOLy9pTeiwbeLRCd
	 R65+mZl7Ke9ftkhLYPCcb+crBJQ8ILs/DKngUH4/lFvGElqOYZORtmfMwwgwH50Erug==
ARC-Authentication-Results: i=1; smtp.subspace.kernel.org; 
	dkim=pass header.d=kernel.org header.i=@kernel.org header.a=rsa-sha256 header.s=k20260515 header.b=g1xNmdea;
	arc=none smtp.remote-ip=100.103.45.18
Received: from smtp.kernel.org (quasi.space.kernel.org [100.103.45.18])
	(using TLSv1.3 with cipher TLS_AES_256_GCM_SHA384 (256/256 bits)
	 key-exchange X25519 server-signature ECDSA (prime256v1))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 30481606C91A;
	Wed,  4 Nov 2026 19:31:55 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key, unprotected) header.d=kernel.org header.i=@kernel.org header.a=rsa-sha256 header.s=k20260515 header.b=g1xNmdea
Received: by smtp.kernel.org (Postfix) with ESMTPSA id D673E1F000C1;
	Wed,  4 Nov 2026 19:31:43 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=kernel.org;
	s=k20260515; t=1793820715;
	bh=rI+hH++7apIZJeSxVTlpoyUp+labJ/8VmRLdHKzA4sw=;
	h=From:To:Cc:Subject:Date:In-Reply-To:References;
	b=g1xNmdeaGBsehlT0mGTeqhhpXf6kwTJQHANgRbkNg/zk1y5cUuy7ROkM+aBoEL2+p
	 E3OSCqkGrshvC6YawX3FVV6DYLaUwcZAOpRTmFdhr4pOsURSFJDWidSlBP0InXKcY8
	 7R18AGGPfEwPphDdg0MrA596kgwtVpNR5rLi+vxLKRqNEyqwjY+2QmvIFFM1dEFwzy
	 e4t7A5gplcaXEHqO6xVcvOu7gr+Fphwn71tTENTsIIh3ONoOBerRMwywp2X7fBPHIJ
	 Wqht5jkhndNZkRpAPtkGZtR2ebixl0SIxL/XGgfkcpuhdtl8TxTkdvT3oPzICGQBvc
	 y2EcS9Hpo4okA==
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
Subject: [PATCH RESEND v2 10/23] treewide: let procfs own the seq_file of simple proc entries
Date: Wed,  4 Nov 2026 20:31:41 +0100
Message-ID: <20261104-work-procfs-core-v2-10-76ace653a773@kernel.org>
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
X-Developer-Signature: v=1; a=openpgp-sha256; l=49291; i=brauner@kernel.org; h=from:subject:message-id; bh=Pm43qXf0IUp/Z6utnpiVRGVlJzCFIUSlYCQeEiCMJHQ=; b=owGbwMvMwCU28Zj0gdSKO4sYT6slMWS9bq91eM4duXq1pvXX/ZYsF51cP8wvuiBkMVdrnWtc8 gU5X4nnHaUsDGJcDLJiiiwO7Sbhcst5KjYbZWrAzGFlAhnCwMUpABOZo8DIcIPHsldXLvPJrlc8 E6dOCOBSe+C0zcD3DNeU01Of2/hniDMyLK1/7HZ4fXbNhS8HDveIB3J9nDN/d5Qyz6IIld69caw fWQE=
X-Developer-Key: i=brauner@kernel.org; a=openpgp; fpr=4880B8C9BD0E5106FC070F4F7B3C391EFEA93624
Content-Transfer-Encoding: 8bit

Most proc entries that bring their own struct proc_ops only call
single_open(), seq_open() or seq_open_private() in ->proc_open() and
free the seq_file with the matching helper. Declare the show function
or the seq_operations instead and let procfs open and free the
seq_file. Reading these files then no longer holds up their removal.

Done with the following semantic patch. The new initializers were
aligned like their neighbours afterwards:

  // SPDX-License-Identifier: GPL-2.0-only
  /// Let procfs open the seq_file of proc entries whose ->proc_open() only
  /// calls single_open(), seq_open() or seq_open_private().
  //
  // Confidence: High
  // Options: --no-includes --include-headers

  virtual patch

  @single depends on patch@
  identifier open_fn, show_fn, i, f;
  @@
  static int open_fn(struct inode *i, struct file *f)
  {
  	return single_open(f, show_fn, \(NULL\|pde_data(i)\));
  }

  @single_ops depends on single@
  identifier single.open_fn, single.show_fn, ops;
  symbol single_release;
  @@
  const struct proc_ops ops = {
  -	.proc_open = open_fn,
  +	.proc_show = show_fn,
  	...,
  -	.proc_release = single_release,
  	...
  };

  @seq depends on patch@
  identifier open_fn, sops, i, f;
  @@
  static int open_fn(struct inode *i, struct file *f)
  {
  	return seq_open(f, &sops);
  }

  @seq_ops depends on seq@
  identifier seq.open_fn, seq.sops, ops;
  symbol seq_release;
  @@
  const struct proc_ops ops = {
  -	.proc_open = open_fn,
  +	.proc_seq_ops = &sops,
  	...,
  -	.proc_release = seq_release,
  	...
  };

  @priv depends on patch@
  identifier open_fn, sops, i, f;
  expression size;
  @@
  static int open_fn(struct inode *i, struct file *f)
  {
  	return seq_open_private(f, &sops, size);
  }

  @priv_ops depends on priv@
  identifier priv.open_fn, priv.sops, ops;
  expression priv.size;
  symbol seq_release_private;
  @@
  const struct proc_ops ops = {
  -	.proc_open = open_fn,
  +	.proc_seq_ops = &sops,
  +	.proc_state_size = size,
  	...,
  -	.proc_release = seq_release_private,
  	...
  };

  // procfs reads and seeks through the seq_file itself
  @depends on single_ops || seq_ops || priv_ops@
  identifier ops = {single_ops.ops, seq_ops.ops, priv_ops.ops};
  symbol seq_read_iter;
  @@
  const struct proc_ops ops = {
  	...,
  -	.proc_read_iter = seq_read_iter,
  	...
  };

  @depends on single_ops || seq_ops || priv_ops@
  identifier ops = {single_ops.ops, seq_ops.ops, priv_ops.ops};
  symbol seq_read;
  @@
  const struct proc_ops ops = {
  	...,
  -	.proc_read = seq_read,
  	...
  };

  @depends on single_ops || seq_ops || priv_ops@
  identifier ops = {single_ops.ops, seq_ops.ops, priv_ops.ops};
  symbol seq_lseek;
  @@
  const struct proc_ops ops = {
  	...,
  -	.proc_lseek = seq_lseek,
  	...
  };

  // drop the open function unless something else still uses it
  @open_used@
  identifier open_fn = {single.open_fn, seq.open_fn, priv.open_fn};
  @@
  open_fn

  @depends on !open_used && (single_ops || seq_ops || priv_ops)@
  identifier open_fn = {single.open_fn, seq.open_fn, priv.open_fn};
  @@
  - static int open_fn(...) { ... }

Signed-off-by: Christian Brauner (Amutable) <brauner@kernel.org>
---
 arch/alpha/kernel/srm_env.c                        | 10 +--
 arch/arm/mm/alignment.c                            | 10 +--
 arch/powerpc/kernel/rtas-proc.c                    | 50 ++------------
 arch/powerpc/platforms/pseries/lpar.c              | 20 +-----
 arch/powerpc/platforms/pseries/lparcfg.c           | 10 +--
 arch/sh/mm/alignment.c                             | 10 +--
 arch/sparc/kernel/led.c                            | 10 +--
 arch/um/kernel/exitcode.c                          | 10 +--
 drivers/acpi/proc.c                                | 12 +---
 drivers/hwmon/dell-smm-hwmon.c                     | 10 +--
 drivers/input/input.c                              | 24 ++-----
 drivers/macintosh/via-pmu.c                        | 10 +--
 drivers/net/wireless/intel/ipw2x00/libipw_module.c | 10 +--
 drivers/platform/x86/lenovo/thinkpad_acpi.c        | 10 +--
 drivers/platform/x86/toshiba_acpi.c                | 40 ++---------
 drivers/pnp/pnpbios/proc.c                         | 10 +--
 drivers/s390/block/dasd_proc.c                     | 10 +--
 drivers/s390/cio/blacklist.c                       | 13 +---
 drivers/scsi/scsi_devinfo.c                        | 10 +--
 drivers/scsi/scsi_proc.c                           | 21 +-----
 drivers/usb/gadget/function/rndis.c                | 10 +--
 drivers/video/fbdev/via/viafbdev.c                 | 70 ++-----------------
 fs/jfs/jfs_debug.c                                 | 10 +--
 fs/ntfs3/super.c                                   | 20 +-----
 fs/proc/cpuinfo.c                                  | 10 +--
 fs/smb/client/cifs_debug.c                         | 79 +++-------------------
 fs/smb/client/dfs_cache.c                          | 10 +--
 kernel/irq/proc.c                                  | 30 +-------
 kernel/latencytop.c                                | 10 +--
 lib/dynamic_debug.c                                |  6 +-
 mm/slab_common.c                                   | 10 +--
 net/core/pktgen.c                                  | 30 +-------
 net/sunrpc/stats.c                                 | 10 +--
 33 files changed, 64 insertions(+), 551 deletions(-)

diff --git a/arch/alpha/kernel/srm_env.c b/arch/alpha/kernel/srm_env.c
index 217b4dca51dd..faafc2df7886 100644
--- a/arch/alpha/kernel/srm_env.c
+++ b/arch/alpha/kernel/srm_env.c
@@ -81,11 +81,6 @@ static int srm_env_proc_show(struct seq_file *m, void *v)
 	return ret;
 }
 
-static int srm_env_proc_open(struct inode *inode, struct file *file)
-{
-	return single_open(file, srm_env_proc_show, pde_data(inode));
-}
-
 static ssize_t srm_env_proc_write(struct file *file, const char __user *buffer,
 				  size_t count, loff_t *pos)
 {
@@ -120,10 +115,7 @@ static ssize_t srm_env_proc_write(struct file *file, const char __user *buffer,
 }
 
 static const struct proc_ops srm_env_proc_ops = {
-	.proc_open	= srm_env_proc_open,
-	.proc_read	= seq_read,
-	.proc_lseek	= seq_lseek,
-	.proc_release	= single_release,
+	.proc_show	= srm_env_proc_show,
 	.proc_write	= srm_env_proc_write,
 };
 
diff --git a/arch/arm/mm/alignment.c b/arch/arm/mm/alignment.c
index f6c1e6b61179..3e5e30968634 100644
--- a/arch/arm/mm/alignment.c
+++ b/arch/arm/mm/alignment.c
@@ -144,11 +144,6 @@ static int alignment_proc_show(struct seq_file *m, void *v)
 	return 0;
 }
 
-static int alignment_proc_open(struct inode *inode, struct file *file)
-{
-	return single_open(file, alignment_proc_show, NULL);
-}
-
 static ssize_t alignment_proc_write(struct file *file, const char __user *buffer,
 				    size_t count, loff_t *pos)
 {
@@ -164,10 +159,7 @@ static ssize_t alignment_proc_write(struct file *file, const char __user *buffer
 }
 
 static const struct proc_ops alignment_proc_ops = {
-	.proc_open	= alignment_proc_open,
-	.proc_read	= seq_read,
-	.proc_lseek	= seq_lseek,
-	.proc_release	= single_release,
+	.proc_show	= alignment_proc_show,
 	.proc_write	= alignment_proc_write,
 };
 #endif /* CONFIG_PROC_FS */
diff --git a/arch/powerpc/kernel/rtas-proc.c b/arch/powerpc/kernel/rtas-proc.c
index 89b165986851..808023f9d1f6 100644
--- a/arch/powerpc/kernel/rtas-proc.c
+++ b/arch/powerpc/kernel/rtas-proc.c
@@ -154,69 +154,29 @@ static ssize_t ppc_rtas_tone_volume_write(struct file *file,
 static int ppc_rtas_tone_volume_show(struct seq_file *m, void *v);
 static int ppc_rtas_rmo_buf_show(struct seq_file *m, void *v);
 
-static int poweron_open(struct inode *inode, struct file *file)
-{
-	return single_open(file, ppc_rtas_poweron_show, NULL);
-}
-
 static const struct proc_ops ppc_rtas_poweron_proc_ops = {
-	.proc_open	= poweron_open,
-	.proc_read	= seq_read,
-	.proc_lseek	= seq_lseek,
+	.proc_show	= ppc_rtas_poweron_show,
 	.proc_write	= ppc_rtas_poweron_write,
-	.proc_release	= single_release,
 };
 
-static int progress_open(struct inode *inode, struct file *file)
-{
-	return single_open(file, ppc_rtas_progress_show, NULL);
-}
-
 static const struct proc_ops ppc_rtas_progress_proc_ops = {
-	.proc_open	= progress_open,
-	.proc_read	= seq_read,
-	.proc_lseek	= seq_lseek,
+	.proc_show	= ppc_rtas_progress_show,
 	.proc_write	= ppc_rtas_progress_write,
-	.proc_release	= single_release,
 };
 
-static int clock_open(struct inode *inode, struct file *file)
-{
-	return single_open(file, ppc_rtas_clock_show, NULL);
-}
-
 static const struct proc_ops ppc_rtas_clock_proc_ops = {
-	.proc_open	= clock_open,
-	.proc_read	= seq_read,
-	.proc_lseek	= seq_lseek,
+	.proc_show	= ppc_rtas_clock_show,
 	.proc_write	= ppc_rtas_clock_write,
-	.proc_release	= single_release,
 };
 
-static int tone_freq_open(struct inode *inode, struct file *file)
-{
-	return single_open(file, ppc_rtas_tone_freq_show, NULL);
-}
-
 static const struct proc_ops ppc_rtas_tone_freq_proc_ops = {
-	.proc_open	= tone_freq_open,
-	.proc_read	= seq_read,
-	.proc_lseek	= seq_lseek,
+	.proc_show	= ppc_rtas_tone_freq_show,
 	.proc_write	= ppc_rtas_tone_freq_write,
-	.proc_release	= single_release,
 };
 
-static int tone_volume_open(struct inode *inode, struct file *file)
-{
-	return single_open(file, ppc_rtas_tone_volume_show, NULL);
-}
-
 static const struct proc_ops ppc_rtas_tone_volume_proc_ops = {
-	.proc_open	= tone_volume_open,
-	.proc_read	= seq_read,
-	.proc_lseek	= seq_lseek,
+	.proc_show	= ppc_rtas_tone_volume_show,
 	.proc_write	= ppc_rtas_tone_volume_write,
-	.proc_release	= single_release,
 };
 
 static int ppc_rtas_find_all_sensors(void);
diff --git a/arch/powerpc/platforms/pseries/lpar.c b/arch/powerpc/platforms/pseries/lpar.c
index 6a415febc53b..48fe0be71a89 100644
--- a/arch/powerpc/platforms/pseries/lpar.c
+++ b/arch/powerpc/platforms/pseries/lpar.c
@@ -584,17 +584,9 @@ static int vcpudispatch_stats_display(struct seq_file *p, void *v)
 	return 0;
 }
 
-static int vcpudispatch_stats_open(struct inode *inode, struct file *file)
-{
-	return single_open(file, vcpudispatch_stats_display, NULL);
-}
-
 static const struct proc_ops vcpudispatch_stats_proc_ops = {
-	.proc_open	= vcpudispatch_stats_open,
-	.proc_read	= seq_read,
+	.proc_show	= vcpudispatch_stats_display,
 	.proc_write	= vcpudispatch_stats_write,
-	.proc_lseek	= seq_lseek,
-	.proc_release	= single_release,
 };
 
 static ssize_t vcpudispatch_stats_freq_write(struct file *file,
@@ -628,17 +620,9 @@ static int vcpudispatch_stats_freq_display(struct seq_file *p, void *v)
 	return 0;
 }
 
-static int vcpudispatch_stats_freq_open(struct inode *inode, struct file *file)
-{
-	return single_open(file, vcpudispatch_stats_freq_display, NULL);
-}
-
 static const struct proc_ops vcpudispatch_stats_freq_proc_ops = {
-	.proc_open	= vcpudispatch_stats_freq_open,
-	.proc_read	= seq_read,
+	.proc_show	= vcpudispatch_stats_freq_display,
 	.proc_write	= vcpudispatch_stats_freq_write,
-	.proc_lseek	= seq_lseek,
-	.proc_release	= single_release,
 };
 
 static int __init vcpudispatch_stats_procfs_init(void)
diff --git a/arch/powerpc/platforms/pseries/lparcfg.c b/arch/powerpc/platforms/pseries/lparcfg.c
index 4f6b2975c6e9..cb3d96efb225 100644
--- a/arch/powerpc/platforms/pseries/lparcfg.c
+++ b/arch/powerpc/platforms/pseries/lparcfg.c
@@ -797,17 +797,9 @@ static int lparcfg_data(struct seq_file *m, void *v)
 	return pseries_lparcfg_data(m, v);
 }
 
-static int lparcfg_open(struct inode *inode, struct file *file)
-{
-	return single_open(file, lparcfg_data, NULL);
-}
-
 static const struct proc_ops lparcfg_proc_ops = {
-	.proc_read	= seq_read,
 	.proc_write	= lparcfg_write,
-	.proc_open	= lparcfg_open,
-	.proc_release	= single_release,
-	.proc_lseek	= seq_lseek,
+	.proc_show	= lparcfg_data,
 };
 
 static int __init lparcfg_init(void)
diff --git a/arch/sh/mm/alignment.c b/arch/sh/mm/alignment.c
index 3a76a766f423..2198c6f2ea63 100644
--- a/arch/sh/mm/alignment.c
+++ b/arch/sh/mm/alignment.c
@@ -132,11 +132,6 @@ static int alignment_proc_show(struct seq_file *m, void *v)
 	return 0;
 }
 
-static int alignment_proc_open(struct inode *inode, struct file *file)
-{
-	return single_open(file, alignment_proc_show, NULL);
-}
-
 static ssize_t alignment_proc_write(struct file *file,
 		const char __user *buffer, size_t count, loff_t *pos)
 {
@@ -153,10 +148,7 @@ static ssize_t alignment_proc_write(struct file *file,
 }
 
 static const struct proc_ops alignment_proc_ops = {
-	.proc_open	= alignment_proc_open,
-	.proc_read	= seq_read,
-	.proc_lseek	= seq_lseek,
-	.proc_release	= single_release,
+	.proc_show	= alignment_proc_show,
 	.proc_write	= alignment_proc_write,
 };
 
diff --git a/arch/sparc/kernel/led.c b/arch/sparc/kernel/led.c
index a1478de9fe5d..0f7376b51a04 100644
--- a/arch/sparc/kernel/led.c
+++ b/arch/sparc/kernel/led.c
@@ -60,11 +60,6 @@ static int led_proc_show(struct seq_file *m, void *v)
 	return 0;
 }
 
-static int led_proc_open(struct inode *inode, struct file *file)
-{
-	return single_open(file, led_proc_show, NULL);
-}
-
 static ssize_t led_proc_write(struct file *file, const char __user *buffer,
 			      size_t count, loff_t *ppos)
 {
@@ -107,10 +102,7 @@ static ssize_t led_proc_write(struct file *file, const char __user *buffer,
 }
 
 static const struct proc_ops led_proc_ops = {
-	.proc_open	= led_proc_open,
-	.proc_read	= seq_read,
-	.proc_lseek	= seq_lseek,
-	.proc_release	= single_release,
+	.proc_show	= led_proc_show,
 	.proc_write	= led_proc_write,
 };
 #endif
diff --git a/arch/um/kernel/exitcode.c b/arch/um/kernel/exitcode.c
index 0230354f4812..c71657df38f5 100644
--- a/arch/um/kernel/exitcode.c
+++ b/arch/um/kernel/exitcode.c
@@ -31,11 +31,6 @@ static int exitcode_proc_show(struct seq_file *m, void *v)
 	return 0;
 }
 
-static int exitcode_proc_open(struct inode *inode, struct file *file)
-{
-	return single_open(file, exitcode_proc_show, NULL);
-}
-
 static ssize_t exitcode_proc_write(struct file *file,
 		const char __user *buffer, size_t count, loff_t *pos)
 {
@@ -57,10 +52,7 @@ static ssize_t exitcode_proc_write(struct file *file,
 }
 
 static const struct proc_ops exitcode_proc_ops = {
-	.proc_open	= exitcode_proc_open,
-	.proc_read	= seq_read,
-	.proc_lseek	= seq_lseek,
-	.proc_release	= single_release,
+	.proc_show	= exitcode_proc_show,
 	.proc_write	= exitcode_proc_write,
 };
 
diff --git a/drivers/acpi/proc.c b/drivers/acpi/proc.c
index c08ead07252b..b8a0bd4580e0 100644
--- a/drivers/acpi/proc.c
+++ b/drivers/acpi/proc.c
@@ -121,19 +121,9 @@ acpi_system_write_wakeup_device(struct file *file,
 	return count;
 }
 
-static int
-acpi_system_wakeup_device_open_fs(struct inode *inode, struct file *file)
-{
-	return single_open(file, acpi_system_wakeup_device_seq_show,
-			   pde_data(inode));
-}
-
 static const struct proc_ops acpi_system_wakeup_device_proc_ops = {
-	.proc_open	= acpi_system_wakeup_device_open_fs,
-	.proc_read	= seq_read,
+	.proc_show	= acpi_system_wakeup_device_seq_show,
 	.proc_write	= acpi_system_write_wakeup_device,
-	.proc_lseek	= seq_lseek,
-	.proc_release	= single_release,
 };
 
 void __init acpi_sleep_proc_init(void)
diff --git a/drivers/hwmon/dell-smm-hwmon.c b/drivers/hwmon/dell-smm-hwmon.c
index 88837f028405..492b2b6c6d7e 100644
--- a/drivers/hwmon/dell-smm-hwmon.c
+++ b/drivers/hwmon/dell-smm-hwmon.c
@@ -694,16 +694,8 @@ static int i8k_proc_show(struct seq_file *seq, void *offset)
 	return 0;
 }
 
-static int i8k_open_fs(struct inode *inode, struct file *file)
-{
-	return single_open(file, i8k_proc_show, pde_data(inode));
-}
-
 static const struct proc_ops i8k_proc_ops = {
-	.proc_open	= i8k_open_fs,
-	.proc_read	= seq_read,
-	.proc_lseek	= seq_lseek,
-	.proc_release	= single_release,
+	.proc_show	= i8k_proc_show,
 	.proc_ioctl	= i8k_ioctl,
 };
 
diff --git a/drivers/input/input.c b/drivers/input/input.c
index 0859b60ca924..d27eecbf4a03 100644
--- a/drivers/input/input.c
+++ b/drivers/input/input.c
@@ -1218,18 +1218,10 @@ static const struct seq_operations input_devices_seq_ops = {
 	.show	= input_devices_seq_show,
 };
 
-static int input_proc_devices_open(struct inode *inode, struct file *file)
-{
-	return seq_open_private(file, &input_devices_seq_ops,
-				sizeof(struct input_seq_state));
-}
-
 static const struct proc_ops input_devices_proc_ops = {
-	.proc_open	= input_proc_devices_open,
+	.proc_seq_ops	= &input_devices_seq_ops,
+	.proc_state_size = sizeof(struct input_seq_state),
 	.proc_poll	= input_proc_devices_poll,
-	.proc_read	= seq_read,
-	.proc_lseek	= seq_lseek,
-	.proc_release	= seq_release_private,
 };
 
 static void *input_handlers_seq_start(struct seq_file *seq, loff_t *pos)
@@ -1279,17 +1271,9 @@ static const struct seq_operations input_handlers_seq_ops = {
 	.show	= input_handlers_seq_show,
 };
 
-static int input_proc_handlers_open(struct inode *inode, struct file *file)
-{
-	return seq_open_private(file, &input_handlers_seq_ops,
-				sizeof(struct input_seq_state));
-}
-
 static const struct proc_ops input_handlers_proc_ops = {
-	.proc_open	= input_proc_handlers_open,
-	.proc_read	= seq_read,
-	.proc_lseek	= seq_lseek,
-	.proc_release	= seq_release_private,
+	.proc_seq_ops = &input_handlers_seq_ops,
+	.proc_state_size = sizeof(struct input_seq_state),
 };
 
 static int __init input_proc_init(void)
diff --git a/drivers/macintosh/via-pmu.c b/drivers/macintosh/via-pmu.c
index 8c652c15018c..49f929ae10e4 100644
--- a/drivers/macintosh/via-pmu.c
+++ b/drivers/macintosh/via-pmu.c
@@ -912,11 +912,6 @@ static int pmu_options_proc_show(struct seq_file *m, void *v)
 	return 0;
 }
 
-static int pmu_options_proc_open(struct inode *inode, struct file *file)
-{
-	return single_open(file, pmu_options_proc_show, NULL);
-}
-
 static ssize_t pmu_options_proc_write(struct file *file,
 		const char __user *buffer, size_t count, loff_t *pos)
 {
@@ -962,10 +957,7 @@ static ssize_t pmu_options_proc_write(struct file *file,
 }
 
 static const struct proc_ops pmu_options_proc_ops = {
-	.proc_open	= pmu_options_proc_open,
-	.proc_read	= seq_read,
-	.proc_lseek	= seq_lseek,
-	.proc_release	= single_release,
+	.proc_show	= pmu_options_proc_show,
 	.proc_write	= pmu_options_proc_write,
 };
 #endif
diff --git a/drivers/net/wireless/intel/ipw2x00/libipw_module.c b/drivers/net/wireless/intel/ipw2x00/libipw_module.c
index 552c8ff3928b..15d9a5efb581 100644
--- a/drivers/net/wireless/intel/ipw2x00/libipw_module.c
+++ b/drivers/net/wireless/intel/ipw2x00/libipw_module.c
@@ -215,11 +215,6 @@ static int debug_level_proc_show(struct seq_file *m, void *v)
 	return 0;
 }
 
-static int debug_level_proc_open(struct inode *inode, struct file *file)
-{
-	return single_open(file, debug_level_proc_show, NULL);
-}
-
 static ssize_t debug_level_proc_write(struct file *file,
 		const char __user *buffer, size_t count, loff_t *pos)
 {
@@ -240,10 +235,7 @@ static ssize_t debug_level_proc_write(struct file *file,
 }
 
 static const struct proc_ops debug_level_proc_ops = {
-	.proc_open	= debug_level_proc_open,
-	.proc_read	= seq_read,
-	.proc_lseek	= seq_lseek,
-	.proc_release	= single_release,
+	.proc_show	= debug_level_proc_show,
 	.proc_write	= debug_level_proc_write,
 };
 #endif				/* CONFIG_LIBIPW_DEBUG */
diff --git a/drivers/platform/x86/lenovo/thinkpad_acpi.c b/drivers/platform/x86/lenovo/thinkpad_acpi.c
index 4f81855ad721..2ee208c82801 100644
--- a/drivers/platform/x86/lenovo/thinkpad_acpi.c
+++ b/drivers/platform/x86/lenovo/thinkpad_acpi.c
@@ -881,11 +881,6 @@ static int dispatch_proc_show(struct seq_file *m, void *v)
 	return ibm->read(m);
 }
 
-static int dispatch_proc_open(struct inode *inode, struct file *file)
-{
-	return single_open(file, dispatch_proc_show, pde_data(inode));
-}
-
 static ssize_t dispatch_proc_write(struct file *file,
 			const char __user *userbuf,
 			size_t count, loff_t *pos)
@@ -910,10 +905,7 @@ static ssize_t dispatch_proc_write(struct file *file,
 }
 
 static const struct proc_ops dispatch_proc_ops = {
-	.proc_open	= dispatch_proc_open,
-	.proc_read	= seq_read,
-	.proc_lseek	= seq_lseek,
-	.proc_release	= single_release,
+	.proc_show	= dispatch_proc_show,
 	.proc_write	= dispatch_proc_write,
 };
 
diff --git a/drivers/platform/x86/toshiba_acpi.c b/drivers/platform/x86/toshiba_acpi.c
index 9eb8f1e5aeda..560e62da05a9 100644
--- a/drivers/platform/x86/toshiba_acpi.c
+++ b/drivers/platform/x86/toshiba_acpi.c
@@ -1448,11 +1448,6 @@ static int lcd_proc_show(struct seq_file *m, void *v)
 	return 0;
 }
 
-static int lcd_proc_open(struct inode *inode, struct file *file)
-{
-	return single_open(file, lcd_proc_show, pde_data(inode));
-}
-
 static int set_lcd_brightness(struct toshiba_acpi_dev *dev, int value)
 {
 	u32 result;
@@ -1509,10 +1504,7 @@ static ssize_t lcd_proc_write(struct file *file, const char __user *buf,
 }
 
 static const struct proc_ops lcd_proc_ops = {
-	.proc_open	= lcd_proc_open,
-	.proc_read	= seq_read,
-	.proc_lseek	= seq_lseek,
-	.proc_release	= single_release,
+	.proc_show	= lcd_proc_show,
 	.proc_write	= lcd_proc_write,
 };
 
@@ -1549,11 +1541,6 @@ static int video_proc_show(struct seq_file *m, void *v)
 	return 0;
 }
 
-static int video_proc_open(struct inode *inode, struct file *file)
-{
-	return single_open(file, video_proc_show, pde_data(inode));
-}
-
 static ssize_t video_proc_write(struct file *file, const char __user *buf,
 				size_t count, loff_t *pos)
 {
@@ -1614,10 +1601,7 @@ static ssize_t video_proc_write(struct file *file, const char __user *buf,
 }
 
 static const struct proc_ops video_proc_ops = {
-	.proc_open	= video_proc_open,
-	.proc_read	= seq_read,
-	.proc_lseek	= seq_lseek,
-	.proc_release	= single_release,
+	.proc_show	= video_proc_show,
 	.proc_write	= video_proc_write,
 };
 
@@ -1660,11 +1644,6 @@ static int fan_proc_show(struct seq_file *m, void *v)
 	return 0;
 }
 
-static int fan_proc_open(struct inode *inode, struct file *file)
-{
-	return single_open(file, fan_proc_show, pde_data(inode));
-}
-
 static ssize_t fan_proc_write(struct file *file, const char __user *buf,
 			      size_t count, loff_t *pos)
 {
@@ -1691,10 +1670,7 @@ static ssize_t fan_proc_write(struct file *file, const char __user *buf,
 }
 
 static const struct proc_ops fan_proc_ops = {
-	.proc_open	= fan_proc_open,
-	.proc_read	= seq_read,
-	.proc_lseek	= seq_lseek,
-	.proc_release	= single_release,
+	.proc_show	= fan_proc_show,
 	.proc_write	= fan_proc_write,
 };
 
@@ -1731,11 +1707,6 @@ static int keys_proc_show(struct seq_file *m, void *v)
 	return 0;
 }
 
-static int keys_proc_open(struct inode *inode, struct file *file)
-{
-	return single_open(file, keys_proc_show, pde_data(inode));
-}
-
 static ssize_t keys_proc_write(struct file *file, const char __user *buf,
 			       size_t count, loff_t *pos)
 {
@@ -1758,10 +1729,7 @@ static ssize_t keys_proc_write(struct file *file, const char __user *buf,
 }
 
 static const struct proc_ops keys_proc_ops = {
-	.proc_open	= keys_proc_open,
-	.proc_read	= seq_read,
-	.proc_lseek	= seq_lseek,
-	.proc_release	= single_release,
+	.proc_show	= keys_proc_show,
 	.proc_write	= keys_proc_write,
 };
 
diff --git a/drivers/pnp/pnpbios/proc.c b/drivers/pnp/pnpbios/proc.c
index 0f0d819b157f..14632a8d0da0 100644
--- a/drivers/pnp/pnpbios/proc.c
+++ b/drivers/pnp/pnpbios/proc.c
@@ -171,11 +171,6 @@ static int pnpbios_proc_show(struct seq_file *m, void *v)
 	return 0;
 }
 
-static int pnpbios_proc_open(struct inode *inode, struct file *file)
-{
-	return single_open(file, pnpbios_proc_show, pde_data(inode));
-}
-
 static ssize_t pnpbios_proc_write(struct file *file, const char __user *buf,
 				  size_t count, loff_t *pos)
 {
@@ -211,10 +206,7 @@ out:
 }
 
 static const struct proc_ops pnpbios_proc_ops = {
-	.proc_open	= pnpbios_proc_open,
-	.proc_read	= seq_read,
-	.proc_lseek	= seq_lseek,
-	.proc_release	= single_release,
+	.proc_show	= pnpbios_proc_show,
 	.proc_write	= pnpbios_proc_write,
 };
 
diff --git a/drivers/s390/block/dasd_proc.c b/drivers/s390/block/dasd_proc.c
index 48e12e81df00..86399427f01d 100644
--- a/drivers/s390/block/dasd_proc.c
+++ b/drivers/s390/block/dasd_proc.c
@@ -246,11 +246,6 @@ static int dasd_stats_proc_show(struct seq_file *m, void *v)
 	return 0;
 }
 
-static int dasd_stats_proc_open(struct inode *inode, struct file *file)
-{
-	return single_open(file, dasd_stats_proc_show, NULL);
-}
-
 static ssize_t dasd_stats_proc_write(struct file *file,
 		const char __user *user_buf, size_t user_len, loff_t *pos)
 {
@@ -316,10 +311,7 @@ out_error:
 }
 
 static const struct proc_ops dasd_stats_proc_ops = {
-	.proc_open	= dasd_stats_proc_open,
-	.proc_read	= seq_read,
-	.proc_lseek	= seq_lseek,
-	.proc_release	= single_release,
+	.proc_show	= dasd_stats_proc_show,
 	.proc_write	= dasd_stats_proc_write,
 };
 
diff --git a/drivers/s390/cio/blacklist.c b/drivers/s390/cio/blacklist.c
index 020d210bde9f..4e02f78f6102 100644
--- a/drivers/s390/cio/blacklist.c
+++ b/drivers/s390/cio/blacklist.c
@@ -397,18 +397,9 @@ static const struct seq_operations cio_ignore_proc_seq_ops = {
 	.show  = cio_ignore_proc_seq_show,
 };
 
-static int
-cio_ignore_proc_open(struct inode *inode, struct file *file)
-{
-	return seq_open_private(file, &cio_ignore_proc_seq_ops,
-				sizeof(struct ccwdev_iter));
-}
-
 static const struct proc_ops cio_ignore_proc_ops = {
-	.proc_open	= cio_ignore_proc_open,
-	.proc_read	= seq_read,
-	.proc_lseek	= seq_lseek,
-	.proc_release	= seq_release_private,
+	.proc_seq_ops	= &cio_ignore_proc_seq_ops,
+	.proc_state_size = sizeof(struct ccwdev_iter),
 	.proc_write	= cio_ignore_write,
 };
 
diff --git a/drivers/scsi/scsi_devinfo.c b/drivers/scsi/scsi_devinfo.c
index cfc259fd0141..0b8f5ff40543 100644
--- a/drivers/scsi/scsi_devinfo.c
+++ b/drivers/scsi/scsi_devinfo.c
@@ -670,11 +670,6 @@ static const struct seq_operations scsi_devinfo_seq_ops = {
 	.show	= devinfo_seq_show,
 };
 
-static int proc_scsi_devinfo_open(struct inode *inode, struct file *file)
-{
-	return seq_open(file, &scsi_devinfo_seq_ops);
-}
-
 /*
  * proc_scsi_dev_info_write - allow additions to scsi_dev_info_list via /proc.
  *
@@ -714,11 +709,8 @@ out:
 }
 
 static const struct proc_ops scsi_devinfo_proc_ops = {
-	.proc_open	= proc_scsi_devinfo_open,
-	.proc_read	= seq_read,
+	.proc_seq_ops	= &scsi_devinfo_seq_ops,
 	.proc_write	= proc_scsi_devinfo_write,
-	.proc_lseek	= seq_lseek,
-	.proc_release	= seq_release,
 };
 #endif /* CONFIG_SCSI_PROC_FS */
 
diff --git a/drivers/scsi/scsi_proc.c b/drivers/scsi/scsi_proc.c
index dbd03360b5a4..3e49c4c8704f 100644
--- a/drivers/scsi/scsi_proc.c
+++ b/drivers/scsi/scsi_proc.c
@@ -521,28 +521,9 @@ static const struct seq_operations scsi_seq_ops = {
 	.show	= scsi_seq_show
 };
 
-/**
- * proc_scsi_open - glue function
- * @inode: not used
- * @file: passed to single_open()
- *
- * Associates proc_scsi_show with this file
- */
-static int proc_scsi_open(struct inode *inode, struct file *file)
-{
-	/*
-	 * We don't really need this for the write case but it doesn't
-	 * harm either.
-	 */
-	return seq_open(file, &scsi_seq_ops);
-}
-
 static const struct proc_ops scsi_scsi_proc_ops = {
-	.proc_open	= proc_scsi_open,
-	.proc_read	= seq_read,
+	.proc_seq_ops	= &scsi_seq_ops,
 	.proc_write	= proc_scsi_write,
-	.proc_lseek	= seq_lseek,
-	.proc_release	= seq_release,
 };
 
 /**
diff --git a/drivers/usb/gadget/function/rndis.c b/drivers/usb/gadget/function/rndis.c
index a2fd239b7ad3..3c7bd30b8a3a 100644
--- a/drivers/usb/gadget/function/rndis.c
+++ b/drivers/usb/gadget/function/rndis.c
@@ -1183,16 +1183,8 @@ static ssize_t rndis_proc_write(struct file *file, const char __user *buffer,
 	return count;
 }
 
-static int rndis_proc_open(struct inode *inode, struct file *file)
-{
-	return single_open(file, rndis_proc_show, pde_data(inode));
-}
-
 static const struct proc_ops rndis_proc_ops = {
-	.proc_open	= rndis_proc_open,
-	.proc_read	= seq_read,
-	.proc_lseek	= seq_lseek,
-	.proc_release	= single_release,
+	.proc_show	= rndis_proc_show,
 	.proc_write	= rndis_proc_write,
 };
 
diff --git a/drivers/video/fbdev/via/viafbdev.c b/drivers/video/fbdev/via/viafbdev.c
index 2c67a18d16ad..4b617e80a77c 100644
--- a/drivers/video/fbdev/via/viafbdev.c
+++ b/drivers/video/fbdev/via/viafbdev.c
@@ -1120,11 +1120,6 @@ static int viafb_dvp0_proc_show(struct seq_file *m, void *v)
 	return 0;
 }
 
-static int viafb_dvp0_proc_open(struct inode *inode, struct file *file)
-{
-	return single_open(file, viafb_dvp0_proc_show, NULL);
-}
-
 static ssize_t viafb_dvp0_proc_write(struct file *file,
 	const char __user *buffer, size_t count, loff_t *pos)
 {
@@ -1173,10 +1168,7 @@ static ssize_t viafb_dvp0_proc_write(struct file *file,
 }
 
 static const struct proc_ops viafb_dvp0_proc_ops = {
-	.proc_open	= viafb_dvp0_proc_open,
-	.proc_read	= seq_read,
-	.proc_lseek	= seq_lseek,
-	.proc_release	= single_release,
+	.proc_show	= viafb_dvp0_proc_show,
 	.proc_write	= viafb_dvp0_proc_write,
 };
 
@@ -1190,11 +1182,6 @@ static int viafb_dvp1_proc_show(struct seq_file *m, void *v)
 	return 0;
 }
 
-static int viafb_dvp1_proc_open(struct inode *inode, struct file *file)
-{
-	return single_open(file, viafb_dvp1_proc_show, NULL);
-}
-
 static ssize_t viafb_dvp1_proc_write(struct file *file,
 	const char __user *buffer, size_t count, loff_t *pos)
 {
@@ -1237,10 +1224,7 @@ static ssize_t viafb_dvp1_proc_write(struct file *file,
 }
 
 static const struct proc_ops viafb_dvp1_proc_ops = {
-	.proc_open	= viafb_dvp1_proc_open,
-	.proc_read	= seq_read,
-	.proc_lseek	= seq_lseek,
-	.proc_release	= single_release,
+	.proc_show	= viafb_dvp1_proc_show,
 	.proc_write	= viafb_dvp1_proc_write,
 };
 
@@ -1252,11 +1236,6 @@ static int viafb_dfph_proc_show(struct seq_file *m, void *v)
 	return 0;
 }
 
-static int viafb_dfph_proc_open(struct inode *inode, struct file *file)
-{
-	return single_open(file, viafb_dfph_proc_show, NULL);
-}
-
 static ssize_t viafb_dfph_proc_write(struct file *file,
 	const char __user *buffer, size_t count, loff_t *pos)
 {
@@ -1271,10 +1250,7 @@ static ssize_t viafb_dfph_proc_write(struct file *file,
 }
 
 static const struct proc_ops viafb_dfph_proc_ops = {
-	.proc_open	= viafb_dfph_proc_open,
-	.proc_read	= seq_read,
-	.proc_lseek	= seq_lseek,
-	.proc_release	= single_release,
+	.proc_show	= viafb_dfph_proc_show,
 	.proc_write	= viafb_dfph_proc_write,
 };
 
@@ -1286,11 +1262,6 @@ static int viafb_dfpl_proc_show(struct seq_file *m, void *v)
 	return 0;
 }
 
-static int viafb_dfpl_proc_open(struct inode *inode, struct file *file)
-{
-	return single_open(file, viafb_dfpl_proc_show, NULL);
-}
-
 static ssize_t viafb_dfpl_proc_write(struct file *file,
 	const char __user *buffer, size_t count, loff_t *pos)
 {
@@ -1305,10 +1276,7 @@ static ssize_t viafb_dfpl_proc_write(struct file *file,
 }
 
 static const struct proc_ops viafb_dfpl_proc_ops = {
-	.proc_open	= viafb_dfpl_proc_open,
-	.proc_read	= seq_read,
-	.proc_lseek	= seq_lseek,
-	.proc_release	= single_release,
+	.proc_show	= viafb_dfpl_proc_show,
 	.proc_write	= viafb_dfpl_proc_write,
 };
 
@@ -1344,11 +1312,6 @@ static int viafb_vt1636_proc_show(struct seq_file *m, void *v)
 	return 0;
 }
 
-static int viafb_vt1636_proc_open(struct inode *inode, struct file *file)
-{
-	return single_open(file, viafb_vt1636_proc_show, NULL);
-}
-
 static ssize_t viafb_vt1636_proc_write(struct file *file,
 	const char __user *buffer, size_t count, loff_t *pos)
 {
@@ -1440,10 +1403,7 @@ static ssize_t viafb_vt1636_proc_write(struct file *file,
 }
 
 static const struct proc_ops viafb_vt1636_proc_ops = {
-	.proc_open	= viafb_vt1636_proc_open,
-	.proc_read	= seq_read,
-	.proc_lseek	= seq_lseek,
-	.proc_release	= single_release,
+	.proc_show	= viafb_vt1636_proc_show,
 	.proc_write	= viafb_vt1636_proc_write,
 };
 
@@ -1491,11 +1451,6 @@ static int viafb_iga1_odev_proc_show(struct seq_file *m, void *v)
 	return 0;
 }
 
-static int viafb_iga1_odev_proc_open(struct inode *inode, struct file *file)
-{
-	return single_open(file, viafb_iga1_odev_proc_show, NULL);
-}
-
 static ssize_t viafb_iga1_odev_proc_write(struct file *file,
 	const char __user *buffer, size_t count, loff_t *pos)
 {
@@ -1517,10 +1472,7 @@ static ssize_t viafb_iga1_odev_proc_write(struct file *file,
 }
 
 static const struct proc_ops viafb_iga1_odev_proc_ops = {
-	.proc_open	= viafb_iga1_odev_proc_open,
-	.proc_read	= seq_read,
-	.proc_lseek	= seq_lseek,
-	.proc_release	= single_release,
+	.proc_show	= viafb_iga1_odev_proc_show,
 	.proc_write	= viafb_iga1_odev_proc_write,
 };
 
@@ -1530,11 +1482,6 @@ static int viafb_iga2_odev_proc_show(struct seq_file *m, void *v)
 	return 0;
 }
 
-static int viafb_iga2_odev_proc_open(struct inode *inode, struct file *file)
-{
-	return single_open(file, viafb_iga2_odev_proc_show, NULL);
-}
-
 static ssize_t viafb_iga2_odev_proc_write(struct file *file,
 	const char __user *buffer, size_t count, loff_t *pos)
 {
@@ -1556,10 +1503,7 @@ static ssize_t viafb_iga2_odev_proc_write(struct file *file,
 }
 
 static const struct proc_ops viafb_iga2_odev_proc_ops = {
-	.proc_open	= viafb_iga2_odev_proc_open,
-	.proc_read	= seq_read,
-	.proc_lseek	= seq_lseek,
-	.proc_release	= single_release,
+	.proc_show	= viafb_iga2_odev_proc_show,
 	.proc_write	= viafb_iga2_odev_proc_write,
 };
 
diff --git a/fs/jfs/jfs_debug.c b/fs/jfs/jfs_debug.c
index 44b62b3c322e..5eb35b0d420f 100644
--- a/fs/jfs/jfs_debug.c
+++ b/fs/jfs/jfs_debug.c
@@ -23,11 +23,6 @@ static int jfs_loglevel_proc_show(struct seq_file *m, void *v)
 	return 0;
 }
 
-static int jfs_loglevel_proc_open(struct inode *inode, struct file *file)
-{
-	return single_open(file, jfs_loglevel_proc_show, NULL);
-}
-
 static ssize_t jfs_loglevel_proc_write(struct file *file,
 		const char __user *buffer, size_t count, loff_t *ppos)
 {
@@ -44,10 +39,7 @@ static ssize_t jfs_loglevel_proc_write(struct file *file,
 }
 
 static const struct proc_ops jfs_loglevel_proc_ops = {
-	.proc_open	= jfs_loglevel_proc_open,
-	.proc_read	= seq_read,
-	.proc_lseek	= seq_lseek,
-	.proc_release	= single_release,
+	.proc_show	= jfs_loglevel_proc_show,
 	.proc_write	= jfs_loglevel_proc_write,
 };
 #endif
diff --git a/fs/ntfs3/super.c b/fs/ntfs3/super.c
index 37e27b73b7a5..cd47839872b0 100644
--- a/fs/ntfs3/super.c
+++ b/fs/ntfs3/super.c
@@ -548,11 +548,6 @@ static int ntfs3_volinfo(struct seq_file *m, void *o)
 	return 0;
 }
 
-static int ntfs3_volinfo_open(struct inode *inode, struct file *file)
-{
-	return single_open(file, ntfs3_volinfo, pde_data(inode));
-}
-
 /* read /proc/fs/ntfs3/<dev>/label */
 static int ntfs3_label_show(struct seq_file *m, void *o)
 {
@@ -598,23 +593,12 @@ out:
 	return ret;
 }
 
-static int ntfs3_label_open(struct inode *inode, struct file *file)
-{
-	return single_open(file, ntfs3_label_show, pde_data(inode));
-}
-
 static const struct proc_ops ntfs3_volinfo_fops = {
-	.proc_read = seq_read,
-	.proc_lseek = seq_lseek,
-	.proc_release = single_release,
-	.proc_open = ntfs3_volinfo_open,
+	.proc_show = ntfs3_volinfo,
 };
 
 static const struct proc_ops ntfs3_label_fops = {
-	.proc_read = seq_read,
-	.proc_lseek = seq_lseek,
-	.proc_release = single_release,
-	.proc_open = ntfs3_label_open,
+	.proc_show = ntfs3_label_show,
 	.proc_write = ntfs3_label_write,
 };
 
diff --git a/fs/proc/cpuinfo.c b/fs/proc/cpuinfo.c
index f38bda5b83ec..d8cd718c6030 100644
--- a/fs/proc/cpuinfo.c
+++ b/fs/proc/cpuinfo.c
@@ -7,17 +7,9 @@
 
 extern const struct seq_operations cpuinfo_op;
 
-static int cpuinfo_open(struct inode *inode, struct file *file)
-{
-	return seq_open(file, &cpuinfo_op);
-}
-
 static const struct proc_ops cpuinfo_proc_ops = {
 	.proc_flags	= PROC_ENTRY_PERMANENT,
-	.proc_open	= cpuinfo_open,
-	.proc_read_iter	= seq_read_iter,
-	.proc_lseek	= seq_lseek,
-	.proc_release	= seq_release,
+	.proc_seq_ops	= &cpuinfo_op,
 };
 
 static int __init proc_cpuinfo_init(void)
diff --git a/fs/smb/client/cifs_debug.c b/fs/smb/client/cifs_debug.c
index 577f0ddede90..dfcd2cdbb2a8 100644
--- a/fs/smb/client/cifs_debug.c
+++ b/fs/smb/client/cifs_debug.c
@@ -357,10 +357,6 @@ static int cifs_debug_dirs_proc_show(struct seq_file *m, void *v)
 }
 
 #ifdef CONFIG_CIFS_DEBUG
-static int cifs_debug_dirs_proc_open(struct inode *inode, struct file *file)
-{
-	return single_open(file, cifs_debug_dirs_proc_show, NULL);
-}
 
 /* Drop all cached directory entries across all CIFS mounts. */
 static ssize_t cifs_debug_dirs_proc_write(struct file *file, const char __user *buffer,
@@ -393,10 +389,7 @@ static ssize_t cifs_debug_dirs_proc_write(struct file *file, const char __user *
 }
 
 static const struct proc_ops cifs_debug_dirs_proc_ops = {
-	.proc_open	= cifs_debug_dirs_proc_open,
-	.proc_read	= seq_read,
-	.proc_lseek	= seq_lseek,
-	.proc_release	= single_release,
+	.proc_show	= cifs_debug_dirs_proc_show,
 	.proc_write	= cifs_debug_dirs_proc_write,
 };
 #endif /* CONFIG_CIFS_DEBUG */
@@ -859,16 +852,8 @@ static int cifs_stats_proc_show(struct seq_file *m, void *v)
 	return 0;
 }
 
-static int cifs_stats_proc_open(struct inode *inode, struct file *file)
-{
-	return single_open(file, cifs_stats_proc_show, NULL);
-}
-
 static const struct proc_ops cifs_stats_proc_ops = {
-	.proc_open	= cifs_stats_proc_open,
-	.proc_read	= seq_read,
-	.proc_lseek	= seq_lseek,
-	.proc_release	= single_release,
+	.proc_show	= cifs_stats_proc_show,
 	.proc_write	= cifs_stats_proc_write,
 };
 
@@ -1012,11 +997,6 @@ static int cifsFYI_proc_show(struct seq_file *m, void *v)
 	return 0;
 }
 
-static int cifsFYI_proc_open(struct inode *inode, struct file *file)
-{
-	return single_open(file, cifsFYI_proc_show, NULL);
-}
-
 static ssize_t cifsFYI_proc_write(struct file *file, const char __user *buffer,
 		size_t count, loff_t *ppos)
 {
@@ -1038,10 +1018,7 @@ static ssize_t cifsFYI_proc_write(struct file *file, const char __user *buffer,
 }
 
 static const struct proc_ops cifsFYI_proc_ops = {
-	.proc_open	= cifsFYI_proc_open,
-	.proc_read	= seq_read,
-	.proc_lseek	= seq_lseek,
-	.proc_release	= single_release,
+	.proc_show	= cifsFYI_proc_show,
 	.proc_write	= cifsFYI_proc_write,
 };
 
@@ -1051,11 +1028,6 @@ static int cifs_linux_ext_proc_show(struct seq_file *m, void *v)
 	return 0;
 }
 
-static int cifs_linux_ext_proc_open(struct inode *inode, struct file *file)
-{
-	return single_open(file, cifs_linux_ext_proc_show, NULL);
-}
-
 static ssize_t cifs_linux_ext_proc_write(struct file *file,
 		const char __user *buffer, size_t count, loff_t *ppos)
 {
@@ -1069,10 +1041,7 @@ static ssize_t cifs_linux_ext_proc_write(struct file *file,
 }
 
 static const struct proc_ops cifs_linux_ext_proc_ops = {
-	.proc_open	= cifs_linux_ext_proc_open,
-	.proc_read	= seq_read,
-	.proc_lseek	= seq_lseek,
-	.proc_release	= single_release,
+	.proc_show	= cifs_linux_ext_proc_show,
 	.proc_write	= cifs_linux_ext_proc_write,
 };
 
@@ -1082,11 +1051,6 @@ static int cifs_lookup_cache_proc_show(struct seq_file *m, void *v)
 	return 0;
 }
 
-static int cifs_lookup_cache_proc_open(struct inode *inode, struct file *file)
-{
-	return single_open(file, cifs_lookup_cache_proc_show, NULL);
-}
-
 static ssize_t cifs_lookup_cache_proc_write(struct file *file,
 		const char __user *buffer, size_t count, loff_t *ppos)
 {
@@ -1100,10 +1064,7 @@ static ssize_t cifs_lookup_cache_proc_write(struct file *file,
 }
 
 static const struct proc_ops cifs_lookup_cache_proc_ops = {
-	.proc_open	= cifs_lookup_cache_proc_open,
-	.proc_read	= seq_read,
-	.proc_lseek	= seq_lseek,
-	.proc_release	= single_release,
+	.proc_show	= cifs_lookup_cache_proc_show,
 	.proc_write	= cifs_lookup_cache_proc_write,
 };
 
@@ -1113,11 +1074,6 @@ static int traceSMB_proc_show(struct seq_file *m, void *v)
 	return 0;
 }
 
-static int traceSMB_proc_open(struct inode *inode, struct file *file)
-{
-	return single_open(file, traceSMB_proc_show, NULL);
-}
-
 static ssize_t traceSMB_proc_write(struct file *file, const char __user *buffer,
 		size_t count, loff_t *ppos)
 {
@@ -1131,10 +1087,7 @@ static ssize_t traceSMB_proc_write(struct file *file, const char __user *buffer,
 }
 
 static const struct proc_ops traceSMB_proc_ops = {
-	.proc_open	= traceSMB_proc_open,
-	.proc_read	= seq_read,
-	.proc_lseek	= seq_lseek,
-	.proc_release	= single_release,
+	.proc_show	= traceSMB_proc_show,
 	.proc_write	= traceSMB_proc_write,
 };
 
@@ -1144,11 +1097,6 @@ static int cifs_security_flags_proc_show(struct seq_file *m, void *v)
 	return 0;
 }
 
-static int cifs_security_flags_proc_open(struct inode *inode, struct file *file)
-{
-	return single_open(file, cifs_security_flags_proc_show, NULL);
-}
-
 /*
  * Ensure that if someone sets a MUST flag, that we disable all other MAY
  * flags except for the ones corresponding to the given MUST flag. If there are
@@ -1234,10 +1182,7 @@ static ssize_t cifs_security_flags_proc_write(struct file *file,
 }
 
 static const struct proc_ops cifs_security_flags_proc_ops = {
-	.proc_open	= cifs_security_flags_proc_open,
-	.proc_read	= seq_read,
-	.proc_lseek	= seq_lseek,
-	.proc_release	= single_release,
+	.proc_show	= cifs_security_flags_proc_show,
 	.proc_write	= cifs_security_flags_proc_write,
 };
 
@@ -1271,16 +1216,8 @@ static int cifs_mount_params_proc_show(struct seq_file *m, void *v)
 	return 0;
 }
 
-static int cifs_mount_params_proc_open(struct inode *inode, struct file *file)
-{
-	return single_open(file, cifs_mount_params_proc_show, NULL);
-}
-
 static const struct proc_ops cifs_mount_params_proc_ops = {
-	.proc_open	= cifs_mount_params_proc_open,
-	.proc_read	= seq_read,
-	.proc_lseek	= seq_lseek,
-	.proc_release	= single_release,
+	.proc_show = cifs_mount_params_proc_show,
 	/* No need for write for now */
 	/* .proc_write	= cifs_mount_params_proc_write, */
 };
diff --git a/fs/smb/client/dfs_cache.c b/fs/smb/client/dfs_cache.c
index 26956e33037e..58f16cf83d36 100644
--- a/fs/smb/client/dfs_cache.c
+++ b/fs/smb/client/dfs_cache.c
@@ -213,16 +213,8 @@ static ssize_t dfscache_proc_write(struct file *file, const char __user *buffer,
 	return count;
 }
 
-static int dfscache_proc_open(struct inode *inode, struct file *file)
-{
-	return single_open(file, dfscache_proc_show, NULL);
-}
-
 const struct proc_ops dfscache_proc_ops = {
-	.proc_open	= dfscache_proc_open,
-	.proc_read	= seq_read,
-	.proc_lseek	= seq_lseek,
-	.proc_release	= single_release,
+	.proc_show	= dfscache_proc_show,
 	.proc_write	= dfscache_proc_write,
 };
 
diff --git a/kernel/irq/proc.c b/kernel/irq/proc.c
index 0c0df16de581..aa3d5544cfc1 100644
--- a/kernel/irq/proc.c
+++ b/kernel/irq/proc.c
@@ -188,29 +188,13 @@ static ssize_t irq_affinity_list_proc_write(struct file *file,
 	return write_irq_affinity(1, file, buffer, count, pos);
 }
 
-static int irq_affinity_proc_open(struct inode *inode, struct file *file)
-{
-	return single_open(file, irq_affinity_proc_show, pde_data(inode));
-}
-
-static int irq_affinity_list_proc_open(struct inode *inode, struct file *file)
-{
-	return single_open(file, irq_affinity_list_proc_show, pde_data(inode));
-}
-
 static const struct proc_ops irq_affinity_proc_ops = {
-	.proc_open	= irq_affinity_proc_open,
-	.proc_read	= seq_read,
-	.proc_lseek	= seq_lseek,
-	.proc_release	= single_release,
+	.proc_show	= irq_affinity_proc_show,
 	.proc_write	= irq_affinity_proc_write,
 };
 
 static const struct proc_ops irq_affinity_list_proc_ops = {
-	.proc_open	= irq_affinity_list_proc_open,
-	.proc_read	= seq_read,
-	.proc_lseek	= seq_lseek,
-	.proc_release	= single_release,
+	.proc_show	= irq_affinity_list_proc_show,
 	.proc_write	= irq_affinity_list_proc_write,
 };
 
@@ -263,16 +247,8 @@ out:
 	return err;
 }
 
-static int default_affinity_open(struct inode *inode, struct file *file)
-{
-	return single_open(file, default_affinity_show, pde_data(inode));
-}
-
 static const struct proc_ops default_affinity_proc_ops = {
-	.proc_open	= default_affinity_open,
-	.proc_read	= seq_read,
-	.proc_lseek	= seq_lseek,
-	.proc_release	= single_release,
+	.proc_show	= default_affinity_show,
 	.proc_write	= default_affinity_write,
 };
 
diff --git a/kernel/latencytop.c b/kernel/latencytop.c
index d4281d1e13a6..b764f47606d3 100644
--- a/kernel/latencytop.c
+++ b/kernel/latencytop.c
@@ -275,17 +275,9 @@ lstats_write(struct file *file, const char __user *buf, size_t count,
 	return count;
 }
 
-static int lstats_open(struct inode *inode, struct file *filp)
-{
-	return single_open(filp, lstats_show, NULL);
-}
-
 static const struct proc_ops lstats_proc_ops = {
-	.proc_open	= lstats_open,
-	.proc_read	= seq_read,
+	.proc_show	= lstats_show,
 	.proc_write	= lstats_write,
-	.proc_lseek	= seq_lseek,
-	.proc_release	= single_release,
 };
 
 static int __init init_lstats_procfs(void)
diff --git a/lib/dynamic_debug.c b/lib/dynamic_debug.c
index 18a71a9108d3..64a211290872 100644
--- a/lib/dynamic_debug.c
+++ b/lib/dynamic_debug.c
@@ -1194,10 +1194,8 @@ static const struct file_operations ddebug_proc_fops = {
 };
 
 static const struct proc_ops proc_fops = {
-	.proc_open = ddebug_proc_open,
-	.proc_read = seq_read,
-	.proc_lseek = seq_lseek,
-	.proc_release = seq_release_private,
+	.proc_seq_ops = &ddebug_proc_seqops,
+	.proc_state_size = sizeof(struct ddebug_iter),
 	.proc_write = ddebug_proc_write
 };
 
diff --git a/mm/slab_common.c b/mm/slab_common.c
index 01c64ef661e7..fbf303b45858 100644
--- a/mm/slab_common.c
+++ b/mm/slab_common.c
@@ -1233,17 +1233,9 @@ static const struct seq_operations slabinfo_op = {
 	.show = slab_show,
 };
 
-static int slabinfo_open(struct inode *inode, struct file *file)
-{
-	return seq_open(file, &slabinfo_op);
-}
-
 static const struct proc_ops slabinfo_proc_ops = {
 	.proc_flags	= PROC_ENTRY_PERMANENT,
-	.proc_open	= slabinfo_open,
-	.proc_read	= seq_read,
-	.proc_lseek	= seq_lseek,
-	.proc_release	= seq_release,
+	.proc_seq_ops	= &slabinfo_op,
 };
 
 static int __init slab_proc_init(void)
diff --git a/net/core/pktgen.c b/net/core/pktgen.c
index 02af70d360bc..12363a373fb8 100644
--- a/net/core/pktgen.c
+++ b/net/core/pktgen.c
@@ -550,17 +550,9 @@ static ssize_t pgctrl_write(struct file *file, const char __user *buf,
 	return count;
 }
 
-static int pgctrl_open(struct inode *inode, struct file *file)
-{
-	return single_open(file, pgctrl_show, pde_data(inode));
-}
-
 static const struct proc_ops pktgen_proc_ops = {
-	.proc_open	= pgctrl_open,
-	.proc_read	= seq_read,
-	.proc_lseek	= seq_lseek,
+	.proc_show	= pgctrl_show,
 	.proc_write	= pgctrl_write,
-	.proc_release	= single_release,
 };
 
 static int pktgen_if_show(struct seq_file *seq, void *v)
@@ -1870,17 +1862,9 @@ static ssize_t pktgen_if_write(struct file *file,
 	return -EINVAL;
 }
 
-static int pktgen_if_open(struct inode *inode, struct file *file)
-{
-	return single_open(file, pktgen_if_show, pde_data(inode));
-}
-
 static const struct proc_ops pktgen_if_proc_ops = {
-	.proc_open	= pktgen_if_open,
-	.proc_read	= seq_read,
-	.proc_lseek	= seq_lseek,
+	.proc_show	= pktgen_if_show,
 	.proc_write	= pktgen_if_write,
-	.proc_release	= single_release,
 };
 
 static int pktgen_thread_show(struct seq_file *seq, void *v)
@@ -2010,17 +1994,9 @@ out:
 	return ret;
 }
 
-static int pktgen_thread_open(struct inode *inode, struct file *file)
-{
-	return single_open(file, pktgen_thread_show, pde_data(inode));
-}
-
 static const struct proc_ops pktgen_thread_proc_ops = {
-	.proc_open	= pktgen_thread_open,
-	.proc_read	= seq_read,
-	.proc_lseek	= seq_lseek,
+	.proc_show	= pktgen_thread_show,
 	.proc_write	= pktgen_thread_write,
-	.proc_release	= single_release,
 };
 
 /* Think find or remove for NN */
diff --git a/net/sunrpc/stats.c b/net/sunrpc/stats.c
index d08711bee18e..f5ee18a0eb37 100644
--- a/net/sunrpc/stats.c
+++ b/net/sunrpc/stats.c
@@ -64,16 +64,8 @@ static int rpc_proc_show(struct seq_file *seq, void *v) {
 	return 0;
 }
 
-static int rpc_proc_open(struct inode *inode, struct file *file)
-{
-	return single_open(file, rpc_proc_show, pde_data(inode));
-}
-
 static const struct proc_ops rpc_proc_ops = {
-	.proc_open	= rpc_proc_open,
-	.proc_read	= seq_read,
-	.proc_lseek	= seq_lseek,
-	.proc_release	= single_release,
+	.proc_show = rpc_proc_show,
 };
 
 /*

-- 
2.53.0

