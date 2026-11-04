Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.remote-ip=100.103.45.18
ARC-Seal: i=1; d=subspace.kernel.org; s=arc20261015; a=rsa-sha256; cv=none;
	t=1793813235;
	b=VT+CHFjcvPEAgNJ6+VqvZusDNtCjBnBGgwpv4f0cJK+pdQN3vof5C7ILJ9reT9wAiQwU
	 +vO1gnWTBrg3VD5nlPisj15euTKml7sU997i0ReM6UB5HTUA83QaVC02/1xcrLCOwUHDq
	 RJPC0bS70e1YyHRhKj0ZPeVbmbFlJB3r/fAqO3HeEObW69Y4S/y4uk8xXlgXbVpLwjamN
	 6RXntyvIwEwdtfdQd72Wu3LmS83BnUpfIJKse+sYCl+a3J+TpZl3jY4O/358SPSuXrj/F
	 xi+umOGvddyKs17GSj9y8dPToeuEW6MjTUhfgUxGhuDlGxXRIJoM09nkvWS/EoPKQEA==
ARC-Message-Signature: i=1; d=subspace.kernel.org; s=arc20261015;
	a=rsa-sha256; c=relaxed/relaxed; t=1793813235;
	h=Received:DKIM-Signature:From:To:Cc:Subject:Date:Message-ID:X-Mailer:
	 MIME-Version:Content-Type:X-Developer-Signature:X-Developer-Key:
	 Content-Transfer-Encoding;
	bh=lAdqJZq7DckAfewXRPAVCUONZuQAofOCOPOWHFZTOPQ=;
	b=fIb3GrfxEMAb3J/TzQgMWEuqnTwJve6bWH10eKuv5MqyXyYRZQr76yC+ok+64mA1ndL0
	 l3WZzVQYkB6SAS2NIhuuEQ8eH0mfseAieh3DkOHgxfUTSL4b5PVCsljQ8fk5pmILOz7su
	 JJ8GyKRk8pgO6+W9ZcnFp6m7/lNOozjAJW/hkNfREyU4TmBmTSJkvhvUD+Ei/tJZgLGj6
	 XOQQEcnhQLa5JCF1y1RcxAv/S10jf5lw/10/4hNdp75bC39qL4LI1Ba+3hrP+gkLZQRbJ
	 VancSZ4eBI2GoUNnoNMTyiNUwh+Oaxh3yTPHwJxMFBqh0c2OImeH2+TGCiHrg1qgfMg==
ARC-Authentication-Results: i=1; smtp.subspace.kernel.org; 
	dkim=pass header.d=kernel.org header.i=@kernel.org header.a=rsa-sha256 header.s=k20260515 header.b=QnqKLYh2;
	arc=none smtp.remote-ip=100.103.45.18
Received: from smtp.kernel.org (quasi.space.kernel.org [100.103.45.18])
	(using TLSv1.3 with cipher TLS_AES_256_GCM_SHA384 (256/256 bits)
	 key-exchange X25519 server-signature ECDSA (prime256v1))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id D07F6606A31B;
	Wed,  4 Nov 2026 17:27:14 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key, unprotected) header.d=kernel.org header.i=@kernel.org header.a=rsa-sha256 header.s=k20260515 header.b=QnqKLYh2
Received: by smtp.kernel.org (Postfix) with ESMTPSA id C4F031F00A02;
	Wed,  4 Nov 2026 17:26:59 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=kernel.org;
	s=k20260515; t=1793813234;
	bh=lAdqJZq7DckAfewXRPAVCUONZuQAofOCOPOWHFZTOPQ=;
	h=From:To:Cc:Subject:Date;
	b=QnqKLYh2fAMD+U5HTXeOnACd1cOBaWr2au0sexyO6Tega8pNFvJ3KwBqyWlewJUso
	 MIi2fzXRHEQROZC9gLvS1bZZ/9/KcmfDhERzkLaXXdIl+Qf8wPegziV2OdOn/5z79r
	 3iTqL/OK9DAdbhv97um4MytPwotOejrYkLFgVhoshHzNg842ittp+lNu4zRCpPsoG2
	 KqhP8Ng8p49cNRXsXj5NGkMfzBM+kKXiniguFgYtTFtMwPvnenK73TWNMd887NGQbI
	 1pG3OChIWDhqEolCKBiLCVppfrBMevoWgaGWalA6fc1c1Jt43H5RxZZPnk2L1SezgW
	 Bq+TYnLLsbzyA==
