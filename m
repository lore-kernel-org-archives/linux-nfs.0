Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.remote-ip=173.212.254.19
ARC-Seal: i=1; d=subspace.kernel.org; s=arc20261015; a=rsa-sha256; cv=none;
	t=1792552599;
	b=wah+5N8TMjaVXSg4QKyKvG6Fb6zyaiiC5NCwDRiDAu1BrdmS/qb4n1pl2vHhg3NFtfKH
	 yJgPpjSYIlDWeCwJxvgLZNzj71ePBcDnf5YZnRUzam6+2m0SNmEwLwi4szjNls3MqUFdA
	 52XX8GCAsUlhXv7KLkEktZsS6p+a7YBscerc08/PbCosHh2dzUHIUmn525j4OGFNeiFyj
	 HTve10aYB6m01+K4djCCOKnPLBdFPvAtZ4DweKcFRWcHJeMrxr1tgH5trDyWszPI8NOrr
	 ne2ATdXysAnWPI4BX68RVRhhvt+KZo4cR75zLuacdbuAAIYyByYXMoAU6OSJpYbZWQg==
ARC-Message-Signature: i=1; d=subspace.kernel.org; s=arc20261015;
	a=rsa-sha256; c=relaxed/relaxed; t=1792552599;
	h=DMARC-Filter:DKIM-Signature:Received:Message-ID:In-Reply-To:
	 References:From:Subject:To:Cc:Date;
	bh=FrlK+4v6tISSCo0hgOXhUqR4jvlPBThqmhMhDsD7inI=;
	b=PwRAHZ7NIPZ0nFlJIwk4dB3swNpUMea3D43lKc4sNEjB6z34LfcT8EXvGf6mkYApOJhY
	 fHREkWEmhmgOIW9tdqqCNTcRYl5/yDEwLqMSrYu6vsq6hoEyPVmfSgVSaU4/oOW+/3KIU
	 F8WUd4pN1bGEzxpqtBxZ+uq9/WtKHb5QcVOv2xfnz3y6RWOHg1UxLoKTIo2WH+LYab2zn
	 O7yRrLtJqnULnKbvrmhtqnXZxIjiRZgRqXu0WTY4y2vW4iw7IgHX/gwC7mEMjeFUpo9hf
	 nRVf8Dq0Kuoui85G6V5jgEses1qI1KEbqG7cEkbdpqmfX0wmJYWguKL5qs8bEJj0Jnw==
ARC-Authentication-Results: i=1; smtp.subspace.kernel.org; 
	dmarc=pass header.from=tuxist.de;
	spf=fail smtp.mailfrom=tuxist.de;
	dkim=pass header.d=tuxist.de header.i=@tuxist.de header.a=rsa-sha256 header.s=201705 header.b=KX5swtju;
	arc=none smtp.remote-ip=173.212.254.19
Received: from groupware.tuxist.de (groupware.tuxist.de [173.212.254.19])
	(using TLSv1.3 with cipher TLS_AES_256_GCM_SHA384 (256/256 bits)
	 key-exchange X25519 server-signature ECDSA (prime256v1) server-digest SHA256)
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 3B86860A6F47;
	Wed, 21 Oct 2026 03:16:38 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.4.2 smtp.subspace.kernel.org 3B86860A6F47
Authentication-Results: smtp.subspace.kernel.org; dmarc=pass (p=reject dis=none) header.from=tuxist.de
Authentication-Results: smtp.subspace.kernel.org; spf=fail smtp.mailfrom=tuxist.de
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key, unprotected) header.d=tuxist.de header.i=@tuxist.de header.a=rsa-sha256 header.s=201705 header.b=KX5swtju
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/simple; d=tuxist.de; s=201705;
	t=1792552596; bh=PNV+j5X8PaQS4BJAGJu1rKZrfJvQMnkNu76c7vN73vE=;
	h=In-Reply-To:References:From:Subject:To:Cc:Date:From;
	b=KX5swtju8hh8/l4MZt2tvdzTlEN1jWBflaHHA8YIPBXGohsuiaB70RyrnppNte9lt
	 fn96DqxLwZCiUmSZg+FkpeXTe/TBX+uBpSkBK4t7jxq+vYe/Q7O4Os/f9kYcya3B9H
	 oqRWl3GDbwINkJSuNYLVwn+HQNhKqdZ/zDboLu7oWj7ehimRPc5BR2p/OxgGkwvXIP
	 UHG0CFjsgl68QtIM6JHhNhWSh7fLfG7QufRAvcBD1gwyvtEx8wG4fV2/i1EVX/772F
	 d4FSnQNUiNR5XBA4Ezz1A4eYPZ0eabXEDEQVSlB6cFokUeinE5lvYxnoPCnbjaPo6y
	 YBMEvJSMRnGAA==
