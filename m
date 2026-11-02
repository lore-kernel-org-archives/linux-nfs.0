Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.remote-ip=100.103.45.18
ARC-Seal: i=1; d=subspace.kernel.org; s=arc20261015; a=rsa-sha256; cv=none;
	t=1793633439;
	b=tOLi7aIxdTJIXnFg1tvZZ1+QpFw72a+EWKB4Xu14u4mWLO5Wl4tSohYL7KxSBX47l09m
	 rqoK3smbXi9XIjlLB3UP3ZgUyu7+27WG2rFmhesMg6RqvHgtn+oc9jdnNE+UPw84Hgh8C
	 nY1gSldte2J1XE8amq8poHWNh+VyHT0pxYW1qaIqm4tgiZk+tZHkVwXOLIwy+cVfOQMdU
	 h7Vt75MJsCPt9+wg71G4ioaBgDyi2o5fsTfLoUyUMknjd2gD1q5lxLQvK0jlIZFeVZgUN
	 hbthA9kmFLR2nkj5h52syq/ho3b8GVYWBj6Ex1FjBU37dizbzzhmgWe9p2WTnbCWskA==
ARC-Message-Signature: i=1; d=subspace.kernel.org; s=arc20261015;
	a=rsa-sha256; c=relaxed/relaxed; t=1793633439;
	h=Received:DKIM-Signature:From:Subject:Date:Message-Id:MIME-Version:
	 Content-Type:Content-Transfer-Encoding:X-B4-Tracking:X-Change-ID:
	 In-Reply-To:References:To:Cc:X-Mailer:X-Developer-Signature:
	 X-Developer-Key;
	bh=nWuCT5YfGLZKMaCIQ2u9uqZ5zT0FDhvi/3SVn3tmVzc=;
	b=BV9D2kVpb2jYXDi/zadAcTjwtp4DcsgBOFwnRVhi35hrSpCXCo5B+pZe3J8UowY/bwFM
	 wHRiSbuldYo3vBYVXjq5fFtVxhZis1LC1HDaHHwfmMgnFvCHaOOHfrxLnwEdI7G6WM2bm
	 TsPPgTNNvQiAXMBrnfCHyGDQZPSU9XclBITJ45FWvSJrtR33cTXWAVOdLhata6Ils+0qF
	 ce35CJ2/GTvqI66NPx7ICVH3Kq9eQWtFglo/IE0oHwex8kj8RYgNrMghILlWzBizljQlP
	 XBlKLxrtfpM6qI9VrJ6nY58wijJKsKlb1fd+Kznv0utZH7MoBdduOi0k+Nf1NeobPlg==
ARC-Authentication-Results: i=1; smtp.subspace.kernel.org; 
	dkim=pass header.d=kernel.org header.i=@kernel.org header.a=rsa-sha256 header.s=k20260515 header.b=JvJL3xSm;
	arc=none smtp.remote-ip=100.103.45.18
Received: from smtp.kernel.org (quasi.space.kernel.org [100.103.45.18])
	(using TLSv1.3 with cipher TLS_AES_256_GCM_SHA384 (256/256 bits)
	 key-exchange X25519 server-signature ECDSA (prime256v1))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 61295606A916;
	Mon,  2 Nov 2026 15:30:39 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key, unprotected) header.d=kernel.org header.i=@kernel.org header.a=rsa-sha256 header.s=k20260515 header.b=JvJL3xSm
Received: by smtp.kernel.org (Postfix) with ESMTPSA id 577111F00A17;
	Mon,  2 Nov 2026 15:30:22 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=kernel.org;
	s=k20260515; t=1793633439;
	bh=nWuCT5YfGLZKMaCIQ2u9uqZ5zT0FDhvi/3SVn3tmVzc=;
	h=From:Subject:Date:In-Reply-To:References:To:Cc;
	b=JvJL3xSmCx1jEXZXFgCWdABT0EtARcgIeWlliBcwjsQggtBY2gtJtPeeTuwFe1En3
	 yghubbz+b6akUmjQFQundlEviJxzYnXvvJ10JOd1KMP0/nBgMjIkXwZ/XC5Z80/QRU
	 TM3v1jZON2+8k+xpLjLlBV7eV9w+fBiVNw5CKH84T3Q2OzPSyUKXQM3m+Ax30lI93Y
	 OyoOQjlKotkqtBU9MfoL0KIPG2osrCvKNSLQ40t0sUClpEBfOkQbyLQFLb27zpFu+Y
	 n8mMnghA5U6ON/ROReGn5Up0EpOwUQn7lOK4akX5XlElTMVXhFxJ9ikuqMVKjPgINC
	 iKJ2YSbzsjVGA==
