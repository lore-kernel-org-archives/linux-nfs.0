Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.remote-ip=100.103.45.18
ARC-Seal: i=1; d=subspace.kernel.org; s=arc20261015; a=rsa-sha256; cv=none;
	t=1793820952;
	b=ENOZ3/a2vlCXOsEDFiwWy8oVv+zB+jH+qWb1xwhY4qYNnBq4g8HqfQAFQQVzMzkjwk5P
	 IOm2cstSs+cDyX3gQ3imGF7hJicf7qjCAzSEFoBmQ6yTty6/bempMnv/ua39hNiffIKSm
	 2r9aeoM7X93xH4tkRQcW6QpWQn9+Dme5OwMkV16qPZQq0FCiCB2pCMs8k5S+3gCJrRvSr
	 MdSCSS5Xa5lbnekMOIecGH1porxwP6+yx710A7ORuFAItsaagh+CGv0AyOfJFcGq+4B++
	 V1rKXBEyd7Ht7vFuFVaPXpyX+e8lP2avgW/5zDIZdXDk0iXC7YWdA/aaZyEaAfgr1ew==
ARC-Message-Signature: i=1; d=subspace.kernel.org; s=arc20261015;
	a=rsa-sha256; c=relaxed/relaxed; t=1793820952;
	h=Received:DKIM-Signature:From:To:Cc:Subject:Date:Message-ID:
	 In-Reply-To:References:MIME-Version:Content-Type:X-Change-ID:X-Mailer:
	 X-Developer-Signature:X-Developer-Key:Content-Transfer-Encoding;
	bh=JLj8qUmOxG8v+4vkiBPzRKoIk8eoD2QLdzNBq5yfolE=;
	b=2HSVmE+SqVBvhdXo37rcnM2KBUW795P6WpNsjs5szdKCRsD5IFxBWAOH5urxsT/eDIdK
	 Nzx9otVr7hICxkq32jPlGQvWWbX2culNAlNt7MKhJlsx4bee86yCC2gUvHaoS48k4GnnZ
	 Y+0OpFZC/u/YMNotwBYb7euonTlZGJV+8cz4QcdGnDqhCfSA9aPO5ZlVlSkSS+pcr5lqG
	 9Fl9Aa3YhxTEo+5H+wklXZ478CArCzmJifxVE9qpmNYhHyHay5n5VwsbhljrgmSJPklot
	 TPF3kIljxiSQ4FM7ZDuTavhFX1lqP8lnQtJnY2M1XvqDZ5kq3pv5g3Nsy90QZ8umrnQ==
ARC-Authentication-Results: i=1; smtp.subspace.kernel.org; 
	dkim=pass header.d=kernel.org header.i=@kernel.org header.a=rsa-sha256 header.s=k20260515 header.b=b+rC1vw+;
	arc=none smtp.remote-ip=100.103.45.18
Received: from smtp.kernel.org (quasi.space.kernel.org [100.103.45.18])
	(using TLSv1.3 with cipher TLS_AES_256_GCM_SHA384 (256/256 bits)
	 key-exchange X25519 server-signature ECDSA (prime256v1))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 6EDE9606EEAB;
	Wed,  4 Nov 2026 19:35:52 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key, unprotected) header.d=kernel.org header.i=@kernel.org header.a=rsa-sha256 header.s=k20260515 header.b=b+rC1vw+