Received: from [10.1.1.106] (unknown [10.1.2.1])
	(using TLSv1.2 with cipher ECDHE-RSA-AES128-GCM-SHA256 (128/128 bits))
	(No client certificate requested)
	by groupware.tuxist.de (Postfix) with ESMTPSA id DF2598A0927;
	Wed, 21 Oct 2026 05:16:35 +0200 (CEST)
Message-ID: <014ca715d4d35199cda084420f0c7b8163d64cab.1792552161.git.jan.koester@tuxist.de>
In-Reply-To: <cover.1792552161.git.jan.koester@tuxist.de>
References: <cover.1792552161.git.jan.koester@tuxist.de>
From: Jan Koester <jan.koester@tuxist.de>
Subject: [RFC PATCH v2 22/41] arch: wire up the *_r uid and gid system calls
To: Christian Brauner <brauner@kernel.org>,
    Alexander Viro <viro@zeniv.linux.org.uk>,
    "Serge E. Hallyn" <serge@hallyn.com>
Cc: Jan Kara <jack@suse.cz>,
    "Theodore Y. Ts'o" <tytso@mit.edu>,
    Paul Moore <paul@paul-moore.com>,
    Arnd Bergmann <arnd@arndb.de>,
    linux-fsdevel@vger.kernel.org,
    linux-api@vger.kernel.org,
    linux-security-module@vger.kernel.org,
    linux-arch@vger.kernel.org,
    linux-ext4@vger.kernel.org,
    linux-nfs@vger.kernel.org,
    linux-cifs@vger.kernel.org,
    netdev@vger.kernel.org,
    audit@vger.kernel.org,
    keyrings@vger.kernel.org,
    linux-kernel@vger.kernel.org
Date: Wed, 21 Oct 2026 05:15:42 +0200
X-Mailing-List: linux-nfs@vger.kernel.org
List-Id: <linux-nfs.vger.kernel.org>
List-Post: <mailto:linux-nfs@vger.kernel.org>
List-Help: <mailto:linux-nfs+help@vger.kernel.org>
List-Subscribe: <mailto:linux-nfs+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:linux-nfs+unsubscribe@vger.kernel.org>
List-Owner: <mailto:linux-nfs+owner@vger.kernel.org>
Precedence: list

Assign 472-491 on all architectures (582-601 on alpha) to getuid_r,
geteuid_r, getgid_r, getegid_r, setuid_r, setgid_r, setreuid_r,
setregid_r, setresuid_r, getresuid_r, setresgid_r, getresgid_r,
setfsuid_r, setfsgid_r, getgroups_r, setgroups_r, chown_r, lchown_r,
fchown_r and fchownat_r.

__kernel_uid_r_t has the same layout on all ABIs, so the compat ABIs
use the native entry points.

Assisted-by: Claude:claude-opus-5-5

Signed-off-by: Jan Koester <jan.koester@tuxist.de>
---
 arch/alpha/kernel/syscalls/syscall.tbl      | 20 ++++++++++
 arch/arm/tools/syscall.tbl                  | 20 ++++++++++
 arch/arm64/tools/syscall_32.tbl             | 20 ++++++++++
 arch/m68k/kernel/syscalls/syscall.tbl       | 20 ++++++++++
 arch/microblaze/kernel/syscalls/syscall.tbl | 20 ++++++++++
 arch/mips/kernel/syscalls/syscall_n32.tbl   | 20 ++++++++++
 arch/mips/kernel/syscalls/syscall_n64.tbl   | 20 ++++++++++
 arch/mips/kernel/syscalls/syscall_o32.tbl   | 20 ++++++++++
 arch/parisc/kernel/syscalls/syscall.tbl     | 20 ++++++++++
 arch/powerpc/kernel/syscalls/syscall.tbl    | 20 ++++++++++
 arch/s390/kernel/syscalls/syscall.tbl       | 20 ++++++++++
 arch/sh/kernel/syscalls/syscall.tbl         | 20 ++++++++++
 arch/sparc/kernel/syscalls/syscall.tbl      | 20 ++++++++++
 arch/x86/entry/syscalls/syscall_32.tbl      | 20 ++++++++++
 arch/x86/entry/syscalls/syscall_64.tbl      | 20 ++++++++++
 arch/xtensa/kernel/syscalls/syscall.tbl     | 20 ++++++++++
 include/uapi/asm-generic/unistd.h           | 43 ++++++++++++++++++++-
 scripts/syscall.tbl                         | 20 ++++++++++
 18 files changed, 382 insertions(+), 1 deletion(-)

diff --git a/arch/alpha/kernel/syscalls/syscall.tbl b/arch/alpha/kernel/syscalls/syscall.tbl
index 52e3538cc7..dbf741faf9 100644
--- a/arch/alpha/kernel/syscalls/syscall.tbl
+++ b/arch/alpha/kernel/syscalls/syscall.tbl
@@ -512,3 +512,23 @@
 580	common	listns				sys_listns
 581	common	rseq_slice_yield		sys_rseq_slice_yield
 582	common	fchroot				sys_fchroot
