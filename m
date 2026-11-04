Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.remote-ip=100.103.45.18
ARC-Seal: i=1; d=subspace.kernel.org; s=arc20261015; a=rsa-sha256; cv=none;
	t=1793820199;
	b=XqYkNtuWLhoucNIT9XxuXD7TxDlrmARcHyr9F+I/BGynmH4f0mkOtgSyMa8O+V74GXTE
	 o8uJTtKNzn3GGHkJ7Oq5QCHRMYgg68csCtd4heX9WFRyWYdAC3GEwYC3YcrG18hREYvCF
	 nwFrbCBtdmpngBa/YuWPBVB2sYMwF+MX/EqUlkZwwlQSg9Dq7owFJCdm/7TkGK2HmgHsg
	 hHDveDKgJO+un2YPAXupy9VTXbcL6xJZY7JH4cJWUKOgCN21KvxmBG0VJ1AwCAHZAmrOF
	 FmmeXFvKLzwMHfBTAb0hX0wnGC1+E5vvv7z3y7YgbJpcaGtD4zLKxftG1mKQ3l3jTpQ==
ARC-Message-Signature: i=1; d=subspace.kernel.org; s=arc20261015;
	a=rsa-sha256; c=relaxed/relaxed; t=1793820199;
	h=Received:DKIM-Signature:From:To:Cc:Subject:Date:Message-ID:
	 In-Reply-To:References:MIME-Version:Content-Type:X-Mailer:
	 X-Developer-Signature:X-Developer-Key:Content-Transfer-Encoding;
	bh=9dtN9D2ek/PODLB9eXKISWT+1DyRVltUAnsYO5R4w7M=;
	b=Wn6SAoyN+gCMLwcht4HwN61zLd0DNzJ9jqr7KEgQOc6Pwv0jADHb5P0axAJATZtwNFM6
	 MG8mIqn9+gehkc7zKk+yLCxTdeIBBNJp4UEoVaw7lKmPta3BXRt2MDQGdbdVayI+DFpYd
	 ARkvwxXgo/wNFbpxTyOLFu2H1w4MDWIuWY76vwOW0UdKc+zeAhn4DZi0J7p7uD5PtEG/p
	 a2B/b8rylRgGJm/PxyiQ57iH/K7VmbRrJXDr/8cfxxRlOtd/D6nw7xix7xuppDhbPz/V+
	 qx7HvKiK/ALvKemS/MiN7EV0MiIMc+1aKz3XYHpdF3zCJc7tqvKKNy0Zb8jU4E6Hq8w==
ARC-Authentication-Results: i=1; smtp.subspace.kernel.org; 
	dkim=pass header.d=kernel.org header.i=@kernel.org header.a=rsa-sha256 header.s=k20260515 header.b=WUjVvSgY;
	arc=none smtp.remote-ip=100.103.45.18
Received: from smtp.kernel.org (quasi.space.kernel.org [100.103.45.18])
	(using TLSv1.3 with cipher TLS_AES_256_GCM_SHA384 (256/256 bits)
	 key-exchange X25519 server-signature ECDSA (prime256v1))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 7DD2E606C900;
	Wed,  4 Nov 2026 19:23:19 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key, unprotected) header.d=kernel.org header.i=@kernel.org header.a=rsa-sha256 header.s=k20260515 header.b=WUjVvSgY
Received: by smtp.kernel.org (Postfix) with ESMTPSA id 055C01F000C1;
	Wed,  4 Nov 2026 19:23:06 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=kernel.org;
	s=k20260515; t=1793820199;
	bh=9dtN9D2ek/PODLB9eXKISWT+1DyRVltUAnsYO5R4w7M=;
	h=From:To:Cc:Subject:Date:In-Reply-To:References;
	b=WUjVvSgYe5Hj7+VHJxqGCdVuPZtH9TtLIRIu84V4WAA6vFP1AvkW+oSj/edLc2ck/
	 AAJWe21jGN66rAVWXOLHwrW3BkgJ7C5MMC9kqPjYIm9KMsBUn46oa0vCJA/TU5q6rX
	 iH5MZ7/d6lbSeiP9AbR9i30r2ap/96zzZx+nemJvi6mhYtlWM8sEF2UUpZwV40I+z3
	 +txyiwalAfhoSb0jj4BJxzYGfVLI7LPAybYz/+TrWrBDGQ0NUDbS+hRxwxJlmPbijJ
	 EE86e3tlHpNNL7Pmd5DKa/IXf1VMJPtPlvfcVaYXoetHk9VmlRKFC3n8SLFdRpRElE
	 JRmL7ZtyfUvGw==
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
	stable@vger.kernel.org
Subject: [PATCH RESEND v2 29/51] proc: don't walk through a non-directory when resolving a name
Date: Wed,  4 Nov 2026 20:23:04 +0100
Message-ID: <20261104-work-procfs-bugfixes-v2-29-021c84d852e0@kernel.org>
In-Reply-To: <20261104-work-procfs-bugfixes-v2-0-021c84d852e0@kernel.org>
References: <20261104-work-procfs-bugfixes-v2-0-021c84d852e0@kernel.org>
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
X-Mailer: b4 0.17-dev
X-Developer-Signature: v=1; a=openpgp-sha256; l=2403; i=brauner@kernel.org; h=from:subject:message-id; bh=syoXv99Xi8HZbn/gUZHMWCnjRlLtpR5bAeJLx/CLQI8=; b=owGbwMvMwCU28Zj0gdSKO4sYT6slMWS9bnzfyJTJaHMu41dep952AaYXinG37t+WyDPu5f08x dN5TvXxjlIWBjEuBlkxRRaHdpNwueU8FZuNMjVg5rAygQxh4OIUgImwHGP4n7qS/1/T39mfA+ez nur5I3X/0v1ZE26+TomYpu8oNvN10zOG/0VzMx60c//Q3nGn5Li21/MFnmxuVnN23S5+YyFT+l7 1HzMA
X-Developer-Key: i=brauner@kernel.org; a=openpgp; fpr=4880B8C9BD0E5106FC070F4F7B3C391EFEA93624
Content-Transfer-Encoding: 8bit

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
index 4c3fcaf68ef4..6ac9c4c13897 100644
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

