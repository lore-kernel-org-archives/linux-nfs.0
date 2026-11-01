Authentication-Results: smtp.subspace.kernel.org; arc=fail smtp.remote-ip=209.85.222.177
ARC-Seal: i=2; d=subspace.kernel.org; s=arc20261015; a=rsa-sha256; cv=fail;
	t=1793522386;
	b=mkt/s2z/1QGL7/9L1Lt3vdrNGaLKCfKJAbCgKf2+IftIbD0ESxhX//fRsMl51grZtO42
	 wF6Uhtc+vxMK0Ct3B7rxXYKTaqMkIqVkjVyhpsmCD1ALabTVn9iB61BI0O8RXax84swfl
	 7nt5bamAZRZjFgPrYCq1ZELGykyko4wnILtAwgFTBOy9HZKPysDi4+0jA2OqEn+Hkwkoq
	 Y/6jtIQzBeX/SqnKgsOoMxgdZbbagXs3Jk1jEHbe51So0L6R7pq6mFfofgXMOUKbfJs6Z
	 yEmruZ8SlnGAY1vGvTb7bk1lN+sHB3+50P97MD6ZABIz2FXYRpKswP/z58YsbsxEzEA==
ARC-Message-Signature: i=2; d=subspace.kernel.org; s=arc20261015;
	a=rsa-sha256; c=relaxed/relaxed; t=1793522386;
	h=DMARC-Filter:Received:DKIM-Signature:X-Google-DKIM-Signature:
	 X-Gm-Message-State:X-Gm-Gg:X-Received:MIME-Version:References:
	 In-Reply-To:From:Date:X-Gm-Features:Message-ID:Subject:To:Cc:
	 Content-Type;
	bh=FGhXGbB6V9XN0Vm9EMZ3W56UdEjS2FFaY0yHUlQ+zlo=;
	b=nSnSU5F1nNMdpiIr0dgpT3DKI9qJMhUFJ4uHYY4Q3V9xwKwEFyKf9sAOL5QeqnW5VlzS
	 JSxF/pJBEIzIjX09k3f5j5rqYBQBTuJjcTJSLRg+i5oAMprPQaHvM7wfjEWjeH8qI4p7Y
	 uildOcSzbrST3iRcEENIYlVKaP2/HWzGf5mPh0pAppVr1sCAH6KE0qoE1P3s9WucCu8j7
	 UnC+PXY/hbKg+PkUnGH/Uhun1Q07v3i5TTj/HQVbNGRySSwm0RZI55REWIqOe+7bk4s5P
	 4jd+I52UWHukWlTLXj0lSiaXnSKD13yl1tdh41ZEpsXiAlG1QR3U6dJI4pVM4XJS8pA==
ARC-Authentication-Results: i=2; smtp.subspace.kernel.org; 
	dmarc=pass header.from=gmail.com;
	spf=pass smtp.mailfrom=gmail.com;
	dkim=pass header.d=gmail.com header.i=@gmail.com header.a=rsa-sha256 header.s=20260707 header.b=HJmVALpa;
	arc=fail smtp.remote-ip=209.85.222.177
Received: from mail-qk1-f177.google.com (mail-qk1-f177.google.com [209.85.222.177])
	(using TLSv1.3 with cipher TLS_AES_128_GCM_SHA256 (128/128 bits)
	 key-exchange X25519 server-signature ECDSA (prime256v1) server-digest SHA256)
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 591F4606A324
	for <linux-nfs@vger.kernel.org>; Sun,  1 Nov 2026 08:39:46 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.4.2 smtp.subspace.kernel.org 591F4606A324