+583	common	getuid_r		sys_getuid_r
+584	common	geteuid_r		sys_geteuid_r
+585	common	getgid_r		sys_getgid_r
+586	common	getegid_r		sys_getegid_r
+587	common	setuid_r		sys_setuid_r
+588	common	setgid_r		sys_setgid_r
+589	common	setreuid_r		sys_setreuid_r
+590	common	setregid_r		sys_setregid_r
+591	common	setresuid_r		sys_setresuid_r
+592	common	getresuid_r		sys_getresuid_r
+593	common	setresgid_r		sys_setresgid_r
+594	common	getresgid_r		sys_getresgid_r
+595	common	setfsuid_r		sys_setfsuid_r
+596	common	setfsgid_r		sys_setfsgid_r
+597	common	getgroups_r		sys_getgroups_r
+598	common	setgroups_r		sys_setgroups_r
+599	common	chown_r		sys_chown_r
+600	common	lchown_r		sys_lchown_r
+601	common	fchown_r		sys_fchown_r
+602	common	fchownat_r		sys_fchownat_r
diff --git a/arch/arm/tools/syscall.tbl b/arch/arm/tools/syscall.tbl
index 55717ed32c..82219c1d42 100644
--- a/arch/arm/tools/syscall.tbl
+++ b/arch/arm/tools/syscall.tbl
@@ -487,3 +487,23 @@
 470	common	listns				sys_listns
 471	common	rseq_slice_yield		sys_rseq_slice_yield
 472	common	fchroot				sys_fchroot
+473	common	getuid_r		sys_getuid_r
+474	common	geteuid_r		sys_geteuid_r
+475	common	getgid_r		sys_getgid_r
+476	common	getegid_r		sys_getegid_r
+477	common	setuid_r		sys_setuid_r
+478	common	setgid_r		sys_setgid_r
+479	common	setreuid_r		sys_setreuid_r
+480	common	setregid_r		sys_setregid_r
+481	common	setresuid_r		sys_setresuid_r
+482	common	getresuid_r		sys_getresuid_r
+483	common	setresgid_r		sys_setresgid_r
+484	common	getresgid_r		sys_getresgid_r
+485	common	setfsuid_r		sys_setfsuid_r
+486	common	setfsgid_r		sys_setfsgid_r
+487	common	getgroups_r		sys_getgroups_r
+488	common	setgroups_r		sys_setgroups_r
+489	common	chown_r		sys_chown_r
+490	common	lchown_r		sys_lchown_r
+491	common	fchown_r		sys_fchown_r
+492	common	fchownat_r		sys_fchownat_r
diff --git a/arch/arm64/tools/syscall_32.tbl b/arch/arm64/tools/syscall_32.tbl
index df2d1d82fb..9e64c3e51a 100644
--- a/arch/arm64/tools/syscall_32.tbl
+++ b/arch/arm64/tools/syscall_32.tbl
@@ -484,3 +484,23 @@
 470	common	listns				sys_listns
 471	common	rseq_slice_yield		sys_rseq_slice_yield
 472	common	fchroot				sys_fchroot
+473	common	getuid_r		sys_getuid_r
+474	common	geteuid_r		sys_geteuid_r
+475	common	getgid_r		sys_getgid_r
+476	common	getegid_r		sys_getegid_r
+477	common	setuid_r		sys_setuid_r
+478	common	setgid_r		sys_setgid_r
+479	common	setreuid_r		sys_setreuid_r
+480	common	setregid_r		sys_setregid_r
+481	common	setresuid_r		sys_setresuid_r
+482	common	getresuid_r		sys_getresuid_r
+483	common	setresgid_r		sys_setresgid_r
+484	common	getresgid_r		sys_getresgid_r
+485	common	setfsuid_r		sys_setfsuid_r
+486	common	setfsgid_r		sys_setfsgid_r
+487	common	getgroups_r		sys_getgroups_r
+488	common	setgroups_r		sys_setgroups_r
+489	common	chown_r		sys_chown_r
+490	common	lchown_r		sys_lchown_r
+491	common	fchown_r		sys_fchown_r
+492	common	fchownat_r		sys_fchownat_r
diff --git a/arch/m68k/kernel/syscalls/syscall.tbl b/arch/m68k/kernel/syscalls/syscall.tbl
index ba7a4d8903..6b82f0265f 100644
--- a/arch/m68k/kernel/syscalls/syscall.tbl
+++ b/arch/m68k/kernel/syscalls/syscall.tbl
@@ -472,3 +472,23 @@
 470	common	listns				sys_listns
 471	common	rseq_slice_yield		sys_rseq_slice_yield
 472	common	fchroot				sys_fchroot
