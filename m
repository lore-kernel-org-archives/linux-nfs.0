Received: from foss.arm.com (foss.arm.com [217.140.110.172])
	by smtp.subspace.kernel.org (Postfix) with ESMTP id 270523806CE;
	Tue,  6 Oct 2026 09:01:00 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=217.140.110.172
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1791277263; cv=none; b=pzVgGNmjdAdkIfq2j685yQ7ivxliR8IpU7z7GIY7WyxL8yFjvVbbGMBpsU++aIrBDF1drj7b6L9rmxzChYGie3gJfvzjZmkWuKgoeQVIILqFvSG4wduV4l706azqkZQu/WiVvJG6bYTTU1y0SzqUQeGkS0dEkw1Bfm5ymUmG0Co=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1791277263; c=relaxed/simple;
	bh=Iwd2tfYTmlt/l0EpeJOvp//1Eq1OPqBlm4ThVSt9wPE=;
	h=From:To:Cc:Subject:Date:Message-ID:MIME-Version; b=Gfk7awB9zhX90V0Xa5svrSrJgnZbEFj8mztOm6FZegAS8sy7zK1skqlZN/0SZlrgZrQq36SuJbp4JDsSHFLxZyOqC8Wb4p4lUC9/2vLrQfJu3LxYpFc3e5UNaHX3fs+HDUKGJhb+9cZ84bNo/bVOB/a3QhpQibWUpduzmz50fnY=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dmarc=pass (p=none dis=none) header.from=arm.com; spf=pass smtp.mailfrom=arm.com; dkim=pass (1024-bit key) header.d=arm.com header.i=@arm.com header.b=Lkh7HC57; arc=none smtp.client-ip=217.140.110.172
Authentication-Results: smtp.subspace.kernel.org; dmarc=pass (p=none dis=none) header.from=arm.com
Authentication-Results: smtp.subspace.kernel.org; spf=pass smtp.mailfrom=arm.com
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (1024-bit key) header.d=arm.com header.i=@arm.com header.b="Lkh7HC57"
Received: from usa-sjc-imap-foss1.foss.arm.com (unknown [10.121.207.14])
	by usa-sjc-mx-foss1.foss.arm.com (Postfix) with ESMTP id 0BDF81516;
	Tue,  6 Oct 2026 02:00:57 -0700 (PDT)
Received: from e132076.cambridge.arm.com (e132076.arm.com [10.2.197.107])
	by usa-sjc-imap-foss1.foss.arm.com (Postfix) with ESMTPA id B5F9C3F86F;
	Tue,  6 Oct 2026 02:00:58 -0700 (PDT)
DKIM-Signature: v=1; a=rsa-sha256; c=simple/simple; d=arm.com; s=foss;
	t=1791277260; bh=Iwd2tfYTmlt/l0EpeJOvp//1Eq1OPqBlm4ThVSt9wPE=;
	h=From:To:Cc:Subject:Date:From;
	b=Lkh7HC57qU32WtFqHB6ARSHn12qBPstQTKP9ycabog/ruDz/CfpY5YXfNFQzJzKI0
	 mU5119dB5zNBKrUEs0EYkqHnALXYec20eReViv6eAkezT2OeJE04AGYYGweoRoeQ1q
	 qgMgwAfyLwZcXax37OGXysHEsLxhTrfb6yiAylTk=
From: J Louis Kaplan <Louis.Kaplan@arm.com>
To: cel@kernel.org,
	dai.ngo@oracle.com,
	jlayton@kernel.org,
	neil@brown.name,
	okorniev@redhat.com,
	tom@talpey.com
Cc: linux-nfs@vger.kernel.org,
	linux-rdma@vger.kernel.org,
	anna@kernel.org,
	jgg@ziepe.ca,
	leon@kernel.org,
	trondmy@kernel.org,
	J Louis Kaplan <Louis.Kaplan@arm.com>
