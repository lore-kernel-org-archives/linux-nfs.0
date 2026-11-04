Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.remote-ip=100.103.45.18
ARC-Seal: i=1; d=subspace.kernel.org; s=arc20261015; a=rsa-sha256; cv=none;
	t=1793813319;
	b=Kh1Wq7Bov0KJi1pjVtfs02txVSqghoY7s9QwvjnNLBWksbly5QYYolAm3ISCXWr6wBGH
	 zcG2vYPOmFQPvWbUJsI/zXaMik7s266blZB6JeQWsUnwajm8qtRp5j/B+hjwHyNgrqoMv
	 yrjJfpIOYPAdVm1niuS0rb26DEjMs/n/fRW4rcGCqKqXxzdSxWSYWFBO4yrviPJQI2T12
	 xK4sZ5LGSmJzpGgk68xqS6KYB6Hk/7Xd1gzc5zBKbJeLRyY9wgVRctJGvDI38FsfxcZPE
	 eOP1eN+oRwTdmLNsr2QdBUQFxhbYjG/MZqCZy8HvrWkPgeigPClV27l27tcSbo64PvQ==
ARC-Message-Signature: i=1; d=subspace.kernel.org; s=arc20261015;
	a=rsa-sha256; c=relaxed/relaxed; t=1793813319;
	h=Received:DKIM-Signature:From:Subject:Date:Message-Id:MIME-Version:
	 Content-Type:Content-Transfer-Encoding:X-B4-Tracking:X-Change-ID:
	 In-Reply-To:References:To:Cc:X-Mailer:X-Developer-Signature:
	 X-Developer-Key;
	bh=gjEH2piUuhMtwxK5i7yIAEc83f1M2MXkP9ZzaCRnQBU=;
	b=pMVz3T4hfzKG8pbwBOBwRUQ5I6YkO4pD7VuqcX4at95zNqcTiZU0UpELdzXgX+tWry9Q
	 tierox/WtLarjDdwHenvAqG7yQyJZ7q8CnPbR7U8FuCMnWbnespxSKu92vHYSYMZaPF49
	 IIc56a0te0XoBHhVB8WeMZWkpxXOL3ZguzOJdIALmIenayc2fi4Co2sesWG2JAYNsPbnL
	 yurHoI83xQX3vy6orbX95NETbqo5EpOcvE9DVbayRwYZP9pxxsRmw5kKcCLmAj0S24F2d
	 V14fQOcxJ6snOO+GMnvCUNaDrMsTIDi0/IZQcDEryanhyWtjNZNaBrn8x7rpbBoe9MA==
ARC-Authentication-Results: i=1; smtp.subspace.kernel.org; 
	dkim=pass header.d=kernel.org header.i=@kernel.org header.a=rsa-sha256 header.s=k20260515 header.b=cVdCjCL1;
	arc=none smtp.remote-ip=100.103.45.18
Received: from smtp.kernel.org (quasi.space.kernel.org [100.103.45.18])
	(using TLSv1.3 with cipher TLS_AES_256_GCM_SHA384 (256/256 bits)
	 key-exchange X25519 server-signature ECDSA (prime256v1))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 3517C606A31B;
	Wed,  4 Nov 2026 17:28:38 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key, unprotected) header.d=kernel.org header.i=@kernel.org header.a=rsa-sha256 header.s=k20260515 header.b=cVdCjCL1
