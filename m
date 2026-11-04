Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.remote-ip=100.103.45.18
ARC-Seal: i=1; d=subspace.kernel.org; s=arc20261015; a=rsa-sha256; cv=none;
	t=1793826933;
	b=GG22GlcVPX8lpOcPOBqOcACZWVvIs4AaOQ8mz1r94LZkXqmhOUrqAcIADZ6DmTcSaN1R
	 gS+GMFgdDOkA1u20njpcwQL8qyhDag7BE+iC3ylF8nO9T4TVTPx5X81TVRm0Giisrdfr6
	 Hhe7Ofou51YFQh+ze5WTY3WOdzY4qVMxmiU+wMORwHhszUC3KwPDmYmGN9sNJVQMwhy0x
	 pYdQbOLyCFGAl5A7PsAJewEXoED7YeE1nga7Anx+tRB0AwWYRdoOOhi0u+ONw0LjihwvP
	 6Kv7p1LvM8FYJ+Jxj7Ea9pUqyLctKnpgkCPwmtfC1C5IxJlYNtwJHRdK9AYv4as3WTg==
ARC-Message-Signature: i=1; d=subspace.kernel.org; s=arc20261015;
	a=rsa-sha256; c=relaxed/relaxed; t=1793826933;
	h=Received:DKIM-Signature:From:To:Cc:Subject:Date:Message-ID:
	 In-Reply-To:References:MIME-Version:Content-Type:X-Change-ID:X-Mailer:
	 X-Developer-Signature:X-Developer-Key:Content-Transfer-Encoding;
	bh=pKDbClFBSTb2iA5lmVWu3JcMB4xPc/CEhi+1bz8KTwM=;
	b=YxH41oVoZl7dIT2flFVRRSpeixLSh6ALg29MdDmkIjNLd0NcDM6dfr5raSXiV7T5UBCy
	 UN9TLHlOkTskZaJJF3COKmyJwJrGUGojXgxDRp1LQxGc0KHieQhQ3YSG5ej/Kjdcid4qb
	 1WOTk4JhMuafW29dsX5oZIAn0x9wqD/o6+705LL6zMMvc70RKTIM5zDZKKnCaaVSvWHV1
	 LsbukF40eqq9maHuJuZA54kPoxHWMy6Y5FJ50Zc7+pH0Z7BDGehOlwG215P3wGmCDO1Na
	 Tb6CzalGn5M1HAtj57IiaRWG17/60IWpMd3BGbk44HZ+9SdkUXwTrhczEPC+9kfad/w==
ARC-Authentication-Results: i=1; smtp.subspace.kernel.org; 
	dkim=pass header.d=kernel.org header.i=@kernel.org header.a=rsa-sha256 header.s=k20260515 header.b=N4RWdVB9;
	arc=none smtp.remote-ip=100.103.45.18
Received: from smtp.kernel.org (quasi.space.kernel.org [100.103.45.18])
	(using TLSv1.3 with cipher TLS_AES_256_GCM_SHA384 (256/256 bits)
	 key-exchange X25519 server-signature ECDSA (prime256v1))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 35B726072FA9;
	Wed,  4 Nov 2026 21:15:32 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key, unprotected) header.d=kernel.org header.i=@kernel.org header.a=rsa-sha256 header.s=k20260515 header.b=N4RWdVB9
Received: by smtp.kernel.org (Postfix) with ESMTPSA id CCB311F000C1;
	Wed,  4 Nov 2026 21:15:19 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=kernel.org;
	s=k20260515; t=1793826932;
	bh=pKDbClFBSTb2iA5lmVWu3JcMB4xPc/CEhi+1bz8KTwM=;
	h=From:To:Cc:Subject:Date:In-Reply-To:References;
	b=N4RWdVB9vOqSj+z3xoqK3D91W85N/5x8BUFgodhr3LnZLIbySQORxP08pdtMQvZv5
	 1x8lIb0WwSPzFyBDxpYFXo9vPXcB7px+UK2StTIJFt7nytavLAUDilrh6newTSihD3
	 KRKMLXLblPoDRGDnQSqCLOWHUTWisM81t9HrsNM941SyGCOmwAO+jwd3PRbW8DUMF5
	 MISMonFFw8afaeqiqjPZqEJRn8XZHGJMgT6VJWTJ9AzSZcOeIwiDx6xHOSqp8Jyv5F
	 HbMH4lodbULontL13ZvwSN6AuwlBe8oX65CYvif6mYtrK7bbtebY8FhAIfYOEl0R0H
	 mEm1nMix81KPg==
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
Subject: [PATCH RESEND v2 0/6] proc: drop the __user methods (Part 7/7)
Date: Wed,  4 Nov 2026 22:15:17 +0100
Message-ID: <20261104-work-procfs-cleanup-v2-0-1e6687e226b1@kernel.org>
In-Reply-To: <20261104-work-procfs-v2-0-b45cd5789ac5@brauner>
References: <20261104-work-procfs-v2-0-b45cd5789ac5@brauner>
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
X-Change-ID: 20261030-work-procfs-cleanup-1694f71bb156
X-Mailer: b4 0.17-dev
X-Developer-Signature: v=1; a=openpgp-sha256; l=42733; i=brauner@kernel.org; h=from:subject:message-id; bh=HcOXoZ0wKV2a+wHtLrfT0g6KO1HDIltU2lSs53LAe8Q=; b=owGbwMvMwCU28Zj0gdSKO4sYT6slMWS9XhBzdKmV1Irnzb4HJxjofOWbFeLAdL9NgHV6Pjf7u VOajbNWd5SyMIhxMciKKbI4tJuEyy3nqdhslKkBM4eVCWQIAxenAEyk0Jzhf61Qz0dZ/Su2/c8v NDvF9jjNa//CWPyYy11m3lQbnl+PZjD8lS8x2ZMqsCPsdQvvpjWLn98yvcwuvux5koHd85r3k7b rcAMA
X-Developer-Key: i=brauner@kernel.org; a=openpgp; fpr=4880B8C9BD0E5106FC070F4F7B3C391EFEA93624
Content-Transfer-Encoding: 8bit

Part 7/7 of "proc: move procfs to what kernfs does", on top of parts 3
to 6:

  https://patch.msgid.link/20261104-work-procfs-v2-0-b45cd5789ac5@brauner

This is the final part of letting procfs own the data path.Every entry
that can be removed reads, writes and handles ioctls through procfs'
buffers now, so its code only runs with the entry pinned and never
touches userspace memory.

Drop ->proc_write(), ->proc_ioctl() and ->proc_compat_ioctl(). The
entries that keep reading straight into userspace, kcore, kmsg and the
kpage files, are built in and never removed, so procfs never pins them
and nothing can wait for them. They get a file_operations of their own
that goes into the inode as it is.

Afterwards, nothing in struct proc_ops takes a __user pointer anymore,
and one set of file_operations serves every entry that has proc_ops,
like kernfs_file_fops does. For those five files mmap() fails with
-ENODEV instead of -EIO now and a write() by someone who can open them
for writing with -EINVAL instead of -EIO. Nothing else changes for them.

With the old names free the _buf suffix of the new methods doesn't mean
anything anymore, so ->proc_write_buf(), ->proc_read_buf() and
->proc_ioctl_buf() become ->proc_write(), ->proc_read() and
->proc_ioctl() at the end.

The last patch takes the poll_table away from ->proc_poll(), so that an
entry can't hand procfs a queue that dies before its files do.

With the whole stack on a KASAN and lockdep kernel the removal
selftests of all parts pass, the proc, pktgen and allocinfo selftests
behave like without it, and kcore, kmsg, the kpage files and
/proc/profile behave the same syscall by syscall, read, pread, seek,
splice, poll and ioctl included, apart from the two errno changes
above and splice() now working on /proc/profile.

Signed-off-by: Christian Brauner (Amutable) <brauner@kernel.org>
---
Changes in v2:
- kcore, kmsg and the kpage files get file_operations of their own
  instead of staying the permanent exception, and ->proc_read() and
  ->proc_read_iter() go away with them: nothing in struct proc_ops takes
  a __user pointer anymore; a splice() from a write-only entry fails
  with -EIO instead of -EINVAL now that one set of file_operations
  serves every entry
