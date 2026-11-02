Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.remote-ip=100.103.45.18
ARC-Seal: i=1; d=subspace.kernel.org; s=arc20261015; a=rsa-sha256; cv=none;
	t=1793629533;
	b=xLJmZXLiXJmPFIOc0RMwKlaFHxFy8HVMf8ke/BjssnMX479tdMPc89yqhuHHZNQLt3Bs
	 mG1IZB428AZJmsKbltRPW4D3IqmT5HOUQI/6hI6elM8E0dEhBjQ368KperwiwLS1z3/oo
	 XKz/aMNCz3PfaxfTcTbBJ01qxttRJ2Xj6C9p4MxZqEoEf/FV7VrGwlg2lUc18/wnFD+dq
	 6w9gqYDowKrQasWr4EzoxnlQnE3s19CWp6H0Z/bFn6rtOmu6CPGiIg2KInEja+Cqxjaom
	 0ncn//MgX3vr+FkxN6YA69qYAqNOIjG2w1fGj5W3kO7mpuogPbMTU0wDo+WB06ZD3NA==
ARC-Message-Signature: i=1; d=subspace.kernel.org; s=arc20261015;
	a=rsa-sha256; c=relaxed/relaxed; t=1793629533;
	h=Received:DKIM-Signature:From:Date:Subject:MIME-Version:Content-Type:
	 Content-Transfer-Encoding:Message-Id:References:In-Reply-To:To:Cc:
	 X-Mailer:X-Developer-Signature:X-Developer-Key;
	bh=mKU98amy9hy90zr0rIuEDpX5DG9FkJnMRpzgeAMYKDA=;
	b=PrcsqJM+MTgwiprzZ2bU2Xi7HtFTFh/WgEhUFMV7Ll9neVf5aWfgfkNJk8lYWziMK9iG
	 u9Bkcgox76axM8vtFzc89dVveGN6JAQgDE2v89GSx63CRAlAS1qb56Jr86B+TJPSLYm5k
	 P91DvvSRbY+2Uq0uWpcc4QnGfFU3HAElviM2LwZ8W2zsG5keCNuBkSmVJMUaNI2GVQ1KV
	 rG++vATe2Gh95Zy872690OhyIqZQdkT8vOGD/eo/AaPLDA0yMAAw6LQyfvWgtTo2TN4Tq
	 zt5GkoQhgwMFyQ+QTrHjj+RK5rczM+RjK/mVGA0QTCRzwoso3gUC8bh2W7/jR616tgw==
ARC-Authentication-Results: i=1; smtp.subspace.kernel.org; 
	dkim=pass header.d=kernel.org header.i=@kernel.org header.a=rsa-sha256 header.s=k20260515 header.b=RuiXMui8;
	arc=none smtp.remote-ip=100.103.45.18
Received: from smtp.kernel.org (quasi.space.kernel.org [100.103.45.18])
	(using TLSv1.3 with cipher TLS_AES_256_GCM_SHA384 (256/256 bits)
	 key-exchange X25519 server-signature ECDSA (prime256v1))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id F2740606B1E0;
	Mon,  2 Nov 2026 14:25:32 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key, unprotected) header.d=kernel.org header.i=@kernel.org header.a=rsa-sha256 header.s=k20260515 header.b=RuiXMui8
Received: by smtp.kernel.org (Postfix) with ESMTPSA id B4C7B1F00A1A;
	Mon,  2 Nov 2026 14:25:18 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=kernel.org;
	s=k20260515; t=1793629532;
	bh=mKU98amy9hy90zr0rIuEDpX5DG9FkJnMRpzgeAMYKDA=;
	h=From:Date:Subject:References:In-Reply-To:To:Cc;
	b=RuiXMui8BjXqcKpOkZSSb2fzdRJqOkdTcBMExOILHIUKi584gE62EX9Rp9REsxAIh
	 tjfzstrESrt5D/m0KQUF1dxAhGVFfymG0E8Js/U44Ve00018P7C9iKFESKyfNdRPH7
	 jxqcAf+UyNqrfhgRtXxl4xxVCit/7IAdifFgBcmNi28pEmExfPZqlZQ4Q0GbNWzpIU
	 msgRoEl0hgaDf8LmrTDw9dYe6Yf6s53ZTxmKCSoEgxdjVUtQjEYNmUbpSyhFg70PwG
	 1lAYyQW6WwhB8zxcVpIbbkLDhHR6Rqo3KCYBrHb/1mUtI2SL/iwP/I6AQGkAgYxSJ7
	 LV6XKXIW55awQ==