Authentication-Results: smtp.subspace.kernel.org; dmarc=pass (p=none dis=none) header.from=gmail.com
Authentication-Results: smtp.subspace.kernel.org; spf=pass smtp.mailfrom=gmail.com
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key, unprotected) header.d=gmail.com header.i=@gmail.com header.a=rsa-sha256 header.s=20260707 header.b=HJmVALpa
Received: by mail-qk1-f177.google.com with SMTP id af79cd13be357-93f3c8958d5so259286885a.2
        for <linux-nfs@vger.kernel.org>; Sun, 01 Nov 2026 01:39:46 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1793522385; cv=none;
        d=google.com; s=arc-20260327;
        b=OJNfxSWnOMiqXp7yb5PpLsAQAf4k6ixHmbyakCRJLaIQ0yzZHUBj4rtsI3/litAQjw
         TQMxM8Ixlff7OfFXgqLdd10gl7JT0uVmtndbQo9evyBydj5Sa2IguIdgCThnd8wzxvgB
         tbffJO9OKu6jET8RT89uRvLIOUFkZFAjocfebnO5QmJ720gTJksb54fdheGIObMpM0Mt
         cVi8hPZ2KC3F+RT64chE9nqXcNaJxQndgvH5stR7g8a32VRG5hNh8kRuLKIL1LxsAsgD
         5uFgKZEfAn3NKnUpaVp89M2nBUFg1IvzbcB+PxoPJ8fFJ5Q4VqpJTy1LAiykkdTRLE4Q
         xdqQ==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20260327;
        h=cc:to:subject:message-id:date:from:in-reply-to:references
         :mime-version:dkim-signature;
        bh=FGhXGbB6V9XN0Vm9EMZ3W56UdEjS2FFaY0yHUlQ+zlo=;
        fh=/Qxb7ltexMOQQngtujgD/jzfl7PSNhYNQHSp8aKImDA=;
        b=rmIzk/4Qxp2gUGQVEZ6T2acKfMD/8+o2ntXVYAF/TXxAxtaYUGX5yxzsvhfNrAiKqK
         corTllB8VpkfscZHDjS4Sg2svhvuY1nHvjwodPyGMwownCxCidXnRIFlz4n2kA22GJU4
         k96EhuYZfhcSLcJR1wBccFLyup5Fb/bAnxGEE18W5b38dtzUVH+VdT7J7ttIUZLXBVOm
         STAPxULDbiH6pjLdzd4bXcYvp4uTXN5WQocqCBlBp0M8TqVngC0948iWoeriM5xsbejG
         1uwptLfku+LMXT/gaFJmlAbkSpG8q0TSpprC0YXzXl273zJ9j5OD4JpeDrW4CDAg4t3F
         AA/Q==;
        darn=vger.kernel.org
ARC-Authentication-Results: i=1; mx.google.com; arc=none
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=gmail.com; s=20260707; t=1793522385; x=1794127185; darn=vger.kernel.org;
        h=content-type:cc:to:subject:message-id:date:from:in-reply-to
         :references:mime-version:from:to:cc:subject:date:message-id:reply-to
         :content-type;
        bh=FGhXGbB6V9XN0Vm9EMZ3W56UdEjS2FFaY0yHUlQ+zlo=;
        b=HJmVALpace5D4ZTuPReY6psuslQP9IsqDZuFl5oB129APu2MQKb3xvTTvwTDvzJku5
         dpzeN1NJM3jywR4BJvD5k/4uUIW2Hzk7Rn/nNvpHmlxtyW7uuErURgO0eYqrZgmbZY5A
         P0Kdpfl28E0TK4bxjsNBHcVQA22CuZsaoP8UJxSRT5CSrzGscpif4ifpqHNBiQIgxl92
         QVVbIMW+GRsd6rUJIFQbT0GSSPZ++dXjQkIsQxe4/P1bJBNx8M17S4Vlq3gC1vzKawZp
         lIy+HLst3+KK+ZfRIaTwc/wlwvm6Tcbp9DE7Mj4VJDue/7kPOvShBKItUnhvWYUsBUTp
         UFcw==
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20260707; t=1793522385; x=1794127185;
        h=content-type:cc:to:subject:message-id:date:from:in-reply-to
         :references:mime-version:x-gm-gg:x-gm-message-state:from:to:cc
         :subject:date:message-id:reply-to:content-type;
        bh=FGhXGbB6V9XN0Vm9EMZ3W56UdEjS2FFaY0yHUlQ+zlo=;
        b=ytBuMOcfKPId8/57kvQJvJYCdsLuK4ZrenC8VFnScmvH59hsNEwNrtDk5sWqvKgB9b
         UORsIB1E47vwpfd9EY+LRESOa0wjd6Lig1+sd08g8RXwG5GJboMcqT/PFCtdiWFySsHB
         pVcr648EWPS/YccSR06IySPEvkVCwv8gX3S0f+P2fUq7PxMwIevf2O3CUiU34lPmK1CP
         HQY/PAvqYiCTi6+yVpsaNnN6BqI/1C0wdv8vxmxyZ5lIsaayWQQZxBq9xa1q82kZIyUz
         CBTDXjQH9ZrbBYcC8FGNAbGlAJJ9rjSBIuv2cM77Cy7ydZIDKGqV9XVN2JI4PxPxuF5l
         LUdw==
