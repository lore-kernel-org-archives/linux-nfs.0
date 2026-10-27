Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.remote-ip=100.103.45.18
ARC-Seal: i=1; d=subspace.kernel.org; s=arc20261015; a=rsa-sha256; cv=none;
	t=1793119546;
	b=JxmMW/THCHI153vSDngl4Dq0Drg8y0kvDS0caf8qZbBFJpcPJQmxScew8+LwAokvm2Cf
	 yLzWC9ZtRgeao4AblRdxhma6uIWPCwRFX2zHSI2Qc9kurWR68gI0wl1+HW/cyJhjBDHw3
	 cq8AbDihAJbKzx0rHmIATwue1F8iKaGasCRICjRXhuOSqtO3tydJzNKIddwbgBJdTMHnH
	 QTLAAOSShCFBy99WZpDIa1RTKel4+B46UYqoedIy5YBGyGVFtS9xMMVesfM6MPQCsndMN
	 o7Y+eikPBzl4IxRoYZ5IYc7b5gFpOC1YqCkfHT2H9rvJq/nJCvJqWUo1CG/GiKZPmBg==
ARC-Message-Signature: i=1; d=subspace.kernel.org; s=arc20261015;
	a=rsa-sha256; c=relaxed/relaxed; t=1793119546;
	h=Received:DKIM-Signature:From:Date:Subject:MIME-Version:Content-Type:
	 Content-Transfer-Encoding:Message-Id:References:In-Reply-To:To:Cc:
	 X-Mailer:X-Developer-Signature:X-Developer-Key;
	bh=UdPWn9NdxuHeQkxvw0YgN+IrvABQATaZk18XrdvJ4eM=;
	b=2YEsYadRCsJyzCcq7XdkOuQfpSyGBjChwMObzDPirkseS5SnmolmYFYvXPAwjsltsEGq
	 TVSNkJ3cw9+qJaSlKMApqLROdQlWM+ikZ/reIpSjr+Lo2foBdbrsEljevp0gtVuOf3DCi
	 a5/6dEEfFlrtV8nvoVL2eJxp/4uVMOLyZ3e5m/4B9GYNrwgBLw31xQTrqmHfi6EcMSBj4
	 uEu2pqLKfIj5SHpT/RtPD/gTcb13flmpJaoPfmSX+eedO36UFt16oEeihkTHcYWaOkuNV
	 C/ODjLErYfAFt+rzidXNZDiZV6hCL8kBS8rZCJN2LzrB2U+Pe8chaKnJUZxLK5a8/FQ==
ARC-Authentication-Results: i=1; smtp.subspace.kernel.org; 
	dkim=pass header.d=kernel.org header.i=@kernel.org header.a=rsa-sha256 header.s=k20260515 header.b=ZhBUlGK3;
	arc=none smtp.remote-ip=100.103.45.18
Received: from smtp.kernel.org (quasi.space.kernel.org [100.103.45.18])
	(using TLSv1.3 with cipher TLS_AES_256_GCM_SHA384 (256/256 bits)
	 key-exchange X25519 server-signature ECDSA (prime256v1))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 77D5760A3813;
	Tue, 27 Oct 2026 16:45:46 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key, unprotected) header.d=kernel.org header.i=@kernel.org header.a=rsa-sha256 header.s=k20260515 header.b=ZhBUlGK3
Received: by smtp.kernel.org (Postfix) with ESMTPSA id 7126B1F031E0;
	Tue, 27 Oct 2026 16:45:44 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=kernel.org;
	s=k20260515; t=1793119546;
	bh=UdPWn9NdxuHeQkxvw0YgN+IrvABQATaZk18XrdvJ4eM=;
	h=From:Date:Subject:References:In-Reply-To:To:Cc;
	b=ZhBUlGK3G8ueBbbRp1iHZ4u7ZcBBasSxaq7xvtyXIewmYR4BhgcKhTX12mn60Aam6
	 t96Bda5pb4hBoYi6ZsAKQo+MdE+xSTJgjlSsCl6W1zcaeH5mN9hPKn0eGFY/o6nD1s
	 mHav25uBIh4AveYamzaYNU8IWbrqCNW0H7dkr3OXhzlaFLxcY5yyg+IASSBSUtOk3g
	 bmcwNMDEIYS4AxY2x5W3t4ZO3rbYy4ohavq8NxmErB+oOf9Hsbtmqbtvd8ldqVpGei
	 H9cxhM0jqM1l1bI8F0/jd4Jg5aqbay1DidNMBOKQMwSwcGAi1o3BtxvVbZohlOOUxv
	 PQS9OoLgFUJqQ==
