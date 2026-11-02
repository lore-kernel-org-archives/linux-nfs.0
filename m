Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.remote-ip=100.103.45.18
ARC-Seal: i=1; d=subspace.kernel.org; s=arc20261015; a=rsa-sha256; cv=none;
	t=1793633760;
	b=bX2UhHB3a5irWiXMTwf2g2RXeVMkA6kIQGpClytWEAF1EedE92brPjj0YaVmW7ZM1AEG
	 zHeu4NMHyAjy/2m6bI6M7mzPs0DMV7FPdL7dZja1e83lZtjxOwDvgZV12sOlQ8H89A0fu
	 QECVugU3Zqcprc3w8zMSkIr4A8Vp2M5Of4ditGmNFoNViDyjKwSzwcSl1GoMd6iuFGp44
	 NRfXKgEPshCt/yg1P5/CdwvyIxoTAisnvMzjgVFYDDbbZWLboEb+nKSCrLayehS1PhFoV
	 T/9xsmONxsFZ2E6Hu8ouCOKQhY+vK/INrbhyMz0yAeD2WO5hRtqGKItv59PD5XaCSfw==
ARC-Message-Signature: i=1; d=subspace.kernel.org; s=arc20261015;
	a=rsa-sha256; c=relaxed/relaxed; t=1793633760;
	h=Received:DKIM-Signature:From:Subject:Date:Message-Id:MIME-Version:
	 Content-Type:Content-Transfer-Encoding:X-B4-Tracking:X-Change-ID:
	 In-Reply-To:References:To:Cc:X-Mailer:X-Developer-Signature:
	 X-Developer-Key;
	bh=b7Pg2eHdxGlrjHkXTu7b1j1ETVV0dfMkZ6acXkqs+5k=;
	b=j/JjcIh1liQMk3zVZoI6Z+XfDEdpHeWZacefkFhEr+b4/kE59sT4bKw234kpnZdv6pbP
	 D1rgyM4nmXN/MHIoOfYfqeYcC4DwHJj4axQuFsir+XO2+/6O5q5Bz7vz1a7MIcE+2Dxx1
	 C84MT+s2X26kft7LfqYOkhlt+Mz1DRRwGil/dW1bpvKouh1f3UwiRcCZ++ESpFgDuxBMi
	 xwbuc5DWIt+ODxFX0B+fED9kGYCPxeKXCLvV6iYngS33cewMAoDCzOAF2WZ8UMPnY1hu1
	 ryQntUhXJybY7tILSUtuJAoLJQzUf9kbfQS+TSH5zWbUqlfNYq4U9C8bbZ5Q1ISPKRA==
ARC-Authentication-Results: i=1; smtp.subspace.kernel.org; 
	dkim=pass header.d=kernel.org header.i=@kernel.org header.a=rsa-sha256 header.s=k20260515 header.b=XNS1kQZm;
	arc=none smtp.remote-ip=100.103.45.18
Received: from smtp.kernel.org (quasi.space.kernel.org [100.103.45.18])
	(using TLSv1.3 with cipher TLS_AES_256_GCM_SHA384 (256/256 bits)
	 key-exchange X25519 server-signature ECDSA (prime256v1))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 7E119606BA4E;
	Mon,  2 Nov 2026 15:35:59 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key, unprotected) header.d=kernel.org header.i=@kernel.org header.a=rsa-sha256 header.s=k20260515 header.b=XNS1kQZm
Received: by smtp.kernel.org (Postfix) with ESMTPSA id 686781F00A16;
	Mon,  2 Nov 2026 15:35:37 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=kernel.org;
	s=k20260515; t=1793633759;
	bh=b7Pg2eHdxGlrjHkXTu7b1j1ETVV0dfMkZ6acXkqs+5k=;
	h=From:Subject:Date:In-Reply-To:References:To:Cc;
	b=XNS1kQZmrl1Q+fxQWTBJtN3IQdYimsMG366zndSkOF79El1Ky8v4UA5a8TriSwk5H
	 Hs+zITwd9Jp2Z5W78L3jPLqgJXiS8U6xLCbc2ZFc3qqPJZtHVGnVPN9xIyc6oFvTyv
	 FlS6MuPbXpKi+fevCw3CU0nARBAqIOJ1YrShlgxlWdOG3c4pdtuq4r1rQzwJ1VjhAx
	 WjVmRHCJZ50F7R0GNmEJL5mmpEwH+FDwO8X/9agAujyVtSsQjFFF8rxAPIvW2TZebl
	 x/gaisL0on9n0LsrCQwYzrjQJ9VP+SGNnAkh/Vg37umO2QReulFUK847OZwIejEd3d
	 5SinwPbDYJWeQ==
