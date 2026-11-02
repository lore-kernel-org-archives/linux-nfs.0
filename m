Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.remote-ip=100.103.45.18
ARC-Seal: i=1; d=subspace.kernel.org; s=arc20261015; a=rsa-sha256; cv=none;
	t=1793632767;
	b=rey7DrqTj72lR0WxgPyc/JmYg+dJ7ygbML+265oq6OGGi2E3PjElPThwOcoY7OhD5jCK
	 HCm3B5bnJjSgDjsQeqeWlAn1GAzbn1uFRHqflncr7Kbs1TYe1iDST6up+Fm1dYdi+8xgq
	 JsGbsufD0W5q+uxC9WV1Hc/eFZ9jdE8K+wYZsaEZxvLHutbWlkw+jzge1sScq9nUpGdHU
	 Wleyf3cGr5+m310tPKUiKyoDdNrTKEDAe6Me5g1iVvykCoiJ5hCbpo84jrJ9YVstO4wJv
	 2Zh6pH2Q7NCLnoCyNlxQCjkZuyIEBDXFB7dkcJ4+Rvl9endcH+tTnSgsvMT02QX63xw==
ARC-Message-Signature: i=1; d=subspace.kernel.org; s=arc20261015;
	a=rsa-sha256; c=relaxed/relaxed; t=1793632767;
	h=Received:DKIM-Signature:From:Subject:Date:Message-Id:MIME-Version:
	 Content-Type:Content-Transfer-Encoding:X-B4-Tracking:X-Change-ID:
	 In-Reply-To:References:To:Cc:X-Mailer:X-Developer-Signature:
	 X-Developer-Key;
	bh=Oc8DmgxGioqkR/9qk3a4pltP7ArAEGeuKF7qww97tvM=;
	b=z6CxnV6oCHTyab/hP84lJ3/sgDnMlmoYmghKsPb85jao2aheSFPCauijLjMB/hp1955l
	 4ebohMy5ahEcEgHr/OFCFCjrUXSxVEJ8drSiU9LUp/ApIZq1TDXdmcpfYKknADAOEMDpK
	 5Kvy4ncH2H6KtFx9n0w6wz+1dUjCqoAPDHfNRhYj6/y0PBgD0XYecxu3hya8yiEe43wvx
	 jR0VT3x9G2XTDOxyJazV0Hseyqzg8v6DISU86pkMdot/Bh0vLz9mmBtro6kFoakj7NfJi
	 GJFpZkz0ek8tS8fY5NdY/c45ulGdD/VZR51TbCYuzYX0AtLhbXqQorEaAe+0WnYabqw==
ARC-Authentication-Results: i=1; smtp.subspace.kernel.org; 
	dkim=pass header.d=kernel.org header.i=@kernel.org header.a=rsa-sha256 header.s=k20260515 header.b=HiivqBNd;
	arc=none smtp.remote-ip=100.103.45.18
Received: from smtp.kernel.org (quasi.space.kernel.org [100.103.45.18])
	(using TLSv1.3 with cipher TLS_AES_256_GCM_SHA384 (256/256 bits)
	 key-exchange X25519 server-signature ECDSA (prime256v1))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 53FF7606C553;
	Mon,  2 Nov 2026 15:19:27 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key, unprotected) header.d=kernel.org header.i=@kernel.org header.a=rsa-sha256 header.s=k20260515 header.b=HiivqBNd
