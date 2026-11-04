Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.remote-ip=100.103.45.18
ARC-Seal: i=1; d=subspace.kernel.org; s=arc20261015; a=rsa-sha256; cv=none;
	t=1793821347;
	b=X3iPobqr2dZcxsINKytMJxkVa6aSAyoYYkbvWV/jxypirh6GLoJRJR8RszAZ4jOcH+ne
	 WEQNQmbu7ZWrxZl76wExLOHCB81OUuDx4v7RScbp/q8zWtZcMQOmEry3+XT1VwLUrSRAk
	 touIuvIdiRpXZyjfUZzXbBSIRQHiGaxoMeX2RoF24cW3KaJyBjILfLkFD0gA4J8GGmuiB
	 7uV7k8nuJ46Y/CC+LW4QRAkVUHnjmMU1Ed08g5+wH5krgZGlFoYvDbgNx1MSn8uS1gusH
	 v6JziTeNPY7i5MS6U31MXj1o3ZwYUeXtiYlvsl3ulE9DUSPrNi3lWqy0t6vAnqTGIEw==
ARC-Message-Signature: i=1; d=subspace.kernel.org; s=arc20261015;
	a=rsa-sha256; c=relaxed/relaxed; t=1793821347;
	h=Received:DKIM-Signature:From:To:Cc:Subject:Date:Message-ID:
	 In-Reply-To:References:MIME-Version:Content-Type:X-Change-ID:X-Mailer:
	 X-Developer-Signature:X-Developer-Key:Content-Transfer-Encoding;
	bh=h//OaF9XF6OuytQdpTDkenswlUXBnTpq7KX5ptGy7O0=;
	b=Fl5zHcTnR2/eVgaRhPCyn40ydEAPGms+sbr5mdq204LkIPAhHq45bdUfbD0sOBMzelvf
	 eFlQEb4yp0rfUglmcI9hYaHhiZ4t+aeoQv88BKtGN2tL9xFV9JVQyJwuAzBWIfI6YBamj
	 Gr76OtPCh6knkvuy74W0uemp5tMjgdafy4avqChadeVCyb2WagS6N5PZSvley8Ffw3mlZ
	 S91LAwiws7yJmQnvC51Ora+09Ppq5K3b9U4ZuDjltswxLTCWFN6gWBjJAo6WiPa/bUwlo
	 /rYI5ENEnWYaCCVUPCrqxEELYv633VUXhmOrcZvVxtwbXbpwRBfpIL/mZHsvr49r/pg==
ARC-Authentication-Results: i=1; smtp.subspace.kernel.org; 
	dkim=pass header.d=kernel.org header.i=@kernel.org header.a=rsa-sha256 header.s=k20260515 header.b=gQ6D33zb;
	arc=none smtp.remote-ip=100.103.45.18
Received: from smtp.kernel.org (quasi.space.kernel.org [100.103.45.18])
	(using TLSv1.3 with cipher TLS_AES_256_GCM_SHA384 (256/256 bits)
	 key-exchange X25519 server-signature ECDSA (prime256v1))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 1A7B1606A326;
	Wed,  4 Nov 2026 19:42:26 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key, unprotected) header.d=kernel.org header.i=@kernel.org header.a=rsa-sha256 header.s=k20260515 header.b=gQ6D33zb
Received: by smtp.kernel.org (Postfix) with ESMTPSA id 6B49A1F000C1;
	Wed,  4 Nov 2026 19:42:14 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=kernel.org;
	s=k20260515; t=1793821346;
	bh=h//OaF9XF6OuytQdpTDkenswlUXBnTpq7KX5ptGy7O0=;
	h=From:To:Cc:Subject:Date:In-Reply-To:References;
	b=gQ6D33zbBn75XdTNgQSCUwa2/NjxDbLQNQnV/325ejI2UB5FUYC6+R4VLUGHaas13
	 7tqpKTfWKXp3xKD1YkzZSAwTaX4OJV29lTay6gDRduxpuwTo9wrIt+a7MSjAmTfQnH
	 5cQUiJmxGo6I4vawHEomerIZON0f5qOy6DStJ2G99rBVKyIHkFT+LIn0YRSCfWTjiI
	 ffaxHsNREnkZnIm/9H9PrtiNDtdXkzYosySFilOUaWUvzCKVWTjjW9DBs2k5lcTowQ
	 Nlhz+rYot83QCwRW1xNsdVsW6Jhv72EjVrgDZpfXEhz43rDtvrKY9BD6MAODP/TQx5
	 iDT2dH106gH/Q==
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
	Chuck Lever <cel@kernel.org>,
	Jiri Slaby <jirislaby@kernel.org>
