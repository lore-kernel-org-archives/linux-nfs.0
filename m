Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.remote-ip=209.85.218.46
ARC-Seal: i=1; d=subspace.kernel.org; s=arc20261015; a=rsa-sha256; cv=none;
	t=1793255987;
	b=YR2E6SLBkn38lBFnnZlSF6a0z7hikijXUI9GMhNnY78zn4R8pVp97QcAY4MxUbD+5Yqp
	 lGpcO7LwCoQ6l/9F7hiUlqnllBCdA+RlG9bb2AHrHx73jfLdn/3CMaTTI2OmC0U3+Zhq6
	 zfBkZ/sv9B+Gy5okSQGrzj/HaCSpKKMUG/vcNecRSpGIReQhrcCtippI5LyyXp88jZlOJ
	 HqiBZ+/ryXGcqRXFwk3MlBisfQ3IN7uiXxBO+4oRuXRqdcoLnFPDVTwJGageD1VtwYBhb
	 7YQPwhtVSUY4DaqdErVkdCfbXtKOfzEbDjAzeIulXhUH2NLyPh2SJ4cr16AX7ga3+dA==
ARC-Message-Signature: i=1; d=subspace.kernel.org; s=arc20261015;
	a=rsa-sha256; c=relaxed/relaxed; t=1793255987;
	h=DMARC-Filter:Received:DKIM-Signature:X-Google-DKIM-Signature:
	 X-Gm-Message-State:X-Gm-Gg:X-Received:Received:From:To:Cc:Subject:
	 Date:Message-ID:X-Mailer:In-Reply-To:References:MIME-Version:
	 Content-Transfer-Encoding;
	bh=N0dM/TOkco5YL18nim0RnIz/lAqfOrL79pLGi5IcLr4=;
	b=0h8Zt5RIJRdOS37cFTZZe9nSYAzzUQAKM+9osx/xLbY91jv9Ei6KK2cFMQn6liAg6fj6
	 1qkaCAW6ffXDdlw/VuM29rKaABxQ/3Ch1fbQisknZViEcESNn20kxv1f9eDqCH1ExHFPJ
	 KPraYrtUoyfMhQGITZunJv9jrkPpsX0MghnFSrfyNATKp/toc+hV+2UEmgkj/Ro+kUXK+
	 hXcDBk0a6wp2jGOUvdT3WrsRpoGidpIT0Aj5S5rGfF8GhQXE3HwTR2KfOIcT+x7XvAiCb
	 lx09QIS5A0uN1czns0Zd8svbn7ProXCNnNswe2DkPjQPsYD9iGen3RhK4V92ljtuGlw==
ARC-Authentication-Results: i=1; smtp.subspace.kernel.org; 
	dmarc=pass header.from=gmail.com;
	spf=pass smtp.mailfrom=gmail.com;
	dkim=pass header.d=gmail.com header.i=@gmail.com header.a=rsa-sha256 header.s=20260707 header.b=c6oi6iRb;
	arc=none smtp.remote-ip=209.85.218.46
Received: from mail-ej1-f46.google.com (mail-ej1-f46.google.com [209.85.218.46])
	(using TLSv1.3 with cipher TLS_AES_128_GCM_SHA256 (128/128 bits)
	 key-exchange X25519 server-signature ECDSA (prime256v1) server-digest SHA256)
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 92A7A606A31A
	for <linux-nfs@vger.kernel.org>; Thu, 29 Oct 2026 06:39:46 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.4.2 smtp.subspace.kernel.org 92A7A606A31A
Authentication-Results: smtp.subspace.kernel.org; dmarc=pass (p=none dis=none) header.from=gmail.com
Authentication-Results: smtp.subspace.kernel.org; spf=pass smtp.mailfrom=gmail.com
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key, unprotected) header.d=gmail.com header.i=@gmail.com header.a=rsa-sha256 header.s=20260707 header.b=c6oi6iRb
Received: by mail-ej1-f46.google.com with SMTP id a640c23a62f3a-c418e215671so225607666b.0
        for <linux-nfs@vger.kernel.org>; Wed, 28 Oct 2026 23:39:46 -0700 (PDT)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=gmail.com; s=20260707; t=1793255985; x=1793860785; darn=vger.kernel.org;
        h=content-transfer-encoding:mime-version:references:in-reply-to
         :message-id:date:subject:cc:to:from:from:to:cc:subject:date
         :message-id:reply-to:content-type;
        bh=N0dM/TOkco5YL18nim0RnIz/lAqfOrL79pLGi5IcLr4=;
        b=c6oi6iRbD/iAiqdF61LSL+6UEs/Sxp8htXYF/lxKDZp9dnh5riyod2b1Ql2EEJgqtS
         CNMYCFnlIWJb+xpzkjT87vwBkWMUTgj+5eD1MznLTjgLLo7fHuJk0CyF1rPv+F0arPk9
         FtM73BIg01PUZDxtRQsfC3AqpktHgaBSX+3b/uOG1WRUMge6S52nFUePAd/g/N2D7s+/
         mD9ExTZeGJiWuFua44PR6753Nro3fIsupbWuOr8BtwLTnpwqFAz9WBUifWPrYDcIhZ/d
         W6LRKC06r3gKHCo9Q1VZzW2o0eC3zYCZo/20wLONx13qzA2LJrCefzksUGmXbM+0vmru
         ixeA==
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20260707; t=1793255985; x=1793860785;
        h=content-transfer-encoding:mime-version:references:in-reply-to
         :message-id:date:subject:cc:to:from:x-gm-gg:x-gm-message-state:from
         :to:cc:subject:date:message-id:reply-to:content-type;
        bh=N0dM/TOkco5YL18nim0RnIz/lAqfOrL79pLGi5IcLr4=;
        b=x6ui9LMsW9zWKzHsEWlKYx2M6HhVioQhUQ5Qh2RpjL1tsfwDu4moNQ1FL4lFx64Jxi
         euOtt09g/ORHF3cRNpoWRcfFOVvyW9WRvHPQb959atVl01IbH1I8nYJCN6iY32OePr9G
         ubNUJ7CzASSc0X3tLwOuCTXfmC7J7rPe7ocPAj7kQnI9Cs/uWI9Msb+L8DgYAp8xS8AH
         7H30+ceE4qxEq2TWxpWJxG37Mm3zJxg34Vi3EwCiU9xq2Bbn12YS/f12bZ15AImIaZLv
         I2ZzUBNBceX76MkGEK7uENjQc/3ptgJKch7E0GWPUwCMCfUcy3G2/dyLFvhnZ+jRTell
         //vw==