Received: by smtp.kernel.org (Postfix) with ESMTPSA id 082D81F000C1;
	Wed,  4 Nov 2026 19:35:39 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=kernel.org;
	s=k20260515; t=1793820952;
	bh=JLj8qUmOxG8v+4vkiBPzRKoIk8eoD2QLdzNBq5yfolE=;
	h=From:To:Cc:Subject:Date:In-Reply-To:References;
	b=b+rC1vw+u0giGnhmNK2PaCSZhvh8IQYMvAt0GMDPbM8PtauDqkuQfwxrhz09Jxt0H
	 RhhBZWMhi3WerjCjDIghmahUUrm6g6C7Tl3QGgArvvK2zhi4wVw+rH9319WMJyFvrx
	 UKYqgEVai/b1ZKhe1nszmBA1S6GmRy1xJIhSmePB9IxIlpPgMNoGkSkDvH5JDog8PI
	 mmeZ/UiAGafxLjdgB0i9GFVsqok4ki20v0iWi6BkUQiDmJs0ph5nqCVxMpo4L7P102
	 WpH0qgr2XT6JgnfTwELlo0C2toSHizUYgk8SQqa4n0wOVT86XRpvv+pKCNlK/qGDVe
	 eJDiWZiF0ih+Q==
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
Subject: [PATCH RESEND v2 00/23] proc: convert the arch and platform entries (Part 3/7)
Date: Wed,  4 Nov 2026 20:35:37 +0100
Message-ID: <20261104-work-procfs-arch-v2-0-2aeb952c9597@kernel.org>
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
X-Change-ID: 20261101-work-procfs-arch-8d4ade48be31
X-Mailer: b4 0.17-dev
X-Developer-Signature: v=1; a=openpgp-sha256; l=9990; i=brauner@kernel.org; h=from:subject:message-id; bh=We2l4X25hmir4pnoYpHOHa+cUJRdJP3mhCPydhALQB8=; b=owGbwMvMwCU28Zj0gdSKO4sYT6slMWS97niTacO/1D+hNOHTua5Hp25vnnLWNTzHb5GOzPVtq 64+2XTmVEcpC4MYF4OsmCKLQ7tJuNxynorNRpkaMHNYmUCGMHBxCsBE1HkY/lew3437yFAsbXbd WF5Z0eSK8xHJB/Kn3h1hZ41eVOlzuJuRoXMDf7dOioTwygkGyrIftZQWOi/edHnpTKnPbgdd5RI quQE=
X-Developer-Key: i=brauner@kernel.org; a=openpgp; fpr=4880B8C9BD0E5106FC070F4F7B3C391EFEA93624
Content-Transfer-Encoding: 8bit

Part 3/7 of "proc: move procfs to what kernfs does", on top of part 2
and independent of parts 4 to 6:

  https://patch.msgid.link/20261104-work-procfs-v2-0-b45cd5789ac5@brauner

This converts the proc entries under arch/ and the ones of ACPI, the
platform drivers, via-pmu and PNP to what "proc: let procfs own the data
path" set up. Afterwards the entries' code only runs with the entry
pinned and never touches userspace memory. One patch per subsystem and
method.

- procfs copies in the writes of alpha's srm_env, the ARM and sh
  alignment files, the rtas, pseries, mconsole and exitcode files,
  sparc's led, /proc/mtrr, simdisk, /proc/acpi/wakeup, via-pmu's
  options, thinkpad_acpi, toshiba_acpi and pnpbios. Most of them just
  stop copying in themselves or switch from kstrto*_from_user() to
  kstrto*(). Where a write larger than anything the entry parses now
  fails with -EINVAL from procfs the commit says so.
- procfs copies out the reads of /proc/atags, /proc/bootinfo, the rtas
  error log and flash files, /proc/powerpc/systemcfg, simdisk and
  /proc/bus/isapnp, mostly simple_read_from_buffer() turned into
  memory_read_from_buffer().
- procfs owns the seq_file of /proc/mtrr and copies its ioctl arguments
  in and out. The ioctls are table driven now, the native and the 32-bit
  commands share one table.
- the rtas flash files take their image in 4k pieces and keep doing that
  with PROC_ENTRY_SHORT_WRITES.
- the rtas error log is a stream, it hands out a record before procfs
  copies it out, so a reader that passes a bad buffer loses it. Its
  pollers sleep on the wait queue procfs owns for the entry now and
  rtasd wakes them with proc_poll_notify().

