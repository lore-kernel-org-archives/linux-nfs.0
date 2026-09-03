Received: from smtp.kernel.org (aws-us-west-2-korg-mail-alma10-1.taild15c8.ts.net [100.103.45.18])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 5DAC219005E
	for <linux-nfs@vger.kernel.org>; Thu,  3 Sep 2026 13:34:12 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=100.103.45.18
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1788442465; cv=none; b=oGEY/rDY6qFnRpbWb/Sq92s5kTmW8fxWjYvdGjPTFXguwSJrJcT6mtrKED+qy5s3WaDqcZRedXiLHO69nzAT+qmo08pFlqNthb+I5ehnNHs46Zx8GvJ0jhkOFsJ5J5VCWy4jEe59c5ye2sKrIoEjxdGgC7e12NADJYbObsU+bGA=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1788442465; c=relaxed/simple;
	bh=XJe2vLXVDzZl62WuHe5arvVnSHi9JRdvaslIXRx/lWE=;
	h=MIME-Version:Date:From:To:Cc:Message-Id:In-Reply-To:References:
	 Subject:Content-Type; b=gkNvnAt2uP0aAwJ8UcAHeAYDKmfs9sri0U70iX6+JLoC4Ps7/gQc3qVw5fhT/5P9oEYQ8p4Wvgoon2S9Zi5g0FcDkX8clQvNW9Y+s/ULm7c+sVOpOq3uZx+nVPWfn+Fi6oxkEv9sYCeNKapBoJOhGWfy5XEkGq7LwdZQFPJH/u0=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.b=YeSyLuhX; arc=none smtp.client-ip=100.103.45.18
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.b="YeSyLuhX"
Received: by smtp.kernel.org (Postfix) with ESMTPSA id 3898F1F00A3E;
	Thu,  3 Sep 2026 13:34:11 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=kernel.org;
	s=k20260515; t=1788442451;
	bh=yUiRI2Rfw7Ef0qHGAPl/4ddYPJE657cvHNOnZdQgUaU=;
	h=Date:From:To:Cc:In-Reply-To:References:Subject;
	b=YeSyLuhXAZd0PFP28QTKNU9WJIBjWGBWQ8L9L5TzHqkZxtOZAM//r6mEYCugLoKig
	 Omt7S2511zHq/3hvYZRtke8oglvtQwL1wtC/GjO3+1y1+B2UpfPIAIReXhkS3V9+C4
	 g6gOG0b8oZvo78DfLtSGvrq/rmjdtdKigF2KptY4HqzXMPpqvwHZK+WiTNL/5+ewh7
	 Jsx59jxWcqZ6FjlpE0etCvKccAS42/4zginnggQ7sSU4W9yFgFH9uMD5n04V8SL3dF
	 RNfy5gmp2yicf1OruVIODCndj1nvYQcIU2mp3CKu664XechlMWNvSwHvDjkQ1l7PAH
	 zNKg8XofhvwNA==
Received: from phl-compute-10.internal (phl-compute-10.internal [10.202.2.50])
	by mailfauth.phl.internal (Postfix) with ESMTP id 5D8C1F40066;
	Thu,  3 Sep 2026 09:34:10 -0400 (EDT)
Received: from phl-imap-15 ([10.202.2.104])
  by phl-compute-10.internal (MEProxy); Thu, 03 Sep 2026 09:34:10 -0400
X-ME-Sender: <xms:UneZani-_bNlDlMNJiNe9rHApID-UPaEMX6Sie_fTkcJJcRCUhy9YA>
    <xme:UneZau28WB5ANhNPYaworV_lv3ZHX5Grvm8ZNoPWOCNzTPVX4x_z0va4WTeRgRlIb
    hFurnJrQbErveFon9sUJ71h4qC_sToqRR-9YLOlvtLGi84EeTnCYAI>
X-ME-Proxy-Cause: dmFkZTF7Vos7m0CU6UL1Y8nc+IUNCMFVmEIpnqLxsr5ReaVht50v9ILByazF6RZHWbwqfd
    7MNjbKoA1+115fiZq76cpmdqBZHpaWlYGoLi1NZN0i84XiLTooR9qRWDBrtbcR4ZLNqXcA
    bNTyGgvxKf/CX85MG6woJgBqGjYz4mmiUrO1chM+P2BK696eP97mp1NP2/0Qg6nb9ZHfwB
    k6Uq1N/bvhGUd1zEfZfCL36gid4DJ6tPN+xbX2ey/I4vi/pG6cQU6mSLRyolxSoV84T3kR
    HqVUBXC1f6aM00gFzotHstJCf4b1UDkPNG1e5RQbfJKHPkopjvn5s+KDJ0m4VP7Y5r7UYb
    hwM8iwV9yCqinVwFG2lXeHsOE5AqX3OZI4cTcoXhjB8FpnYVXiJXsYXd01ZkZDlnizsPUj
    joEgzPz8F0rSWnPbu6Cy7SGu6rmud3cDONRuzrQAxeuvVwbdcgQ7aUlN5PWWoFiTLIqIid
    +ASVFmnYvwBc1l9vRDK2b9tCB9bRBmtp253t/f0SDMfj/0AqGbCgCzdpqYKcdOrYYXZwDo
    Iid6l2BZbIBG19XkMGPG/stK0WTV3cZVGPpy9ahx6LKfdPPVaKOYelLvZV64Qv6GumwFai
    q71AeJ0Ouaqv28sJ64iMfh1Fw8voBoIV4AMTMLQxwKG4vsmTvmBATt4I2nxQ