X-Gm-Message-State: AFq9FYIj8lh9xukO2r9Y4rC4V6Bu0ybWyN8ai6UyBFUrOA2e8pJ3kTkD
	XzhKyrwIB/O87Z9oDeUBFu68EXtDIRcKTq+NIKMQjdaCZ5cYvoD+OD4X
X-Gm-Gg: AYBFou2dk4P+lxkl+fQ8oDN9141cmo6iH3UDJ06SbiBq44d5wHR0fwbSFtOxDW9KKqz
	XhBJK+mWNiTCZ5NjK5mzGdlILOfUmXtA3JN1/of/HLhmndimLMklsqKJEUJWXMC95VceEi6l3w+
	wfRJhmBjBDp9jd0ZwfZCv57NTf1OD5Yk8c3t17N9l3F5OiB7GhAwkDG1zdXOhhir+c62dCzyqOk
	NaBru7zeOURv6NNjhcHXfx1eudhZEPDO3DnMADFDMBt0Sh+SHhgNIy+aiUZwYEV/3nNJHf7EwKC
	zdGhdLNoc46vjsL57sC7G1CcbAOftANkbiBsYMc1a7jLs4Q5MLihpFt5/Z/la+eaiFZkv6AKcOH
	Z5iDjPI47GRDMyoXdepj7P/QHwglYuoMZ+Mqq9XoPuuGfIcKyn7Gs7LfL0Q0JNeXeYhykL3LnJX
	eIc4TTr4yRJHDayIXG3oDxlGg07nrLi/FYPwCmzATlnnEJk4rTVg2Efj/M5gh1pgmKIQ/uiGm3w
	w5ErVN/PG267Ms/MekVuJS7Alhal/y+yy6mhsyq0VDBxJJjV9ItD4x5jNDyVBx8fiziUIOBRWau
	Hll4j2yir2OPmOAHtqhNt/ICrr2q3+uq89u9Agn6T+iU2RRdeSuJoZA2kVLxZXj0KUyg0BIE
X-Received: by 2002:a17:906:ef07:b0:c2d:bd87:7fa7 with SMTP id a640c23a62f3a-c49bded29f8mr378705866b.24.1793255984396;
        Wed, 28 Oct 2026 23:39:44 -0700 (PDT)
Received: from localhost.localdomain (173.242.112.181.16clouds.com. [173.242.112.181])
        by smtp.gmail.com with ESMTPSA id a640c23a62f3a-c4992141068sm474572266b.60.2026.10.28.23.39.41
        (version=TLS1_3 cipher=TLS_AES_256_GCM_SHA384 bits=256/256);
        Wed, 28 Oct 2026 23:39:43 -0700 (PDT)
From: VeroFess <coderzeng@gmail.com>
To: cel@kernel.org,
	jlayton@kernel.org,
	neil@brown.name,
	okorniev@redhat.com,
	Dai.Ngo@oracle.com,
	tom@talpey.com
Cc: linux-nfs@vger.kernel.org
Subject: [PATCH v4] nfsd: enforce export security for NFSv4 filehandles and stateids
Date: Thu, 29 Oct 2026 14:39:16 +0800
Message-ID: <20261029063917.138184-1-coderzeng@gmail.com>
X-Mailer: git-send-email 2.43.0
In-Reply-To: <20261029051430.96326-1-coderzeng@gmail.com>
References: <20261029051430.96326-1-coderzeng@gmail.com>
X-Mailing-List: linux-nfs@vger.kernel.org
List-Id: <linux-nfs.vger.kernel.org>
List-Post: <mailto:linux-nfs@vger.kernel.org>
List-Help: <mailto:linux-nfs+help@vger.kernel.org>
List-Subscribe: <mailto:linux-nfs+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:linux-nfs+unsubscribe@vger.kernel.org>
List-Owner: <mailto:linux-nfs+owner@vger.kernel.org>
Precedence: list
MIME-Version: 1.0
Content-Transfer-Encoding: 8bit

