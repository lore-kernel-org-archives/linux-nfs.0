Received: from smtp.kernel.org (aws-us-west-2-korg-mail-alma10-1.taild15c8.ts.net [100.103.45.18])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id A61BE3FF1B4
	for <linux-nfs@vger.kernel.org>; Wed, 12 Aug 2026 22:13:25 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=100.103.45.18
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1786572806; cv=none; b=HfPmgyy0T9voQyZCYHMf0wS9HcEdJR8hK/7nmnB3uwBX9wtbnrUi7KvMIfUvQaPiiISmdpOKUMTlaNGtHF2Ji6lxexppl4y1Yda+BeGUdf8uugW7lRiXDpmhMaARQUDJ7KtMBa5pXMrMvchjnby1oA9gLjPr1A0AVnmsZnwQOTM=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1786572806; c=relaxed/simple;
	bh=XjyeCIdNAdLUa2rNI9NsfMyHiXDnhbYVenF8XMtYSRo=;
	h=Date:From:To:Cc:Subject:Message-ID:References:MIME-Version:
	 Content-Type:Content-Disposition:In-Reply-To; b=R2GvHx/53ZuY9TW5GVN07YU9N/V6gvvbO8wXK98elXK/bkDzQY2SUQ2Olb6fHqRBafvNW9rEFghOMMefSW34x7MEvV0hTPWQqOh2V7QKywEvav2fb06n0gBK4eNS3uf2bhqdtODo5EgToHCIZejdUy9fdr7HcL/MaUjW1VRzQ7U=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.b=AiC78zWp; arc=none smtp.client-ip=100.103.45.18
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.b="AiC78zWp"
Received: by smtp.kernel.org (Postfix) with ESMTPSA id 22D571F000E9;
	Wed, 12 Aug 2026 22:13:25 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=kernel.org;
	s=k20260515; t=1786572805;
	bh=p3hXWyBDLihSFFGfFe644R0erepdbJyLSadPJ6Vr6MU=;
	h=Date:From:To:Cc:Subject:References:In-Reply-To;
	b=AiC78zWpVBgQy4x/aYXFuzT5t5bsUfBejFDOrrlsdi9wCNesXEyU1n7jdfE4ZIJVN
	 2r7bg4K8PB099Lp0WUcZLyfBkTKcV8dXywzzD+SFFBh2mKa3eOQsaNcg1piPu+o2z7
	 x4uC++OcrJjB5bMl642D+KkNd/BxVsBQieb0fk8N9zRpzdLoTRixskkF9Ft6woZsRX
	 1UVjv/mtEwa9DceegVMRVc1I7F1O0D0OCNsMVcZS2q3PPShFp2VyDja4CcpFzwgVaI
	 N+hP1tKuwZvyo1owsfe19t6sKvqBQCmaPr/YXJYZc92J0bQs2KHPJE5Vc9DKoq9ku2
	 0C/VrY5bTWYHQ==
Date: Wed, 12 Aug 2026 18:13:24 -0400
From: Mike Snitzer <snitzer@kernel.org>
To: Anna Schumaker <anna@kernel.org>
Cc: Trond Myklebust <trondmy@kernel.org>, linux-nfs@vger.kernel.org
Subject: Re: NFS/localio: fix nfs_local_dio_misaligned tracepoint
Message-ID: <anzwBIacMU73oYn_@kernel.org>
References: <20260708213610.19001-1-snitzer@kernel.org>
 <9a005347-837e-4a0b-b2a7-972f3cb59052@app.fastmail.com>
Precedence: bulk
X-Mailing-List: linux-nfs@vger.kernel.org
List-Id: <linux-nfs.vger.kernel.org>
List-Subscribe: <mailto:linux-nfs+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:linux-nfs+unsubscribe@vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <9a005347-837e-4a0b-b2a7-972f3cb59052@app.fastmail.com>

On Tue, Jul 21, 2026 at 09:56:33AM -0400, Anna Schumaker wrote:
> Hi Mike,
> 
> On Wed, Jul 8, 2026, at 5:36 PM, Mike Snitzer wrote:
> > The intended focus of nfs_local_iters_setup_dio()'s call to
> > trace_nfs_local_dio_misaligned() is on the middle segment being
> > misaligned, yet the @offset passed in was local_dio->start_len.
> > It would appear this was a cut-n-paste bug from the preceding
> > nfs_local_iter_setup() call that passes local_dio->start_len.
> >
> > Fix this by passing the @offset as local_dio->middle_offset and
> > calculate the start segment's offset rather than assume.
> >
> > Example traces, before this fix:
> >
> >    python3-32744   [006] .l... 132946.352360:
> >    nfs_local_dio_write: fileid=00:33:1286 fhandle=0xf1f7c10b
> >    offset=1048759 count=1048576 mem_align=4 offset_align=512
> >    start=1048759+329 middle=1049088+1048064 end=2097152+183
> >
> >    python3-32744   [006] .l... 132946.352360:
> >    nfs_local_dio_misaligned: fileid=00:33:1286 fhandle=0xf1f7c10b
> >    offset=329 count=1048064 mem_align=4 offset_align=512
> >    start=329+329 middle=1049088+1048064 end=2097152+183
> >
> > After this fix:
> >
> >    python3-32744   [006] .l... 132946.352360:
> >    nfs_local_dio_write: fileid=00:33:1286 fhandle=0xf1f7c10b
> >    offset=1048759 count=1048576 mem_align=4 offset_align=512
> >    start=1048759+329 middle=1049088+1048064 end=2097152+183
> >
> >    python3-32744   [006] .l... 132946.352360:
> >    nfs_local_dio_misaligned: fileid=00:33:1286 fhandle=0xf1f7c10b
> >    offset=1049088 count=1048064 mem_align=4 offset_align=512
> >    start=1048759+329 middle=1049088+1048064 end=2097152+183
> >
> > Cc: stable@vger.kernel.org
> 
> Do you have a fixes tag for this commit?
>
> Thanks,
> Anna

Sorry, I somehow missed this until now.  Looks to be:

Fixes: 6a218b9c3183e ("nfs/localio: do not issue misaligned DIO out-of-order")
