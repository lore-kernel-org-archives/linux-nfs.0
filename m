Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.remote-ip=100.103.45.18
ARC-Seal: i=1; d=subspace.kernel.org; s=arc20261015; a=rsa-sha256; cv=none;
	t=1793629310;
	b=tf3fLwpQvq1w41GNxito6v3bIilnIEAcHBiKj06Y3hx/KId8FN0lt9P62jBNohB/vivt
	 YFmEeUhSYjmEBEZqJrR9lz3BxTa6RITtFWMNnR6fbLuNPxOHhuIeHcyMqQQj2B0JqcWM9
	 SgtnRD+suD0UCtK5zMmdLwKPHfSkjRU/AG4kEW9x9mua3cHYjl+Ocoqe6ZTpkrUWDin/H
	 apz1Hq9SjjlIgbTu+EFNVhUU3D3fr6OMpmq6B+bCMLA9eNusBiGrdY/4DeINua46Gfydb
	 KRH0/NOCX33tRYkfsKZtEfirEJBfqcINkGUpS1zDrG8bKxWCURMPj0SpHD/zlsySMqQ==
ARC-Message-Signature: i=1; d=subspace.kernel.org; s=arc20261015;
	a=rsa-sha256; c=relaxed/relaxed; t=1793629310;
	h=Received:DKIM-Signature:From:Subject:Date:Message-Id:MIME-Version:
	 Content-Type:Content-Transfer-Encoding:X-B4-Tracking:X-Change-ID:
	 In-Reply-To:References:To:Cc:X-Mailer:X-Developer-Signature:
	 X-Developer-Key;
	bh=AKjVXDS7/7G3ahe8DshU2hjAAldvYiNw9Ybpn/C9WsE=;
	b=eeqLucWfwzmYQOXEM7wrrnIfoRs+lrpYL3YjHwYc6Htp8RmVyi7eK6xnwvBAX7plfSJ0
	 VwPImoMgki/4hbpmZyeYG9EBl7Mrv2a8rHuCqSyy3OfYXbPxLHD0kBCrp7JRM/xl/m2FN
	 O6gUfBZvNRxjdZbGhPwdzbPk9WcQ5hS1USoVONGp46gQFok6ulLF0R6ZRV5J3Is/i3i8/
	 Q4W0cGIz4cdjK/m+TsD7pLBpggmOG7SDsU0CvoQVLX6PTjuVk3meTFLifIKZkBzSxbj3x
	 DioOkQrfJwgXnhBhlDM4gruPdgHoQETXK1ifh0hwewvrQR6zD7+g9bHYx1f13hSbLTA==
ARC-Authentication-Results: i=1; smtp.subspace.kernel.org; 
	dkim=pass header.d=kernel.org header.i=@kernel.org header.a=rsa-sha256 header.s=k20260515 header.b=JJ7f2k4c;
	arc=none smtp.remote-ip=100.103.45.18
Received: from smtp.kernel.org (quasi.space.kernel.org [100.103.45.18])
	(using TLSv1.3 with cipher TLS_AES_256_GCM_SHA384 (256/256 bits)
	 key-exchange X25519 server-signature ECDSA (prime256v1))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id B720C606A32C;
	Mon,  2 Nov 2026 14:21:49 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key, unprotected) header.d=kernel.org header.i=@kernel.org header.a=rsa-sha256 header.s=k20260515 header.b=JJ7f2k4c
