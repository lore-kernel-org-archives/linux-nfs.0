Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.remote-ip=100.103.45.18
ARC-Seal: i=1; d=subspace.kernel.org; s=arc20261015; a=rsa-sha256; cv=none;
	t=1793627896;
	b=PM3PPeIkTQT7KdMAdh22YiQgiF+95EN0poACKcN4di8tfPnnlFZguc8L/Tc8pWO57Tr/
	 PQKFhgWEQeakE7HE2yUiZJxEqShD7uQUq0Wh45zw2D2phT8leq6qMnY4wVLx9JZu+jUkz
	 esbDm48ltxmWqfWmyVrp20m2RKhqaLOOTPI47s6quXLuzGw2+r640vdNSgj9Yin44J8gP
	 S+x8juBHwOTofEX7hNkZcGYYjzlVwCYYjDY7+hK8R+gYTezQrnzqwm9pMSDM6NR2mQNNy
	 T85j3G+h3aC8q2758x45i09QK5oHKmn3ZR4vQgkx3MZkXxbwVYEtAvHjVDsQBGjYlUg==
ARC-Message-Signature: i=1; d=subspace.kernel.org; s=arc20261015;
	a=rsa-sha256; c=relaxed/relaxed; t=1793627896;
	h=Received:DKIM-Signature:From:Subject:Date:Message-Id:MIME-Version:
	 Content-Type:Content-Transfer-Encoding:X-B4-Tracking:X-Change-ID:To:
	 Cc:X-Mailer:X-Developer-Signature:X-Developer-Key;
	bh=0omTH9+qTBw/XxXTrr5tzQOOdwWG+3wHa1kpEmV0SEc=;
	b=NRf2yrnMvgR105917yhwpqlolWljVplXcUI3o7eCElD/coHjo6weTx/mJdrBkfAN2+Ff
	 avhjY+KjKdBcN5A6bGI7PNI7fhfWRa0P//o2gMhj9XFM349Kz1830qn+WligHAoHQkNp0
	 mM3Ho2fLIap5DFH4Xf4Kd0TbRsrOYk0VJcUrLuImD0eHLKE/2EhxbL+cy8Osxfxntu7V3
	 VThm4J5gw76M6FcI+JLzk7alsSAOvSXMe8sgHhQ8qMBnPtTglvobnQSBPVy1AWyKVQVMS
	 xpWJw0ImiZewmogHOIrXNHI8h520Fe4Pqzc7QsX8BGnMNNACGP2tXzuti7OxlvCqdYw==
ARC-Authentication-Results: i=1; smtp.subspace.kernel.org; 
	dkim=pass header.d=kernel.org header.i=@kernel.org header.a=rsa-sha256 header.s=k20260515 header.b=MvmvZjjR;
	arc=none smtp.remote-ip=100.103.45.18
Received: from smtp.kernel.org (quasi.space.kernel.org [100.103.45.18])
	(using TLSv1.3 with cipher TLS_AES_256_GCM_SHA384 (256/256 bits)
	 key-exchange X25519 server-signature ECDSA (prime256v1))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id A6BF2606A324
	for <linux-nfs@vger.kernel.org>; Mon,  2 Nov 2026 13:58:15 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key, unprotected) header.d=kernel.org header.i=@kernel.org header.a=rsa-sha256 header.s=k20260515 header.b=MvmvZjjR
Received: by smtp.kernel.org (Postfix) with ESMTPSA id 6B7EC1F00A16;
	Mon,  2 Nov 2026 13:58:14 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=kernel.org;
	s=k20260515; t=1793627895;
	bh=0omTH9+qTBw/XxXTrr5tzQOOdwWG+3wHa1kpEmV0SEc=;
	h=From:Subject:Date:To:Cc;
	b=MvmvZjjRndYKIws4cFiWtQaiMJl6L2sJtRT1LKtuolYi7EnJrqOHdKGfSFl0J4uqx
	 dgrKIW99l9OsQzD4BvALgQlYb1WNfxkF5IqgCPRd9J1nZbT7kMQ8YUDww1GQF2Ox/K
	 GxD+IvDmpBux7cYOePuhsHVPd23Qwe7Q3vVGrNU+R7TnpOoQO/5IrBXa6geJZYfTwe
	 jVSbG13JptSNGPd9+oGZ0iMyTxnDtIfOK9DRUB3R5La31CuJACNWAQeY0Sn9KTLjGj
	 cO3379bllRdOBOFtw8oqmfl4KhzkQZJs0WNpdvBt2YZdthV974RjP4oa0UJhT3u3Bn
	 O5vOCxVbVmEew==
From: Chuck Lever <cel@kernel.org>
Subject: [PATCH v7 0/5] NFSD: Enforce export security after a deferred
 PUTFH check
Date: Mon, 02 Nov 2026 08:58:00 -0500
Message-Id: <20261102-verofess-v7-0-d2cc0de4d44e@kernel.org>
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
X-B4-Tracking: v=1; b=H4sIAAAAAAAC/22Oyw7CIBBFf6VhLQr0Ja78D+OiwNCiDTVMJZqm/
 26pCzVxeSb33DsTQQgOkByyiQSIDt3gF6g3GdFd41ugzixMBBMVZzmjEcJgAZFaJvZcQZ5Lpck
 SvwWw7rFWnc5vxru6gB6TnxKqQaAqNF536aSh33mLho6Ao/NtinQOxyE813dimar+LMeSMioKA
 dAIKbnNj1cIHvrtEFqSpmP1MTnjX2a1mIWpGZO1UbX5Ned5fgFMXwd2EAEAAA==