Received: by smtp.kernel.org (Postfix) with ESMTPSA id C54621F00A16;
	Mon,  2 Nov 2026 15:19:07 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=kernel.org;
	s=k20260515; t=1793632767;
	bh=Oc8DmgxGioqkR/9qk3a4pltP7ArAEGeuKF7qww97tvM=;
	h=From:Subject:Date:In-Reply-To:References:To:Cc;
	b=HiivqBNdbktMB3jIR2AZpFD8s6Tn7iHfe8kJ0WslNzaoAQW5kc7o0gRDBArnpxDsS
	 CtfL51KKLRBSwt+j3D7V1//ejI98V61eo5T0NlexRsUi5c8pC1GbUMNrvk4YIwh8E5
	 2lhDypmE88DBG1tieFL1FjjkiAc9DS68lntunq5HpGVUJiZJWOvuGdSub19BrAbLty
	 mrA/DenKQtkX+TIPLm37CWzKJ4S67BQQ5VCO1dvBtJzcV1DDF470qP/7oLpQMpdRK1
	 T/4sZq0Faz7QcfBjhDQAlwLqisGwJC3D3nAo8pdpGdJQsFprczR6CHYKoPi6OQI8eX
	 km5AalwrjwlXw==
From: Christian Brauner <brauner@kernel.org>
Subject: [PATCH RFC 00/27] proc: convert the fs, kernel and mm entries
Date: Mon, 02 Nov 2026 16:07:10 +0100
Message-Id: <20261102-work-procfs-fs-v1-0-d09a996317b3@kernel.org>
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
X-B4-Tracking: v=1; b=H4sIAAAAAAAC/22OwU7DMAyGX6XymUxNmnVpr0g8AFe0Q+LYLKA1w
 +kK0rR3J2XTTki+/L/sz98FCkmiAmNzAaEllZSnGvRTA3jw0zupFGsG05pe61ar7yyf6iQZuag
 6VvPAEa0bMEA9Oglx+vkDvsHryzPsb2U5hw/CeUWta8EXUkH8hIe1WqGbG3QTJS0k5Q4T+jpXq
 flOfDiNzb9GmIWUY2+9ZasN8rjoxz/Mx2Oax6bfBu+4s4TO9YQ7Ewy2uxjRIXfR6S12xvVDhP3
 1+gsC/z1/IQEAAA==
X-Change-ID: 20261101-work-procfs-fs-41f9fdc489cb
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
X-Developer-Signature: v=1; a=openpgp-sha256; l=8569; i=brauner@kernel.org;
 h=from:subject:message-id; bh=6lMrJQN91rnuCiXg2l4F0Y5JeubSe/EgzAgxv51kRnM=;
 b=owGbwMvMwCU28Zj0gdSKO4sYT6slMWS9WG7I7/625f3h7Cqd5DNl2xf/OvlHY0/nxX2OC1eoq
 c38/udvX0cpC4MYF4OsmCKLQ7tJuNxynorNRpkaMHNYmUCGMHBxCsBECo0Z/goyKdd8SMi1Y43f
 /3aj6Iub5itcN6opMgkcrnwpe3DK1hMM//Q+yfyds/PFlb03GAyP//g85/4Pr0O5e65Xx839JOd
 xK5QZAA==
X-Developer-Key: i=brauner@kernel.org; a=openpgp;
 fpr=4880B8C9BD0E5106FC070F4F7B3C391EFEA93624

This converts the proc entries of jbd2, jfs, lockd, nfsd, ntfs3 and
cifs, the irq affinity files, latencytop, lockdep, /proc/profile,
/proc/pressure, kallsyms, /proc/modules, dynamic_debug, sysvipc,
allocinfo, /proc/swaps and /proc/config.gz to what "proc: let procfs
own the data path" set up: procfs owns the seq_file, copies in writes,
copies out reads and copies ioctl arguments in and out, so the entries'
code only ever runs with the entry pinned and never touches userspace
memory.

