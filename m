Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.remote-ip=100.103.45.18
ARC-Seal: i=1; d=subspace.kernel.org; s=arc20261015; a=rsa-sha256; cv=none;
	t=1793820573;
	b=JN9o+TMBgOFS+Nb/8n9PCPv3+gFmJ9Lfz8ZSn4uonYWY5qzXE1SMM16RQ32jyHPi0sBo
	 oawEu+ZoYYI4rFnRz39UPDF0pkomB97jP95XqepdVIanBU6x6PqfbnpqgCJIlH9Z7oQad
	 +ewL1ctJpd8dUOlT0uLLjuP0pU8HKP3TDS/RlfFtn2cG1C4Txs6LnsRq4REBRu1vCMhjn
	 V+QaP58781EzvK6+2T2tPTmnuhrgd/b9vMBq3OKJiAYg9cs+o1Xo6kAXEgGun0TtSpCtY
	 4QqAN/wkPcMAg53H9nKuYce5gB+VUXjYFuOa2wKgf3IyNbXaxskNGpIQHmLiE8dCRtQ==
ARC-Message-Signature: i=1; d=subspace.kernel.org; s=arc20261015;
	a=rsa-sha256; c=relaxed/relaxed; t=1793820573;
	h=Received:DKIM-Signature:From:To:Cc:Subject:Date:Message-ID:
	 In-Reply-To:References:MIME-Version:Content-Type:X-Change-ID:X-Mailer:
	 X-Developer-Signature:X-Developer-Key:Content-Transfer-Encoding;
	bh=BSR8KrA5WsWDAsnf7a3SEYyO4TT3rIWRkkpblhU3vC4=;
	b=AsLw/32uBNouFGatfKxPA6axSqL08Xb4gIzLnFDiOB7uFK7d6zG3J9EXKOYP+lKsimOy
	 5qvj0QfKPa9rLHagLVfs9s954qpCSwxeqFlOVwPwvt2svSxo2xKvB7Souv+djEzw2s6lg
	 RJAcanRPKfgmCP8uxfiwYI/5C63KIOdXkLG96bZhRp9BrLIsBz3tsQ1lGVQ6RrFYWlofY
	 7vhE7jpMufpA52rZbwfiDz59Zf0PLna3xbNg+ER0X8F6soHG/Tse+hiEX1b8oMHsEjjD4
	 BF4k96y0w8tEHqOqAkheC33syUq52jNWFRtWaqEFFg7xGSazT8/7TEqP/yzro78Jo8g==
ARC-Authentication-Results: i=1; smtp.subspace.kernel.org; 
	dkim=pass header.d=kernel.org header.i=@kernel.org header.a=rsa-sha256 header.s=k20260515 header.b=fm+snEsH;
	arc=none smtp.remote-ip=100.103.45.18
Received: from smtp.kernel.org (quasi.space.kernel.org [100.103.45.18])
	(using TLSv1.3 with cipher TLS_AES_256_GCM_SHA384 (256/256 bits)
	 key-exchange X25519 server-signature ECDSA (prime256v1))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id C1833606B2D7;
	Wed,  4 Nov 2026 19:29:32 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key, unprotected) header.d=kernel.org header.i=@kernel.org header.a=rsa-sha256 header.s=k20260515 header.b=fm+snEsH
