Received: from smtp.kernel.org (aws-us-west-2-korg-mail-alma10-1.taild15c8.ts.net [100.103.45.18])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id CDDAF34AB14
	for <linux-nfs@vger.kernel.org>; Mon,  3 Aug 2026 16:04:40 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=100.103.45.18
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1785773082; cv=none; b=EVN+hIJj6+Mv95jsr/7r5PIRtjkducrVXZ+sWDWXIrem3Uh5dheIInUvIuVF5DGfvTVvzayU0EQpGotTHnJoICqF8bsZ0coy7+MXuLzF7tGO7Nr9/+l2eujYQC9x2dankpsNKSOAH07hhNP3Iv8zEkAoRAaEqQ1/YXvHVJLbxzk=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1785773082; c=relaxed/simple;
	bh=L+oz4810AuZPVlhhXScKKgBbwOv5T1VeO2oBYg7TMks=;
	h=MIME-Version:Date:From:To:Cc:Message-Id:In-Reply-To:References:
	 Subject:Content-Type; b=HYkZ8IDoGbfabUIfAV33n75hZmlRnrCgGCP9ikQ3s8S6jbuvszYqeIEGApte9grcPK4az2sQIkfnYICEY7xuMJlK0s6pexlmGuA94jvYnSGbFYBpdMhxnI82bsTNTy3IhnIc8xVx3lsb30NGa/Y9NTVDfsmhhv1uijS18vgVxMk=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.b=Ct+nsW11; arc=none smtp.client-ip=100.103.45.18
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.b="Ct+nsW11"
Received: by smtp.kernel.org (Postfix) with ESMTPSA id 3DBF21F00A3E;
	Mon,  3 Aug 2026 16:04:40 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=kernel.org;
	s=k20260515; t=1785773080;
	bh=3P2+M0/uJuvXeqrX7ImnsDrjPJ4Rsq7UL4buKeeANvs=;
	h=Date:From:To:Cc:In-Reply-To:References:Subject;
	b=Ct+nsW115ZnFMR0MpRh6pTyjdaQPflpBbchaEZgIKx0uZoA+AbVIHf+7tgbvD566v
	 wj0joUGRCBZFEnw4JAZXE8EJ16ThG7GpYUx8/DlOIVkD/dk3ELzciSZrZZiniuj2sh
	 99OYYpSKf0WRpyQvj5i6YqLZB6f+so1R4SpTLDwYfKI91gHYHVD/LLxXDAp+8N5Ni4
	 C9AmnBc+sU1xTkQkB8XM65Y8Y5KM4HIzh7i7XhNTGK3YfOh9H2M4HcquIfrkVSQOMk
	 mfSsFQSsHQgHbh66NgsCUMWuhU3ZBzlqCWMQyVZNglqCRMS+E+ZK+LvqbDu21IkIzB
	 OJWwT/iqiX5Lg==
Received: from phl-compute-10.internal (phl-compute-10.internal [10.202.2.50])
	by mailfauth.phl.internal (Postfix) with ESMTP id 48F40F40066;
	Mon,  3 Aug 2026 12:04:39 -0400 (EDT)
Received: from phl-imap-15 ([10.202.2.104])
  by phl-compute-10.internal (MEProxy); Mon, 03 Aug 2026 12:04:39 -0400
X-ME-Sender: <xms:F7xwauFDXEW1sv0eCsWil6JGmiB2tSb53Vyqc8b9K3Sy2mmKJNYpyA>
    <xme:F7xwaqLgP_qLgpqdAFrJlEtgxx-K0ra89ZLdiz_va0s5FvlCM4Kkkx_Ivg3Kj8fhU
    A21eTLxMQpKZSkYVJc7EZdWOOyMa9tyGmkO2mKBlIg386s_w_lE6Qc>
