Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.remote-ip=209.85.208.97
ARC-Seal: i=1; d=subspace.kernel.org; s=arc20261015; a=rsa-sha256; cv=none;
	t=1793403901;
	b=QLYNsQB7ArQZAhme7jCWuxYoPVKPk8zUDsVi1rvN05X8aE+DVLZfZnxke9A0nxZDV4/e
	 Rm+GlcE7cve7I4undXXjYdUVMSP4s9zPDnMX1x1PlOj+rIzOh4MGddu8HZHVB1dFZ2b5h
	 zKMpwrWyjxdoqsgvU62NIDTQbGTyesqa2yWUND9D4oFXQ9SpcqWk77xW9wuvX6tctD92/
	 AyeWm8ETz7csUineWIEs8MWsMemYWHrFWSLQGrCsw8jjsOJFowgySWK1sJdI/LLEGvN8q
	 PJYhKqYeVHC7l5onPeshIPcKBNvjRBYIFMZL6eWIdC4k/DjdoHgx+6WdjNk6biSNxEw==
ARC-Message-Signature: i=1; d=subspace.kernel.org; s=arc20261015;
	a=rsa-sha256; c=relaxed/relaxed; t=1793403901;
	h=DMARC-Filter:Received:DKIM-Signature:X-Google-DKIM-Signature:
	 X-Gm-Message-State:X-Gm-Gg:X-Received:Received:X-Relaying-Domain:
	 Received:From:To:Cc:Subject:Date:Message-ID:X-Mailer:MIME-Version:
	 Content-Transfer-Encoding;
	bh=ENPGEJQjHDmi0YXc71Juxw0DF5443i7C7rtlAkvii2U=;
	b=5WdCpb3061OUtsf9VcCLUWKEHksG/B72R/QSlRk0McrhpYowCeFhW76bcpF0DpbqLZKq
	 7e8x5juPNAtNK4TR1ntzGw2oWbpiloi+fvZK+zrOQKVzM0dObS+B4JyO/rNESQ63VI1UT
	 pbpjRp4tt3mX00/tUwaS3AmU6cAzuE1UuKrwnRx1XhhhEs2NxK5y+D06hxYRwNEaoyVye
	 413nylkA+j05fNJSbvRk3KKvzIeF4GggMwsUUBEua9M50IfqVMtmT95cxBLcmNw6qzAIA
	 Nm9Y1wLdKWpYejJzWsgtA0X9dOJWHLXN2x71ehchdjrWNodDf97oVUJ7/iplp2n7hJg==
ARC-Authentication-Results: i=1; smtp.subspace.kernel.org; 
	dmarc=pass header.from=everpuredata.com;
	spf=pass smtp.mailfrom=everpuredata.com;
	arc=none smtp.remote-ip=209.85.208.97
Received: from mail-ed1-f97.google.com (mail-ed1-f97.google.com [209.85.208.97])
	(using TLSv1.3 with cipher TLS_AES_128_GCM_SHA256 (128/128 bits)
	 key-exchange X25519 server-signature ECDSA (prime256v1) server-digest SHA256)
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 69448606A31D
	for <linux-nfs@vger.kernel.org>; Fri, 30 Oct 2026 23:44:55 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.4.2 smtp.subspace.kernel.org 69448606A31D