Subject: [PATCH RESEND v2 00/26] proc: convert the driver entries (Part 4/7)
Date: Wed,  4 Nov 2026 20:42:12 +0100
Message-ID: <20261104-work-procfs-drivers-v2-0-245e54e87116@kernel.org>
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
X-Change-ID: 20261101-work-procfs-drivers-58cd83649658
X-Mailer: b4 0.17-dev
X-Developer-Signature: v=1; a=openpgp-sha256; l=12126; i=brauner@kernel.org; h=from:subject:message-id; bh=/Ke7GE1Lku+aW5nhVStvo53gUocaN49Ji1fBG+M5T6w=; b=owGbwMvMwCU28Zj0gdSKO4sYT6slMWS97ioKWnK2eJpQsjoH73N3nTvXWy3+Po9a2ie6tbsrp EpH89DRjlIWBjEuBlkxRRaHdpNwueU8FZuNMjVg5rAygQxh4OIUgInUbmT4py44+2RaWJFiUciz fe/a/QQkxZ9meaq2Ki9ktl3IIbLAl5Fh7pNs3wOVex003rW0fBS7/INpD8sTienMruxpxZN+q0k yAwA=
X-Developer-Key: i=brauner@kernel.org; a=openpgp; fpr=4880B8C9BD0E5106FC070F4F7B3C391EFEA93624
Content-Transfer-Encoding: 8bit

Part 4/7 of "proc: move procfs to what kernfs does", on top of part 2
and independent of parts 3, 5 and 6:

  https://patch.msgid.link/20261104-work-procfs-v2-0-b45cd5789ac5@brauner

This converts the proc entries of nubus, zorro, PCI, md, dasd and cio,
scsi, dell-smm, viafb, rndis, ipw2x00, sysrq, the input devices file and
ALSA to what "proc: let procfs own the data path" set up. Afterwards the
entries' code only runs with the entry pinned and never touches
userspace memory. One patch per subsystem and method.

- procfs owns the seq_file of the nubus resource files, /proc/mdstat,
  the scsi host files, sg's allow_dio and def_reserved_size and ALSA's
  text entries. Their open and release hooks only do what is left,
  private data or the event count, and reading a scsi host file or an
  ALSA entry no longer holds up the removal of the host or the card.
- procfs copies in the writes of the PCI config space,
  /proc/dasd/statistics, cio_ignore and cio_settle, /proc/scsi/scsi,
  device_info and the host files, sg, viafb, rndis, ipw2x00's debug
  level, /proc/sysrq-trigger and ALSA's entries. Most of them just parse
  procfs' copy. Where a write larger than anything the entry parses now
  fails with -EINVAL from procfs the commit says so.
- procfs copies out the reads of /proc/bus/zorro, the PCI config space
  and ALSA's data entries.
- the PCI config space and ALSA's data entries take binary data at
  positions and keep doing that, PROC_ENTRY_SHORT_WRITES for writes in
  pieces, and ALSA's data entries ask for PROC_ENTRY_FULL_READS so that
  reading all of one at once keeps working. They hand procfs' buffer to
  the drivers, so struct snd_info_entry_ops changes along with them.
- procfs copies the ioctl arguments of PCI, esas2r's ATTONode file and
  dell-smm's i8k in and out. The PCI commands only pass values and the
  i8k ones encode the wrong sizes, both tables list what is really
  copied. ALSA's ioctl hook that no driver implements goes away.
- /proc/mdstat and /proc/bus/input/devices move their pollers to the
  wait queue procfs owns for the entry, which ends md's wakeup loop at
  unload, and the poll op of an ALSA info entry, which nothing
  implements, loses its poll_table.

The selftest writes to the file of a scsi_debug host from a buffer
backed by userfaultfd and removes the host while procfs copies in. On a
KASAN and lockdep kernel it fails without the series and passes with it.
Build tested per commit on x86_64 and with W=1 on the touched objects on
their own architectures. The entries I could get at in a VM behave the
same with and without the series.

Signed-off-by: Christian Brauner (Amutable) <brauner@kernel.org>
---
Changes in v2:
- md and Input let procfs own the wait queues of /proc/mdstat and
  /proc/bus/input/devices, md's wakeup loop at unload is gone and
  /proc/mdstat is removed last, Input forgets the entry when it is
  removed, and the poll op of an ALSA info entry loses its poll_table