From: Jeff Layton <jlayton@kernel.org>
Date: Tue, 27 Oct 2026 12:45:29 -0400
Subject: [PATCH 6/6] NFSD: Document how to choose an IO mode
X-Mailing-List: linux-nfs@vger.kernel.org
List-Id: <linux-nfs.vger.kernel.org>
List-Post: <mailto:linux-nfs@vger.kernel.org>
List-Help: <mailto:linux-nfs+help@vger.kernel.org>
List-Subscribe: <mailto:linux-nfs+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:linux-nfs+unsubscribe@vger.kernel.org>
List-Owner: <mailto:linux-nfs+owner@vger.kernel.org>
Precedence: list
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Message-Id: <20261027-export-iomode-v1-6-262ed932a036@kernel.org>
References: <20261027-export-iomode-v1-0-262ed932a036@kernel.org>
In-Reply-To: <20261027-export-iomode-v1-0-262ed932a036@kernel.org>
To: Chuck Lever <cel@kernel.org>, NeilBrown <neil@brown.name>, 
 Olga Kornievskaia <okorniev@redhat.com>, Dai Ngo <Dai.Ngo@oracle.com>, 
 Tom Talpey <tom@talpey.com>, Trond Myklebust <trondmy@kernel.org>, 
 Anna Schumaker <anna@kernel.org>, Jonathan Corbet <corbet@lwn.net>, 
 Shuah Khan <skhan@linuxfoundation.org>, 
 Randy Dunlap <rdunlap@infradead.org>, Mike Snitzer <snitzer@kernel.org>, 
 Donald Hunter <donald.hunter@gmail.com>, Jakub Kicinski <kuba@kernel.org>, 
 "David S. Miller" <davem@davemloft.net>, Eric Dumazet <edumazet@kernel.org>, 
 Paolo Abeni <pabeni@redhat.com>, Simon Horman <horms@kernel.org>
Cc: Steve Dickson <steved@redhat.com>, netdev@vger.kernel.org, 
 linux-kernel@vger.kernel.org, linux-nfs@vger.kernel.org, 
 linux-doc@vger.kernel.org, Jeff Layton <jlayton@kernel.org>
X-Mailer: b4 0.14.3
X-Developer-Signature: v=1; a=openpgp-sha256; l=8695; i=jlayton@kernel.org;
 h=from:subject:message-id; bh=3VMALAqaxEsTZzg9oK0Rgz9Q70hh90AsFJgBVhFDyYw=;
 b=owEBbQKS/ZANAwAKAQAOaEEZVoIVAcsmYgBq4NUskWZDITs+J24U2SjFbcghoj3a1XEXkJRph
 EkSiqU/LjSJAjMEAAEKAB0WIQRLwNeyRHGyoYTq9dMADmhBGVaCFQUCauDVLAAKCRAADmhBGVaC
 FdZYD/9P0Pxekd5DSzL6YypVwn+463OKFCLx69Vdsv03VO0EHBcduRv7/R/MK9KaISPaF8AFb2j
 sffIGHFRL7J1sI1wy0wpJYoGvR5WsBkrQiMM6mdEcWGD4EsQbfgTQ5vbPxuJcp4FU7nAuhlK45o
 RDrjfwA1feyaXqOoiRypIeWAV42rNUa3kAAU8eZV8rfaL1UHMTGLacjDLsD9yJlpbchflNs5YP3
 /FDud9nOTR+6I8HXFUbmEuegqDw9Y6BN2MHJ6SniqfIuKXw4fLMtlfamIgQYItpsgONBv5D6j9B
 Nk4YrNuCZkwhbbTEnF7sIrjJ//xrNiu93ez0sd0Z2W1goy6/3RnaACYU1UvZjbUGFAgYQhl9jrC
 dKMSYdMFIzSL67+RAElr5XxLK9LooE0n7Cj2giRDabWtYalIFWVJHux4vmehxDZmxFnPVk7aiwj
 Z6lbxxyRc5Pxitm/jx4VmlFNVckHZpwVU54HnfBMqkXRYaDW4qwKdNN46sH84pWbREyPOy7ofEl
 y27QRL9+BoX+yDej9hc43dY5aPnAn4t3Ts4b/owMqeHseYdCQBU4EmyzFlwiVbIRK6ufgpGbhLq
 BY63KWaWp6hq2HSHzaCjKfa7K+IW1uqQRdunpEJDDJ7ceUC64UCmffBBRerWAYF+llbPU+TsmBf
 F3UgKBIuDegaVpA==
