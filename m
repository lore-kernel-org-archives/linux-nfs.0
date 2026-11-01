Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.remote-ip=100.103.45.18
ARC-Seal: i=1; d=subspace.kernel.org; s=arc20261015; a=rsa-sha256; cv=none;
	t=1793548281;
	b=XpG+jkaZIGJW4fjn/brrzRemIE/eb0hdKZiRvZB6FX5sCHBJ1rji4YlAGnPzVIMR6fma
	 ayVybNIG/AMg6QeZpjtz9U5FDFtpNUzBQfma8X+M3ImFhu2J8W+Hn4pA5LuHCEl2fejv/
	 h/DXpMqDuGOqNrIPSMlzcC5BjSd/kYXB1WlDT0KAnKpl9M5uDohQ+nleHNLDWlvjn7Qlo
	 fmICKuMETFPWv/gORqArCQ9p6KgQN7mvd+iGe6jbNjhNbEe8Oqhbrpo460MU2SJuQ4/T1
	 5pf2CzmLW2qG9xMFyS4bUqqhGW28TRHmDGBijZsQER8Xj2x/woJkDsb1GmdLPFqKySg==
ARC-Message-Signature: i=1; d=subspace.kernel.org; s=arc20261015;
	a=rsa-sha256; c=relaxed/relaxed; t=1793548281;
	h=Received:DKIM-Signature:From:Subject:Date:Message-Id:MIME-Version:
	 Content-Type:Content-Transfer-Encoding:X-B4-Tracking:X-Change-ID:To:
	 Cc:X-Mailer:X-Developer-Signature:X-Developer-Key;
	bh=Cq+s2t+7tMsZIq2OvqLBiq37s3CihVFhMMqbQJ0kiVA=;
	b=ow9h6u+T1XoM1w70GrfD2wpZU5KoqFojGv1LiaLoQzJ8rBVISuBoBtJw56x0hOwjNM+R
	 Y5+A2yC9FZsbdcHJrb6UX9pJsB7hThFEhcofQNAIXG7StZB7yENq6s5PUYeGzs46U4C+K
	 Abrx+JNWCee4BTUcRbgggNJykAlMoTgjI15h3/nGxvpUhYdiHS3hIn436fFDSsblKsiAE
	 ESZYZG8GYIcevUppGGwrcxAGP/gXVqfWGiHiojr6bT3cNJYyHO68kC9dMkJX/7qdrM8JP
	 TUUV4P2cEEvg2mgkIclN84AJjEbGpILH1P9S/+/ZEVvse84F+KCr5Fn6grXeI37RIyg==
ARC-Authentication-Results: i=1; smtp.subspace.kernel.org; 
	dkim=pass header.d=kernel.org header.i=@kernel.org header.a=rsa-sha256 header.s=k20260515 header.b=Wwe+Q9Mg;
	arc=none smtp.remote-ip=100.103.45.18
Received: from smtp.kernel.org (quasi.space.kernel.org [100.103.45.18])
	(using TLSv1.3 with cipher TLS_AES_256_GCM_SHA384 (256/256 bits)
	 key-exchange X25519 server-signature ECDSA (prime256v1))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id C010E606A324
	for <linux-nfs@vger.kernel.org>; Sun,  1 Nov 2026 15:51:20 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key, unprotected) header.d=kernel.org header.i=@kernel.org header.a=rsa-sha256 header.s=k20260515 header.b=Wwe+Q9Mg
Received: by smtp.kernel.org (Postfix) with ESMTPSA id B49501F0093A;
	Sun,  1 Nov 2026 15:51:19 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=kernel.org;
	s=k20260515; t=1793548280;
	bh=Cq+s2t+7tMsZIq2OvqLBiq37s3CihVFhMMqbQJ0kiVA=;
	h=From:Subject:Date:To:Cc;
	b=Wwe+Q9MgTSZQ/3/sLfzoyo3SEXMB03A9LO1WA0b+o//q/EqsSjpPbfNqwt9MkydlC
	 QNxIv7KrPjqChRLheccgCGGl9ZIrsBfVeLbgKHvrdaFyjSOAJtrE7VcKUf49+JAxvS
	 LDuQMAL0V/Q8gcuuRGjGzbFeIwuAn3k9xXOQq4gUdx0TypWTAJWmglw57nJ1R/CUQN
	 MntKBmoudq8ZkfXaJ+6NdgWg+7s2xbxHm8u6N+2MNQLje+GDiYD1XtBtmPA4dxtI5M
	 I9Tkofo9ZbmS5puWPrA13BysY+s8GCGUuK8e03OJVelYv5Q8DRB49A1JYAwjq00upU
	 K61k/V90savXA==
