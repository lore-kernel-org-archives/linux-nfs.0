Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.remote-ip=100.103.45.18
ARC-Seal: i=1; d=subspace.kernel.org; s=arc20261015; a=rsa-sha256; cv=none;
	t=1793815021;
	b=1RtcZ4H7Yvmu7BNfpsOw5R8YNcCL817+lT4MYRI4mwVQ1BOJHjHgqto/jn3NPbKrkVqa
	 pX1pryw8L1aGPyfITjnIow2nV8l5QWIonz+/3U7gnbHNCAtTCVhuFA8UEmOFHG9/2OslZ
	 99r5faOy1kNFlSaAbaSPwMhnKfWNIiVobgBLuYi90YbTJWg+vbPiMFgOkq46jxHSKT6kl
	 S7wxGq7id9JaFTzWxLv3UdplMmBtOEX1CBjUxXf8wbR729aaj926E0+O7nv1/+rezZFKB
	 ESKUd9hGT8m1HVbvdj4/y3AQb1sTrX+spAcQcH5QNtnmIm9cJxRgZ7EYcsLMJE17Csw==
ARC-Message-Signature: i=1; d=subspace.kernel.org; s=arc20261015;
	a=rsa-sha256; c=relaxed/relaxed; t=1793815021;
	h=Received:DKIM-Signature:From:To:Cc:Subject:Date:Message-ID:
	 In-Reply-To:References:MIME-Version:Content-Type:X-Mailer:
	 X-Developer-Signature:X-Developer-Key:Content-Transfer-Encoding;
	bh=qeQgphPdxdiWtw36JzKqWooMSgzPZU+EeD4NlyLVhDM=;
	b=hLWmFrbPw7erilaLuXoiV/7HRrwEOrMVpup6UyLm8lHm7YmyiBt+xXFplhDYhCHP3LVS
	 vynbqIoOhr4+ti6wXyLdyl5iiQHoNj866LJGWssg+f07Q9VHRPBsRyfeNg6QRec0rglK7
	 mUv07lPvusXTYkekg8Rrtrdf2XIOduIzih/WU7whBaYgURp3v5CfbsTdcnlCenrm/OzXM
	 27IcMkVM7UyNZ8dgd//cqwN3UXfC63F8vzFaY+V8YIrOQqs7p7tKlQLuNPk/fB/VtKwqi
	 FzU6kiWXhyWsyBjkk6j7FEzbVcQkjo53dNE1NL3V5Swd+1AkIYQbIcbHOWm3RsPq/kQ==
ARC-Authentication-Results: i=1; smtp.subspace.kernel.org; 
	dkim=pass header.d=kernel.org header.i=@kernel.org header.a=rsa-sha256 header.s=k20260515 header.b=jJ+YsSS1;
	arc=none smtp.remote-ip=100.103.45.18
Received: from smtp.kernel.org (quasi.space.kernel.org [100.103.45.18])
	(using TLSv1.3 with cipher TLS_AES_256_GCM_SHA384 (256/256 bits)
	 key-exchange X25519 server-signature ECDSA (prime256v1))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 9E895607A3C1;
	Wed,  4 Nov 2026 17:57:00 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key, unprotected) header.d=kernel.org header.i=@kernel.org header.a=rsa-sha256 header.s=k20260515 header.b=jJ+YsSS1
Received: by smtp.kernel.org (Postfix) with ESMTPSA id 0110B1F000C1;
	Wed,  4 Nov 2026 17:56:43 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=kernel.org;
	s=k20260515; t=1793815020;
	bh=qeQgphPdxdiWtw36JzKqWooMSgzPZU+EeD4NlyLVhDM=;
	h=From:To:Cc:Subject:Date:In-Reply-To:References;
	b=jJ+YsSS1mKgXVutXvIprPjWbk/f3EaiHLkE0iUZZAD8UlGdeiTsq37AMjiJ1LQO42
	 s7IKloTcsbSWCr6Lc4020v768o++Pni3fgFkFO5tp1ySQmamfYyvOlYF89oN/AE0uz
	 cDBLCJtKpTc2bEc32o8AER5NNVvUQIyxG/58XGRNwW4UebnC4TzH2w4THg6Y4IuZEE
	 HY4QLlr1k8HjiamlPJYs4KZrW3+I6WmOXTXZ8NvkX2h2a4OGzF5wxpPCxFfmNGgkxC
	 TEjrpd9SN8JK0f/Vf8mgRK+nlmhJ6yDeGzIC6DtBcVm6ZCj3+6Kd0iuDWQx/Ae1YSo
	 KOmYuIt4jqdDw==
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
Subject: [PATCH v2 39/51] powerpc/crash_dump: recover from a machine check in copy_oldmem_page()
Date: Wed,  4 Nov 2026 18:47:25 +0100
Message-ID: <20261104-work-procfs-bugfixes-v2-39-bbf7d5546809@kernel.org>
In-Reply-To: <20261104-work-procfs-bugfixes-v2-0-bbf7d5546809@kernel.org>
References: <20261104-work-procfs-bugfixes-v2-0-bbf7d5546809@kernel.org>
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
X-Developer-Signature: v=1; a=openpgp-sha256; l=2421; i=brauner@kernel.org; h=from:subject:message-id; bh=VIVKq8y+KdCJwnDd/z4L2OCrr1yqDfObdGoCOSjiCdM=; b=owGbwMvMwCU28Zj0gdSKO4sYT6slMWS9znu/ZLFx05xpnp+TTtxLuaWnvKXR5q5SRcWM5RNFJ +7uuXKbraOUhUGMi0FWTJHFod0kXG45T8Vmo0wNmDmsTCBDGLg4BWAi0wIZ/nB7KCi471/L1Nq6 9n0/51Uea/Fd3qy9fnsOr1vwmcnr62yG/yWGkZU+VvatQgcYS97WRSfuKtivn95TcozLZv5XWWl eDgA=
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

