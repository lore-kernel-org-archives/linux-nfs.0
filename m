Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.remote-ip=74.125.82.177
ARC-Seal: i=1; d=subspace.kernel.org; s=arc20261015; a=rsa-sha256; cv=none;
	t=1793460208;
	b=r3Qf8yOnJfGEdhw9xMqhrVCq+LBFoYSCWPQldd5hDxVZz/Mfypu82C+rvH8wC7/TZ94S
	 SCnFggzv/XYc0xRbfOJeqsm8JUbtiBhxctUT+gU+YydNBqO+t4RC8CQtyHVtc+Zs9/IkK
	 5Mw07U7vg0v4jcsY2PYXT5ZAaktv4BOs8XY6q5mgDXsjpZEeiVvgiiQppJaqKThD6wSBZ
	 sQWemFpxC1lGtkXoOci1b58/0tP/dzngfFPWEIs1z3cpbR6OtGNtQzaGDyakeTVVxWG6g
	 vilOtqMOF8H1CVI4aoULD5hG1Ff29iy9Vr0HdwX7A3J/QlserLayFt5gPDqThkv2uMw==
ARC-Message-Signature: i=1; d=subspace.kernel.org; s=arc20261015;
	a=rsa-sha256; c=relaxed/relaxed; t=1793460208;
	h=DMARC-Filter:Received:DKIM-Signature:X-Google-DKIM-Signature:
	 X-Gm-Message-State:X-Gm-Gg:X-Received:Received:From:To:Cc:Subject:
	 Date:Message-ID:X-Mailer:In-Reply-To:References:MIME-Version:
	 Content-Transfer-Encoding;
	bh=TysyqyCDsrzuuXgp/xRgXr2Epz2vAF1gUTnCGRlLUOk=;
	b=RLV4ZGUGkKg6Q6arxJN2e98qt4ahSCZ3DJu8dPuMz1B5QNqEK67IQh9lADIylzqcBAy9
	 0PBU688Wszikh4eUwjNT2lVyPjBTYMvkNCtgnX+tcQ+I0jmUV403tjA9heo9HOGAS3KR/
	 3pxZ8yDMraUShSGO9N1/kVkNgcYkfR/A4J36baku1twk9XHt6wCj0ua6xk1P8I5R/JhX+
	 9ruBkK/v292xficMwRuO7t/D1+x7XboITA3YOdiRGXu0Q7k85ggkMBEMaZ5JhLz3XwiGk
	 gL6WQ/jg3LXbgnuS1zf1XPlya8Vx5WNLATKNknXC1U9C1ooZrp5xCPxrwiHSPMCZYUg==
ARC-Authentication-Results: i=1; smtp.subspace.kernel.org; 
	dmarc=pass header.from=wcopy.net;
	spf=pass smtp.mailfrom=wcopy.net;
	dkim=pass header.d=wcopy.net header.i=@wcopy.net header.a=rsa-sha256 header.s=google header.b="l2/yhB4q";
	arc=none smtp.remote-ip=74.125.82.177
Received: from mail-dy1-f177.google.com (mail-dy1-f177.google.com [74.125.82.177])
	(using TLSv1.3 with cipher TLS_AES_128_GCM_SHA256 (128/128 bits)
	 key-exchange X25519 server-signature ECDSA (prime256v1) server-digest SHA256)
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id A83A0606A31C
	for <linux-nfs@vger.kernel.org>; Sat, 31 Oct 2026 15:23:27 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.4.2 smtp.subspace.kernel.org A83A0606A31C
Authentication-Results: smtp.subspace.kernel.org; dmarc=pass (p=reject dis=none) header.from=wcopy.net
Authentication-Results: smtp.subspace.kernel.org; spf=pass smtp.mailfrom=wcopy.net
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key, unprotected) header.d=wcopy.net header.i=@wcopy.net header.a=rsa-sha256 header.s=google header.b=l2/yhB4q
Received: by mail-dy1-f177.google.com with SMTP id 5a478bee46e88-35c76e9614aso2418887eec.0
        for <linux-nfs@vger.kernel.org>; Sat, 31 Oct 2026 08:23:27 -0700 (PDT)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=wcopy.net; s=google; t=1793460206; x=1794065006; darn=vger.kernel.org;
        h=content-transfer-encoding:mime-version:references:in-reply-to
         :message-id:date:subject:cc:to:from:from:to:cc:subject:date
         :message-id:reply-to:content-type;
        bh=TysyqyCDsrzuuXgp/xRgXr2Epz2vAF1gUTnCGRlLUOk=;
        b=l2/yhB4qw/Mss0tuli/ZElilRxMcBbcBnTQZPLDPEfxICPhgamin2a/ZaWBwFTdVz0
         VFLDal5VvJoI9KkTDGtyAzjzC85GW/hKdmqF0xu+Bq7/hUYjCr+RsblA/H47CzP9O+Y7
         VheWkir2PonZ2/dndocIQ0EExYIHjDdvRV5GC3OmCBNlxMgHa4gYZstzbFeuILPwZu0M
         q3TvAtE27bobRwlMp0ZeObXVTFwM19SpYPXN3uoIx4orn7sbynuGCmvJ+XWNNopCyhP3
         lEcN2wVrDU+2QwVyMumyjYVDfWLVxPmlrYScj6T31SR0LnyonEW1bzAj5KeI7BDxCr8+
         a3vw==
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20260707; t=1793460206; x=1794065006;
        h=content-transfer-encoding:mime-version:references:in-reply-to
         :message-id:date:subject:cc:to:from:x-gm-gg:x-gm-message-state:from
         :to:cc:subject:date:message-id:reply-to:content-type;
        bh=TysyqyCDsrzuuXgp/xRgXr2Epz2vAF1gUTnCGRlLUOk=;
        b=qnpE8PQ8ARsMfpF3FS/jRs96LTTtaRpvIpw5hpDrEsmfolS7MdhtvClEXY/avAnqwT
         qlJj6h9/fU+xT6Z+JiHJIg47XhqkYd+YGKm/HK45IVO3ii9ZKkgC9O77vyMuY1UxBVvA
         Z+669F4pC8fZZnpBXBCWDy/6ojuisInBUjbSpwvAM/CodE1tESJHHcsmaqdUxi3ZnUyq
         eBBMESEoDSbGWtDPEMzPLbJawFZlCQ58te16AC7ptnyKNUJqtRStelS8NTxMwJSUfsUq
         jVW0ltXnp4iBY7Ykhbl2nM/zhU4OZFafQPzrkO3zKFq09aT0hEoSjoRWqhDbdPtDmQot
         9rSQ==
X-Gm-Message-State: AFq9FYJZyiWueDMLTHWKV4kCuGhUozUGJtdo6WevJMMtCp7BcUMXk/XZ
	PGnm4qUlymbcCKD5P4CAKZEWixp10BF5KMpKisdqXQvPmvaBsNrPovmtfJqFivf/JQOw9b8jn28
	UwJyBS60=
