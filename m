Authentication-Results: smtp.subspace.kernel.org; arc=pass header.oldest-pass=0 smtp.remote-ip=209.85.167.48
ARC-Seal: i=2; d=subspace.kernel.org; s=arc20261015; a=rsa-sha256; cv=pass;
	t=1794031567;
	b=kKQfJAXZaedsX6dGU8YGL9rbp+w8fgzXdzivupRGnkXGnKWcmGAv3cPoMxNz0et51GPH
	 DWYXBWySNdUfnXZmSd3x4GiyP+9epQNpKWHZshkmY0Piqcf4Pv2db7+rgMnMRymiAZ79H
	 KtFcWOXGw7cPmr+xSqErCnkCRw2z13lBxQoBRsri8jgSJlxSUamnrtCktny8DkKl4W++O
	 39WBIO6Yp7dgYb7VstuzZ7SWh2tK4IGK/E3DyW7u5kiuCh4+bAcP7BWB0nYNNmrPhJ7Qz
	 dDbgTF/hwW/G1HbNJMthHnqon7btI8Y2YSH1kWNwtqDu8ZJxVb9ZMDmged/0pPmbIlA==
ARC-Message-Signature: i=2; d=subspace.kernel.org; s=arc20261015;
	a=rsa-sha256; c=relaxed/relaxed; t=1794031567;
	h=DMARC-Filter:Received:DKIM-Signature:X-Google-DKIM-Signature:
	 X-Gm-Message-State:X-Gm-Gg:X-Received:Received:Received:From:
	 MIME-Version:Date:X-Gm-Features:Message-ID:Subject:To:Cc:
	 Content-Type;
	bh=Zv9Wwix0Wl9ji6g1q9+egVqK021IPU9Yv4uSbk/ntw4=;
	b=s0DCTsLE/9dr6fj3j/saDb3j7gDGQh2zhf0E101Y564e1/SMoTKFmwIkrwEcu/CzQexG
	 EkLrO2hG7tE00niMcRADNggDfP7zjt60BiWQkIr16tIPYTy/ekmCbfPte3TsJq4t9PiD3
	 Wax02pts6OXXoko+0SCXXI3nDxsPAi9PAws4d8eyWgpdKVVoRCj6ajQp8r7gRRkHTYA5h
	 U2nxNJYQ6jK1N5LbdfOzy4mZkecvuvkbTpKNyjXW9z/XuUcRwBWRvyhU7YW1Bcm64EI9e
	 /hCSs3UjD8brU5yyJKSMu567EyGxMhXCNNp/bNYQtQlUaYEkf5WurJfywzMmH9Rk4Cg==
ARC-Authentication-Results: i=2; smtp.subspace.kernel.org; 
	dmarc=pass header.from=gmail.com;
	spf=pass smtp.mailfrom=gmail.com;
	dkim=pass header.d=gmail.com header.i=@gmail.com header.a=rsa-sha256 header.s=20260707 header.b=FRSC5N9H;
	arc=pass header.oldest-pass=0 smtp.remote-ip=209.85.167.48
Received: from mail-lf1-f48.google.com (mail-lf1-f48.google.com [209.85.167.48])
	(using TLSv1.3 with cipher TLS_AES_128_GCM_SHA256 (128/128 bits)
	 key-exchange X25519 server-signature ECDSA (prime256v1) server-digest SHA256)
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id F2375606A32C
	for <linux-nfs@vger.kernel.org>; Sat,  7 Nov 2026 06:06:06 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.4.2 smtp.subspace.kernel.org F2375606A32C