Received: by smtp.kernel.org (Postfix) with ESMTPSA id A1DAB1F000C1;
	Wed,  4 Nov 2026 19:29:20 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=kernel.org;
	s=k20260515; t=1793820572;
	bh=BSR8KrA5WsWDAsnf7a3SEYyO4TT3rIWRkkpblhU3vC4=;
	h=From:To:Cc:Subject:Date:In-Reply-To:References;
	b=fm+snEsHSUMdJQMYXWtJD8H75OujfOckcQGSgOUJCHoiXcnuWL5JqHO+xlPMJnNHh
	 7L7gY4b8oU4/m94jZyMfjd1GdoeMs60fpGp9AIrXeVMfN31aiMuEzCyS+eWLbTLuPV
	 BPA6rRRRrTTWpwaGwq0GiCB1IRfXCb4E10ZB+LQTgcJCp5dD5hAbq0xeoS5uD6mvGo
	 XD6O9ShL3YDsjDBRPXV2CpOA2VgGaIsET3FaKweJoWfpyMC3h7R8xDixN1ERs055n+
	 MwPpkjy3mlDsFA6EPjwSN35unN1AzQE3PB3MKS0y+nNSfE2LBKJlHHBhaGEtSZvTPv
	 6mP8wZt8knuPw==
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
Subject: [PATCH RESEND v2 00/23] proc: let procfs own the data path (Part 2/7)
Date: Wed,  4 Nov 2026 20:29:18 +0100
Message-ID: <20261104-work-procfs-core-v2-0-76ace653a773@kernel.org>
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
X-Change-ID: 20261101-work-procfs-core-8fa4a4f412cf
X-Mailer: b4 0.17-dev
X-Developer-Signature: v=1; a=openpgp-sha256; l=16472; i=brauner@kernel.org; h=from:subject:message-id; bh=GiozsU5LVlTUmY0umOFVQ6uJF4f9wh0KdRccm0wVx6E=; b=owGbwMvMwCU28Zj0gdSKO4sYT6slMWS9bi+w5eOU3bi0Li6RX/SGgKzywiMKPIquQersv3v2b Ps69YR2RykLgxgXg6yYIotDu0m43HKeis1GmRowc1iZQIYwcHEKwER+yjH803JhEI5n71P+nKa9 xWamU7mPXk1MCJuAhO4leT7DomcRDH8FS92Wh1+8/7p17m/HyKiLn6eqPVfnNlV9vX8zYxZL/2d +AA==
X-Developer-Key: i=brauner@kernel.org; a=openpgp; fpr=4880B8C9BD0E5106FC070F4F7B3C391EFEA93624
Content-Transfer-Encoding: 8bit

Part 2/7 of "proc: move procfs to what kernfs does", on top of part 1:

  https://patch.msgid.link/20261104-work-procfs-v2-0-b45cd5789ac5@brauner

remove_proc_entry() waits until every call into the entry has returned.
A seq_file entry wait across seq_read_iter() including the copy to
userspace. Non-seq_file entries wait across ->proc_read(),
->proc_write() and ->proc_ioctl(), which copy to and from userspace
as well.

A reader or writer can abuse a page fault to make copy take as long as
it wants. For example, by using userfaultfd or by punching holes into a
memfd over and over. And callers of remove_proc_entry() like to hold
locks while they wait. For instance, addrconf holds RTNL when it removes
/proc/net/dev_snmp6/<dev> and xt_hashlimit holds hashlimit_mutex which
is shared by all network namespaces.

There was a hackish and very narrow AI solution to a small part of this
bug class which was sent off-list. In essence, it used a second
buffering mechanism on top of seqfiles which was really nasty. It also
didn't address any of the non-seqfile users.

If we want to get rid of the this whole bug class we need a bigger
hammer. That means reworking how procfs handles data. So I tried to work
through all of that.

This changes procfs so the entry's code only ever runs with the entry
pinned and never touches userspace memory. This is the core procfs
change required for this. The entries themselves are converted in four
series on top of it. The are independent of each other. The last series
drops all __user methods.

* seq_file reads

  procfs owns the seq_file and only calls into the entry with it pinned.
  An entry declares its seq_operations, or just a show function, and the
  size of its private state in struct proc_ops. procfs opens and frees
  the seq_file and reads and seeks through seq_file directly.

  ->proc_open() and ->proc_release() only deal with whatever the entry
  needs on top of that. proc_create_seq() and friends already keep the
  seq_operations in the entry so they're switched over in one go here.
  That covers most of /proc/net.

  The open coded single_open() and seq_open() users that don't do
  anything else are converted with a coccinelle script. A nice side
  effect is that opening one of these entries no longer allocates a
  pde_opener as they have no ->proc_release() of their own anymore.

* Writes

  procfs copies in what is written before it pins the entry and hands
  the entry a NUL-terminated kernel copy through ->proc_write_buf().

  The copy is capped at PAGE_SIZE - 1 bytes unless the entry asks for
  more in ->proc_write_size.

  Entries that take binary data in pieces (the PCI config space, ALSA's
  data entries, cio_ignore and the rtas flash files) ask for
  PROC_ENTRY_SHORT_WRITES and their writes come up short.

  Since procfs copies in the whole write first, a write that is too
  large or whose buffer can't be read fails before the entry's own
  checks now.

* Reads that don't go through seq_file

  An entry fills a kernel buffer in ->proc_read_buf(), procfs copies
  that to userspace after unpinning the entry and only moves the
  position if that copy worked, like kernfs_file_read_iter().

  The buffer is a page unless the entry asks for more in
  ->proc_read_size, and like with kernfs a larger read comes up short.

  Entries whose readers want all of a large file in one read,
  /proc/vmcore, /proc/config.gz and ALSA's data entries, ask for
  PROC_ENTRY_FULL_READS and procfs fills their reads in pieces. These
  entries are read through ->read_iter() now, so sendfile() and splice()
  work for them.

