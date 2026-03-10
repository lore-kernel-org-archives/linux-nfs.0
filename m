Received: from smtp.kernel.org (aws-us-west-2-korg-mail-1.web.codeaurora.org [10.30.226.201])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 02FC3295DAC
	for <linux-nfs@vger.kernel.org>; Tue, 10 Mar 2026 18:24:27 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=10.30.226.201
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1773167068; cv=none; b=IPagXpVnNqhZ1slnGtRed2/SB91A+fasJq4f/LN+XADumjAdt4cSVe6zqkoLzGufdmG0AMfa4TOHJ4Qf3MsJ4m6kS9uFxjcYdRZJCvJPd+t4vthfV8M5RvxGFbEY5gMsopyMp570FC2NaH9vAvQHAFcSrway4Cvp5dVQtEE/ICk=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1773167068; c=relaxed/simple;
	bh=qhwmtfc0MkerkcTUn0dOtGlRVfQrAF19OIrD9QSM/f0=;
	h=Message-ID:Date:MIME-Version:Subject:To:Cc:References:From:
	 In-Reply-To:Content-Type; b=qOjZep7xwiI4BH6g3lFY0MIhpfZ88/5CN1mCpxh5K7XMM2GOCKKaxYBmbjqbu1E+LGSoMvHvilxChaFryVsb+o36G3JlG8afvVJKxz+4eY4cUp+YFweUeDfK44CTEsoUh/ze9vI5GqEJsfBO6woyBOBpIPiRIgOIFmQhN5A9ScA=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.b=J+QTjEFr; arc=none smtp.client-ip=10.30.226.201
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.b="J+QTjEFr"
Received: by smtp.kernel.org (Postfix) with ESMTPSA id 08B82C19423;
	Tue, 10 Mar 2026 18:24:26 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/simple; d=kernel.org;
	s=k20201202; t=1773167067;
	bh=qhwmtfc0MkerkcTUn0dOtGlRVfQrAF19OIrD9QSM/f0=;
	h=Date:Subject:To:Cc:References:From:In-Reply-To:From;
	b=J+QTjEFrnlHDOfHGI9k6CE5pem/b+knBZTa/zBjZbRvuEQxA/uTTwyJ7et95G4goZ
	 zGtFm4mB6zLDQT05j/AnZTgz/P5sNVWpbfb3vcvEYyAvIOf6KUvtmuqO7wQp9dsVob
	 cXMkvOMg4fbrDasviT62VAkCxpyE+SJwhxMIx4kbF4asttEey/QjYuFyZyYjmmbWXE
	 abySuRg9VNB5f3oyPlorB1WknMWGtfAJrUApks9dcDzJhQsc5qiBWkYTatkpAgXlbb
	 Ec8Mtu+VzmtvpcAaNjjiAkqb3TyOJscnHg8i0Ve2Qa7N+xI1Ot+G2kApNuzNzhco/o
	 EC4XzWYmzvovQ==
Message-ID: <9314b7cc-0ed5-497f-ad28-a308e4149c84@kernel.org>
Date: Tue, 10 Mar 2026 14:24:26 -0400
Precedence: bulk
X-Mailing-List: linux-nfs@vger.kernel.org
List-Id: <linux-nfs.vger.kernel.org>
List-Subscribe: <mailto:linux-nfs+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:linux-nfs+unsubscribe@vger.kernel.org>
MIME-Version: 1.0
User-Agent: Mozilla Thunderbird
Subject: Re: [PATCH v2 0/6] Optimize NFSD buffer page management
To: Jeff Layton <jlayton@kernel.org>, NeilBrown <neilb@ownmail.net>,
 Olga Kornievskaia <okorniev@redhat.com>, Dai Ngo <dai.ngo@oracle.com>,
 Tom Talpey <tom@talpey.com>
Cc: linux-nfs@vger.kernel.org, Chuck Lever <chuck.lever@oracle.com>
References: <20260226144739.193129-1-cel@kernel.org>
 <2496d230c2cc7abf8941927bb8e7bd944127a769.camel@kernel.org>
