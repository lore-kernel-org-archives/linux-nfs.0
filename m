Received: from mail-oa1-f50.google.com (mail-oa1-f50.google.com [209.85.160.50])
	(using TLSv1.2 with cipher ECDHE-RSA-AES128-GCM-SHA256 (128/128 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id BD2AF3CD8C7
	for <linux-nfs@vger.kernel.org>; Wed,  3 Jun 2026 15:09:51 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=209.85.160.50
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1780499393; cv=none; b=KFw4SJh5u0RvhqBtsCXUGkYW3A2G6vktB4NZsdB3XrmHnzVXidT2sDvVgx3A3wCFmKuw1Fq/aEHa0e2xQsJHOeiB3AEEVd6k7XsUqV6PbG4LirlII4eGAYA425Cue4IjxnPRcB9rXNiwd4/puC0Vb5xTo7dSvARC26EUKqk0faU=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1780499393; c=relaxed/simple;
	bh=Di2X3eCnm0TUFkLPZG5xZvyZHEJZIZMDUmWU53Aj5/c=;
	h=From:To:Cc:Subject:Date:Message-ID:In-Reply-To:References:
	 MIME-Version; b=jCnd5j7cN2MV7X4r8yUm3nuf111YrzmR3MPGwU61R+941cbVRj3n2RaT9Y+Lu6VfZXN9ddRYBS21NOYPF8IKSG3WWr29iazz9MM8vVffcTtjiycsSXj74eQ7Oy9vH/jSyGX0Y5YbiBwpZMzKowNe6dwrCbfKptRh6u1BPa7PbN0=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dmarc=pass (p=quarantine dis=none) header.from=hammerspace.com; spf=fail smtp.mailfrom=hammerspace.com; dkim=pass (2048-bit key) header.d=hammerspace.com header.i=@hammerspace.com header.b=cUv1qfRe; arc=none smtp.client-ip=209.85.160.50
Authentication-Results: smtp.subspace.kernel.org; dmarc=pass (p=quarantine dis=none) header.from=hammerspace.com
Authentication-Results: smtp.subspace.kernel.org; spf=fail smtp.mailfrom=hammerspace.com
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=hammerspace.com header.i=@hammerspace.com header.b="cUv1qfRe"
Received: by mail-oa1-f50.google.com with SMTP id 586e51a60fabf-43b7e186a0cso3915669fac.0
        for <linux-nfs@vger.kernel.org>; Wed, 03 Jun 2026 08:09:51 -0700 (PDT)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=hammerspace.com; s=google; t=1780499391; x=1781104191; darn=vger.kernel.org;
        h=content-transfer-encoding:mime-version:references:in-reply-to
         :message-id:date:subject:cc:to:from:from:to:cc:subject:date
         :message-id:reply-to;
        bh=Ak18w+oJSVNcJ/GQ0eVatn/ZAfgMQz0FlNCgUmJJ6kQ=;
        b=cUv1qfReqNkphrO68HCi6jAZr1PZMdNDAUjIBKKcuZ+OEbIL1V+2XEktpRuUI6Ymk3
         1WBx3ktGKn36VG6DZr8gWV0EafPRuoWWAkqxYJmTboGcMCr0DogLVXeem/LfZ9FW7f84
         NSoKS+o2r46LbMXdgYJcD9cHY8apEgBpiqd+6UwN2Gjx/eQnRTRQYFM5fvwVcRRPlIZX
         lLnWtRzV/5Yzeb0tnT08WlGWHyH2M/YJMmvUC6OQ7PPQTM7Cs5FdTJ37ehIL9Scry4yX
         rx32ALJ9Qi7by7SML4FngbWm3DF7OrclJyhifBx6sIgqmlJHXJoub+OxBchTjF94Idjw
         gcTQ==
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20251104; t=1780499391; x=1781104191;
        h=content-transfer-encoding:mime-version:references:in-reply-to
         :message-id:date:subject:cc:to:from:x-gm-gg:x-gm-message-state:from
         :to:cc:subject:date:message-id:reply-to;
        bh=Ak18w+oJSVNcJ/GQ0eVatn/ZAfgMQz0FlNCgUmJJ6kQ=;
        b=DONEt1b8i8q48JrNHEl0siVGLtIc1XYz5RgFT3LnrwfcOdZturBtoCrl5/eHhPQQrN
         +Q9B/Sy1nVmFdBZWj+u2/02f69b0dHkdvASU09ODr/Y2Q9tT4OAvN5jcsvz7wVGamFPb
         XigcIHT1e628dpep0FOw1ODQOAfgptl/OWKryEInZJNnMVvF5LUXtDujRChHxFKua44U
         RMpgEJL5FgmS1XtkPT1QKJSrI3OPCWpZ3fXIa/C5xFNAWKeon/XGuD1afj27BycydENC
         FwrxiqsmEyUa/Ih+1ldqUvesEICdrkLr/IG76kBGdLTOzjHbUzNNs1k67FHJIl3cOH8x
         klkg==
X-Gm-Message-State: AOJu0YyTGWceicQAA26ILkcJpWX1O8QYL//yNtmw4bDgYcw/9lQWrcne
	Tm75LAGBCgsZGT7fnW7LRkrLzXhHOnnPT5nvdz3YuMBIVPUqwCtay+SU9KBWYlXE9xE=
X-Gm-Gg: Acq92OFJrNE0hP98m5ZZSahAhn4ch5yAZib96Kmf/xJZxigKMtv2QpORUgCmRfllp/Z
	R4TyV/YJFKEbjUHWjeO6xbimMqUe/5/F4AbIOHqGNzK9LRBIYQ3j7fjM8EiTeI1rYtdBJ80EHaL
	OiFFubLU/E/0fnEeR6RBxL1j9gTJ6AQqmDlho05+YyeEqFoq2ngL5Mo902bIMeHC9RoucRVaN7V
	Naz7QzyFCGsFtAvwrYLPKGqdONhy7QbR328kzJk48rZ6Vqj3bpPgvsmcQLg0TmXaJxp92Es5qr1
	Jl+nd0JvNBfvxPJoHFJ3Q33jVkk+FIrAT8zdkd0qkdjqIod7GpLuuriWh0ALgShu706Vd3zas23
	Hv6IJU7UwOmvRkzTOYz+KKPwJkcRmbjqZ/MiFJFnpNpZdXD09alqenlGY9NLPGzXvVm8dP/DWrK
	/1mQTP6hdRzIujil31LP/EJ0tRJRSWVvioWmIH3dYC4+ZK1UsgDxveaoJRI6Sx2y35B08sPQ==
X-Received: by 2002:a05:6870:d152:b0:434:72:28b9 with SMTP id 586e51a60fabf-440db49632amr2404230fac.7.1780499390454;
        Wed, 03 Jun 2026 08:09:50 -0700 (PDT)
Received: from bcodding.csb.hammerspace.com ([66.97.168.37])
        by smtp.gmail.com with ESMTPSA id 586e51a60fabf-440d84c0ce2sm2917634fac.16.2026.06.03.08.09.49
        (version=TLS1_3 cipher=TLS_AES_256_GCM_SHA384 bits=256/256);
        Wed, 03 Jun 2026 08:09:49 -0700 (PDT)
From: Benjamin Coddington <ben.coddington@hammerspace.com>
X-Google-Original-From: Benjamin Coddington <bcodding@hammerspace.com>
To: Chuck Lever <cel@kernel.org>,
	Jeff Layton <jlayton@kernel.org>,
	NeilBrown <neilb@ownmail.net>
Cc: linux-nfs@vger.kernel.org,
	Daire Byrne <daire@brahma.io>
Subject: [PATCH RFC 4/4] nfsd: key NFSv4.1 connections by clientid for fair queueing
Date: Wed,  3 Jun 2026 11:09:42 -0400
Message-ID: <5f3a6acbc4f5347ddc231d5ed33500128a85c547.1780498019.git.bcodding@hammerspace.com>
X-Mailer: git-send-email 2.53.0
In-Reply-To: <cover.1780498019.git.bcodding@hammerspace.com>
References: <cover.1780498019.git.bcodding@hammerspace.com>
Precedence: bulk
X-Mailing-List: linux-nfs@vger.kernel.org
List-Id: <linux-nfs.vger.kernel.org>
List-Subscribe: <mailto:linux-nfs+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:linux-nfs+unsubscribe@vger.kernel.org>
MIME-Version: 1.0
Content-Transfer-Encoding: 8bit

An NFSv4.1 client may bind several connections to its session.  Stamp
each such transport's fairness key with a value derived from the clientid
in nfsd4_init_conn(), so that all of a client's connections share one key
and the fair-queue dispatcher schedules them as a single client rather
than per transport.  A multi-connection v4.1 client is thereby held to
the same per-client share as a single-connection client.

Signed-off-by: Benjamin Coddington <bcodding@hammerspace.com>
Co-Authored-By: Claude Opus 4.8 <noreply@anthropic.com>
---
 fs/nfsd/nfs4state.c | 17 +++++++++++++++++
 1 file changed, 17 insertions(+)

diff --git a/fs/nfsd/nfs4state.c b/fs/nfsd/nfs4state.c
index 5982fc9eb6b1..52bd9bc5cdbd 100644
--- a/fs/nfsd/nfs4state.c
+++ b/fs/nfsd/nfs4state.c
@@ -2351,11 +2351,28 @@ static int nfsd4_register_conn(struct nfsd4_conn *conn)
 	return register_xpt_user(conn->cn_xprt, &conn->cn_xpt_user);
 }
 
+/*
+ * Derive the transport fairness key from the v4.1 clientid, so that all of a
+ * client's connections (bound to its session) share one key and the sunrpc
+ * fair-queue dispatcher schedules them as a single client rather than per
+ * transport.  cl_boot is the server's boot time and is effectively always
+ * nonzero, so this overrides the source-address default that
+ * svc_xprt_fairq_key() would otherwise use.
+ */
+static unsigned long nfsd4_fairq_key(const clientid_t *clid)
+{
+	u64 id = ((u64)clid->cl_boot << 32) | clid->cl_id;
+
+	return (unsigned long)(id ^ (id >> 32));
+}
+
 static void nfsd4_init_conn(struct svc_rqst *rqstp, struct nfsd4_conn *conn, struct nfsd4_session *ses)
 {
 	int ret;
 
 	nfsd4_hash_conn(conn, ses);
+	conn->cn_xprt->xpt_fairq_key =
+		nfsd4_fairq_key(&ses->se_client->cl_clientid);
 	ret = nfsd4_register_conn(conn);
 	if (ret)
 		/* oops; xprt is already down: */
-- 
2.53.0