X-Gm-Gg: AYBFou3RvZjNL5iuhlkySduQg3re3i+g4kakKecIKUkFplD0arwKjyidXhv4Igyr4Dt
	WTHgqGT076ecf6Apc4cNlDWOKR27Tol6ncyG8OTRbizqYS5MHtN2wyZLr6do95VeyEdUrczmsno
	OuSbruP/X12fnuVUM2od9YLN27OzPoD4J2ZPyU0D2ko01hN63RAheRpZUh9VxAq3IzDU2gz2Vt0
	E1B/FUPHRkIBhOfA7YnK98XlR2xSK+mE5vffPru5nUBeLUHIpiioaRCc5hAEj/wfNSphTSCiVi0
	1EMNNNijEwxZ3pIzXvOSYtpQuLyogybVSUB8p3cDxksQRWfrGwmhj2xqQsv/WCgP4eVvEoJgJIx
	bzaLZprtyeyXziPli0mizFDd8BzeN11xmBaGOabRfic+XOqcLo3Nei9raTR3He53XQSrN9eDRPg
	wz5xnguCVG3JALkMEFESFjJTO1yAf6wdnP4RTsSYxT79YGwKPF+gm+OfVGucN1t4bwjKDhoPLaw
	CSDtVVyAYX3ZE33SwuI7o3Sj4Y3UfpU2TBRZSNVb7e8tsCHoPvYvVixrawvu96vJdOm5eJXsIXA
	I6KWPzMWr52lLRtVRH1m/acv9Ubt1INyoxWS+uPD4A==
X-Received: by 2002:a05:7300:cb0b:b0:354:1db3:674e with SMTP id 5a478bee46e88-36a42330b9fmr10089411eec.6.1793460205178;
        Sat, 31 Oct 2026 08:23:25 -0700 (PDT)
Received: from pallene.netbird.cloud ([2600:4041:4459:1f00:be24:11ff:fe04:265e])
        by smtp.gmail.com with ESMTPSA id 5a478bee46e88-36a42a98f65sm17703907eec.28.2026.10.31.08.23.22
        (version=TLS1_3 cipher=TLS_AES_256_GCM_SHA384 bits=256/256);
        Sat, 31 Oct 2026 08:23:24 -0700 (PDT)
From: Roland Wunderlich <roland@wcopy.net>
To: linux-nfs@vger.kernel.org
Cc: Roland Wunderlich <roland@wcopy.net>,
	x86@kernel.org,
	Borislav Petkov <bp@alien8.de>,
	Dave Hansen <dave.hansen@linux.intel.com>,
	Trond Myklebust <trondmy@kernel.org>,
	Anna Schumaker <anna@kernel.org>,
	Kris Globtrotter <kris.globtrotter@gmail.com>,
	linux-kernel@vger.kernel.org
Subject: Re: NULL indirect call in xs_read_stream_request, leaked socket lock wedges all NFS traffic
Date: Sat, 31 Oct 2026 11:23:21 -0400
Message-ID: <20261031152321.789132-1-roland@wcopy.net>
X-Mailer: git-send-email 2.54.0
In-Reply-To: <CAGD-p3J3nnDhghOMCOy6jk0UQzBysut1sbS7wn6bdF75KZJPbQ@mail.gmail.com>
References: <CAGD-p3J3nnDhghOMCOy6jk0UQzBysut1sbS7wn6bdF75KZJPbQ@mail.gmail.com>
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

Hi,

I've hit the oops from this thread four times, and I think it's a CPU
problem rather than an NFS one.

- 4 oopses within 32 h of uptime on 6.18.57 following a BIOS update,
  in a KVM guest on an i9-12900K (06-97-02, microcode 0x3e), all in
  xprtiod -> xs_read_stream_request -> tcp_recvmsg -> _copy_to_iter.
- In every one, the memcpy inside _copy_to_iter has finished the copy
  (RCX = 0, both pointers advanced by 0x1000), and the CPU then
  continues at a wrong RIP instead of returning.
- They started hours after the host BIOS update moved the microcode
  from 0x3a to 0x3e.
- With clearcpuid=fsrm (memcpy uses memcpy_orig, not rep movsb):
  0 oopses in 5 days under similar load.
- Kris's oops [1] has the same register pattern on bare metal
  (i5-13500), which takes KVM and virtio out of it.


1. Setup
--------