Received: by smtp.kernel.org (Postfix) with ESMTPSA id 035EC1F00A16;
	Mon,  2 Nov 2026 14:21:34 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=kernel.org;
	s=k20260515; t=1793629309;
	bh=AKjVXDS7/7G3ahe8DshU2hjAAldvYiNw9Ybpn/C9WsE=;
	h=From:Subject:Date:In-Reply-To:References:To:Cc;
	b=JJ7f2k4cU68wTicZeWKzQQfGVbEpkmDNTGKl80Agj5AqJZIHH3qRQfknBhjtLKc1k
	 s1fzxvLI1AqeAkCrA+g+8xX46AJ7KI81t8y1TTE7Xd0uWW1SNPwSJ6UNbtkzT3Lmtq
	 LwrFkz4F+CUYrvsN+m8f3T/ImxRrsSZFh057F3Z+EnaX30skxqBw16sluoqM0My/bK
	 u46Nwmm9Jd+2p/bFOTUuv8UEqUSUdyHdjWkHRiez9aqYTw6SDGdxR6S9l9cLSinNCP
	 V0sM+LfmNUdi0jKrnLUdT+ZNCbr1YhzpvdrAig/9QetGb9j+/Y+jmnYs2KokrkIu1Y
	 1DcsE8HgrAaiw==
From: Christian Brauner <brauner@kernel.org>
Subject: [PATCH RFC 00/38] proc: fix a few old bugs in /proc handlers
Date: Mon, 02 Nov 2026 15:21:15 +0100
Message-Id: <20261102-work-procfs-bugfixes-v1-0-59422ed3e465@kernel.org>
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
X-B4-Tracking: v=1; b=H4sIAAAAAAAC/yWMwQrCMBBEf6Xs2S1JqKJehX6AV/GQpNs2CknZt
 SqU/ruJPc6bmbeAEAcSOFcLML2DhBRz0LsK/GjjQBi6nMEoc9BaafwkfuLEyfeCbh768CVBtW8
 6pZQ5NicN+Tox/Yv8vMG1vcB9gzK7B/lXEZaZs0Lo2EY/FlTU9aauSwXr+gNYyfSLoAAAAA==
X-Change-ID: 20261101-work-procfs-bugfixes-054d00028491
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
 Chuck Lever <cel@kernel.org>, stable@vger.kernel.org
X-Mailer: b4 0.17-dev
X-Developer-Signature: v=1; a=openpgp-sha256; l=11786; i=brauner@kernel.org;
 h=from:subject:message-id; bh=sL1UI5hX39uHLdvK3RtrVQfZyGYI6aerMTpxK73Q95s=;
 b=owGbwMvMwCU28Zj0gdSKO4sYT6slMWS9mJPlpxzv8ehF0vpZEwJuZaifZ1Z+PNf929HM+wHfc
 nsaP90w7yhlYRDjYpAVU2RxaDcJl1vOU7HZKFMDZg4rE8gQBi5OAZjILxOG/2lTitXz5e6suHX6
 TNNrz7a29SuvnT+z614/47KmDU9imqwYGWa8eKda8/PBrtdcwYKHDZYXFuuZJLpueRwrmnw7/Iq
 ZCjsA
X-Developer-Key: i=brauner@kernel.org; a=openpgp;
 fpr=4880B8C9BD0E5106FC070F4F7B3C391EFEA93624

Moving procfs to what kernfs does touches just about every
->proc_read(), ->proc_write() and ->proc_ioctl() in the tree. Reviewing
that turned up a bunch of bugs that have nothing to do with the
conversion and are a lot older. They're fixed here first so they can go
to stable on their own and the conversion doesn't have to carry them.

Two of them matter for the conversion itself:

- proc_bus_pci_write() truncates the file position to an int. A
  pwrite() at an offset like 0xfffffc00 makes it negative and the loop
  then writes a lot more than it was handed into config space at
  negative offsets. Once procfs hands it a kernel copy of the write
  that's a heap out-of-bounds read, so this has to be fixed before the
  PCI conversion:

    BUG: KASAN: slab-out-of-bounds in proc_bus_pci_write+0x528/0x5c0
    Read of size 4 at addr ff11000112103b20 by task pci-check/241
    Call Trace:
     proc_bus_pci_write+0x528/0x5c0
     proc_reg_write+0x2d7/0x730
     vfs_write+0x1cd/0xfa0
     __x64_sys_pwrite64+0x191/0x250

  isapnp has the same bug on the read side.