Authentication-Results: smtp.subspace.kernel.org; dmarc=pass (p=none dis=none) header.from=gmail.com
Authentication-Results: smtp.subspace.kernel.org; spf=pass smtp.mailfrom=gmail.com
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=gmail.com header.i=@gmail.com header.a=rsa-sha256 header.s=20260707 header.b=FRSC5N9H
Received: by mail-lf1-f48.google.com with SMTP id 2adb3069b0e04-5be502e1adaso144419e87.0
        for <linux-nfs@vger.kernel.org>; Fri, 06 Nov 2026 22:06:06 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1794031564; cv=none;
        d=google.com; s=arc-20260327;
        b=eraI+qXjMLNoj+bdQxVKEt8tQuanoVO9sM3OmLrHSQn57owz1q6n8RqTkoQiTuDHki
         ECM2yonnu+c5BQhi+VXn1NHb14PRxMerejPMum+hBRAMQqDWGdqwkJgqMGYMSGtJGucw
         SSy5UuLQ3HJF76+JWiNlKY3WidCOQaHv1EgRN3y/dhW6IXxS0gEgpRpt5m0n7YRp9u++
         FThLhG65oY4p+0GkP6qaGy/A5Z7jkii3JABS2Bkq9Ae1EV7wxvPBuEFDSFaEKvTrdoQA
         Kr3v1KV7b81ej3jm5UTLaaPTGmIexayc1nZcNjUqWIkzFwtChs2tUwoaifhCHO0VsSor
         Ku7w==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20260327;
        h=cc:to:subject:message-id:date:mime-version:from:dkim-signature;
        bh=Zv9Wwix0Wl9ji6g1q9+egVqK021IPU9Yv4uSbk/ntw4=;
        fh=ymfhShoCUKxLn7czh2H3/oZetPTS67X53Vhfwc0U5jI=;
        b=FXFU3+oEWmBd2qGFPa13c0SPdobaKpYINPLQB/npLCFmEyzQI7HLsSQwJV+Tw5BaM7
         AnPU8D6m34jd++Wcc7eu6ZevlnCszP4O46TwO6BFF+jES9++bCr304zd7fiIqCU6lMgp
         S5TFPNQCs8sclHzq4mYUOsD1dKO8MTW1MjTU0LqDBdsnOsRsQaaSdLY8GCu6ClL9bgEW
         YwFQv3Oh6ZfCzsh88URUYCLF50/N0FQmonQTv658ide4AT18FUOFxf9kmj7G5XVE3lEq
         l3weZDyq3FlUdAu9Vc3Bk4mSRDe+4zG5VQUDRK/Em9zk2t/AOufp/njhI6P8ThzZr4vM
         Pxsw==;
        darn=vger.kernel.org
ARC-Authentication-Results: i=1; mx.google.com; arc=none
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=gmail.com; s=20260707; t=1794031564; x=1794636364; darn=vger.kernel.org;
        h=content-type:cc:to:subject:message-id:date:mime-version:from:from
         :to:cc:subject:date:message-id:reply-to:content-type;
        bh=Zv9Wwix0Wl9ji6g1q9+egVqK021IPU9Yv4uSbk/ntw4=;
        b=FRSC5N9Hgw8OXO9geWOY+oxpQxb7xzncCii6Xjh+XDOJINUou+ytjFWRECxKmSNEDt
         atv1lOUugfIuST/z3cuyuu/foXf6H/brEceojhSNPDrOPq1uypZAiHxCmc2TDuZEF2/F
         GPFs3t0ZGv4W+pEJAmYQ9fOdQoo892WNeu1FWVgTxLJqK9sVjUrpcpoZmOcJywR+28Tk
         xaEYef+2kxg11r3wrW+vkRkt3BUt058bKyVL/tt2yz3N4mQbTiNQRReISBGRixRVSrmo
         Br10W1L5KKWSOqd5IPaQ2WveD74DQSYEMhLPuygo8PgUhX+9Ith8KINFaAA/rsZj/W67
         NKnQ==
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20260707; t=1794031564; x=1794636364;
        h=content-type:cc:to:subject:message-id:date:mime-version:from
         :x-gm-gg:x-gm-message-state:from:to:cc:subject:date:message-id
         :reply-to:content-type;
        bh=Zv9Wwix0Wl9ji6g1q9+egVqK021IPU9Yv4uSbk/ntw4=;
        b=qAl4m3v+YrGHZd5YoBpbn3GE0EXI/qYbavGH8Nl4XRXKS1lVLcpCDeGFTmsT7OIc0I
         6dPuN4LjQaJJi6WWdRFXuLzrGtK7B9Z9H8Tv/NootnCGrbxuVCkgcum88Ny1tTvYo4Od
         3BfEVi+h/vZhqk/6qxKQEdg7YX35bVgY6RKmrg7Hd8G87CqmszWIvu/mBdKgEgTLzmHK
         VGyjfKFFEA2dJsn5YDKMextz0qZ4rd1HcV6FXHIj4NK0Eb+BG4K46Qhwa6sO/+OSxCQO
         n4qQTF+ITbG/bCCQBnqDuYQRh9NCAtP57wDq/PKkV1WDRSRwYZUEN2FB+B7dsa6ZVuq/
         HMaA==
