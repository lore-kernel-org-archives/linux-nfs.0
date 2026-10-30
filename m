Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.remote-ip=100.103.45.18
ARC-Seal: i=1; d=subspace.kernel.org; s=arc20261015; a=rsa-sha256; cv=none;
	t=1793395668;
	b=iC+z4HHl0QOJ01hGP9j2Y5Hsrn8SHiW+LkC4gpPSAcsJZqKB786xOtbu2pd0g0dlqrQv
	 VGjXiNC+Y0tG6j1s5S2hzvucWkvQwLyD0ne2+oN/bXh36lIKg8Vx/zmRU6QboFq/DbdiO
	 wNSxvyeDNMzbgY/PrF8Dwf67f0np/rYoUK5brWAbRbMfcsvCzknZqDzLEXzV1eiERez3u
	 UwhUeFG3HOBlVB8YeuD0gFLhGQ/xxfN+qiXlJo25zSPMr65QJzGZhdvC5c1OuhMQFNeZX
	 xRymN9U6UEkqM+RIvEmxKNZTN5OyioTlx1RYm9fiif1muLyRtfqVQpg36IsClZhctvA==
ARC-Message-Signature: i=1; d=subspace.kernel.org; s=arc20261015;
	a=rsa-sha256; c=relaxed/relaxed; t=1793395668;
	h=Received:DKIM-Signature:From:Subject:Date:Message-Id:MIME-Version:
	 Content-Type:Content-Transfer-Encoding:X-B4-Tracking:X-Change-ID:To:
	 Cc:X-Mailer:X-Developer-Signature:X-Developer-Key;
	bh=jrXwnUw6tTuINTOdFLUYswDWEXstnj2zCyJ3r3e830M=;
	b=KPqZ/hFnO0Meso2jgmvdmPHw0L01xMXHE9HWh2ld78i7IaL+9IJWAW9EUPOWOD8/oqRF
	 d2UEgpCkH7loFNTHIFni6eXK3+23F/5UGNvAJQQYOGbxeKH2Tls1BrRAHw/UyiXXXI5ol
	 CuOZp2HiS4nqi7s+uk+i4wC2gaJkE1VJOFidGi43Vqs6HYJeUjZzI/d9G8nOo2W6JGRNF
	 mJa3yppvI4CBLUnHI1SEudRtWjsLbAbX1pR6OdwSwnt+Iw88D0cf3Ja+IxbGd9T4vSLTd
	 g0jXqqGjNfNAv9uq4bOd4oG2bs4MqWQgyE0rwocfGYDU0n/s/CG4rz2hUXH9baksj3g==
ARC-Authentication-Results: i=1; smtp.subspace.kernel.org; 
	dkim=pass header.d=kernel.org header.i=@kernel.org header.a=rsa-sha256 header.s=k20260515 header.b=F2xVr44g;
	arc=none smtp.remote-ip=100.103.45.18
Received: from smtp.kernel.org (quasi.space.kernel.org [100.103.45.18])
	(using TLSv1.3 with cipher TLS_AES_256_GCM_SHA384 (256/256 bits)
	 key-exchange X25519 server-signature ECDSA (prime256v1))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 51C3060A260C
	for <linux-nfs@vger.kernel.org>; Fri, 30 Oct 2026 21:27:48 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key, unprotected) header.d=kernel.org header.i=@kernel.org header.a=rsa-sha256 header.s=k20260515 header.b=F2xVr44g
Received: by smtp.kernel.org (Postfix) with ESMTPSA id 392B41F000C1;
	Fri, 30 Oct 2026 21:27:47 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=kernel.org;
	s=k20260515; t=1793395668;
	bh=jrXwnUw6tTuINTOdFLUYswDWEXstnj2zCyJ3r3e830M=;
	h=From:Subject:Date:To:Cc;
	b=F2xVr44gsWfTMBguL01/9eb1h1HXYgfgxi4CF+GLDfpVYnMoFjaFC9MVEHB/7QFlb
	 4DkW/WAbDC3z2ZHt+cxGDqssDVVNas7n4y/Ew+NugOVvYSaui21bfdH4xe7NFoL9dt
	 FDlmJ31tstH/8OHSNZDjZWflLGYRf2pXdrof3pdV8tX9Ay8GRLkZ7negJ5Cu4t9P30
	 pCQaHQLr3jcTlorINGDUN0TrMsKtkSG7UggqOVQMMR2rpVCeaKT5oJA31N+oKHjhUF
	 KFIL29lHhAefWM4W5VN22NUAA2f8JgSMfYT1BvYn6Bo1I97r/NPTLiJy6Qa4R8reKH
	 yMvWtVAhsZWlg==