X-Gm-Message-State: AFq9FYKAjRFYriP2SzxlezASeMwr9OQYgAupj4foL6+5rVx0h/SjYAoI
	89uS/yxLm0/afRI1fUZvmPvM3IWCqR0wBFL73Vh6GHdSryFyypbhKV7PnDpfM8gJwkSS4ryZSfR
	g8/TrKZ+GyH3NedJ7C7+vBANDMgQZRWw=
X-Gm-Gg: AYBFou355Ni9FsznGmStr3kep5ZUh5U5EZsYRY2edDrCyXRJpEzQ0E6Uw/U/KJKQHjs
	HNpSaHlyYhGiUvn5sXMwkoxCEqgdhRaoHW55h/LCDzX0t9zgeiv/Jwl4QYaPNtEz/9iRxK/mhpO
	y6HgFf15UR+WKVBfX/T8SQSEjAMPJEdKz0vyQNo4hI7ZUfPT1rcSumftgDqQ7cktzRvkdzaK5ld
	TJue6PhbrAIhwacjkZfEb/8BkXERoPMaY30nUZiC+PT5VUvz+uEJpsl2Cm3DTS1okY/tEXII2K0
	G3woi0dRgs92bptyyjm0NSh0FLK7sde8coAf2BM6LRDVJpFuc2mLX9V3ztyWBQZyzex2+3kyXOy
	PB+QozoYESr2HxqIXgHtriUvp4bV1TZSSZlMShSxeh4v2HItiF7qWvDQ9IolE5zHEYaD4OnLs/q
	ytxAzUT9V4ixQVB6NdGDvWGpFe
X-Received: by 2002:a05:620a:414f:b0:93e:9171:b83 with SMTP id
 af79cd13be357-944216970c2mr1129754285a.43.1793522385162; Sun, 01 Nov 2026
 01:39:45 -0700 (PDT)
X-Mailing-List: linux-nfs@vger.kernel.org
List-Id: <linux-nfs.vger.kernel.org>
List-Post: <mailto:linux-nfs@vger.kernel.org>
List-Help: <mailto:linux-nfs+help@vger.kernel.org>
List-Subscribe: <mailto:linux-nfs+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:linux-nfs+unsubscribe@vger.kernel.org>
List-Owner: <mailto:linux-nfs+owner@vger.kernel.org>
Precedence: list
MIME-Version: 1.0
References: <CAGD-p3J3nnDhghOMCOy6jk0UQzBysut1sbS7wn6bdF75KZJPbQ@mail.gmail.com>
 <20261031152321.789132-1-roland@wcopy.net>
In-Reply-To: <20261031152321.789132-1-roland@wcopy.net>
From: Kris Globtrotter <kris.globtrotter@gmail.com>
Date: Sun, 1 Nov 2026 09:39:09 +0100
X-Gm-Features: AclHuK-CiAD492gom2cKp5nZ6QEHaUhYiLxNN7EQW7fEKfz5faSk0ia7eYqIdvA
Message-ID: <CAGD-p3JJTjkZTG=Z0ZN-j0fRvph+oANSyPLqWDpn_diN3G5oRQ@mail.gmail.com>
Subject: Re: NULL indirect call in xs_read_stream_request, leaked socket lock
 wedges all NFS traffic