Subject: [RFC PATCH 0/6] Improve NFS server direct throughput with passthrough enabled
Date: Tue,  6 Oct 2026 10:00:22 +0100
Message-ID: <20261006090028.3412544-1-Louis.Kaplan@arm.com>
X-Mailer: git-send-email 2.43.0
Precedence: bulk
X-Mailing-List: linux-nfs@vger.kernel.org
List-Id: <linux-nfs.vger.kernel.org>
List-Subscribe: <mailto:linux-nfs+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:linux-nfs+unsubscribe@vger.kernel.org>
MIME-Version: 1.0
Content-Transfer-Encoding: 8bit

For NFSoRDMA using RoCE, and with IOMMU passthrough enabled, use of a
64KiB base page size was found to provide higher NFS read throughput
than a 4KiB base page size. This patch series recovers some of that
throughput with a 4k base page size by opportunistic use of large folios
for the svc reply buffer.

To better understand the performance implications of this patch series,
an ablation test was run which added a single line to limit bio_vec
coalescing to a single 4 KiB page. Large-folio allocation was kept in
place. This brought direct-read throughput in configuration A (see
below) back to approximately plain-kernel levels. This indicates that
coalescing strongly contributes to the observed throughput gains with
passthrough enabled.

Tests with patch series on Linux 7.2 commit 8d3ae59288f1
========================================================

(The below tests were done before minor internal revisions.)

Performance:
fio read benchmark results on an NFSv4 mount are shown below with
various tested boot commandlines on the NFS server. NFSoRDMA was used
for all tests.

Configurations B-D explicitly disable passthrough as I wanted to confirm
that no significant regressions to the passthrough=0 are introduced by
this prototype. I plan to test more passthrough=1 configurations ASAP.

- Throughput and CPU usage were averaged over 60s runs.
- Request size was 1 MiB in all tests.
- Except where noted, 64 fio jobs and 64 nfsd threads were used.
- Clients used O_DIRECT in all tests.
- `Mode` in tables below is NFS server's access mode.
- Server throughput/core is mean throughput divided by mean measured
  server core equivalents, where 100% processor usage represents one core.
- Changes are relative to the plain kernel:
  100 * (patched - plain) / plain. Positive values mean increases.
- Percentages are calculated from means rounded to two decimal places.
- Results from the first buffered runs were discarded so as to
  only compare filled page cache performance.
- Direct results are average of two runs, except direct
  configuration E which is the average of four runs.
- Hardware used: Nvidia Grace (144 Arm Neoverse V2 cores),
  Broadcom 400G NICs connected to NUMA 1 on client and server

NFS server command lines tested:
A: cpufreq.off=1 cpuidle.off=1 iommu.passthrough=1 iommu.strict=0
   kpti=off maxcpus=72 mem=480g rcu_nocb_poll selinux=0
B: cpufreq.off=1 cpuidle.off=1 iommu.passthrough=0 iommu.strict=0
   kpti=off maxcpus=72 mem=480g rcu_nocb_poll selinux=0
C: cpufreq.off=1 cpuidle.off=1 iommu.passthrough=0 iommu.strict=1
   kpti=off maxcpus=72 mem=480g rcu_nocb_poll selinux=0
D: cpufreq.off=0 cpuidle.off=0 iommu.passthrough=0 iommu.strict=1
            maxcpus=72 mem=480g
E: <empty command line>
F: <empty command line> with only 8 fio jobs and 8 nfsd threads.

Configuration   Mode      Throughput change   Server throughput/core change
--------------  --------  ------------------  -----------------------------
A               Direct               +136.8%                         +95.5%
B               Direct                 +6.7%                         +74.9%
C               Direct                +11.3%                         +62.4%
D               Direct                 -1.9%                         +27.6%
E               Direct                 -2.6%                         +28.2%
F               Direct                +18.8%                         +21.8%

More benchmarks are planned for a better signal/noise ratio.