- xt_recent removes the proc entries of its tables with a spinlock held
  when a network namespace goes away. remove_proc_entry() waits for the
  readers and a reader takes that very lock. That's a deadlock.

/proc/sys readdir resumes a listing at a counted position. The entries
are sorted by name, so a device that comes or goes in front of that
position shifts them and the next getdents64() repeats an entry or
skips one. Even ls needs a second call to find the end of a directory.
It resumes after the name of the last entry it returned now, the way
kernfs resumes after its last node, and a selftest lists a directory in
two pieces around a device coming and going. That one is first, it
goes to stable on its own.

/proc/sys also has the bug the conversion fixes for the rest of /proc.
proc_sys_call_handler() copies what is read and written and
proc_sys_readdir() copies the names of the entries to and from userspace
while the sysctl tables are in use. Unregistering a table waits until
nobody uses it anymore. So a read(), write() or getdents64() whose
buffer faults for as long as userspace wants keeps
unregister_sysctl_table() waiting. addrconf unregisters the ipv6 sysctls
of a device under RTNL, so that stalls every RTNL user. The handler
copies in before it grabs the table and out after letting go of it.
readdir doesn't take the tables into use at all anymore. It pins the
memory of the entry it is at, which unregistering doesn't wait for,
finds the next one under sysctl_lock and emits with nothing held, the
way kernfs_fop_readdir() and proc_readdir_de() work. That's the same
one trip through sysctl_lock per entry as before. A selftest covers all
three.

/proc symlinks have it as well. proc_get_link() pins the entry and
vfs_readlink() copies the link to userspace before the delayed call
unpins it. ALSA removes /proc/asound/<id> with snd_card_mutex and
info_mutex held when a card changes its id, so a faulting readlink()
holds those up. The pin keeps nothing alive, the inode holds
the entry, so it goes. A selftest covers that too.

Chris' review of the conversion turned up more old bugs, in procfs
itself and in its users. Those are here as well:

- __xlate_proc_name() walks through whatever it finds for the
  components of a name, regular files included, and pktgen hands it the
  names that the writer of "add_device" picks. So an unprivileged user
  in namespaces of its own can hang an entry below another file and get
  it freed behind pktgen's back. procfs doesn't walk through anything
  but directories anymore and pktgen refuses names with a '/'.

- SUNRPC moved the waitqueue that poll() and epoll use for its channel
  files into the cache_detail of a network namespace. That's freed when
  the namespace goes away, but procfs leaves the waiters of a removed
  file queued. That's a use-after-free an unprivileged user can trigger
  too. It goes back to a single static waitqueue. procfs should really
  own the waitqueues of its files like kernfs does. I'll do that
  separately, it's nothing for stable.

- proc_register() WARNs when a name is already registered, and pktgen
  lets userspace pick names that collide with its own files. It reports
  the duplicate with pr_warn() and a stack dump now, like sysfs does.

- proc_readdir_de() resumes at a counted position just like /proc/sys
  and on top of that ends a listing early when the entry it is emitting
  goes away. It resumes after the last name now too, and a selftest
  covers both.

- proc_remove() removes by name, so removing an entry that is already
  gone can take out a different one. It removes the entry it's given
  now. And procfs warns about entries that a dying network namespace
  leaves in /proc/net instead of silently freeing their parent.

- On NOMMU every /proc file can be mapped privately, which reads it with
  nommu_region_sem held, and reading /proc/maps takes that lock too. Any
  user can hang the machine with that. procfs files can't be mapped on
  NOMMU anymore.

- esas2r takes the lengths of its HBA, SMP and firmware ioctls from
  userspace without checking them against the buffer they're copied
  into, through a file everyone can open.

- vmcore_cleanup() can run twice at once. powerpc's copy_oldmem_page()
  doesn't check ioremap_cache() and only recovers from a machine check
  for read(), not for splice() or vmcore's own reads. The pseries ofdt
  parser can read past its input and lparcfg reports a failed hcall as
  a huge write.

