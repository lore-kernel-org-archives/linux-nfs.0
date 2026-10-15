Received: from mail-pf1-f172.google.com (mail-pf1-f172.google.com [209.85.210.172])
	(using TLSv1.2 with cipher ECDHE-RSA-AES128-GCM-SHA256 (128/128 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 050EA277C96
	for <linux-nfs@vger.kernel.org>; Thu, 15 Oct 2026 11:48:01 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=209.85.210.172
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1792064883; cv=none; b=TS82Ea8XOMiSIywMkjWo7nXVESVBmdDyHQq+o3UpsASqVNbO5Dh/KQO98jH6Inq9f+cKq5seFdbJNsNFKR65fIuzBbGO4co8mVwtnRWNABAOBcT3+dmciAoMjbQZLTHphCvDura8rT0Xgu+W/TbKRgp13xR1RotLtkk7av6NMRU=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1792064883; c=relaxed/simple;
	bh=fCbsQRLTJrXSvxnSQbdF6RSD4ux4mk9s+xNuvq9pRHA=;
	h=From:To:Cc:Subject:Date:Message-Id:MIME-Version; b=EwrBY/PoVIry3DBGkRFdLTOTvE/qmq1GN8UHglqHzeSTCU8NwTpFYyi13XY1DpgczBVbbbsMuYp9qk37aefMSsvSBjJe1VUoIHVLBWub7vAjuLDi8eQD7e2mzFYs0g5yh74dGEXddNkvtJv5WfwKR18Gq8cCdUaMni4ptudXoi0=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dmarc=pass (p=none dis=none) header.from=gmail.com; spf=pass smtp.mailfrom=gmail.com; dkim=pass (2048-bit key) header.d=gmail.com header.i=@gmail.com header.b=RN2G7p/J; arc=none smtp.client-ip=209.85.210.172
Authentication-Results: smtp.subspace.kernel.org; dmarc=pass (p=none dis=none) header.from=gmail.com
Authentication-Results: smtp.subspace.kernel.org; spf=pass smtp.mailfrom=gmail.com
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=gmail.com header.i=@gmail.com header.b="RN2G7p/J"
Received: by mail-pf1-f172.google.com with SMTP id d2e1a72fcca58-84e4e98d2cfso109602b3a.0
        for <linux-nfs@vger.kernel.org>; Thu, 15 Oct 2026 04:48:01 -0700 (PDT)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=gmail.com; s=20251104; t=1792064881; x=1792669681; darn=vger.kernel.org;
        h=content-transfer-encoding:mime-version:message-id:date:subject:cc
         :to:from:from:to:cc:subject:date:message-id:reply-to:content-type;
        bh=7I/fqu+vb667av4ul/9d28DJ7taixwlUrdvqRPT65yc=;
        b=RN2G7p/Jk0p1xXpHf+OyGXhyJMRu/INP1PBXu+LWOch/GJrJlJBy6puAFwBSdAU0/5
         HLa3cs/MPYxI/iV/3ppRPqHR5Zi+eaCLYu2I2JSlOt8f1pgWR5a0Eyv9lbvgBYSQEQcJ
         kEZJb+LCxqs+mw/x70WR661qLzxwtc5jAcImE8r5MTV6mRQj6I4wto0a70LgY2oNuFiM
         GbdMei09U9zzTcY4/aha+cbMHThvvwYQRk5/xYucE/6wgtGi9fP0P0JcyADMK4oEzeEO
         8N9PwvTlqhc+k2jMqHkGQjl6XvisO7bvlTDfFDmNQ0n8JeWdQgLpavJ9FYT7ZCL0vfgk
         lIbw==
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20260707; t=1792064881; x=1792669681;
        h=content-transfer-encoding:mime-version:message-id:date:subject:cc
         :to:from:x-gm-gg:x-gm-message-state:from:to:cc:subject:date
         :message-id:reply-to:content-type;
        bh=7I/fqu+vb667av4ul/9d28DJ7taixwlUrdvqRPT65yc=;
        b=2qlPxNQqLZWYudj4gBTPGQ9chr5IcoEX8QaFbuorviVe8egW5T1AD5esAoxcYSrXXa
         z+RqhjCx6bahPxbpFTOVX/coxRmzqc3sKZGrMxBrEa8ZP09A6FgZGmFzUa9hmsniMtWO
         5rGvCGP6pbF9zv3pMytLYZL6rAoj3eP+uC6MPF4f/mjnYPn+JYuK6s5UJcdugJkAn25O
         6Ims95IKDIHlPsx0aE18hFpUkdzKvPEQJcbjxVcozITedcVTHe+JKyQU7CBdS9CMaW36
         ohjI2b1H2XvimzSScS6hczxFch56V3PvAFz3sBwBprjIEfCe0iiOGKewz/j6PhDzI2wj
         M0+Q==
X-Gm-Message-State: AFq9FYI4CNGzZQGevEFjT0yyALccZMAUPSTuqB5oDLbgAR+J+nSC1AVs
	xGc3osF7puG8mfOhmnaNdC0ogSVryAl7nL844X+hBeEluKUxSOUdTT/J84BkqKrCTjQ=
X-Gm-Gg: AYBFou2RAHmt57fyqwdj8sy3uU0F7m38Zok+Gl0gq5Ish6HoLWPVsBAczWGEBfE2Zc6
	rPAL25Aoq+CoJWy526cBDvEV5knYTRw1XCoVwU8fUKVs6NGNDidQYNXtNZn/9f00bOaon1POF3z
	DounUh6DHLupo1cEQuT0K3bKRJApgAPGiIMQBk33VDvnj/pX76fKsiADp/lhgAmvnuOKvKpKc4U
	sSVxOzupJVvJM0S/HT6++efTQgerhMx2QUJegHQUDPDCPvgLlZurXSQ7+/KmMqjLawSUq5DK8vd
	ubjV95yool6UeG56nTGKSzphnypzdaDmMXQulax6nEe36xmg3Ph2BnEEHoWN0NTKpBkWLBdTWv5
	U/Z5kEMIJ4lGAOQDD853mloO+efOqbQYj3qDtMwoYjc3xO79gMytS/GmPWtgKjwGZba/2SFA3SH
	HUOrtIgRFFr13FHQwe+Dz+AamRZ69DGO5wApmYaswz6u33EiZrww0wwqBAYdJSfxjgWcXlqiJ0v
	XoH1G8zBrPI69kYB4c=
X-Received: by 2002:a05:6a00:9a9:b0:89e:37c3:1fe9 with SMTP id d2e1a72fcca58-89e37c32a2fmr4549513b3a.0.1792064881150;
        Thu, 15 Oct 2026 04:48:01 -0700 (PDT)
Received: from localhost.localdomain ([112.220.91.130])
        by smtp.gmail.com with ESMTPSA id d2e1a72fcca58-89d804d1c10sm2263737b3a.35.2026.10.15.04.47.58
        (version=TLS1_3 cipher=TLS_AES_256_GCM_SHA384 bits=256/256);
        Thu, 15 Oct 2026 04:48:00 -0700 (PDT)
From: HeonJe Lee <lhjnano@gmail.com>
To: linux-nfs@vger.kernel.org
Cc: cel@kernel.org,
	jlayton@kernel.org,
	HeonJe Lee <lhjnano@gmail.com>
Subject: [PATCH] NFSD: wait for nfsdcld to open the cld pipe
Date: Thu, 15 Oct 2026 20:47:55 +0900
Message-Id: <20261015114755.33331-1-lhjnano@gmail.com>
X-Mailer: git-send-email 2.34.1
Precedence: bulk
X-Mailing-List: linux-nfs@vger.kernel.org
List-Id: <linux-nfs.vger.kernel.org>
List-Subscribe: <mailto:linux-nfs+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:linux-nfs+unsubscribe@vger.kernel.org>
MIME-Version: 1.0
Content-Transfer-Encoding: 8bit

When nfsd starts, nfsd4_cld_tracking_init() waits up to one second
for nfsdcld to open the freshly created cld pipe and fails the
entire nfsd startup if it does not. nfsdcld is the only supported
client tracking backend, so a slow daemon takes NFS down entirely.
In the field this was observed as a 44 minute outage after nfsd
restarted alongside twenty plus other services.

The cld pipe queues upcalls for late readers
(RPC_PIPE_WAIT_FOR_OPEN). Drop the cld_running() pre-check and let
the GetVersion upcall sit in the queue: nfsdcld picks it up as soon
as it opens the pipe, and the 30 second rpc_pipefs queue timeout
purges it with -ETIMEDOUT if the daemon never shows up. A missing
nfsdcld now delays nfsd start by up to 30 seconds before failing,
instead of failing outright at one second.

Also stop queueing a GraceStart upcall after GetVersion has timed
out; that would just stack another 30 second wait.

No single Fixes: tag applies: the one second wait came in
commit 869216075b5d ("nfsd: re-order client tracking method
selection") when fallback methods still existed, and the last
fallback method was removed by the still-unreleased
commit 0dc9d8fd2952 ("nfsd: remove CONFIG_NFSD_LEGACY_CLIENT_TRACKING"),
so no LTS backport is required yet.

Signed-off-by: HeonJe Lee <lhjnano@gmail.com>
---
 fs/nfsd/nfs4recover.c | 31 ++++++-------------------------
 1 file changed, 6 insertions(+), 25 deletions(-)

diff --git a/fs/nfsd/nfs4recover.c b/fs/nfsd/nfs4recover.c
index cd057a722..5592218ae 100644
--- a/fs/nfsd/nfs4recover.c
+++ b/fs/nfsd/nfs4recover.c
@@ -828,15 +828,6 @@ nfs4_cld_state_shutdown(struct net *net)
 	kfree(nn->reclaim_str_hashtbl);
 }
 
-static bool
-cld_running(struct nfsd_net *nn)
-{
-	struct cld_net *cn = nn->cld_net;
-	struct rpc_pipe *pipe = cn->cn_pipe;
-
-	return pipe->nreaders || pipe->nwriters;
-}
-
 static int
 nfsd4_cld_get_version(struct nfsd_net *nn)
 {
@@ -889,8 +880,6 @@ nfsd4_cld_tracking_init(struct net *net)
 {
 	int status;
 	struct nfsd_net *nn = net_generic(net, nfsd_net_id);
-	bool running;
-	int retries = 10;
 
 	status = nfs4_cld_state_init(net);
 	if (status)
@@ -900,23 +889,15 @@ nfsd4_cld_tracking_init(struct net *net)
 	if (status)
 		goto err_shutdown;
 
-	/*
-	 * rpc pipe upcalls take 30 seconds to time out, so do not queue an
-	 * upcall until nfsdcld has opened the pipefs file just created.
-	 * nfsdcld should already be running before nfsd is started, so
-	 * this wait is short.
-	 */
-	while (!(running = cld_running(nn)) && retries--)
-		msleep(100);
-
-	if (!running) {
-		status = -ETIMEDOUT;
-		goto err_remove;
-	}
-
 	status = nfsd4_cld_get_version(nn);
 	if (status == -EOPNOTSUPP)
 		pr_warn("NFSD: nfsdcld GetVersion upcall failed. Please upgrade nfsdcld.\n");
+	else if (status) {
+		/* No one answered the GetVersion upcall (e.g. the rpc_pipefs
+		 * queue timeout purged it): don't stack GraceStart on top.
+		 */
+		goto err_remove;
+	}
 
 	status = nfsd4_cld_grace_start(nn);
 	if (status) {
-- 
2.34.1