X-ME-Proxy-Cause: dmFkZTEIJqn7NtJ/zW6K6nMYHTh+ATFE22Ht2iuCAQ+u/wDon48pa2KYZO/PTZtGLC6Slu
    M3oHXxG36D7jdyXT09fsCqQK/FzRfiHgoDrhOc+autyo2C2Andnqd4DMf+qhP7I1UIOP3d
    gN79dboHGeBns1JwZRp2FsVBe/KOjdCx9eyb6NSGujaXSejy4rx+Ivfe/ErWgan7vOCetn
    mQ0WtnPimwSKKvHTjzis9a2AMW7HYXBGaYyRR9D4pT+TqAzRY+PJx2HCbj1hESEUPXUVWm
    dlzGfbPGW6qDeXo0gNA/un+mK8+LD5EoCPEr9ZLAXgk+sRZBSAMhRCsv5fZonA0m5Li+Pc
    /joxRtLj5OAH8Vr1BmvZJ0syhRPUKLTU/+itRklkOmC170nzgPY02yOnbDaUoSKlx1w/0E
    Uj8D+87oo/lc1DKPip9ygPMVd2abyRjEmBrxRVdu4EFstE6DSm9CYcNvqewDsLEwObDXU0
    ofPKYYsjYOoqqUBuRPrnFmz3tg8HMDwSpvs2hgpEU3NE4Jv+hj5+YLnEdu+DzxvYL2+RW2
    wqsfqLSMp8AocVU/OFa3o+WUvV7h7IHcMXL+gtBkTFsYtHsYTLiHJOaJHD0l/rE/lk6nvb
    DNaNWdl5Fz9Swz1+q2mPPckalaZ6VWNtkOGwWsoSjtaB51tzX4t8nYf2KVhg
X-ME-Proxy: <xmx:F7xwap0BxD_kd9Kx_6eH3rgXzORZO_bMJHb1r_1QZrBSrj9SAClKDg>
    <xmx:F7xwam0OZ2VcEQqH5XZ6-MFqZD_MA_dstKSNa_EW6xyjLRTDk-9CcA>
    <xmx:F7xwarryBslhUP1qdV85r4YWKOeT_M4qZ15MDffil44BgwkDelgjbA>
    <xmx:F7xwaihKnmxkjuwoGQehKRNdwto--Th6v70HKG9efWnyRkTvdNWa4A>
    <xmx:F7xwan84cpCb_1yAYI5sDQKb7cRizv5vPg9lFQ4SMqyMJFMUxyIuzoYG>
Feedback-ID: ifa6e4810:Fastmail
Received: by mailuser.phl.internal (Postfix, from userid 501)
	id 2AD6F780070; Mon,  3 Aug 2026 12:04:39 -0400 (EDT)
X-Mailer: MessagingEngine.com Webmail Interface
Precedence: bulk
X-Mailing-List: linux-nfs@vger.kernel.org
List-Id: <linux-nfs.vger.kernel.org>
List-Subscribe: <mailto:linux-nfs+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:linux-nfs+unsubscribe@vger.kernel.org>
MIME-Version: 1.0
X-ThreadId: A0Y-jwfPBytZ
Date: Mon, 03 Aug 2026 12:04:19 -0400
From: "Chuck Lever" <cel@kernel.org>
To: "Jeff Layton" <jlayton@kernel.org>, NeilBrown <neil@brown.name>,
 "Olga Kornievskaia" <okorniev@redhat.com>, "Dai Ngo" <Dai.Ngo@oracle.com>,
 "Tom Talpey" <tom@talpey.com>
Cc: linux-nfs@vger.kernel.org, linux-kernel@vger.kernel.org,
 "kernel test robot" <lkp@intel.com>
Message-Id: <c018418c-4f4e-4984-8312-c082509090cd@app.fastmail.com>
In-Reply-To: <b8a7379cf6e8e73a0e994937a6b738757a8be744.camel@kernel.org>
References: <20260803-dir-deleg-v1-0-51be76861821@kernel.org>
 <20260803-dir-deleg-v1-1-51be76861821@kernel.org>
 <54f8ab19-fb1b-4cd6-9600-e3d3d6971173@app.fastmail.com>
 <b8a7379cf6e8e73a0e994937a6b738757a8be744.camel@kernel.org>
Subject: Re: [PATCH 1/2] nfsd: fix type mismatch and explain host-endian xdr buffer
 usage
Content-Type: text/plain
Content-Transfer-Encoding: 7bit