--------------  --------  ------------------  -----------------------------
A               Buffered               +0.2%                         +33.6%
B               Buffered                0.0%                         +28.7%
C               Buffered                0.0%                         +11.4%
D               Buffered                0.0%                          -8.0%
E               Buffered                0.0%                          +7.4%
F               Buffered                0.0%                         -12.0%

Buffered mode saw no loss of throughput but there was an increased
CPU usage observed in some configurations.

Functional testing:
Seven hour NFSv4 over RDMA stress run exercised buffered and direct NFSD
modes using fsstress, fsx, and fio, with concurrency up to 64 workers.
All 879 completed workloads passed.

Tests with patch series on nfsd-testing commit 32eb1a60b456
===========================================================

Performance:

Set-up as above.

Configuration   Mode      Throughput change   Server throughput/core change
--------------  --------  ------------------  -----------------------------
A               Direct               +104.5%                         +70.2%
E               Direct                 +3.4%                         +20.8%
A               Buffered               +1.0%                         +35.6%
E               Buffered                0.0%                         +15.5%

Functional testing:
A planned seven-hour NFSv4 over RDMA stress run stopped after
approximately one hour because the test harness stops on server kernel
warnings. It detected two correctable PCIe AER reports (RxErr and
BadTLP) from the root port upstream of the server's RoCE NIC.

Before the stop, 315 test workloads completed with exit status zero,
including fio checksum readbacks. The cause of the AER reports and any
relationship to this series have not been established.

Tests with patch series on nfsd-testing commit 56589cdb58819
============================================================

Functional testing:
On the rebased nfsd-testing tree, 490 workloads completed successfully.
They covered buffered and direct NFSD modes with 1, 8, 32, and 64
workers, using fsstress, fsx, and fio write/checksum readback tests.
The planned seven-hour run stopped after 1h37 when the harness detected
two USB hub descriptor timeouts that appear unrelated to the nfs stack.
A full 7 hour test will be re-attempted again as soon as practicable.

Known issues and follow-up
==========================

- Complete a seven-hour stress run on nfsd-testing and investigate
  whether the PCIe AER reports recur.
- Address memory-registration capacity limits with coalesced vectors
  in the force_mr and Xen paths.
- Gather more comprehensive performance data, including write data

LLM Usage
=========

The idea of folio usage here was human-generated from observations of
performance differences between 4KiB and 64KiB page size kernels. An
LLM was used for familiarization with the NFS and related subsystems
and for generating some of the code after lengthy prompted technical
discussions. An LLM was used for multiple rounds of review, including
for the cover letter; suggested changes were manually verified. It also
helped develop scripts to invoke the various test suites mentioned above
and analyze resulting logs.

Signed-off-by: J Louis Kaplan <Louis.Kaplan@arm.com>
Assisted-by: LLM

J Louis Kaplan (6):
  sunrpc: Add helpers to build bvecs from contiguous pages
  nfsd: Coalesce contiguous pages for direct reads
  svcrdma: Coalesce contiguous pages when mapping replies
  svcrdma: Coalesce contiguous pages in RDMA Write chunks
  svcrdma: Coalesce contiguous pages in RDMA Read chunks
  sunrpc: Allocate svc request pages from large folios

 drivers/infiniband/core/rw.c          |   7 +-
 fs/nfsd/vfs.c                         |  11 +-
 include/linux/sunrpc/svc.h            |  90 +++++++++++++
 include/linux/sunrpc/svc_rdma.h       |  15 +++
 net/sunrpc/svc_xprt.c                 |  44 ++++++-
 net/sunrpc/xprtrdma/svc_rdma_rw.c     | 178 +++++++++++++++-----------
 net/sunrpc/xprtrdma/svc_rdma_sendto.c | 112 +++++++++-------
 7 files changed, 327 insertions(+), 130 deletions(-)

-- 
2.43.0