An AUTH_SYS NFSv4.0 client can read or write a file on a sec=krb5p
export using another client's valid OPEN stateid by inserting
SAVEFH between PUTFH and READ or WRITE.

PUTFH resolves the handle with NFSD_MAY_BYPASS_GSS, expecting
a later security check. SAVEFH carries OP_HANDLES_WRONGSEC even though
it only saves the handle, so PUTFH skips NFS4ERR_WRONGSEC. Stateid I/O
can then reuse a cached nfsd_file.

The original report used these export options:

  rw,sync,no_subtree_check,fsid=0,sec=krb5p,secure,root_squash

A Kerberos privacy NFSv4.0 client held an OPEN stateid on that export.
With the same stateid, an AUTH_SYS request was rejected by PUTFH, READ,
but SAVEFH between those operations allowed READ and WRITE. The Kerberos
client subsequently read the changed contents.

SAVEFH leaves CURRENT_FH in place. When deciding whether PUTFH must
report NFS4ERR_WRONGSEC, look past SAVEFH to the first operation that
uses or replaces CURRENT_FH. If another PUTFH replaces it, leave the
earlier PUTFH unchecked, as required by RFC 8881 Section 2.6.3.1.1.

Local COPY and CLONE consume SAVED_FH as the source. Check the
saved export with check_nfsd_access() before using its stateid:
a cached open stateid can otherwise bypass the sec= policy. Map
NFS4ERR_WRONGSEC to NFS4ERR_ACCESS at COPY or CLONE, since neither
operation permits NFS4ERR_WRONGSEC.

An inter-server COPY carries a foreign SAVED_FH. The source server
validates it; the destination must not apply its own export policy
to that handle. The destination PUTFH still checks its local export.

A bind-mounted regular file can have a stricter export than its parent.
LOOKUP crosses into that export, but nfsd_cross_mnt() checks the
parent export. Check the selected export in nfsd_lookup() before
composing a filehandle, and in READDIR before encoding child attributes.
When rdattr_error is not requested, return NFS4ERR_ACCESS for a flavor
mismatch; NFS4ERR_WRONGSEC is not a READDIR status. Keep the child-export
check out of nfsd_cross_mnt(): SECINFO uses it to discover the child's
supported security flavors.

SECINFO and SECINFO_NO_NAME report export security policies. RFC 8881
Section 2.6.3.1.1.5 forbids NFS4ERR_WRONGSEC from either operation.
SECINFO_NO_NAME(PARENT) needs to look up the parent without enforcing
the parent's policy; ordinary LOOKUPP still checks the selected export.

The starting directory's fh_verify(..., NFSD_MAY_EXEC) call also
rejects SECINFO and SECINFO_NO_NAME(PARENT) when that export does not
allow the request's flavor. When SECINFO crosses a mount, it can hit
another check on the source export.
The fsid=0 lookup uses the request's auth domains to find an export;
it does not itself enforce the export's sec= policy.

Pass NFSD_MAY_SECINFO to fh_verify() so it skips the starting export's
security flavor check. RFC 8881 section 2.6.3.1.1.5 forbids SECINFO
from returning NFS4ERR_WRONGSEC, so it must report the flavors even
when the caller's flavor is not one the export accepts. The export's
transport policy (xprtsec=) is a transport-layer requirement, not part
of the flavor negotiation SECINFO performs, so SECINFO does not bypass
it: fh_verify() still applies check_xprtsec_policy(). A SECINFO mount
crossing likewise skips only the crossed-into export's flavor check and
keeps its transport policy. The directory type, secure-port, transport,
and execute-permission checks still apply. Ordinary LOOKUP and LOOKUPP
continue to enforce export security.

The LOOKUP check controls whether a client obtains a new child handle.
It does not cover a handle and OPEN stateid retained while the export's
sec= policy changes. The cached nfsd_file branch of nfs4_check_file()
calls nfsd_permission() without checking the current export's flavor.
Check that export before reusing the file for stateid I/O.

COPY_NOTIFY validates a stateid without acquiring an nfsd_file, so it
misses that check. After an export was changed to sec=krb5p, an
AUTH_SYS COPY_NOTIFY using an existing stateid still issued a copy
stateid although AUTH_SYS READ was denied. In the test, a separate
user-space GSS client used that stateid to read the file. Check the
current export before issuing it and return NFS4ERR_ACCESS on a
flavor mismatch.

Fixes: 68d93184352f ("nfsd4: fix wrongsec handling for PUTFH + op cases")
Fixes: 624322f1adc5 ("NFSD add COPY_NOTIFY operation")
Fixes: f0d6ad5a2f67 ("nfsd: move check_nfsd_access() call into nfsd_cross_mnt()")
Fixes: 29a78a3ed7fc ("nfsd4: make fh_verify responsibility of nfsd_lookup_dentry caller")
Fixes: 04f4ad16b231 ("nfsd4: implement secinfo_no_name")
Assisted-by: LLM
Signed-off-by: VeroFess <coderzeng@gmail.com>
---
Changes since v3:
  Narrow the SECINFO exemption to the RPC security flavor check only.
  v3 also skipped the export's xprtsec= transport policy for SECINFO,
  which let a plaintext client run SECINFO against a TLS-only export.
  RFC 8881 only requires SECINFO to avoid NFS4ERR_WRONGSEC for the
  security flavor; the transport requirement is separate and remains
  enforced. __fh_verify() now skips only check_security_flavor() for
  SECINFO. Because a SECINFO lookup can cross a mount or step up to a
  parent, nfsd_lookup_dentry() re-checks check_xprtsec_policy() whenever
  it selects a different export object, so a SECINFO that crosses into a
  stricter transport is still denied while the already-verified starting
  export is not checked twice.

