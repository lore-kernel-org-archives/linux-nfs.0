Received: from smtp.kernel.org (aws-us-west-2-korg-mail-1.web.codeaurora.org [10.30.226.201])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 27EAD3E4C61;
	Fri,  8 May 2026 20:14:44 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=10.30.226.201
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1778271285; cv=none; b=XxKl1lPif/I9tgi6fHQ1ue58m0MYTb08L3eWhnvr+qGCQaY7X6CF0BLDpstos5KBZagP7RcwmkLBL4Qu0V82MD4RfgxZxxaUai/S63iZkKQaM6n4F9faaukssLBLpVq1UFXJJwmZlOnstTsySdPcCgnxb0ISUJ9nzSKDTyXP4qg=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1778271285; c=relaxed/simple;
	bh=oL96w9GxoS7e+L0xMasx8uNMIKOmIhN5Py5nS5kyQkU=;
	h=Message-ID:Date:MIME-Version:Subject:To:Cc:References:From:
	 In-Reply-To:Content-Type; b=sV1+0q75wQevdxzrzDD4acUuP6vScjcqMNml1SUZQt51cw3rBJqRjUsN9FvfWsVUvdAR+Z3NIDPzqLTPa+cimNV0MZQTpPgGTS8vrSg/P/wv/E+ly37Hy0GzfGu08DaLlmCgD2yZSSACzAn6kM2O6rjqZL1U+uTNfJpIysJaqPo=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.b=uztWB7rt; arc=none smtp.client-ip=10.30.226.201
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.b="uztWB7rt"
Received: by smtp.kernel.org (Postfix) with ESMTPSA id EB127C2BCB0;
	Fri,  8 May 2026 20:14:43 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/simple; d=kernel.org;
	s=k20201202; t=1778271284;
	bh=oL96w9GxoS7e+L0xMasx8uNMIKOmIhN5Py5nS5kyQkU=;
	h=Date:Subject:To:Cc:References:From:In-Reply-To:From;
	b=uztWB7rtjI4hFkb4+BvZnrU0h4XD2F+x3aL1dfORldtIzvx37Evvu0z13UiwoMT/5
	 upXd9mqVuEgeUwPxO0HGsXvmGisQfCZbQ6CMeLgwsoGOrf+Tvs31jEQLdzSno3V7+1
	 MZEnV5iqcS/WqfvzEO68M01Vel3ebSxiaTe4daELNs2+ZmsVEABluzdvxiWo6JzMjF
	 kpIpc4VyHGT8jTf6Fk+7uJJMP3xAsWJMBYJaloVKNB8mHaiGArf87JjSiIV5u8O0Zx
	 SMEhhsNugbzGZpYGBuD9SXYVucJHJuWkmZmcXirUCvVtDYb17mH5YgUhwJ+T7HeR92
	 4EE5oIcAVOZBw==
Message-ID: <0267f73f-b4e5-4318-85de-808699f77d95@kernel.org>
Date: Fri, 8 May 2026 16:14:42 -0400
Precedence: bulk
X-Mailing-List: linux-nfs@vger.kernel.org
List-Id: <linux-nfs.vger.kernel.org>
List-Subscribe: <mailto:linux-nfs+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:linux-nfs+unsubscribe@vger.kernel.org>
MIME-Version: 1.0
User-Agent: Mozilla Thunderbird
Subject: Re: [PATCH 1/2] svcrdma: Release write chunk resources without
 re-queuing
To: Mike Snitzer <snitzer@kernel.org>,
 Jonathan Flynn <jonathan.flynn@hammerspace.com>
Cc: Jeff Layton <jlayton@kernel.org>, NeilBrown <neil@brown.name>,
 Olga Kornievskaia <okorniev@redhat.com>, Dai Ngo <Dai.Ngo@oracle.com>,
 Tom Talpey <tom@talpey.com>, linux-nfs@vger.kernel.org,
 linux-rdma@vger.kernel.org, Chuck Lever <chuck.lever@oracle.com>,
 ben.coddington@hammerspace.com
References: <20260506-svcrdma-next-v1-0-915fce8c4fbb@oracle.com>
 <20260506-svcrdma-next-v1-1-915fce8c4fbb@oracle.com>
 <afz6PwRlpJFzoIQE@kernel.org>
Content-Language: en-US
From: Chuck Lever <cel@kernel.org>
Organization: kernel.org
In-Reply-To: <afz6PwRlpJFzoIQE@kernel.org>
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 7bit

On 5/7/26 4:46 PM, Mike Snitzer wrote:
> On Wed, May 06, 2026 at 11:26:50AM -0400, Chuck Lever wrote:
>> From: Chuck Lever <chuck.lever@oracle.com>
>>
>> Each RDMA Send completion triggers a cascade of work items on the
>> svcrdma_wq unbound workqueue:
>>
>>   ib_cq_poll_work (on ib_comp_wq, per-CPU)
>>     -> svc_rdma_send_ctxt_put -> queue_work    [work item 1]
>>       -> svc_rdma_write_info_free -> queue_work [work item 2]
>>
>> Every transition through queue_work contends on the unbound
>> pool's spinlock. Profiling an 8KB NFSv3 read/write workload
>> over RDMA shows about 4% of total CPU cycles spent on this
>> lock, with the cascading re-queue of write_info release
>> contributing roughly 1%.
>>
>> The initial queue_work in svc_rdma_send_ctxt_put is needed to
>> move release work off the CQ completion context (which runs on
>> a per-CPU bound workqueue). However, once executing on
>> svcrdma_wq, there is no need to re-queue for each write_info
>> structure. svc_rdma_reply_chunk_release already calls
>> svc_rdma_cc_release inline from the same svcrdma_wq context,
>> and svc_rdma_recv_ctxt_put does the same from nfsd thread
>> context.
>>
>> Release write chunk resources inline in
>> svc_rdma_write_info_free, removing the intermediate
>> svc_rdma_write_info_free_async work item and the wi_work
>> field from struct svc_rdma_write_info.
>>
>> Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
> 
> You were correct: this patch alone eliminates the OOM (we tested with
> both 16K and then 4K read IO from 121 clients to 8 NFS servers, no
> measurable memory growth while testing).

Excellent news! Thanks to you both for testing.


> Feel free to add:
> 
> Reviewed-by: Mike Snitzer <snitzer@kernel.org>
> Tested-by: Jonathan Flynn <jonathan.flynn@hammerspace.com>
> 
> Thanks!
> Mike
> 
> ps.
> So you are aware, couldn't test your 2nd patch at the customer site
> because the baseline kernel there is based on 6.12-stable but your
> 2nd patch builds on your 7.1 svcrdma changes. I think your 2nd patch
> is ideal though, and will be able to pull it in to test in future, but
> won't have the ability to test at this customer's scale until we can
> role that newer kernel out there... might take a couple months.

Understood.


-- 
Chuck Lever
