Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.remote-ip=209.85.221.49
ARC-Seal: i=1; d=subspace.kernel.org; s=arc20261015; a=rsa-sha256; cv=none;
	t=1792852748;
	b=fojgl9Wy4TskDVtWrG939RIdt/75Io42JSJwHY5m2L/PpFQlzoA/Z6brAnozXZnwJW2m
	 k03DXfWxfiIv0b4KOudIFLlAk4B8kh/n64+Ln9JOFqmCyRBkQdp0ZRzbH8vdrWzY3ttB0
	 J0F/53dov9evC5txWvfQE96uuVFp+57WU2K+NY/MV8N8Z6ojNmwsN7Ntipe0/ItyPYE7f
	 +gxXv6ijSx5LEjA8Kxs7AvNgt9Dj1Pe/iV7KbUu7pk9k6IUHGvIT09widhCpi/P9CB6Ar
	 GFoRBjju1f8dzAzuNJsPZw8Ft4ubfW62iF1UYzWOjYOdt+1GmhVr5hbrWTOOgijIdHA==
ARC-Message-Signature: i=1; d=subspace.kernel.org; s=arc20261015;
	a=rsa-sha256; c=relaxed/relaxed; t=1792852748;
	h=DMARC-Filter:Received:DKIM-Signature:X-Google-DKIM-Signature:
	 X-Forwarded-Encrypted:X-Gm-Message-State:X-Gm-Gg:X-Received:Received:
	 From:To:Cc:Subject:Date:Message-ID:X-Mailer:MIME-Version:
	 Content-Transfer-Encoding;
	bh=zjXifzsuYpS0FQruVBIsTQMHaxQeJksSexJHZzpqVro=;
	b=AFcfoPUCCH42Rrz/hCdcI0Z1CyVQAFzvjAW0dUXjmC1VkPDfWIQ4irg8pb4qrQFa+6Ps
	 bUElQ9hW6IrtWkIgvydXXAULreB3H/tRE6yKGmTlS6dcIgrPEzdMYTPq7QzJWTWWCGfy2
	 A7bUjT3hHFwnmFEsQK4b0xcdbXN6JRfddAjS/UgLVk6/ouC+fxdxfxNPq/5asyJ3b9DMp
	 rySY4m2hEEVVjmTGaGvfRtU+OpgYYdupfkF3iVTYdBdiQFcEkSAMTkcOWtEMsfMJkSXs3
	 uZEXgA9vLvsVKAFKsxKlBCUsDdC882XmrAkKz0O3sFzE8hLjxmcMlJqQme4XXkWiRtg==
ARC-Authentication-Results: i=1; smtp.subspace.kernel.org; 
	dmarc=pass header.from=gmail.com;
	spf=pass smtp.mailfrom=gmail.com;
	dkim=pass header.d=gmail.com header.i=@gmail.com header.a=rsa-sha256 header.s=20251104 header.b=sZQCj41k;
	arc=none smtp.remote-ip=209.85.221.49
Received: from mail-wr1-f49.google.com (mail-wr1-f49.google.com [209.85.221.49])
	(using TLSv1.3 with cipher TLS_AES_128_GCM_SHA256 (128/128 bits)
	 key-exchange X25519 server-signature ECDSA (prime256v1) server-digest SHA256)
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 6B4F6606A31D
	for <linux-nfs@vger.kernel.org>; Sat, 24 Oct 2026 14:39:08 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.4.2 smtp.subspace.kernel.org 6B4F6606A31D