One patch per subsystem and method, in the order seq_file, write, read,
ioctl. Where a write that is larger than anything the entry parses now
fails with -EINVAL from procfs I've called that out in the commit.
/proc/profile and /proc/pressure/* are never removed and are marked
permanent, procfs calls into them without pinning. readprofile reads
all of /proc/profile in one go, so it keeps reading straight into
userspace. /proc/config.gz asks for PROC_ENTRY_FULL_READS so that
reading all of it at once keeps working.

The selftest unloads configs.ko while a reader of /proc/config.gz
faults in procfs' copy to userspace. On a KASAN and lockdep kernel it
fails without the series and passes with it. Build tested per commit on
x86_64 and with W=1 on the touched objects. The proc and allocinfo
selftests behave the same with and without the series and so do the
entries I could get at in a VM.

This is on top of "proc: let procfs own the data path". The other three
conversion series don't depend on it and it doesn't depend on them.

Signed-off-by: Christian Brauner (Amutable) <brauner@kernel.org>
---
Christian Brauner (27):
      jbd2: let procfs own the seq_file of the info file
      jfs: let procfs copy in writes to the loglevel file
      lockd: let procfs copy in writes to nlm_end_grace
      lockd: let procfs copy out reads of nlm_end_grace
      nfsd: factor out setting up the exports seq_file
      nfsd: let procfs own the seq_file of /proc/fs/nfs/exports
      ntfs3: let procfs copy in writes to the label file
      smb: client: let procfs own the seq_file of the smbdirect files
      smb: client: let procfs copy in writes
      genirq/proc: let procfs copy in the affinity masks
      latencytop: let procfs copy in writes to /proc/latency_stats
      locking/lockdep: let procfs own the seq_file of /proc/lock_stat
      locking/lockdep: let procfs copy in writes to /proc/lock_stat
      profiling: let procfs copy in writes to /proc/profile
      profiling: mark /proc/profile permanent
      sched/psi: let procfs own the seq_file of the pressure files
      sched/psi: let procfs copy in trigger writes
      sched/psi: mark the pressure files permanent
      kallsyms: let procfs own the seq_file of /proc/kallsyms
      module: procfs: let procfs own the seq_file of /proc/modules
      dyndbg: let procfs copy in writes to /proc/dynamic_debug/control
      ipc: let procfs own the seq_file of the sysvipc files
      alloc_tag: let procfs own the seq_file of /proc/allocinfo
      alloc_tag: let procfs copy the ioctl arguments of /proc/allocinfo
      mm/swapfile: let procfs own the seq_file of /proc/swaps
      kernel/configs: let procfs copy out reads of /proc/config.gz
      selftests/proc: check that unloading configs doesn't wait for a reader

 fs/jbd2/journal.c                                  |  33 ++---
 fs/jfs/jfs_debug.c                                 |  11 +-
 fs/lockd/procfs.c                                  |  19 +--
 fs/nfsd/nfsctl.c                                   |  41 ++++--
 fs/ntfs3/super.c                                   |  27 ++--
 fs/smb/client/cifs_debug.c                         |  71 ++++------
 fs/smb/client/dfs_cache.c                          |  13 +-
 ipc/util.c                                         |  14 +-
 kernel/configs.c                                   |   7 +-
 kernel/irq/proc.c                                  |  27 ++--
 kernel/kallsyms.c                                  |  12 +-
 kernel/latencytop.c                                |   5 +-
 kernel/locking/lockdep_proc.c                      |  60 ++++----
 kernel/module/procfs.c                             |  19 +--
 kernel/profile.c                                   |  11 +-
 kernel/sched/psi.c                                 |  82 ++++-------
 lib/dynamic_debug.c                                |  34 +++--
 mm/alloc_tag.c                                     |  75 ++++------
 mm/swapfile.c                                      |  13 +-
 tools/testing/selftests/proc/.gitignore            |   1 +
 tools/testing/selftests/proc/Makefile              |   1 +
 tools/testing/selftests/proc/config                |   4 +
 .../proc/proc-remove-slow-config-reader.c          | 157 +++++++++++++++++++++
 23 files changed, 400 insertions(+), 337 deletions(-)
---
base-commit: 65ba8f34ec886ec72b2c07ddc8cf3d815c32869d
change-id: 20261101-work-procfs-fs-41f9fdc489cb
prerequisite-change-id: 20261101-work-procfs-core-8fa4a4f412cf:v1
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