From: Chuck Lever <cel@kernel.org>
Subject: [PATCH v5 0/3] NFSD: Enforce export security after a deferred
 PUTFH check
Date: Fri, 30 Oct 2026 17:27:34 -0400
Message-Id: <20261030-verofess-v5-0-242eea2991f3@kernel.org>
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
X-B4-Tracking: v=1; b=H4sIAAAAAAAC/yWMQQrCMBREr1L+2mCaoKhXkS6SdNJ+kVTyYxFK7
 26iyze8NxsJMkPo1m2UsbLwkiqcDh2F2aUJisfKZLQ599pqtSIvESIqanPpPay9+kBVf2VE/vy
 u7sOf5e0fCKX1zfBOoHx2KcxtCngeU5RRFUjhNNG+fwHHrU7ejwAAAA==
X-Change-ID: 20261030-verofess-f0281be339bc
To: VeroFess <coderzeng@gmail.com>, Chuck Lever <cel@kernel.org>, 
 Jeff Layton <jlayton@kernel.org>, NeilBrown <neil@brown.name>, 
 Olga Kornievskaia <okorniev@redhat.com>, Dai Ngo <Dai.Ngo@oracle.com>, 
 Tom Talpey <tom@talpey.com>
Cc: linux-nfs@vger.kernel.org
X-Mailer: b4 0.17-dev-9c833
X-Developer-Signature: v=1; a=openpgp-sha256; l=3607; i=cel@kernel.org;
 h=from:subject:message-id; bh=mGOttYmJqQ5d/onpnvFTFUSjgfw9P61WN18d9L/fI6s=;
 b=owEBbQKS/ZANAwAKATNqszNvZn+XAcsmYgBq5QvK4jGtVw5FdXxqcz0PrYa7BZggTZ+4HVx2P
 PEjldBlDYWJAjMEAAEKAB0WIQQosuWwEobfJDzyPv4zarMzb2Z/lwUCauULygAKCRAzarMzb2Z/
 l0WlEACCVtQAnMNCrxc7XheAduUClUpni7jELiw3UGhb592p47u1SOik5ipJFg/tf0qPzKH8MuJ
 etdpgMwBdrGIj0+8FWy661jpOsNyxVPvHRPK+XybQnWqMedxr4TpZB5LFQHLUX2QP1UJW7FjGFJ
 WoQNrbnkRPhhYJZgXU//o45JWG5/h672OVcuX/0/Rtwn4MTGS/guYnGqeY+GRMID7rO5Jw3cO/I
 weOVfiSefr8v0gwTtHDFEQDSvqu4qzflglss6T5HMRlTOndyFavdN1lexnw9q2XoGzFHB0xfJrg
 yAzj+cLqY/NnoG5pP2P8t50GOLubdMzmnEQuoOpHPLQMvkA+JmoxP5D2LaIMDF3aUStqcBxrIZk
 qOy8W+hN5HcAftb/VCB8o6UYpdDcRGLqkQhN6QIhp3/AoM82i4AlsX1PGjmE6N4w5HC8+2IWCh6
 7VqbNHpN5MfTH/JoZgtBAnatSeqTMoRcFSuGzNZo40giFCjL5lDxAe4/fJbA12aY5fZhUJbMWCe
 qK1NdDes2WVGL+cuKV83Lkpgpybmqmc2JKk3qx5Th5smpycFjHTDts/0CawAc8P8ayumYSNUqyL
 5GIbOysSG99vrI3ykdIn0yHOmS5tEVmRu5RNS3fMuWFtGnSJ22VJscI6nTxCsFZjKWQNB7Alcv6
 2S2MeBpiRR+9cPQ==
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
 fs/nfsd/nfs4proc.c  | 80 +++++++++++++++++++++++++++++++++++++----------------
 fs/nfsd/nfs4state.c |  2 +-
 fs/nfsd/nfs4xdr.c   |  8 ++++--
 fs/nfsd/nfsfh.c     | 12 ++++++--
 fs/nfsd/nfsproc.c   |  2 +-
 fs/nfsd/trace.h     |  3 +-
 fs/nfsd/vfs.c       | 60 ++++++++++++++++++++++++++--------------
 fs/nfsd/vfs.h       | 17 +++++++++---
 10 files changed, 132 insertions(+), 60 deletions(-)
---
base-commit: d9130c9f6535392d423351ffb5521e7689cae6b6
change-id: 20261030-verofess-f0281be339bc

Best regards,
--  
Chuck Lever <cel@kernel.org>