Received: by smtp.kernel.org (Postfix) with ESMTPSA id 159391F000C1;
	Wed,  4 Nov 2026 17:28:23 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=kernel.org;
	s=k20260515; t=1793813318;
	bh=gjEH2piUuhMtwxK5i7yIAEc83f1M2MXkP9ZzaCRnQBU=;
	h=From:Subject:Date:In-Reply-To:References:To:Cc;
	b=cVdCjCL1e/r71WdMYR37Zt/JfRlrKHW7hYZIgKlb+Kfq5/0Yh0QHjoclvPtLk+fin
	 YvLgjvxb1o8KGGlc0ouDFGIVy7l/F0u8+/o2IaiADydVB3cYg+8utWuIWlMJBZdzLc
	 /53Gg0Gbq8hzAJ7pJy8kC4ywtg8GeAqY7L8q2t05Q3VVA/15mpyDJc0JlDsOPjtKm0
	 ICfDugN5L9H7CTh57OX9YNroaBA4oZMjjvn+zt/+ujI0IUGwntNelJKez+5cVCDp/1
	 /Fk9OLdyb5lc9b0NV9me5V0xQ66Awmj2F7LFQ7pJUpFi9Q1b19Eol8hEhwveYWX8Y+
	 j2RAv7ggEn+OA==
From: Christian Brauner <brauner@kernel.org>
Subject: [PATCH v2 00/51] proc: fix a few old bugs in /proc handlers (Part
 1/7)
Date: Wed, 04 Nov 2026 18:27:17 +0100
Message-Id: <20261104-work-procfs-bugfixes-v2-0-bbf7d5546809@kernel.org>
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
X-B4-Tracking: v=1; b=H4sIAAAAAAAC/22OTQ6CMBCFr0K6tqSthYgr72FY0DJAxVAyA6gh3
 N0W4s7l+/vyVkaADohdk5UhLI6cH4JQp4TZrhpa4K4OmimhcimF5C+PPR/R24a4mdvGvYG4yHQ
 thFAXXUgWpiPCHoTlvTw0zeYBdoqs2DAVATdYDbaLVqSmBzWNUax0jiaPn/3aIiPq90L9f7FIL
 nhWaKWgPoPOs1sPOMAz9diyctu2L6vwdQzuAAAA
X-Change-ID: 20261101-work-procfs-bugfixes-054d00028491
In-Reply-To: <20261104-work-procfs-v2-0-288f0ce32927@kernel.org>
References: <20261104-work-procfs-v2-0-288f0ce32927@kernel.org>
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
 Chuck Lever <cel@kernel.org>, stable@vger.kernel.org, 
 "Rafael J. Wysocki (Intel)" <rafael@kernel.org>, 
 Chuck Lever <cel@kernel.org>
X-Mailer: b4 0.17-dev
X-Developer-Signature: v=1; a=openpgp-sha256; l=12755; i=brauner@kernel.org;
 h=from:subject:message-id; bh=gmyRMdG+KcFIxcDC/b/LbsSvPn/1UP4r7z8EeefJTHI=;
 b=owGbwMvMwCU28Zj0gdSKO4sYT6slMWS9zvoZ/Lbi45HAjXEZngICNzO2r77RGG7annMue//5S
 vPIRFafjlIWBjEuBlkxRRaHdpNwueU8FZuNMjVg5rAygQxh4OIUgImsqWZkmB8ls//fK/m2uq02
 e6ZP5GLmOXZuurw00/Er33PDn7le7WdkWM43v1iERV9nimmWQJvcnN3yDPFFyhtVY/feyotVPvm
 NFQA=
X-Developer-Key: i=brauner@kernel.org; a=openpgp;
 fpr=4880B8C9BD0E5106FC070F4F7B3C391EFEA93624

Part 1/7 of "proc: move procfs to what kernfs does", the base of the
other six parts:

  https://patch.msgid.link/20261104-work-procfs-v2-0-288f0ce32927@kernel.org

Moving procfs to what kernfs does touches just about every
->proc_read(), ->proc_write() and ->proc_ioctl() in the tree. Reviewing
that turned up bugs that have nothing to do with the conversion and are
a lot older. They go first so they can go to stable on their own. Four
selftests come with them.

In procfs itself:

- readdir resumed a listing at a counted position, so an entry that came
  or went in between repeated or skipped one, and it ended a listing
  early when the entry it was emitting went away. It resumes after the
  last name now, like kernfs. /proc/sys had the same bug.
