Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.remote-ip=209.85.218.48
ARC-Seal: i=1; d=subspace.kernel.org; s=arc20261015; a=rsa-sha256; cv=none;
	t=1793237836;
	b=l9iKXHpwQ9RNWtiB+6F50JpCPQ3CDUMatipJ3gRHpvUAwnty6PGqVeLu4+0gsuTyx7XX
	 23WYSKNv/dgDat9+yimnC2JccDVMQI5jnC+WiYr0wE++awTFdsLf64R0vFligKLipVXNb
	 iYYSNrIO50Z6MU/lzoE5Er8eC1+ELe9cayGPUqJFq9uOyB17ltXYiLEKcfJyHRIGeXgS7
	 fTPzb+6MG2Aua1oHG5ImAU1CUJzWRFsTZQK74aRjMkB+kft9MaiElgp9m6uVt+3PmaSSc
	 aLan/uQ4dnogG4PLBicrcwbmSZrhth1MrhmawAD5TH/+PF8ms9rtyhSCSNFmb9PgI8Q==
ARC-Message-Signature: i=1; d=subspace.kernel.org; s=arc20261015;
	a=rsa-sha256; c=relaxed/relaxed; t=1793237836;
	h=DMARC-Filter:Received:DKIM-Signature:X-Google-DKIM-Signature:
	 X-Gm-Message-State:X-Gm-Gg:X-Received:Received:From:To:Cc:Subject:
	 Date:Message-ID:X-Mailer:In-Reply-To:References:MIME-Version:
	 Content-Transfer-Encoding;
	bh=mlG9nR54GtHfeNbEZdjATk9VbG5JP8DB15jYjxggGsk=;
	b=Uq1Ku8yC+4PpzI9v9Cx6RBLOnBjeWJBF2fm73DOYtukz+07I30fEbKJDzCING08SpaId
	 RML9TFnTn64j4fVMnnxPcdzyQtzhuXSFCKIVVOrwoVl6reXU7QWH0VeusG8gyVnlQ0B1E
	 Kop/AGXfbEHzDYzB+woKt13xR1WTjrpAilU43e1e0FuNgu36lV0qEm6p/KNXvMTG+CncI
	 KpFpw2BpDTYP2MPFziqJqhVYnaYLNFonIq6kqsQXtsa1YOuHrjUKTfsLIrrdCLPd6EKOz
	 iI+JJIeZD5XL34+50EF6FLjisk3v9VyUQEZgDvs0tgWvicZvYFs/HdOa8VnCc8FcSfg==
ARC-Authentication-Results: i=1; smtp.subspace.kernel.org; 
	dmarc=pass header.from=gmail.com;
	spf=pass smtp.mailfrom=gmail.com;
	dkim=pass header.d=gmail.com header.i=@gmail.com header.a=rsa-sha256 header.s=20260707 header.b=olRLczzR;
	arc=none smtp.remote-ip=209.85.218.48
Received: from mail-ej1-f48.google.com (mail-ej1-f48.google.com [209.85.218.48])
	(using TLSv1.3 with cipher TLS_AES_128_GCM_SHA256 (128/128 bits)
	 key-exchange X25519 server-signature ECDSA (prime256v1) server-digest SHA256)
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 08849606A31A
	for <linux-nfs@vger.kernel.org>; Thu, 29 Oct 2026 01:37:15 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.4.2 smtp.subspace.kernel.org 08849606A31A