- the scsi_debug selftest skips without /proc/scsi and removes the host
  it added when its file can't be found
- Reviewed-by from Jiri on sysrq
- rebased onto v7.4-rc1
- Link to v1: https://patch.msgid.link/20261102-work-procfs-drivers-v1-0-a994bd4d3b1a@kernel.org

---
Christian Brauner (26):
      nubus: let procfs own the seq_file of the resource files
      zorro: let procfs copy out reads
      PCI/proc: let procfs copy in config space writes
      PCI/proc: let procfs copy out config space reads
      PCI/proc: let procfs handle the ioctls
      md: let procfs own the seq_file of /proc/mdstat
      md: let procfs own the wait queue of /proc/mdstat
      s390/dasd: let procfs copy in writes to /proc/dasd/statistics
      s390/cio: let procfs copy in writes
      scsi: let procfs own the seq_file of the host files
      scsi: core: let procfs copy in writes
      selftests/proc: check that a faulting writer doesn't hold up removal
      scsi: sg: let procfs own the seq_file of allow_dio and def_reserved_size
      scsi: sg: let procfs copy in writes
      scsi: esas2r: let procfs copy the ioctl argument of the ATTONode file
      hwmon: (dell-smm) let procfs copy the i8k ioctl arguments
      fbdev: viafb: let procfs copy in writes
      usb: gadget: function: rndis: let procfs copy in writes
      wifi: ipw2x00: let procfs copy in writes to the debug level
      tty: sysrq: let procfs copy in writes to /proc/sysrq-trigger
      Input: let procfs own the wait queue of /proc/bus/input/devices
      ALSA: info: let procfs own the seq_file of text entries
      ALSA: info: let procfs copy in writes
      ALSA: info: let procfs copy out reads of data entries
      ALSA: info: drop the ioctl hook of data entries
      ALSA: info: drop the poll_table from the info entry poll op

 .../sound/kernel-api/writing-an-alsa-driver.rst    |  10 +-
 drivers/hwmon/dell-smm-hwmon.c                     |  48 ++---
 drivers/input/input.c                              |  13 +-
 drivers/md/md.c                                    |  44 ++---
 drivers/net/wireless/intel/ipw2x00/libipw_module.c |   7 +-
 drivers/nubus/proc.c                               |  12 +-
 drivers/pci/proc.c                                 |  69 +++----
 drivers/s390/block/dasd_proc.c                     |  17 +-
 drivers/s390/cio/blacklist.c                       |  33 +---
 drivers/s390/cio/css.c                             |   4 +-
 drivers/scsi/esas2r/esas2r.h                       |   2 +
 drivers/scsi/esas2r/esas2r_ioctl.c                 |  58 +++---
 drivers/scsi/esas2r/esas2r_main.c                  |  44 ++++-
 drivers/scsi/scsi_devinfo.c                        |  29 +--
 drivers/scsi/scsi_proc.c                           |  55 ++----
 drivers/scsi/sg.c                                  |  44 ++---
 drivers/tty/sysrq.c                                |   9 +-
 drivers/usb/gadget/function/rndis.c                |   9 +-
 drivers/video/fbdev/via/viafbdev.c                 |  46 +++--
 drivers/zorro/proc.c                               |   7 +-
 include/sound/gus.h                                |   2 +-
 include/sound/info.h                               |   9 +-
 sound/core/info.c                                  |  59 +++---
 sound/drivers/opl4/opl4_proc.c                     |  23 +--
 sound/isa/gus/gus_dram.c                           |   7 +-
 sound/isa/gus/gus_mem_proc.c                       |   2 +-
 sound/pci/cs4281.c                                 |  10 +-
 sound/pci/cs46xx/cs46xx_lib.c                      |   5 +-
 sound/pci/emu10k1/emuproc.c                        |   8 +-
 sound/pci/mixart/mixart.c                          |  10 +-
 sound/usb/mixer_scarlett2.c                        |   9 +-
 tools/testing/selftests/proc/.gitignore            |   1 +
 tools/testing/selftests/proc/Makefile              |   1 +
 tools/testing/selftests/proc/config                |   3 +
 .../selftests/proc/proc-remove-slow-writer.c       | 209 +++++++++++++++++++++
 35 files changed, 503 insertions(+), 415 deletions(-)
---
base-commit: 6628e7d4c6b25c8d18f1345e3a20d21829aae7e4
change-id: 20261101-work-procfs-drivers-58cd83649658
prerequisite-change-id: 20261101-work-procfs-core-8fa4a4f412cf:v2
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