- the poll_table is dropped from ->proc_poll()
- rebased onto v7.4-rc1
- Link to v1: https://patch.msgid.link/20261102-work-procfs-cleanup-v1-0-c40014bc12f5@kernel.org

---
Christian Brauner (6):
      proc: drop ->proc_write()
      proc: drop ->proc_ioctl() and ->proc_compat_ioctl()
      proc: give kcore, kmsg and the kpage files their own file_operations
      proc: drop ->proc_read() and ->proc_read_iter()
      proc: drop the _buf suffix from the new methods
      proc: drop the poll_table from ->proc_poll()

 arch/alpha/kernel/srm_env.c                        |   2 +-
 arch/arm/kernel/atags_proc.c                       |   2 +-
 arch/arm/mm/alignment.c                            |   2 +-
 arch/m68k/kernel/bootinfo_proc.c                   |   2 +-
 arch/powerpc/kernel/proc_powerpc.c                 |   2 +-
 arch/powerpc/kernel/rtas-proc.c                    |  10 +-
 arch/powerpc/kernel/rtas_flash.c                   |  16 +--
 arch/powerpc/kernel/rtasd.c                        |   4 +-
 arch/powerpc/platforms/pseries/lpar.c              |   4 +-
 arch/powerpc/platforms/pseries/lparcfg.c           |   2 +-
 arch/powerpc/platforms/pseries/reconfig.c          |   2 +-
 arch/sh/mm/alignment.c                             |   2 +-
 arch/sparc/kernel/led.c                            |   2 +-
 arch/um/drivers/mconsole_kern.c                    |   2 +-
 arch/um/kernel/exitcode.c                          |   2 +-
 arch/x86/kernel/cpu/mtrr/if.c                      |   4 +-
 arch/xtensa/platforms/iss/simdisk.c                |   4 +-
 drivers/acpi/proc.c                                |   2 +-
 drivers/hwmon/dell-smm-hwmon.c                     |   2 +-
 drivers/input/input.c                              |   2 +-
 drivers/macintosh/via-pmu.c                        |   2 +-
 drivers/md/md.c                                    |   2 +-
 drivers/net/wireless/intel/ipw2x00/libipw_module.c |   2 +-
 drivers/pci/proc.c                                 |   6 +-
 drivers/platform/x86/lenovo/thinkpad_acpi.c        |   2 +-
 drivers/platform/x86/toshiba_acpi.c                |   8 +-
 drivers/pnp/isapnp/proc.c                          |   2 +-
 drivers/pnp/pnpbios/proc.c                         |   2 +-
 drivers/s390/block/dasd_proc.c                     |   2 +-
 drivers/s390/cio/blacklist.c                       |   2 +-
 drivers/s390/cio/css.c                             |   2 +-
 drivers/scsi/esas2r/esas2r_main.c                  |   2 +-
 drivers/scsi/scsi_devinfo.c                        |   2 +-
 drivers/scsi/scsi_proc.c                           |   4 +-
 drivers/scsi/sg.c                                  |   4 +-
 drivers/tty/sysrq.c                                |   2 +-
 drivers/usb/gadget/function/rndis.c                |   2 +-
 drivers/video/fbdev/via/viafbdev.c                 |  14 +-
 drivers/zorro/proc.c                               |   2 +-
 fs/jfs/jfs_debug.c                                 |   2 +-
 fs/lockd/procfs.c                                  |   4 +-
 fs/ntfs3/super.c                                   |   2 +-
 fs/proc/generic.c                                  |  60 +++++----
 fs/proc/inode.c                                    | 146 ++++-----------------
 fs/proc/internal.h                                 |  21 +--
 fs/proc/kcore.c                                    |  14 +-
 fs/proc/kmsg.c                                     |  17 +--
 fs/proc/page.c                                     |  27 ++--
 fs/proc/proc_net.c                                 |   4 +-
 fs/proc/vmcore.c                                   |   2 +-
 fs/smb/client/cifs_debug.c                         |  16 +--
 fs/smb/client/dfs_cache.c                          |   2 +-
 include/linux/proc_fs.h                            |  39 +++---
 kernel/configs.c                                   |   2 +-
 kernel/irq/proc.c                                  |   6 +-
 kernel/latencytop.c                                |   2 +-
 kernel/locking/lockdep_proc.c                      |   2 +-
 kernel/profile.c                                   |   4 +-
 kernel/sched/psi.c                                 |  12 +-
 lib/dynamic_debug.c                                |   2 +-
 mm/alloc_tag.c                                     |   2 +-
 mm/swapfile.c                                      |   2 +-
 net/atm/proc.c                                     |   2 +-
 net/core/pktgen.c                                  |   6 +-
 net/netfilter/xt_recent.c                          |   2 +-
 net/sunrpc/auth_gss/svcauth_gss.c                  |   6 +-
 net/sunrpc/cache.c                                 |  10 +-
 samples/kfifo/bytestream-example.c                 |   4 +-
 samples/kfifo/inttype-example.c                    |   4 +-
 samples/kfifo/record-example.c                     |   4 +-
 sound/core/info.c                                  |   8 +-
 71 files changed, 242 insertions(+), 328 deletions(-)