The rest is small: dasd looks in front of its buffer on an empty write,
toshiba_acpi's input checks can't fail, simdisk reads the file name
without the lock that protects it, rtas_flash can read past its message
buffer, rtasd hands out whatever vmalloc() left in its log buffer,
ALSA's info layer doesn't clamp writes past the end of a data entry,
BusLogic, ips and libipw return 0 from writes so stdio writers spin
forever, the scsi host files and um's exitcode parse what is written
without NUL-terminating it, and ntfs3 warns when a huge label is
written.

The PCI, xt_recent, sysctl, readdir, readlink, pktgen, SUNRPC,
duplicate name and /proc readdir bugs reproduce on a KASAN and lockdep
kernel in a VM and are gone with the series. The rest is build tested
only.

The procfs conversion is on top of this, starting with "proc: let
procfs own the data path".

Signed-off-by: Christian Brauner (Amutable) <brauner@kernel.org>
---
Christian Brauner (38):
      PCI/proc: don't truncate the position of config space accesses
      PNP: isapnp: don't read past the end of the buffer on a large pread()
      netfilter: xt_recent: don't remove the proc entries under a spinlock
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
 arch/powerpc/kernel/rtas_flash.c                   |   2 +-
 arch/powerpc/kernel/rtasd.c                        |   2 +-
 arch/powerpc/platforms/pseries/lparcfg.c           |   2 +-
 arch/powerpc/platforms/pseries/reconfig.c          |  18 +-
 arch/um/kernel/exitcode.c                          |   3 +-
 arch/xtensa/platforms/iss/simdisk.c                |  25 +-
 drivers/net/wireless/intel/ipw2x00/libipw_module.c |   2 +-
 drivers/pci/proc.c                                 |  15 +-
 drivers/platform/x86/toshiba_acpi.c                |   8 +-
 drivers/pnp/isapnp/proc.c                          |   6 +-
 drivers/s390/block/dasd.c                          |   2 +-
 drivers/scsi/BusLogic.c                            |   2 +-
 drivers/scsi/esas2r/esas2r.h                       |   2 +-
 drivers/scsi/esas2r/esas2r_ioctl.c                 |  41 ++-
 drivers/scsi/esas2r/esas2r_main.c                  |   3 +-
 drivers/scsi/ips.c                                 |   2 +-
 drivers/scsi/scsi_proc.c                           |   1 +
 fs/ntfs3/super.c                                   |  11 +-
 fs/proc/generic.c                                  | 174 ++++++---
 fs/proc/inode.c                                    |  38 +-
 fs/proc/internal.h                                 |   1 +
 fs/proc/proc_net.c                                 |   7 +
 fs/proc/proc_sysctl.c                              | 389 ++++++++++++++-------
 fs/proc/root.c                                     |   1 +
 fs/proc/vmcore.c                                   |   5 +
 include/linux/sunrpc/cache.h                       |   1 -
 net/core/pktgen.c                                  |   4 +
 net/netfilter/xt_recent.c                          |   4 +-
 net/sunrpc/cache.c                                 |  12 +-
 sound/core/info.c                                  |   2 +
 tools/testing/selftests/proc/.gitignore            |   5 +
 tools/testing/selftests/proc/Makefile              |   5 +
 tools/testing/selftests/proc/config                |   6 +
 tools/testing/selftests/proc/proc-readdir-churn.c  | 236 +++++++++++++
 .../selftests/proc/proc-remove-slow-readlink.c     | 191 ++++++++++
 .../selftests/proc/proc-remove-slow-sysctl.c       | 213 +++++++++++
 .../selftests/proc/proc-sysctl-readdir-churn.c     | 147 ++++++++
 38 files changed, 1342 insertions(+), 252 deletions(-)
---
base-commit: 65ba8f34ec886ec72b2c07ddc8cf3d815c32869d
change-id: 20261101-work-procfs-bugfixes-054d00028491

