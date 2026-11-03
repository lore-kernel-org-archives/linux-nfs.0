Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.remote-ip=209.85.208.51
ARC-Seal: i=1; d=subspace.kernel.org; s=arc20261015; a=rsa-sha256; cv=none;
	t=1793669584;
	b=rBdu6Gc/ppWjWZY/txsWR43KNClEv/5W/OUskKDbr/jcEAE3g0AmAWTe0d3uednJiGPr
	 FJXiijCkn7oBENwEhLrpt0F3HpvOfHjDnv31nrm5dnOToFLuuCb+z+hYQxlbEvhzeNkzq
	 iMeR9MdHr829gBqRlqfoRDnvG+oYJQdHVcNK2W/xuxPB7SNdYrCqlTAixNSZnWjxO7dd/
	 S4d510lRSDzfaZlDuRACcpxUjzy94YUmBgLxPAwG1p7gBYhcah3lEKay1TNdGvR48vxtc
	 9Bdb/unHmyCnnpMz90u+brU15y1w3pzy8hHowaCFmGM35xTjDdmIpGGeUE80awG+a7w==
ARC-Message-Signature: i=1; d=subspace.kernel.org; s=arc20261015;
	a=rsa-sha256; c=relaxed/relaxed; t=1793669584;
	h=DMARC-Filter:Received:DKIM-Signature:X-Google-DKIM-Signature:
	 X-Gm-Message-State:X-Gm-Gg:X-Received:Received:From:To:Cc:Subject:
	 Date:Message-ID:X-Mailer:In-Reply-To:References:MIME-Version:
	 Content-Transfer-Encoding;
	bh=Kd8d42xyVxByjnK4LgEP17oQV3A+VolNRmLqLMWvUSQ=;
	b=If7+YsLrbG8uRT43CFj8SczlhYZQLaE+xDmyRHt6l0z3AamUwzqeHwRbZ+U4WftKdMWh
	 QpX/luED6P+QaYmbGFl1E43OAtrkuLMzwfrL+gouHGApCjb/FX+OdhThAeiaVjn/7cBGe
	 OVFwJlS2fmlG18CIErzYDbsJNttr1nSm5oB6wKdeIY0QikPMNdQ22ZJzqsbJWdYnIpKqV
	 f7POcndCyzQ1OThcpxyXwnyuxg8K3ZdU2w9NYDSxQkNe9akqa5FgWpMK+3zG2VG7ohXRD
	 UhYWaAU2wQKlvz/iOrM2iBDd/Vp//is3JOPREBNgXY1rPuQWClch+JzcjhlOK2yG3dw==
ARC-Authentication-Results: i=1; smtp.subspace.kernel.org; 
	dmarc=pass header.from=gmail.com;
	spf=pass smtp.mailfrom=gmail.com;
	dkim=pass header.d=gmail.com header.i=@gmail.com header.a=rsa-sha256 header.s=20260707 header.b=y+jocFG8;
	arc=none smtp.remote-ip=209.85.208.51
Received: from mail-ed1-f51.google.com (mail-ed1-f51.google.com [209.85.208.51])
	(using TLSv1.3 with cipher TLS_AES_128_GCM_SHA256 (128/128 bits)
	 key-exchange X25519 server-signature ECDSA (prime256v1) server-digest SHA256)
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 9445C606A324
	for <linux-nfs@vger.kernel.org>; Tue,  3 Nov 2026 01:33:03 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.4.2 smtp.subspace.kernel.org 9445C606A324