From: Chuck Lever <cel@kernel.org>
Content-Language: en-US
Organization: kernel.org
In-Reply-To: <2496d230c2cc7abf8941927bb8e7bd944127a769.camel@kernel.org>
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 7bit

On 3/10/26 2:19 PM, Jeff Layton wrote:
> On Thu, 2026-02-26 at 09:47 -0500, Chuck Lever wrote:
>> From: Chuck Lever <chuck.lever@oracle.com>
>>
>> This series solves two problems. First:
>>
>>  NFSv3 operations have complementary Request and Response sizes.
>>  When a Request message is large, the corresponding Response
>>  message is small, and vice versa. The sum of the two message
>>  sizes is never more than the maximum transport payload size. So
>>  NFSD could get away with maintaining a single array of pages,
>>  split between the RPC send and Receive buffer.
>>
>>  NFSv4 is not as cut and dried. An NFSv4 client may construct an
>>  NFSv4 COMPOUND that is arbitrarily complex, mixing operations
>>  that can have large Request size with operations that have a
>>  large Response size. The resulting server-side buffer size
>>  requirement can be larger than the maximum transport payload size.
>>
>>  Therefore we must increase the allocated RPC Call landing zone and
>>  the RPC Reply construction zone to ensure that arbitrary NFSv4
>>  COMPOUNDs can be handled.
>>
>> Second:
>>
>>  Due to the above, and because NFSD can now handle payload sizes
>>  considerably larger than 1MB, the number of array entries that
>>  alloc_bulk_pages() walks through to reset the rqst page arrays
>>  after each RPC completes has increased dramatically.
>>
>>  But we observe that the mean size of NFS requests remains smaller
>>  than a few pages. If only a few pages are consumed while processing
>>  each RPC, then traversing all of the pages in the page arrays for
>>  refills is wasted effort. The CPU cost of walking these arrays is
>>  noticeable in "perf" captures.
>>
>>  It would be more efficient to keep track of which entries need to
>>  be refilled, since that is likely to be a small number in the most
>>  common case, and use alloc_bulk_pages() to fill only those entries.
>>  
>> ---
>>
>> Changes since RFC:
>> - Clarify a number of comments based on review (NeilBrown)
>> - Possible NFSv3 waste is still open for discussion
>>
>> Chuck Lever (6):
>>   SUNRPC: Tighten bounds checking in svc_rqst_replace_page
>>   SUNRPC: Allocate a separate Reply page array
>>   SUNRPC: Handle NULL entries in svc_rqst_release_pages
>>   svcrdma: preserve rq_next_page in svc_rdma_save_io_pages
>>   SUNRPC: Track consumed rq_pages entries
>>   SUNRPC: Optimize rq_respages allocation in svc_alloc_arg
>>
>>  include/linux/sunrpc/svc.h              | 61 +++++++++++++++----------
>>  net/sunrpc/svc.c                        | 59 +++++++++++++++++-------
>>  net/sunrpc/svc_xprt.c                   | 47 +++++++++++++++----
>>  net/sunrpc/svcsock.c                    |  7 +--
>>  net/sunrpc/xprtrdma/svc_rdma_recvfrom.c | 15 ++----
>>  net/sunrpc/xprtrdma/svc_rdma_rw.c       |  1 +
>>  net/sunrpc/xprtrdma/svc_rdma_sendto.c   |  6 +--
>>  7 files changed, 125 insertions(+), 71 deletions(-)
> 
> The patches all look good to me. I like getting rid of the old "sliding
> window", which was error prone. The extra memory consumption sort of
> sucks, but an extra 1M per thread should be no big deal for most nfsd
> deployments.
> 

Thanks for having a look. My feeling is the new dynamic nfsd thread
count mechanism should mitigate much of the extra memory consumption.

Meanwhile, I think this is not going to be the final stop on the train
of optimizations in this area.


-- 
Chuck Lever