From: Chuck Lever <cel@kernel.org>
Subject: [PATCH v6 0/3] NFSD: Enforce export security after a deferred
 PUTFH check
Date: Sun, 01 Nov 2026 10:51:09 -0500
Message-Id: <20261101-verofess-v6-0-4d70097db7d3@kernel.org>
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
X-B4-Tracking: v=1; b=H4sIAAAAAAAC/22OQQ7CIBBFr9KwFqVgG+vKe5gugA4tasDMINE0v
 bulbl2+yZv//8wI0AOxczUzhOzJx7BCu6uYnXQYgfthZSaFbGuhBM+A0QERd0KeagNKdcayVX8
 iOP/eoq79j+llbmBT+S+G0QTcoA52KicLj0NwNPAElHwYizJ5ShE/25zclKg/zbnhgsujBNCy6
 2qnLnfAAI99xJH1y7J8ATFdR9LWAAAA
X-Change-ID: 20261030-verofess-f0281be339bc
To: VeroFess <coderzeng@gmail.com>, Chuck Lever <cel@kernel.org>, 
 Jeff Layton <jlayton@kernel.org>, NeilBrown <neil@brown.name>, 
 Olga Kornievskaia <okorniev@redhat.com>, Dai Ngo <Dai.Ngo@oracle.com>, 
 Tom Talpey <tom@talpey.com>
Cc: linux-nfs@vger.kernel.org
X-Mailer: b4 0.17-dev-9c833
X-Developer-Signature: v=1; a=openpgp-sha256; l=3880; i=cel@kernel.org;
 h=from:subject:message-id; bh=k7W5qUwLSGhMon7lLOkbdzysAQ3NgfHlKLbkC12Ah2A=;
 b=owEBbQKS/ZANAwAKATNqszNvZn+XAcsmYgBq51/wjyBzEvfhktmbqWygPSZ76Zw45rnHqceVU
 JBKzQn05d6JAjMEAAEKAB0WIQQosuWwEobfJDzyPv4zarMzb2Z/lwUCaudf8AAKCRAzarMzb2Z/
 lxt8D/9tRi3zgTHwraNULo5GZGXadyd24z5iFqm5Wdelo3Dld31ExLIuEJcgbUzr7H1oh29Qz5b
 1/rHxbN2vh8aa5e58OtZm4cdffwJktybgegCKNzJ183iWz4JTvdethGPg1XhdPJ2GNGcJUu5XQH
 ypwWK6hksEBqtw0DEoEZSLfPBQdJQRzRvVtb5Z1TkDy9Jk7q7LyOHzcwi8vZ2Ag57AeHPEVdaPt
 Oq62+Q7HFZyY00/+wyOV1NhSOvks2vyWPaDibuuJUYM1aZ7aL+h/YZAVaSQ26/Gy4tIsuEtrFyu
 9pqbXXA0VZWYzfQtn81pDhfDHgavGTX2PSUKO2PDIUchRhCuIFHW9SPVIq3465ufYO7nhIGZ7lh
 +vKdca5h7kDC3IivbkKB/aFKC/ZOWajQ0dgAlO5PBZ/Fmut1qFh15v4oKuL/PlN4jt25+gMNqYQ
 PyDLeBYRzTyJLULaEHE+zXsxXj31+ChZUP7Ce+gbt1WwY3iTg+08xaDUsmM04Htp9BD153es1Mc
 quqhZH2Apolc3OUUY77UAjsZQNjh6xHGAtWfxnby3VlFdAodJ1P9Q4NVn1uGECbNIGonpMmBD9V
 eOkGtblyQKsG6VoQRooYu1yeymHNCOCSsqPeiVi8ClVsT1VMBJ8Sez4vH1mREQ5n4x+fMvV6XDg
 WBcf8IXFFM7xU9g==
X-Developer-Key: i=cel@kernel.org; a=openpgp;
 fpr=28B2E5B01286DF243CF23EFE336AB3336F667F97

