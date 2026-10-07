Received: from mail-oo1-f44.google.com (mail-oo1-f44.google.com [209.85.161.44])
	(using TLSv1.2 with cipher ECDHE-RSA-AES128-GCM-SHA256 (128/128 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 44BE44E73DF
	for <linux-nfs@vger.kernel.org>; Wed,  7 Oct 2026 19:59:38 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=209.85.161.44
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1791403181; cv=none; b=q1Edo2KCOn6JV0taCQXIn4N8TFca7DEbGOsjJ/qBmXa2kGxHuxGuxsqeL5udWJ3Zal+oKfjzVCdhn/VNaEdX5rE0FA1oSvjKwTVG9lXF1NLsNWT1VI6PVMCCyl4fE+RP2L0PFttGNt+6pa1IBUrwPOXjSejvqOpqaydAA3xVDNc=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1791403181; c=relaxed/simple;
	bh=0pPmeZyp251Lr0x3886a9pgXCkpW4jNoTcJsPjHFl9g=;
	h=From:To:Cc:Subject:Date:Message-ID:MIME-Version; b=NNBdLr2ft0YT2cGtyckYg3GtbwMuruAcoMEYtsKEyZ9QnmMxl+Lze2Ole96SAAxnrWZBiEwE9/1bcpr/sU4zpf00mAiq6m2XrXmwu+shb7Mns7XWyfOqQD782lROthLIfyIFe0YRs9+Wr4KmUOQl5ZcU++7caHJbuQIZXElt0KI=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dmarc=pass (p=quarantine dis=none) header.from=hammerspace.com; spf=pass smtp.mailfrom=hammerspace.com; dkim=pass (2048-bit key) header.d=hammerspace.com header.i=@hammerspace.com header.b=AEcc0tmI; arc=none smtp.client-ip=209.85.161.44
Authentication-Results: smtp.subspace.kernel.org; dmarc=pass (p=quarantine dis=none) header.from=hammerspace.com
Authentication-Results: smtp.subspace.kernel.org; spf=pass smtp.mailfrom=hammerspace.com
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=hammerspace.com header.i=@hammerspace.com header.b="AEcc0tmI"
Received: by mail-oo1-f44.google.com with SMTP id 006d021491bc7-6de1fd5f572so1017106eaf.3
        for <linux-nfs@vger.kernel.org>; Wed, 07 Oct 2026 12:59:38 -0700 (PDT)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=hammerspace.com; s=google; t=1791403177; x=1792007977; darn=vger.kernel.org;
        h=content-transfer-encoding:mime-version:message-id:date:subject:cc
         :to:from:from:to:cc:subject:date:message-id:reply-to:content-type;
        bh=RlvmTENnWdcvYsu4QTibTscykQ0vwVEqV2HgUrxeKRU=;
        b=AEcc0tmIii4yPMyuUwsLkDOpjstv2xxCG4of+/7l0cZ199AW8ykghTTwgL2zuoDMn4
         bzAPHF1QxjLMl/+q0FnO/PxZJ7SO+vQQ3N6QfYOKBYHox4poeBiXbraGpYRN1wUmMl3Y
         /3mAejKZ8AI//NFAs77jvPcP9hSpDMY2I1BjTgKNwZ2hJyEMhOlQpbprntXyEIJPxHWM
         YmfCD2ZMVMoTNkySxMNk6G+ApO/Po2vTx20wfsgukXgeWSCJ5y/uPYCw7h+CI6D4fjsF
         Mf3BqDLLvjnHQ9JBgoUyrdS/seo4PA1qoZWNceGErOVLnyUkAw1p3lYBJFKPsunTWN0Q
         CDVA==
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20260707; t=1791403177; x=1792007977;
        h=content-transfer-encoding:mime-version:message-id:date:subject:cc
         :to:from:x-gm-gg:x-gm-message-state:from:to:cc:subject:date
         :message-id:reply-to:content-type;
        bh=RlvmTENnWdcvYsu4QTibTscykQ0vwVEqV2HgUrxeKRU=;
        b=MLnl4phf+TPgectMAd2FOtaTYW6aG7eWerKuTpY7v1DvKWmYNflzoiij3o7n5tpGt5
         AY2MBveZTl+sm9uTjdtblBGE353M9N6P38FK2+BNcmAMszjaqPp6GEIdFtDmgjVWgjFR
         LSNeH3/gKoS3c4Lap/TPQVe64wxZO/sPcW97xddA5WIrTXYarvEYihyPjEZdxtlKTz3y
         WJQ3OKcwlSvxL/sOyvuxfP/v5BJZIVrwYCMpM9MUsuaIzduwYbuBvy/DjiusgrXPHfJp
         OOUmDmY6jGcc+B+tju/Ck5dUAp5LnJAvc6nv0W4oBP3yqCXkg1efIlq4XeyAZa9Wketw
         HlMA==
X-Gm-Message-State: AFuF++nF2okTy72ksjGhJMIgR6BKZUxNmc0mCbr/TOjDI/Ys34bvfyNb
	m9DzuJdEkIZBv5vf9RtFipOhwI4IIOq9YQK4vQU5bD3kUuiE8x1Oh4UF4NYCBah6kYknAYRTk28
	UhymH
X-Gm-Gg: AYBFou2MZzckTNFKDftkVC45ErcghR5OmZu4nPeDoOSOrh4o79XMaM9vRxQH8AePtlx
	9mgYp71HNwSGF2z2QVJJfMbj2yPzGGx24DQMBNmWtXlXGB++EkNktqmxxQAWxN2dTKIGYlwYqga
	r7aMKlFLV0GIEBKh6p0zwQ04kZITxgDN+PkaLGFGrUp6usVpdJ6mEALfFcqc6Zc6PiSbmJVD/dt
	t1OW6jEXYDv1VEdpkL/2D7RUBFYurtbvbAy9uS42IVEaS7QM1DCffHjoqZvW0+WiOeyT6JyeBGf
	S6qMYmB5+7uAGRILvFIEFzObbnEVXDrHunrJOnl8cTosjjhI1tm4AWytVWjGJayD7R1R6dChHIu
	clVa7b5dIFsZnpyEKR6/6C1kq+7JfoUgWUM8GEr9nGx7OFdPJ+rjLzDlT8N4wpEMQk/g3I5TeYN
	DM8FUBPryWAQJeudXV8wuopi6VwudZYVahhC5tG0aczltII47OpcoapjMqfOBSl0MRqzzbtbXoO
	BzkfVP0M8ULMXUto2At7c6A0XM3ej4NdVIArGYzvg==
X-Received: by 2002:a05:6820:f011:b0:6dd:3105:1f86 with SMTP id 006d021491bc7-6e7a98932efmr3318026eaf.62.1791403176819;
        Wed, 07 Oct 2026 12:59:36 -0700 (PDT)
Received: from bcodding.csb.hammerspace.com ([66.97.168.37])
        by smtp.gmail.com with ESMTPSA id 586e51a60fabf-4a274c9c520sm1084285fac.16.2026.10.07.12.59.35
        (version=TLS1_3 cipher=TLS_AES_256_GCM_SHA384 bits=256/256);
        Wed, 07 Oct 2026 12:59:36 -0700 (PDT)
From: Benjamin Coddington <ben.coddington@hammerspace.com>
To: Chuck Lever <cel@kernel.org>,
	Jeff Layton <jlayton@kernel.org>,
	NeilBrown <neil@brown.name>
Cc: linux-nfs@vger.kernel.org,
	Daire Byrne <daire@dneg.com>,
	bpf@vger.kernel.org,
	Martin KaFai Lau <martin.lau@linux.dev>
Subject: [PATCH RFC v2 0/9] SUNRPC: dispatch ready transports round-robin across clients, classes from BPF
Date: Wed,  7 Oct 2026 15:59:25 -0400
Message-ID: <cover.1791402701.git.bcodding@hammerspace.com>
X-Mailer: git-send-email 2.53.0
Precedence: bulk
X-Mailing-List: linux-nfs@vger.kernel.org
List-Id: <linux-nfs.vger.kernel.org>
List-Subscribe: <mailto:linux-nfs+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:linux-nfs+unsubscribe@vger.kernel.org>
MIME-Version: 1.0
Content-Transfer-Encoding: 8bit

From: Benjamin Coddington <bcodding@hammerspace.com>

This is v2 of [3], with the change I floated in that thread: the kernel
no longer decides which transports belong together.  By default nothing
changes.  An administrator who wants peers grouped loads a small BPF
program that returns a class for each accepted connection, and the pool
takes turns across classes.

What's different from v1
------------------------

The table I described on [3] became a hook.  Instead of a kernel table
of address prefixes, a netlink interface for it and an nfs-utils side,
sunrpc registers a struct_ops with one callback: given the accepted
svc_xprt, return a class.  0 means the anonymous client (shared with
everything unclassified, today's order among them); any other number is
a class every transport returning it shares; a flag bit on top means
"and one client per peer address within that class".  So "all movers are
one class, everybody else per host" is two entries in a prefix map, and
the posted v1 behaviour is one entry.

The hook runs once per accepted connection, in process context, after
TCP and RDMA have both set the peer address.  Nothing runs per request.
No program loaded means every transport is on the
anonymous client, and with patch 6 the pool uses its old flat queue
until a classifier attaches, so the dispatch path is today's code for
anyone who hasn't asked for anything.  That's the answer to Chuck's cost
question from [3]: measured on bare metal the two-level queue cost about
half a microsecond a dispatch (1.7% at 484k IOPS on one client's eight
connections); with no program it now costs a static branch on enqueue
and an empty-queue test on dequeue.

Attaching is a struct_ops link, bound to the attaching task's network
namespace, one per namespace.  A second attach gets -EBUSY, a link
update replaces the program, closing the link removes it, and a
namespace that exits leaves its link with nothing behind.  Transports
keep the class they got at accept; a new program only affects new
connections.  The reference program and the attach tests are in the BPF
selftests (patch 7).  svc-classify (patch 8) attaches the prefix
classifier and manages its map by address prefix, so an administrator
never touches bpftool.  The page in patch 9,
Documentation/filesystems/nfs/rpc-server-clients.rst, has the class
word, the install procedure, and six class maps with the share each one
gives its clients.

Still not in here: moving a transport between clients, so a v4.1
clientid key, which Chuck asked about on [3], is not in this version.
A multi-homed host or an IPv6 host with a prefix's worth of addresses
is handled by the prefix map instead.

Also from the [3] review: control events (accept, close, handshake) go
ahead of data within a client (patch 5), and the dequeue tracepoint
prints the class (patch 4).

Numbers
-------

The dispatch numbers are the v1 series' on a two-socket box (2 x Xeon
6542Y, 96 threads, no KASAN), from [3].  The dispatch code is the same
here: v2 puts the classifier in front of it, and the flat queue behind
a static branch when nothing is attached.  Loopback, NFSv3, 16 threads,
10 ms injected service time with 50% jitter.  A is v7.2, B the series.
v4.1 is within 2% in every cell.

One interactive client (bursts of 32) against one host with K
backlogged connections, burst completion p50 in ms, floor 37:

    K             4      8     16     32
    A            70    195    351    671
    B            56     62     61     63

    N (K=16)      1      8     32     64     96    128
    A            21     98    350    690   1035   1365
    B            11     31     62    103    144    179

    M hosts x 4   1      2      4      8
    A            70    192    351    670
    B            57     81    121    192

    S: 2x8 vs K, share   4      8     16     32
    A                 41.0   20.0   11.1    5.9
    B                 50.3   50.0   50.0   50.0

A real NFSv3 client walking 500 files against a 16-connection
aggressor: 37.8 s on A, 2.5 s on B, 0.12 s alone on both.

Classes.  The v1 kernel keyed on source address, so on [3] I emulated
"all movers are one class" by giving six movers one address.  With this
series that's one map entry (the movers' prefix -> 1, everything else
per address), and the six-address column is what "everything per
address" gives.  Six movers at 4 or 8 connections each against
customers, customer share of dispatches:

                                 A           per address   movers one class
    one customer, 1 conn x 16    4.0 / 2.0   14.3 / 14.3   49.9 / 49.9
    one customer, 4 x 4         14.3 / 7.7   14.3 / 14.3   49.8 / 49.7
    four customers, 4 x 4 each  40 / 25      40 / 40       80 / 80

Burst of 32 against M busy hosts, p50 ms: hosts on their own addresses
57 81 121 192, as one class 56 62 62 62.  A: 71 193 348 673 either way.

Cost.  With a classifier attached, dispatch takes two or three more
lock-free queue operations per request.  On the same box that's about half a
microsecond when the enqueue and the dequeue run on different cores,
fio 4k O_DIRECT randread over loopback, 5 x 20s:

                                   A        B
    nconnect=1, 16 jobs        152.8k   152.2k   -0.4%
    nconnect=8, 16 jobs        483.8k   475.5k   -1.7%
    nconnect=8, 64 jobs        584.2k   581.0k   -0.5%

The serial walk and 4 jobs on one connection don't move.  With no
classifier attached the pool is on its old flat queue (patch 6).  I only
have my VM for that path so far (KASAN, 10 vCPUs, loopback, the same
fio), and there the no-program kernel measures the same as v7.2 within
the run-to-run spread: 16 jobs 94.9k vs 95.5k, 64 jobs 138.6k vs 139.0k.
So the static branch adds nothing I can see, but that's a VM number.

Not tested: RDMA.  The hook sits in the accept path TCP and RDMA share,
but I could not bring a soft-RoCE listener up on the VM.

Daire - the same nine patches on v7.2 (plus the wake fix) are at
https://github.com/bcodding/linux branch nfsd-clientq-v2-7.2 if you
want to run it; the loader builds from tools/net/sunrpc/svc-classify in
that tree.

The series is on nfsd-testing at 56589cdb5881, which already has the
svc_clean_up_xprts() wake fix from [3].

  patch 1  track clients by class, no change to dispatch
  patch 2  dispatch round-robin across clients
  patch 3  the struct_ops hook
  patch 4  class in the svc_xprt_dequeue tracepoint
  patch 5  control events ahead of data within a client
  patch 6  flat queue while no classifier is attached
  patch 7  selftests: the prefix program and the attach tests
  patch 8  tools/net/sunrpc/svc-classify: the prefix classifier and its
           loader (load/replace/unload, add/del/list by prefix, status)
  patch 9  Documentation: the model, the class word, installing a
           classifier with svc-classify, six class maps and the share
           each gives, how it works underneath

[1] https://lore.kernel.org/linux-nfs/cover.1780498019.git.bcodding@hammerspace.com
[2] https://lore.kernel.org/linux-nfs/cover.1782314746.git.bcodding@hammerspace.com
[3] https://lore.kernel.org/linux-nfs/cover.1790953694.git.bcodding@hammerspace.com

Benjamin Coddington (9):
  SUNRPC: track service clients by class
  SUNRPC: dispatch ready transports round-robin across clients
  SUNRPC: add a BPF struct_ops hook to classify accepted transports
  SUNRPC: report the transport's class in the svc_xprt_dequeue
    tracepoint
  SUNRPC: dispatch control events ahead of data within a client
  SUNRPC: keep the single transport queue while no classifier is
    attached
  selftests/bpf: add svc_classifier tests
  tools/net/sunrpc: add svc-classify, a prefix classifier and its loader
  Documentation: describe RPC server transport classes and the BPF
    classifier

 Documentation/filesystems/nfs/index.rst       |   1 +
 .../filesystems/nfs/rpc-server-clients.rst    | 394 ++++++++++++++++++
 include/linux/sunrpc/svc.h                    |  72 +++-
 include/linux/sunrpc/svc_xprt.h               |  30 ++
 include/trace/events/sunrpc.h                 |  11 +-
 net/sunrpc/Kconfig                            |  12 +
 net/sunrpc/Makefile                           |   1 +
 net/sunrpc/netns.h                            |   4 +
 net/sunrpc/sunrpc_syms.c                      |   4 +
 net/sunrpc/svc.c                              |  36 ++
 net/sunrpc/svc_classify.c                     | 210 ++++++++++
 net/sunrpc/svc_xprt.c                         | 281 ++++++++++++-
 tools/net/sunrpc/svc-classify/.gitignore      |   1 +
 tools/net/sunrpc/svc-classify/Makefile        |  65 +++
 tools/net/sunrpc/svc-classify/svc-classify.c  | 357 ++++++++++++++++
 .../sunrpc/svc-classify/svc_classify.bpf.c    |  83 ++++
 tools/testing/selftests/bpf/config            |   2 +
 .../selftests/bpf/prog_tests/svc_classifier.c | 104 +++++
 .../selftests/bpf/progs/bpf_svc_classifier.c  |  80 ++++
 19 files changed, 1724 insertions(+), 24 deletions(-)
 create mode 100644 Documentation/filesystems/nfs/rpc-server-clients.rst
 create mode 100644 net/sunrpc/svc_classify.c
 create mode 100644 tools/net/sunrpc/svc-classify/.gitignore
 create mode 100644 tools/net/sunrpc/svc-classify/Makefile
 create mode 100644 tools/net/sunrpc/svc-classify/svc-classify.c
 create mode 100644 tools/net/sunrpc/svc-classify/svc_classify.bpf.c
 create mode 100644 tools/testing/selftests/bpf/prog_tests/svc_classifier.c
 create mode 100644 tools/testing/selftests/bpf/progs/bpf_svc_classifier.c

-- 
2.53.0