Guest: NixOS, kernel 6.18.57, 16 vCPUs, QEMU "cpu: host", q35,
virtio-net. Kernel IBT is on ("CET detected: Indirect Branch Tracking
enabled").
Host: Proxmox, kernel 7.0.14-25-pve, QEMU 11.0.3, i9-12900K (Alder
Lake-S C0, 06-97-02), BIOS A.O0, microcode 0x3e.
Workload: Plex reading whole media files over NFS from a Synology NAS
(TCP, v4.1 for oopses 1-3, v3 for oops 4), mostly at night, one or two
readers at a time, 100-230 MB/s.


2. Stack trace
--------------

_copy_to_iter+0x254 is a direct call to memcpy (bvec path: one 4 KiB
reply page copied into a page-cache page). After alternatives and
return-thunk patching, memcpy on this kernel is:

  +0x0   endbr64
  +0x4   nop              (66 90)
  +0x6   mov  %rdi,%rax
  +0x9   mov  %rdx,%rcx
  +0xc   rep movsb
  +0xe   ret
  +0xf   int3 x4          (padding)

The Code: line of oops 2 shows these bytes.

All four oopses have:

  RCX = 0
  RSI, RDI = src + 0x1000, dest + 0x1000
  RAX = dest (page-aligned direct-map address)
  RBX = RBP = 0x1000
  RSP = memcpy's frame, same stack offset (...a40) in all four
  first trace entry = _copy_to_iter+0x259, the return address, intact

and then:

  oopses 1, 3, 4:  RIP = 0x1000, the copy length; RDX = 0x1000
  oops 2:          #BP at memcpy+0x11, the int3 padding two bytes
                   past the ret; RDX = 0xbcee0000 (the low half of
                   RAX), so something ran between the ret and the int3

So the copy is done and the return address on the stack is fine, yet
the next instruction is fetched from the wrong place. An indirect call
into the int3 padding would have raised #CP, not #BP, since IBT is on.
A corrupted return address or function pointer doesn't explain RIP
being equal to the copy length three times out of four. It resembles
Reptar (CVE-2023-23583), where execution continues at a wrong IP after
a micro-architectural event, though there's no redundant prefix here.

Kris's oops on the Proxmox forum [1] reads the same way: RIP == R12
exactly (a kernel stack address, hence the NX fault), RCX = 0,
RAX = RDX = 0x1000, first trace entry _copy_to_iter+0x27f. The oops
that started this thread has RIP = 0x8.


3. Microcode timeline
---------------------

The host BIOS update on 2026-10-24 (MSI A.J1 -> A.O0) changed the
running microcode from 0x3a (early-loaded by the host OS) to 0x3e
(Intel microcode-20260210, INTEL-SA-01396, which updates 06-97-02 and
06-bf-02/05 together). The first oops came 7.5 h later.

The two nights before ran the same workload on 0x3a without an oops:
192 and 1,159 whole-file reads over NFS v4.1. The same maintenance
window also updated the host kernel (6.17 -> 7.0.14-pve) and QEMU
(10.1 -> 11.0), so the microcode is the main suspect, not a
fully proven cause.

Kris's i5-13500 is 06-bf-02 or 06-bf-05 depending on stepping, which
is covered by the same microcode release.


4. The clearcpuid=fsrm test
---------------------------

Since 2026-10-26 the guest has booted with clearcpuid=fsrm, so memcpy
jumps to memcpy_orig instead of running rep movsb. The kernel is tainted
S from that, as expected. Nothing else changed: same kernel, microcode,
NFS mount (v3, TCP) and workload.

  before:  4 oopses in 32 h of uptime
  after:   0 oopses in 5 nights / 120 h of uptime,
           1047 whole-file analyses,
           41.6 M NFS READs (5.5 TB), 0 RPC timeouts

The NFS receive path is probably just where this guest does most of
its kernel-mode rep movsb with interrupts enabled: one 4 KiB memcpy per
reply page, about 25k per second at 100 MB/s, in the kworker that also
takes the virtio-net interrupts. I'd expect any other heavy user of
rep movsb to be able to hit it.


5. Suggested reproduction
-------------------------

It is not load-driven. A 20-minute flood of 16 parallel dd readers
(216 GB at 180 MB/s) and a 2.5 h stress test (17 M READs) didn't
trigger it, and one oops came during a quiet period. The oopses came
1.1 h to 11.6 h into a boot. Possible repro:

  - An Alder Lake or Raptor Lake CPU with FSRM, on the 20260210
    microcode (0x3e for 06-97-02).
  - An NFS mount over TCP (v3 or v4) from a server that can sustain
    100's of MB/s.
  - One or two sequential whole-file readers running continuously,
    with the page cache dropped between passes, for 24-48 h:

      while :; do
          echo 3 > /proc/sys/vm/drop_caches
          find /mnt/nfs -type f -size +1G -print0 |
              xargs -0 -P2 -n1 sh -c 'dd if="$1" of=/dev/null bs=1M' _
      done

  - Expected rate, if it matches mine: about one oops per 8 h.

Comparisons that could settle it, each over the same 24-48 h:

  a) the same with clearcpuid=fsrm (here: 0 oopses);
  b) the same with the previous microcode (0x3a for 06-97-02),
     early-loaded;
  c) the guest pinned to P-cores only, then E-cores only, to see if
     one core type is involved.

I haven't run (b) or (c) yet. I also haven't tried a reproducer
without NFS, such as a kthread per CPU doing 4 KiB memcpy between
pages in a loop with interrupts enabled. If the x86 folks think that
would be a better test, I can try it.


6. Questions
------------

Kris: which microcode revision and stepping are you on
(grep -m1 -E 'stepping|microcode' /proc/cpuinfo)? Could you try
clearcpuid=fsrm?

x86 / Intel: is a wrong-RIP issue after rep movsb known for 0x3e, or
for this microcode release on other parts?

NFS: unless someone sees a sunrpc path that could produce these
registers, I don't think there is anything to fix on your side.

The attachments below are inline text: the four oopses, /proc/cpuinfo
(first CPU), the VM config, guest kernel config bits, the host log
lines showing the microcode change, and the memcpy and _copy_to_iter
disassembly.

[1] https://forum.proxmox.com/threads/kernel-oops-in-sunrpc-xs_read_stream_request-%E2%80%94-nfsv4-2-client-wedges-host-reboot-required-7-0-14-12-pve.185948/

Thanks,
Roland