Authentication-Results: smtp.subspace.kernel.org; dmarc=pass (p=reject dis=none) header.from=everpuredata.com
Authentication-Results: smtp.subspace.kernel.org; spf=pass smtp.mailfrom=everpuredata.com
Received: by mail-ed1-f97.google.com with SMTP id 4fb4d7f45d1cf-6b408f2d936so1615861a12.1
        for <linux-nfs@vger.kernel.org>; Fri, 30 Oct 2026 16:44:55 -0700 (PDT)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=everpuredata.com; s=google; t=1793403894; x=1794008694; darn=vger.kernel.org;
        h=content-transfer-encoding:mime-version:message-id:date:subject:cc
         :to:from:from:to:cc:subject:date:message-id:reply-to:content-type;
        bh=ENPGEJQjHDmi0YXc71Juxw0DF5443i7C7rtlAkvii2U=;
        b=ydriti7zC8uEtFrWzYDb1hmakiggIIPqyZubmQU3J5TGQfdMUBxqMCjS/7PGld049C
         PIJXQpd3EPFL36vZE6F2udfB1t05qSE+ovPBVmYlQrlHpSQ55Lsqa2MCmzqNPh/a80Ac
         BUiLE/kV6gr51kv4AuSQjItwP9IN+vcPj179bJjj0dKzPCU1B8GWZzM54JSsGvH/qm4l
         SodEgcZXYiC8TKZzUXknTkCF1YSVmFMZwymRrfo0CdcigMJnCjHY0Qdl20GhmviAsod1
         zr2WcqnCg9SM59uBUwjf/vujnxqU80D/Df9JZ3iYmi2S1rHJDtiKjxhgvKxkn7zkXpA7
         Fo7g==
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20260707; t=1793403894; x=1794008694;
        h=content-transfer-encoding:mime-version:message-id:date:subject:cc
         :to:from:x-gm-gg:x-gm-message-state:from:to:cc:subject:date
         :message-id:reply-to:content-type;
        bh=ENPGEJQjHDmi0YXc71Juxw0DF5443i7C7rtlAkvii2U=;
        b=HhcBx8By5kpopva53aenQsjncUTT/3BZWLANMX4LrwEyo89SE9R1SIzLPEPhDl3lrs
         LjgDRMA/ZO6y4tp6fetAVvCAD/EjCbjqu7NfJElqMXzUDHRKVYDNxfpxud5KKoAh0cM/
         y1Ry9j7PZBPDiRWmRGtGIW3+urMuK7NYaw//sxFvLpP+zzL4a5UPhZ+Kfg8mb4yln3P/
         WsalOuXJx9pQDgts5XRK6hkXkVHCKTJUhbmsN3AVaTQn+Xc4mKlfpt5in89sEDubLC1U
         p0VvQXN1KT4GjrF3N9MoPJTzGW/i2LXaTabXWKsnZgrC6kkrE3nGJhSHLU4S3Td/gyXp
         l0oQ==
X-Gm-Message-State: AFq9FYJ5clzPE7P0FUgR20sNdo5yhpsd9oXhz+rn2FeZIMtQbD7XKsKf
	+mf7vIsCGllgZ8FHjFwjQvIfzl62vnl7HBNm+izovR+H7Ca1+XobR1EBsevQpIfVZZl1swCrzWj
	tYERAv04kL2c6Pck3ucPVhrcBpfJLRfKZ7sq4
X-Gm-Gg: AYBFou1mOt+zQEeE+y3k1eV25UrsSx6DLQegZ7D27gViqGYAWUE+iMT+9otbJi7GnzE
	6qomxiApuLEQrgHkYh0JyEGNbVyMgGrqttJOE1Twp+013g1tAKFnJV9IdlWTdEmpDTkZ3eUb/Fd
	dJ6GNCFCd5FTOSS5YjnK+bu9YOrDR8FsHRC/mfErc+/Hf213z1rPL+ny3AMTqWVruwcp9/5raIc
	IlMC3RDFHdRCDSdIyLusRTbeC0WEJKXWl5z0iBehAgLaUFyBShRmY6rKTY9neJH2U1Lh2fL+OZ1
	z3HRuFmyLjE+1u+9tvIQ58wgMkC7pPs9V1DmB9qKFtTmLfFZsLWYLgEPz/eSkSmbfxRHv4Zpkx8
	RYC1+GpoRNCxazQ5EWAVzCXcyNnPQVi2D9WW5ho0=
X-Received: by 2002:aa7:c70b:0:b0:6aa:f14f:5571 with SMTP id 4fb4d7f45d1cf-6b4d5ee0692mr2076001a12.45.1793403893737;
        Fri, 30 Oct 2026 16:44:53 -0700 (PDT)
