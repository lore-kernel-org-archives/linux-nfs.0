Received: from smtp.kernel.org (aws-us-west-2-korg-mail-1.web.codeaurora.org [10.30.226.201])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 3F08C3E95B7;
	Fri,  6 Mar 2026 16:30:32 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=10.30.226.201
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1772814632; cv=none; b=UbAO4rD7gC2Ht9bnDdMFTShbSWSrJwNSCLWVBNxwlpugHOjSxJPxznNzsDw3sLqp/7OtjH2QuEt8kFgMpiHXHmAHvSY8w0u7SaM+jNXt+cdBnD+Z9zVTvaHsvzQzX8N8vWYCe+yARIAtJcnLmjDldTN60ivaTDQPy+y2K18sbJU=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1772814632; c=relaxed/simple;
	bh=OmXIeO1BMQOa9SXSEVLKkjgLXEmOLbLWpqPeWHAthv8=;
	h=Message-ID:Date:MIME-Version:Subject:To:Cc:References:From:
	 In-Reply-To:Content-Type; b=DyZqOjIMHNKQyyCyuNIys33mN678dKMU4cw0k91pHhWo2nv4lBHtLsxJbOeiduRVPRA/IwvjBtFf9r/qBiirNhewN9G0bslQiB/rDf/Wd2S5LEFlidMfAaFFlfkqOPGFgTSi8hCV2UQf7NbaE5a+XWaEeze8TZ+8s7Bjb4Q1WTk=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.b=gcsV9Wek; arc=none smtp.client-ip=10.30.226.201
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.b="gcsV9Wek"
Received: by smtp.kernel.org (Postfix) with ESMTPSA id 92A31C4CEF7;
	Fri,  6 Mar 2026 16:30:31 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/simple; d=kernel.org;
	s=k20201202; t=1772814632;
	bh=OmXIeO1BMQOa9SXSEVLKkjgLXEmOLbLWpqPeWHAthv8=;
	h=Date:Subject:To:Cc:References:From:In-Reply-To:From;
	b=gcsV9WekyZBgjyexDZ+X2TyMrCebZNXQMNCg8FRN4wvrFNas0Gs4LzQ9vBewer/fA
	 zD1wfrivy7ROeK4mHbAF54qyoMelGy4Mpy63Bwqx7UOPV3yJleGQSt6L6iEBOQFMIt
	 +Oz5BPIxbsadHgi6cazxoCr5KrdYsNG0rrBa+GMsoD2kT3VgOmNGPdGBlsXgRwthPZ
	 7275phkiogax++DoGt4vvKAwbzuo5xs7DjGWjksg0OPMlWqsgO1YSM4VY7xHBw1yWC
	 EaTf8L8/uIiTyh9lfAL2YdJWjK0jUIxKhXhMRv2a/46EexLJTxv5Ffcnbw6MSD/9IO
	 WAP3pzQZvzf8Q==
Message-ID: <61b6ee13-71ac-4205-94a3-6c8daa94fd0b@kernel.org>
Date: Fri, 6 Mar 2026 11:30:30 -0500
Precedence: bulk
X-Mailing-List: linux-nfs@vger.kernel.org
List-Id: <linux-nfs.vger.kernel.org>
List-Subscribe: <mailto:linux-nfs+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:linux-nfs+unsubscribe@vger.kernel.org>
MIME-Version: 1.0
User-Agent: Mozilla Thunderbird
Subject: Re: [PATCH v2 6/8] xprtrdma: Replace rpcrdma_mr_seg with xdr_buf
 cursor
To: Anna Schumaker <anna@kernel.org>
Cc: Trond Myklebust <trond.myklebust@hammerspace.com>,
 linux-nfs@vger.kernel.org, linux-rdma@vger.kernel.org,
 Chuck Lever <chuck.lever@oracle.com>
References: <20260305145054.7096-10-cel@kernel.org>
 <20260305145054.7096-16-cel@kernel.org>
 <0f75a763-5ec9-4829-85b8-9a6ccb059704@app.fastmail.com>
