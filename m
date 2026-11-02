Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.remote-ip=100.103.45.18
ARC-Seal: i=1; d=subspace.kernel.org; s=arc20261015; a=rsa-sha256; cv=none;
	t=1793630941;
	b=RC8J22JEZS6Qq6bGTq48GuDItffn3tLr2alCq0KbuItwOjfGD8gJTPUjkPvuAGEcjx1d
	 SX+Klp75MYL2Ncvkk5JTcFhKFX45yPa+ICXoad3oMyR3VHxzXgzsHjm7Q1oJ3ECNtK2Hp
	 ByyHX1dbGMX8mnlTDpU2bfmAyJ7kIjuWEZljgwzRltzAckKuO4XCKfnkJ+k+DGjYdu+lY
	 cz3EZOyhWxFoeEuNxmNT9nhNYd1dUuGHVSJF0By6FwwFeLPXCDc9tUh6WcudmkGKlZP2K
	 mf+SDkwyv0IYgBCO31mwOGGq3OOweNFXaoI4+jddCpI/y86yQ9OzHSW412ddLmvEzyw==
ARC-Message-Signature: i=1; d=subspace.kernel.org; s=arc20261015;
	a=rsa-sha256; c=relaxed/relaxed; t=1793630941;
	h=Received:DKIM-Signature:From:Subject:Date:Message-Id:MIME-Version:
	 Content-Type:Content-Transfer-Encoding:X-B4-Tracking:X-Change-ID:
	 In-Reply-To:References:To:Cc:X-Mailer;
	bh=8jrSUs1NekCcqSC9vvFrLSxyeMYzE04YL21WWGf4M1s=;
	b=fU1K5UAEFqlTN1hOcX1QIDVHSJWbEM3PtAgDCe8+xHBKTSBoCHAY7l7Rbe1S5I+eLhnS
	 5X9trJVXC+f87hB4MtWpS7aBrkpG/DNQ/Uy5BGCyNU2X0sBDuUeO8pRBFOMadMm6Y20tJ
	 /1KLpGRbsltZ4eClC1L1+XO9c1sg2aZHBo7XCDf30V34hqj+YQaK2IKnwoaLwR7nrQi+y
	 8mBuBoga59DjUuWgxbJ0kcm67XnfIXfFADPriQLqxPYZjQQjWKJZZX59uVvER04jocLTH
	 EUKx9Qw0izvw11S9ns/pQrPEj0pWALO60c07Ge2E9yidbTztPLtfrAjd1GPxuRT6pnQ==
ARC-Authentication-Results: i=1; smtp.subspace.kernel.org; 
	dkim=pass header.d=kernel.org header.i=@kernel.org header.a=rsa-sha256 header.s=k20260515 header.b=KdaVBd+L;
	arc=none smtp.remote-ip=100.103.45.18
Received: from smtp.kernel.org (quasi.space.kernel.org [100.103.45.18])
	(using TLSv1.3 with cipher TLS_AES_256_GCM_SHA384 (256/256 bits)
	 key-exchange X25519 server-signature ECDSA (prime256v1))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 8ADFF606A91C;
	Mon,  2 Nov 2026 14:49:01 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key, unprotected) header.d=kernel.org header.i=@kernel.org header.a=rsa-sha256 header.s=k20260515 header.b=KdaVBd+L
Received: by smtp.kernel.org (Postfix) with ESMTPSA id 0000C1F00A17;
	Mon,  2 Nov 2026 14:48:44 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=kernel.org;
	s=k20260515; t=1793630941;
	bh=8jrSUs1NekCcqSC9vvFrLSxyeMYzE04YL21WWGf4M1s=;
	h=From:Subject:Date:In-Reply-To:References:To:Cc;
	b=KdaVBd+LR6dYrZOwxkALP6csVexgpTI17X0oGeUCg9cBeFTUgiR94zL6IyLoxq3GZ
	 aQIkaCOUsB8Oj/VUFcyqtDjBTHM3GgcvmUMOBZk0ZHCAJ2h41NDOZ+peUAbAsjobsF
	 zM0SFZ6wizhatH0BU12+Ioe1vUILWF6E1PDa0Tf8A/4th4qQcCELh9uSBD2k61TxFY
	 6DJtyWMTqO1JSRuci+enS4ZGiVJraiPNydbCuB9pH27FOcPP2tfaKhcNesGf3tTGPM
	 Mj1aPT7WKn91KKayYyS6um+HvRncQzg65nW7VPnUHihTaWl5PXPZv6N7VacBwj9V5+
	 0bdrkd3Bl9Nsg==