- /proc/sys readdir ended a listing early at an entry that was being
  unregistered, so getdents64() reported EOF with entries left.
- /proc/sys copied to and from userspace with the table held, so a read,
  write or getdents64() that faults for as long as userspace wants kept
  unregister_sysctl_table() waiting, which addrconf calls under RTNL.
- proc_sys_make_inode() read the table after it had dropped sysctl_lock.
- a symlink's entry stayed pinned while readlink() copied it out, so a
  faulting readlink() held up remove_proc_entry(). ALSA removes its card
  links with snd_card_mutex held.
- name resolution walked through regular files, and pktgen lets
  userspace pick names, so an unprivileged user could hang an entry
  below another file and get it freed. pktgen refuses a '/' now.
- proc_register() WARNed on a duplicate name, which pktgen's names can
  provoke.
- proc_remove() removed by name, so removing an entry that was already
  gone could take out a different one.
- the parent of entries a dying network namespace left in /proc/net was
  freed silently. procfs warns now.
- on NOMMU every /proc file could be mapped privately, which reads it
  with nommu_region_sem held, and /proc/maps takes that lock. Any user
  could hang the machine.
- sunrpc queued the pollers of its channel files on a wait queue in the
  per-namespace cache_detail, which is freed with the namespace. Back to
  one static queue here, the conversion makes procfs own the queues.
- vmcore_cleanup() could run twice at once.

In the handlers:

- PCI/proc and isapnp truncated the position to an int, so a pwrite()
  or pread() at a huge offset went negative and accessed config space
  far outside the file.
- dasd looked in front of its buffer on an empty write.
- toshiba_acpi's brightness and fan write checks could never fail.
- simdisk read the file name without the lock that protects it, so a
  reader could copy out memory a concurrent detach had freed.
- rtas_flash read past its validate message, and rtasd handed out what
  vmalloc() left in its log buffer.
- ALSA's info layer let a write past the end of a data entry through
  unclamped.
- BusLogic, ips and libipw returned 0 from writes, so stdio writers
  retry forever.
- the scsi host files and um's /proc/exitcode parsed writes without
  NUL-terminating them.
- ntfs3 tripped the page allocator's warning on a huge label write.
- esas2r took the lengths of its HBA, SMP and firmware ioctls from
  userspace unchecked, through a file everyone can open.
- powerpc's copy_oldmem_page() didn't check ioremap_cache() and only
  recovered from a machine check for read(), the pseries ofdt parser
  read past its input, and lparcfg reported a failed hcall as a huge
  write.
- alloc_tag removed /proc/allocinfo with the codetag module lock held
  when a module's tags couldn't be reserved, and a reader of the file
  takes that lock with the entry pinned, so the module load and the
  reader waited for each other for good.
- esas2r copied the kernel addresses of the adapter, its pci_dev and its
  Scsi_Host out through the 0444 ATTONode.
- cs46xx stored the chip in the private data of its region files and
  read it back as the region.
- isapnp went on talking to whatever device the card had selected, and
  unlocked a mutex it never took, when isapnp_cfg_begin() refused a
  logical device number.
- simdisk freed the gendisk before it removed the entry, so a write in
  between set the capacity of a freed disk.
- the pseries ofdt commands leaked a node reference per property
  command, and lockd handed out the NUL behind "Y\n".
- lparcfg and psi overwrote the last byte of a write to terminate it,
  so a write without a trailing newline lost a character.
- the sparc LED and rtas progress files consumed only the start of a
  write, so a looping writer sent the rest as a second command.
- profiling reported success when /proc/profile couldn't be created,
  and zorro sized its files like a zorro_dev instead of the ConfigDev
  they serve.

The xt_recent deadlock v1 fixed here goes in through netfilter instead.

The procfs, sysctl, readlink, pktgen, sunrpc, PCI and duplicate name
bugs reproduce on a KASAN and lockdep kernel in a VM and are gone with
the series. The rest is build tested.

