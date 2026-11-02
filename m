Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.remote-ip=100.103.45.18
ARC-Seal: i=1; d=subspace.kernel.org; s=arc20261015; a=rsa-sha256; cv=none;
	t=1793629667;
	b=Ap+qbSjEyyKPy4fJwkzT4SIDxTGsJLbwlbl2vQQykQqfQY07LSjBtmf0AduBfB/Smhb/
	 b+PxwB7YHJTGeB+ftkby4VJ49dG6EnkIML1DghoMJHHKM1ir0F71Q0b/19wo/0vzZ2khW
	 W4YQ7igoMCApqgFBhLIiMJcAAx1Vvc1jDwvv8x5LApOROO+UPL/lq1pWOGIotMxCpaJWP
	 EhKrFwnEYIZ3572h4aIxrMPPmiXidBN6yOIzhdAwzRnD2gtzgZ6OsE1M3Y6FT0xCHyjrR
	 YDFWvYSKmknx4ouQHRufybEFtnPyWNJQErtjmSJj24PC3FDYLFVXSopcCgeiZCXqaqA==
ARC-Message-Signature: i=1; d=subspace.kernel.org; s=arc20261015;
	a=rsa-sha256; c=relaxed/relaxed; t=1793629667;
	h=Received:DKIM-Signature:From:Date:Subject:MIME-Version:Content-Type:
	 Content-Transfer-Encoding:Message-Id:References:In-Reply-To:To:Cc:
	 X-Mailer:X-Developer-Signature:X-Developer-Key;
	bh=a3x3EcOd04d3k5+O3dMfsGmWB77s9fU2q2h860UaVdk=;
	b=cx1zn+lHiUqWlSj4ap+/hfGIDN6adM1sUHyNPVHhy2OO3D4MpuNMXBXW0jY0U5JCMD49
	 ii5f0/qFrMLV0w3KthhJs7ash56vosuTioJMX6dqMVENuuvvYFwpI5TXuUVmBNlvf+xM4
	 mH565AFfH+8+RNiOOd4nOBEzV3yqB3g/n+mn21yLI/to9vg6p6565UjZHmvZGA6nAP98w
	 T14MqkiBZYGzMGxaIvvlq0TtNfeXduCSEZePYJxmU5PIgrteGkLjXvO1RJ2msfqw5JqNj
	 tYH6CZMEgejLRbWSQT3uoFWjHH0/GNIoZ5PD2EPkGCnVuSJqDipLAY8486rHkB9bvWw==
ARC-Authentication-Results: i=1; smtp.subspace.kernel.org; 
	dkim=pass header.d=kernel.org header.i=@kernel.org header.a=rsa-sha256 header.s=k20260515 header.b=RVwyyj26;
	arc=none smtp.remote-ip=100.103.45.18
Received: from smtp.kernel.org (quasi.space.kernel.org [100.103.45.18])
	(using TLSv1.3 with cipher TLS_AES_256_GCM_SHA384 (256/256 bits)
	 key-exchange X25519 server-signature ECDSA (prime256v1))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 1AF36607E0D4;
	Mon,  2 Nov 2026 14:27:46 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key, unprotected) header.d=kernel.org header.i=@kernel.org header.a=rsa-sha256 header.s=k20260515 header.b=RVwyyj26
Received: by smtp.kernel.org (Postfix) with ESMTPSA id 1D5CA1F00A16;
	Mon,  2 Nov 2026 14:27:33 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=kernel.org;
	s=k20260515; t=1793629666;
	bh=a3x3EcOd04d3k5+O3dMfsGmWB77s9fU2q2h860UaVdk=;
	h=From:Date:Subject:References:In-Reply-To:To:Cc;
	b=RVwyyj26nRGz0YAa3qJjLMbMcY59GFv7k2/Yo4WgpVWb59sfMb8Zl9naRaGYP0rou
	 MMpo/iaTuwZ+wi6sRL6CWH+xBh8p8Hh0LzLpasPr6e/4udRG/oCcZ29xKchnIx3/p+
	 B3Jo+wFAlApWU/ThwP5etPS2jmB2GKh3nFbyeKDeBWGAaYO2fqeijfiRa42kJVjmo5
	 eE8+TH9zCGeavvC5T8ODN/DYi8pcd4vmfSKYG4AUNTrxGouYTZAQo3PNclBsTunvuS
	 i1W58HX+mcpImcnTaTchfOLoReuEjUSRmdexvU8N4yNjatMl7C5uOyxR6YUyGiu2Qj
	 eJ8cshD06UL+w==