From: Christian Brauner <brauner@kernel.org>
Subject: [PATCH RFC 00/16] proc: let procfs own the data path
Date: Mon, 02 Nov 2026 15:48:40 +0100
Message-Id: <20261102-work-procfs-core-v1-0-75df35e4f8b8@kernel.org>
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
X-B4-Tracking: v=1; b=H4sIAAAAAAAC/22Owa7CIBBFf6WZtRigtGK3Jn6AW+MChkHRWBRaN
 TH+u631uXrLezPnzH1CphQoQ1M8IdEt5BDbIYhZAXgw7Z5YcEMGyWUtBBfsHtOJXVJEnxnGREx
 7o4zySkj0MGCXRD48PsotbNYr2E1l7u2RsBtl45k1mZhNpsXDWI3a+aSd234/GSYw0bUfdnVf5
 W9WU/w76o9mvFKOcy61WormJn5PMZ7PoWuKurJG+1IRal0TLqSVyBfOoUZfOi0qLKWulw52r9c
 bgbcrXCgBAAA=
X-Change-ID: 20261101-work-procfs-core-8fa4a4f412cf
In-Reply-To: <20261102-defizit-jobaussicht-kurios-7016c6e67442@brauner>
References: <20261102-defizit-jobaussicht-kurios-7016c6e67442@brauner>
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

remove_proc_entry() waits until every call into the entry has returned.
For a seq_file entry that's all of seq_read_iter() including the copy
to userspace. For everything else it's ->proc_read(), ->proc_write()
and ->proc_ioctl(), which copy to and from userspace themselves. A
reader or writer can make a page fault in that copy take as long as it
wants, e.g. with userfaultfd or by punching holes into a memfd over and
over. And callers of remove_proc_entry() like to hold locks while they
wait. addrconf holds RTNL when it removes /proc/net/dev_snmp6/<dev> and
xt_hashlimit holds hashlimit_mutex which is shared by all network
namespaces.

An earlier AI generated version bounced the text through a second buffer
in seq_file so the copy to userspace could happen with the entry
unpinned. That second buffering is really nasty and complicates
everything unnecessarily. So after chatting with Jann a bit I decided to
do what kernfs does instead: the entry's code only ever runs with the
entry pinned and never touches userspace memory. This series is the
procfs side of that. The entries are converted in four series on top of
it, one per area of the tree, which don't depend on each other, and a
last one drops the __user methods.

seq_file reads: procfs owns the seq_file and only calls into the entry
with it pinned. An entry declares its seq_operations, or just a show
function, and the size of its private state in struct proc_ops. procfs
opens and frees the seq_file and reads and seeks through seq_file
directly. ->proc_open() and ->proc_release() only deal with whatever
the entry needs on top of that. proc_create_seq() and friends already
keep the seq_operations in the entry so they're switched over in one
go here. That covers most of /proc/net. The open coded single_open()
and seq_open() users that don't do anything else are converted with a
coccinelle script, also here. A nice side effect is that opening one of
these entries no longer allocates a pde_opener, they have no
->proc_release() of their own anymore.

Writes: procfs copies in what is written before it pins the entry and
hands the entry a NUL-terminated kernel copy through ->proc_write_buf().
The copy is capped at PAGE_SIZE - 1 bytes unless the entry asks for
more in ->proc_write_size, which is what proc_simple_write() always
did. Entries that take binary data in pieces, the PCI config space,
ALSA's data entries, cio_ignore and the rtas flash files, ask for
PROC_ENTRY_SHORT_WRITES and their writes come up short. Since procfs
copies in the whole write first, a write that is too large or whose
buffer can't be read fails before the entry's own checks now,
permission checks included.

Reads that don't go through seq_file: an entry fills a kernel buffer in
->proc_read_buf(), procfs copies that to userspace after unpinning the
entry and only moves the position if that copy worked, like
kernfs_file_read_iter(). The buffer is a page unless the entry asks for
more in ->proc_read_size, and like with kernfs a larger read comes up
short. Entries whose readers want all of a large file in one read,
/proc/vmcore, /proc/config.gz and ALSA's data entries, ask for
PROC_ENTRY_FULL_READS and procfs fills their reads in pieces. These
entries are read through ->read_iter() now, so sendfile() and splice()
work for them.