VeroFess reported that an AUTH_SYS NFSv4.0 client can read or write
a file on a sec=krb5p export with another client's OPEN stateid by
placing SAVEFH between PUTFH and the I/O operation. The v4 posting
carried that fix together with changes to COPY, LOOKUP, READDIR, and
SECINFO in one patch, which would not apply to the stable kernels
that need the fix. This series splits that patch. The
need_wrongsec_check() change stands alone (patch 1) and applies to
every LTS kernel, and the remaining patches carry only the Fixes:
tags that match their code. VeroFess developed the original fix with
the assistance of an LLM, and an LLM assisted with the split and the
commit messages in this series.

VeroFess confirmed on a kernel with only the need_wrongsec_check()
change that PUTFH; SAVEFH; READ and PUTFH; SAVEFH; WRITE return
NFS4ERR_WRONGSEC, and on a kernel with that change plus the COPY
source check that PUTFH; SAVEFH; PUTFH; COPY returns NFS4ERR_ACCESS.
The series as posted has not been run against the reproducer yet.
VeroFess has offered to do that.

After this series, NFSD still relies on per-operation
check_nfsd_access() calls to enforce a PUTFH check that was deferred.
A filehandle could instead carry a check-pending state that the
COMPOUND loop enforces before any operation consumes the filehandle.
Carrying such a state is later work.

Based on nfsd-testing.

---
Changes in v6:
- Verify the current filehandle in SECINFO_NO_NAME(CURRENT_FH) (sashiko).
- Note that PUTFH still returns WRONGSEC for a GSS or xprtsec= mismatch.
- Link to v5: https://patch.msgid.link/20261030-verofess-v5-0-242eea2991f3@kernel.org

Changes in v5:
- Split the single patch into three, each with its own Fixes: tags.
- Drop the nfs4_check_file() and COPY_NOTIFY export checks.
- Check the entered export in nfsd_cross_mnt() and nfsd_lookup_parent().
- Replace the for_secinfo flag with NFSD_MAY_SECINFO.
- Report a SECINFO transport policy mismatch as NFS4ERR_ACCESS.
- Keep the PUTFH export check for NFSv4.0 PUTFH; SECINFO.
- Link to v4: https://lore.kernel.org/r/20261029063917.138184-1-coderzeng@gmail.com

Changes in v4:
- Skip only the flavor check for SECINFO; xprtsec= stays enforced.
- Re-check xprtsec= when a SECINFO lookup selects another export.
- Link to v3: https://lore.kernel.org/r/20261029051430.96326-1-coderzeng@gmail.com

Changes in v3:
- Use nfsd_lookup_dentry() for SECINFO_NO_NAME(PARENT).
- Let SECINFO and SECINFO_NO_NAME(PARENT) query a strict starting export.
- Skip the source export's policy check on a SECINFO mount crossing.
- Link to v2: https://lore.kernel.org/r/20261029013648.12015-1-coderzeng@gmail.com

Changes in v2:
- Check cached stateid I/O and COPY_NOTIFY against the current export.
- Check the selected export after LOOKUP and READDIR mount crossing.
- Map READDIR's NFS4ERR_WRONGSEC to NFS4ERR_ACCESS without rdattr_error.
- Add the missing Fixes: tags and regenerate the whitespace-damaged diff.
- v1 was sent off-list.

---
VeroFess (3):
      NFSD: Fix PUTFH wrongsec check when SAVEFH follows
      NFSD: Check export security on the COPY and CLONE source
      NFSD: Enforce export security on LOOKUP, READDIR, and SECINFO

 fs/nfsd/export.c    |  6 ++--
 fs/nfsd/nfs3proc.c  |  2 +-
 fs/nfsd/nfs4proc.c  | 84 ++++++++++++++++++++++++++++++++++++++---------------
 fs/nfsd/nfs4state.c |  2 +-
 fs/nfsd/nfs4xdr.c   |  8 +++--
 fs/nfsd/nfsfh.c     | 12 ++++++--
 fs/nfsd/nfsproc.c   |  2 +-
 fs/nfsd/trace.h     |  3 +-
 fs/nfsd/vfs.c       | 72 +++++++++++++++++++++++++--------------------
 fs/nfsd/vfs.h       | 43 +++++++++++++++++++++++----
 10 files changed, 162 insertions(+), 72 deletions(-)
---
base-commit: d9130c9f6535392d423351ffb5521e7689cae6b6
change-id: 20261030-verofess-f0281be339bc

Best regards,
--  
Chuck Lever <cel@kernel.org>