Build tested per commit on x86_64 and with W=1 on the touched objects on
alpha, arm, m68k, powerpc, sh, sparc, um, x86 and xtensa. The entries I
could get at in an x86 VM behave the same with and without the series.

Signed-off-by: Christian Brauner (Amutable) <brauner@kernel.org>
---
Changes in v2:
- rtasd lets procfs own the wait queue of the rtas error log
- rebased onto v7.4-rc1, the thinkpad_acpi write merged with its
  cleanup.h restyle upstream
- Link to v1: https://patch.msgid.link/20261102-work-procfs-arch-v1-0-c9492ab08480@kernel.org

---
Christian Brauner (23):
      alpha: srm_env: let procfs copy in writes
      ARM: alignment: let procfs copy in writes
      ARM: atags: let procfs copy out reads of /proc/atags
      m68k/bootinfo: let procfs copy out reads of /proc/bootinfo
      powerpc/rtas: let procfs copy in writes
      powerpc/rtas: let procfs copy out reads
      powerpc/rtasd: let procfs own the wait queue of the rtas error log
      powerpc/pseries: let procfs copy in writes
      powerpc/procfs: let procfs copy out reads of /proc/powerpc/systemcfg
      sh: alignment: let procfs copy in writes
      sparc: led: let procfs copy in writes
      um: let procfs copy in writes
      x86/mtrr: let procfs own the seq_file of /proc/mtrr
      x86/mtrr: let procfs copy in writes to /proc/mtrr
      x86/mtrr: let procfs copy the ioctl arguments of /proc/mtrr
      xtensa: simdisk: let procfs copy in writes
      xtensa: simdisk: let procfs copy out reads
      ACPI: proc: let procfs copy in writes to /proc/acpi/wakeup
      macintosh/via-pmu: let procfs copy in writes to the options file
      platform/x86: thinkpad_acpi: let procfs copy in writes
      platform/x86: toshiba_acpi: let procfs copy in writes
      PNP: pnpbios: let procfs copy in writes
      PNP: isapnp: let procfs copy out reads

 arch/alpha/kernel/srm_env.c                 | 12 +---
 arch/arm/kernel/atags_proc.c                |  6 +-
 arch/arm/mm/alignment.c                     |  7 +--
 arch/m68k/kernel/bootinfo_proc.c            |  6 +-
 arch/powerpc/kernel/proc_powerpc.c          |  6 +-
 arch/powerpc/kernel/rtas-proc.c             | 40 ++++++------
 arch/powerpc/kernel/rtas_flash.c            | 62 +++++++++----------
 arch/powerpc/kernel/rtasd.c                 | 30 +++------
 arch/powerpc/platforms/pseries/lpar.c       | 14 ++---
 arch/powerpc/platforms/pseries/lparcfg.c    |  7 +--
 arch/powerpc/platforms/pseries/reconfig.c   | 22 +++----
 arch/sh/mm/alignment.c                      |  7 +--
 arch/sparc/kernel/led.c                     | 12 +---
 arch/um/drivers/mconsole_kern.c             | 11 +---
 arch/um/kernel/exitcode.c                   | 14 ++---
 arch/x86/kernel/cpu/mtrr/if.c               | 95 ++++++++++++++++-------------
 arch/xtensa/platforms/iss/simdisk.c         | 32 ++++------
 drivers/acpi/proc.c                         |  7 +--
 drivers/macintosh/via-pmu.c                 |  7 +--
 drivers/platform/x86/lenovo/thinkpad_acpi.c | 12 +---
 drivers/platform/x86/toshiba_acpi.c         | 36 ++++-------
 drivers/pnp/isapnp/proc.c                   | 20 +++---
 drivers/pnp/pnpbios/proc.c                  |  9 +--
 23 files changed, 198 insertions(+), 276 deletions(-)
---
base-commit: 6628e7d4c6b25c8d18f1345e3a20d21829aae7e4
change-id: 20261101-work-procfs-arch-8d4ade48be31
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