Authentication-Results: smtp.subspace.kernel.org; dmarc=pass (p=none dis=none) header.from=gmail.com
Authentication-Results: smtp.subspace.kernel.org; spf=pass smtp.mailfrom=gmail.com
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key, unprotected) header.d=gmail.com header.i=@gmail.com header.a=rsa-sha256 header.s=20260707 header.b=olRLczzR
Received: by mail-ej1-f48.google.com with SMTP id a640c23a62f3a-c40e02b2ebaso250792466b.1
        for <linux-nfs@vger.kernel.org>; Wed, 28 Oct 2026 18:37:15 -0700 (PDT)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=gmail.com; s=20260707; t=1793237834; x=1793842634; darn=vger.kernel.org;
        h=content-transfer-encoding:mime-version:references:in-reply-to
         :message-id:date:subject:cc:to:from:from:to:cc:subject:date
         :message-id:reply-to:content-type;
        bh=mlG9nR54GtHfeNbEZdjATk9VbG5JP8DB15jYjxggGsk=;
        b=olRLczzR7JZu9YEl8QvmGuAJc2m0Z3dfEUHVqzPnPn004jFEfpyy1ZKfC0rWUDQ7dE
         tF/LzkuEtYss2eud2B1eofOc2FL4KIpN39Ghl37wmy/c68tQGY9KcRXNxHPOQ+b0OEYB
         KqOI1hx8dWFjcJI1Y8B2byuX7toksuhsVzUQVh6z3tV+nd/a4HcMVKOtu6QlRq4LbxVu
         hINc9gSfZlTdX0u9YH7uh1398UsevZr5lasEoLqM0qHjI6HinJoqlvfZaRm8mRaCYGOA
         adUXUbMNJinsZiScyKrhoC3XY6AmL1UyZuQlJSPOX3FrLZBslVQzBr+svbbUmMMEPzyt
         KNjQ==
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20260707; t=1793237834; x=1793842634;
        h=content-transfer-encoding:mime-version:references:in-reply-to
         :message-id:date:subject:cc:to:from:x-gm-gg:x-gm-message-state:from
         :to:cc:subject:date:message-id:reply-to:content-type;
        bh=mlG9nR54GtHfeNbEZdjATk9VbG5JP8DB15jYjxggGsk=;
        b=NZWGiuf5XRBJmmDPJyaWZ9K3nDlnlNY9R+vEC72RDgHxI6S+2kVnDHEbKyKxXqoGQE
         PTF32fZBqdFuT00L/EEmGTBtRx0drdRq0njoE5c3NQhL8Rqg8XHrjWXdmAGF9AxllHSf
         EDaBXH6Cz+1JZX601fNSpCxaSo2NsYIgBJ0XMLtcngfsgFdedOfV/OZ4CxC8eoOyz69W
         K9SGEAwH8/4Z+bZa31L9HffTdt2WU37G5pv3DFTSFUA6bz0hyy760/jSK9DuB+uSHqge
         3eFHgEyeRtXGSM6/CDtO6UjEp1PVYAXUcN99mTBmw1enbygEohUd3pUC2oGzbHz6Qudy
         Zdrw==
X-Gm-Message-State: AFq9FYJjYaNT/ozU2UcPd32qYWr8E560d5sFomAGsYmMWnbKXMcmGrwu
	ZjJ4RRJc5C2qcYO5BkBT9gf3ED6pdLCDHHcOSFFOvkUuygMnTu5B9Plw
X-Gm-Gg: AYBFou2UrtVgiSmuccUOkUrcZRSphA9TUR740QyNh5yvvNsIt0HnR71544LVjC15FIp
	ZIRnOywVpA7Hr1XBA7ggMOXTSTDsZ2pKxfuqCyfjvLSNdo2+EVaE8ty5rMB514NQ7/+u3afq+Lk
	AFxTkYa9PgpE8W6cUy3P9s9Qb/4ajHOsonckx7fGAnMvJr46TbXtXe9juB4bEWQsFIQ//Ox2GSF
	V2zEoBRi2CQC2r5MRRC1gJeylAcA6UkVoHDG6ZDUNL+5YjkOEjpw+kqBCWDNTbpIdg7en7k/pdE
	K/XRhO8y3BclexGGHwNDigFOWUq1Mi5zRGWCAsB17FuQOWQh+umSxWAFJsoE4Cmt8DyeOXfMEh+
	oN8R4CVGYfJ2NonfmtS1bRUM5IER9FGbo8/4PHGAArZ5p5eVwU1lbU7gqFst5ViWTq07LhEtbfA
	mvBH/MQT+H8DAJEXIc0lXvEZzowUptuD7NKVglelMMobdIK192kJv4GhC6O3a5O0ECMl3Mn8fG4
	NPO+HmhCyXlWvanbh/BjzmbxbCZm+s2SUT0ClEC0bULUrna+tXoqqw2aVSiv+Maz7nfScj5dEgk
	H0ZDAgzEBnmhTHEuDQkvdSjDi+wOtqiQ85p3rA0Vgx6Zu4wZI/AFBE5y014F7WWTg1l8wjMsJA=
	=
X-Received: by 2002:a17:907:80a:b0:c3f:d912:ff8e with SMTP id a640c23a62f3a-c49bdec8226mr309718866b.16.1793237834177;
        Wed, 28 Oct 2026 18:37:14 -0700 (PDT)