To: Roland Wunderlich <roland@wcopy.net>
Cc: linux-nfs@vger.kernel.org, x86@kernel.org, Borislav Petkov <bp@alien8.de>, 
	Dave Hansen <dave.hansen@linux.intel.com>, Trond Myklebust <trondmy@kernel.org>, 
	Anna Schumaker <anna@kernel.org>, linux-kernel@vger.kernel.org
Content-Type: text/plain; charset="UTF-8"

On Sat, Oct 31, 2026 at 4:23 PM Roland Wunderlich <roland@wcopy.net> wrote:
> Kris: which microcode revision and stepping are you on
> (grep -m1 -E 'stepping|microcode' /proc/cpuinfo)? Could you try
> clearcpuid=fsrm?

Hi Roland,

Answers to your questions, plus a third oops from this machine that
was never posted anywhere.

Hardware: ASRock Rack W680 WS, BIOS 21.12 (10/25/2024), i5-13500
(06-bf-02: model 191, stepping 2), 128 GB DDR5 ECC, bare metal
Proxmox. NFS client is the host, server is a TrueNAS VM on the same
host, NFSv4.2 over TCP via a virtio bridge. Workload: a couple of
dozen containers doing many small, concurrent RPCs on the mount
(metadata, random reads), not sequential whole-file reads.

Microcode: 0x3d, unchanged on all 30 boots since 2026-08-02 (journal
"microcode: Current revision: 0x0000003d" on every one). The BIOS
ships 0x35 ("Updated early from: 0x00000035"); 0x3d is early-loaded
from Debian's intel-microcode 3.20251111.1~deb13u1, i.e. the November
2025 release, not 20260210. So all three of my oopses happened on
0x3d, and the 52 days without an oops since then are on the same
0x3d. Microcode is not a variable here. Whether 0x3d for 06-bf
corresponds to your 0x3a or 0x3e for 06-97, I don't know.

Timeline (all on 7.0.14-12-pve):
  #1  2026-08-24 11:23  Oops 0011, RIP == R12 (stack address, NX)
                        -- the one on the Proxmox forum
  #2  2026-08-27 02:56  Oops 0010, RIP = 0x8
                        -- the one that opened this thread
  #3  2026-09-10 05:17  Oops 0011, RIP == R12 again, full trace below

Since #3 the host has run 7.0.14-15-pve (from 2026-09-10 11:22) and
7.0.14-20-pve (from 2026-10-10): 52 days, 0 oopses, same workload,
same microcode, same NFS mount options. The kernel change happened
six hours after #3, so I can't separate "kernel" from "coincidence";
I'm not claiming -15/-20 fixed anything. The -13/-14 changelogs had
nothing touching sunrpc, which is why I had stayed on -12 until #3.

Oops #3 has the same register pattern you describe:

  RCX = 0
  RAX = RDX = R14 = R15 = 0x1000
  RDI = ffff8dc102fe1000  (page-aligned destination + 0x1000)
  RSI = ffff8dbdd3c1106c, R08 = ffff8dbdd3c1006c  (source + 0x1000)
  RIP = R12 = ffffd2d32e31bd68  (a kernel stack address -> NX fault)
  first trace entry _copy_to_iter+0x27f

so the 4 KiB copy had completed and execution continued at the value
of R12 instead of returning.

Not thermal as far as I can tell: CPU package 30-55 C in normal
operation, no thermal events in the journal around any of the three,
and #3 happened at 05:17 under night load.

I haven't run clearcpuid=fsrm: with no reproduction in 52 days a
host-side test would not be informative, and an oops on the host
wedges production NFS. If the x86 people think a third data point
matters, I can run your dd loop in a throwaway KVM guest on this host
against the same NFS server, 24-48 h with and without clearcpuid=fsrm.
Say so and I'll set it up.

Thanks,
Kris