ioctls: the command number doesn't reliably say what an ioctl copies.
The PCI ioctls aren't encoded at all, i8k's encode the wrong sizes and
esas2r uses a range of plain numbers. So an entry lists its commands in
->proc_ioctl_args with what goes in and what comes back out, like DRM's
ioctl tables. procfs copies the argument in before it pins the entry,
calls ->proc_ioctl_buf() with that copy and copies it back out after
unpinning the entry. A command that isn't in the table fails with
-ENOTTY. 32-bit tasks go through the same table, so the compat hooks go
away.

The limits of reads and writes are remembered in the entry when it is
registered, the proc_ops go away with the entry and procfs shouldn't
have to pin it just to look up a number. An entry that declares a
seq_file and a read or seek method of its own, or one of the new
methods next to the old one it replaces, fails to register.

Entries that are never removed, kcore, kmsg, the kpage files and
/proc/profile, keep reading straight into userspace. procfs never pins
those, so nothing can wait for them. The last series enforces that.

What this doesn't cover is mmap(). procfs pins the entry around
->proc_mmap() only and a page fault into the mapping runs the entry's
vm_ops unpinned. kernfs wraps those. That's for another day.

On a KASAN and lockdep kernel the reader selftest fails without the
series and passes with it. The other proc selftests behave the same
with and without the series and so do the entries converted here that I
could get at in a VM.

This is on top of "proc: fix a few old bugs in /proc handlers".

Signed-off-by: Christian Brauner (Amutable) <brauner@kernel.org>
---
Christian Brauner (16):
      proc: drop the compat file operations
      proc: add pde_pin() and pde_unpin()
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
      Documentation: seq_file: describe how a /proc file uses seq_file

 Documentation/filesystems/seq_file.rst             |  42 +-
 arch/alpha/kernel/srm_env.c                        |  10 +-
 arch/arm/mm/alignment.c                            |  10 +-
 arch/powerpc/kernel/rtas-proc.c                    |  50 +--
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
 drivers/video/fbdev/via/viafbdev.c                 |  70 +---
 fs/jfs/jfs_debug.c                                 |  10 +-
 fs/ntfs3/super.c                                   |  20 +-
 fs/proc/cpuinfo.c                                  |  10 +-
 fs/proc/generic.c                                  | 126 +++---
 fs/proc/inode.c                                    | 457 ++++++++++++++++-----
 fs/proc/internal.h                                 |  54 ++-
 fs/proc/proc_net.c                                 |  44 +-
 fs/proc/stat.c                                     |   6 +-
 fs/proc/vmcore.c                                   |  14 +-
 fs/seq_file.c                                      |  36 +-
 fs/smb/client/cifs_debug.c                         |  79 +---
 fs/smb/client/dfs_cache.c                          |  10 +-
 include/linux/proc_fs.h                            |  91 +++-
 include/linux/seq_file.h                           |  11 +-
 kernel/irq/proc.c                                  |  30 +-
 kernel/latencytop.c                                |  10 +-
 lib/dynamic_debug.c                                |   6 +-
 mm/slab_common.c                                   |  10 +-
 net/core/pktgen.c                                  |  30 +-
 net/sunrpc/stats.c                                 |  10 +-
 .../selftests/proc/proc-remove-slow-reader.c       | 133 ++++++
 44 files changed, 837 insertions(+), 792 deletions(-)
---
base-commit: 65ba8f34ec886ec72b2c07ddc8cf3d815c32869d
change-id: 20261101-work-procfs-core-8fa4a4f412cf
prerequisite-change-id: 20261101-work-procfs-bugfixes-054d00028491:v1
prerequisite-patch-id: 0474af12959624910718795bf86684383664c685
prerequisite-patch-id: 540aa9ea28adcbc54d8264f66314e29e3b8c9d49
prerequisite-patch-id: 2f7139d1c972c4439dccca610caa5f1288987a3d
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
prerequisite-patch-id: 78f067c343177e52d49ddfe9ee2992e602549869
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
prerequisite-patch-id: 4ed6b3d3d45de49d4967e88ba4e7f03372775f55
prerequisite-patch-id: dbe02fe3f784776fda5e7ae99f077bef0cd4b48d
prerequisite-patch-id: 53edc9a95afff57c4acba40095a8054924261ea2
prerequisite-patch-id: cf9ce0099005fd3bc31a1e15131d48e315ac3bee
prerequisite-patch-id: 16a657a5d0046068dbace29e7ea046ac1441f46f
prerequisite-patch-id: efeb2d6f7df71d5dede2c1d12fe999a28e38aab9
prerequisite-patch-id: e6ffe2a5c3ee5645f56c8366b568fbc9f140848c