Received: from localhost.localdomain (173.242.112.181.16clouds.com. [173.242.112.181])
        by smtp.gmail.com with ESMTPSA id a640c23a62f3a-c46bd34fe2dsm672327066b.1.2026.10.28.18.37.10
        (version=TLS1_3 cipher=TLS_AES_256_GCM_SHA384 bits=256/256);
        Wed, 28 Oct 2026 18:37:13 -0700 (PDT)
From: VeroFess <coderzeng@gmail.com>
To: cel@kernel.org,
	jlayton@kernel.org,
	neil@brown.name,
	okorniev@redhat.com,
	Dai.Ngo@oracle.com,
	tom@talpey.com
Cc: linux-nfs@vger.kernel.org
Subject: [PATCH v2] nfsd: enforce export security for NFSv4 filehandles and stateids
Date: Thu, 29 Oct 2026 09:36:48 +0800
Message-ID: <20261029013648.12015-1-coderzeng@gmail.com>
X-Mailer: git-send-email 2.43.0
In-Reply-To: <SY9P300MB153090355AAD017CD7216634A6602@SY9P300MB1530.AUSP300.PROD.OUTLOOK.COM>
References: <SY9P300MB153090355AAD017CD7216634A6602@SY9P300MB1530.AUSP300.PROD.OUTLOOK.COM>
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

The original report exported /srv/nfs-sec to * with these options:

  rw,sync,no_subtree_check,fsid=0,sec=krb5p,secure,root_squash

The 0600, nobody:nogroup file /srv/nfs-sec/secret.txt held 32 random
bytes. A Kerberos privacy NFSv4.0 client ran SETCLIENTID, OPEN and
OPEN_CONFIRM, then kept its read/write stateid live. A separate
AUTH_SYS client used UID/GID 65534 and a reserved source port.

The AUTH_SYS client enumerated a bounded range of nearby clientid counters,
stateid numbers and seqids to find the live OPEN stateid. With it,
PUTFH, READ returned NFS4ERR_WRONGSEC, while PUTFH, SAVEFH, READ
returned the file data and PUTFH, SAVEFH, WRITE changed it. The
Kerberos client subsequently read the changed contents.

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
Assisted-by: LLM
Signed-off-by: VeroFess <coderzeng@gmail.com>
---
Changes since v1:
  Check the selected export after LOOKUP and READDIR mount crossing.
  Map READDIR's operation-level WRONGSEC to ACCESS when rdattr_error
  was not requested. Add guards for cached stateid I/O and COPY_NOTIFY.
  Restore the RFC comments, drop a redundant assignment, and add the
  missing Fixes tags. Regenerate the diff after v1's whitespace damage.