X-Developer-Key: i=jlayton@kernel.org; a=openpgp;
 fpr=4BC0D7B24471B2A184EAF5D3000E684119568215

Admins have no guidance on when to pick buffered, dontcache, or direct
IO for an export. Add a section that:

- explains why a low server page cache hit rate is normal (clients
  cache their own re-reads)
- lists the workload conditions that favor each IO mode
- describes existing metrics to measure: per-export miss ratio from
  export_stats vs. block device reads, workingset refault counters,
  cachestat(2), reclaim cost (PSI, allocstall, compact_stall), and
  client mountstats byte counters
- notes that refault counters do not see dontcache or direct IO, so
  measure while the export uses buffered IO

Signed-off-by: Jeff Layton <jlayton@kernel.org>
---
 Documentation/filesystems/nfs/nfsd-io-modes.rst | 168 ++++++++++++++++++++++++
 1 file changed, 168 insertions(+)

diff --git a/Documentation/filesystems/nfs/nfsd-io-modes.rst b/Documentation/filesystems/nfs/nfsd-io-modes.rst
index 6b29275e9128..400d5e462943 100644
--- a/Documentation/filesystems/nfs/nfsd-io-modes.rst
+++ b/Documentation/filesystems/nfs/nfsd-io-modes.rst
@@ -298,3 +298,171 @@ Tracing:
     segment that it could not invalidate. Only a filesystem that uses
     iomap for direct IO emits it, and other fallbacks, such as ext4's
     own, are not traced.