X-Gm-Message-State: APuU4Z+g8KVO3s+kJnWUiVEG2+PiU7cujid8lMftSX/1xaWyNdaDw+2p
	E4+TieqjtELb29tI/WFmKqUOiakP81OrcaN1lOZ+DSNiip+O9kehII6asbLjCG/TBqM4JDiOYNB
	ef691n6ZXkDA4lXxxangp89pSwhYeA7t69S+7
X-Gm-Gg: AYBFou0BeoFzrCBheLM9j/9KxuKI0qx2OxL2e/unMnZLCUO3HFGOBhDCvkpjMLvnH4q
	6BODP2eM6Y/t2FYB0E+NMUQ/lNhEE9nsfonHzhc9AKqkzdbx7HobI815EAg0t2db07Fu8XSDw6h
	UFSDuj1gVFr2bYqD+tyCTZKiGU2+vQMNZA1NRosk4Mm3oUZf09aibctzxvi6/c5FYRaOX1z0zmF
	dLLUAyrcma+hRiOjI0WMUyPW36XE7+Uj0wvD+h7USQ/MBgkiUhBMeh8HoNUd+Lh7BuVZH37KiFT
	waGhDt6RhJDZxg5NhzgS1JpniD/isO8LfE+6tD+9TDTOpTbBVAY31aVPlGVhg/UtUD67SHeraXf
	XhfEr6b288Mn4sfDkd7H5oJN1FAgmBUE+htT5rsxW31cuCmvm0qaFnG1k
X-Received: by 2002:a05:6512:1156:b0:5bf:e6a1:3115 with SMTP id
 2adb3069b0e04-5c00394e554mr1649938e87.2.1794031564200; Fri, 06 Nov 2026
 22:06:04 -0800 (PST)
Received: from 779715102257 named unknown by gmailapi.google.com with
 HTTPREST; Fri, 6 Nov 2026 22:06:03 -0800
Received: from 779715102257 named unknown by gmailapi.google.com with
 HTTPREST; Fri, 6 Nov 2026 22:03:03 -0800
From: =?UTF-8?B?7YyM656R7IOI?= <lhjnano@gmail.com>
X-Mailing-List: linux-nfs@vger.kernel.org
List-Id: <linux-nfs.vger.kernel.org>
List-Post: <mailto:linux-nfs@vger.kernel.org>
List-Help: <mailto:linux-nfs+help@vger.kernel.org>
List-Subscribe: <mailto:linux-nfs+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:linux-nfs+unsubscribe@vger.kernel.org>
List-Owner: <mailto:linux-nfs+owner@vger.kernel.org>
Precedence: list
MIME-Version: 1.0
Date: Fri, 6 Nov 2026 22:06:03 -0800
X-Gm-Features: AclHuK-HJ-T3Qt48WRvYwHF-g2wTD3rKc5L8toXrVwzv19ILbU7Pxf4OwXCYS1I
Message-ID: <CAN+dWLYt7=WDO-wGHt5_1K2JcqDgrHs1bX2WBOvaTt-PFi1meg@mail.gmail.com>
Subject: [PATCH nfs-utils] nfsdcld: signal readiness only after the pipefs
 watch is installed