From: Christian Brauner <brauner@kernel.org>
Subject: [PATCH RFC 00/11] proc: convert the net entries and the kfifo
 samples
Date: Mon, 02 Nov 2026 16:07:14 +0100
Message-Id: <20261102-work-procfs-net-v1-0-982104a4f592@kernel.org>
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
X-B4-Tracking: v=1; b=H4sIAAAAAAAC/22OQQ6CMBBFr0JmbQ0tiJWtiQdwa1i00xmtBqoto
 onx7oIaVy7/z/w37wGJoqcEdfaASINPPnRjkLMM8GC6PQnvxgwqV5WUuRS3EE/iHANyEh31wqK
 2SlJBzDmMq3Mk9vc3cQfbzRqaT5mu9kjYT6zpzJpEwkbT4WGqJur8Q51z+nIiXa6jUP+F/Xzq7
 K8NhkhCsylNyaVUyPUgf68wtK3v66xaWKO5KAm1rgiXyirMl86hRi6clgsslK5WDprn8wWY6yG
 oHQEAAA==
X-Change-ID: 20261101-work-procfs-net-bc8b21e3eff0
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
X-Developer-Signature: v=1; a=openpgp-sha256; l=6204; i=brauner@kernel.org;
 h=from:subject:message-id; bh=Lm5+su7qsScEvEwR5OzG4cxYScUPPN8KO8cD1pJduAM=;
 b=owGbwMvMwCU28Zj0gdSKO4sYT6slMWS9WG6sZzlnpdTObhHnrxsNnhcwhx7JdFJe6ZC4aXbLM
 a/56SU2HaUsDGJcDLJiiiwO7Sbhcst5KjYbZWrAzGFlAhnCwMUpABPZ58vwP2FCTv7c1nPufxUn
 rxVffbXetcGH6/Pd/nXCDCUSoTFLchj+WfEH5fmX5SrzarKvehro8vvd34Piq3/NKC07Jbo2ZmU
 OMwA=
X-Developer-Key: i=brauner@kernel.org; a=openpgp;
 fpr=4880B8C9BD0E5106FC070F4F7B3C391EFEA93624

This converts the proc entries of atm, l2tp, pktgen, xt_recent and
sunrpc, and the kfifo samples, to what "proc: let procfs own the data
path" set up: procfs owns the seq_file, copies in writes, copies out
reads and copies ioctl arguments in and out, so the entries' code only
ever runs with the entry pinned and never touches userspace memory.

One patch per subsystem and method, in the order seq_file, write, read,
ioctl. The sunrpc channel files take 32k downcalls, which is what
->proc_write_size is for, and their ioctl goes away: do_vfs_ioctl()
answers FIONREAD for regular files before the file's ioctl ever sees
it. The sunrpc channel and the kfifo samples are streams. They hand out
what is read before procfs copies it out, so a reader that passes a bad
buffer loses that part. Where a write that is larger than anything the
entry parses now fails with -EINVAL from procfs I've called that out in
the commit.

Build tested per commit on x86_64 and with W=1 on the touched objects.
The pktgen selftest behaves the same with and without the series and so
do the entries I could get at in a VM.

This is on top of "proc: let procfs own the data path". The other three
conversion series don't depend on it and it doesn't depend on them.

Signed-off-by: Christian Brauner (Amutable) <brauner@kernel.org>
---
Christian Brauner (11):
      atm: let procfs copy out reads of the device files
      l2tp: let procfs own the seq_file of /proc/net/pppol2tp
      net: pktgen: let procfs copy in commands
      netfilter: xt_recent: let procfs own the seq_file
      netfilter: xt_recent: let procfs copy in writes
      SUNRPC: let procfs own the seq_file of the cache content file
      SUNRPC: let procfs copy in writes
      SUNRPC: let procfs copy out reads
      SUNRPC: drop the ioctl of the procfs channel files
      samples/kfifo: let procfs copy in writes
      samples/kfifo: let procfs copy out reads

 net/atm/proc.c                     |   9 ++-
 net/core/pktgen.c                  | 128 +++++++++++++----------------------
 net/l2tp/l2tp_ppp.c                |  20 +++---
 net/netfilter/xt_recent.c          |  19 ++----
 net/sunrpc/auth_gss/svcauth_gss.c  |  34 +++-------
 net/sunrpc/cache.c                 | 133 ++++++++++++++++++++++---------------
 samples/kfifo/bytestream-example.c |  18 ++---
 samples/kfifo/inttype-example.c    |  20 +++---
 samples/kfifo/record-example.c     |  21 +++---
 9 files changed, 177 insertions(+), 225 deletions(-)
---
base-commit: 65ba8f34ec886ec72b2c07ddc8cf3d815c32869d
change-id: 20261101-work-procfs-net-bc8b21e3eff0
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

