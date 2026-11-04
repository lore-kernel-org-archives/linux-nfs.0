Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.remote-ip=100.103.45.18
ARC-Seal: i=1; d=subspace.kernel.org; s=arc20261015; a=rsa-sha256; cv=none;
	t=1793820347;
	b=Nol8fzKcWQz5aCqGi8qXBq/qc7BSH4H7JbUvAIqZ0gkzhNR/T8Kv8BP53FubgBe4Bomq
	 SD1bV8msdJDaEnRjGBxyCnjn+KsP9Z/uL0SwRkhal7WYNrQilDTqpqC0A82F0aCvhQ3n8
	 La6pP0mi0pJj6ogjSp1sQWQIW/jjNCKLPvo5jQhYMFX0Zzx1sisUQOp4730ZIYjRjc1re
	 AUvOFjr7Zmp1zh5eVhLlf0yIAyTIwdzg1pA91IN89Ej8B9DRaefN1QpmQJWadyiR9lQa+
	 jT+jf6blPUWnmgk8h7etu+U3pFpdXb4la6W7PzUXw3a7RBpMedIi/wAUt4TwvL0D7NQ==
ARC-Message-Signature: i=1; d=subspace.kernel.org; s=arc20261015;
	a=rsa-sha256; c=relaxed/relaxed; t=1793820347;
	h=Received:DKIM-Signature:From:To:Cc:Subject:Date:Message-ID:
	 In-Reply-To:References:MIME-Version:Content-Type:X-Mailer:
	 X-Developer-Signature:X-Developer-Key:Content-Transfer-Encoding;
	bh=qeQgphPdxdiWtw36JzKqWooMSgzPZU+EeD4NlyLVhDM=;
	b=pnQiIb7ihnw51BEXVmgnCg7z3c7T1dgHJyphzcw2/fB8CyhgcyuzGbqzXesEX+mtlY+K
	 8PtgYv5/Vsp31FgRRE5fRC9cj8HnZes/ViD+fT5LBu4B0G22O6WaTHfja17OMnsog8CyE
	 by8FFfzGndZxdz/WrqtfatyNbwh21Uh24E0FZZFm/PF23kD0L3zJ32gC/5A+tGOpPQHoC
	 IWo1DVE+rJxyjh4tQsrdcEBpMkWwc2+OmgwOCOBwfYETynUaNLyTK4JjdgVf/LBxH/Pvv
	 rnNWm6T4YKYq9zkfYeNWBKQ+J/rbCZpEadeSqBttA6TtI/DbM/FlDpYiOY/tJxLtFjg==
ARC-Authentication-Results: i=1; smtp.subspace.kernel.org; 
	dkim=pass header.d=kernel.org header.i=@kernel.org header.a=rsa-sha256 header.s=k20260515 header.b=hdJNDh6O;
	arc=none smtp.remote-ip=100.103.45.18
Received: from smtp.kernel.org (quasi.space.kernel.org [100.103.45.18])
	(using TLSv1.3 with cipher TLS_AES_256_GCM_SHA384 (256/256 bits)
	 key-exchange X25519 server-signature ECDSA (prime256v1))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 1B3446071A2A;
	Wed,  4 Nov 2026 19:25:46 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key, unprotected) header.d=kernel.org header.i=@kernel.org header.a=rsa-sha256 header.s=k20260515 header.b=hdJNDh6O
Received: by smtp.kernel.org (Postfix) with ESMTPSA id 752A91F00A18;
	Wed,  4 Nov 2026 19:25:34 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=kernel.org;
	s=k20260515; t=1793820346;
	bh=qeQgphPdxdiWtw36JzKqWooMSgzPZU+EeD4NlyLVhDM=;
	h=From:To:Cc:Subject:Date:In-Reply-To:References;
	b=hdJNDh6OaAui4lay7OJSmMgInc6T7e+u7rQGOiRGT5ecgJvEKZTk+bvy31gj25xp5
	 EMlVcNskaOB166UEuHcs9M+Arv+SuzxXQANcu/UbyUjMc0+sWDzpbdt76bmGDk4jwv
	 dzXVAXuyKiSVZ4ea/xwRNPPO1mVA9tLUIKS+h63z+xkJopkB5HFxrzEYzXBr5K3/DV
	 4tqBQSe+LfkRA0E4BHcJdz2FUN/7x+h1XEREGcZZ7zmxMVbUH/gH7DuyHZmLjtDcQc
	 J1yVCFHrELmM7UJtS3ngB8pEivcyFDbp7nlx9CIfgNwUk9+JqlDkEZunCVDa84Tte0
	 905iHrsfzrTdg==
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
Subject: [PATCH RESEND v2 39/51] powerpc/crash_dump: recover from a machine check in copy_oldmem_page()
Date: Wed,  4 Nov 2026 20:25:32 +0100
Message-ID: <20261104-work-procfs-bugfixes-v2-39-021c84d852e0@kernel.org>
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
X-Developer-Signature: v=1; a=openpgp-sha256; l=2421; i=brauner@kernel.org; h=from:subject:message-id; bh=VIVKq8y+KdCJwnDd/z4L2OCrr1yqDfObdGoCOSjiCdM=; b=owGbwMvMwCU28Zj0gdSKO4sYT6slMWS9bvzdev5O1pqOqInnVq7QehNleaUr+ZQXg2RwxdMDB mu8jeRsO0pZGMS4GGTFFFkc2k3C5ZbzVGw2ytSAmcPKBDKEgYtTACby8zTDH46/Ovo1n1rt927Z GbOo3ko0bH+/ELda9QrWhpqiI0sd7zD8Fbm2sNi91NhmUkJA6g2DG31172P/sXlZMGhOKDWf+aC ZDQA=
X-Developer-Key: i=brauner@kernel.org; a=openpgp; fpr=4880B8C9BD0E5106FC070F4F7B3C391EFEA93624
Content-Transfer-Encoding: 8bit

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
vmcore does itself, and those have been memcpy() for as long as
copy_oldmem_page() has had its kernel buffer branch, since commit
54c32021eb6f ("[PATCH] powerpc: Add arch-dependent copy_oldmem_page").

Copy with _copy_mc_to_iter() instead. PPC64 selects ARCH_HAS_COPY_MC
and there it uses copy_mc_generic() for kernel and user destinations
alike, which has the exception table entries. Everywhere else it is
_copy_to_iter().

Reported-by: Chris Mason <mason@kernel.org>
Fixes: 54c32021eb6f ("[PATCH] powerpc: Add arch-dependent copy_oldmem_page")
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