Tests and review notes:
  W=1 object builds and an x86_64 KASAN bzImage completed. Runtime
  tests used bcd97658ca9b; the diff also applied without fuzz to
  cel/nfsd-testing at 944812cf2b77.

  PUTFH, SAVEFH, READ/WRITE returned NFS4ERR_WRONGSEC at PUTFH.
  SAVEFH alone, a replacement PUTFH, and SECINFO_NO_NAME remained
  allowed; RESTOREFH, READ checked at RESTOREFH.

  An ordinary file export kept the parent handle on LOOKUP; a bind
  mount selected the stricter child export. With parent sec=sys:krb5p
  and child sec=krb5p, AUTH_SYS LOOKUP, READ/WRITE succeeded before
  this fix using a GSS-opened stateid. The v4.0 test used another
  client; v4.1 and v4.2 changed credentials within one session. The
  final kernel returned NFS4ERR_WRONGSEC at LOOKUP on all three
  versions. Direct PUTFH already returned NFS4ERR_WRONGSEC. GSS
  LOOKUP, AUTH_SYS SECINFO, and access to a public sibling succeeded.
  SECINFO returned krb5p for the strict child. Source review found
  that the Linux client calls SECINFO(parent, name) after LOOKUP
  WRONGSEC and retries LOOKUP with the selected flavor.
  Cross-client stateids were not tested on v4.1 or v4.2.

  On v4.0, v4.1, and v4.2, READDIR reported the strict child's
  NFS4ERR_WRONGSEC in rdattr_error and kept public entries intact.
  With size but no rdattr_error, READDIR returned NFS4ERR_ACCESS;
  name-only READDIR succeeded. COPY into the strict child copied
  4096 bytes before this fix; the final LOOKUP check now prevents
  that destination from being selected under AUTH_SYS. CLONE reached
  ext4 but returned NFS4ERR_NOTSUPP before the fix, so no clone
  completed. Protected saved-source COPY/CLONE still returned
  NFS4ERR_ACCESS.

  Before restoring the LOOKUP check, the cached-file guard returned
  NFS4ERR_ACCESS for READ/WRITE, READ_PLUS, SEEK, ALLOCATE, DEALLOCATE,
  and COPY with the strict child handle. GETATTR, ACCESS, and OPEN
  already returned NFS4ERR_WRONGSEC. Source review found fh_verify()
  in SETATTR, READLINK, VERIFY/NVERIFY, and xattrs; COMMIT acquires
  an nfsd_file. LINK/RENAME saved-FH probes returned NFS4ERR_WRONGSEC.

  After a live AUTH_SYS OPEN, changing the export to sec=krb5p and
  mode 000 denied AUTH_SYS READ but still allowed COPY_NOTIFY to
  issue a copy stateid before this fix. A separate user-space GSS
  client could not OPEN the file, yet read 4096 bytes with that
  stateid and wrote them to another export. An intermediate build
  rejected COPY_NOTIFY with NFS4ERR_ACCESS before issuing a stateid.
  With the final kernel, both READ and COPY_NOTIFY compounds stop at
  LOOKUP with NFS4ERR_WRONGSEC. Source review and repeated denial
  found no notification allocation or retained stateid reference
  on COPY_NOTIFY's own error path.

  Stock NFSD-to-NFSD COPY from the strict export ended with
  NFS4ERR_OFFLOAD_DENIED and zero bytes copied; the permissive-source
  control copied the file. With the final kernel, an authorized foreign-FH
  inter-server COPY completed and the destination matched the source.
  A local-only COPY with a foreign FH returned NFS4ERR_STALE at PUTFH.

  The targeted KASAN guests logged no KASAN fault or NFSD warning.
  pNFS, other architectures, and the full pynfs suite were not tested.

base-commit: bcd97658ca9be5a691eff14065a8f2dcfef6bbaf

 fs/nfsd/nfs4proc.c  | 43 ++++++++++++++++++++++++++++++-------------
 fs/nfsd/nfs4state.c |  6 ++++++
 fs/nfsd/nfs4xdr.c   |  8 +++++++-
 fs/nfsd/vfs.c       |  4 ++++
 4 files changed, 47 insertions(+), 14 deletions(-)

diff --git a/fs/nfsd/nfs4proc.c b/fs/nfsd/nfs4proc.c
index a50f9dcb3..3a7f5e96a 100644
--- a/fs/nfsd/nfs4proc.c
+++ b/fs/nfsd/nfs4proc.c
@@ -1491,6 +1491,11 @@ nfsd4_verify_copy(struct svc_rqst *rqstp, struct nfsd4_compound_state *cstate,
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
@@ -2532,6 +2537,12 @@ nfsd4_copy_notify(struct svc_rqst *rqstp, struct nfsd4_compound_state *cstate,
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
 
@@ -3237,32 +3248,38 @@ static bool need_wrongsec_check(struct svc_rqst *rqstp)
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
index f2b52ba90..27f5b1a58 100644
--- a/fs/nfsd/nfs4state.c
+++ b/fs/nfsd/nfs4state.c
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
diff --git a/fs/nfsd/vfs.c b/fs/nfsd/vfs.c
index f59a55f89..8935a6fcc 100644
--- a/fs/nfsd/vfs.c
+++ b/fs/nfsd/vfs.c
@@ -340,6 +340,9 @@ nfsd_lookup(struct svc_rqst *rqstp, struct svc_fh *fhp, const char *name,
 	err = nfsd_lookup_dentry(rqstp, fhp, name, len, &exp, &dentry);
 	if (err)
 		return err;
+	err = check_nfsd_access(exp, rqstp);
+	if (err)
+		goto out;
 	/*
 	 * Note: we compose the file handle now, but as the
 	 * dentry may be negative, it may need to be updated.
@@ -348,6 +351,7 @@ nfsd_lookup(struct svc_rqst *rqstp, struct svc_fh *fhp, const char *name,
 	if (!err && d_really_is_negative(dentry))
 		err = nfserr_noent;
 
+out:
 	dput(dentry);
 	exp_put(exp);
 	return err;
-- 
2.43.0