+473	common	getuid_r		sys_getuid_r
+474	common	geteuid_r		sys_geteuid_r
+475	common	getgid_r		sys_getgid_r
+476	common	getegid_r		sys_getegid_r
+477	common	setuid_r		sys_setuid_r
+478	common	setgid_r		sys_setgid_r
+479	common	setreuid_r		sys_setreuid_r
+480	common	setregid_r		sys_setregid_r
+481	common	setresuid_r		sys_setresuid_r
+482	common	getresuid_r		sys_getresuid_r
+483	common	setresgid_r		sys_setresgid_r
+484	common	getresgid_r		sys_getresgid_r
+485	common	setfsuid_r		sys_setfsuid_r
+486	common	setfsgid_r		sys_setfsgid_r
+487	common	getgroups_r		sys_getgroups_r
+488	common	setgroups_r		sys_setgroups_r
+489	common	chown_r		sys_chown_r
+490	common	lchown_r		sys_lchown_r
+491	common	fchown_r		sys_fchown_r
+492	common	fchownat_r		sys_fchownat_r
diff --git a/arch/microblaze/kernel/syscalls/syscall.tbl b/arch/microblaze/kernel/syscalls/syscall.tbl
index c55a5c96f4..5b414aa124 100644
--- a/arch/microblaze/kernel/syscalls/syscall.tbl
+++ b/arch/microblaze/kernel/syscalls/syscall.tbl
@@ -478,3 +478,23 @@
 470	common	listns				sys_listns
 471	common	rseq_slice_yield		sys_rseq_slice_yield
 472	common	fchroot				sys_fchroot
+473	common	getuid_r		sys_getuid_r
+474	common	geteuid_r		sys_geteuid_r
+475	common	getgid_r		sys_getgid_r
+476	common	getegid_r		sys_getegid_r
+477	common	setuid_r		sys_setuid_r
+478	common	setgid_r		sys_setgid_r
+479	common	setreuid_r		sys_setreuid_r
+480	common	setregid_r		sys_setregid_r
+481	common	setresuid_r		sys_setresuid_r
+482	common	getresuid_r		sys_getresuid_r
+483	common	setresgid_r		sys_setresgid_r
+484	common	getresgid_r		sys_getresgid_r
+485	common	setfsuid_r		sys_setfsuid_r
+486	common	setfsgid_r		sys_setfsgid_r
+487	common	getgroups_r		sys_getgroups_r
+488	common	setgroups_r		sys_setgroups_r
+489	common	chown_r		sys_chown_r
+490	common	lchown_r		sys_lchown_r
+491	common	fchown_r		sys_fchown_r
+492	common	fchownat_r		sys_fchownat_r
diff --git a/arch/mips/kernel/syscalls/syscall_n32.tbl b/arch/mips/kernel/syscalls/syscall_n32.tbl
index 9ae88e4eac..ed6bddb005 100644
--- a/arch/mips/kernel/syscalls/syscall_n32.tbl
+++ b/arch/mips/kernel/syscalls/syscall_n32.tbl
@@ -411,3 +411,23 @@
 470	n32	listns				sys_listns
 471	n32	rseq_slice_yield		sys_rseq_slice_yield
 472	n32	fchroot				sys_fchroot
+473	n32	getuid_r		sys_getuid_r
+474	n32	geteuid_r		sys_geteuid_r
+475	n32	getgid_r		sys_getgid_r
+476	n32	getegid_r		sys_getegid_r
+477	n32	setuid_r		sys_setuid_r
+478	n32	setgid_r		sys_setgid_r
+479	n32	setreuid_r		sys_setreuid_r
+480	n32	setregid_r		sys_setregid_r
+481	n32	setresuid_r		sys_setresuid_r
+482	n32	getresuid_r		sys_getresuid_r
+483	n32	setresgid_r		sys_setresgid_r
+484	n32	getresgid_r		sys_getresgid_r
+485	n32	setfsuid_r		sys_setfsuid_r
+486	n32	setfsgid_r		sys_setfsgid_r
+487	n32	getgroups_r		sys_getgroups_r
+488	n32	setgroups_r		sys_setgroups_r
+489	n32	chown_r		sys_chown_r
+490	n32	lchown_r		sys_lchown_r
+491	n32	fchown_r		sys_fchown_r
+492	n32	fchownat_r		sys_fchownat_r
diff --git a/arch/mips/kernel/syscalls/syscall_n64.tbl b/arch/mips/kernel/syscalls/syscall_n64.tbl
index 83dc93a071..716ea51670 100644
--- a/arch/mips/kernel/syscalls/syscall_n64.tbl
+++ b/arch/mips/kernel/syscalls/syscall_n64.tbl
@@ -387,3 +387,23 @@
 470	n64	listns				sys_listns
 471	n64	rseq_slice_yield		sys_rseq_slice_yield
 472	n64	fchroot				sys_fchroot