Signed-off-by: Christian Brauner (Amutable) <brauner@kernel.org>
---
Changes in v2:
- thirteen more fixes that the review of v1 turned up: alloc_tag,
  esas2r, cs46xx, isapnp, simdisk, pseries ofdt, lockd, lparcfg, psi,
  the sparc LED, rtas progress, profiling and zorro
- the NOMMU, crash_dump and lparcfg patches say more about the bug
- new patch: sysctl readdir ended a listing early when an entry was
  being unregistered, pre-existing
- the xt_recent patch is dropped, Cen Zhang's fix for the same lock is
  on its way through netfilter
- the readdir churn selftests skip instead of failing without
  /dev/net/tun, the sysctl removal selftest seeks past the dots first so
  its fault lands in an entry, the selftests' Makefile, .gitignore and
  config lines sit in the series that adds each test
- struct sysctl_dirent loses its unused mode
- Reviewed-by and Acked-by from Rafael, Takashi and Chuck
- rebased onto v7.4-rc1
- Link to v1: https://patch.msgid.link/20261102-work-procfs-bugfixes-v1-0-59422ed3e465@kernel.org

---
Christian Brauner (51):
      alloc_tag: don't remove /proc/allocinfo under the codetag module lock
      scsi: esas2r: don't copy kernel pointers out in EXPRESS_IOCTL_GET_MOD_INFO
      ALSA: cs46xx: hand the region to the region proc files
      PNP: isapnp: don't go on when isapnp_cfg_begin() fails
      xtensa: simdisk: remove the proc entry before the disk
      powerpc/pseries: put the node that the ofdt property commands look up
      lockd: don't hand out the terminator of nlm_end_grace
      powerpc/pseries/lparcfg: don't drop the last byte of a write
      profiling: report it when /proc/profile can't be created
      zorro: size the proc files like what they serve
      sparc: led: consume the whole write
      powerpc/rtas: consume the whole write to /proc/powerpc/rtas/progress
      sched/psi: don't drop the last byte of a trigger write
      proc: sysctl: don't stop readdir at an entry that is being unregistered
      PCI/proc: don't truncate the position of config space accesses
      PNP: isapnp: don't read past the end of the buffer on a large pread()
      s390/dasd: don't look in front of the buffer on an empty write
      platform/x86: toshiba_acpi: reject malformed brightness and fan writes
      xtensa: simdisk: don't read the file name without the lock
      powerpc/rtas_flash: don't read past the validate message
      powerpc/rtasd: zero the error log buffer
      ALSA: info: don't write past the end of a data entry
      scsi: BusLogic: don't return 0 from writes to the proc file
      scsi: ips: don't return 0 from writes to the proc file
      wifi: libipw: don't return 0 from writes to debug_level
      scsi: core: NUL-terminate what is written to the host proc files
      um: NUL-terminate what is written to /proc/exitcode
      ntfs3: don't warn when a huge label is written
      proc: don't walk through a non-directory when resolving a name
      net: pktgen: reject device names with a '/'
      proc: don't WARN about a name that is already registered
      proc: resume readdir after the last name it returned
      selftests/proc: check a /proc listing while entries come and go
      proc: let proc_remove() remove the entry it was given
      proc: warn about entries left in /proc/net of a dying namespace
      proc: don't let NOMMU map procfs files
      proc/vmcore: don't let vmcore_cleanup() run twice at once
      powerpc/crash_dump: check ioremap_cache() in copy_oldmem_page()
      powerpc/crash_dump: recover from a machine check in copy_oldmem_page()
      sunrpc: make queue_wait a global wait queue again
      scsi: esas2r: bound the lengths of the HBA, SMP and firmware ioctls
      powerpc/pseries: bound the lengths in the ofdt property parser
      powerpc/pseries/lparcfg: return h_get_ppp()'s status as a long
      proc: sysctl: resume readdir after the last name it returned
      selftests/proc: check a sysctl listing while entries come and go
      proc: sysctl: copy to and from userspace without holding the table
      proc: sysctl: look at the table under sysctl_lock when creating an inode
      proc: sysctl: don't hold the tables while readdir copies to userspace
      selftests/proc: check that faulting sysctl accesses don't hold up removal
      proc: don't pin a symlink's entry while readlink() copies it out
      selftests/proc: check that a faulting readlink() doesn't hold up removal

 arch/powerpc/kernel/crash_dump.c                   |   6 +-
 arch/powerpc/kernel/rtas-proc.c                    |   3 +-
 arch/powerpc/kernel/rtas_flash.c                   |   2 +-
 arch/powerpc/kernel/rtasd.c                        |   2 +-
 arch/powerpc/platforms/pseries/lparcfg.c           |   7 +-
 arch/powerpc/platforms/pseries/reconfig.c          |  24 +-
 arch/sparc/kernel/led.c                            |   3 +-
 arch/um/kernel/exitcode.c                          |   3 +-
 arch/xtensa/platforms/iss/simdisk.c                |  28 +-
 drivers/net/wireless/intel/ipw2x00/libipw_module.c |   2 +-
 drivers/pci/proc.c                                 |  15 +-
 drivers/platform/x86/toshiba_acpi.c                |   8 +-
 drivers/pnp/isapnp/core.c                          |  16 +-
 drivers/pnp/isapnp/proc.c                          |  11 +-
 drivers/s390/block/dasd.c                          |   2 +-
 drivers/scsi/BusLogic.c                            |   2 +-
 drivers/scsi/esas2r/esas2r.h                       |   2 +-
 drivers/scsi/esas2r/esas2r_ioctl.c                 |  48 ++-
 drivers/scsi/esas2r/esas2r_main.c                  |   3 +-
 drivers/scsi/ips.c                                 |   2 +-
 drivers/scsi/scsi_proc.c                           |   1 +
 drivers/zorro/proc.c                               |   2 +-
 fs/lockd/procfs.c                                  |   2 +-
 fs/ntfs3/super.c                                   |  11 +-
 fs/proc/generic.c                                  | 174 ++++++---
 fs/proc/inode.c                                    |  38 +-
 fs/proc/internal.h                                 |   1 +
 fs/proc/proc_net.c                                 |   7 +
 fs/proc/proc_sysctl.c                              | 388 ++++++++++++++-------
 fs/proc/root.c                                     |   1 +
 fs/proc/vmcore.c                                   |   5 +
 include/linux/sunrpc/cache.h                       |   1 -
 kernel/profile.c                                   |   8 +-
 kernel/sched/psi.c                                 |   4 +-
 mm/alloc_tag.c                                     |  27 +-
 net/core/pktgen.c                                  |   4 +
 net/sunrpc/cache.c                                 |  12 +-
 sound/core/info.c                                  |   2 +
 sound/isa/es18xx.c                                 |   6 +-
 sound/pci/cs46xx/cs46xx_lib.c                      |   2 +-
 tools/testing/selftests/proc/.gitignore            |   4 +
 tools/testing/selftests/proc/Makefile              |   4 +
 tools/testing/selftests/proc/config                |   9 +
 tools/testing/selftests/proc/proc-readdir-churn.c  | 240 +++++++++++++
 .../selftests/proc/proc-remove-slow-readlink.c     | 191 ++++++++++
 .../selftests/proc/proc-remove-slow-sysctl.c       | 215 ++++++++++++
 .../selftests/proc/proc-sysctl-readdir-churn.c     | 152 ++++++++
 47 files changed, 1420 insertions(+), 280 deletions(-)
---
base-commit: 6628e7d4c6b25c8d18f1345e3a20d21829aae7e4
change-id: 20261101-work-procfs-bugfixes-054d00028491

