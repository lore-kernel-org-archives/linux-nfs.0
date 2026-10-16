Received: from mail-yx1-f49.google.com (mail-yx1-f49.google.com [74.125.224.49])
	(using TLSv1.2 with cipher ECDHE-RSA-AES128-GCM-SHA256 (128/128 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 3753B2F260F
	for <linux-nfs@vger.kernel.org>; Fri, 16 Oct 2026 15:44:38 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=74.125.224.49
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1792165479; cv=none; b=SI/Me0t40KLHfaNS+rKmbUNOaa1YCfeeOMuLqTkky0DuxbytzXqDZcCpkNRpoEi+5G/XJO3XSW6SAtt2OyXzStE9Hpg4h/q0EwjIbweXbiACdC0yMONa4FtWajL3quxcj0KXiEilP06r5fTfpd95CSiwUcEboa7u4utv0pZJErQ=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1792165479; c=relaxed/simple;
	bh=d6QUxmjmsFNQ4xfR0Br4ChhLaqG5Ifp8uMokwFgSiwU=;
	h=From:To:Cc:Subject:Date:Message-Id:In-Reply-To:References:
	 MIME-Version; b=qSaFWnuo7ZeTcepW15Wr8E2bqTShGTSRiVI7Z5xeiPJhsmpIs88JTkPLHeqTdcpd9h1GD4my53XxDS/K/kuSkn/4ILjiq4os48GX8VvDJv6QyncJv3bBQcgr/K+Wx6sUGajhHRV6PFcZhdj75RjDcbsWo4qZmSxL7P0IAQDk6hE=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dmarc=pass (p=none dis=none) header.from=gmail.com; spf=pass smtp.mailfrom=gmail.com; dkim=pass (2048-bit key) header.d=gmail.com header.i=@gmail.com header.b=iEQVDNiR; arc=none smtp.client-ip=74.125.224.49
Authentication-Results: smtp.subspace.kernel.org; dmarc=pass (p=none dis=none) header.from=gmail.com
Authentication-Results: smtp.subspace.kernel.org; spf=pass smtp.mailfrom=gmail.com
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=gmail.com header.i=@gmail.com header.b="iEQVDNiR"
Received: by mail-yx1-f49.google.com with SMTP id 956f58d0204a3-6790c2eb033so21079d50.3
        for <linux-nfs@vger.kernel.org>; Fri, 16 Oct 2026 08:44:38 -0700 (PDT)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=gmail.com; s=20251104; t=1792165477; x=1792770277; darn=vger.kernel.org;
        h=content-transfer-encoding:mime-version:references:in-reply-to
         :message-id:date:subject:cc:to:from:from:to:cc:subject:date
         :message-id:reply-to:content-type;
        bh=GfV/mSw0ValKs2Xbc1n/YMtaANNV1FAKPqUAf4xYsdQ=;
        b=iEQVDNiRoV5uDCGOApRffGMD2Vc4f432sAKQK+P9zaYvVpnuA64QaUNwkz9YzuUMI0
         UAPy2NKhNSapvdFNQXmpkyp2t7GXkqoZT23EPlJfdv8CAqdjRTLX5c73EfhOgZBjryZ+
         HjnpSiUSyLI+jorMu2uv4kPtX2cYh6Nrdf9i/m9RfCn8+hDtuG0/9a3TmNnLNVPh4A+8
         tS5xQ6fI1DgCbSHkVbRS0R1CBTOfsogvdHpFKoHd8iw91gyEfAF4y+sJ0OTGMvJIU6Vw
         qwPyKjxcf3zccjLuDfR4OFjR2xAW3nsC2+08/hlyXrV+zOAIH4LHqT6TLkbt/sSsFYn1
         ikKQ==
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20260707; t=1792165477; x=1792770277;
        h=content-transfer-encoding:mime-version:references:in-reply-to
         :message-id:date:subject:cc:to:from:x-gm-gg:x-gm-message-state:from
         :to:cc:subject:date:message-id:reply-to:content-type;
        bh=GfV/mSw0ValKs2Xbc1n/YMtaANNV1FAKPqUAf4xYsdQ=;
        b=RcAHK38au/Bq8qzPl2zTfSS3AGptqnNd1Le42anTAFyD+om4dRultqw0cN2WbwmGFj
         xSlb42/AdIxKicSwz/VOZ83FzfpdnezH38DkGwt+vxZ3rs1wcWkBzz4qD+MkNjb+1owP
         r63rYfwJaGFpTrtZWISkVYwafgGBJb7HlPaflYgxbsbi7qPDjCxuIqRJMwPbHZ+FO4Lt
         IQAfaZGV2MuW6MC/vKEmX9Vs8GqVuPlobo3hvm6Dq7DtQHAb8fT9KQpgtAUr9PzJAsBZ
         I9uX0kN3rrHWAQvdEXKJS0VRo5Oi7VNdv7/dfwV9JhUBXtHeVl/Kb5XcTATuQwG+Lpuy
         Ti5w==
X-Gm-Message-State: AFq9FYJtEi19Hf3yhnSZ9yT0C5Yh7muzZa1Y6bJWmfEM4yCg47CEMwin
	BNuqoiOuS+MppMkGg5YWzd+ZX95igZdxOFVulClH7NgOZho/rZNvJO1YS/oB+VmHa/s=
X-Gm-Gg: AYBFou3RDZPYGCiocFRO2JArEtprAPV6vGj9k5Wxy+oySVIpTmqlQSwxxsJH/miEDck
	9xDnxVoX7eZD+IrsbQIwWwMNtMsC9Zn65Wklyt6E9abf2KDvue377M8pFTnI+nK4WwlLnTnH3om
	JkyeIDOSBO4qtRXkVM6TMRJ+7KJduMe4vLwl8yOcx4Z1m43qAyOw6gFxcWYDWWxoG/S8xly7giv
	hET88E09XU3lY+4cm0LGLfyoJMue/toLWzKhk1eMPyqdLWdCtniAsdn2Q11S9dLQeKa+tnAVl9x
	7ZU/JMHSE3BKJqh8yFjFNPSioZLfkLw8crEfyN4Z1RFDi/xmbclHgeKOT9hthmxyDcjkewFCs7i
	qB7YwAMLPZK7IQaKAOu+85WRgbFpafcKSppIdSShWgb7m/ZYagw4hX6FB2FHEcEFmKoZdduZOfG
	CPojav+i3MrWnhpkT3+QAn43T3rXoJ1D+8ruLzgS8WwZtIRMdtwXdN7kxeE1aI9xkL+Vunbd46+
	0ThNtmY
X-Received: by 2002:a05:690e:1348:b0:675:6f06:5642 with SMTP id 956f58d0204a3-67935eebba4mr14721776d50.1.1792165477006;
        Fri, 16 Oct 2026 08:44:37 -0700 (PDT)
Received: from localhost.localdomain ([112.220.91.130])
        by smtp.gmail.com with ESMTPSA id 956f58d0204a3-679b1ee6f8bsm1217970d50.17.2026.10.16.08.44.34
        (version=TLS1_3 cipher=TLS_AES_256_GCM_SHA384 bits=256/256);
        Fri, 16 Oct 2026 08:44:36 -0700 (PDT)
From: HeonJe Lee <lhjnano@gmail.com>
To: linux-nfs@vger.kernel.org
Cc: cel@kernel.org,
	jlayton@kernel.org,
	HeonJe Lee <lhjnano@gmail.com>
Subject: Re: [PATCH] NFSD: wait for nfsdcld to open the cld pipe
Date: Sat, 17 Oct 2026 00:44:32 +0900
Message-Id: <20261016154432.369488-1-lhjnano@gmail.com>
X-Mailer: git-send-email 2.34.1
In-Reply-To: <20261015114755.33331-1-lhjnano@gmail.com>
References: <20261015114755.33331-1-lhjnano@gmail.com>
Precedence: bulk
X-Mailing-List: linux-nfs@vger.kernel.org
List-Id: <linux-nfs.vger.kernel.org>
List-Subscribe: <mailto:linux-nfs+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:linux-nfs+unsubscribe@vger.kernel.org>
MIME-Version: 1.0
Content-Transfer-Encoding: 8bit

Thanks for the review. You are right that the 44 minute outage was
not a kernel code path outcome - the kernel produced one failed
start, and the rest was the host's oneshot unit not being restarted.

The journal around the failure:

  systemd[1]: Stopping nfs-server.service            06:05:54
  systemd[1]: Stopped nfs-server.service             06:05:55
  systemd[1]: Starting nfs-server.service            06:05:57
  systemd[1]: nfs-server.service: Main process
             exited, status=1/FAILURE                06:05:58
  (manual restart at 06:50:50)

  nfsdcld ActiveEnterTimestamp: 2026-09-29 06:12:24 UTC
  nfsdcld journal between 06:00 and 06:10: no entries

For the record: nfsdcld had been running for 16 days and was not
restarted during the incident, so its inotify watch should have
been in place well before nfsd recreated the pipe. nfsdcld does
not log watch state, so this is an inference rather than a direct
observation, but I have not found a restart of the daemon that
would explain the missed window.

I will hold the kernel patch and look at the nfsdcld side first
as you suggested. I converted nfsdcld to daemon_init()/daemon_ready():
the parent no longer exits until the child signals readiness, and
the child signals right after cld_pipe_init() has installed the
inotify watch.

One additional change this required: the event base is now created
after daemonizing, because daemon_init() renumbers fds (its status
pipe takes fd 3) and would otherwise clobber the epoll descriptor
created before daemonizing. The event base allocation failure is
also reported through xlog() instead of fprintf(stderr) now,
because stderr is /dev/null after daemonizing and an fprintf()
message would be lost.

The patch is inlined below, and it builds and runs against
today's master.

Best regards,
Heon

---

From 229873b7fe52101ee5ba4a234c9b4044e77516dc Mon Sep 17 00:00:00 2001
From: HeonJe Lee <lhjnano@gmail.com>
Date: Fri, 16 Oct 2026 23:58:41 +0900
Subject: [PATCH] nfsdcld: signal readiness only after the pipefs watch is
 installed

nfsdcld daemonizes with daemon(0, 0) and nfsdcld.service is
Type=forking, so systemd considers the service started when the
daemonizing parent exits. The child, however, only installs its
inotify watch on the rpc_pipefs directory much later, after the
sqlite database is prepared and cld_pipe_init() runs. Until the
watch is installed, nfsdcld cannot notice that the kernel has
(re)created the cld pipe.

nfs-server.service orders itself After=nfsdcld.service, but that
ordering is meaningless with Type=forking: on a busy boot or a
restart storm, systemd starts nfsd while nfsdcld is still doing
schema migration or legacy record import, and the kernel's one
second wait for nfsdcld to open the pipe (see
nfs4recover.c:nfsd4_cld_tracking_init()) can expire unused. An
observed instance of this race took an NFS server down for 44
minutes when nothing restarted the failed nfsd.

Fix by converting nfsdcld to the daemon_init()/daemon_ready()
helpers used by the other nfs-utils daemons: the parent no longer
exits until the child signals, and the child signals right after
cld_pipe_init() has installed the inotify watch. With that, the
existing After=nfsdcld.service ordering means what it claims, and
the kernel's one second window is sufficient. The event base is
now created after daemonizing: daemon_init() renumbers fds (its
status pipe takes fd 3) and would otherwise clobber the epoll
descriptor created before daemonizing.  The event base allocation
failure is now reported through xlog() instead of fprintf(stderr):
stderr is /dev/null after daemonizing, so an fprintf() message
would be lost, while xlog() routes it to the syslog.

Link: https://lore.kernel.org/linux-nfs/20261015114755.33331-1-lhjnano@gmail.com/
Signed-off-by: HeonJe Lee <lhjnano@gmail.com>
---
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