From: Christian Brauner <brauner@kernel.org>
Subject: [PATCH RFC 0/5] proc: drop the __user methods
Date: Mon, 02 Nov 2026 16:15:53 +0100
Message-Id: <20261102-work-procfs-cleanup-v1-0-c40014bc12f5@kernel.org>
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
X-B4-Tracking: v=1; b=H4sIAAAAAAAC/42QwW6DMAyGXwXlvFSEhGC4TtoD7Dr1kDjOyLoCS
 4BNqvruA4qm7TCpki+2/H367QtLFAMl1mQXFmkOKfTd0oiHjGFrulfiwS09K/JCi1zm/LOPJz7
 EHn3i+E6mmwYudK18JawVpWYLOUTy4WuzvrDnp0d2vA3TZN8Ix9W3rlmTiNtoOmzX0Wo+3MyHj
 sZdFOljWlKNu+0nVJNtkUQu/kQyEVsOThlHCixJ0cyC/T7mH87FMFNMvAR0ILWqdQl3oksp4Wv
 vUEGN9k5quZBbBFsIkuR9vmPbT7A/n8PYZLq0BrxUhACasCpsgXnlHAJ66UCUKAvQtWPH6/Ubh
 FALZ8oBAAA=
X-Change-ID: 20261030-work-procfs-cleanup-1694f71bb156
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
X-Developer-Signature: v=1; a=openpgp-sha256; l=34892; i=brauner@kernel.org;
 h=from:subject:message-id; bh=iA4LisBTuw6fqu6bSILNXKnFopnLtxRDGYy9ks8EgZ4=;
 b=owGbwMvMwCU28Zj0gdSKO4sYT6slMWS9WBlbcv4666belW07nn2QfFigbZZ97VN6TA+z7hrvr
 XvfHX5g1VHKwiDGxSArpsji0G4SLrecp2KzUaYGzBxWJpAhDFycAjARvj6G36wK/NIy76/LrHtr
 uvFiyNJp/5IvJj5Y2tgom2BxvuriiRCGf5qpBhItYd3K3VmLp+ubSJrNrNZc/D7T82/B6vrkSzW
 bGQA=
X-Developer-Key: i=brauner@kernel.org; a=openpgp;
 fpr=4880B8C9BD0E5106FC070F4F7B3C391EFEA93624

This is the last part of moving procfs to what kernfs does. Every entry
that can be removed reads, writes and handles ioctls through procfs'
buffers now, so its code only runs with the entry pinned and never
touches userspace memory.

Drop ->proc_write(), ->proc_ioctl() and ->proc_compat_ioctl(). Keep
->proc_read() and ->proc_read_iter() for the entries that are never
removed, kcore, kmsg, the kpage files and /proc/profile. procfs never
pins those, so nothing can wait for them. procfs refuses to register an
entry that can be removed and has one of them.

With the old names free the _buf suffix of the new methods doesn't say
anything anymore, so ->proc_write_buf(), ->proc_read_buf() and
->proc_ioctl_buf() become ->proc_write(), ->proc_read() and
->proc_ioctl() at the end, which is what kernfs calls its read and
write as well. That's one mechanical patch over all the converted
entries.

With the whole stack on a KASAN and lockdep kernel the removal
selftests of all parts pass, the proc, pktgen and allocinfo selftests
behave like without it and the permanent entries read like before.

This is on top of the four conversion series, "proc: convert the arch
and platform entries", "proc: convert the driver entries", "proc:
convert the fs, kernel and mm entries" and "proc: convert the net
entries and the kfifo samples".