From: Chuck Lever <cel@kernel.org>
Content-Language: en-US
Organization: kernel.org
In-Reply-To: <0f75a763-5ec9-4829-85b8-9a6ccb059704@app.fastmail.com>
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 7bit

On 3/6/26 11:28 AM, Anna Schumaker wrote:
> Hi Chuck,
> 
> On Thu, Mar 5, 2026, at 9:51 AM, Chuck Lever wrote:
>> From: Chuck Lever <chuck.lever@oracle.com>
>>
>> The FRWR registration path converts data through three
>> representations: xdr_buf -> rpcrdma_mr_seg[] ->
>> scatterlist[] -> ib_map_mr_sg(). The rpcrdma_mr_seg
>> intermediate is a relic of when multiple registration
>> strategies existed (FMR, physical, FRWR). Only FRWR
>> remains, so the indirection serves no purpose.
>>
>> Introduce struct rpcrdma_xdr_cursor to track position
>> within an xdr_buf during iterative MR registration.
>> The cursor is 16 bytes on the stack (a pointer and two
>> unsigned ints), replacing the 6240-byte rl_segments[260]
>> array that was embedded in each rpcrdma_req.
>>
>> Rewrite frwr_map to populate scatterlist entries directly
>> from the xdr_buf regions (head kvec, page list, tail
>> kvec) via the cursor. The boundary logic for non-SG_GAPS
>> devices is simpler than before because the xdr_buf
>> structure guarantees that page-region entries after the
>> first start at offset 0, and that head/tail kvecs are
>> separate regions that naturally break at MR boundaries.
>>
>> Rewrite the three chunk-encoding functions
>> (rpcrdma_encode_read_list, rpcrdma_encode_write_list,
>> rpcrdma_encode_reply_chunk) to use cursor-based iteration
>> instead of the two-pass convert-then-register approach.
>>
>> Fix a pre-existing bug in rpcrdma_encode_write_list where
>> the write-pad statistics accumulator added mr->mr_length
>> from the last data MR rather than the write-pad MR. The
>> refactored code uses ep->re_write_pad_mr->mr_length.
>>
>> Delete rpcrdma_convert_kvec, rpcrdma_convert_iovs, struct
>> rpcrdma_mr_seg, rl_segments, and RPCRDMA_MAX_IOV_SEGS.
>> Adapt the chunk tracepoints to take a bool is_last
>> parameter instead of the now-eliminated nsegs count.
> 
> After this patch I start to see a bunch of errors running cthon
> tests with both soft iwarp and soft roce.  With NFSv3 I see IO errors:
> 
> ./server -b -o v3,proto=rdma,sec=sys -m /mnt/test/server/nfs3 -p /srv/test/xfs/anna/nfs3 server
> The '-b' test using 'v3,proto=rdma,sec=sys' options to server: Failed!!
> /tmp/nfsv3rdma-11:10:46.error:
>         sh ./runtests  -b -t /mnt/test/server/nfs3/client.test
> 
>         Starting BASIC tests: test directory /mnt/test/server/nfs3/client.test (arg: -t)
>         mkdir: cannot create directory '/mnt/test/server/nfs3/client.test': Input/output error
>         Can't make directory /mnt/test/server/nfs3/client.test
>         basic tests failed
>         Tests failed, leaving /mnt/test/server/nfs3 mounted
> 
> I can't even get that far with NFSv4.2, the mounts just fail:
> 
> ./server -b -o v4.2,proto=rdma,sec=sys -m /mnt/test/server/nfs4.2 -p /srv/test/xfs/anna/nfs4.2 server
> Waiting for '-b' to finish ... 
> The '-b' test using 'v4.2,proto=rdma,sec=sys' options to server: Failed!!
> /tmp/nfsv4.2rdma-11:15:07.error:
>         mount.nfs: mount system call failed for /mnt/test/server/nfs4.2
>         Can't mount server:/srv/test/xfs/anna/nfs4.2 on /mnt/test/server/nfs4.2
> Done: 11:15:07
> 
> 
> Is there anything specific I should look at to try to figure out what's going on?
D'oh! I'll try to track it down.


-- 
Chuck Lever