Authentication-Results: smtp.subspace.kernel.org; dmarc=pass (p=none dis=none) header.from=gmail.com
Authentication-Results: smtp.subspace.kernel.org; spf=pass smtp.mailfrom=gmail.com
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key, unprotected) header.d=gmail.com header.i=@gmail.com header.a=rsa-sha256 header.s=20251104 header.b=sZQCj41k
Received: by mail-wr1-f49.google.com with SMTP id ffacd0b85a97d-48e00eee27dso1110919f8f.0
        for <linux-nfs@vger.kernel.org>; Sat, 24 Oct 2026 07:39:08 -0700 (PDT)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=gmail.com; s=20251104; t=1792852747; x=1793457547; darn=vger.kernel.org;
        h=content-transfer-encoding:mime-version:message-id:date:subject:cc
         :to:from:from:to:cc:subject:date:message-id:reply-to:content-type;
        bh=zjXifzsuYpS0FQruVBIsTQMHaxQeJksSexJHZzpqVro=;
        b=sZQCj41k767rX6Ga5oQaHrf80CdrLuhs50LN8sctOyTArONZ1XmyK+8SPG9oEmiHFA
         Ir3Wi9sruGtPWEL8IRs5qx/i+8wsOnGZFtjUKwy4HhUiUjHgIADtOLI0adl14CxoOPdY
         vlxJRbD+s5K3OxhhDo/YqHYwJixTw6kKy4KOtp8F9QPH10XDgsjNqVnTFXi+ZV095UYa
         J8sSPfd9Gt1oSd5pWklimpOW4xKK7jmqAsKAe8Nt3r8gtx3BdlhogeahWzcBFUSvnCXi
         0AWS/UVfwpSwhg9ASnrVK75uOKh/qMaGP4yh3A3Zr70N9dtjG661I++loJhVi+w1Tixg
         k6tg==
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20260707; t=1792852747; x=1793457547;
        h=content-transfer-encoding:mime-version:message-id:date:subject:cc
         :to:from:x-gm-gg:x-gm-message-state:from:to:cc:subject:date
         :message-id:reply-to:content-type;
        bh=zjXifzsuYpS0FQruVBIsTQMHaxQeJksSexJHZzpqVro=;
        b=NJ2SvKN2WOd2R8v9bwafxerM6Do3ukAjCutgHYCaZLO50YXamgcN29SeV+o9iH30Ww
         8GTQ706+1Z4cW4DUGByVNG+LgLcoMabLTG6b0fM/iQEbdY+cmi+cZONIsXgaVudfO3Ht
         9xpylGkVTGsBEDCt1pxk2dz+tLDCxuJkITUP4wLYjgLucwkmBFKGlTWfaduzxfpRrdlh
         aX0566jjPBkMetvBWDcbRG1flT8wVrg5wmna4rdsgnx+1J3INDEwr5MHgwsEpCNLTHLL
         hhN3gjGe4j40A4A3hoZkRnWqge3SNYf2DALHnBw35uJO5Vc0w7esbMZatR1ad6wvHa+K
         2D0w==
X-Forwarded-Encrypted: i=1; AKwUvByPrU5GLpuXT5oMIjJFADYSI2ZUaiUWPhdZk47IgT3s2tJ6MIWytJ0TrAHOrU6jD8BFv3t6Z+W5ZRs=@vger.kernel.org
X-Gm-Message-State: AFq9FYKdbo3A+V4zEirjIcSbfiehoKcivWnuHBJNdpRnGl6h0gyDC0X6
	YU60GzM8YPxPwvC3JnCSC1hEOhojIJKmQ2Kiukq2165d9zW3YQ/3Dr4s
X-Gm-Gg: AYBFou2bdi7lwCoFFjI5JJPC/FmqQsvxZ5ve0+S6ASViCMyX4EZrT2ESialFOhcK6Y2
	AdR+Q3fdYXK5zYIOT/iuhJe7g/4PiQSD80TzSlnP+KrQKYpMMK4876CVQSd48Oz6wB5tMCGg9rj
	Fsx8vFoneyb++9Doipim8mPilk4MQUqX2wRlgoQF7cn5d71pd/jLAejDbHFh7dn3AjGkgu8Da/F
	zgtNjswlh0stf6Dpl15i+WB4wNLQbSPVqJxUroENNcH71yyVbzdNfIeobFxB+CQm3mojTEGdk4I
	/xaIp1/FUpVW6wAJbQjN04MkwwsDoSMCtW3RKIyXpMkhDIKLD2PYDlB5yoQE1rwSRHCbkWSU7V5
	awb8CZ1XHT6bpkBdmHEH2UljHeuyI0kJK4gaCO/KBbhnKJwkAL8YxWxty3M1W64UOmQFGS/Gx5N
	wO71VwffY+LH48p7MZn8JDfQkRgRibZmoTpqGm9g5A7eol+1BWU0INBeoWYIc75dwQJMnfKtuda
	XRsDjLBqG8OlYz6+0CSdxv1zCsGjfP5B9eH67tDf3uVW0maObxDN7dUWHT+6pWe0KBmKjIPjX0T
	x2t3y80AdI9OStwdCRS+zOLtL4pQcVrbbGruNl/F2FtSpFXaypBaUA==