+473	n64	getuid_r		sys_getuid_r
+474	n64	geteuid_r		sys_geteuid_r
+475	n64	getgid_r		sys_getgid_r
+476	n64	getegid_r		sys_getegid_r
+477	n64	setuid_r		sys_setuid_r
+478	n64	setgid_r		sys_setgid_r
+479	n64	setreuid_r		sys_setreuid_r
+480	n64	setregid_r		sys_setregid_r
+481	n64	setresuid_r		sys_setresuid_r
+482	n64	getresuid_r		sys_getresuid_r
+483	n64	setresgid_r		sys_setresgid_r
+484	n64	getresgid_r		sys_getresgid_r
+485	n64	setfsuid_r		sys_setfsuid_r
+486	n64	setfsgid_r		sys_setfsgid_r
+487	n64	getgroups_r		sys_getgroups_r
+488	n64	setgroups_r		sys_setgroups_r
+489	n64	chown_r		sys_chown_r
+490	n64	lchown_r		sys_lchown_r
+491	n64	fchown_r		sys_fchown_r
+492	n64	fchownat_r		sys_fchownat_r
diff --git a/arch/mips/kernel/syscalls/syscall_o32.tbl b/arch/mips/kernel/syscalls/syscall_o32.tbl
index 9c62429c9b..5f7178745f 100644
--- a/arch/mips/kernel/syscalls/syscall_o32.tbl
+++ b/arch/mips/kernel/syscalls/syscall_o32.tbl
@@ -460,3 +460,23 @@
 470	o32	listns				sys_listns
 471	o32	rseq_slice_yield		sys_rseq_slice_yield
 472	o32	fchroot				sys_fchroot
+473	o32	getuid_r		sys_getuid_r
+474	o32	geteuid_r		sys_geteuid_r
+475	o32	getgid_r		sys_getgid_r
+476	o32	getegid_r		sys_getegid_r
+477	o32	setuid_r		sys_setuid_r
+478	o32	setgid_r		sys_setgid_r
+479	o32	setreuid_r		sys_setreuid_r
+480	o32	setregid_r		sys_setregid_r
+481	o32	setresuid_r		sys_setresuid_r
+482	o32	getresuid_r		sys_getresuid_r
+483	o32	setresgid_r		sys_setresgid_r
+484	o32	getresgid_r		sys_getresgid_r
+485	o32	setfsuid_r		sys_setfsuid_r
+486	o32	setfsgid_r		sys_setfsgid_r
+487	o32	getgroups_r		sys_getgroups_r
+488	o32	setgroups_r		sys_setgroups_r
+489	o32	chown_r		sys_chown_r
+490	o32	lchown_r		sys_lchown_r
+491	o32	fchown_r		sys_fchown_r
+492	o32	fchownat_r		sys_fchownat_r
diff --git a/arch/parisc/kernel/syscalls/syscall.tbl b/arch/parisc/kernel/syscalls/syscall.tbl
index 88adc4016c..47a8a13983 100644
--- a/arch/parisc/kernel/syscalls/syscall.tbl
+++ b/arch/parisc/kernel/syscalls/syscall.tbl
@@ -471,3 +471,23 @@
 470	common	listns				sys_listns
 471	common	rseq_slice_yield		sys_rseq_slice_yield
 472	common	fchroot				sys_fchroot
+473	common	getuid_r		sys_getuid_r
+474	common	geteuid_r		sys_geteuid_r
+475	common	getgid_r		sys_getgid_r
+476	common	getegid_r		sys_getegid_r
+477	common	setuid_r		sys_setuid_r
+478	common	setgid_r		sys_setgid_r
+479	common	setreuid_r		sys_setreuid_r
+480	common	setregid_r		sys_setregid_r
+481	common	setresuid_r		sys_setresuid_r
+482	common	getresuid_r		sys_getresuid_r
+483	common	setresgid_r		sys_setresgid_r
+484	common	getresgid_r		sys_getresgid_r
+485	common	setfsuid_r		sys_setfsuid_r
+486	common	setfsgid_r		sys_setfsgid_r
+487	common	getgroups_r		sys_getgroups_r
+488	common	setgroups_r		sys_setgroups_r
+489	common	chown_r		sys_chown_r
+490	common	lchown_r		sys_lchown_r
+491	common	fchown_r		sys_fchown_r
+492	common	fchownat_r		sys_fchownat_r
diff --git a/arch/powerpc/kernel/syscalls/syscall.tbl b/arch/powerpc/kernel/syscalls/syscall.tbl
index cfbb70039f..66fb8e0146 100644
--- a/arch/powerpc/kernel/syscalls/syscall.tbl
+++ b/arch/powerpc/kernel/syscalls/syscall.tbl
@@ -563,3 +563,23 @@
 470	common	listns				sys_listns
 471	nospu	rseq_slice_yield		sys_rseq_slice_yield
 472	common	fchroot				sys_fchroot