----------------------------------------------------------------------
Oops 1 of 4 (2026-10-25 02:12 EDT, EFI pstore 1792908807)
----------------------------------------------------------------------
[26975.685653] BUG: unable to handle page fault for address: 0000000000001000
[26975.688315] #PF: supervisor instruction fetch in kernel mode
[26975.689599] #PF: error_code(0x0010) - not-present page
[26975.690741] PGD 91493e067 P4D 91493e067 PUD 91493f067 PMD 0 
[26975.692006] Oops: Oops: 0010 [#1] SMP NOPTI
[26975.692957] CPU: 5 UID: 0 PID: 156937 Comm: kworker/u80:2 Tainted: G        W           6.18.57 #1-NixOS PREEMPT(lazy) 
[26975.695276] Tainted: [W]=WARN
[26975.695971] Hardware name: QEMU Standard PC (Q35 + ICH9, 2009), BIOS 4.2026.08-1 08/26/2026
[26975.697791] Workqueue: xprtiod xs_stream_data_receive_workfn [sunrpc]
[26975.699380] RIP: 0010:0x1000
[26975.700092] Code: Unable to access opcode bytes at 0xfd6.
[26975.701146] RSP: 0018:ffffcf302110fa40 EFLAGS: 00010246
[26975.702070] RAX: ffff89b3b8e20000 RBX: 0000000000001000 RCX: 0000000000000000
[26975.703192] RDX: 0000000000001000 RSI: ffff89b3769b70d6 RDI: ffff89b3b8e21000
[26975.704179] RBP: 0000000000001000 R08: 0000000000001634 R09: ffffcf302110fd60
[26975.705052] R10: ffff89b3769b60d6 R11: 0000000000000000 R12: 0000000000000000
[26975.705835] R13: ffffcf302110fd60 R14: 00000000000016a0 R15: 0000000000001634
[26975.706530] FS:  0000000000000000(0000) GS:ffff89bc047b9000(0000) knlGS:0000000000000000
[26975.707243] CS:  0010 DS: 0000 ES: 0000 CR0: 0000000080050033
[26975.707727] CR2: 0000000000001000 CR3: 0000000914937006 CR4: 0000000000f72ef0
[26975.708269] PKRU: 55555554
[26975.708482] Call Trace:
[26975.708674]  <TASK>
[26975.708834]  ? _copy_to_iter+0x259/0x6b0
[26975.709098]  ? __check_object_size+0x86/0x1f0
[26975.709389]  ? __skb_datagram_iter+0x77/0x320
[26975.709657]  ? __pfx_simple_copy_to_iter+0x10/0x10
[26975.709936]  ? skb_copy_datagram_iter+0x33/0xa0
[26975.710189]  ? tcp_recvmsg_locked+0x7a9/0xa20
[26975.710436]  ? tcp_recvmsg+0x85/0x1e0
[26975.710642]  ? sock_recvmsg+0x97/0xa0
[26975.710821]  ? xs_sock_recvmsg.constprop.0+0x27/0x80 [sunrpc]
[26975.711127]  ? xs_read_stream_request.constprop.0+0x26f/0x4f0 [sunrpc]
[26975.711448]  ? sock_recvmsg+0x97/0xa0
[26975.711609]  ? kvm_clock_get_cycles+0x18/0x30
[26975.711793]  ? xs_read_stream.constprop.0+0x299/0x430 [sunrpc]
[26975.712044]  ? xs_stream_data_receive_workfn+0x6d/0x130 [sunrpc]
[26975.712301]  ? process_one_work+0x18e/0x350
[26975.712461]  ? worker_thread+0x165/0x2d0
[26975.712604]  ? __pfx_worker_thread+0x10/0x10
[26975.712761]  ? kthread+0xfb/0x260
[26975.712885]  ? __pfx_kthread+0x10/0x10
[26975.713023]  ? _raw_spin_unlock+0xe/0x30
[26975.713167]  ? finish_task_switch.isra.0+0x9c/0x310
[26975.713344]  ? __pfx_kthread+0x10/0x10
[26975.713483]  ? __pfx_kthread+0x10/0x10
[26975.713621]  ? ret_from_fork+0x22d/0x260
[26975.713764]  ? __pfx_kthread+0x10/0x10
[26975.713902]  ? ret_from_fork_asm+0x1a/0x30
[26975.714052]  </TASK>
[26975.714137] Modules linked in: rpcsec_gss_krb5 krb5 auth_rpcgss nfsv4 dns_resolver nfs lockd grace nfs_localio netfs nf_conntrack_netlink xt_MASQUERADE 
xfrm_user xfrm_algo xt_set ip_set xt_addrtype overlay nft_nat nft_fib_ipv6 nft_fib_ipv4 nft_fib nft_masq nft_ct nft_chain_nat wireguard libcurve25519 
libchacha20poly1305 libchacha ip6_udp_tunnel udp_tunnel libpoly1305 sunrpc nls_iso8859_1 nls_cp437 vfat fat af_packet pmt_crashlog cfg80211 rfkill xe 
intel_rapl_msr intel_rapl_common xt_conntrack xt_tcpudp intel_uncore_frequency_common ip6t_rpfilter intel_pmc_core pmt_telemetry drm_gpuvm ipt_rpfilter 
pmt_discovery drm_gpusvm_helper pmt_class drm_buddy intel_pmc_ssram_telemetry intel_vsec gpu_sched snd_hda_intel drm_exec xt_pkttype joydev polyval_clmulni 
iTCO_wdt drm_suballoc_helper ghash_clmulni_intel intel_pmc_bxt nft_compat aesni_intel drm_ttm_helper snd_hda_codec watchdog mousedev ttm rapl snd_hda_core 
drm_display_helper snd_intel_dspcfg evdev snd_intel_sdw_acpi snd_hwdep cec snd_pcm nf_tables i2c_algo_bit video
[26975.714176]  rtc_cmos i2c_i801 snd_timer input_leds i2c_smbus wmi nfnetlink psmouse snd led_class lpc_ich intel_agp i2c_mux vmgenid tiny_power_button 
mac_hid soundcore intel_gtt button sch_fq_codel serio_raw kvm_intel kvm xt_nat x_tables br_netfilter nf_nat bridge nf_conntrack fuse loop veth nf_defrag_ipv6 
stp irqbypass llc nf_defrag_ipv4 configfs vsock_loopback vmw_vsock_virtio_transport_common vmw_vsock_vmci_transport zram vsock vmw_vmci 842_decompress 
842_compress lz4hc_compress lz4_compress dmi_sysfs qemu_fw_cfg ext4 crc16 mbcache jbd2 sd_mod ahci libahci virtio_net libata net_failover virtio_scsi failover 
atkbd libps2 scsi_mod vivaldi_fmap virtio_pci i8042 virtio_pci_legacy_dev virtio_pci_modern_dev serio scsi_common ehci_pci uhci_hcd ehci_hcd virtio_gpu dm_mod 
virtio_console virtio_balloon virtio_rng virtio_dma_buf virtio virtio_ring efivarfs autofs4
[26975.719934] CR2: 0000000000001000
[26975.720060] ---[ end trace 0000000000000000 ]---

----------------------------------------------------------------------
Oops 2 of 4 (2026-10-25 03:21 EDT, EFI pstore 1792912925)
----------------------------------------------------------------------
[ 4098.063173] Oops: int3: 0000 [#1] SMP NOPTI
[ 4098.063190] CPU: 12 UID: 0 PID: 16825 Comm: kworker/u80:1 Tainted: G        W           6.18.57 #1-NixOS PREEMPT(lazy) 
[ 4098.063200] Tainted: [W]=WARN
[ 4098.063202] Hardware name: QEMU Standard PC (Q35 + ICH9, 2009), BIOS 4.2026.08-1 08/26/2026
[ 4098.063207] Workqueue: xprtiod xs_stream_data_receive_workfn [sunrpc]
[ 4098.063383] RIP: 0010:memcpy+0x11/0x20
[ 4098.063396] Code: 00 00 00 00 0f 1f 44 00 00 90 90 90 90 90 90 90 90 90 90 90 90 90 90 90 90 f3 0f 1e fa 66 90 48 89 f8 48 89 d1 f3 a4 c3 cc cc <cc> cc 66 
90 66 66 2e 0f 1f 84 00 00 00 00 00 90 90 90 90 90 90 90
[ 4098.063402] RSP: 0018:ffffccdd25ccfa40 EFLAGS: 00000286
[ 4098.063407] RAX: ffff8891bcee0000 RBX: 0000000000001000 RCX: 0000000000000000
[ 4098.063411] RDX: 00000000bcee0000 RSI: ffff888ab98970d6 RDI: ffff8891bcee1000
[ 4098.063415] RBP: 0000000000001000 R08: 0000000000001bdc R09: ffffccdd25ccfd60
[ 4098.063418] R10: ffff888ab98960d6 R11: 0000000000000000 R12: 0000000000000000
[ 4098.063421] R13: ffffccdd25ccfd60 R14: 0000000000001c48 R15: 0000000000001bdc
[ 4098.063425] FS:  0000000000000000(0000) GS:ffff889518d39000(0000) knlGS:0000000000000000
[ 4098.063430] CS:  0010 DS: 0000 ES: 0000 CR0: 0000000080050033
[ 4098.063433] CR2: 0000308f87b98000 CR3: 00000001114ab003 CR4: 0000000000f72ef0
[ 4098.063447] PKRU: 55555554
[ 4098.063450] Call Trace:
[ 4098.063455]  <TASK>
[ 4098.063463]  ? _copy_to_iter+0x259/0x6b0
[ 4098.063477]  ? __check_object_size+0x86/0x1f0
[ 4098.063507]  ? __skb_datagram_iter+0x77/0x320
[ 4098.063515]  ? __pfx_simple_copy_to_iter+0x10/0x10
[ 4098.063630]  ? skb_copy_datagram_iter+0x33/0xa0
[ 4098.063638]  ? tcp_recvmsg_locked+0x7a9/0xa20
[ 4098.063649]  ? tcp_recvmsg+0x85/0x1e0
[ 4098.063653]  ? sock_recvmsg+0x97/0xa0
[ 4098.063663]  ? xs_sock_recvmsg.constprop.0+0x27/0x80 [sunrpc]
[ 4098.063802]  ? xs_read_stream_request.constprop.0+0x26f/0x4f0 [sunrpc]
[ 4098.063904]  ? sock_recvmsg+0x97/0xa0
[ 4098.063907]  ? kvm_clock_get_cycles+0x18/0x30
[ 4098.063914]  ? xs_read_stream.constprop.0+0x299/0x430 [sunrpc]
[ 4098.064017]  ? xs_stream_data_receive_workfn+0x6d/0x130 [sunrpc]
[ 4098.064117]  ? process_one_work+0x18e/0x350
[ 4098.064125]  ? worker_thread+0x165/0x2d0
[ 4098.064130]  ? __pfx_worker_thread+0x10/0x10
[ 4098.064135]  ? kthread+0xfb/0x260
[ 4098.064140]  ? __pfx_kthread+0x10/0x10
[ 4098.064142]  ? _raw_spin_unlock+0xe/0x30
[ 4098.064148]  ? finish_task_switch.isra.0+0x9c/0x310
[ 4098.064154]  ? __pfx_kthread+0x10/0x10
[ 4098.064157]  ? __pfx_kthread+0x10/0x10
[ 4098.064160]  ? ret_from_fork+0x22d/0x260
[ 4098.064164]  ? __pfx_kthread+0x10/0x10
[ 4098.064167]  ? ret_from_fork_asm+0x1a/0x30
[ 4098.064174]  </TASK>
[ 4098.064177] Modules linked in: rpcsec_gss_krb5 krb5 auth_rpcgss nfsv4 dns_resolver nfs lockd grace nfs_localio netfs nf_conntrack_netlink xt_MASQUERADE 
xfrm_user xfrm_algo xt_set ip_set xt_addrtype overlay nft_nat nft_fib_ipv6 nft_fib_ipv4 nft_fib nft_masq nft_ct nft_chain_nat wireguard libcurve25519 
libchacha20poly1305 libchacha ip6_udp_tunnel udp_tunnel libpoly1305 sunrpc nls_iso8859_1 nls_cp437 vfat fat pmt_crashlog af_packet cfg80211 xe rfkill 
intel_rapl_msr intel_rapl_common intel_uncore_frequency_common drm_gpuvm intel_pmc_core drm_gpusvm_helper drm_buddy pmt_telemetry joydev gpu_sched 
pmt_discovery snd_hda_intel drm_exec pmt_class intel_pmc_ssram_telemetry drm_suballoc_helper iTCO_wdt intel_vsec xt_conntrack drm_ttm_helper intel_pmc_bxt 
mousedev ttm snd_hda_codec watchdog polyval_clmulni ghash_clmulni_intel drm_display_helper snd_hda_core xt_tcpudp aesni_intel cec rapl i2c_algo_bit 
ip6t_rpfilter video snd_intel_dspcfg psmouse evdev snd_intel_sdw_acpi ipt_rpfilter wmi rtc_cmos snd_hwdep snd_pcm snd_timer
[ 4098.064256]  i2c_i801 xt_pkttype i2c_smbus snd i2c_mux nft_compat lpc_ich vmgenid input_leds tiny_power_button soundcore button led_class mac_hid intel_agp 
intel_gtt serio_raw nf_tables nfnetlink sch_fq_codel kvm_intel kvm xt_nat x_tables br_netfilter nf_nat bridge nf_conntrack fuse nf_defrag_ipv6 stp veth loop 
llc nf_defrag_ipv4 irqbypass configfs vsock_loopback vmw_vsock_virtio_transport_common vmw_vsock_vmci_transport zram vsock 842_decompress vmw_vmci 842_compress 
lz4hc_compress lz4_compress dmi_sysfs qemu_fw_cfg ext4 crc16 mbcache jbd2 sd_mod virtio_net virtio_scsi net_failover failover ahci libahci atkbd libata libps2 
vivaldi_fmap i8042 virtio_pci serio virtio_pci_legacy_dev virtio_pci_modern_dev scsi_mod ehci_pci uhci_hcd scsi_common ehci_hcd virtio_gpu dm_mod 
virtio_console virtio_balloon virtio_rng virtio_dma_buf virtio virtio_ring efivarfs autofs4
[ 4098.064334] ---[ end trace 0000000000000000 ]---

----------------------------------------------------------------------
Oops 3 of 4 (2026-10-25 14:58 EDT, EFI pstore 1792954695)
----------------------------------------------------------------------
[41749.014846] BUG: unable to handle page fault for address: 0000000000001000
[41749.017399] #PF: supervisor instruction fetch in kernel mode
[41749.019679] #PF: error_code(0x0010) - not-present page
[41749.021457] PGD 0 P4D 0 
[41749.022279] Oops: Oops: 0010 [#1] SMP NOPTI
[41749.023463] CPU: 3 UID: 0 PID: 307896 Comm: kworker/u80:4 Tainted: G        W           6.18.57 #1-NixOS PREEMPT(lazy) 
[41749.024860] Tainted: [W]=WARN
[41749.025092] Hardware name: QEMU Standard PC (Q35 + ICH9, 2009), BIOS 4.2026.08-1 08/26/2026
[41749.025671] Workqueue: xprtiod xs_stream_data_receive_workfn [sunrpc]
[41749.026164] RIP: 0010:0x1000
[41749.026412] Code: Unable to access opcode bytes at 0xfd6.
[41749.026739] RSP: 0018:ffffd0c3649aba40 EFLAGS: 00010246
[41749.027041] RAX: ffff8ee32abc0000 RBX: 0000000000001000 RCX: 0000000000000000
[41749.027440] RDX: 0000000000001000 RSI: ffff8ee357b4f0d6 RDI: ffff8ee32abc1000
[41749.027810] RBP: 0000000000001000 R08: 000000000000108c R09: ffffd0c3649abd60
[41749.028165] R10: ffff8ee357b4e0d6 R11: 0000000000000000 R12: 0000000000000000
[41749.028512] R13: ffffd0c3649abd60 R14: 00000000000010f8 R15: 000000000000108c
[41749.028829] FS:  0000000000000000(0000) GS:ffff8ef286eb9000(0000) knlGS:0000000000000000
[41749.029171] CS:  0010 DS: 0000 ES: 0000 CR0: 0000000080050033
[41749.029413] CR2: 0000000000001000 CR3: 00000009bb624006 CR4: 0000000000f72ef0
[41749.029693] PKRU: 55555554
[41749.029800] Call Trace:
[41749.029899]  <TASK>
[41749.029987]  ? _copy_to_iter+0x259/0x6b0
[41749.030141]  ? __check_object_size+0x86/0x1f0
[41749.030312]  ? __skb_datagram_iter+0x77/0x320
[41749.030476]  ? __pfx_simple_copy_to_iter+0x10/0x10
[41749.030651]  ? skb_copy_datagram_iter+0x33/0xa0
[41749.030817]  ? tcp_recvmsg_locked+0x7a9/0xa20
[41749.030980]  ? tcp_recvmsg+0x85/0x1e0
[41749.031116]  ? sock_recvmsg+0x97/0xa0
[41749.031256]  ? xs_sock_recvmsg.constprop.0+0x27/0x80 [sunrpc]
[41749.031499]  ? xs_read_stream_request.constprop.0+0x26f/0x4f0 [sunrpc]
[41749.031754]  ? sock_recvmsg+0x97/0xa0
[41749.031889]  ? kvm_clock_get_cycles+0x18/0x30
[41749.032051]  ? xs_read_stream.constprop.0+0x299/0x430 [sunrpc]
[41749.032287]  ? xs_stream_data_receive_workfn+0x6d/0x130 [sunrpc]
[41749.032525]  ? process_one_work+0x18e/0x350
[41749.032680]  ? worker_thread+0x165/0x2d0
[41749.032824]  ? __pfx_worker_thread+0x10/0x10
[41749.032982]  ? kthread+0xfb/0x260
[41749.033107]  ? __pfx_kthread+0x10/0x10
[41749.033247]  ? _raw_spin_unlock+0xe/0x30
[41749.033392]  ? finish_task_switch.isra.0+0x9c/0x310
[41749.033571]  ? __pfx_kthread+0x10/0x10
[41749.033709]  ? __pfx_kthread+0x10/0x10
[41749.033848]  ? ret_from_fork+0x22d/0x260
[41749.033992]  ? __pfx_kthread+0x10/0x10
[41749.034131]  ? ret_from_fork_asm+0x1a/0x30
[41749.034284]  </TASK>
[41749.034369] Modules linked in: rpcsec_gss_krb5 krb5 auth_rpcgss nfsv4 dns_resolver nfs lockd grace nfs_localio netfs nf_conntrack_netlink xt_MASQUERADE 
xfrm_user xfrm_algo xt_set ip_set xt_addrtype overlay nft_nat nft_fib_ipv6 nft_fib_ipv4 nft_fib nft_masq nft_ct nft_chain_nat wireguard libcurve25519 
libchacha20poly1305 libchacha ip6_udp_tunnel udp_tunnel libpoly1305 sunrpc nls_iso8859_1 nls_cp437 vfat fat af_packet pmt_crashlog cfg80211 rfkill xe 
xt_conntrack xt_tcpudp ip6t_rpfilter intel_rapl_msr ipt_rpfilter intel_rapl_common xt_pkttype intel_uncore_frequency_common nft_compat intel_pmc_core drm_gpuvm 
pmt_telemetry drm_gpusvm_helper pmt_discovery pmt_class intel_pmc_ssram_telemetry drm_buddy intel_vsec gpu_sched iTCO_wdt polyval_clmulni snd_hda_intel 
ghash_clmulni_intel drm_exec intel_pmc_bxt aesni_intel evdev joydev drm_suballoc_helper watchdog drm_ttm_helper snd_hda_codec mousedev rapl nf_tables ttm 
snd_hda_core drm_display_helper snd_intel_dspcfg nfnetlink snd_intel_sdw_acpi cec sch_fq_codel snd_hwdep rtc_cmos
[41749.034409]  snd_pcm i2c_algo_bit input_leds snd_timer video i2c_i801 led_class wmi i2c_smbus psmouse snd mac_hid i2c_mux lpc_ich vmgenid tiny_power_button 
intel_agp soundcore button intel_gtt serio_raw kvm_intel kvm xt_nat x_tables nf_nat br_netfilter bridge nf_conntrack nf_defrag_ipv6 veth stp nf_defrag_ipv4 
loop irqbypass llc fuse configfs vsock_loopback vmw_vsock_virtio_transport_common vmw_vsock_vmci_transport vsock zram 842_decompress vmw_vmci 842_compress 
lz4hc_compress lz4_compress dmi_sysfs qemu_fw_cfg ext4 crc16 mbcache jbd2 sd_mod virtio_net net_failover ahci virtio_scsi failover libahci libata virtio_pci 
atkbd libps2 virtio_pci_legacy_dev vivaldi_fmap i8042 serio virtio_pci_modern_dev scsi_mod uhci_hcd ehci_pci scsi_common ehci_hcd virtio_gpu dm_mod 
virtio_console virtio_rng virtio_balloon virtio_dma_buf virtio virtio_ring efivarfs autofs4
[41749.040071] CR2: 0000000000001000
[41749.040197] ---[ end trace 0000000000000000 ]---

----------------------------------------------------------------------
Oops 4 of 4 (2026-10-26 03:13 EDT, EFI pstore 1792998837)
----------------------------------------------------------------------
[44120.737858] BUG: unable to handle page fault for address: 0000000000001000
[44120.741226] #PF: supervisor instruction fetch in kernel mode
[44120.743763] #PF: error_code(0x0010) - not-present page
[44120.744919] PGD ecfff3067 P4D ecfff3067 PUD 3b1e1f067 PMD 33c2ba067 PTE 0
[44120.746430] Oops: Oops: 0010 [#1] SMP NOPTI
[44120.747380] CPU: 19 UID: 0 PID: 310352 Comm: kworker/u80:0 Tainted: G        W           6.18.57 #1-NixOS PREEMPT(lazy) 
[44120.749683] Tainted: [W]=WARN
[44120.749796] Hardware name: QEMU Standard PC (Q35 + ICH9, 2009), BIOS 4.2026.08-1 08/26/2026
[44120.750090] Workqueue: xprtiod xs_stream_data_receive_workfn [sunrpc]
[44120.750360] RIP: 0010:0x1000
[44120.750484] Code: Unable to access opcode bytes at 0xfd6.
[44120.750678] RSP: 0018:ffffcdb1a7d0fa40 EFLAGS: 00010246
[44120.750867] RAX: ffff8bf3e8b60000 RBX: 0000000000001000 RCX: 0000000000000000
[44120.751122] RDX: 0000000000001000 RSI: ffff8be63f63f0ee RDI: ffff8bf3e8b61000
[44120.751377] RBP: 0000000000001000 R08: 0000000000001f12 R09: ffffcdb1a7d0fd60
[44120.751632] R10: ffff8be63f63e0ee R11: 0000000000000000 R12: ffffffff963f3b30
[44120.751887] R13: 0000000000001f12 R14: 0000000000001f96 R15: 0000000000000084
[44120.752141] FS:  0000000000000000(0000) GS:ffff8bf527cb9000(0000) knlGS:0000000000000000
[44120.752485] CS:  0010 DS: 0000 ES: 0000 CR0: 0000000080050033
[44120.752694] CR2: 0000000000001000 CR3: 0000000e7e35c002 CR4: 0000000000f72ef0
[44120.752951] PKRU: 55555554
[44120.753054] Call Trace:
[44120.753149]  <TASK>
[44120.753234]  ? _copy_to_iter+0x259/0x6b0
[44120.753385]  ? __check_object_size+0x86/0x1f0
[44120.753548]  ? __pfx_simple_copy_to_iter+0x10/0x10
[44120.753725]  ? __skb_datagram_iter+0x1ae/0x320
[44120.754035]  ? __pfx_simple_copy_to_iter+0x10/0x10
[44120.754668]  ? skb_copy_datagram_iter+0x33/0xa0
[44120.755305]  ? tcp_recvmsg_locked+0x7a9/0xa20
[44120.755970]  ? tcp_recvmsg+0x85/0x1e0
[44120.756544]  ? sock_recvmsg+0x97/0xa0
[44120.757172]  ? xs_sock_recvmsg.constprop.0+0x27/0x80 [sunrpc]
[44120.758299]  ? xs_read_stream_request.constprop.0+0x26f/0x4f0 [sunrpc]
[44120.759471]  ? sock_recvmsg+0x97/0xa0
[44120.760080]  ? kvm_clock_get_cycles+0x18/0x30
[44120.760777]  ? xs_read_stream.constprop.0+0x299/0x430 [sunrpc]
[44120.761723]  ? xs_stream_data_receive_workfn+0x6d/0x130 [sunrpc]
[44120.762622]  ? process_one_work+0x18e/0x350
[44120.763164]  ? worker_thread+0x165/0x2d0
[44120.763653]  ? __pfx_worker_thread+0x10/0x10
[44120.764143]  ? kthread+0xfb/0x260
[44120.764529]  ? __pfx_kthread+0x10/0x10
[44120.764925]  ? _raw_spin_unlock+0xe/0x30
[44120.765325]  ? finish_task_switch.isra.0+0x9c/0x310
[44120.765796]  ? __pfx_kthread+0x10/0x10
[44120.766141]  ? __pfx_kthread+0x10/0x10
[44120.766486]  ? ret_from_fork+0x22d/0x260
[44120.766815]  ? __pfx_kthread+0x10/0x10
[44120.767124]  ? ret_from_fork_asm+0x1a/0x30
[44120.767453]  </TASK>
[44120.767628] Modules linked in: nfsv3 nfs_acl rpcsec_gss_krb5 krb5 auth_rpcgss nfsv4 dns_resolver nfs lockd grace nfs_localio netfs nf_conntrack_netlink 
xt_MASQUERADE xfrm_user xfrm_algo xt_set ip_set xt_addrtype overlay nft_nat nft_fib_ipv6 nft_fib_ipv4 nft_fib nft_masq nft_ct nft_chain_nat wireguard 
libcurve25519 libchacha20poly1305 libchacha ip6_udp_tunnel udp_tunnel libpoly1305 sunrpc nls_iso8859_1 nls_cp437 vfat fat pmt_crashlog af_packet cfg80211 
rfkill xe xt_conntrack intel_rapl_msr intel_rapl_common xt_tcpudp intel_uncore_frequency_common intel_pmc_core ip6t_rpfilter pmt_telemetry pmt_discovery 
pmt_class ipt_rpfilter intel_pmc_ssram_telemetry intel_vsec drm_gpuvm iTCO_wdt joydev drm_gpusvm_helper intel_pmc_bxt drm_buddy polyval_clmulni 
ghash_clmulni_intel mousedev watchdog aesni_intel gpu_sched xt_pkttype rapl drm_exec snd_hda_intel evdev drm_suballoc_helper nft_compat snd_hda_codec i2c_i801 
drm_ttm_helper ttm snd_hda_core drm_display_helper psmouse i2c_smbus lpc_ich snd_intel_dspcfg i2c_mux cec
[44120.767700]  snd_intel_sdw_acpi snd_hwdep rtc_cmos i2c_algo_bit snd_pcm video nf_tables wmi input_leds vmgenid snd_timer led_class mac_hid nfnetlink snd 
serio_raw tiny_power_button intel_agp sch_fq_codel soundcore button intel_gtt kvm_intel kvm br_netfilter xt_nat x_tables bridge nf_nat nf_conntrack fuse 
nf_defrag_ipv6 stp loop veth nf_defrag_ipv4 irqbypass llc configfs vsock_loopback vmw_vsock_virtio_transport_common vmw_vsock_vmci_transport zram vsock 
842_decompress vmw_vmci 842_compress lz4hc_compress lz4_compress dmi_sysfs qemu_fw_cfg ext4 crc16 mbcache jbd2 sd_mod virtio_net ahci virtio_scsi net_failover 
libahci failover atkbd libata libps2 vivaldi_fmap i8042 virtio_pci serio virtio_pci_legacy_dev scsi_mod virtio_pci_modern_dev uhci_hcd ehci_pci scsi_common 
ehci_hcd virtio_gpu dm_mod virtio_console virtio_balloon virtio_rng virtio_dma_buf virtio virtio_ring efivarfs autofs4
[44120.774989] CR2: 0000000000001000
[44120.775115] ---[ end trace 0000000000000000 ]---

----------------------------------------------------------------------
/proc/cpuinfo, first CPU (guest; test boot, so fsrm is cleared)
----------------------------------------------------------------------
processor	: 0
vendor_id	: GenuineIntel
cpu family	: 6
model		: 151
model name	: 12th Gen Intel(R) Core(TM) i9-12900K
stepping	: 2
microcode	: 0x3e
cpu MHz		: 3187.200
cache size	: 16384 KB
physical id	: 0
siblings	: 20
core id		: 0
cpu cores	: 20
apicid		: 0
initial apicid	: 0
fpu		: yes
fpu_exception	: yes
cpuid level	: 32
wp		: yes
flags		: fpu vme de pse tsc msr pae mce cx8 apic sep mtrr pge mca cmov pat pse36 clflush mmx fxsr sse sse2 ss ht syscall nx pdpe1gb rdtscp lm rep_good 
nopl xtopology cpuid tsc_known_freq pni pclmulqdq vmx ssse3 fma cx16 pcid sse4_1 sse4_2 x2apic movbe popcnt tsc_deadline_timer aes xsave avx f16c rdrand 
hypervisor lahf_lm abm 3dnowprefetch cpuid_fault ssbd ibrs ibpb stibp ibrs_enhanced tpr_shadow flexpriority ept vpid ept_ad fsgsbase tsc_adjust bmi1 avx2 smep 
bmi2 erms invpcid rdseed adx smap clflushopt clwb sha_ni xsaveopt xsavec xgetbv1 xsaves user_shstk avx_vnni arat vnmi umip pku ospke waitpkg gfni vaes 
vpclmulqdq rdpid movdiri movdir64b md_clear serialize ibt flush_l1d arch_capabilities
vmx flags	: vnmi preemption_timer posted_intr invvpid ept_x_only ept_ad ept_1gb flexpriority apicv tsc_offset vtpr mtf vapic ept vpid unrestricted_guest 
vapic_reg vid shadow_vmcs pml ept_mode_based_exec tsc_scaling usr_wait_pause
bugs		: spectre_v1 spectre_v2 spec_store_bypass swapgs eibrs_pbrsb rfds bhi ibpb_no_ret spectre_v2_user
bogomips	: 6374.40
clflush size	: 64
cache_alignment	: 64
address sizes	: 46 bits physical, 48 bits virtual
power management:

----------------------------------------------------------------------
Host and VM
----------------------------------------------------------------------
Host: MSI PRO Z690-A WIFI (MS-7D25), i9-12900K, 4x DIMM, BIOS A.O0 (08/20/2026)
7.0.14-25-pve
pve-manager/9.2.21/4f6e0ac86f9e8c7f (running kernel: 7.0.14-25-pve)
QEMU emulator version 11.0.3 (pve-qemu-kvm_11.0.3-4)

qm config 101 (identifiers removed):
agent: 1,fstrim_cloned_disks=1
bios: ovmf
boot: order=scsi0;net0
cores: 20
cpu: host
hostpci0: mapping=dGPU,pcie=1
machine: q35
memory: 65536
name: pallene
numa: 0
onboot: 1
ostype: l26
protection: 1
scsihw: virtio-scsi-single
serial0: socket
sockets: 1
startup: order=2,up=30
vga: serial0
===

Guest kernel 6.18.57 #1-NixOS config:
CONFIG_PREEMPT_LAZY=y
CONFIG_PREEMPT_DYNAMIC=y
CONFIG_X86_KERNEL_IBT=y
CONFIG_RANDOMIZE_BASE=y
CONFIG_CALL_PADDING=y
CONFIG_MITIGATION_RETHUNK=y
CONFIG_MITIGATION_SLS=y
CONFIG_VMAP_STACK=y

----------------------------------------------------------------------
Host microcode across the BIOS update (tethys kernel log, first line of each boot)
----------------------------------------------------------------------
2026-10-21T16:41:39-04:00 tethys kernel: DMI: Micro-Star International Co., Ltd. MS-7D25/PRO Z690-A WIFI (MS-7D25), BIOS A.J1 08/15/2024
2026-10-21T16:41:39-04:00 tethys kernel: microcode: Current revision: 0x0000003a
2026-10-21T16:41:39-04:00 tethys kernel: microcode: Updated early from: 0x00000036
2026-10-24T18:29:18-04:00 tethys kernel: DMI: Micro-Star International Co., Ltd. MS-7D25/PRO Z690-A WIFI (MS-7D25), BIOS A.O0 08/20/2026
2026-10-24T18:29:18-04:00 tethys kernel: microcode: Current revision: 0x0000003e
2026-10-24T18:43:24-04:00 tethys kernel: DMI: Micro-Star International Co., Ltd. MS-7D25/PRO Z690-A WIFI (MS-7D25), BIOS A.O0 08/20/2026
2026-10-24T18:43:24-04:00 tethys kernel: microcode: Current revision: 0x0000003e

----------------------------------------------------------------------
Disassembly (on-disk vmlinux of the guest kernel, before alternatives)
----------------------------------------------------------------------
memcpy (at runtime with FSRM the jmp is patched to a 2-byte nop and the
return-thunk jmp to ret + int3 padding; the Code: line of oops 2 shows the
patched bytes: f3 0f 1e fa 66 90 48 89 f8 48 89 d1 f3 a4 c3 cc cc cc cc):

memcpy+0x000:	f3 0f 1e fa          	endbr64
memcpy+0x004:	eb 2a                	jmp    memcpy_orig
memcpy+0x006:	48 89 f8             	mov    %rdi,%rax
memcpy+0x009:	48 89 d1             	mov    %rdx,%rcx
memcpy+0x00c:	f3 a4                	rep movsb (%rsi),(%rdi)
memcpy+0x00e:	e9 7d 13 01 00       	jmp    __x86_return_thunk

_copy_to_iter, around the call (call at +0x254, return address +0x259):

_copy_to_iter+0x237:	48 2b 3d 9a 2b fc 00 	sub    0xfc2b9a(%rip),%rdi        # 0xffffffff8292f698
_copy_to_iter+0x23e:	48 c1 ff 06          	sar    $0x6,%rdi
_copy_to_iter+0x242:	48 c1 e7 0c          	shl    $0xc,%rdi
_copy_to_iter+0x246:	48 03 3d 9b 2b fc 00 	add    0xfc2b9b(%rip),%rdi        # 0xffffffff8292f6a8
_copy_to_iter+0x24d:	48 01 f7             	add    %rsi,%rdi
_copy_to_iter+0x250:	4b 8d 34 1a          	lea    (%r10,%r11,1),%rsi
_copy_to_iter+0x254:	e8 47 1d 74 00       	call   memcpy
_copy_to_iter+0x259:	48 8b 4c 24 10       	mov    0x10(%rsp),%rcx
_copy_to_iter+0x25e:	4c 8b 5c 24 08       	mov    0x8(%rsp),%r11
_copy_to_iter+0x263:	4c 8b 44 24 18       	mov    0x18(%rsp),%r8
_copy_to_iter+0x268:	4c 8b 14 24          	mov    (%rsp),%r10
_copy_to_iter+0x26c:	8b 51 08             	mov    0x8(%rcx),%edx
_copy_to_iter+0x26f:	48 8d 41 10          	lea    0x10(%rcx),%rax
_copy_to_iter+0x273:	49 01 eb             	add    %rbp,%r11
_copy_to_iter+0x276:	4c 8b 4c 24 20       	mov    0x20(%rsp),%r9
_copy_to_iter+0x27b:	48 39 d3             	cmp    %rdx,%rbx
_copy_to_iter+0x27e:	48 0f 43 c8          	cmovae %rax,%rcx
_copy_to_iter+0x282:	b8 00 00 00 00       	mov    $0x0,%eax