* ioctls

  The command number doesn't reliably say what an ioctl copies. The PCI
  ioctls aren't encoded at all, i8k's encode the wrong sizes and esas2r
  uses a range of plain numbers.

  So an entry lists its commands in ->proc_ioctl_args with what goes in
  and what comes back out. That works like DRM's ioctl tables.

  procfs copies the argument in before it pins the entry, calls
  ->proc_ioctl_buf() with that copy and copies it back out after
  unpinning the entry.

  A command that isn't in the table fails with -ENOTTY. 32-bit tasks go
  through the same table, so the compat hooks go away.

* permanent entries

  Entries that are never removed, kcore, kmsg and the kpage files, keep
  reading straight into userspace. The last series gives them
  file_operations of their own and takes the __user methods out of
  struct proc_ops altogether.

* mmap()

  procfs pins the entry around ->proc_mmap() and then wraps the
  vm_operations of the mapping the way kernfs does. So the entry's
  ->fault(), ->page_mkwrite(), ->access() and ->open() run pinned as
  well.

  Removing the entry unmaps the mappings in its own address space, like
  kernfs does, and a fault into one of them is SIGBUS from then on.

  A file that maps through another address space, /proc/bus/pci through
  the one of /dev/mem, keeps its mappings like a sysfs resource file
  does. The entry's vm_operations live in its open node. vmcore's
  mappings of the old memory no longer outlive fadump releasing it.

* Poll

  An entry with a ->proc_poll() used to sleep its pollers on a wait
  queue of its own and procfs only pinned the entry around the call.

  The poller stays on that queue after the call, so after
   remove_proc_entry() ran ->proc_release() on the still open file and
   the owner freed the queue with the rest.

   sunrpc kept the queue of its channel files in the per-namespace
   cache_detail, so a poll() across the end of the namespace was a
   use-after-free. md works around the same thing at unload by waking
   its pollers in a loop until nobody is left.

   Make procfs own the wait queue. It lives in the open node,
   proc_reg_poll() does the poll_wait() on it before it calls the
   method. The owner wakes the pollers with proc_poll_notify(), and a
   poll of a removed entry reports EPOLLERR | EPOLLPRI.

   The seven pollable entries in the tree move over in the conversion
   series.

   The last series takes the poll_table away from ->proc_poll() once
   nothing needs it anymore.

* Lockdep

  The pin is a read lock to lockdep and a removal takes the write side
  around waiting for the last user, the way kernfs annotates its active
  reference.

  A method that takes a lock while pinned and a removal under that lock
  is the deadlock xt_recent had, and lockdep reports it now instead of a
  reviewer having to find it.

  The class is per kind of entry, keyed on the seq_operations or
  proc_ops the entries of a kind share, and per registration site for
  the entries that only share a show function, like sysfs keys per
  attribute.

On a KASAN and lockdep kernel the reader selftest fails without the
series and passes with it, and the mapped-entry selftest, run against
a virtio-rng device in a VM, fails without the mmap patch and passes
with it. The other proc selftests behave the same with and without the
series and so do the entries converted here that I could get at in a
VM.

Signed-off-by: Christian Brauner (Amutable) <brauner@kernel.org>
---
Changes in v2:
- the open files of an entry live in an open node that only entries with
  a release or mmap hook get, a removal waits with wait_var_event(), the
  readdir cursor is shared with sysctl
- procfs pins the entry around the vm_operations of its mappings and
  unmaps a removed entry's own address space like kernfs does, with a
  selftest; a file that maps through another address space,
  /proc/bus/pci through the one of /dev/mem, keeps its mappings like a
  sysfs resource file; vmcore's mappings of the old memory no longer
  outlive fadump releasing it
- lockdep checks the pin
- procfs owns the wait queue of an entry with a ->proc_poll(), the
  conversions are in the area series
- the seq_file runs the entry's own ->next() and ->show() with procfs's
  ->start() and ->stop() around them instead of a wrapper per record,
  which cost up to 24% on /proc/vmstat, and the ERR_PTR(-EIO) sentinel
  is gone
- ioctls that only pass a value no longer copy to a NULL pointer
  (-EFAULT on csky), and registration also refuses a
  ->proc_compat_ioctl() next to ->proc_ioctl_buf()
- rebased onto v7.4-rc1
- Link to v1: https://patch.msgid.link/20261102-work-procfs-core-v1-0-75df35e4f8b8@kernel.org