+473	nospu	getuid_r		sys_getuid_r
+474	nospu	geteuid_r		sys_geteuid_r
+475	nospu	getgid_r		sys_getgid_r
+476	nospu	getegid_r		sys_getegid_r
+477	nospu	setuid_r		sys_setuid_r
+478	nospu	setgid_r		sys_setgid_r
+479	nospu	setreuid_r		sys_setreuid_r
+480	nospu	setregid_r		sys_setregid_r
+481	nospu	setresuid_r		sys_setresuid_r
+482	nospu	getresuid_r		sys_getresuid_r
+483	nospu	setresgid_r		sys_setresgid_r
+484	nospu	getresgid_r		sys_getresgid_r
+485	nospu	setfsuid_r		sys_setfsuid_r
+486	nospu	setfsgid_r		sys_setfsgid_r
+487	nospu	getgroups_r		sys_getgroups_r
+488	nospu	setgroups_r		sys_setgroups_r
+489	nospu	chown_r		sys_chown_r
+490	nospu	lchown_r		sys_lchown_r
+491	nospu	fchown_r		sys_fchown_r
+492	nospu	fchownat_r		sys_fchownat_r
diff --git a/arch/s390/kernel/syscalls/syscall.tbl b/arch/s390/kernel/syscalls/syscall.tbl
index 1b45e68a21..dd7e3eca14 100644
--- a/arch/s390/kernel/syscalls/syscall.tbl
+++ b/arch/s390/kernel/syscalls/syscall.tbl
@@ -399,3 +399,23 @@
 470	common	listns				sys_listns
 471	common	rseq_slice_yield		sys_rseq_slice_yield
 472	common	fchroot				sys_fchroot
+473	common	getuid_r		sys_getuid_r
+474	common	geteuid_r		sys_geteuid_r
+475	common	getgid_r		sys_getgid_r
+476	common	getegid_r		sys_getegid_r
+477	common	setuid_r		sys_setuid_r
+478	common	setgid_r		sys_setgid_r
+479	common	setreuid_r		sys_setreuid_r
+480	common	setregid_r		sys_setregid_r
+481	common	setresuid_r		sys_setresuid_r
+482	common	getresuid_r		sys_getresuid_r
+483	common	setresgid_r		sys_setresgid_r
+484	common	getresgid_r		sys_getresgid_r
+485	common	setfsuid_r		sys_setfsuid_r
+486	common	setfsgid_r		sys_setfsgid_r
+487	common	getgroups_r		sys_getgroups_r
+488	common	setgroups_r		sys_setgroups_r
+489	common	chown_r		sys_chown_r
+490	common	lchown_r		sys_lchown_r
+491	common	fchown_r		sys_fchown_r
+492	common	fchownat_r		sys_fchownat_r
diff --git a/arch/sh/kernel/syscalls/syscall.tbl b/arch/sh/kernel/syscalls/syscall.tbl
index ace068dff0..e5a7558785 100644
--- a/arch/sh/kernel/syscalls/syscall.tbl
+++ b/arch/sh/kernel/syscalls/syscall.tbl
@@ -476,3 +476,23 @@
 470	common	listns				sys_listns
 471	common	rseq_slice_yield		sys_rseq_slice_yield
 472	common	fchroot				sys_fchroot
+473	common	getuid_r		sys_getuid_r
+474	common	geteuid_r		sys_geteuid_r
+475	common	getgid_r		sys_getgid_r
+476	common	getegid_r		sys_getegid_r
+477	common	setuid_r		sys_setuid_r
+478	common	setgid_r		sys_setgid_r
+479	common	setreuid_r		sys_setreuid_r
+480	common	setregid_r		sys_setregid_r
+481	common	setresuid_r		sys_setresuid_r
+482	common	getresuid_r		sys_getresuid_r
+483	common	setresgid_r		sys_setresgid_r
+484	common	getresgid_r		sys_getresgid_r
+485	common	setfsuid_r		sys_setfsuid_r
+486	common	setfsgid_r		sys_setfsgid_r
+487	common	getgroups_r		sys_getgroups_r
+488	common	setgroups_r		sys_setgroups_r
+489	common	chown_r		sys_chown_r
+490	common	lchown_r		sys_lchown_r
+491	common	fchown_r		sys_fchown_r
+492	common	fchownat_r		sys_fchownat_r
diff --git a/arch/sparc/kernel/syscalls/syscall.tbl b/arch/sparc/kernel/syscalls/syscall.tbl
index 5b9fe0e814..974556f815 100644
--- a/arch/sparc/kernel/syscalls/syscall.tbl
+++ b/arch/sparc/kernel/syscalls/syscall.tbl
@@ -518,3 +518,23 @@
 470	common	listns				sys_listns
 471	common	rseq_slice_yield		sys_rseq_slice_yield
 472	common	fchroot				sys_fchroot