Signed-off-by: Christian Brauner (Amutable) <brauner@kernel.org>
---
Christian Brauner (5):
      proc: drop ->proc_write()
      proc: drop ->proc_ioctl() and ->proc_compat_ioctl()
      proc: only let permanent entries read straight into userspace
      proc: rename ->proc_read() and ->proc_read_iter()
      proc: drop the _buf suffix from the new methods

 arch/alpha/kernel/srm_env.c                        |   2 +-
 arch/arm/kernel/atags_proc.c                       |   2 +-
 arch/arm/mm/alignment.c                            |   2 +-
 arch/m68k/kernel/bootinfo_proc.c                   |   2 +-
 arch/powerpc/kernel/proc_powerpc.c                 |   2 +-
 arch/powerpc/kernel/rtas-proc.c                    |  10 +-
 arch/powerpc/kernel/rtas_flash.c                   |  16 ++--
 arch/powerpc/kernel/rtasd.c                        |   2 +-
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
 drivers/macintosh/via-pmu.c                        |   2 +-
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
 drivers/video/fbdev/via/viafbdev.c                 |  14 +--
 drivers/zorro/proc.c                               |   2 +-
 fs/jfs/jfs_debug.c                                 |   2 +-
 fs/lockd/procfs.c                                  |   4 +-
 fs/ntfs3/super.c                                   |   2 +-
 fs/proc/generic.c                                  |  33 ++++---
 fs/proc/inode.c                                    | 103 ++++++---------------
 fs/proc/internal.h                                 |  17 ++--
 fs/proc/kcore.c                                    |   2 +-
 fs/proc/kmsg.c                                     |   2 +-
 fs/proc/page.c                                     |   6 +-
 fs/proc/proc_net.c                                 |   4 +-
 fs/proc/vmcore.c                                   |   2 +-
 fs/smb/client/cifs_debug.c                         |  16 ++--
 fs/smb/client/dfs_cache.c                          |   2 +-
 include/linux/proc_fs.h                            |  39 ++++----
 kernel/configs.c                                   |   2 +-
 kernel/irq/proc.c                                  |   6 +-
 kernel/latencytop.c                                |   2 +-
 kernel/locking/lockdep_proc.c                      |   2 +-
 kernel/profile.c                                   |   4 +-
 kernel/sched/psi.c                                 |   8 +-
 lib/dynamic_debug.c                                |   2 +-
 mm/alloc_tag.c                                     |   2 +-
 net/atm/proc.c                                     |   2 +-
 net/core/pktgen.c                                  |   6 +-
 net/netfilter/xt_recent.c                          |   2 +-
 net/sunrpc/auth_gss/svcauth_gss.c                  |   6 +-
 net/sunrpc/cache.c                                 |   8 +-
 samples/kfifo/bytestream-example.c                 |   4 +-
 samples/kfifo/inttype-example.c                    |   4 +-
 samples/kfifo/record-example.c                     |   4 +-
 sound/core/info.c                                  |   6 +-
 68 files changed, 195 insertions(+), 237 deletions(-)