To: SteveD@redhat.com
Cc: linux-nfs@vger.kernel.org, cel@kernel.org
Content-Type: text/plain; charset="UTF-8"

nfsdcld daemonizes with daemon(0, 0) and nfsdcld.service is Type=forking,
so systemd considers the service started when the daemonizing parent exits.
The child, however, only installs its inotify watch on the rpc_pipefs
directory much later, after the sqlite database is prepared and
cld_pipe_init() runs. Until the watch is installed, nfsdcld cannot notice
that the kernel has (re)created the cld pipe.

nfs-server.service orders itself After=nfsdcld.service, but that ordering
is meaningless with Type=forking: on a busy boot or a restart storm,
systemd starts nfsd while nfsdcld is still doing schema migration or legacy
record import, and the kernel's one second wait for nfsdcld to open the pipe
(see nfs4recover.c:nfsd4_cld_tracking_init()) can expire unused. An observed
instance of this race took an NFS server down for 44 minutes when nothing
restarted the failed nfsd.

Fix by converting nfsdcld to the daemon_init()/daemon_ready() helpers used
by the other nfs-utils daemons: the parent no longer exits until the child
signals, and the child signals right after cld_pipe_init() has installed
the inotify watch. With that, the existing After=nfsdcld.service ordering
means what it claims, and the kernel's one second window is sufficient.

The event base is now created after daemonizing: daemon_init() renumbers fds
(its status pipe takes fd 3) and would otherwise clobber the epoll descriptor
created before daemonizing. The event base allocation failure is now reported
through xlog() instead of fprintf(stderr): stderr is /dev/null after
daemonizing, so an fprintf() message would be lost, while xlog() routes it to
the syslog.

Suggested-by: Chuck Lever <cel@kernel.org>
Link: https://lore.kernel.org/linux-nfs/20261015114755.33331-1-lhjnano@gmail.com/
Signed-off-by: HeonJe Lee <lhjnano@gmail.com>
---
Hi Steve,

Chuck Lever suggested on linux-nfs that I direct this patch to you as
the maintainer of nfs-utils. The thread originated from an NFSD startup
race investigation.

 utils/nfsdcld/nfsdcld.c | 22 +++++++++++-----------
 1 file changed, 11 insertions(+), 11 deletions(-)

diff --git a/utils/nfsdcld/nfsdcld.c b/utils/nfsdcld/nfsdcld.c
index 8551dc9..772cf31 100644
--- a/utils/nfsdcld/nfsdcld.c
+++ b/utils/nfsdcld/nfsdcld.c
@@ -819,12 +819,6 @@ main(int argc, char **argv)
 		return 1;
 	}

-	evbase = event_base_new();
-	if (evbase == NULL) {
-		fprintf(stderr, "%s: unable to allocate event base.\n", argv[0]);
-		free(progname);
-		return 1;
-	}
 	xlog_syslog(0);
 	xlog_stderr(1);

@@ -866,14 +860,18 @@ main(int argc, char **argv)

 	strlcat(pipepath, DEFAULT_CLD_PATH, sizeof(pipepath));
 	xlog_open(progname);
+	daemon_init(foreground);
 	if (!foreground) {
 		xlog_syslog(1);
 		xlog_stderr(0);
-		rc = daemon(0, 0);
-		if (rc) {
-			xlog(L_ERROR, "Unable to daemonize: %m");
-			goto out;
-		}
+	}
+
+	/* daemon_init() renumbers fds and would clobber the epoll fd. */
+	evbase = event_base_new();
+	if (evbase == NULL) {
+		xlog(L_ERROR, "unable to allocate event base.");
+		free(progname);
+		return 1;
 	}

 	/* drop all capabilities */
@@ -925,6 +923,8 @@ main(int argc, char **argv)
 	signal(SIGINT, sig_die);
 	signal(SIGTERM, sig_die);

+	daemon_ready();
+
 	xlog(D_GENERAL, "%s: Starting event dispatch handler.", __func__);
 	rc = event_base_dispatch(evbase);
 	if (rc < 0)
-- 
2.34.1