+473	common	getuid_r		sys_getuid_r
+474	common	geteuid_r		sys_geteuid_r
+475	common	getgid_r		sys_getgid_r
+476	common	getegid_r		sys_getegid_r
+477	common	setuid_r		sys_setuid_r
+478	common	setgid_r		sys_setgid_r
+479	common	setreuid_r		sys_setreuid_r
+480	common	setregid_r		sys_setregid_r
+481	common	setresuid_r		sys_setresuid_r
+482	common	getresuid_r		sys_getresuid_r
+483	common	setresgid_r		sys_setresgid_r
+484	common	getresgid_r		sys_getresgid_r
+485	common	setfsuid_r		sys_setfsuid_r
+486	common	setfsgid_r		sys_setfsgid_r
+487	common	getgroups_r		sys_getgroups_r
+488	common	setgroups_r		sys_setgroups_r
+489	common	chown_r		sys_chown_r
+490	common	lchown_r		sys_lchown_r
+491	common	fchown_r		sys_fchown_r
+492	common	fchownat_r		sys_fchownat_r
diff --git a/arch/x86/entry/syscalls/syscall_32.tbl b/arch/x86/entry/syscalls/syscall_32.tbl
index 2c172ef48d..32f8dfd8cb 100644
--- a/arch/x86/entry/syscalls/syscall_32.tbl
+++ b/arch/x86/entry/syscalls/syscall_32.tbl
@@ -478,3 +478,23 @@
 470	i386	listns			sys_listns
 471	i386	rseq_slice_yield	sys_rseq_slice_yield
 472	i386	fchroot			sys_fchroot
+473	i386	getuid_r	sys_getuid_r
+474	i386	geteuid_r	sys_geteuid_r
+475	i386	getgid_r	sys_getgid_r
+476	i386	getegid_r	sys_getegid_r
+477	i386	setuid_r	sys_setuid_r
+478	i386	setgid_r	sys_setgid_r
+479	i386	setreuid_r	sys_setreuid_r
+480	i386	setregid_r	sys_setregid_r
+481	i386	setresuid_r	sys_setresuid_r
+482	i386	getresuid_r	sys_getresuid_r
+483	i386	setresgid_r	sys_setresgid_r
+484	i386	getresgid_r	sys_getresgid_r
+485	i386	setfsuid_r	sys_setfsuid_r
+486	i386	setfsgid_r	sys_setfsgid_r
+487	i386	getgroups_r	sys_getgroups_r
+488	i386	setgroups_r	sys_setgroups_r
+489	i386	chown_r		sys_chown_r
+490	i386	lchown_r	sys_lchown_r
+491	i386	fchown_r	sys_fchown_r
+492	i386	fchownat_r	sys_fchownat_r
diff --git a/arch/x86/entry/syscalls/syscall_64.tbl b/arch/x86/entry/syscalls/syscall_64.tbl
index d5b6045b00..e89eaeba19 100644
--- a/arch/x86/entry/syscalls/syscall_64.tbl
+++ b/arch/x86/entry/syscalls/syscall_64.tbl
@@ -397,6 +397,26 @@
 470	common	listns			sys_listns
 471	common	rseq_slice_yield	sys_rseq_slice_yield
 472	common	fchroot			sys_fchroot
+473	common	getuid_r	sys_getuid_r
+474	common	geteuid_r	sys_geteuid_r
+475	common	getgid_r	sys_getgid_r
+476	common	getegid_r	sys_getegid_r
+477	common	setuid_r	sys_setuid_r
+478	common	setgid_r	sys_setgid_r
+479	common	setreuid_r	sys_setreuid_r
+480	common	setregid_r	sys_setregid_r
+481	common	setresuid_r	sys_setresuid_r
+482	common	getresuid_r	sys_getresuid_r
+483	common	setresgid_r	sys_setresgid_r
+484	common	getresgid_r	sys_getresgid_r
+485	common	setfsuid_r	sys_setfsuid_r
+486	common	setfsgid_r	sys_setfsgid_r
+487	common	getgroups_r	sys_getgroups_r
+488	common	setgroups_r	sys_setgroups_r
+489	common	chown_r		sys_chown_r
+490	common	lchown_r	sys_lchown_r
+491	common	fchown_r	sys_fchown_r
+492	common	fchownat_r	sys_fchownat_r
 
 #
 # Due to a historical design error, certain syscalls are numbered differently
diff --git a/arch/xtensa/kernel/syscalls/syscall.tbl b/arch/xtensa/kernel/syscalls/syscall.tbl
index d354bb2317..6c80877a6e 100644
--- a/arch/xtensa/kernel/syscalls/syscall.tbl
+++ b/arch/xtensa/kernel/syscalls/syscall.tbl
@@ -443,3 +443,23 @@
 470	common	listns				sys_listns
 471	common	rseq_slice_yield		sys_rseq_slice_yield
 472	common	fchroot				sys_fchroot