From: Christian Brauner <brauner@kernel.org>
To: linux-fsdevel@vger.kernel.org
Cc: Christian Brauner <brauner@kernel.org>,
	Linus Torvalds <torvalds@linux-foundation.org>,
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
	Chuck Lever <chuck.lever@oracle.com>,
	Takashi Iwai <tiwai@suse.de>,
	linux-input@vger.kernel.org,
	linux-raid@vger.kernel.org,
	linux-ext4@vger.kernel.org,
	linux-modules@vger.kernel.org,
	linux-debuggers@vger.kernel.org
Subject: [PATCH v2 0/7] proc: move procfs to what kernfs does
Date: Wed,  4 Nov 2026 18:26:54 +0100
Message-ID: <20261104-trompete-gejagt-raddampfer-9fb5640a6102@brauner>
X-Mailer: git-send-email 2.53.0
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
X-Developer-Signature: v=1; a=openpgp-sha256; l=6699; i=brauner@kernel.org; h=from:subject:message-id; bh=vwrWu4QhJtoloSbOepgjr6FTno3vPTd4Ym/VDTikOkw=; b=owGbwMvMwCU28Zj0gdSKO4sYT6slMWS9zrofyGH5UuGlf8QM041zGftlZmtyqi7/2jv5suCKX cadvXNTOkpZGMS4GGTFFFkc2k3C5ZbzVGw2ytSAmcPKBDKEgYtTACaSkMjI8PXT/ahLzms2tG95 p/y6Wd4h+MQHNf/VL1dGn7i1utyl/SQjw+WcTXp/Xn+/v4hxooZnZYRWmPKsDU2ur9N2RKRMsj5 7gh0A
X-Developer-Key: i=brauner@kernel.org; a=openpgp; fpr=4880B8C9BD0E5106FC070F4F7B3C391EFEA93624
Content-Transfer-Encoding: 8bit

This series aims to get rid of copying to and from userspace while pinning
procfs entries allowing userspace to delay removal as long as it wants.

In essence, it aligns procfs with what kernfs is already doing. That
gets rid of a big attack surface and a whole bug class in one go. The
bounce buffer will come with some costs but luckily some codepaths (like
readdir) have been so criminally slow and buggy that massaging them ends
up speeding things up or at least leaving them on par with mainline even
with a bounce buffer in the mix.

There was a hackish and very narrow AI solution to a small part of this
bug class which was sent off-list. In essence, it used a second
buffering mechanism on top of seqfiles which was really nasty. It also
didn't address any of the non-seqfile users.