---
base-commit: 6628e7d4c6b25c8d18f1345e3a20d21829aae7e4
change-id: 20261030-work-procfs-cleanup-1694f71bb156
prerequisite-change-id: 20261101-work-procfs-arch-8d4ade48be31:v2
prerequisite-patch-id: a81e8b894107e48d607f8257d2c9f56e0dd6f400
prerequisite-patch-id: 7edf7ca7ecd32c9e09085e4b65922af10097beaa
prerequisite-patch-id: 81f6893f79b4236637675553298a6f2892b603f3
prerequisite-patch-id: 598c2b1a389f47adcac88ebcf1c9f74e2511fbab
prerequisite-patch-id: 6f5a2172dacc5ff2491fa9832c48ccd0e1ce1eda
prerequisite-patch-id: 8947af6490288e4e2a3b2bf8844a974bedb1d975
prerequisite-patch-id: 8cbe756286fd95967d31b0c46cacfeb05f0a2c6b
prerequisite-patch-id: 3fa159f2b6ccd0ac51a2662e4eec5587ec18de89
prerequisite-patch-id: bfb4e4ffe9631cb58015fefe6bd3698cd53e2244
prerequisite-patch-id: 56ff6667a57a962264c07c0227c61aa2f1f4c22c
prerequisite-patch-id: bc506323e29944ec0c29eae84950c706a8592042
prerequisite-patch-id: 326c0ebb5accf0f40cbee1323fb4c3378f5be154
prerequisite-patch-id: d6eaf7690a54a0dfda7500936a048b769fa265dd
prerequisite-patch-id: 7c7b2535642b4d388e13eab518cbe0f9550eb1e6
prerequisite-patch-id: 0474af12959624910718795bf86684383664c685
prerequisite-patch-id: f6d4191e23c22e2d2cc90cc5d04781f913e98a8e
prerequisite-patch-id: b0031a7c4855b7ec38259c59f30f65101a8fc4b5
prerequisite-patch-id: 0b7f226abf2b9ff41873a1aa55cf97747647d56b
prerequisite-patch-id: f63e345f897619af54813958046617c655fb7daf
prerequisite-patch-id: c0e21e762a2960e3324c5ab04634a7035e515fa6
prerequisite-patch-id: fd59c71eadd8f39c58b3baea93567bc093bc9b0e
prerequisite-patch-id: 5d52cc8a5c73e4c5ba16b8e24f51408c17583bf9
prerequisite-patch-id: 1f9179284e2f3314d4b46ac5e989089a21c7576c
prerequisite-patch-id: 10397bbf696bee16dc71eb79fff6c5e73842bcbc
prerequisite-patch-id: 9b44279dcf08912238d2f6438a3328a778a79a0c
prerequisite-patch-id: 16854b621a3a71dfc365aaf7abaa7f65adfe9f7e
prerequisite-patch-id: ca42eea21fae1fd1cd3518ab057c74b61ffd68fe
prerequisite-patch-id: 23255dc2be76b0479c083dbd4c897bfbb533aed5
prerequisite-patch-id: 82129c687ebf0a41b369893b92f2c038420ab801
prerequisite-patch-id: 56ad57a99a5bda075a9f4e844368974296744934
prerequisite-patch-id: 288b3cbaa11e01a778cc3d7beb6c0549aacf59f2
prerequisite-patch-id: a163b1549608652bfa5bd9ff93efa55b541010c4
prerequisite-patch-id: 43b92dfc1a98fbf0d14597a3e3ae99972844773b
prerequisite-patch-id: 19c12bc6e3fbed35acc1f657196b1a997f48cdfe
prerequisite-patch-id: 5800c3076694bad719954b2ad4d7448c6e013bfd
prerequisite-patch-id: 2a2f63d8843b159594b9eee6ddea028ce76a6270
prerequisite-patch-id: 40a1951d57906c4a1b98a4bd96a814b80339b9c5
prerequisite-patch-id: e2141077e69f20a2b27fab69c8d61d0686682f53
prerequisite-patch-id: c4d6018c26c40dc549d88330d23ce48f872c2b7f
prerequisite-patch-id: 6de8ec17746031bc6d1d9ac262c5be0f905fcd79
prerequisite-patch-id: b87bcb167884605bff1fd0f2ed8a88942d07efd5
prerequisite-patch-id: cfa9a8b4c67e20cfd22d77035bfd21ee96ab3298
prerequisite-patch-id: abf3482ed2399b7b2e1ee72e937af05bb9200667
prerequisite-patch-id: 02c175b2dee565a85b3308ecf2ec8e3c9a029e0f
prerequisite-patch-id: d58c239fba616b366a725de6acba3f88734156d0
prerequisite-patch-id: dbe02fe3f784776fda5e7ae99f077bef0cd4b48d
prerequisite-patch-id: 53edc9a95afff57c4acba40095a8054924261ea2
prerequisite-patch-id: 5348d8957eb7eae7430ca8b101aa84ce77d3aa4f
prerequisite-patch-id: 36c96d781e2dd80b20932667bbe6e7fd14976069
prerequisite-patch-id: efeb2d6f7df71d5dede2c1d12fe999a28e38aab9
prerequisite-patch-id: 17f95c7fdf0bdc7c8aaaf7883bff1dcc19a0f529
prerequisite-patch-id: 117db27dcdef433de7c6be5e95973cac1e373927
prerequisite-patch-id: a0844aa26ffb65ccb362b88ef6c2f4758e15edbf
prerequisite-patch-id: 9c64355dfde62e399f2717d9208c4607834d4650
prerequisite-patch-id: 9644739854ddfe2876f17fda8727fd5119255957
prerequisite-patch-id: c61bba24c035f79a2a32a80ace0924ab58e97f46
prerequisite-patch-id: 143fb91bddf33068b6ee11e205818c4c2815e23d
prerequisite-patch-id: 9ce9be2ff05250f92d945c0084f4bb31d3d0b27d
prerequisite-patch-id: aee0961341523547095a43ae298cb8b551302f10
prerequisite-patch-id: 2f0fdb970ddd760d85ff5d2caad0b96348270182
prerequisite-patch-id: f2aa468ff5cbb1cabab3f70e1b8eeee0286cfb4a
prerequisite-patch-id: 5555895bcbca4d7c9888ecc9e82c0e4d76da8f40
prerequisite-patch-id: 487141c49e2548310bfb6c2a0964a78f08b285a9
prerequisite-patch-id: c3d3008819fa5629a18142ec9ba6d7024ade7fdb
prerequisite-patch-id: ca587c976690ac16e3d759fccab2116fef0508e8
prerequisite-patch-id: 9423f410b99853693db06c29f12f1c08278b050d
prerequisite-patch-id: e269815617a6324615a38916b8886f99d98c641e
prerequisite-patch-id: 3d24be1897a624d519ef144801f76d152c7528a9
prerequisite-patch-id: 1ea3fc8319d9012faaf3a182ac61d5da89aafdb7
prerequisite-patch-id: 7547b4e2c1b3588acf6caf90cc01fe7884fdb6bd
prerequisite-patch-id: 695d325349ebeb89bf0ea24bcf0c4f1c4edacab5
prerequisite-patch-id: e33502a202979aba0d6fdaf196e8471d906992a1
prerequisite-patch-id: 47bfe4f07677ad75fe8d9accc8923a1cbdf3afa6
prerequisite-patch-id: 9fc0739226572203fcb36f2c271be7b27f405ef2
prerequisite-patch-id: 504e13cb7af5da6f3c8503f9336116ddd6ee9fc0
prerequisite-patch-id: 079f5420c7c6660679b25a93ab2912b42af19d6d
prerequisite-patch-id: 717bfde0d4141e875562d62b0e3c22d687517462
prerequisite-patch-id: 3e465d93cacbb875c5508b106bcaae53665de29e
prerequisite-patch-id: daa2e27b0b2dbf5ac04776bf03b0953d9f10bcbb
prerequisite-patch-id: a293472d78b43026dacbfe22a34ba1f8f2626e63
prerequisite-patch-id: f0a09eebade394217c88730e272d7bd33616f982
prerequisite-patch-id: 8471e839ad125d2f4cd9072486ae7da137619c1b
prerequisite-patch-id: 16433e5bde53510f9e6b7e04db2279bd0a8f63f5
prerequisite-patch-id: 03d349761a5a56d223067b051b1a38d594006ae2
prerequisite-patch-id: ffc6f41124e66357a7872aa1553e5404a7d48a55
prerequisite-patch-id: 901a0c1b4c2da010722471826fbfc51402ab8573
prerequisite-patch-id: 1204b4883154dea8cb7d93efadb9f49e70ecd7a8
prerequisite-patch-id: d2762d5dd1254bf7cf89a16b317b7b421718935f
prerequisite-patch-id: d1337f7a08fd4758a94bc5b2faeb30cbad1fe9cf
prerequisite-patch-id: a1d46785e75f0ec87cd12807cb57adc869a7f6a8
prerequisite-patch-id: 44c5d2365c5237b44a0162be9e73dcb392deab2c
prerequisite-patch-id: ad7ca39e7946dbf9e9ed4677b577bb5efad15af5
prerequisite-patch-id: 3984bbb1dbd74d87215a789483a75e968e81b453
prerequisite-patch-id: 48c81c042a9252249b32613e94f6bbca2fcb64b5
prerequisite-patch-id: 4d97d31af7bca868bf68a61fe7825dcbd7cc500b
prerequisite-patch-id: 227908b78f668bc6301cfa2217fa581471176b0f
prerequisite-patch-id: b4cbc3d04d64c061cc9cf2d22412ab5b4b37baaa
prerequisite-change-id: 20261101-work-procfs-drivers-58cd83649658:v2
prerequisite-patch-id: a81e8b894107e48d607f8257d2c9f56e0dd6f400
prerequisite-patch-id: 7edf7ca7ecd32c9e09085e4b65922af10097beaa
prerequisite-patch-id: 81f6893f79b4236637675553298a6f2892b603f3
prerequisite-patch-id: 598c2b1a389f47adcac88ebcf1c9f74e2511fbab
prerequisite-patch-id: 6f5a2172dacc5ff2491fa9832c48ccd0e1ce1eda
prerequisite-patch-id: 8947af6490288e4e2a3b2bf8844a974bedb1d975
prerequisite-patch-id: 8cbe756286fd95967d31b0c46cacfeb05f0a2c6b
prerequisite-patch-id: 3fa159f2b6ccd0ac51a2662e4eec5587ec18de89
prerequisite-patch-id: bfb4e4ffe9631cb58015fefe6bd3698cd53e2244
prerequisite-patch-id: 56ff6667a57a962264c07c0227c61aa2f1f4c22c
prerequisite-patch-id: bc506323e29944ec0c29eae84950c706a8592042
prerequisite-patch-id: 326c0ebb5accf0f40cbee1323fb4c3378f5be154
prerequisite-patch-id: d6eaf7690a54a0dfda7500936a048b769fa265dd
prerequisite-patch-id: 7c7b2535642b4d388e13eab518cbe0f9550eb1e6
prerequisite-patch-id: 0474af12959624910718795bf86684383664c685
prerequisite-patch-id: f6d4191e23c22e2d2cc90cc5d04781f913e98a8e
prerequisite-patch-id: b0031a7c4855b7ec38259c59f30f65101a8fc4b5
prerequisite-patch-id: 0b7f226abf2b9ff41873a1aa55cf97747647d56b
prerequisite-patch-id: f63e345f897619af54813958046617c655fb7daf
prerequisite-patch-id: c0e21e762a2960e3324c5ab04634a7035e515fa6
prerequisite-patch-id: fd59c71eadd8f39c58b3baea93567bc093bc9b0e
prerequisite-patch-id: 5d52cc8a5c73e4c5ba16b8e24f51408c17583bf9
prerequisite-patch-id: 1f9179284e2f3314d4b46ac5e989089a21c7576c
prerequisite-patch-id: 10397bbf696bee16dc71eb79fff6c5e73842bcbc
prerequisite-patch-id: 9b44279dcf08912238d2f6438a3328a778a79a0c
prerequisite-patch-id: 16854b621a3a71dfc365aaf7abaa7f65adfe9f7e
prerequisite-patch-id: ca42eea21fae1fd1cd3518ab057c74b61ffd68fe
prerequisite-patch-id: 23255dc2be76b0479c083dbd4c897bfbb533aed5
prerequisite-patch-id: 82129c687ebf0a41b369893b92f2c038420ab801
prerequisite-patch-id: 56ad57a99a5bda075a9f4e844368974296744934
prerequisite-patch-id: 288b3cbaa11e01a778cc3d7beb6c0549aacf59f2
prerequisite-patch-id: a163b1549608652bfa5bd9ff93efa55b541010c4
prerequisite-patch-id: 43b92dfc1a98fbf0d14597a3e3ae99972844773b
prerequisite-patch-id: 19c12bc6e3fbed35acc1f657196b1a997f48cdfe
prerequisite-patch-id: 5800c3076694bad719954b2ad4d7448c6e013bfd
prerequisite-patch-id: 2a2f63d8843b159594b9eee6ddea028ce76a6270
prerequisite-patch-id: 40a1951d57906c4a1b98a4bd96a814b80339b9c5
prerequisite-patch-id: e2141077e69f20a2b27fab69c8d61d0686682f53
prerequisite-patch-id: c4d6018c26c40dc549d88330d23ce48f872c2b7f
prerequisite-patch-id: 6de8ec17746031bc6d1d9ac262c5be0f905fcd79
prerequisite-patch-id: b87bcb167884605bff1fd0f2ed8a88942d07efd5
prerequisite-patch-id: cfa9a8b4c67e20cfd22d77035bfd21ee96ab3298
prerequisite-patch-id: abf3482ed2399b7b2e1ee72e937af05bb9200667
prerequisite-patch-id: 02c175b2dee565a85b3308ecf2ec8e3c9a029e0f
prerequisite-patch-id: d58c239fba616b366a725de6acba3f88734156d0
prerequisite-patch-id: dbe02fe3f784776fda5e7ae99f077bef0cd4b48d
prerequisite-patch-id: 53edc9a95afff57c4acba40095a8054924261ea2
prerequisite-patch-id: 5348d8957eb7eae7430ca8b101aa84ce77d3aa4f
prerequisite-patch-id: 36c96d781e2dd80b20932667bbe6e7fd14976069
prerequisite-patch-id: efeb2d6f7df71d5dede2c1d12fe999a28e38aab9
prerequisite-patch-id: 17f95c7fdf0bdc7c8aaaf7883bff1dcc19a0f529
prerequisite-patch-id: 117db27dcdef433de7c6be5e95973cac1e373927
prerequisite-patch-id: a0844aa26ffb65ccb362b88ef6c2f4758e15edbf
prerequisite-patch-id: 9c64355dfde62e399f2717d9208c4607834d4650
prerequisite-patch-id: 9644739854ddfe2876f17fda8727fd5119255957
prerequisite-patch-id: c61bba24c035f79a2a32a80ace0924ab58e97f46
prerequisite-patch-id: 143fb91bddf33068b6ee11e205818c4c2815e23d
prerequisite-patch-id: 9ce9be2ff05250f92d945c0084f4bb31d3d0b27d
prerequisite-patch-id: aee0961341523547095a43ae298cb8b551302f10
prerequisite-patch-id: 2f0fdb970ddd760d85ff5d2caad0b96348270182
prerequisite-patch-id: f2aa468ff5cbb1cabab3f70e1b8eeee0286cfb4a
prerequisite-patch-id: 5555895bcbca4d7c9888ecc9e82c0e4d76da8f40
prerequisite-patch-id: 487141c49e2548310bfb6c2a0964a78f08b285a9
prerequisite-patch-id: c3d3008819fa5629a18142ec9ba6d7024ade7fdb
prerequisite-patch-id: ca587c976690ac16e3d759fccab2116fef0508e8
prerequisite-patch-id: 9423f410b99853693db06c29f12f1c08278b050d
prerequisite-patch-id: e269815617a6324615a38916b8886f99d98c641e
prerequisite-patch-id: 3d24be1897a624d519ef144801f76d152c7528a9
prerequisite-patch-id: 1ea3fc8319d9012faaf3a182ac61d5da89aafdb7
prerequisite-patch-id: 7547b4e2c1b3588acf6caf90cc01fe7884fdb6bd
prerequisite-patch-id: 695d325349ebeb89bf0ea24bcf0c4f1c4edacab5
prerequisite-patch-id: e33502a202979aba0d6fdaf196e8471d906992a1
prerequisite-patch-id: 47bfe4f07677ad75fe8d9accc8923a1cbdf3afa6
prerequisite-patch-id: 9fc0739226572203fcb36f2c271be7b27f405ef2
prerequisite-patch-id: 504e13cb7af5da6f3c8503f9336116ddd6ee9fc0
prerequisite-patch-id: 079f5420c7c6660679b25a93ab2912b42af19d6d
prerequisite-patch-id: 717bfde0d4141e875562d62b0e3c22d687517462
prerequisite-patch-id: 3e465d93cacbb875c5508b106bcaae53665de29e
prerequisite-patch-id: daa2e27b0b2dbf5ac04776bf03b0953d9f10bcbb
prerequisite-patch-id: a293472d78b43026dacbfe22a34ba1f8f2626e63
prerequisite-patch-id: f0a09eebade394217c88730e272d7bd33616f982
prerequisite-patch-id: 8471e839ad125d2f4cd9072486ae7da137619c1b
prerequisite-patch-id: 16433e5bde53510f9e6b7e04db2279bd0a8f63f5
prerequisite-patch-id: 03d349761a5a56d223067b051b1a38d594006ae2
prerequisite-patch-id: ffc6f41124e66357a7872aa1553e5404a7d48a55
prerequisite-patch-id: 901a0c1b4c2da010722471826fbfc51402ab8573
prerequisite-patch-id: 1204b4883154dea8cb7d93efadb9f49e70ecd7a8
prerequisite-patch-id: d2762d5dd1254bf7cf89a16b317b7b421718935f
prerequisite-patch-id: d1337f7a08fd4758a94bc5b2faeb30cbad1fe9cf
prerequisite-patch-id: a1d46785e75f0ec87cd12807cb57adc869a7f6a8
prerequisite-patch-id: 44c5d2365c5237b44a0162be9e73dcb392deab2c
prerequisite-patch-id: ad7ca39e7946dbf9e9ed4677b577bb5efad15af5
prerequisite-patch-id: 3984bbb1dbd74d87215a789483a75e968e81b453
prerequisite-patch-id: 48c81c042a9252249b32613e94f6bbca2fcb64b5
prerequisite-patch-id: 4d97d31af7bca868bf68a61fe7825dcbd7cc500b
prerequisite-patch-id: 227908b78f668bc6301cfa2217fa581471176b0f
prerequisite-patch-id: b4cbc3d04d64c061cc9cf2d22412ab5b4b37baaa
prerequisite-patch-id: fd779ec9acd1cd56b7eb9176cd0a10a548133f0c
prerequisite-patch-id: 5c61093340a745890222477d54f21e1121643c95
prerequisite-patch-id: 1199e9ee338002117fbe257118ff264e64eec0bb
prerequisite-patch-id: 08be0388a5aafb66919d0d678380c33f092738ce
prerequisite-patch-id: f98799e2973376543e67ae7a93ab62a20aa29564
prerequisite-patch-id: f670bed1eba8e1440bbfed164fb0c367f248e231
prerequisite-patch-id: f87d26787b356816be42fe8452d0262857d347b9
prerequisite-patch-id: 88a5543ceb70d27bd05b718480334d0a28133697
prerequisite-patch-id: 544f65704decf1a67848c8dc68ac60c5b76cdb81
prerequisite-patch-id: f36fad7a6eb02bf1b3c1171a61cbb854794bdf63
prerequisite-patch-id: 03a4a6747171c25f622df537a7608a4058acfc2c
prerequisite-patch-id: 3a87a035ec7c5f8773a6a7e5085ff19228263b2d
prerequisite-patch-id: 8483765548e3cdbd16e0a9ef44e9c60941611b12
prerequisite-patch-id: 6643c2dbd00ab86e742ef5a15f4d23c039575f07
prerequisite-patch-id: 9f288cab3b89ff67865b4e20c7b7f6f3835cec6f
prerequisite-patch-id: 6c8bae764061f224f8bf6bfb0a58b44689d1fb85
prerequisite-patch-id: c2d5675bad1219323ceb4f7c382dea8ef654256f
prerequisite-patch-id: f5fd02ee0a5960d146eba2f57ecf9ccb15a1b216
prerequisite-patch-id: d12cfa9299bb33218551b98efc8d2af8bb2ef321
prerequisite-patch-id: 889b86d3e246e3d6b4cd71e7e77571bc2bbaf45e
prerequisite-patch-id: a0f908f1aac5152622736d7589549682aabbdc72
prerequisite-patch-id: 92f4f7c0df22746ab9dcf4c84bc14f25f5043dc2
prerequisite-patch-id: 172d56f9145b9ec517bb8ff3e33b33c6a2c39786
prerequisite-patch-id: f374a92609437c1cd7bf2e247c287f126d337a02
prerequisite-patch-id: 2d540c940f6a6e05946e9ba2ca12a3fb28135e8c
prerequisite-patch-id: 24b5f0ec2a4f445e827caf1f4a95a80b0a9f7034
prerequisite-change-id: 20261101-work-procfs-fs-41f9fdc489cb:v2
prerequisite-patch-id: a81e8b894107e48d607f8257d2c9f56e0dd6f400
prerequisite-patch-id: 7edf7ca7ecd32c9e09085e4b65922af10097beaa
prerequisite-patch-id: 81f6893f79b4236637675553298a6f2892b603f3
prerequisite-patch-id: 598c2b1a389f47adcac88ebcf1c9f74e2511fbab
prerequisite-patch-id: 6f5a2172dacc5ff2491fa9832c48ccd0e1ce1eda
prerequisite-patch-id: 8947af6490288e4e2a3b2bf8844a974bedb1d975
prerequisite-patch-id: 8cbe756286fd95967d31b0c46cacfeb05f0a2c6b
prerequisite-patch-id: 3fa159f2b6ccd0ac51a2662e4eec5587ec18de89
prerequisite-patch-id: bfb4e4ffe9631cb58015fefe6bd3698cd53e2244
prerequisite-patch-id: 56ff6667a57a962264c07c0227c61aa2f1f4c22c
prerequisite-patch-id: bc506323e29944ec0c29eae84950c706a8592042
prerequisite-patch-id: 326c0ebb5accf0f40cbee1323fb4c3378f5be154
prerequisite-patch-id: d6eaf7690a54a0dfda7500936a048b769fa265dd
prerequisite-patch-id: 7c7b2535642b4d388e13eab518cbe0f9550eb1e6
prerequisite-patch-id: 0474af12959624910718795bf86684383664c685
prerequisite-patch-id: f6d4191e23c22e2d2cc90cc5d04781f913e98a8e
prerequisite-patch-id: b0031a7c4855b7ec38259c59f30f65101a8fc4b5
prerequisite-patch-id: 0b7f226abf2b9ff41873a1aa55cf97747647d56b
prerequisite-patch-id: f63e345f897619af54813958046617c655fb7daf
prerequisite-patch-id: c0e21e762a2960e3324c5ab04634a7035e515fa6
prerequisite-patch-id: fd59c71eadd8f39c58b3baea93567bc093bc9b0e
prerequisite-patch-id: 5d52cc8a5c73e4c5ba16b8e24f51408c17583bf9
prerequisite-patch-id: 1f9179284e2f3314d4b46ac5e989089a21c7576c
prerequisite-patch-id: 10397bbf696bee16dc71eb79fff6c5e73842bcbc
prerequisite-patch-id: 9b44279dcf08912238d2f6438a3328a778a79a0c
prerequisite-patch-id: 16854b621a3a71dfc365aaf7abaa7f65adfe9f7e
prerequisite-patch-id: ca42eea21fae1fd1cd3518ab057c74b61ffd68fe
prerequisite-patch-id: 23255dc2be76b0479c083dbd4c897bfbb533aed5
prerequisite-patch-id: 82129c687ebf0a41b369893b92f2c038420ab801
prerequisite-patch-id: 56ad57a99a5bda075a9f4e844368974296744934
prerequisite-patch-id: 288b3cbaa11e01a778cc3d7beb6c0549aacf59f2
prerequisite-patch-id: a163b1549608652bfa5bd9ff93efa55b541010c4
prerequisite-patch-id: 43b92dfc1a98fbf0d14597a3e3ae99972844773b
prerequisite-patch-id: 19c12bc6e3fbed35acc1f657196b1a997f48cdfe
prerequisite-patch-id: 5800c3076694bad719954b2ad4d7448c6e013bfd
prerequisite-patch-id: 2a2f63d8843b159594b9eee6ddea028ce76a6270
prerequisite-patch-id: 40a1951d57906c4a1b98a4bd96a814b80339b9c5
prerequisite-patch-id: e2141077e69f20a2b27fab69c8d61d0686682f53
prerequisite-patch-id: c4d6018c26c40dc549d88330d23ce48f872c2b7f
prerequisite-patch-id: 6de8ec17746031bc6d1d9ac262c5be0f905fcd79
prerequisite-patch-id: b87bcb167884605bff1fd0f2ed8a88942d07efd5
prerequisite-patch-id: cfa9a8b4c67e20cfd22d77035bfd21ee96ab3298
prerequisite-patch-id: abf3482ed2399b7b2e1ee72e937af05bb9200667
prerequisite-patch-id: 02c175b2dee565a85b3308ecf2ec8e3c9a029e0f
prerequisite-patch-id: d58c239fba616b366a725de6acba3f88734156d0
prerequisite-patch-id: dbe02fe3f784776fda5e7ae99f077bef0cd4b48d
prerequisite-patch-id: 53edc9a95afff57c4acba40095a8054924261ea2
prerequisite-patch-id: 5348d8957eb7eae7430ca8b101aa84ce77d3aa4f
prerequisite-patch-id: 36c96d781e2dd80b20932667bbe6e7fd14976069
prerequisite-patch-id: efeb2d6f7df71d5dede2c1d12fe999a28e38aab9
prerequisite-patch-id: 17f95c7fdf0bdc7c8aaaf7883bff1dcc19a0f529
prerequisite-patch-id: 117db27dcdef433de7c6be5e95973cac1e373927
prerequisite-patch-id: a0844aa26ffb65ccb362b88ef6c2f4758e15edbf
prerequisite-patch-id: 9c64355dfde62e399f2717d9208c4607834d4650
prerequisite-patch-id: 9644739854ddfe2876f17fda8727fd5119255957
prerequisite-patch-id: c61bba24c035f79a2a32a80ace0924ab58e97f46
prerequisite-patch-id: 143fb91bddf33068b6ee11e205818c4c2815e23d
prerequisite-patch-id: 9ce9be2ff05250f92d945c0084f4bb31d3d0b27d
prerequisite-patch-id: aee0961341523547095a43ae298cb8b551302f10
prerequisite-patch-id: 2f0fdb970ddd760d85ff5d2caad0b96348270182
prerequisite-patch-id: f2aa468ff5cbb1cabab3f70e1b8eeee0286cfb4a
prerequisite-patch-id: 5555895bcbca4d7c9888ecc9e82c0e4d76da8f40
prerequisite-patch-id: 487141c49e2548310bfb6c2a0964a78f08b285a9
prerequisite-patch-id: c3d3008819fa5629a18142ec9ba6d7024ade7fdb
prerequisite-patch-id: ca587c976690ac16e3d759fccab2116fef0508e8
prerequisite-patch-id: 9423f410b99853693db06c29f12f1c08278b050d
prerequisite-patch-id: e269815617a6324615a38916b8886f99d98c641e
prerequisite-patch-id: 3d24be1897a624d519ef144801f76d152c7528a9
prerequisite-patch-id: 1ea3fc8319d9012faaf3a182ac61d5da89aafdb7
prerequisite-patch-id: 7547b4e2c1b3588acf6caf90cc01fe7884fdb6bd
prerequisite-patch-id: 695d325349ebeb89bf0ea24bcf0c4f1c4edacab5
prerequisite-patch-id: e33502a202979aba0d6fdaf196e8471d906992a1
prerequisite-patch-id: 47bfe4f07677ad75fe8d9accc8923a1cbdf3afa6
prerequisite-patch-id: 9fc0739226572203fcb36f2c271be7b27f405ef2
prerequisite-patch-id: 504e13cb7af5da6f3c8503f9336116ddd6ee9fc0
prerequisite-patch-id: 079f5420c7c6660679b25a93ab2912b42af19d6d
prerequisite-patch-id: 717bfde0d4141e875562d62b0e3c22d687517462
prerequisite-patch-id: 3e465d93cacbb875c5508b106bcaae53665de29e
prerequisite-patch-id: daa2e27b0b2dbf5ac04776bf03b0953d9f10bcbb
prerequisite-patch-id: a293472d78b43026dacbfe22a34ba1f8f2626e63
prerequisite-patch-id: f0a09eebade394217c88730e272d7bd33616f982
prerequisite-patch-id: 8471e839ad125d2f4cd9072486ae7da137619c1b
prerequisite-patch-id: 16433e5bde53510f9e6b7e04db2279bd0a8f63f5
prerequisite-patch-id: 03d349761a5a56d223067b051b1a38d594006ae2
prerequisite-patch-id: ffc6f41124e66357a7872aa1553e5404a7d48a55
prerequisite-patch-id: 901a0c1b4c2da010722471826fbfc51402ab8573
prerequisite-patch-id: 1204b4883154dea8cb7d93efadb9f49e70ecd7a8
prerequisite-patch-id: d2762d5dd1254bf7cf89a16b317b7b421718935f
prerequisite-patch-id: d1337f7a08fd4758a94bc5b2faeb30cbad1fe9cf
prerequisite-patch-id: a1d46785e75f0ec87cd12807cb57adc869a7f6a8
prerequisite-patch-id: 44c5d2365c5237b44a0162be9e73dcb392deab2c
prerequisite-patch-id: ad7ca39e7946dbf9e9ed4677b577bb5efad15af5
prerequisite-patch-id: 3984bbb1dbd74d87215a789483a75e968e81b453
prerequisite-patch-id: 48c81c042a9252249b32613e94f6bbca2fcb64b5
prerequisite-patch-id: 4d97d31af7bca868bf68a61fe7825dcbd7cc500b
prerequisite-patch-id: 227908b78f668bc6301cfa2217fa581471176b0f
prerequisite-patch-id: b4cbc3d04d64c061cc9cf2d22412ab5b4b37baaa
prerequisite-patch-id: fd779ec9acd1cd56b7eb9176cd0a10a548133f0c
prerequisite-patch-id: 5c61093340a745890222477d54f21e1121643c95
prerequisite-patch-id: 1199e9ee338002117fbe257118ff264e64eec0bb
prerequisite-patch-id: 08be0388a5aafb66919d0d678380c33f092738ce
prerequisite-patch-id: f98799e2973376543e67ae7a93ab62a20aa29564
prerequisite-patch-id: f670bed1eba8e1440bbfed164fb0c367f248e231
prerequisite-patch-id: f87d26787b356816be42fe8452d0262857d347b9
prerequisite-patch-id: 88a5543ceb70d27bd05b718480334d0a28133697
prerequisite-patch-id: 544f65704decf1a67848c8dc68ac60c5b76cdb81
prerequisite-patch-id: f36fad7a6eb02bf1b3c1171a61cbb854794bdf63
prerequisite-patch-id: 03a4a6747171c25f622df537a7608a4058acfc2c
prerequisite-patch-id: 3a87a035ec7c5f8773a6a7e5085ff19228263b2d
prerequisite-patch-id: 8483765548e3cdbd16e0a9ef44e9c60941611b12
prerequisite-patch-id: 6643c2dbd00ab86e742ef5a15f4d23c039575f07
prerequisite-patch-id: 9f288cab3b89ff67865b4e20c7b7f6f3835cec6f
prerequisite-patch-id: 6c8bae764061f224f8bf6bfb0a58b44689d1fb85
prerequisite-patch-id: c2d5675bad1219323ceb4f7c382dea8ef654256f
prerequisite-patch-id: f5fd02ee0a5960d146eba2f57ecf9ccb15a1b216
prerequisite-patch-id: d12cfa9299bb33218551b98efc8d2af8bb2ef321
prerequisite-patch-id: 889b86d3e246e3d6b4cd71e7e77571bc2bbaf45e
prerequisite-patch-id: a0f908f1aac5152622736d7589549682aabbdc72
prerequisite-patch-id: 92f4f7c0df22746ab9dcf4c84bc14f25f5043dc2
prerequisite-patch-id: 172d56f9145b9ec517bb8ff3e33b33c6a2c39786
prerequisite-patch-id: f374a92609437c1cd7bf2e247c287f126d337a02
prerequisite-patch-id: 2d540c940f6a6e05946e9ba2ca12a3fb28135e8c
prerequisite-patch-id: 24b5f0ec2a4f445e827caf1f4a95a80b0a9f7034
prerequisite-patch-id: e1136dd06b641700522373064fc4f0b8988019d2
prerequisite-patch-id: 1f93c44de1de16d56b63f242e11c61eb99fb839e
prerequisite-patch-id: 9e05d183b1de52caab2cfdfc3ddf204626166018
prerequisite-patch-id: f5e3b4966dc89516136a95cd4cc112a247737306
prerequisite-patch-id: a6e9771994c9e7839f6346ce84b88aa76b1fbb94
prerequisite-patch-id: 5cdbf669ab8cb5aae9695872b95cedcc895e8920
prerequisite-patch-id: 1181569f72ebcfd92fc854891a4cab295c99fd94
prerequisite-patch-id: 51fef3e3ccf3c0de31f96ace299dc6d1960af10b
prerequisite-patch-id: 2c3465f99c412708e4dd74d08a59c584d38cd011
prerequisite-patch-id: 4c2dd5a6b6956f87252fa471bfbdbec2f93e261f
prerequisite-patch-id: 637fd7a493983a181121f23dd2a9894bb941ea6e
prerequisite-patch-id: 7922f04bbdfc10776b16363f2414a179a168842b
prerequisite-patch-id: fbeeb1ac52cfcbd92b9670b4e69b948e80c874b6
prerequisite-patch-id: 76ce3f750a3c747b6dbbe4fe8dfca721504ff9e7
prerequisite-patch-id: 99e82aa0b1df251a7d4568cdfa605589cd726f02
prerequisite-patch-id: bf20bda16cfcdadcde5c4a22b8020fa1525c206b
prerequisite-patch-id: 7d31311fd97ddb0b2833c153f22855a39516be16
prerequisite-patch-id: ab46e417566b7997d43cc540d670892ffa186526
prerequisite-patch-id: a1a7ca09cabb1f3bde983a8f249865cfb33ffba9
prerequisite-patch-id: 5d507b2ac0f54617dd7bcc0ebbe003696809cbfe
prerequisite-patch-id: 30b8a6a426dd7b9f466bde876a813a4e27c4a284
prerequisite-patch-id: 95ece6bf7b926859312be956bb9b0ba7bf1d274a
prerequisite-patch-id: 4a896ec0ba4ac506b1f6a010a05f703f1bf888b8
prerequisite-patch-id: 5914904497e4739e4e94d391968d547b375c4def
prerequisite-patch-id: f98a02b2dae4ad56aa7d11de0361ff86b1b60846
prerequisite-patch-id: c4ba3c61e396328d84731308a7fa49348191f2a2
prerequisite-patch-id: 1b836097aa8c6e35ca7a9f5cbb0aafab59153720
prerequisite-patch-id: a4ff1666fad32f9037d926cb5e37b338d2379d61
prerequisite-patch-id: fa65e32038043b8430248870d256e3eaa47f4d34
prerequisite-patch-id: 9a278cc30fac355264a1fd2d9739ebbfb8474b04
prerequisite-change-id: 20261101-work-procfs-net-bc8b21e3eff0:v2
prerequisite-patch-id: a81e8b894107e48d607f8257d2c9f56e0dd6f400
prerequisite-patch-id: 7edf7ca7ecd32c9e09085e4b65922af10097beaa
prerequisite-patch-id: 81f6893f79b4236637675553298a6f2892b603f3
prerequisite-patch-id: 598c2b1a389f47adcac88ebcf1c9f74e2511fbab
prerequisite-patch-id: 6f5a2172dacc5ff2491fa9832c48ccd0e1ce1eda
prerequisite-patch-id: 8947af6490288e4e2a3b2bf8844a974bedb1d975
prerequisite-patch-id: 8cbe756286fd95967d31b0c46cacfeb05f0a2c6b
prerequisite-patch-id: 3fa159f2b6ccd0ac51a2662e4eec5587ec18de89
prerequisite-patch-id: bfb4e4ffe9631cb58015fefe6bd3698cd53e2244
prerequisite-patch-id: 56ff6667a57a962264c07c0227c61aa2f1f4c22c
prerequisite-patch-id: bc506323e29944ec0c29eae84950c706a8592042
prerequisite-patch-id: 326c0ebb5accf0f40cbee1323fb4c3378f5be154
prerequisite-patch-id: d6eaf7690a54a0dfda7500936a048b769fa265dd
prerequisite-patch-id: 7c7b2535642b4d388e13eab518cbe0f9550eb1e6
prerequisite-patch-id: 0474af12959624910718795bf86684383664c685
prerequisite-patch-id: f6d4191e23c22e2d2cc90cc5d04781f913e98a8e
prerequisite-patch-id: b0031a7c4855b7ec38259c59f30f65101a8fc4b5
prerequisite-patch-id: 0b7f226abf2b9ff41873a1aa55cf97747647d56b
prerequisite-patch-id: f63e345f897619af54813958046617c655fb7daf
prerequisite-patch-id: c0e21e762a2960e3324c5ab04634a7035e515fa6
prerequisite-patch-id: fd59c71eadd8f39c58b3baea93567bc093bc9b0e
prerequisite-patch-id: 5d52cc8a5c73e4c5ba16b8e24f51408c17583bf9
prerequisite-patch-id: 1f9179284e2f3314d4b46ac5e989089a21c7576c
prerequisite-patch-id: 10397bbf696bee16dc71eb79fff6c5e73842bcbc
prerequisite-patch-id: 9b44279dcf08912238d2f6438a3328a778a79a0c
prerequisite-patch-id: 16854b621a3a71dfc365aaf7abaa7f65adfe9f7e
prerequisite-patch-id: ca42eea21fae1fd1cd3518ab057c74b61ffd68fe
prerequisite-patch-id: 23255dc2be76b0479c083dbd4c897bfbb533aed5
prerequisite-patch-id: 82129c687ebf0a41b369893b92f2c038420ab801
prerequisite-patch-id: 56ad57a99a5bda075a9f4e844368974296744934
prerequisite-patch-id: 288b3cbaa11e01a778cc3d7beb6c0549aacf59f2
prerequisite-patch-id: a163b1549608652bfa5bd9ff93efa55b541010c4
prerequisite-patch-id: 43b92dfc1a98fbf0d14597a3e3ae99972844773b
prerequisite-patch-id: 19c12bc6e3fbed35acc1f657196b1a997f48cdfe
prerequisite-patch-id: 5800c3076694bad719954b2ad4d7448c6e013bfd
prerequisite-patch-id: 2a2f63d8843b159594b9eee6ddea028ce76a6270
prerequisite-patch-id: 40a1951d57906c4a1b98a4bd96a814b80339b9c5
prerequisite-patch-id: e2141077e69f20a2b27fab69c8d61d0686682f53
prerequisite-patch-id: c4d6018c26c40dc549d88330d23ce48f872c2b7f
prerequisite-patch-id: 6de8ec17746031bc6d1d9ac262c5be0f905fcd79
prerequisite-patch-id: b87bcb167884605bff1fd0f2ed8a88942d07efd5
prerequisite-patch-id: cfa9a8b4c67e20cfd22d77035bfd21ee96ab3298
prerequisite-patch-id: abf3482ed2399b7b2e1ee72e937af05bb9200667
prerequisite-patch-id: 02c175b2dee565a85b3308ecf2ec8e3c9a029e0f
prerequisite-patch-id: d58c239fba616b366a725de6acba3f88734156d0
prerequisite-patch-id: dbe02fe3f784776fda5e7ae99f077bef0cd4b48d
prerequisite-patch-id: 53edc9a95afff57c4acba40095a8054924261ea2
prerequisite-patch-id: 5348d8957eb7eae7430ca8b101aa84ce77d3aa4f
prerequisite-patch-id: 36c96d781e2dd80b20932667bbe6e7fd14976069
prerequisite-patch-id: efeb2d6f7df71d5dede2c1d12fe999a28e38aab9
prerequisite-patch-id: 17f95c7fdf0bdc7c8aaaf7883bff1dcc19a0f529
prerequisite-patch-id: 117db27dcdef433de7c6be5e95973cac1e373927
prerequisite-patch-id: a0844aa26ffb65ccb362b88ef6c2f4758e15edbf
prerequisite-patch-id: 9c64355dfde62e399f2717d9208c4607834d4650
prerequisite-patch-id: 9644739854ddfe2876f17fda8727fd5119255957
prerequisite-patch-id: c61bba24c035f79a2a32a80ace0924ab58e97f46
prerequisite-patch-id: 143fb91bddf33068b6ee11e205818c4c2815e23d
prerequisite-patch-id: 9ce9be2ff05250f92d945c0084f4bb31d3d0b27d
prerequisite-patch-id: aee0961341523547095a43ae298cb8b551302f10
prerequisite-patch-id: 2f0fdb970ddd760d85ff5d2caad0b96348270182
prerequisite-patch-id: f2aa468ff5cbb1cabab3f70e1b8eeee0286cfb4a
prerequisite-patch-id: 5555895bcbca4d7c9888ecc9e82c0e4d76da8f40
prerequisite-patch-id: 487141c49e2548310bfb6c2a0964a78f08b285a9
prerequisite-patch-id: c3d3008819fa5629a18142ec9ba6d7024ade7fdb
prerequisite-patch-id: ca587c976690ac16e3d759fccab2116fef0508e8
prerequisite-patch-id: 9423f410b99853693db06c29f12f1c08278b050d
prerequisite-patch-id: e269815617a6324615a38916b8886f99d98c641e
prerequisite-patch-id: 3d24be1897a624d519ef144801f76d152c7528a9
prerequisite-patch-id: 1ea3fc8319d9012faaf3a182ac61d5da89aafdb7
prerequisite-patch-id: 7547b4e2c1b3588acf6caf90cc01fe7884fdb6bd
prerequisite-patch-id: 695d325349ebeb89bf0ea24bcf0c4f1c4edacab5
prerequisite-patch-id: e33502a202979aba0d6fdaf196e8471d906992a1
prerequisite-patch-id: 47bfe4f07677ad75fe8d9accc8923a1cbdf3afa6
prerequisite-patch-id: 9fc0739226572203fcb36f2c271be7b27f405ef2
prerequisite-patch-id: 504e13cb7af5da6f3c8503f9336116ddd6ee9fc0
prerequisite-patch-id: 079f5420c7c6660679b25a93ab2912b42af19d6d
prerequisite-patch-id: 717bfde0d4141e875562d62b0e3c22d687517462
prerequisite-patch-id: 3e465d93cacbb875c5508b106bcaae53665de29e
prerequisite-patch-id: daa2e27b0b2dbf5ac04776bf03b0953d9f10bcbb
prerequisite-patch-id: a293472d78b43026dacbfe22a34ba1f8f2626e63
prerequisite-patch-id: f0a09eebade394217c88730e272d7bd33616f982
prerequisite-patch-id: 8471e839ad125d2f4cd9072486ae7da137619c1b
prerequisite-patch-id: 16433e5bde53510f9e6b7e04db2279bd0a8f63f5
prerequisite-patch-id: 03d349761a5a56d223067b051b1a38d594006ae2
prerequisite-patch-id: ffc6f41124e66357a7872aa1553e5404a7d48a55
prerequisite-patch-id: 901a0c1b4c2da010722471826fbfc51402ab8573
prerequisite-patch-id: 1204b4883154dea8cb7d93efadb9f49e70ecd7a8
prerequisite-patch-id: d2762d5dd1254bf7cf89a16b317b7b421718935f
prerequisite-patch-id: d1337f7a08fd4758a94bc5b2faeb30cbad1fe9cf
prerequisite-patch-id: a1d46785e75f0ec87cd12807cb57adc869a7f6a8
prerequisite-patch-id: 44c5d2365c5237b44a0162be9e73dcb392deab2c
prerequisite-patch-id: ad7ca39e7946dbf9e9ed4677b577bb5efad15af5
prerequisite-patch-id: 3984bbb1dbd74d87215a789483a75e968e81b453
prerequisite-patch-id: 48c81c042a9252249b32613e94f6bbca2fcb64b5
prerequisite-patch-id: 4d97d31af7bca868bf68a61fe7825dcbd7cc500b
prerequisite-patch-id: 227908b78f668bc6301cfa2217fa581471176b0f
prerequisite-patch-id: b4cbc3d04d64c061cc9cf2d22412ab5b4b37baaa
prerequisite-patch-id: fd779ec9acd1cd56b7eb9176cd0a10a548133f0c
prerequisite-patch-id: 5c61093340a745890222477d54f21e1121643c95
prerequisite-patch-id: 1199e9ee338002117fbe257118ff264e64eec0bb
prerequisite-patch-id: 08be0388a5aafb66919d0d678380c33f092738ce
prerequisite-patch-id: f98799e2973376543e67ae7a93ab62a20aa29564
prerequisite-patch-id: f670bed1eba8e1440bbfed164fb0c367f248e231
prerequisite-patch-id: f87d26787b356816be42fe8452d0262857d347b9
prerequisite-patch-id: 88a5543ceb70d27bd05b718480334d0a28133697
prerequisite-patch-id: 544f65704decf1a67848c8dc68ac60c5b76cdb81
prerequisite-patch-id: f36fad7a6eb02bf1b3c1171a61cbb854794bdf63
prerequisite-patch-id: 03a4a6747171c25f622df537a7608a4058acfc2c
prerequisite-patch-id: 3a87a035ec7c5f8773a6a7e5085ff19228263b2d
prerequisite-patch-id: 8483765548e3cdbd16e0a9ef44e9c60941611b12
prerequisite-patch-id: 6643c2dbd00ab86e742ef5a15f4d23c039575f07
prerequisite-patch-id: 9f288cab3b89ff67865b4e20c7b7f6f3835cec6f
prerequisite-patch-id: 6c8bae764061f224f8bf6bfb0a58b44689d1fb85
prerequisite-patch-id: c2d5675bad1219323ceb4f7c382dea8ef654256f
prerequisite-patch-id: f5fd02ee0a5960d146eba2f57ecf9ccb15a1b216
prerequisite-patch-id: d12cfa9299bb33218551b98efc8d2af8bb2ef321
prerequisite-patch-id: 889b86d3e246e3d6b4cd71e7e77571bc2bbaf45e
prerequisite-patch-id: a0f908f1aac5152622736d7589549682aabbdc72
prerequisite-patch-id: 92f4f7c0df22746ab9dcf4c84bc14f25f5043dc2
prerequisite-patch-id: 172d56f9145b9ec517bb8ff3e33b33c6a2c39786
prerequisite-patch-id: f374a92609437c1cd7bf2e247c287f126d337a02
prerequisite-patch-id: 2d540c940f6a6e05946e9ba2ca12a3fb28135e8c
prerequisite-patch-id: 24b5f0ec2a4f445e827caf1f4a95a80b0a9f7034
prerequisite-patch-id: e1136dd06b641700522373064fc4f0b8988019d2
prerequisite-patch-id: 1f93c44de1de16d56b63f242e11c61eb99fb839e
prerequisite-patch-id: 9e05d183b1de52caab2cfdfc3ddf204626166018
prerequisite-patch-id: f5e3b4966dc89516136a95cd4cc112a247737306
prerequisite-patch-id: a6e9771994c9e7839f6346ce84b88aa76b1fbb94
prerequisite-patch-id: 5cdbf669ab8cb5aae9695872b95cedcc895e8920
prerequisite-patch-id: 1181569f72ebcfd92fc854891a4cab295c99fd94
prerequisite-patch-id: 51fef3e3ccf3c0de31f96ace299dc6d1960af10b
prerequisite-patch-id: 2c3465f99c412708e4dd74d08a59c584d38cd011
prerequisite-patch-id: 4c2dd5a6b6956f87252fa471bfbdbec2f93e261f
prerequisite-patch-id: 637fd7a493983a181121f23dd2a9894bb941ea6e
prerequisite-patch-id: 7922f04bbdfc10776b16363f2414a179a168842b
prerequisite-patch-id: fbeeb1ac52cfcbd92b9670b4e69b948e80c874b6
prerequisite-patch-id: 76ce3f750a3c747b6dbbe4fe8dfca721504ff9e7
prerequisite-patch-id: 99e82aa0b1df251a7d4568cdfa605589cd726f02
prerequisite-patch-id: bf20bda16cfcdadcde5c4a22b8020fa1525c206b
prerequisite-patch-id: 7d31311fd97ddb0b2833c153f22855a39516be16
prerequisite-patch-id: ab46e417566b7997d43cc540d670892ffa186526
prerequisite-patch-id: a1a7ca09cabb1f3bde983a8f249865cfb33ffba9
prerequisite-patch-id: 5d507b2ac0f54617dd7bcc0ebbe003696809cbfe
prerequisite-patch-id: 30b8a6a426dd7b9f466bde876a813a4e27c4a284
prerequisite-patch-id: 95ece6bf7b926859312be956bb9b0ba7bf1d274a
prerequisite-patch-id: 4a896ec0ba4ac506b1f6a010a05f703f1bf888b8
prerequisite-patch-id: 5914904497e4739e4e94d391968d547b375c4def
prerequisite-patch-id: f98a02b2dae4ad56aa7d11de0361ff86b1b60846
prerequisite-patch-id: c4ba3c61e396328d84731308a7fa49348191f2a2
prerequisite-patch-id: 1b836097aa8c6e35ca7a9f5cbb0aafab59153720
prerequisite-patch-id: a4ff1666fad32f9037d926cb5e37b338d2379d61
prerequisite-patch-id: fa65e32038043b8430248870d256e3eaa47f4d34
prerequisite-patch-id: 9a278cc30fac355264a1fd2d9739ebbfb8474b04
prerequisite-patch-id: ed86b546d44c9d5612a132b8f188a1727bf20140
prerequisite-patch-id: 3531ac7c29c6d31f5c4d7830eec493700c7817cc
prerequisite-patch-id: d5636a3c6c5d806cac00791c49bf3703b2a61c7d
prerequisite-patch-id: a789b6da4762c80e4e223d6f20db32a4812cd87b
prerequisite-patch-id: 96c2d266089780f6a0b07f54da812b87b5749abd
prerequisite-patch-id: 51e5bdc34987e2266e8801368e622566ccf20968
prerequisite-patch-id: 48b7e3fe2d9ce6c61b8b7d34ad26ecf0bfcf53cc
prerequisite-patch-id: f39c6af65cc5b209517939533a7cb9cc1ee03da0
prerequisite-patch-id: 9e2cccf47b8c293ebef941d1268956901f1dd323
prerequisite-patch-id: 3d0d826b755fabb6f5ceef6f74ca50777ae1c64c
prerequisite-patch-id: 0126190ba10aa140572e0a652c91d1de7fae0106
prerequisite-patch-id: c0de7f6bcf931394d46239405296ce7008f7a095
prerequisite-patch-id: b8c2dd4243818acc67a9e3917c528a4f6decb498