---
Christian Brauner (23):
      proc: drop the compat file operations
      proc: add pde_pin() and pde_unpin()
      proc: share the readdir cursor with sysctl
      proc: wait for the last user of an entry with wait_var_event()
      proc: keep the open files of an entry in an open node
      proc: make room for more entry flags
      proc: let procfs own the seq_file of seq_file entries
      proc: let procfs own the seq_file of proc_create_seq() and friends
      proc: let procfs own the seq_file of DEFINE_PROC_SHOW_ATTRIBUTE() files
      treewide: let procfs own the seq_file of simple proc entries
      selftests/proc: check that a faulting reader doesn't hold up removal
      seq_file: add seq_preallocate()
      proc: let procfs own the seq_file of /proc/stat
      proc: let procfs copy in writes before pinning the entry
      proc: copy in writes to the network namespace entries before pinning
      proc: let procfs copy out reads that don't go through seq_file
      fs/proc/vmcore: let procfs copy out reads
      proc: let procfs copy ioctl arguments in and out
      proc: pin the entry around the vm_operations of its mappings
      selftests/proc: check that a mapped entry can be removed
      proc: let lockdep check the pin
      proc: own the wait queue of an entry with a ->proc_poll()
      Documentation: seq_file: describe how a /proc file uses seq_file

 Documentation/filesystems/seq_file.rst             |  42 +-
 arch/alpha/kernel/srm_env.c                        |  10 +-
 arch/arm/mm/alignment.c                            |  10 +-
 arch/powerpc/kernel/rtas-proc.c                    |  50 +-
 arch/powerpc/platforms/pseries/lpar.c              |  20 +-
 arch/powerpc/platforms/pseries/lparcfg.c           |  10 +-
 arch/sh/mm/alignment.c                             |  10 +-
 arch/sparc/kernel/led.c                            |  10 +-
 arch/um/kernel/exitcode.c                          |  10 +-
 drivers/acpi/proc.c                                |  12 +-
 drivers/hwmon/dell-smm-hwmon.c                     |  10 +-
 drivers/input/input.c                              |  24 +-
 drivers/macintosh/via-pmu.c                        |  10 +-
 drivers/net/wireless/intel/ipw2x00/libipw_module.c |  10 +-
 drivers/platform/x86/lenovo/thinkpad_acpi.c        |  10 +-
 drivers/platform/x86/toshiba_acpi.c                |  40 +-
 drivers/pnp/pnpbios/proc.c                         |  10 +-
 drivers/s390/block/dasd_proc.c                     |  10 +-
 drivers/s390/cio/blacklist.c                       |  13 +-
 drivers/scsi/scsi_devinfo.c                        |  10 +-
 drivers/scsi/scsi_proc.c                           |  21 +-
 drivers/usb/gadget/function/rndis.c                |  10 +-
 drivers/video/fbdev/via/viafbdev.c                 |  70 +--
 fs/jfs/jfs_debug.c                                 |  10 +-
 fs/ntfs3/super.c                                   |  20 +-
 fs/proc/cpuinfo.c                                  |  10 +-
 fs/proc/generic.c                                  | 261 ++++++---
 fs/proc/inode.c                                    | 652 ++++++++++++++++-----
 fs/proc/internal.h                                 | 146 ++++-
 fs/proc/proc_net.c                                 |  72 +--
 fs/proc/proc_sysctl.c                              |  45 +-
 fs/proc/stat.c                                     |   6 +-
 fs/proc/vmcore.c                                   |  14 +-
 fs/seq_file.c                                      |  36 +-
 fs/smb/client/cifs_debug.c                         |  79 +--
 fs/smb/client/dfs_cache.c                          |  10 +-
 include/linux/proc_fs.h                            | 159 ++++-
 include/linux/seq_file.h                           |  11 +-
 kernel/irq/proc.c                                  |  30 +-
 kernel/latencytop.c                                |  10 +-
 lib/dynamic_debug.c                                |   6 +-
 mm/slab_common.c                                   |  10 +-
 net/core/pktgen.c                                  |  30 +-
 net/sunrpc/stats.c                                 |  10 +-
 tools/testing/selftests/proc/.gitignore            |   2 +
 tools/testing/selftests/proc/Makefile              |   2 +
 tools/testing/selftests/proc/proc-remove-mapped.c  | 160 +++++
 .../selftests/proc/proc-remove-slow-reader.c       | 133 +++++
 48 files changed, 1440 insertions(+), 916 deletions(-)
---
base-commit: 6628e7d4c6b25c8d18f1345e3a20d21829aae7e4
change-id: 20261101-work-procfs-core-8fa4a4f412cf
prerequisite-change-id: 20261101-work-procfs-bugfixes-054d00028491:v2
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