Changes since v2:
  SECINFO_NO_NAME(PARENT) uses the parent lookup path. The selected-export
  check added in v2 made it return NFS4ERR_WRONGSEC when the parent export
  rejected the RPC flavor. Use nfsd_lookup_dentry() for this query;
  leave nfsd_lookup() and its selected-export check in place for LOOKUPP.
  Also allow SECINFO and SECINFO_NO_NAME(PARENT) to query a strict
  starting export. SECINFO mount crossing skips the source export's
  policy check. Directory traversal permission remains enforced.

Changes since v1:
  Check cached stateid I/O and COPY_NOTIFY against the current export.
  Check the selected export after LOOKUP and READDIR mount crossing, and
  map READDIR's operation-level NFS4ERR_WRONGSEC to NFS4ERR_ACCESS when
  rdattr_error was not requested. Restore the RFC comments, drop a
  redundant assignment, and add the missing Fixes tags. Regenerate the
  diff after v1's whitespace damage.

Tests and review notes:
  SECINFO_NO_NAME(PARENT) was tested on v4.1 and v4.2 with a retained
  child-directory handle after the parent export's policy changed. It
  returned the parent's AUTH_SYS flavor before v2, NFS4ERR_WRONGSEC in
  v2, and the AUTH_SYS flavor in v3. With a strict starting export,
  AUTH_SYS SECINFO_NO_NAME(PARENT) also returned the parent's flavors.
  SECINFO returned the named file's or crossed-mount export's flavors
  on v4.0, v4.1 and v4.2. LOOKUP and LOOKUPP still returned
  NFS4ERR_WRONGSEC. Without directory execute permission, the queries
  returned NFS4ERR_ACCESS.

  SECINFO can distinguish existing from nonexistent names while
  negotiating security flavors. This is consistent with the protocol's
  security negotiation semantics.

  On v4 of this patch, a plaintext client querying an xprtsec=tls,
  sec=sys export had SECINFO rejected with NFS4ERR_WRONGSEC, matching
  GETATTR and LOOKUP; v3 had allowed that SECINFO. A plaintext SECINFO
  that crossed a mount into an xprtsec=tls child export was likewise
  rejected, while SECINFO of a non-TLS sibling and of a sec=krb5p
  export without xprtsec= still succeeded, so the flavor exemption is
  intact. An xprtsec=mtls export behaved the same for a plaintext
  client, both as the starting export and across a mount crossing. The
  TLS-session-without-peer-authentication case that distinguishes mtls
  from tls was not exercised at runtime; it uses the same
  check_xprtsec_policy() path. Tested on v4.0, v4.1 and v4.2.

  nfsd_lookup_dentry() has three callers; only nfsd4_secinfo() and the
  SECINFO_NO_NAME(PARENT) helper pass for_secinfo=true, and both run
  fh_verify() on the starting export first. svc_export objects are
  immutable once published (a policy change installs a new object and
  expires the old, which held references keep unchanged), so a filehandle
  reference gives a stable policy view for the request. The transport
  re-check keys on export-object identity (exp != fhp->fh_export): any
  switch re-authorizes the new object, and the unchanged starting object
  is not re-verified. Call counts observed with a kprobe on
  check_xprtsec_policy() were one for a non-crossing SECINFO and two for
  a crossing one (starting export plus crossed-into export), consistent
  with that design; the counts are evidence, not the correctness
  argument, which rests on the immutable-reference model above.

  The original SAVEFH READ/WRITE tests returned NFS4ERR_WRONGSEC at
  PUTFH. SAVEFH alone, a replacement PUTFH and
  SECINFO_NO_NAME(CURRENT_FH) remained allowed; RESTOREFH checked the
  restored handle.

  A regular-file export with stricter security than its parent was
  also tested. The v4.0 test used another client's stateid; v4.1 and
  v4.2 changed credentials within one session. The fixed LOOKUP
  returned NFS4ERR_WRONGSEC on all three versions. GSS LOOKUP,
  AUTH_SYS SECINFO, and access to a public sibling still succeeded.
  The Linux client uses SECINFO to retry LOOKUP with an allowed flavor
  after NFS4ERR_WRONGSEC. Cross-client stateids were not tested on
  v4.1 or v4.2.

  In earlier v3 tests, READDIR with rdattr_error reported the strict
  child's NFS4ERR_WRONGSEC per entry and kept the public entry; with
  size but no rdattr_error it returned NFS4ERR_ACCESS. Name-only
  READDIR succeeded on v4.0, v4.1 and v4.2. Before the fix, COPY into
  the strict child transferred 4096 bytes; the LOOKUP check now stops
  that destination from being selected under AUTH_SYS. CLONE reached
  ext4 but returned NFS4ERR_NOTSUPP, so no clone completed in that test.

  In an intermediate build without the LOOKUP check, nfs4_check_file()
  denied stateid READ/WRITE, READ_PLUS, SEEK, ALLOCATE,
  DEALLOCATE and COPY. GETATTR, ACCESS and OPEN already returned
  NFS4ERR_WRONGSEC. Source review found fh_verify() in SETATTR,
  READLINK, VERIFY/NVERIFY and xattrs; COMMIT acquires an nfsd_file.
  LINK/RENAME saved-handle probes returned NFS4ERR_WRONGSEC.

  Protected saved-source COPY/CLONE returned NFS4ERR_ACCESS; authorized
  local COPY/CLONE and a foreign-filehandle inter-server COPY completed.
  Local-only COPY with a foreign handle returned NFS4ERR_STALE.
  Before the COPY_NOTIFY fix, a policy change left AUTH_SYS READ denied
  while COPY_NOTIFY still issued a copy stateid usable by a GSS client.
  Stock NFSD-to-NFSD COPY from the strict source returned
  NFS4ERR_OFFLOAD_DENIED with zero bytes copied; the permissive-source
  control completed. The v2 guard denied a retained-handle COPY_NOTIFY
  before issuing a stateid. Source review and repeated denials found no
  notification allocation or retained stateid reference on that path.

  Earlier W=1 object builds and the revised x86_64 KASAN bzImage
  completed. The targeted guest logged no KASAN fault or NFSD warning.
  pNFS, other architectures and the full pynfs suite were not tested.