X-Change-ID: 20261030-verofess-f0281be339bc
To: VeroFess <coderzeng@gmail.com>, Chuck Lever <cel@kernel.org>, 
 Jeff Layton <jlayton@kernel.org>, NeilBrown <neil@brown.name>, 
 Olga Kornievskaia <okorniev@redhat.com>, Dai Ngo <Dai.Ngo@oracle.com>, 
 Tom Talpey <tom@talpey.com>
Cc: linux-nfs@vger.kernel.org, sashiko-bot <sashiko-bot@kernel.org>
X-Mailer: b4 0.17-dev-9c833
X-Developer-Signature: v=1; a=openpgp-sha256; l=4614; i=cel@kernel.org;
 h=from:subject:message-id; bh=1HoYHYCXahpH2XFBeacDkyMDN8mTLikISGdrm97Heng=;
 b=owEBbQKS/ZANAwAKATNqszNvZn+XAcsmYgBq6JbtnTno7OxyqiTBsa0nkT479lGoVVBkKV70V
 yQT2vsDPRWJAjMEAAEKAB0WIQQosuWwEobfJDzyPv4zarMzb2Z/lwUCauiW7QAKCRAzarMzb2Z/
 l8EyD/9CnMTOdyqXNyaWi9krudd8Vs4DY93A0zkSd/SKil9yPSKf6beHzhSs6GlZfKS4Koya987
 FMjBMzGtgJ0VVlsmA/qd+d8Cd/Iea488GT3J/seSdqkMaRMb9w59tiUE9Lv2bhGHobMOLcR0Rsj
 lW4IF32eRes7SL0QjCHWmstzRCXWzX3y1WXEFaNLcRWB6tq5SchDIx9auBplYU2MQWxWPyUE/aq
 T9zeAUNRCnRtnwt609eY5g5yNyvezXbvtiqld2hwvStNT/Hawhsd5lwBa9g9pwg+hLIm7S1/WcO
 8OQkHi5nRxORHet5TlDPAxRAncL/c3IE4KlKGjGO0QxUx6T8VwhMzULzcGA9SlVsGrpkeGtJetW
 SvAroBNbroemenNIOVPaWyl5bIVL2aiBWl2rlTz6PpGcJv+11FtiShg9EOsQIdi6ycfRkPBchjL
 9OVkzUeM56Iefi9sq9WkIUDONbkNhAD0TGrtkHoPOfseU6zFVYae1Uv+XUfVBK4kwlaobruPjNP
 6b+Xhcvy6NyCrSj+w7wcDs5yMs0cZLAQ5hX0e5TGWw1MmIWNqkFntyGSr7Yq6PD6Eg2yzlnxI7Q
 +QDhBihOJ7wcK1+fO4UHiOlgt3EScoso1BoscjlbyD7kv8wmTDtOoZtfEDGQdzF2bO5E65UMM0q
 yrpDH+wQMBRXNEg==
X-Developer-Key: i=cel@kernel.org; a=openpgp;
 fpr=28B2E5B01286DF243CF23EFE336AB3336F667F97

[ I was hoping v6 would be final, but v7 is needed to address
  some reasonable agentic review findings. ]

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

VeroFess tested v5 incrementally against the reproducer in a KASAN
guest, with an RPC-over-TLS run of the full series, and the first
three patches carry a Tested-by. The SECINFO and PUTFH patches
changed in v7 and have not been run against a krb5 or TLS client.

After this series, PUTFH checks the export's transport policy but not
its security flavor, for any RPC flavor. need_wrongsec_check() reports
NFS4ERR_WRONGSEC from PUTFH when the next operation uses the current
filehandle, and LOOKUP, LOOKUPP, OPEN, and SECINFO verify the
filehandle themselves. A sec=sys client reading a pseudo-root that
has a sec=krb5p child now receives rdattr_error for that entry
instead of the child's attributes.

---
Changes in v7:
- Skip the PUTFH flavor check for every flavor (sashiko).
- Split the mount-crossing fix out of the SECINFO patch.
- Carry only Fixes: f0d6ad5a2f67 on the mount-crossing patch.
- Cite RFC 8881 Section 18.29.4 for READDIR's rdattr_error.
- Rename NFSD_MAY_SECINFO to NFSD_MAY_BYPASS_FLAVOR.
- Drop the PUTFH limitation paragraph from the SECINFO description.
- Link to v6: https://patch.msgid.link/20261101-verofess-v6-0-4d70097db7d3@kernel.org

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
Chuck Lever (1):
      NFSD: Defer the PUTFH export security flavor check

VeroFess (4):
      NFSD: Fix PUTFH wrongsec check when SAVEFH follows
      NFSD: Check export security on the COPY and CLONE source
      NFSD: Check the entered export on a mount crossing
      NFSD: Let SECINFO query an export that excludes the request's flavor

 fs/nfsd/export.c    |  6 ++--
 fs/nfsd/nfs3proc.c  |  2 +-
 fs/nfsd/nfs4proc.c  | 87 ++++++++++++++++++++++++++++++++++++++---------------
 fs/nfsd/nfs4state.c |  2 +-
 fs/nfsd/nfs4xdr.c   |  8 +++--
 fs/nfsd/nfsfh.c     |  9 ++++--
 fs/nfsd/nfsproc.c   |  2 +-
 fs/nfsd/trace.h     |  3 +-
 fs/nfsd/vfs.c       | 72 +++++++++++++++++++++++++-------------------
 fs/nfsd/vfs.h       | 43 ++++++++++++++++++++++----
 10 files changed, 161 insertions(+), 73 deletions(-)
---
base-commit: d9130c9f6535392d423351ffb5521e7689cae6b6
change-id: 20261030-verofess-f0281be339bc

Best regards,
--  
Chuck Lever <cel@kernel.org>