X-ME-Proxy: <xmx:UneZakvxEbHTTMBop0TZAxAOm36YPi_r3aFOjIG7XgQqlVmgKLhI4w>
    <xmx:UneZajAbmMcuwFKXrW0eqqGyT4uZN_9p98koGlU_Tb3zdKUQPgr_UQ>
    <xmx:UneZamGaPMy3RDcfKeChdeqs5xA33mvp9O5yft4W7W3cDIWo1lZSoQ>
    <xmx:UneZajAak0vJIF0bTw5S309cACEmYmbs4qDqNmrFRPDH4FB4iMYGWQ>
    <xmx:UneZaslH3kugatbyDu6jSnLNcXne4q1cQw9m6yducsQp0Y-302XZgECr>
Feedback-ID: ifa6e4810:Fastmail
Received: by mailuser.phl.internal (Postfix, from userid 501)
	id 3BFB67811F3; Thu,  3 Sep 2026 09:34:10 -0400 (EDT)
X-Mailer: MessagingEngine.com Webmail Interface
Precedence: bulk
X-Mailing-List: linux-nfs@vger.kernel.org
List-Id: <linux-nfs.vger.kernel.org>
List-Subscribe: <mailto:linux-nfs+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:linux-nfs+unsubscribe@vger.kernel.org>
MIME-Version: 1.0
X-ThreadId: AgpFG2YqzZmg
Date: Thu, 03 Sep 2026 09:33:54 -0400
From: "Chuck Lever" <cel@kernel.org>
To: "Tim Menninger" <tmenninger@everpuredata.com>
Cc: "Trond Myklebust" <trondmy@kernel.org>,
 "Anna Schumaker" <anna@kernel.org>, "Tejun Heo" <tj@kernel.org>,
 "Lai Jiangshan" <jiangshanlai@gmail.com>, linux-nfs@vger.kernel.org,
 linux-kernel@vger.kernel.org, "Eric Badger" <ebadger@everpuredata.com>,
 "Jon Curley" <jcurley@everpuredata.com>
Message-Id: <dc18f84a-f53f-440f-b0cb-f27b44e090eb@app.fastmail.com>
In-Reply-To: <20260902204048.4100864-1-tmenninger@everpuredata.com>
References: <20260831-performance-v1-6-8d9fd9b67f96@kernel.org>
 <20260902204048.4100864-1-tmenninger@everpuredata.com>
Subject: Re: [PATCH RFC 6/8] SUNRPC: Reduce rpciod workqueue contention
Content-Type: text/plain
Content-Transfer-Encoding: 7bit

On Wed, Sep 2, 2026, at 4:40 PM, Tim Menninger wrote:
> I am seeing a significant throughput regression from the rpciod SMT
> affinity change on a high-throughput NFS/RDMA workload.

Thanks for the report!

I'd like to learn a bit more about the setup before drawing
any firm conclusions.

1. Does v2 of the series behave the same way? v2 dropped the
   patch that ran the first RPC states in the submitter's
   context, so the rpciod traffic pattern differs from v1.
   The same smt -> cache_shard -> smt toggle on v2 would tell
   us whether that matters.
  
2. How are the RDMA device's completion interrupts placed?
   Please share, on a bad run:
   - /proc/interrupts lines for the device's completion vectors
   - the smp_affinity_list for each of those IRQs
   - whether irqbalance is running, and whether you've pinned
     the IRQs by hand

3. Where is CPU time going on a bad run versus a good one?
   A short capture of each would help:
     perf record -a -g -- sleep 10
     perf report --sort comm,cpu --stdio | head -80
   In particular I'm interested in which CPUs the kworker
   threads for rpciod and the ib-comp-wq threads run on under
   each scope.

4. tools/workqueue/wq_monitor.py rpciod, sampled for a few
   seconds under each scope, would show whether the pools are
   evenly loaded.

5. The workload itself: thread count, I/O size and direction,
   number of mounts and RDMA connections, and the mount
   options (nconnect in particular).

6. The base kernel the series was applied to, and the RDMA
   device and driver.
  
If you have a way to capture a bad run reliably shortly after
boot, a "before and after" of items 2 through 4 across a single
scope toggle would be the most direct evidence.


-- 
Chuck Lever (Come to NFS bake-a-thon! https://nfsv4bat.org)