base-commit: bcd97658ca9be5a691eff14065a8f2dcfef6bbaf

 fs/nfsd/nfs4proc.c  | 80 +++++++++++++++++++++++++++++++++++----------
 fs/nfsd/nfs4state.c |  8 ++++-
 fs/nfsd/nfs4xdr.c   |  8 ++++-
 fs/nfsd/nfsfh.c     | 16 +++++++--
 fs/nfsd/trace.h     |  3 +-
 fs/nfsd/vfs.c       | 49 ++++++++++++++++++++++-----
 fs/nfsd/vfs.h       |  4 ++-
 7 files changed, 135 insertions(+), 33 deletions(-)

diff --git a/fs/nfsd/nfs4proc.c b/fs/nfsd/nfs4proc.c
index a50f9dcb3..d0eebd3cd 100644
--- a/fs/nfsd/nfs4proc.c
+++ b/fs/nfsd/nfs4proc.c
@@ -1079,7 +1079,31 @@ nfsd4_link(struct svc_rqst *rqstp, struct nfsd4_compound_state *cstate,
 	return status;
 }
 
-static __be32 nfsd4_do_lookupp(struct svc_rqst *rqstp, struct svc_fh *fh)
+/* SECINFO_NO_NAME(PARENT) must be able to report the parent's flavors. */
+static __be32
+nfsd4_secinfo_lookupp(struct svc_rqst *rqstp, struct svc_fh *fh)
+{
+	struct svc_export *exp;
+	struct dentry *dentry;
+	__be32 status;
+
+	status = fh_verify(rqstp, fh, S_IFDIR,
+			   NFSD_MAY_EXEC | NFSD_MAY_SECINFO);
+	if (status)
+		return status;
+	status = nfsd_lookup_dentry(rqstp, fh, "..", 2, &exp, &dentry, true);
+	if (status)
+		return status;
+	status = fh_compose(fh, exp, dentry, fh);
+	if (!status && d_really_is_negative(dentry))
+		status = nfserr_noent;
+	dput(dentry);
+	exp_put(exp);
+	return status;
+}
+
+static __be32 nfsd4_do_lookupp(struct svc_rqst *rqstp, struct svc_fh *fh,
+			       bool for_secinfo)
 {
 	struct svc_fh tmp_fh;
 	__be32 ret;
@@ -1093,6 +1117,8 @@ static __be32 nfsd4_do_lookupp(struct svc_rqst *rqstp, struct svc_fh *fh)
 		return nfserr_noent;
 	}
 	fh_put(&tmp_fh);
+	if (for_secinfo)
+		return nfsd4_secinfo_lookupp(rqstp, fh);
 	return nfsd_lookup(rqstp, fh, "..", 2, fh);
 }
 
@@ -1100,7 +1126,7 @@ static __be32
 nfsd4_lookupp(struct svc_rqst *rqstp, struct nfsd4_compound_state *cstate,
 	      union nfsd4_op_u *u)
 {
-	return nfsd4_do_lookupp(rqstp, &cstate->current_fh);
+	return nfsd4_do_lookupp(rqstp, &cstate->current_fh, false);
 }
 
 static __be32