From: Christian Brauner <brauner@kernel.org>
Date: Mon, 02 Nov 2026 15:21:41 +0100
Subject: [PATCH RFC 26/38] powerpc/crash_dump: recover from a machine check
 in copy_oldmem_page()
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
Message-Id: <20261102-work-procfs-bugfixes-v1-26-59422ed3e465@kernel.org>
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
X-Developer-Signature: v=1; a=openpgp-sha256; l=2160; i=brauner@kernel.org;
 h=from:subject:message-id; bh=46QTFCl18GYq9rYmjhc3/nfnECuPknUgrDKXTEluZq8=;
 b=owGbwMvMwCU28Zj0gdSKO4sYT6slMWS9mJNjfd/SLtTaSr/hcs8Or+rV/z323q+aevR7v4GS5
 AXFwhMXOkpZGMS4GGTFFFkc2k3C5ZbzVGw2ytSAmcPKBDKEgYtTACYyv5Xhf9Ujn1e//n02s36h
 97fg8AGx5+WqXD/VJ1+ZtszhE6fMyz2MDAuiVhYyzznyU29ZeOz86L3bl/VWxVxten6I87kdz7q
 Q9ZwA
X-Developer-Key: i=brauner@kernel.org; a=openpgp;
 fpr=4880B8C9BD0E5106FC070F4F7B3C391EFEA93624

A capture kernel reads the memory of the crashed kernel, and that memory
may well have uncorrectable errors. On powerpc a machine check in the
kernel is only recovered from if the instruction that took it has an
exception table entry (cf. mce_common_process_ue()). copy_oldmem_page()
copies with copy_to_iter(). For a read() of /proc/vmcore that is a user
copy, all of whose loads have exception table entries, so the machine
check turns into a short copy and read_from_oldmem() returns -EFAULT.

But since commit 4a22fd20379c ("vmcore: convert __read_vmcore to use an
iov_iter") /proc/vmcore can be spliced too, and splice(), sendfile()
and copy_file_range() copy into kernel pages with memcpy(), which has
no exception table entries. A machine check there panics the capture
kernel. The same goes for the reads of the ELF headers and notes that
vmcore does itself.

Copy with _copy_mc_to_iter() instead. PPC64 selects ARCH_HAS_COPY_MC
and there it uses copy_mc_generic() for kernel and user destinations
alike, which has the exception table entries. Everywhere else it is
_copy_to_iter().

Reported-by: Chris Mason <mason@kernel.org>
Fixes: 4a22fd20379c ("vmcore: convert __read_vmcore to use an iov_iter")
Cc: stable@vger.kernel.org
Signed-off-by: Christian Brauner (Amutable) <brauner@kernel.org>
---
 arch/powerpc/kernel/crash_dump.c | 4 ++--
 1 file changed, 2 insertions(+), 2 deletions(-)

diff --git a/arch/powerpc/kernel/crash_dump.c b/arch/powerpc/kernel/crash_dump.c
index 1543917bd3e1..ca7e019ae3e9 100644
--- a/arch/powerpc/kernel/crash_dump.c
+++ b/arch/powerpc/kernel/crash_dump.c
@@ -83,12 +83,12 @@ ssize_t copy_oldmem_page(struct iov_iter *iter, unsigned long pfn,
 
 	if (memblock_is_region_memory(paddr, csize)) {
 		vaddr = __va(paddr);
-		csize = copy_to_iter(vaddr + offset, csize, iter);
+		csize = _copy_mc_to_iter(vaddr + offset, csize, iter);
 	} else {
 		vaddr = ioremap_cache(paddr, PAGE_SIZE);
 		if (!vaddr)
 			return -ENOMEM;
-		csize = copy_to_iter(vaddr + offset, csize, iter);
+		csize = _copy_mc_to_iter(vaddr + offset, csize, iter);
 		iounmap(vaddr);
 	}
 

-- 
2.53.0