Authentication-Results: smtp.subspace.kernel.org; dmarc=pass (p=none dis=none) header.from=gmail.com
Authentication-Results: smtp.subspace.kernel.org; spf=pass smtp.mailfrom=gmail.com
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key, unprotected) header.d=gmail.com header.i=@gmail.com header.a=rsa-sha256 header.s=20260707 header.b=y+jocFG8
Received: by mail-ed1-f51.google.com with SMTP id 4fb4d7f45d1cf-6acb9c018ffso297969a12.1
        for <linux-nfs@vger.kernel.org>; Mon, 02 Nov 2026 17:33:03 -0800 (PST)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=gmail.com; s=20260707; t=1793669582; x=1794274382; darn=vger.kernel.org;
        h=content-transfer-encoding:mime-version:references:in-reply-to
         :message-id:date:subject:cc:to:from:from:to:cc:subject:date
         :message-id:reply-to:content-type;
        bh=Kd8d42xyVxByjnK4LgEP17oQV3A+VolNRmLqLMWvUSQ=;
        b=y+jocFG8Yoq25d7JvbWsXMtvKL3zq3jZ2Kii7BlTH7bzUNod6RjMw7ki6/AiGq71xn
         1a1//JmFFvQCaZ7DrInOaS3O62SJGC6IXIBjefioMdTe8oRVSusCMYo/W/5AYt7iE4Fw
         hkX+45LsGScZKi96urTq1NO6rrogNgKZI4kr2bxi8arUE3+BB8VFhboB53BlFrF9qtui
         wRnpoQWCU2amKA3xB0Tr863YZ9KmNkcaPkLxSUzk43fIiY0xY8Bbp+M0AV97o8Fy3H2x
         ieHP8RuYqbsHiwCp/cEq4pKukkxHdxMKQnLgD0hz1r91KftokYRgYTGz0SLS6HakGM6Q
         Slnw==
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20260707; t=1793669582; x=1794274382;
        h=content-transfer-encoding:mime-version:references:in-reply-to
         :message-id:date:subject:cc:to:from:x-gm-gg:x-gm-message-state:from
         :to:cc:subject:date:message-id:reply-to:content-type;
        bh=Kd8d42xyVxByjnK4LgEP17oQV3A+VolNRmLqLMWvUSQ=;
        b=OHA8Bkch0qPFrm246YyvPClAqwDD5vZgBzlnmx90HSG7Yb4n0uBW87VhJQgarNs9TO
         T7OYsBf7TI9n25FiGYCN2wzpx9LFSIRqpGduqpYOysai4wHKmQQj0uTobfNyexsJuyYv
         MzsovQvRMzsfZ0TjcP86gQ7gF5b61f1s1Yq2PH6ya9hKF5tKxUOblepN02e5qxjyn/ze
         vnHPBDdNTBkUXQ8O6GYsCGTicwNfLNqwU2gfEEYrGqmmbyfwC1ovp6ePezoPYMa0e+H7
         Eq5FbcMT5BEZEUGrvZVm8e4P+QuVoj5s5iYA+/7BpMvWyjLzgALelGDWBO0a5Ua2dXMg
         8XtA==
X-Gm-Message-State: APuU4Z9nWImoLPgLWmlKGpBPD9dbvXDLpfSRyU8g4m8MUULBnY7yPvBE
	N0txUCHTkgFGv8Lf0RhAXL78FhTFBGrFbNfXcc7wuZ/VXQUmETcWkaYacpVDvTBaGUk=
X-Gm-Gg: AYBFou0qdA3SZGbcsUzcM7X6ir0zZxlo7i28Tv3IexJsFcG1yYpiBnCykudDHxbi5cL
	Ep3O17iD9yOi90am/r/6pNwNFIuH8hPiZ4c2uU3sqh93SdRva3k5IkkBCk1gk0KrsfTv9a6yx4K
	sXeEhqKA45LpeeJhFAOi14FVcOarGzIpYNpIRt1TZp8JFm5AR3PrgE0zVLHsNAO2L8InUcrE3tX
	fSYlJb1s08cPjuybEsyQwNTXUt4UlGepWsCj58QC3jPMXYF5F5wq794xoacl0mm1tJ+Wp3DYLpC
	Vh7fk53AT2wrbUe+mDMJLqZDNJsQWVGt37CHNj9ES/k+/9IF75pnuseqEPRLd35+MI3/pIpD7+M
	CzcC28hmhUv478j7p/Iu37h31DnbqcGSihvQSNBoiR+DDv3GE5Tgwcq6eAkuh7gr/xdsJNxCbjw
	2PCwqE5BZL2Saa1HJSuShkG+R9mTuUGra3oxK6Gn25U6GIr097PGweJu2CIfMfNdetApXFTY0Z3
	IQCOgT2Oh5WbRW4zVAOHH9zTH0Bl+xSIjFp8w5oMQkodgXDec1zJdccl5smIywK2rPiKC6kchLF
	2hkwqW3fvzNQZQVfdiHESi013DorTpz5sX5jTBB9qt+smCbtFRjFhcVif3dfuw4WMHJlt8iR