+
+CHOOSING AN NFSD IO MODE
+========================
+
+The correct IO mode for an export depends on the workload of its
+clients. The most important question is this: does NFSD read the same
+data again before the page cache evicts it?
+
+NFS clients keep their own page cache. When a client reads the same
+data again, its own cache usually supplies the data. The READ request
+does not get to the server. Thus, the server page cache helps mostly
+in these conditions:
+
+- Different clients read the same data.
+- A client reads data that a different client wrote recently.
+- A client reads data again after its own page cache evicted the data.
+
+A low server page cache hit rate is thus normal. It does not by itself
+show that buffered IO is the wrong choice.
+
+Use buffered IO for an export when:
+
+- The working set of the export fits in server memory.
+- Many clients read the same files.
+- Clients send small or misaligned WRITEs. The page cache collects
+  these WRITEs and writes them to storage in larger units.
+
+Use dontcache IO for an export when:
+
+- Clients read or write most data only one time.
+- The working set of the export is much larger than server memory.
+- The data of the export causes the page cache to evict data of other
+  exports.
+
+If the underlying filesystem does not support dontcache, NFSD uses
+buffered IO instead. See NFSD DONTCACHE above.
+
+Use direct IO for an export when the conditions for dontcache are true,
+and also:
+
+- Clients send large, aligned READs and WRITEs.
+- Page reclaim uses a large quantity of CPU time, or makes IO stop.
+
+Change the IO mode of one export at a time. Compare the metrics below
+before and after each change.
+
+Metrics to monitor
+------------------
+
+The metrics that follow can help you choose an IO mode. Measure them
+while the export uses buffered IO.
+
+Miss ratio for each export
+~~~~~~~~~~~~~~~~~~~~~~~~~~
+
+``/proc/fs/nfsd/export_stats`` shows the number of bytes that NFSD read
+(``io_read``) and wrote (``io_write``) for each export and client. If the
+kernel has ``CONFIG_TASK_IO_ACCOUNTING``, it also shows the number of
+bytes that storage supplied for these READs (``io_read_storage``). This
+value includes the readahead that the READs started, and the filesystem
+metadata that they needed.
+
+The kernel adds an export to ``export_stats`` when a client first uses
+it. The counters of an export continue when mountd refreshes the export
+or when ``exportfs -r`` flushes the export cache. They restart if the
+export stays out of the export cache for an hour. The start time shows
+when the counters started.
+
+Measure ``io_read`` and ``io_read_storage`` over the same interval. Then
+divide the increase of ``io_read_storage`` by the increase of
+``io_read``. This is the miss ratio of the export.
+
+- A ratio near 1 shows that storage supplies almost all data that NFSD
+  reads. The page cache gives little benefit. Dontcache or direct IO
+  can be a better choice.
+- A ratio much smaller than 1 shows that the page cache supplies a
+  large part of the data. Buffered IO is probably the correct choice.
+- A ratio larger than 1 shows that readahead reads data that clients
+  do not request, for example with small random READs.
+
+Without ``io_read_storage``, compare ``io_read`` with the number of bytes
+that the block device read. Field 3 of ``/sys/block/<dev>/stat`` shows
+the device reads in 512-byte sectors. You can also use iostat(1). This
+ratio is for all exports on the device. Local applications also cause
+device reads. Thus, this ratio is only an approximate value.
+
+Reads of recently evicted data
+~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
+
+When page reclaim evicts a file page, the kernel records the eviction.
+If a task reads that page again soon, the kernel counts a refault.
+``/proc/vmstat`` shows these counters:
+
+- ``workingset_refault_file``: the number of file pages that the kernel
+  read again soon after their eviction.
+- ``workingset_activate_file``: the number of refaulted file pages that
+  the kernel identified as part of the working set.
+- ``pgsteal_kswapd`` and ``pgsteal_direct``: the number of pages that
+  page reclaim freed.
+
+Use these counters as follows:
+
+- The ``pgsteal`` counters increase quickly, but
+  ``workingset_refault_file`` stays near zero. This shows that clients
+  read most data only one time. To find the export that causes this,
+  use the miss ratio above or cachestat(2).
+- ``workingset_refault_file`` increases quickly. This shows that clients
+  read the data again, but the page cache is too small to keep it.
+  Set dontcache or direct IO on other exports that read data only one
+  time. This gives more page cache to this workload.
+
+These counters are for the full system, not for each export. Dontcache
+IO drops pages without a record of the eviction. Direct IO does not use
+the page cache. Thus, these counters do not include exports that use
+dontcache or direct IO.
+
+Page cache state of a file
+~~~~~~~~~~~~~~~~~~~~~~~~~~
+
+The cachestat(2) system call shows the page cache state of a range in a
+file. It is available in Linux 6.5 and later. Its output includes:
+
+- ``nr_cache``: the number of pages in the page cache.
+- ``nr_dirty`` and ``nr_writeback``: the number of pages that wait for
+  writeback, or that are in writeback.
+- ``nr_evicted``: the number of pages that the kernel evicted.
+- ``nr_recently_evicted``: the number of evicted pages that would cause
+  a refault if a task read them now.
+
+Use cachestat(2) on the frequently used files of an export. This gives
+data for each export. Monitor ``nr_recently_evicted`` on the files of
+one export while a different export is busy. If the value increases,
+the busy export causes the page cache to evict useful data. Set
+dontcache or direct IO on the busy export.
+
+fincore(1) shows how much of a file is in the page cache.
+
+Cost of page reclaim
+~~~~~~~~~~~~~~~~~~~~
+
+Direct IO helps most when page reclaim uses much CPU time or makes IO
+stop. Monitor these metrics:
+
+- ``/proc/pressure/memory``: the "some" and "full" lines show the
+  percentage of time that tasks waited for memory.
+- ``allocstall_*`` and ``pgscan_direct`` in ``/proc/vmstat``: direct
+  reclaim activity.
+- ``compact_stall`` in ``/proc/vmstat``: memory compaction stalls.
+- The CPU time of the kswapd and kcompactd kernel threads.
+- ``Dirty`` and ``Writeback`` in ``/proc/meminfo``, for WRITE workloads.
+
+High values can occur while NFSD moves large quantities of data that
+clients use only one time. In this condition, direct IO can decrease
+the CPU load and make IO performance more constant.
+
+Client page cache
+~~~~~~~~~~~~~~~~~
+
+On a Linux NFS client, the ``bytes:`` line in ``/proc/self/mountstats``
+shows the bytes that applications read (field 1). It also shows the
+bytes that the client read from the server (field 5). mountstats(8) and
+nfsiostat(8) also show these values.
+
+Field 5 can be much smaller than field 1. This shows that the client
+page cache supplies most reads. In this condition, the server page
+cache keeps copies of data that the clients already have. If other
+clients do not read the same data, dontcache IO on the server can be a
+better choice.

-- 
2.56.0