If we want to get rid of the this whole bug class we need a bigger
hammer. That means reworking how procfs handles data. So I tried to work
through all of that. The series is now in a decent shape (I'm not saying
"glorious" as there's so so many warts. If they were ironed out it could
be a lot nicer but that's for another day.).

I understand it's big but I think it is nicer to be able to look at the
end result since we have some transitory states that are gone at the end
of the series.

I have polished this a bit more and have sorted out a few more bugs and
tried to clean up some codepaths given the current constraints. Again, I
think we could go a lot further there if we wanted to but I think that
blows this out of proportion and at some point it becomes difficult to
grasp the scope.

So, remove_proc_entry() waits until every call into the procfs entry has
returned. Most of those calls copy to or from userspace with the entry
pinned.

A reader or writer can induce a page fault in that copy take as long as
it wants. For example, with userfaultfd or by punching holes into a
memfd over and over. Plus, the callers of remove_proc_entry() like to
hold locks while they wait. For example, addrconf holds RTNL when it
removes /proc/net/dev_snmp6/<dev> and xt_hashlimit holds a mutex that
all network namespaces share.

So every network device with IPv6 gets a /proc/net/dev_snmp6/<dev> that
everyone can read, and addrconf_ifdown() removes it with RTNL held. So
any local user can keep RTNL for as long as their read stays stalled.
Until then no device can be registered, removed or renamed and no
network namespace can be created or torn down.

If the caller lacks privileges for userfaultfd a FUSE mount in a user
namespace whose daemon never answers is enough to stall the copy.
Killing the reader ends it, but until then whoever removes the file sits
in D state.

xt_hashlimit removes the proc file of a table with hashlimit_mutex
held. Every rule insert in every network namespace takes that mutex and
so does network namespace cleanup. cleanup_net() runs on a single
workqueue with pernet_ops_rwsem held, so a stalled reader also stops
every later network namespace teardown and every module load that
registers pernet operations. xt_recent does the same with recent_mutex.

And of course, it's not specific to networking. remove_proc_entry(),
proc_remove() and remove_proc_subtree() have over 200 callers and plenty
of them hold locks. For example, a stalled reader of
/proc/fs/ext4/<dev>/options holds up the unmount of that filesystem with
s_umount held, and every sync(2) with it. The same goes for PCI
hot-removal, for freeing IRQ descriptors, which CPU bring-up waits on,
and for unplugging a USB sound card.

And btw, syzbot has hit removal under locks before (cf. [1]), and the
xt_recent deadlock fixed in (1) below is another one.

Stalling the kernel in a copy to or from userspace is a well-known
exploitation primitive. It's why unprivileged userfaultfd can't do it
by default anymore since v5.11 (d0d4730ac2e4), and FUSE has been used
the same way.

This series touches just about every ->proc_read(), ->proc_write() and
->proc_ioctl() in the tree, so I've split it up into seven series. They
go out as replies to this mail:

Part 1/7: proc: fix a few old bugs in /proc handlers (51 patches)

    Bugs in the handlers and in procfs itself that are a lot older than
    the conversion and that reviewing it turned up. Most of them are for
    stable. They come first so they can go there on their own and the
    conversion doesn't have to bother with that crap.

Part 2/7: proc: let procfs own the data path (23 patches)

    The procfs side. procfs owns the seq_file of an entry, copies in
    writes, copies out reads and copies ioctl arguments in and out, and
    only calls into an entry with it pinned. The open files procfs has
    to know and the wait queue a pollable entry is polled on live in an
    open node that only those entries get, the entry is pinned around
    the vm_operations of its mappings, and lockdep checks the pin.
    proc_create_seq() and friends and the plain seq_file users are
    switched over here too.

Part 3/7: proc: convert the arch and platform entries (23 patches)
Part 4/7: proc: convert the driver entries (26 patches)
Part 5/7: proc: convert the fs, kernel and mm entries (30 patches)
Part 6/7: proc: convert the net entries and the kfifo samples (13 patches)

Part 7/7: proc: drop the __user methods (6 patches)

    Drops the old methods. kcore, kmsg and the kpage files, which are
    never removed and keep reading straight into userspace, get
    file_operations of their own, so nothing in struct proc_ops takes a
    __user pointer anymore, and the new methods get the names kernfs
    uses, ->proc_read(), ->proc_write() and ->proc_ioctl(). The last
    patch takes the poll_table away from ->proc_poll(). This needs all
    four conversion series.

Parts 1 and 2 are the base. Parts 3 to 6 go on top of part 2 in any
order and don't depend on each other. Part 7 needs all four.

The series should all indicate cleanly what dependencies they have so b4
should be able to pull it for review.

With all of it on a KASAN and lockdep kernel the removal selftests of
every part pass, the proc, pktgen and allocinfo selftests behave like
without it and the bugs from (1) that reproduce in a VM are gone. Every
patch builds on its own on x86_64 and i386, and with W=1 on the
architectures it touches.

[1]: https://lore.kernel.org/r/000000000000f24f4705b6988f3e@google.com
[2]: https://lore.kernel.org/r/20231109212251.213873-7-johannes@sipsolutions.net

---
Link to v1: https://patch.msgid.link/20261102-defizit-jobaussicht-kurios-7016c6e67442@brauner

-- 
Christian Brauner <brauner@kernel.org>
