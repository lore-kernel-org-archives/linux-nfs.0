Received: from smtp.kernel.org (aws-us-west-2-korg-mail-alma10-1.taild15c8.ts.net [100.103.45.18])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id A68503CA486
	for <linux-nfs@vger.kernel.org>; Tue,  8 Sep 2026 21:12:19 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=100.103.45.18
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1788901941; cv=none; b=M2+4+XP3wg3+I87lRN+cQUIMv6afRrOqgLPf1QZPCBFpiQ1i+pNLCM9N4esJsi7q2/XFNgggb+WWi5RDGnFLcnH6CWfjGVuVZps93oTNPNM8PHxAAXrQ9UDb+0vs2duvw7Z+YecadiAfMLmH2M1zauHGBkNY5wWiYhn3NjB4dEM=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1788901941; c=relaxed/simple;
	bh=4hST8EC4yMUXRzN8C/eRuw+LBFZ5U6+4bLxq2or4x4U=;
	h=MIME-Version:Date:From:To:Cc:Message-Id:In-Reply-To:References:
	 Subject:Content-Type; b=NQ4TszRDiMkFga2t5wvfgo3V9gabrElpCjla7dm+ulvYSgfkBenvTvh3XQAaFATbozrARFUv5zfj2asJcYLOKay7YSkQ5byQFBhkPii4bmQPExS6zXXZLUCKZPEfxf93ZjZzoUp5OepGAnOgs2Y1QoQUW8DxgB1/MP5WLHfXyIk=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.b=dBYeylX4; arc=none smtp.client-ip=100.103.45.18
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.b="dBYeylX4"
Received: by smtp.kernel.org (Postfix) with ESMTPSA id 12AE21F00A3D;
	Tue,  8 Sep 2026 21:12:18 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=kernel.org;
	s=k20260515; t=1788901939;
	bh=/0efugg9pUrDQ0EHEEzBUr4HWRYeAM03GHJXiuTqxes=;
	h=Date:From:To:Cc:In-Reply-To:References:Subject;
	b=dBYeylX4/jmnUJ3BUHBJ1qKMwpJ+L98sgKRE9EZlVz3sPkmwDqTUFYvm2xN6iSoQK
	 66mSVchsq3WyAwvyCJ0TJJbZ6w9zkScNjl8bJ5FdqzEcgJLREz43xWJUd0ph09QmgX
	 aaAQKNZaPHXP0KR5DcDRPiL9EpcwSWFyCJKlvZfYRdf0uNZ98N2P3pq1GfAHz6SfvT
	 g6pVP4dgVNmRICJHP4hFy1lk522jxo9J99QN05yMj7Jj5naXTbD5Dmj3+e3QiGGv+D
	 0UMYvX7g9zVXFjWiofnQffNYQ8AHK0lNL/MjxBpUS8R/01arQTRqWpvE1RsXibAV4X
	 TdFcT10HbZsjw==
Received: from phl-compute-10.internal (phl-compute-10.internal [10.202.2.50])
	by mailfauth.phl.internal (Postfix) with ESMTP id E7B68F40069;
	Tue,  8 Sep 2026 17:12:17 -0400 (EDT)
Received: from phl-imap-15 ([10.202.2.104])
  by phl-compute-10.internal (MEProxy); Tue, 08 Sep 2026 17:12:17 -0400
X-ME-Sender: <xms:MXqgatKPinVLrpJKLHfKaLKhPZ8w_MwiXwdjRzyaoJlrBFfr9e0dHg>
    <xme:MXqgaj-8XBakZuk9tjNPG_BcysEIAS7KgaMQwGPBpUgduNwPFL6vwmfu48S88hIG5
    2xnsHHJNzc3r6JLc3pWp-l7rAKL4LZBY-1MWA4xI6nsT65QFsCjTvJu>
X-ME-Proxy-Cause: dmFkZTF0kI2foI8pDJrzOE0ZfWjwZ7K8ksez6LM9BQPMb1M/xM3oIl8/tp9XfiSxt/8Ft2
    /7yiQBySdx6MoWIB30zU2ohR8RScRxhussJ5dN8EX0akvooqY3AfgYfWI4YWNbqvpB5INK
    sm0r/L/XxSs3D7S+jd2z9FItRVxADougQvWZnrNDmZbkzXzurp2E7rBPzBTCZUoWq2uESG
    wktrIIWogdC4/DpGGTpziZH5sM2FvTM6ApbI7cwscZvD9ZQ/MM0XYxEDy1b4WgK7CU7oeu
    rews2RYzktyEeQKw/vokgIH17YjM7QhjMsi3hWy55VGodfvmRmB7W+NhH58gVNRFESudLZ
    llLqFpWASAVSzyx4jT6zdNeaWu80yFRdHHkzROnr5Q57B2AOuSht5XgueVapztCiq3JkIK
    dlq1C3X4Oe4LRqWPMpZzDxun9qYUWTi5yBPT84/fXL097ET2sx3sym7ON8GPOs2sFivjiZ
    hDCgi99K4C+L3O0hyNlzwgb/1Nw+J32ja2BIe5ykBnT+AMrK03LJkeUmmK8mDLGYS+jR8/
    a1anRT5B7ucN5ZwuMVbCy6W+vwaP1gjRrNZwJtSxf9YuxTQKFf+fxRuVZNFCEsSvjImUg+
    cHsnWQL40yfXHV6Oz+1amyygSV+KLR4qJQH6P96HcHhwAJvtmDRgVRTntZTQ