Received: from c14-smtp-2023.dev.purestorage.com ([208.88.158.129])
        by smtp-relay.gmail.com with ESMTPS id 4fb4d7f45d1cf-6b4ec9f672esm196010a12.14.2026.10.30.16.44.53
        (version=TLS1_3 cipher=TLS_AES_256_GCM_SHA384 bits=256/256);
        Fri, 30 Oct 2026 16:44:53 -0700 (PDT)
X-Relaying-Domain: everpuredata.com
Received: from irdv-tmenninger.dev.purestorage.com (irdv-tmenninger.dev.purestorage.com [10.32.149.15])
	by c14-smtp-2023.dev.purestorage.com (Postfix) with ESMTPS id 403993404F8;
	Fri, 30 Oct 2026 16:44:22 -0700 (PDT)
From: Tim Menninger <tmenninger@everpuredata.com>
To: Trond Myklebust <trondmy@kernel.org>,
	Anna Schumaker <anna@kernel.org>
Cc: linux-nfs@vger.kernel.org,
	linux-kernel@vger.kernel.org,
	stable@vger.kernel.org,
	Jon Curley <jcurley@everpuredata.com>,
	Eric Badger <ebadger@everpuredata.com>
Subject: [PATCH] NFSv4: Prevent indefinite waits for out-of-order OPEN stateids
Date: Fri, 30 Oct 2026 23:44:22 +0000
Message-ID: <20261030234422.2367263-1-tmenninger@everpuredata.com>
X-Mailer: git-send-email 2.53.0
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

When processing an out-of-order OPEN stateid on an NFSv4.1 or later
mount, nfs_set_open_stateid_locked() waits for stateid updates to be
processed in order. A five-second timeout is intended to prevent
indefinite waits when preceding updates never arrive.

However, each iteration calls schedule_timeout() with a fresh
five-second timeout. An update to the shared open state can wake the
caller without satisfying its ordering check. The remaining timeout
is then discarded, and the next iteration starts another full wait.

Under sustained concurrent OPEN/CLOSE activity on the same open state,
repeated wakeups can prevent the timeout from ever expiring. Some
tasks can remain stuck in update_open_stateid() while others continue
making progress.

Compute a single deadline on entry and pass only the remaining time
to schedule_timeout(). Once the deadline expires, take the existing
timeout path rather than starting another wait. This prevents
wakeups from extending the wait indefinitely.

Observed on Linux 6.8.0 and reproduced on 7.3.0 with 96 concurrent
O_RDWR|O_TRUNC open/close loops on one NFSv4.1/TCP file (nconnect=16).
Ten workers made no progress for over 300 seconds while others ran.
With the fix, all workers resumed after transient stalls.

Fixes: c9399f21c215 ("NFSv4: Fix OPEN / CLOSE race")
Cc: stable@vger.kernel.org
Signed-off-by: Tim Menninger <tmenninger@everpuredata.com>
---
 fs/nfs/nfs4proc.c | 5 ++++-
 1 file changed, 4 insertions(+), 1 deletion(-)

diff --git a/fs/nfs/nfs4proc.c b/fs/nfs/nfs4proc.c
index e1018b03c1cbd..f2cb8e788c017 100644
--- a/fs/nfs/nfs4proc.c
+++ b/fs/nfs/nfs4proc.c
@@ -1722,6 +1722,8 @@ static void nfs_set_open_stateid_locked(struct nfs4_state *state,
 {
 	DEFINE_WAIT(wait);
 	int status = 0;
+	unsigned long deadline = jiffies + 5 * HZ;
+	signed long remaining;
 	for (;;) {
 
 		if (nfs_stateid_is_sequential(state, stateid))
@@ -1756,7 +1758,8 @@ static void nfs_set_open_stateid_locked(struct nfs4_state *state,
 
 		if (!fatal_signal_pending(current) &&
 		    !nfs_current_task_exiting()) {
-			if (schedule_timeout(5*HZ) == 0)
+			remaining = (long)(deadline - jiffies);
+			if (remaining <= 0 || schedule_timeout(remaining) == 0)
 				status = -EAGAIN;
 			else
 				status = 0;
-- 
2.53.0