X-Received: by 2002:a5d:6246:0:b0:487:40d:af33 with SMTP id ffacd0b85a97d-48e3eb834d0mr2415372f8f.13.1792852746535;
        Sat, 24 Oct 2026 07:39:06 -0700 (PDT)
Received: from DESKTOP-IR7J1S9.localdomain ([105.102.66.195])
        by smtp.gmail.com with ESMTPSA id ffacd0b85a97d-48e3ecd3555sm4466723f8f.42.2026.10.24.07.39.05
        (version=TLS1_3 cipher=TLS_AES_256_GCM_SHA384 bits=256/256);
        Sat, 24 Oct 2026 07:39:06 -0700 (PDT)
From: Drif Abdelmalek Mohamed Said <drifabdelmalekmohamedsaid@gmail.com>
To: trondmy@kernel.org,
	anna@kernel.org,
	cel@kernel.org,
	jlayton@kernel.org
Cc: neil@brown.name,
	okorniev@redhat.com,
	Dai.Ngo@oracle.com,
	tom@talpey.com,
	linux-nfs@vger.kernel.org,
	netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org,
	Drif Abdelmalek Mohamed Said <drifabdelmalekmohamedsaid@gmail.com>,
	syzbot+ae55a0fac80c73c938ac@syzkaller.appspotmail.com
Subject: [PATCH] sunrpc: fix null-ptr-deref Read in xprt_reserve
Date: Sat, 24 Oct 2026 15:39:02 +0100
Message-ID: <20261024143902.341-1-drifabdelmalekmohamedsaid@gmail.com>
X-Mailer: git-send-email 2.43.0
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

syzbot reported:

BUG: KASAN: null-ptr-deref in instrument_atomic_read
     include/linux/instrumented.h:82 [inline]
BUG: KASAN: null-ptr-deref in _test_bit
     include/asm-generic/bitops/instrumented-non-atomic.h:141 [inline]
BUG: KASAN: null-ptr-deref in xprt_throttle_congested
     net/sunrpc/xprt.c:1708 [inline]
BUG: KASAN: null-ptr-deref in xprt_reserve+0xe2/0x2c0 net/sunrpc/xprt.c:1948
Read of size 8 at addr 0000000000000628 by task syz.8.3118/20390

