Received: from mail-wm1-f99.google.com (mail-wm1-f99.google.com [209.85.128.99])
	(using TLSv1.2 with cipher ECDHE-RSA-AES128-GCM-SHA256 (128/128 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id AB33F3CC7D6
	for <linux-nfs@vger.kernel.org>; Wed, 16 Sep 2026 23:22:30 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=209.85.128.99
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1789600953; cv=none; b=tQeLuhPHvbq999YWt0NgImxewIAv+e8BoTNiud1cxJB39FDWI02U5MV1N0Hm3twRjvVKr8hkbYsliCxJvOB+8delDWcyMCPb/ebsipFyHdeTC6u6M45hKd/s+44XO+gCU+SnGTUYZKf/mIKbi9HkrJhB+lP1Dw9QnyNvTiVL0+k=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1789600953; c=relaxed/simple;
	bh=u0ldBGyhGC5y5y/oveUv9vi7r/DrK+TTyXkJ7VQ7FOM=;
	h=From:To:Cc:Subject:Date:Message-Id:MIME-Version; b=k/7r7ccjByydvkh/b80d6qFIF9F73ZxAWAPiFVN3g+lnI5SfD5/zPpqNe/Gk7ZEFTu/uh7lg0hy0k66M/M3Np6Bc/DJezwF8UrydpY/+Nd50q+DMLH/itd3+M6u3MKCtI/cp2YTOxRKCDI2cqKkc+sQVa4nlBYu7mfRwFtdTl4s=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dmarc=pass (p=reject dis=none) header.from=everpuredata.com; spf=pass smtp.mailfrom=everpuredata.com; dkim=pass (2048-bit key) header.d=everpuredata.com header.i=@everpuredata.com header.b=YVe8HI3g; arc=none smtp.client-ip=209.85.128.99
Authentication-Results: smtp.subspace.kernel.org; dmarc=pass (p=reject dis=none) header.from=everpuredata.com
Authentication-Results: smtp.subspace.kernel.org; spf=pass smtp.mailfrom=everpuredata.com
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=everpuredata.com header.i=@everpuredata.com header.b="YVe8HI3g"
Received: by mail-wm1-f99.google.com with SMTP id 5b1f17b1804b1-49e667fe31dso864875e9.0
        for <linux-nfs@vger.kernel.org>; Wed, 16 Sep 2026 16:22:30 -0700 (PDT)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=everpuredata.com; s=google; t=1789600949; x=1790205749; darn=vger.kernel.org;
        h=content-transfer-encoding:mime-version:message-id:date:subject:cc
         :to:from:from:to:cc:subject:date:message-id:reply-to:content-type;
        bh=+Mz/ooayWzSCDSVBUMPNqpX+5H+WrF58DE6bDY0Ctws=;
        b=YVe8HI3gSdqA4VfHua3kHrpht1RgKehJsRHnCL44wtfphJEy/Nxa+Rrsuof9dkJk7L
         mqY2DqmmYMU4Ll/4AtBwv1QRj3AhKIiMefvQrJbtTQyCzFb0Swlyx3snQPwbgFfez0ai
         /oEEJwSY4m/PB7LfvpoYox1xQXT7GnIb1zVR7pXPagC/ERhKaLEKDjtnfETG1mK1HAAg
         NeCXGWNLx4nfHtqxzcdJV6j8MaNHZAmDSwGh4HzEpG+a1kQggETJAGq1NglApZWj4vAF
         W0P/onrKZN+I+G6IqfBlEHCQzIq4oNtdxBhRnHnuc4/uCSkHahA7YL+PQrjnnK9smq3C
         R2AA==
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20260707; t=1789600949; x=1790205749;
        h=content-transfer-encoding:mime-version:message-id:date:subject:cc
         :to:from:x-gm-gg:x-gm-message-state:from:to:cc:subject:date
         :message-id:reply-to:content-type;
        bh=+Mz/ooayWzSCDSVBUMPNqpX+5H+WrF58DE6bDY0Ctws=;
        b=rMytLe1JZn5CUeIawRjGtSc3ByAli4al1HAZW0Yw6gmVGCzkv53SR6eezx7DPEse8M
         WFnaoGVb2KLn4o/IdpuANMu95rSXGVGOyY26v9pzjLt/kCTJ9SYGbclvDJ451GBYFb2/
         jiNA7tSb8Uhc1If7qr8qTnM3KxoRtJBRQLwyK7Rx3znVQ1JTL22Ihghon8BKSj1rVjnG
         lXxbOZCwIP7UygkISu16siTLNF7nLjDD1pXCP3Ig/EjIm0BzGCxf4yp8G4mkOcWMoM4R
         Q7XDWTlLxWAlKZHRNfnQwNtwWZbmk0hvScAH8q08xGe8vCtsauuhkRII70q2Igj5/fud
         zBhA==
X-Forwarded-Encrypted: i=1; AKwUvBwdK7Yr6/GF03ewSnuPqzrO1hvMSwWpwxx2FKBu+1Z2jw+PZT2K6Piq/xQwvGI2Mjn+GXHQlKSXjWY=@vger.kernel.org
X-Gm-Message-State: AFuF++n/UBANKoZ3NSjNDnXaY7Za04DdQImwpnTyQFVUOHTi7tL2kpbp
	09ihFQtsoa/rUiQ96AOTFPjGofG2ZHaUV3B6UhYXCWEBYTCPZpA0eZS3rwdoBnreUAyG/HOROPX
	vH8Hw3RJYdvQ0lfLsqQYH9/VXTGv+XhkjyrV+
X-Gm-Gg: AYBFou3Zb3/gEdfGJNnzU8JKO9tcQ5H81BymeAAUDXCuZkGS7xw3McikXyL6gZ7yC2F
	7e8LvLE/NRHpEniYJ5AA+v7rvHp+y/8AM2OXHEUCBKdkqJg8V6w84zxDcDtq0LxQ6qev2vS3ci9
	x1erHnD/VwL0eliX2sy/Au5QiWG0aaI92dZlVvI1B4wtqc570J9Q820if+pOcSepT83952cf+KE
	1ktj5p1cB7uDCxBWgBRcU7AIq2GDHI6rJZFMUxROlLJ5+fAhZWbUo2evRmgwiLne+CxzuO21pWz
	k1jjIun8VUeyLBA612C9R5x+RJ4/5Apc7/XkAuz1Uee5JkMqQ+Ti5no0urnzX92GZM7g7hKTZdR
	+lEDYi6xXLQqnLbWlmYP/MIpYIdaWn3Z38mC02PE=
X-Received: by 2002:a05:600c:8b35:b0:49e:6861:50f7 with SMTP id 5b1f17b1804b1-49eac4626c0mr46150355e9.5.1789600948882;
        Wed, 16 Sep 2026 16:22:28 -0700 (PDT)
Received: from c14-smtp-2023.dev.purestorage.com ([208.88.158.129])
        by smtp-relay.gmail.com with ESMTPS id 5b1f17b1804b1-49fbd2499eesm2213885e9.6.2026.09.16.16.22.28
        (version=TLS1_3 cipher=TLS_AES_256_GCM_SHA384 bits=256/256);
        Wed, 16 Sep 2026 16:22:28 -0700 (PDT)
X-Relaying-Domain: everpuredata.com
Received: from irdv-tmenninger.dev.purestorage.com (irdv-tmenninger.dev.purestorage.com [10.32.149.15])
	by c14-smtp-2023.dev.purestorage.com (Postfix) with ESMTPS id 6F4D834014B;
	Wed, 16 Sep 2026 16:22:27 -0700 (PDT)
From: Tim Menninger <tmenninger@everpuredata.com>
To: linux-mm@kvack.org
Cc: Chuck Lever <cel@kernel.org>,
	linux-nfs@vger.kernel.org,
	Jon Curley <jcurley@everpuredata.com>,
	Eric Badger <ebadger@everpuredata.com>
Subject: [SLUB] nfs_page cmpxchg_double_fail and perf lock perturbation on dual-socket NFS/RDMA
Date: Wed, 16 Sep 2026 23:22:27 +0000
Message-Id: <20260916232227.4098143-1-tmenninger@everpuredata.com>
X-Mailer: git-send-email 2.34.1
Precedence: bulk
X-Mailing-List: linux-nfs@vger.kernel.org
List-Id: <linux-nfs.vger.kernel.org>
List-Subscribe: <mailto:linux-nfs+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:linux-nfs+unsubscribe@vger.kernel.org>
MIME-Version: 1.0
Content-Transfer-Encoding: 8bit

Chuck Lever suggested I bring this to linux-mm after we found some SLUB
measurements we could not account for while investigating an NFS/RDMA
throughput regression.

The original NFS discussion is here for context:

    https://lore.kernel.org/linux-nfs/0e2f9688-097c-4bb9-a7ec-82b41bdb3653@slotpi15m67/

The NFS regression itself has been separated from this issue. What
remains interesting here is the behavior of the nfs_page slab cache on
this machine, particularly the measurements with and without perf lock.

The system is:

    Intel Xeon Silver 4516Y+
    2 sockets
    24 cores/socket
    2 threads/core
    96 logical CPUs

    NUMA node0 CPUs: 0-23,48-71
    NUMA node1 CPUs: 24-47,72-95

The workload is a high-throughput NFS/RDMA direct-read workload using
1 MiB I/O, 160 threads, and iodepth 64.

The relevant debug options are all disabled:

    # CONFIG_KASAN is not set
    # CONFIG_PROVE_LOCKING is not set
    # CONFIG_LOCK_STAT is not set
    # CONFIG_DEBUG_SPINLOCK is not set
    # CONFIG_DEBUG_LIST is not set

All measurements below were collected on the unpatched base kernel:

    $ git rev-parse HEAD
    940de590b839f71d6dc846160534bf202401b8b7

    $ uname -r
    7.3.0-rc1-mainline+

The initial observation was a high apparent contention rate on the
nfs_page slab's list_lock. In 10-second perf-lock captures I was seeing
roughly 4.5M contended acquisitions and about 170-185 us of average
reported wait.

Chuck reproduced a similar acquisition rate on a single-node EPYC
system, but saw only about 7 ns average wait and fewer than 100
cmpxchg_double_fail events over a corresponding interval. He suggested
checking cmpxchg_double_fail because __slab_free() drops list_lock and
retries when the freelist cmpxchg fails.

I repeated the measurements in three placement configurations:

    A. workload unpinned, CQs all on node0
    B. workload pinned to node0, CQs all on node0
    C. workload unpinned, CQs balanced across the nodes

Without perf lock, throughput is similar in all three:

    A. unpinned / CQs node0:       ~45.5 GB/s
    B. node0 pinned / CQs node0:   ~45.7 GB/s
    C. unpinned / balanced CQs:    ~45.5 GB/s

During the perf-lock captures, throughput is approximately 25 GB/s.

For each instrumented 10-second window I ran:

    sudo perf lock record -a -g -o "$D/perf-locks.data" -- sleep 10
    mpstat -P ALL 1 10

Before and after the same window I sampled the counters under:

    /sys/kernel/slab/nfs_page/

I also collected separate 10-second counter and mpstat windows under
the same workload configurations without perf lock.

The resulting slab counter deltas were:

                            A               B                 C
                     unpinned/node0    node0/node0   unpinned/balanced

    free_fastpath
    instrumented        655,917,745    457,936,140       328,670,030
    uninstrumented       34,906,233    119,984,226        59,469,931

    free_slowpath
    instrumented        236,735,724      7,720,917       270,716,506
    uninstrumented       85,039,753          2,814        60,145,870

    sheaf_flush
    instrumented         39,842,700     42,706,800         8,341,440
    uninstrumented        1,286,400     13,487,700           887,700

    barn_put_fail
    instrumented            663,994        711,745           139,037
    uninstrumented           21,464        224,762            14,765

    barn_get_fail
    instrumented          4,609,925        840,344         4,651,225
    uninstrumented        1,438,643        224,787         1,017,006

    cmpxchg_double_fail
    instrumented             70,524          8,077            28,062
    uninstrumented            7,471            713             1,503

    alloc_slowpath
    all cases                     0              0                 0

The SLUB counter profile changes substantially with perf lock despite
the lower NFS throughput, and the exact mix depends strongly on
placement.

The uninstrumented node0/node0 run also reproduces the barn/sheaf
relationship Chuck pointed out earlier. The nfs_page sheaf capacity is
60:

    sheaf_flush / 60 = 13,487,700 / 60 = 224,795
    barn_put_fail                      = 224,762

The placement dependence of free_slowpath is also large. It falls from
about 85M events per 10 seconds in the unpinned/node0 case to 2,814 in
the node0/node0 case.

The reported perf-lock result, however, is similar across all three
placements:

                         contentions    total wait    average wait
    unpinned/node0         4,782,839      14.39 min      180.47 us
    node0/node0            4,582,012      14.13 min      185.05 us
    unpinned/balanced      4,572,196      12.81 min      168.14 us

I also revisited an inconsistency Chuck noticed in my earlier
measurements. Previously I had compared aggregate perf-lock wait from
one 10-second capture with CPU utilization measured during a different
window.

I now have paired 10-second mpstat samples for each placement, with and
without perf lock. The node values below are averages of the per-CPU
%idle values for the CPUs in each NUMA node:

                                  system-wide       node0       node1
                                  %idle             %idle       %idle

    A. unpinned / CQs node0
       uninstrumented                 31.46           8.0        54.6
       instrumented                    3.60           0.06        7.1

    B. node0 pinned / CQs node0
       uninstrumented                 84.26          69.2        99.4
       instrumented                   12.07          10.4        13.8

    C. unpinned / balanced CQs
       uninstrumented                 66.86          66.7        66.9
       instrumented                   14.83          19.0        10.6

This resolves the accounting inconsistency in my earlier measurements.
The large aggregate perf-lock wait and high idle percentage had come
from different windows. In the aligned samples, the system is much
busier during the perf-lock capture than in the corresponding
uninstrumented run.

I am still unsure how representative the reported ~170-185 us average
wait is of the uninstrumented workload.

The remaining number I am less sure how to interpret is
cmpxchg_double_fail. In the uninstrumented windows I see:

    unpinned / CQs node0:       7,471 / 10 sec
    node0 pinned / CQs node0:     713 / 10 sec
    unpinned / balanced CQs:    1,503 / 10 sec

compared with fewer than 100 in Chuck's test.

I understand that cmpxchg_double_fail counts failed slab freelist
updates rather than failed logical frees, so I am not sure what the
appropriate denominator is here. In particular, the node0/node0 case
still has 713 failures while sustaining full throughput and only 2,814
free_slowpath events over the interval.

My questions are:

1. Do the uninstrumented cmpxchg_double_fail rates above look abnormal
   for this workload/topology, or are they within the range one would
   expect from this degree of concurrency and NUMA placement?

2. Is there a less invasive way you would recommend measuring the
   nfs_page list_lock/freelist contention? I would like to distinguish
   the steady-state behavior from what is observed during the perf-lock
   capture.

Thanks,
Tim