----------------------------------------------------------------------
Oops #3 (2026-09-10 05:17 CEST, 7.0.14-12-pve, bare metal)
----------------------------------------------------------------------
kernel tried to execute NX-protected page - exploit attempt? (uid: 0)
BUG: unable to handle page fault for address: ffffd2d32e31bd68
#PF: supervisor instruction fetch in kernel mode
#PF: error_code(0x0011) - permissions violation
PGD 100000067 P4D 100000067 PUD 1008d6067 PMD 19278a067 PTE 800000194a6f3163
Oops: Oops: 0011 [#1] SMP NOPTI
CPU: 16 UID: 0 PID: 1935713 Comm: kworker/u80:6 Tainted: P           O
       7.0.14-12-pve #1 PREEMPT(lazy)
Tainted: [P]=PROPRIETARY_MODULE, [O]=OOT_MODULE
Hardware name:  W680 WS/W680 WS, BIOS 21.12 10/25/2024
Workqueue: xprtiod xs_stream_data_receive_workfn [sunrpc]
RIP: 0010:0xffffd2d32e31bd68
Code: ff ff 00 fc 08 00 ac 8d ff ff 10 c6 b2 cb bc 8d ff ff 0c 00 00
00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 <02> 00
00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 f0 5b 70 bf 8d
RSP: 0000:ffffd2d32e31b988 EFLAGS: 00010286
RAX: 0000000000001000 RBX: 0000000000006f94 RCX: 0000000000000000
RDX: 0000000000001000 RSI: ffff8dbdd3c1106c RDI: ffff8dc102fe1000
RBP: ffffd2d32e31ba18 R08: ffff8dbdd3c1006c R09: 0000000000000000
R10: 0000000000000000 R11: ffff8dac041d6100 R12: ffffd2d32e31bd68
R13: ffff8dbf705bf000 R14: 0000000000001000 R15: 0000000000001000
FS:  0000000000000000(0000) GS:ffff8dcb5db0e000(0000) knlGS:0000000000000000
CS:  0010 DS: 0000 ES: 0000 CR0: 0000000080050033
CR2: ffffd2d32e31bd68 CR3: 000000130c63e005 CR4: 0000000000f72ef0
PKRU: 55555554
Call Trace:
 <TASK>
 ? _copy_to_iter+0x27f/0x610
 ? __ip_queue_xmit+0x19b/0x4e0
 ? __check_object_size+0xb4/0x270
 ? __pfx_simple_copy_to_iter+0x10/0x10
 simple_copy_to_iter+0x3e/0x70
 __skb_datagram_iter+0x1b8/0x2f0
 ? __pfx_simple_copy_to_iter+0x10/0x10
 skb_copy_datagram_iter+0x39/0xc0
 tcp_recvmsg_locked+0x836/0xb00
 ? __tcp_send_ack.part.0+0xf3/0x1f0
 tcp_recvmsg+0x83/0x1f0
 inet_recvmsg+0x51/0x130
 ? apparmor_socket_recvmsg+0x64/0x80
 ? security_socket_recvmsg+0x70/0x1e0
 sock_recvmsg+0xb6/0xc0
 xs_sock_recvmsg.constprop.0+0x2c/0xa0 [sunrpc]
 xs_read_stream_request.constprop.0+0x255/0x4f0 [sunrpc]
 xs_read_stream.constprop.0+0x2b3/0x450 [sunrpc]
 xs_stream_data_receive_workfn+0x71/0x160 [sunrpc]
 process_one_work+0x1a9/0x3c0
 worker_thread+0x1b8/0x360
 ? __pfx_worker_thread+0x10/0x10
 kthread+0xf7/0x130
 ? __pfx_kthread+0x10/0x10
 ret_from_fork+0x2da/0x3a0
 ? __pfx_kthread+0x10/0x10
 ret_from_fork_asm+0x1a/0x30
 </TASK>
note: kworker/u80:6[1935713] exited with irqs disabled

Blocked worker three hours later (kworker/u80:4+rpciod):
[<0>] __lock_sock+0x7c/0xd0
[<0>] lock_sock_nested+0x54/0x60
[<0>] tcp_sock_set_cork+0x19/0x60
[<0>] xs_tcp_send_request+0xe3/0x360 [sunrpc]
[<0>] xprt_transmit+0x1be/0x4b0 [sunrpc]
[<0>] call_transmit+0x7f/0xa0 [sunrpc]
[<0>] __rpc_execute+0xbb/0x4e0 [sunrpc]
[<0>] rpc_async_schedule+0x33/0x50 [sunrpc]