On Mon, Aug 3, 2026, at 11:43 AM, Jeff Layton wrote:
> On Mon, 2026-08-03 at 11:32 -0400, Chuck Lever wrote:
>> 
>> On Mon, Aug 3, 2026, at 10:49 AM, Jeff Layton wrote:
>> > sparse flagged this type mismatch. Also the xdr buffer usage is a bit
>> > non-standard, so explain what we're doing and why.
>> > 
>> > Fixes: 4b64b811f368 ("nfsd: add notification handlers for dir events")
>> > Reported-by: kernel test robot <lkp@intel.com>
>> > Closes: 
>> > https://lore.kernel.org/oe-kbuild-all/202607310455.AT0GoC5j-lkp@intel.com/
>> > Signed-off-by: Jeff Layton <jlayton@kernel.org>
>> > ---
>> >  fs/nfsd/nfs4xdr.c | 11 ++++++++---
>> >  1 file changed, 8 insertions(+), 3 deletions(-)
>> > 
>> > diff --git a/fs/nfsd/nfs4xdr.c b/fs/nfsd/nfs4xdr.c
>> > index a47eb544b99f..5cbb4a415384 100644
>> > --- a/fs/nfsd/nfs4xdr.c
>> > +++ b/fs/nfsd/nfs4xdr.c
>> > @@ -4383,13 +4383,18 @@ nfsd4_setup_notify_entry4(struct notify_entry4 
>> > *ne, struct xdr_stream *xdr,
>> >  	struct path path = nf->nf_file->f_path;
>> >  	struct nfsd4_fattr_args args = { };
>> >  	const u32 *reqmask;
>> > -	uint32_t *attrmask;
>> > +	u32 *attrmask;
>> >  	__be32 status;
>> >  	bool parent;
>> >  	int ret;
>> > 
>> > -	/* Reserve space for attrmask */
>> > -	attrmask = xdr_reserve_space(xdr, 3 * sizeof(uint32_t));
>> > +	/*
>> > +	 * attrmask is the host-order bmval[3] that nfsd4_encode_attr_vals()
>> > +	 * consumes and that ne_attrs.attrmask.element points at. It must
>> > +	 * outlive this call, so steal a few words from the xdr stream to hold
>> > +	 * it.
>> > +	 */
>> > +	attrmask = (u32 *)xdr_reserve_space(xdr, 3 * sizeof(*attrmask));
>> >  	if (!attrmask)
>> >  		return false;
>> 
>> I still don't understand what's going on. "Steal a few words to hold it"
>> sounds like you're trying to avoid a kmalloc call. Is this code reserving
>> space in the XDR stream, or isn't it? If it is, then accessing those bytes
>> has to be done with a big-endian pointer, the same way it is done at every
>> other xdr_reserve_space() call site. Storing host-order bytes that are not
>> part of an opaque into an XDR stream is just... wrong.
>> 
>> If you're doing the usual "reserve and backfill the encoded data later"
>> dance, then spell it the way everyone else does so us poor human readers
>> can recognize that's what's going on.
>
> It's using a small piece of the xdr buffer (3 32-bit words) to hold the
> host-endian bitmap fields that will later be encoded into the stream
> when the encoding is actually done.
>
> This piece is not accessed by anything else and there is plenty of room
> in the buffer, so I don't see the issue here. Can you elaborate on why
> you feel that this is a problem?

Well A-number-1 is that it's a hack and technical debt. It just
isn't obvious what's going on, it needs a four-line comment to
explain it, and it opens the door to people copy-pasting it to
other encoders.

Number 2 is that the XDR stream buffer is ephemeral. There are
conditions that callers must stick to to keep that pointer valid
for the lifetime of the xdr_stream.

Number 3: Yes, we have a sordid history of grabbing a piece of
the xdr_buf's tail iov for temporary storage. That doesn't make
it wise to do, and assumes behavior about that buffer that is
not guaranteed by sunrpc's API contracts. That makes life hard
when future changes need to change that buffer to, say, a page
rather than kmalloc'd memory. Or when I want to convert this
code to use xdrgen instead of hand-rolled encoding.

So what you've done is fine for operational prototype code, but
not something we can carry forward as production code. The sparse
warning is a canary, it's not the actual structural problem.


> Certainly we could do this with yet another set of separate
> allocations, but I'm not clear on how we'd track them to free them.
> Each notify_entry4 gets a separate bitmap, so we'd need more than one.

The server has a chain of temporary allocations that are freed
after the COMPOUND is released. Could do something similar for
the server's callback client.


-- 
Chuck Lever