X-Received: by 2002:aa7:cd74:0:b0:6b4:1916:9674 with SMTP id 4fb4d7f45d1cf-6b4d4a7b9fbmr5506699a12.5.1793669582114;
        Mon, 02 Nov 2026 17:33:02 -0800 (PST)
Received: from localhost.localdomain (173.242.112.181.16clouds.com. [173.242.112.181])
        by smtp.gmail.com with ESMTPSA id 4fb4d7f45d1cf-6b4ec91e2f2sm3776583a12.0.2026.11.02.17.33.00
        (version=TLS1_3 cipher=TLS_AES_256_GCM_SHA384 bits=256/256);
        Mon, 02 Nov 2026 17:33:01 -0800 (PST)
From: VeroFess <coderzeng@gmail.com>
To: linux-nfs@vger.kernel.org
Cc: cel@kernel.org,
	jlayton@kernel.org
Subject: [PATCH 3/3] NFSD: Verify COPY and CLONE source and destination filehandles
Date: Tue,  3 Nov 2026 09:32:37 +0800
Message-ID: <20261103013237.1174538-4-coderzeng@gmail.com>
X-Mailer: git-send-email 2.43.0
In-Reply-To: <20261103013237.1174538-1-coderzeng@gmail.com>
References: <20261103013237.1174538-1-coderzeng@gmail.com>
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

nfsd4_verify_copy() checks the saved source export's flavor and
transport policy, then resolves its stateid. With a cached OPEN
stateid, the file permission check can use credentials left by PUTFH
on the destination export. This can retain root access after the
source export enables root_squash, or reject a source that all_squash
maps to its anonymous UID or GID. The requester must already hold an
OPEN stateid for each file in the reproducer, both source and
destination.

Verify the saved filehandle before resolving the source stateid.
This checks its port requirement and installs the source export's
mapped credentials. Verify the destination filehandle before
resolving its stateid to restore the credentials for the write.
Continue mapping NFS4ERR_WRONGSEC to NFS4ERR_ACCESS for COPY and CLONE.

Fixes: 29ae7f9dc21a ("NFSD: Implement the COPY call")
Signed-off-by: VeroFess <coderzeng@gmail.com>
---
On the combined fix tree, saved-source COPY with root_squash was denied
without changing the destination; permitted COPY and CLONE matched the
source bytes. This patch also built alone with W=1.

 fs/nfsd/nfs4proc.c | 10 +++++++++-
 1 file changed, 9 insertions(+), 1 deletion(-)

diff --git a/fs/nfsd/nfs4proc.c b/fs/nfsd/nfs4proc.c
index 218cedb..774ba9e 100644
--- a/fs/nfsd/nfs4proc.c
+++ b/fs/nfsd/nfs4proc.c
@@ -1514,7 +1514,7 @@ nfsd4_verify_copy(struct svc_rqst *rqstp, struct nfsd4_compound_state *cstate,
 		return nfserr_nofilehandle;
 
 	/* A cached open stateid does not authorize the saved source export. */
-	status = check_nfsd_access(cstate->save_fh.fh_export, rqstp);
+	status = fh_verify(rqstp, &cstate->save_fh, 0, NFSD_MAY_NOP);
 	if (status)
 		return status == nfserr_wrongsec ? nfserr_acces : status;
 
@@ -1523,6 +1523,14 @@ nfsd4_verify_copy(struct svc_rqst *rqstp, struct nfsd4_compound_state *cstate,
 	if (status)
 		goto out;
 
+	/* Use the destination export's credentials for the write. */
+	status = fh_verify(rqstp, &cstate->current_fh, 0, NFSD_MAY_NOP);
+	if (status) {
+		if (status == nfserr_wrongsec)
+			status = nfserr_acces;
+		goto out_put_src;
+	}
+
 	status = nfs4_preprocess_stateid_op(rqstp, cstate, &cstate->current_fh,
 					    dst_stateid, WR_STATE, dst, NULL);
 	if (status)
-- 
2.43.0