+473	common	getuid_r		sys_getuid_r
+474	common	geteuid_r		sys_geteuid_r
+475	common	getgid_r		sys_getgid_r
+476	common	getegid_r		sys_getegid_r
+477	common	setuid_r		sys_setuid_r
+478	common	setgid_r		sys_setgid_r
+479	common	setreuid_r		sys_setreuid_r
+480	common	setregid_r		sys_setregid_r
+481	common	setresuid_r		sys_setresuid_r
+482	common	getresuid_r		sys_getresuid_r
+483	common	setresgid_r		sys_setresgid_r
+484	common	getresgid_r		sys_getresgid_r
+485	common	setfsuid_r		sys_setfsuid_r
+486	common	setfsgid_r		sys_setfsgid_r
+487	common	getgroups_r		sys_getgroups_r
+488	common	setgroups_r		sys_setgroups_r
+489	common	chown_r		sys_chown_r
+490	common	lchown_r		sys_lchown_r
+491	common	fchown_r		sys_fchown_r
+492	common	fchownat_r		sys_fchownat_r
diff --git a/include/uapi/asm-generic/unistd.h b/include/uapi/asm-generic/unistd.h
index 5b7e77a7c7..8475635005 100644
--- a/include/uapi/asm-generic/unistd.h
+++ b/include/uapi/asm-generic/unistd.h
@@ -867,8 +867,49 @@ __SYSCALL(__NR_rseq_slice_yield, sys_rseq_slice_yield)
 #define __NR_fchroot 472
 __SYSCALL(__NR_fchroot, sys_fchroot)
 
+#define __NR_getuid_r 473
+__SYSCALL(__NR_getuid_r, sys_getuid_r)
+#define __NR_geteuid_r 474
+__SYSCALL(__NR_geteuid_r, sys_geteuid_r)
+#define __NR_getgid_r 475
+__SYSCALL(__NR_getgid_r, sys_getgid_r)
+#define __NR_getegid_r 476
+__SYSCALL(__NR_getegid_r, sys_getegid_r)
+#define __NR_setuid_r 477
+__SYSCALL(__NR_setuid_r, sys_setuid_r)
+#define __NR_setgid_r 478
+__SYSCALL(__NR_setgid_r, sys_setgid_r)
+#define __NR_setreuid_r 479
+__SYSCALL(__NR_setreuid_r, sys_setreuid_r)
+#define __NR_setregid_r 480
+__SYSCALL(__NR_setregid_r, sys_setregid_r)
+#define __NR_setresuid_r 481
+__SYSCALL(__NR_setresuid_r, sys_setresuid_r)
+#define __NR_getresuid_r 482
+__SYSCALL(__NR_getresuid_r, sys_getresuid_r)
+#define __NR_setresgid_r 483
+__SYSCALL(__NR_setresgid_r, sys_setresgid_r)
+#define __NR_getresgid_r 484
+__SYSCALL(__NR_getresgid_r, sys_getresgid_r)
+#define __NR_setfsuid_r 485
+__SYSCALL(__NR_setfsuid_r, sys_setfsuid_r)
+#define __NR_setfsgid_r 486
+__SYSCALL(__NR_setfsgid_r, sys_setfsgid_r)
+#define __NR_getgroups_r 487
+__SYSCALL(__NR_getgroups_r, sys_getgroups_r)
+#define __NR_setgroups_r 488
+__SYSCALL(__NR_setgroups_r, sys_setgroups_r)
+#define __NR_chown_r 489
+__SYSCALL(__NR_chown_r, sys_chown_r)
+#define __NR_lchown_r 490
+__SYSCALL(__NR_lchown_r, sys_lchown_r)
+#define __NR_fchown_r 491
+__SYSCALL(__NR_fchown_r, sys_fchown_r)
+#define __NR_fchownat_r 492
+__SYSCALL(__NR_fchownat_r, sys_fchownat_r)
+
 #undef __NR_syscalls
-#define __NR_syscalls 473
+#define __NR_syscalls 493
 
 /*
  * 32 bit systems traditionally used different
diff --git a/scripts/syscall.tbl b/scripts/syscall.tbl
index 0ab5316051..10f9ff35d9 100644
--- a/scripts/syscall.tbl
+++ b/scripts/syscall.tbl
@@ -413,3 +413,23 @@
 470	common	listns				sys_listns
 471	common	rseq_slice_yield		sys_rseq_slice_yield
 472	common	fchroot				sys_fchroot
+473	common	getuid_r		sys_getuid_r
+474	common	geteuid_r		sys_geteuid_r
+475	common	getgid_r		sys_getgid_r
+476	common	getegid_r		sys_getegid_r
+477	common	setuid_r		sys_setuid_r
+478	common	setgid_r		sys_setgid_r
+479	common	setreuid_r		sys_setreuid_r
+480	common	setregid_r		sys_setregid_r
+481	common	setresuid_r		sys_setresuid_r
+482	common	getresuid_r		sys_getresuid_r
+483	common	setresgid_r		sys_setresgid_r
+484	common	getresgid_r		sys_getresgid_r
+485	common	setfsuid_r		sys_setfsuid_r
+486	common	setfsgid_r		sys_setfsgid_r
+487	common	getgroups_r		sys_getgroups_r
+488	common	setgroups_r		sys_setgroups_r
+489	common	chown_r		sys_chown_r
+490	common	lchown_r		sys_lchown_r
+491	common	fchown_r		sys_fchown_r
+492	common	fchownat_r		sys_fchownat_r
-- 
2.56.0