@@ -1252,12 +1278,13 @@ nfsd4_secinfo(struct svc_rqst *rqstp, struct nfsd4_compound_state *cstate,
 	struct dentry *dentry;
 	__be32 err;
 
-	err = fh_verify(rqstp, &cstate->current_fh, S_IFDIR, NFSD_MAY_EXEC);
+	err = fh_verify(rqstp, &cstate->current_fh, S_IFDIR,
+			NFSD_MAY_EXEC | NFSD_MAY_SECINFO);
 	if (err)
 		return err;
 	err = nfsd_lookup_dentry(rqstp, &cstate->current_fh,
 				    secinfo->si_name, secinfo->si_namelen,
-				    &exp, &dentry);
+				    &exp, &dentry, true);
 	if (err)
 		return err;
 	if (d_really_is_negative(dentry)) {
@@ -1282,7 +1309,7 @@ nfsd4_secinfo_no_name(struct svc_rqst *rqstp, struct nfsd4_compound_state *cstat
 	case NFS4_SECINFO_STYLE4_CURRENT_FH:
 		break;
 	case NFS4_SECINFO_STYLE4_PARENT:
-		err = nfsd4_do_lookupp(rqstp, &cstate->current_fh);
+		err = nfsd4_do_lookupp(rqstp, &cstate->current_fh, true);
 		if (err)
 			return err;
 		break;
@@ -1491,6 +1518,11 @@ nfsd4_verify_copy(struct svc_rqst *rqstp, struct nfsd4_compound_state *cstate,
 	if (!cstate->save_fh.fh_dentry)
 		return nfserr_nofilehandle;
 
+	/* A cached open stateid does not authorize the saved source export. */
+	status = check_nfsd_access(cstate->save_fh.fh_export, rqstp);
+	if (status)
+		return nfserr_acces;
+
 	status = nfs4_preprocess_stateid_op(rqstp, cstate, &cstate->save_fh,
 					    src_stateid, RD_STATE, src, NULL);
 	if (status)
@@ -2532,6 +2564,12 @@ nfsd4_copy_notify(struct svc_rqst *rqstp, struct nfsd4_compound_state *cstate,
 	if (!stid)
 		return nfserr_bad_stateid;
 
+	status = check_nfsd_access(cstate->current_fh.fh_export, rqstp);
+	if (status) {
+		status = nfserr_acces;
+		goto out;
+	}
+
 	cn->cpn_lease_time.tv_sec = nn->nfsd4_lease;
 	cn->cpn_lease_time.tv_nsec = 0;
 
@@ -3237,32 +3275,38 @@ static bool need_wrongsec_check(struct svc_rqst *rqstp)
 	struct nfsd4_compoundres *resp = rqstp->rq_resp;
 	struct nfsd4_compoundargs *argp = rqstp->rq_argp;
 	struct nfsd4_op *this = &argp->ops[resp->opcnt - 1];
-	struct nfsd4_op *next = &argp->ops[resp->opcnt];
+	struct nfsd4_op *next;
 	const struct nfsd4_operation *thisd = OPDESC(this);
 	const struct nfsd4_operation *nextd;
+	unsigned int i;
 
-	/*
-	 * Most ops check wronsec on our own; only the putfh-like ops
-	 * have special rules.
-	 */
+	/* Only put-filehandle operations need a deferred WRONGSEC check. */
 	if (!(thisd->op_flags & OP_IS_PUTFH_LIKE))
 		return false;
+
 	/*
-	 * rfc 5661 2.6.3.1.1.6: don't bother erroring out a
-	 * put-filehandle operation if we're not going to use the
-	 * result:
+	 * RFC 8881 2.6.3.1.1.1: ignore SAVEFH when choosing the operation
+	 * that determines whether the put-filehandle operation checks WRONGSEC.
 	 */
-	if (argp->opcnt == resp->opcnt)
+	for (i = resp->opcnt; i < argp->opcnt; i++) {
+		next = &argp->ops[i];
+		if (next->opnum != OP_SAVEFH)
+			break;
+	}
+
+	/* RFC 8881 2.6.3.1.1.6: the filehandle is not used. */
+	if (i == argp->opcnt)
 		return false;
+
 	if (next->opnum == OP_ILLEGAL)
 		return false;
 	nextd = OPDESC(next);
 	/*
-	 * Rest of 2.6.3.1.1: certain operations will return WRONGSEC
-	 * errors themselves as necessary; others should check for them
-	 * now:
+	 * RFC 8881 2.6.3.1.1.2: a later put-filehandle operation replaces
+	 * this one. Other marked operations check WRONGSEC themselves.
 	 */
-	return !(nextd->op_flags & OP_HANDLES_WRONGSEC);
+	return !(nextd->op_flags &
+		  (OP_HANDLES_WRONGSEC | OP_IS_PUTFH_LIKE));
 }
 
 #ifdef CONFIG_NFSD_V4_2_INTER_SSC
diff --git a/fs/nfsd/nfs4state.c b/fs/nfsd/nfs4state.c
index f2b52ba90..3a12aeb56 100644
--- a/fs/nfsd/nfs4state.c
+++ b/fs/nfsd/nfs4state.c
@@ -6967,7 +6967,7 @@ nfsd4_verify_deleg_dentry(struct nfsd4_open *open, struct nfs4_file *fp,
 
 	err = nfsd_lookup_dentry(open->op_rqstp, parent,
 				 open->op_fname, open->op_fnamelen,
-				 &exp, &child);
+				 &exp, &child, false);
 
 	if (err)
 		return -ESTALE;
@@ -8486,6 +8486,12 @@ nfs4_check_file(struct svc_rqst *rqstp, struct svc_fh *fhp, struct nfs4_stid *s,
 
 	nf = nfs4_find_file(s, flags);
 	if (nf) {
+		/* A cached file still needs the current export security check. */
+		status = check_nfsd_access(fhp->fh_export, rqstp);
+		if (status) {
+			nfsd_file_put(nf);
+			return nfserr_acces;
+		}
 		status = nfsd_permission(&rqstp->rq_cred,
 					 fhp->fh_export, fhp->fh_dentry,
 				acc | NFSD_MAY_OWNER_OVERRIDE);
diff --git a/fs/nfsd/nfs4xdr.c b/fs/nfsd/nfs4xdr.c
index 4d9834446..daf2ad77d 100644
--- a/fs/nfsd/nfs4xdr.c
+++ b/fs/nfsd/nfs4xdr.c
@@ -4677,6 +4677,9 @@ nfsd4_encode_entry4_fattr(struct nfsd4_readdir *cd, const char *name,
 		 * At least, add a comment here to explain....
 		 */
 		nfserr = nfsd_cross_mnt(cd->rd_rqstp, &dentry, &exp);
+		if (nfserr)
+			goto out_put;
+		nfserr = check_nfsd_access(exp, cd->rd_rqstp);
 		if (nfserr)
 			goto out_put;
 		crossed = true;
@@ -4775,8 +4778,11 @@ nfsd4_encode_entry4(void *ccdv, const char *name, int namlen,
 		 * then in accordance with the spec, we fail the
 		 * entire READDIR operation(!)
 		 */
-		if (!(cd->rd_bmval[0] & FATTR4_WORD0_RDATTR_ERROR))
+		if (!(cd->rd_bmval[0] & FATTR4_WORD0_RDATTR_ERROR)) {
+			if (nfserr == nfserr_wrongsec)
+				nfserr = nfserr_acces;
 			goto fail;
+		}
 		if (nfsd4_encode_entry4_rdattr_error(xdr, nfserr)) {
 			nfserr = nfserr_toosmall;
 			goto fail;
diff --git a/fs/nfsd/nfsfh.c b/fs/nfsd/nfsfh.c
index f1ba5a14b..901948f0b 100644
--- a/fs/nfsd/nfsfh.c
+++ b/fs/nfsd/nfsfh.c
@@ -471,9 +471,19 @@ __fh_verify(struct svc_rqst *rqstp,
 			&& exp->ex_path.dentry == dentry)
 		may_bypass_gss = true;
 
-	error = check_security_flavor(exp, rqstp, may_bypass_gss);
-	if (error)
-		goto out;
+	/*
+	 * SECINFO reports an export's RPC security flavors, and RFC 8881
+	 * section 2.6.3.1.1.5 forbids it from returning NFS4ERR_WRONGSEC, so
+	 * it must succeed even when the caller's flavor is not one the export
+	 * accepts.  Skip only the flavor check for SECINFO.  The export's
+	 * xprtsec= policy constrains the transport security mode and stays
+	 * enforced above, independently of the RPC flavor negotiation.
+	 */
+	if (!(access & NFSD_MAY_SECINFO)) {
+		error = check_security_flavor(exp, rqstp, may_bypass_gss);
+		if (error)
+			goto out;
+	}
 
 	svc_xprt_set_valid(rqstp->rq_xprt);
 
diff --git a/fs/nfsd/trace.h b/fs/nfsd/trace.h
index 951af645d..a7d9f9d7b 100644
--- a/fs/nfsd/trace.h
+++ b/fs/nfsd/trace.h
@@ -142,7 +142,8 @@ DEFINE_NFSD_DYNTHREAD_EVENT(trylock_fail);
 		{ NFSD_MAY_BYPASS_GSS,		"BYPASS_GSS" },		\
 		{ NFSD_MAY_READ_IF_EXEC,	"READ_IF_EXEC" },	\
 		{ NFSD_MAY_64BIT_COOKIE,	"64BIT_COOKIE" },	\
-		{ NFSD_MAY_LOCALIO,		"LOCALIO" })
+		{ NFSD_MAY_LOCALIO,		"LOCALIO" },	\
+		{ NFSD_MAY_SECINFO,		"SECINFO" })
 
 TRACE_EVENT(nfsd_compound,
 	TP_PROTO(
diff --git a/fs/nfsd/vfs.c b/fs/nfsd/vfs.c
index f59a55f89..0012c68d6 100644
--- a/fs/nfsd/vfs.c
+++ b/fs/nfsd/vfs.c
@@ -124,14 +124,14 @@ nfserrno(int errno)
 }
 
 /*
- * Called from nfsd_lookup and encode_dirent. Check if we have crossed
+ * Called from lookup, SECINFO, and encode_dirent. Check if we have crossed
  * a mount point.
  * Returns an nfs error leaving *dpp and *expp unchanged,
  *  or nfs_ok having possibly changed *dpp and *expp
  */
-__be32
-nfsd_cross_mnt(struct svc_rqst *rqstp, struct dentry **dpp,
-	       struct svc_export **expp)
+static __be32
+nfsd_cross_mnt_common(struct svc_rqst *rqstp, struct dentry **dpp,
+		      struct svc_export **expp, bool for_secinfo)
 {
 	struct svc_export *exp = *expp, *exp2 = NULL;
 	struct dentry *dentry = *dpp;
@@ -169,7 +169,9 @@ nfsd_cross_mnt(struct svc_rqst *rqstp, struct dentry **dpp,
 			err = 0;
 	} else if (nfsd_v4client(rqstp) ||
 		(exp->ex_flags & NFSEXP_CROSSMOUNT) || EX_NOHIDE(exp2)) {
-		nfserr = check_nfsd_access(exp, rqstp);
+		/* SECINFO needs the target's flavors even if the source differs. */
+		if (!for_secinfo)
+			nfserr = check_nfsd_access(exp, rqstp);
 		if (nfserr == nfs_ok) {
 			/* successfully crossed mount point */
 			/*
@@ -193,6 +195,13 @@ nfsd_cross_mnt(struct svc_rqst *rqstp, struct dentry **dpp,
 	return nfserrno(err);
 }
 
+__be32
+nfsd_cross_mnt(struct svc_rqst *rqstp, struct dentry **dpp,
+	       struct svc_export **expp)
+{
+	return nfsd_cross_mnt_common(rqstp, dpp, expp, false);
+}
+
 static void follow_to_parent(struct path *path)
 {
 	struct dentry *dp;
@@ -255,7 +264,8 @@ int nfsd_mountpoint(struct dentry *dentry, struct svc_export *exp)
 __be32
 nfsd_lookup_dentry(struct svc_rqst *rqstp, struct svc_fh *fhp,
 		   const char *name, unsigned int len,
-		   struct svc_export **exp_ret, struct dentry **dentry_ret)
+		   struct svc_export **exp_ret, struct dentry **dentry_ret,
+		   bool for_secinfo)
 {
 	struct svc_export	*exp;
 	struct dentry		*dparent;
@@ -288,7 +298,8 @@ nfsd_lookup_dentry(struct svc_rqst *rqstp, struct svc_fh *fhp,
 		if (IS_ERR(dentry))
 			goto out_nfserr;
 		if (nfsd_mountpoint(dentry, exp)) {
-			__be32 nfserr = nfsd_cross_mnt(rqstp, &dentry, &exp);
+			__be32 nfserr = nfsd_cross_mnt_common(rqstp,
+					&dentry, &exp, for_secinfo);
 
 			if (nfserr) {
 				dput(dentry);
@@ -297,6 +308,23 @@ nfsd_lookup_dentry(struct svc_rqst *rqstp, struct svc_fh *fhp,
 			}
 		}
 	}
+	/*
+	 * For SECINFO the caller's fh_verify() has already checked the
+	 * starting export's xprtsec= policy.  A mount crossing or parent
+	 * traversal above can switch to a different export; since
+	 * svc_export objects are immutable once published, re-check the
+	 * transport policy only for that new export.  The flavor is left
+	 * for SECINFO to report (RFC 8881 section 2.6.3.1.1.5).
+	 */
+	if (for_secinfo && exp != fhp->fh_export) {
+		__be32 nfserr = check_xprtsec_policy(exp, rqstp);
+
+		if (nfserr) {
+			dput(dentry);
+			exp_put(exp);
+			return nfserr;
+		}
+	}
 	*dentry_ret = dentry;
 	*exp_ret = exp;
 	return 0;
@@ -337,9 +365,13 @@ nfsd_lookup(struct svc_rqst *rqstp, struct svc_fh *fhp, const char *name,
 	err = fh_verify(rqstp, fhp, S_IFDIR, NFSD_MAY_EXEC);
 	if (err)
 		return err;
-	err = nfsd_lookup_dentry(rqstp, fhp, name, len, &exp, &dentry);
+	err = nfsd_lookup_dentry(rqstp, fhp, name, len, &exp, &dentry,
+				  false);
 	if (err)
 		return err;
+	err = check_nfsd_access(exp, rqstp);
+	if (err)
+		goto out;
 	/*
 	 * Note: we compose the file handle now, but as the
 	 * dentry may be negative, it may need to be updated.
@@ -348,6 +380,7 @@ nfsd_lookup(struct svc_rqst *rqstp, struct svc_fh *fhp, const char *name,
 	if (!err && d_really_is_negative(dentry))
 		err = nfserr_noent;
 
+out:
 	dput(dentry);
 	exp_put(exp);
 	return err;
diff --git a/fs/nfsd/vfs.h b/fs/nfsd/vfs.h
index 1f05c83a3..e7724628f 100644
--- a/fs/nfsd/vfs.h
+++ b/fs/nfsd/vfs.h
@@ -33,6 +33,7 @@
 #define NFSD_MAY_64BIT_COOKIE		0x1000 /* 64 bit readdir cookies for >= NFSv3 */
 
 #define NFSD_MAY_LOCALIO		0x2000 /* for tracing, reflects when localio used */
+#define NFSD_MAY_SECINFO		0x4000 /* query export security policy */
 
 #define NFSD_MAY_CREATE		(NFSD_MAY_EXEC|NFSD_MAY_WRITE)
 #define NFSD_MAY_REMOVE		(NFSD_MAY_EXEC|NFSD_MAY_WRITE|NFSD_MAY_TRUNC)
@@ -133,7 +134,8 @@ __be32		nfsd_lookup(struct svc_rqst *, struct svc_fh *,
 				const char *, unsigned int, struct svc_fh *);
 __be32		 nfsd_lookup_dentry(struct svc_rqst *, struct svc_fh *,
 				const char *, unsigned int,
-				struct svc_export **, struct dentry **);
+				struct svc_export **, struct dentry **,
+				bool for_secinfo);
 __be32		nfsd_setattr(struct svc_rqst *, struct svc_fh *,
 			     struct nfsd_attrs *, const struct timespec64 *);
 int nfsd_mountpoint(struct dentry *, struct svc_export *);
-- 
2.43.0