X-ME-Proxy: <xmx:MXqgasZ__xeQIPz3WdsL62nzHSA56FCdA5F20O8OTLHrEBZPsIaesg>
    <xmx:MXqgan0Bv1SNCtUWB8BsDCWKyLVcEWbyYnC5a3Usd40RIEWPS-NGsw>
    <xmx:MXqganrs7D58WavwQwpZOk3VaA1NMLqVY85Tzf13JK1JkGegvDkfkw>
    <xmx:MXqgauMymuuLATrC7ZdR6FjOSEdMxdRS0k2UEYkOuWYdqy2oZ42HoQ>
    <xmx:MXqgaorVSRF3JHemVWSVSAl2jKWQCuapKZhDedHDVYCkubLKIv2M1mKf>
Feedback-ID: ifa6e4810:Fastmail
Received: by mailuser.phl.internal (Postfix, from userid 501)
	id 96BE37811F4; Tue,  8 Sep 2026 17:12:17 -0400 (EDT)
X-Mailer: MessagingEngine.com Webmail Interface
Precedence: bulk
X-Mailing-List: linux-nfs@vger.kernel.org
List-Id: <linux-nfs.vger.kernel.org>
List-Subscribe: <mailto:linux-nfs+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:linux-nfs+unsubscribe@vger.kernel.org>
MIME-Version: 1.0
X-ThreadId: AgpFG2YqzZmg
Date: Tue, 08 Sep 2026 17:11:57 -0400
From: "Chuck Lever" <cel@kernel.org>
To: tmenninger@purestorage.com
Cc: "Trond Myklebust" <trondmy@kernel.org>,
 "Anna Schumaker" <anna@kernel.org>, "Tejun Heo" <tj@kernel.org>,
 "Lai Jiangshan" <jiangshanlai@gmail.com>, linux-nfs@vger.kernel.org,
 linux-kernel@vger.kernel.org, "Eric Badger" <ebadger@everpuredata.com>,
 "Jon Curley" <jcurley@everpuredata.com>
Message-Id: <e485f23d-896d-4c01-9d24-eb3784a10dc2@slotpi15m67>
In-Reply-To: <20260908181927.783442-1-tmenninger@purestorage.com>
References: <425864a2-3276-4c16-a861-32defe5e04e2@slotpi15m67>
 <20260908181927.783442-1-tmenninger@purestorage.com>
Subject: Re: [PATCH RFC 6/8] SUNRPC: Reduce rpciod workqueue contention
Content-Type: text/plain
Content-Transfer-Encoding: 7bit

On Tue, 8 Sep 2026, Tim Menninger wrote:

> Patches 1-2 alone do not reproduce it across 5 trials ...
>
> Patches 3-8 do reproduce it (as well as the full 1-8) ...

Thanks, that confirms which part of the series is responsible. The
scope change on rpciod is the cause, and the XID and recv_lock
changes are not involved.


>                         smt         cache_shard     smt
>     aggregate           15%         32%             19%
>     CPU 0-23,48-71      0-1%        6-9%            0-2%
>     CPU 24-47,72-95     28-32%      55-61%          35-40%

Hrm. Under smt, node 0 is saturated and node 1 is busier too, yet
throughput is lower than under cache_shard, where both nodes have
more idle time. The smt scope is burning CPU on something that is
not moving data. That is a different failure than the one I
expected (node 0 starved while node 1 sleeps), so the next step
is to find out what those cycles are doing.


> Would there be a downside to using WQ_AFFN_CACHE_SHARD here instead of
> WQ_AFFN_SMT?

cache_shard is the system default, and that is what the workqueue
used before this series. On the 12-core system where I developed
the series, cache_shard produces only two pools of six cores each,
and 30-40% of cycles went to the pool lock's spinlock slowpath,
accompanied with a measurable loss in throughput.

Your machine gets six pods of sixteen threads, which is a different
regime, and it is possible that cache_shard is simply the right
answer there. What I'm ultimately shooting for is something that
automatically configures the correct behavior. I thought smt would
be that configuration.

A few experiments, all with the full series applied and all CQs on
node 0. Each is a single sysfs write on rpciod except the last.

1. Toggle affinity_strict under smt:

       echo 1 > /sys/bus/workqueue/devices/rpciod/affinity_strict

   Strict pins each pool's kworkers to its SMT pair. If strict
   recovers throughput, the loss comes from non-strict workers
   being wake-affined or migrated onto the saturated node. If
   strict makes it worse, node 0's pools are starved and the fix
   is to let work spill to node 1. Either result cuts the
   hypothesis space in half, so if you have time for only one of
   these, this is the one.

2. Walk the scope ladder: cpu, smt, cache, cache_shard, numa, and
   report throughput for each. If cpu is as bad as smt, pool
   granularity itself is the problem. If cache already recovers,
   the threshold sits between 2-thread and 16-thread pods.

3. Profile the smt and cache_shard windows of one run, node 0 CPUs
   only, so the two captures differ in nothing but the scope:

       perf record -a -g -C 0-23,48-71 -- sleep 10
       perf lock contention -a -C 0-23,48-71 -- sleep 10
       perf stat -a -C 0-23,48-71 \
           -e context-switches,cpu-migrations,sched:sched_wakeup \
           -- sleep 10

   The two candidates I have in mind are a downstream lock, such as
   the transport's queue_lock or recv_lock, contended by 24 small
   pools running completions in parallel; or scheduler overhead
   from each pool waking its own kworkers. The %sys, %irq, and
   %soft columns from the same mpstat runs would help too, since
   idle alone does not say what the busy CPUs are doing.

4. With the even 17/15 CQ split and rpciod at cache_shard, a perf
   profile shows whether the pool-lock slowpath the series targets
   appears on your box at all. If it does not, cache_shard is
   correct for your system, and the series needs a way to express
   that rather than one hardcoded scope.


-- 
Chuck Lever (Come to NFS bake-a-thon! https://nfsv4bat.org)