---
base-commit: 65ba8f34ec886ec72b2c07ddc8cf3d815c32869d
change-id: 20261030-work-procfs-cleanup-1694f71bb156
prerequisite-change-id: 20261101-work-procfs-arch-8d4ade48be31:v1
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
prerequisite-patch-id: 117db27dcdef433de7c6be5e95973cac1e373927
prerequisite-patch-id: a0844aa26ffb65ccb362b88ef6c2f4758e15edbf
prerequisite-patch-id: 143fb91bddf33068b6ee11e205818c4c2815e23d
prerequisite-patch-id: 6490e4da1cb2f543683bd164bc9a5a1c943057e7
prerequisite-patch-id: cdefca57d3c552fb6f6b928699edd85f33be25fd
prerequisite-patch-id: 2f0fdb970ddd760d85ff5d2caad0b96348270182
prerequisite-patch-id: f2aa468ff5cbb1cabab3f70e1b8eeee0286cfb4a
prerequisite-patch-id: 037030d95eeb7c49b1e43f638ec954f2cebbcfb1
prerequisite-patch-id: 487141c49e2548310bfb6c2a0964a78f08b285a9
prerequisite-patch-id: c3d3008819fa5629a18142ec9ba6d7024ade7fdb
prerequisite-patch-id: ba15e7c86b60ccc2f0f7ee4c9bc99073068757bc
prerequisite-patch-id: 9423f410b99853693db06c29f12f1c08278b050d
prerequisite-patch-id: 4e7966978e4b11c4d843831f312cdcd5b848f00c
prerequisite-patch-id: 3d24be1897a624d519ef144801f76d152c7528a9
prerequisite-patch-id: 3b4d9fe7b26f6b7b9b3f7725ea333df357107c44
prerequisite-patch-id: 7d9dd345428baeb88c862ef902612f7160dc1d8c
prerequisite-patch-id: 504e13cb7af5da6f3c8503f9336116ddd6ee9fc0
prerequisite-patch-id: 079f5420c7c6660679b25a93ab2912b42af19d6d
prerequisite-patch-id: 717bfde0d4141e875562d62b0e3c22d687517462
prerequisite-patch-id: 3e465d93cacbb875c5508b106bcaae53665de29e
prerequisite-patch-id: da2eff4c67005d05b39c39d6d164b94c2837a4dd
prerequisite-patch-id: a293472d78b43026dacbfe22a34ba1f8f2626e63
prerequisite-patch-id: 56469933009bbfd5a57d843f698f91bb0cdd846a
prerequisite-patch-id: 16433e5bde53510f9e6b7e04db2279bd0a8f63f5
prerequisite-patch-id: 03d349761a5a56d223067b051b1a38d594006ae2
prerequisite-patch-id: 9112aaf35b0ab26bf396285fbfbb51b81901d80b
prerequisite-patch-id: 901a0c1b4c2da010722471826fbfc51402ab8573
prerequisite-patch-id: 1204b4883154dea8cb7d93efadb9f49e70ecd7a8
prerequisite-patch-id: d2762d5dd1254bf7cf89a16b317b7b421718935f
prerequisite-patch-id: d1337f7a08fd4758a94bc5b2faeb30cbad1fe9cf
prerequisite-patch-id: a1d46785e75f0ec87cd12807cb57adc869a7f6a8
prerequisite-patch-id: 44c5d2365c5237b44a0162be9e73dcb392deab2c
prerequisite-patch-id: ad7ca39e7946dbf9e9ed4677b577bb5efad15af5
prerequisite-patch-id: 3984bbb1dbd74d87215a789483a75e968e81b453
prerequisite-patch-id: 0db54371960496caafd93db8801125a92f43d6c6
prerequisite-patch-id: 4d97d31af7bca868bf68a61fe7825dcbd7cc500b
prerequisite-patch-id: 227908b78f668bc6301cfa2217fa581471176b0f
prerequisite-patch-id: d4fba49d9b4aaee2cc42d91651041faa4b1a4d38
prerequisite-change-id: 20261101-work-procfs-drivers-58cd83649658:v1
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
prerequisite-patch-id: 117db27dcdef433de7c6be5e95973cac1e373927
prerequisite-patch-id: a0844aa26ffb65ccb362b88ef6c2f4758e15edbf
prerequisite-patch-id: 143fb91bddf33068b6ee11e205818c4c2815e23d
prerequisite-patch-id: 6490e4da1cb2f543683bd164bc9a5a1c943057e7
prerequisite-patch-id: cdefca57d3c552fb6f6b928699edd85f33be25fd
prerequisite-patch-id: 2f0fdb970ddd760d85ff5d2caad0b96348270182
prerequisite-patch-id: f2aa468ff5cbb1cabab3f70e1b8eeee0286cfb4a
prerequisite-patch-id: 037030d95eeb7c49b1e43f638ec954f2cebbcfb1
prerequisite-patch-id: 487141c49e2548310bfb6c2a0964a78f08b285a9
prerequisite-patch-id: c3d3008819fa5629a18142ec9ba6d7024ade7fdb
prerequisite-patch-id: ba15e7c86b60ccc2f0f7ee4c9bc99073068757bc
prerequisite-patch-id: 9423f410b99853693db06c29f12f1c08278b050d
prerequisite-patch-id: 4e7966978e4b11c4d843831f312cdcd5b848f00c
prerequisite-patch-id: 3d24be1897a624d519ef144801f76d152c7528a9
prerequisite-patch-id: 3b4d9fe7b26f6b7b9b3f7725ea333df357107c44
prerequisite-patch-id: 7d9dd345428baeb88c862ef902612f7160dc1d8c
prerequisite-patch-id: 504e13cb7af5da6f3c8503f9336116ddd6ee9fc0
prerequisite-patch-id: 079f5420c7c6660679b25a93ab2912b42af19d6d
prerequisite-patch-id: 717bfde0d4141e875562d62b0e3c22d687517462
prerequisite-patch-id: 3e465d93cacbb875c5508b106bcaae53665de29e
prerequisite-patch-id: da2eff4c67005d05b39c39d6d164b94c2837a4dd
prerequisite-patch-id: a293472d78b43026dacbfe22a34ba1f8f2626e63
prerequisite-patch-id: 56469933009bbfd5a57d843f698f91bb0cdd846a
prerequisite-patch-id: 16433e5bde53510f9e6b7e04db2279bd0a8f63f5
prerequisite-patch-id: 03d349761a5a56d223067b051b1a38d594006ae2
prerequisite-patch-id: 9112aaf35b0ab26bf396285fbfbb51b81901d80b
prerequisite-patch-id: 901a0c1b4c2da010722471826fbfc51402ab8573
prerequisite-patch-id: 1204b4883154dea8cb7d93efadb9f49e70ecd7a8
prerequisite-patch-id: d2762d5dd1254bf7cf89a16b317b7b421718935f
prerequisite-patch-id: d1337f7a08fd4758a94bc5b2faeb30cbad1fe9cf
prerequisite-patch-id: a1d46785e75f0ec87cd12807cb57adc869a7f6a8
prerequisite-patch-id: 44c5d2365c5237b44a0162be9e73dcb392deab2c
prerequisite-patch-id: ad7ca39e7946dbf9e9ed4677b577bb5efad15af5
prerequisite-patch-id: 3984bbb1dbd74d87215a789483a75e968e81b453
prerequisite-patch-id: 0db54371960496caafd93db8801125a92f43d6c6
prerequisite-patch-id: 4d97d31af7bca868bf68a61fe7825dcbd7cc500b
prerequisite-patch-id: 227908b78f668bc6301cfa2217fa581471176b0f
prerequisite-patch-id: d4fba49d9b4aaee2cc42d91651041faa4b1a4d38
prerequisite-patch-id: fd779ec9acd1cd56b7eb9176cd0a10a548133f0c
prerequisite-patch-id: 5c61093340a745890222477d54f21e1121643c95
prerequisite-patch-id: 1199e9ee338002117fbe257118ff264e64eec0bb
prerequisite-patch-id: 08be0388a5aafb66919d0d678380c33f092738ce
prerequisite-patch-id: f98799e2973376543e67ae7a93ab62a20aa29564
prerequisite-patch-id: f670bed1eba8e1440bbfed164fb0c367f248e231
prerequisite-patch-id: 88a5543ceb70d27bd05b718480334d0a28133697
prerequisite-patch-id: 544f65704decf1a67848c8dc68ac60c5b76cdb81
prerequisite-patch-id: f36fad7a6eb02bf1b3c1171a61cbb854794bdf63
prerequisite-patch-id: 03a4a6747171c25f622df537a7608a4058acfc2c
prerequisite-patch-id: 7079fdab6ec5000d3a7b4868e138e9177bf03945
prerequisite-patch-id: 8483765548e3cdbd16e0a9ef44e9c60941611b12
prerequisite-patch-id: 6643c2dbd00ab86e742ef5a15f4d23c039575f07
prerequisite-patch-id: 9f288cab3b89ff67865b4e20c7b7f6f3835cec6f
prerequisite-patch-id: 6c8bae764061f224f8bf6bfb0a58b44689d1fb85
prerequisite-patch-id: c2d5675bad1219323ceb4f7c382dea8ef654256f
prerequisite-patch-id: f5fd02ee0a5960d146eba2f57ecf9ccb15a1b216
prerequisite-patch-id: d12cfa9299bb33218551b98efc8d2af8bb2ef321
prerequisite-patch-id: 889b86d3e246e3d6b4cd71e7e77571bc2bbaf45e
prerequisite-patch-id: 92f4f7c0df22746ab9dcf4c84bc14f25f5043dc2
prerequisite-patch-id: 172d56f9145b9ec517bb8ff3e33b33c6a2c39786
prerequisite-patch-id: f374a92609437c1cd7bf2e247c287f126d337a02
prerequisite-patch-id: 2d540c940f6a6e05946e9ba2ca12a3fb28135e8c
prerequisite-change-id: 20261101-work-procfs-fs-41f9fdc489cb:v1
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
prerequisite-patch-id: 117db27dcdef433de7c6be5e95973cac1e373927
prerequisite-patch-id: a0844aa26ffb65ccb362b88ef6c2f4758e15edbf
prerequisite-patch-id: 143fb91bddf33068b6ee11e205818c4c2815e23d
prerequisite-patch-id: 6490e4da1cb2f543683bd164bc9a5a1c943057e7
prerequisite-patch-id: cdefca57d3c552fb6f6b928699edd85f33be25fd
prerequisite-patch-id: 2f0fdb970ddd760d85ff5d2caad0b96348270182
prerequisite-patch-id: f2aa468ff5cbb1cabab3f70e1b8eeee0286cfb4a
prerequisite-patch-id: 037030d95eeb7c49b1e43f638ec954f2cebbcfb1
prerequisite-patch-id: 487141c49e2548310bfb6c2a0964a78f08b285a9
prerequisite-patch-id: c3d3008819fa5629a18142ec9ba6d7024ade7fdb
prerequisite-patch-id: ba15e7c86b60ccc2f0f7ee4c9bc99073068757bc
prerequisite-patch-id: 9423f410b99853693db06c29f12f1c08278b050d
prerequisite-patch-id: 4e7966978e4b11c4d843831f312cdcd5b848f00c
prerequisite-patch-id: 3d24be1897a624d519ef144801f76d152c7528a9
prerequisite-patch-id: 3b4d9fe7b26f6b7b9b3f7725ea333df357107c44
prerequisite-patch-id: 7d9dd345428baeb88c862ef902612f7160dc1d8c
prerequisite-patch-id: 504e13cb7af5da6f3c8503f9336116ddd6ee9fc0
prerequisite-patch-id: 079f5420c7c6660679b25a93ab2912b42af19d6d
prerequisite-patch-id: 717bfde0d4141e875562d62b0e3c22d687517462
prerequisite-patch-id: 3e465d93cacbb875c5508b106bcaae53665de29e
prerequisite-patch-id: da2eff4c67005d05b39c39d6d164b94c2837a4dd
prerequisite-patch-id: a293472d78b43026dacbfe22a34ba1f8f2626e63
prerequisite-patch-id: 56469933009bbfd5a57d843f698f91bb0cdd846a
prerequisite-patch-id: 16433e5bde53510f9e6b7e04db2279bd0a8f63f5
prerequisite-patch-id: 03d349761a5a56d223067b051b1a38d594006ae2
prerequisite-patch-id: 9112aaf35b0ab26bf396285fbfbb51b81901d80b
prerequisite-patch-id: 901a0c1b4c2da010722471826fbfc51402ab8573
prerequisite-patch-id: 1204b4883154dea8cb7d93efadb9f49e70ecd7a8
prerequisite-patch-id: d2762d5dd1254bf7cf89a16b317b7b421718935f
prerequisite-patch-id: d1337f7a08fd4758a94bc5b2faeb30cbad1fe9cf
prerequisite-patch-id: a1d46785e75f0ec87cd12807cb57adc869a7f6a8
prerequisite-patch-id: 44c5d2365c5237b44a0162be9e73dcb392deab2c
prerequisite-patch-id: ad7ca39e7946dbf9e9ed4677b577bb5efad15af5
prerequisite-patch-id: 3984bbb1dbd74d87215a789483a75e968e81b453
prerequisite-patch-id: 0db54371960496caafd93db8801125a92f43d6c6
prerequisite-patch-id: 4d97d31af7bca868bf68a61fe7825dcbd7cc500b
prerequisite-patch-id: 227908b78f668bc6301cfa2217fa581471176b0f
prerequisite-patch-id: d4fba49d9b4aaee2cc42d91651041faa4b1a4d38
prerequisite-patch-id: fd779ec9acd1cd56b7eb9176cd0a10a548133f0c
prerequisite-patch-id: 5c61093340a745890222477d54f21e1121643c95
prerequisite-patch-id: 1199e9ee338002117fbe257118ff264e64eec0bb
prerequisite-patch-id: 08be0388a5aafb66919d0d678380c33f092738ce
prerequisite-patch-id: f98799e2973376543e67ae7a93ab62a20aa29564
prerequisite-patch-id: f670bed1eba8e1440bbfed164fb0c367f248e231
prerequisite-patch-id: 88a5543ceb70d27bd05b718480334d0a28133697
prerequisite-patch-id: 544f65704decf1a67848c8dc68ac60c5b76cdb81
prerequisite-patch-id: f36fad7a6eb02bf1b3c1171a61cbb854794bdf63
prerequisite-patch-id: 03a4a6747171c25f622df537a7608a4058acfc2c
prerequisite-patch-id: 7079fdab6ec5000d3a7b4868e138e9177bf03945
prerequisite-patch-id: 8483765548e3cdbd16e0a9ef44e9c60941611b12
prerequisite-patch-id: 6643c2dbd00ab86e742ef5a15f4d23c039575f07
prerequisite-patch-id: 9f288cab3b89ff67865b4e20c7b7f6f3835cec6f
prerequisite-patch-id: 6c8bae764061f224f8bf6bfb0a58b44689d1fb85
prerequisite-patch-id: c2d5675bad1219323ceb4f7c382dea8ef654256f
prerequisite-patch-id: f5fd02ee0a5960d146eba2f57ecf9ccb15a1b216
prerequisite-patch-id: d12cfa9299bb33218551b98efc8d2af8bb2ef321
prerequisite-patch-id: 889b86d3e246e3d6b4cd71e7e77571bc2bbaf45e
prerequisite-patch-id: 92f4f7c0df22746ab9dcf4c84bc14f25f5043dc2
prerequisite-patch-id: 172d56f9145b9ec517bb8ff3e33b33c6a2c39786
prerequisite-patch-id: f374a92609437c1cd7bf2e247c287f126d337a02
prerequisite-patch-id: 2d540c940f6a6e05946e9ba2ca12a3fb28135e8c
prerequisite-patch-id: e1136dd06b641700522373064fc4f0b8988019d2
prerequisite-patch-id: 1f93c44de1de16d56b63f242e11c61eb99fb839e
prerequisite-patch-id: 9e05d183b1de52caab2cfdfc3ddf204626166018
prerequisite-patch-id: 715c9c767af5025546ebd4a73411f92fe69f2c5b
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
prerequisite-patch-id: d2d80316fbb9ce1cdad0ff0fcaddfc003715aff6
prerequisite-patch-id: 7d31311fd97ddb0b2833c153f22855a39516be16
prerequisite-patch-id: 17675d57b3957c9d0e81c1bb6f7ddf01233a3586
prerequisite-patch-id: a1a7ca09cabb1f3bde983a8f249865cfb33ffba9
prerequisite-patch-id: 30b8a6a426dd7b9f466bde876a813a4e27c4a284
prerequisite-patch-id: 95ece6bf7b926859312be956bb9b0ba7bf1d274a
prerequisite-patch-id: 4a896ec0ba4ac506b1f6a010a05f703f1bf888b8
prerequisite-patch-id: 5914904497e4739e4e94d391968d547b375c4def
prerequisite-patch-id: f98a02b2dae4ad56aa7d11de0361ff86b1b60846
prerequisite-patch-id: c4ba3c61e396328d84731308a7fa49348191f2a2
prerequisite-patch-id: 1b836097aa8c6e35ca7a9f5cbb0aafab59153720
prerequisite-patch-id: fa65e32038043b8430248870d256e3eaa47f4d34
prerequisite-patch-id: f2dd514af8011acaea88d58a6fefe06a6af349bb
prerequisite-change-id: 20261101-work-procfs-net-bc8b21e3eff0:v1
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
prerequisite-patch-id: 117db27dcdef433de7c6be5e95973cac1e373927
prerequisite-patch-id: a0844aa26ffb65ccb362b88ef6c2f4758e15edbf
prerequisite-patch-id: 143fb91bddf33068b6ee11e205818c4c2815e23d
prerequisite-patch-id: 6490e4da1cb2f543683bd164bc9a5a1c943057e7
prerequisite-patch-id: cdefca57d3c552fb6f6b928699edd85f33be25fd
prerequisite-patch-id: 2f0fdb970ddd760d85ff5d2caad0b96348270182
prerequisite-patch-id: f2aa468ff5cbb1cabab3f70e1b8eeee0286cfb4a
prerequisite-patch-id: 037030d95eeb7c49b1e43f638ec954f2cebbcfb1
prerequisite-patch-id: 487141c49e2548310bfb6c2a0964a78f08b285a9
prerequisite-patch-id: c3d3008819fa5629a18142ec9ba6d7024ade7fdb
prerequisite-patch-id: ba15e7c86b60ccc2f0f7ee4c9bc99073068757bc
prerequisite-patch-id: 9423f410b99853693db06c29f12f1c08278b050d
prerequisite-patch-id: 4e7966978e4b11c4d843831f312cdcd5b848f00c
prerequisite-patch-id: 3d24be1897a624d519ef144801f76d152c7528a9
prerequisite-patch-id: 3b4d9fe7b26f6b7b9b3f7725ea333df357107c44
prerequisite-patch-id: 7d9dd345428baeb88c862ef902612f7160dc1d8c
prerequisite-patch-id: 504e13cb7af5da6f3c8503f9336116ddd6ee9fc0
prerequisite-patch-id: 079f5420c7c6660679b25a93ab2912b42af19d6d
prerequisite-patch-id: 717bfde0d4141e875562d62b0e3c22d687517462
prerequisite-patch-id: 3e465d93cacbb875c5508b106bcaae53665de29e
prerequisite-patch-id: da2eff4c67005d05b39c39d6d164b94c2837a4dd
prerequisite-patch-id: a293472d78b43026dacbfe22a34ba1f8f2626e63
prerequisite-patch-id: 56469933009bbfd5a57d843f698f91bb0cdd846a
prerequisite-patch-id: 16433e5bde53510f9e6b7e04db2279bd0a8f63f5
prerequisite-patch-id: 03d349761a5a56d223067b051b1a38d594006ae2
prerequisite-patch-id: 9112aaf35b0ab26bf396285fbfbb51b81901d80b
prerequisite-patch-id: 901a0c1b4c2da010722471826fbfc51402ab8573
prerequisite-patch-id: 1204b4883154dea8cb7d93efadb9f49e70ecd7a8
prerequisite-patch-id: d2762d5dd1254bf7cf89a16b317b7b421718935f
prerequisite-patch-id: d1337f7a08fd4758a94bc5b2faeb30cbad1fe9cf
prerequisite-patch-id: a1d46785e75f0ec87cd12807cb57adc869a7f6a8
prerequisite-patch-id: 44c5d2365c5237b44a0162be9e73dcb392deab2c
prerequisite-patch-id: ad7ca39e7946dbf9e9ed4677b577bb5efad15af5
prerequisite-patch-id: 3984bbb1dbd74d87215a789483a75e968e81b453
prerequisite-patch-id: 0db54371960496caafd93db8801125a92f43d6c6
prerequisite-patch-id: 4d97d31af7bca868bf68a61fe7825dcbd7cc500b
prerequisite-patch-id: 227908b78f668bc6301cfa2217fa581471176b0f
prerequisite-patch-id: d4fba49d9b4aaee2cc42d91651041faa4b1a4d38
prerequisite-patch-id: fd779ec9acd1cd56b7eb9176cd0a10a548133f0c
prerequisite-patch-id: 5c61093340a745890222477d54f21e1121643c95
prerequisite-patch-id: 1199e9ee338002117fbe257118ff264e64eec0bb
prerequisite-patch-id: 08be0388a5aafb66919d0d678380c33f092738ce
prerequisite-patch-id: f98799e2973376543e67ae7a93ab62a20aa29564
prerequisite-patch-id: f670bed1eba8e1440bbfed164fb0c367f248e231
prerequisite-patch-id: 88a5543ceb70d27bd05b718480334d0a28133697
prerequisite-patch-id: 544f65704decf1a67848c8dc68ac60c5b76cdb81
prerequisite-patch-id: f36fad7a6eb02bf1b3c1171a61cbb854794bdf63
prerequisite-patch-id: 03a4a6747171c25f622df537a7608a4058acfc2c
prerequisite-patch-id: 7079fdab6ec5000d3a7b4868e138e9177bf03945
prerequisite-patch-id: 8483765548e3cdbd16e0a9ef44e9c60941611b12
prerequisite-patch-id: 6643c2dbd00ab86e742ef5a15f4d23c039575f07
prerequisite-patch-id: 9f288cab3b89ff67865b4e20c7b7f6f3835cec6f
prerequisite-patch-id: 6c8bae764061f224f8bf6bfb0a58b44689d1fb85
prerequisite-patch-id: c2d5675bad1219323ceb4f7c382dea8ef654256f
prerequisite-patch-id: f5fd02ee0a5960d146eba2f57ecf9ccb15a1b216
prerequisite-patch-id: d12cfa9299bb33218551b98efc8d2af8bb2ef321
prerequisite-patch-id: 889b86d3e246e3d6b4cd71e7e77571bc2bbaf45e
prerequisite-patch-id: 92f4f7c0df22746ab9dcf4c84bc14f25f5043dc2
prerequisite-patch-id: 172d56f9145b9ec517bb8ff3e33b33c6a2c39786
prerequisite-patch-id: f374a92609437c1cd7bf2e247c287f126d337a02
prerequisite-patch-id: 2d540c940f6a6e05946e9ba2ca12a3fb28135e8c
prerequisite-patch-id: e1136dd06b641700522373064fc4f0b8988019d2
prerequisite-patch-id: 1f93c44de1de16d56b63f242e11c61eb99fb839e
prerequisite-patch-id: 9e05d183b1de52caab2cfdfc3ddf204626166018
prerequisite-patch-id: 715c9c767af5025546ebd4a73411f92fe69f2c5b
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
prerequisite-patch-id: d2d80316fbb9ce1cdad0ff0fcaddfc003715aff6
prerequisite-patch-id: 7d31311fd97ddb0b2833c153f22855a39516be16
prerequisite-patch-id: 17675d57b3957c9d0e81c1bb6f7ddf01233a3586
prerequisite-patch-id: a1a7ca09cabb1f3bde983a8f249865cfb33ffba9
prerequisite-patch-id: 30b8a6a426dd7b9f466bde876a813a4e27c4a284
prerequisite-patch-id: 95ece6bf7b926859312be956bb9b0ba7bf1d274a
prerequisite-patch-id: 4a896ec0ba4ac506b1f6a010a05f703f1bf888b8
prerequisite-patch-id: 5914904497e4739e4e94d391968d547b375c4def
prerequisite-patch-id: f98a02b2dae4ad56aa7d11de0361ff86b1b60846
prerequisite-patch-id: c4ba3c61e396328d84731308a7fa49348191f2a2
prerequisite-patch-id: 1b836097aa8c6e35ca7a9f5cbb0aafab59153720
prerequisite-patch-id: fa65e32038043b8430248870d256e3eaa47f4d34
prerequisite-patch-id: f2dd514af8011acaea88d58a6fefe06a6af349bb
prerequisite-patch-id: ed86b546d44c9d5612a132b8f188a1727bf20140
prerequisite-patch-id: 3531ac7c29c6d31f5c4d7830eec493700c7817cc
prerequisite-patch-id: d5636a3c6c5d806cac00791c49bf3703b2a61c7d
prerequisite-patch-id: a789b6da4762c80e4e223d6f20db32a4812cd87b
prerequisite-patch-id: 96c2d266089780f6a0b07f54da812b87b5749abd
prerequisite-patch-id: 51e5bdc34987e2266e8801368e622566ccf20968
prerequisite-patch-id: 48b7e3fe2d9ce6c61b8b7d34ad26ecf0bfcf53cc
prerequisite-patch-id: f39c6af65cc5b209517939533a7cb9cc1ee03da0
prerequisite-patch-id: 9e2cccf47b8c293ebef941d1268956901f1dd323
prerequisite-patch-id: 0126190ba10aa140572e0a652c91d1de7fae0106
prerequisite-patch-id: c0de7f6bcf931394d46239405296ce7008f7a095