Call Trace:
 <TASK>
 dump_stack_lvl+0xe8/0x150 lib/dump_stack.c:120
 kasan_report+0x117/0x150 mm/kasan/report.c:595
 check_region_inline mm/kasan/generic.c:-1 [inline]
 kasan_check_range+0x264/0x2c0 mm/kasan/generic.c:200
 instrument_atomic_read include/linux/instrumented.h:82 [inline]
 _test_bit include/asm-generic/bitops/instrumented-non-atomic.h:141 [inline]
 xprt_throttle_congested net/sunrpc/xprt.c:1708 [inline]
 xprt_reserve+0xe2/0x2c0 net/sunrpc/xprt.c:1948
 __rpc_execute+0x526/0x1280 net/sunrpc/sched.c:947
 rpc_execute+0x1c1/0x390 net/sunrpc/sched.c:1023
 rpc_run_task+0x4a6/0x660 net/sunrpc/clnt.c:1269
 rpc_ping_noreply net/sunrpc/clnt.c:2944 [inline]
 rpc_create_xprt+0x452/0xa90 net/sunrpc/clnt.c:494
 rpc_create+0x649/0x900 net/sunrpc/clnt.c:619
 gssp_rpc_create net/sunrpc/auth_gss/gss_rpc_upcall.c:107 [inline]
 set_gssp_clnt+0x188/0x2d0 net/sunrpc/auth_gss/gss_rpc_upcall.c:131
 write_gssp+0x21e/0x310 net/sunrpc/auth_gss/svcauth_gss.c:1423
 pde_write fs/proc/inode.c:330 [inline]
 proc_reg_write+0x1e9/0x2e0 fs/proc/inode.c:342
 vfs_write+0x296/0xba0 fs/read_write.c:685
 ksys_write+0x150/0x270 fs/read_write.c:739
 do_syscall_x64 arch/x86/entry/syscall_64.c:61 [inline]
 do_syscall_64+0x166/0x520 arch/x86/entry/syscall_64.c:84
 entry_SYSCALL_64_after_hwframe+0x77/0x7f

The GSS proxy client setup races with sysfs. xprt_switch_alloc() publishes
the transport in sysfs before rpc_new_client() sets xprt->main = true. The
sysfs offline handler rejects writes when main is already true, so
userspace can set XPRT_OFFLINE in that window.

The initial RPC then runs with the only transport offline.
xprt_is_active() only rejects a transport whose refcount is zero
or whose XPRT_OFFLINE bit is set, and a transport that is still on the switch's
list always holds a reference.

xprt_switch_find_first_entry() returns NULL, rpc_task_get_next_xprt()
returns NULL with it, and since rpc_task_set_transport() returns void,
the task continues with tk_xprt == NULL until xprt_reserve() dereferences it.

Mark the first transport as main in xprt_switch_alloc() before creating the
sysfs entries, and drop the assignment from rpc_new_client().

Fixes: e091853ebdb4 ("SUNRPC mark the first transport")
Reported-by: syzbot+ae55a0fac80c73c938ac@syzkaller.appspotmail.com
Closes: https://syzkaller.appspot.com/bug?extid=ae55a0fac80c73c938ac
Signed-off-by: Drif Abdelmalek Mohamed Said <drifabdelmalekmohamedsaid@gmail.com>
---
 net/sunrpc/clnt.c          | 1 -
 net/sunrpc/xprtmultipath.c | 1 +
 2 files changed, 1 insertion(+), 1 deletion(-)

diff --git a/net/sunrpc/clnt.c b/net/sunrpc/clnt.c
index 6cedc824cf82..aa9f9c185c02 100644
--- a/net/sunrpc/clnt.c
+++ b/net/sunrpc/clnt.c
@@ -419,7 +419,6 @@ static struct rpc_clnt * rpc_new_client(const struct rpc_create_args *args,
 	}
 
 	rpc_clnt_set_transport(clnt, xprt, timeout);
-	xprt->main = true;
 	xprt_iter_init(&clnt->cl_xpi, xps);
 	xprt_switch_put(xps);
 
diff --git a/net/sunrpc/xprtmultipath.c b/net/sunrpc/xprtmultipath.c
index 3ba818d637be..5e2d43d6c643 100644
--- a/net/sunrpc/xprtmultipath.c
+++ b/net/sunrpc/xprtmultipath.c
@@ -159,6 +159,7 @@ struct rpc_xprt_switch *xprt_switch_alloc(struct rpc_xprt *xprt,
 		atomic_long_set(&xps->xps_queuelen, 0);
 		xps->xps_net = NULL;
 		INIT_LIST_HEAD(&xps->xps_xprt_list);
+		xprt->main = true;
 		xps->xps_iter_ops = &rpc_xprt_iter_singular;
 		rpc_sysfs_xprt_switch_setup(xps, xprt, gfp_flags);
 		xprt_switch_add_xprt_locked(xps, xprt);
-- 
2.43.0