From: Christian Brauner <brauner@kernel.org>
Date: Mon, 02 Nov 2026 15:21:31 +0100
Subject: [PATCH RFC 16/38] proc: don't walk through a non-directory when
 resolving a name
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
Message-Id: <20261102-work-procfs-bugfixes-v1-16-59422ed3e465@kernel.org>
References: <20261102-work-procfs-bugfixes-v1-0-59422ed3e465@kernel.org>
In-Reply-To: <20261102-work-procfs-bugfixes-v1-0-59422ed3e465@kernel.org>
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
X-Developer-Signature: v=1; a=openpgp-sha256; l=2403; i=brauner@kernel.org;
 h=from:subject:message-id; bh=/ELhSiescDaKRjbpWYPGx1ceLHTHmhSA6KoiiBWZ7Vg=;
 b=owGbwMvMwCU28Zj0gdSKO4sYT6slMWS9mJOt9OXTNdZ5WT/1Ui5nzeZtP2wlv61nddee+08Ux
 Eyii1I+d5SyMIhxMciKKbI4tJuEyy3nqdhslKkBM4eVCWQIAxenAEykaAvD/7pF4SLFW7W7Qx48
 CBf6zy7QHPZPaforsYxZ6W92nFswPYbhf+p3tsbuWgVbTQW7NyaGa9/nmy3g0Lj3LuPQBLv7vNr
 OzAA=
X-Developer-Key: i=brauner@kernel.org; a=openpgp;
 fpr=4880B8C9BD0E5106FC070F4F7B3C391EFEA93624

__xlate_proc_name() walks the components of a name like "a/b/c" and
takes whatever it finds for "a" and "b" as the directory to go on in.
It never checks that they actually are directories. So
proc_create("file/x") hangs x into the subdir tree of the regular file
"file". Nobody can look x up there, but remove_proc_subtree() on the
file removes and frees x along with it, behind the back of whoever
registered x.

pktgen passes the name the writer of "add_device" picks to
proc_create_data(), and only the part in front of the '@' has to name
a network device:

  echo "add_device lo@"   > /proc/net/pktgen/kpktgend_0
  echo "add_device lo@/x" > /proc/net/pktgen/kpktgend_1
  echo "rem_device_all"   > /proc/net/pktgen/kpktgend_0
  echo "rem_device_all"   > /proc/net/pktgen/kpktgend_1

The third write frees both entries and the fourth one makes kpktgend_1
call proc_remove() on the freed second one:

  BUG: KASAN: slab-use-after-free in proc_remove+0x8f/0xa0
  Read of size 8 at addr ff110001134c8e70 by task kpktgend_1/243
  Call Trace:
   proc_remove+0x8f/0xa0
   pktgen_remove_device.isra.0+0x118/0x500
   pktgen_rem_all_ifs+0xeb/0x1a0
   pktgen_thread_worker+0x1b42/0x7280

The files of a network namespace belong to the root of its user
namespace and these writes don't require a capability. So once pktgen
is loaded an unprivileged user can do this in namespaces of its own.

Treat a component that isn't a directory like one that doesn't exist.
All names with a '/' that the tree passes in as literals only walk
through directories. pktgen is fixed separately to not pass such names
in the first place.

Reported-by: Chris Mason <mason@kernel.org>
Fixes: 1da177e4c3f4 ("Linux-2.6.12-rc2")
Cc: stable@vger.kernel.org
Signed-off-by: Christian Brauner (Amutable) <brauner@kernel.org>
---
 fs/proc/generic.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/fs/proc/generic.c b/fs/proc/generic.c
index 2b1971da4a85..c560c96a64eb 100644
--- a/fs/proc/generic.c
+++ b/fs/proc/generic.c
@@ -170,7 +170,7 @@ static int __xlate_proc_name(const char *name, struct proc_dir_entry **ret,
 	de = *ret ?: &proc_root;
 	while ((next = strchr(cp, '/')) != NULL) {
 		de = pde_subdir_find(de, cp, next - cp);
-		if (!de) {
+		if (!de || !S_ISDIR(de->mode)) {
 			WARN(1, "name '%s'\n", name);
 			return -ENOENT;
 		}

-- 
2.53.0

