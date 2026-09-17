Received: from smtp.kernel.org (aws-us-west-2-korg-mail-alma10-1.taild15c8.ts.net [100.103.45.18])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 64EBF5A0ABD
	for <linux-nfs@vger.kernel.org>; Thu, 17 Sep 2026 14:58:11 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=100.103.45.18
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1789657127; cv=none; b=PWfwZ3H8kcsyVb9VHSkx7xpdikR+kJNGdLUp4igew83EvHGhYUIFh29MetQVUMsvwSpVB0y3SiYSYrStuC3taAcANvuHnyNCidf0wzH6wdl2RNXrCxPkvr682+kHqvZbYcBe3bhVpV0ysHCGK3U0YJeyHRSQgFoZ66KfXYLnz70=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1789657127; c=relaxed/simple;
	bh=pOiQIxrft1/qh1HT7FvOEfAVcOLAKoAd4QgKw+Nv9rM=;
	h=MIME-Version:Date:From:To:Cc:Message-Id:In-Reply-To:References:
	 Subject:Content-Type; b=Lvh+plbRg4zloGvuMGAppU6uzR5FEcjv744/Giq0wcp5J+36oR2SGMCyxxNvPk2o9CitXOgNhbnu/Pdt47l/eMJ8VuiB9dTk0I2qIT5UcXhIraUBZgGPJJfSutN63WWFkX5s1D1FgF/zDRf7IpRB3Kx4pJvNObXtnpqFdC2EGNw=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.b=HC1cytIX; arc=none smtp.client-ip=100.103.45.18
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.b="HC1cytIX"
Received: by smtp.kernel.org (Postfix) with ESMTPSA id B8BE91F0089A
	for <linux-nfs@vger.kernel.org>; Thu, 17 Sep 2026 14:58:07 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=kernel.org;
	s=k20260515; t=1789657087;
	bh=Zig+4O9vLbxMnSBcKkqTc+yXwiK/h65DXffRSc/09Os=;
	h=Date:From:To:Cc:In-Reply-To:References:Subject;
	b=HC1cytIX7sFwGyXoGzJfGlcwqWaYHaVBW4yLTFoMa8FtG8i+ef5LDc9jDOOSlVHZf
	 hPdhTtI8pP4Rk06hHq/KECVf+/mvRhsqE+VqA84MPBWuva/WQv/Gx4esShgAbyhk6B
	 yo4mHR4irjPmGnNPYLNBi+YHtGkNvpMgXWX2l3QzE7Y7LSwA/qu3peFDaoQsYk/mpm
	 uW3uRqg5AUKpGrJpqFwE6TxvCY+8NPtHbXMGhFCpsy1gebxPo0ux7vqeOysNOeKvoG
	 bgiRU+EiEhcdEcxVq/uXfqUUTSyTKUKnv5RYLVWOWEwgN9ZSHFVqpr/pM5mA9ZjFh6
	 ZSYU2MFVtZDpg==
Received: from phl-compute-10.internal (phl-compute-10.internal [10.202.2.50])
	by mailfauth.phl.internal (Postfix) with ESMTP id DDA7EF4006A;
	Thu, 17 Sep 2026 10:58:06 -0400 (EDT)
Received: from phl-imap-15 ([10.202.2.104])
  by phl-compute-10.internal (MEProxy); Thu, 17 Sep 2026 10:58:06 -0400
X-ME-Sender: <xms:_v-ravCUAiALrZIHWZgEcayqaqqMaMMlJ89f-jrYICMeXkBQx8aukA>
    <xme:_v-ragXetzvIU7ZDGw_KLFhFWQE8jQGdEDMHHYT8DpZJC7jLFAR05wLjXEoO8Y2i7
    xv7B6v6rxAsqHyJF7SiDIB4TdpAzyZ7WkYTAaDxT52pd4GW5t5zlG7lnQ>
X-ME-Proxy-Cause: dmFkZTE/mqf1k3J7Wnp7HUdcWt9nYOoh+zlT4l3Dyl0J/7S4D1BMB/aNCEBN1OsDiFB2Dq
    PI96s/dWNvcRxMnn88rEVawXBpaDxULUZy+HEVy6ycDx+bMGzCZ/GP22bXMZ4xOqGPMS+i
    +V/+AziBEAF1a6SIzORThsCjLxSCNyJbUjF1YCLRn1RsGKaOHa0ta1xDaa06soOvVD1JT8
    bVexTJhimEK7g7yAY2tktKxM7XO0Db9Y5VO6dPE1+szUGuwB5P7xyIbL+eJQzTn5MrJ2hu
    MzSBPaKoowL0jeuTmqMZ/TAnSZhCblPrbCzHI16mdRv6uRYEqXuRsIZTu/PssIK1Es/Oof
    8gNLzUoqcvdDMxILrR3kazP2byEaLj5FLv9k4vSs9wGpL+2RbEO0waSTJn+ix2Ezgd+smg
    +3hVwqZ+DbX36TR7HkOwzVEgslt6ZBnEEhxdOKrjNsMc5HlY8rMPkJsi1c8i3Wf01WAvA1
    S7rjRRX+PmF0PcjQdLO59ANwmv8RdspKRO5q8Twdul/yDJYuj+vRzQqLTz/JSH0T8AAAlB
    D3BBjcM1Xp9NpQJ7WjQG2PBx9QqkxTd9WvzkNhBRpmE77ZLkrApvnn4spv8jWLR9d/xquv
    Ne9qzdBfCv1PzPpfmHvFTvDAYYYUhLKoL/kVDWESpiLlDRAESTY96kiQUNFg
X-ME-Proxy: <xmx:_v-raqsfLhqsa4Z8Od9apfONGSgjKSlN4ZXUAmMKVd6XE3QPpB7PHQ>
    <xmx:_v-raoyNqPX1GgAAVN8itNoFXHb672kpI7FbBEH9ysEQ2ZIX0cSHJA>
    <xmx:_v-ratDbdVN4R71pMOSEECkbWjGcnSGqdLITOqeVf6dtvO5Gw1D2Ow>
    <xmx:_v-rameWm__Tc0u6rT_ShwAYLXbVtWAjcayocUW8-mffc2yJptaUFQ>
    <xmx:_v-rankKXKWVswM-PTeR5L2zcBD1Q1kY77vDzCOyTrQ9iUQO-O4z2lDq>
Feedback-ID: ifa6e4810:Fastmail
Received: by mailuser.phl.internal (Postfix, from userid 501)
	id C0C60780075; Thu, 17 Sep 2026 10:58:06 -0400 (EDT)
X-Mailer: MessagingEngine.com Webmail Interface
Precedence: bulk
X-Mailing-List: linux-nfs@vger.kernel.org
List-Id: <linux-nfs.vger.kernel.org>
List-Subscribe: <mailto:linux-nfs+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:linux-nfs+unsubscribe@vger.kernel.org>
MIME-Version: 1.0
X-ThreadId: A_u4bRgnV0G7
Date: Thu, 17 Sep 2026 10:57:40 -0400
From: "Chuck Lever" <cel@kernel.org>
To: "Jeff Layton" <jlayton@kernel.org>, NeilBrown <neil@brown.name>,
 "Olga Kornievskaia" <okorniev@redhat.com>, "Dai Ngo" <dai.ngo@oracle.com>,
 "Tom Talpey" <tom@talpey.com>
Cc: linux-nfs@vger.kernel.org
Message-Id: <b20bdc5e-013b-4cac-adec-aa80d0b5638d@app.fastmail.com>
In-Reply-To: <4edae19999311917fdc27b6a736a567bc6de249c.camel@kernel.org>
References: <20260916162859.2051-1-cel@kernel.org>
 <4edae19999311917fdc27b6a736a567bc6de249c.camel@kernel.org>
Subject: Re: [PATCH v1 00/27] Convert server-side NFSv2 XDR to use xdrgen
Content-Type: text/plain
Content-Transfer-Encoding: 7bit



On Thu, Sep 17, 2026, at 7:56 AM, Jeff Layton wrote:
> On Wed, 2026-09-16 at 12:28 -0400, Chuck Lever wrote:
>> Replace NFSD's NFSv2 XDR encoders and decoders with code that is
>> mechanically generated directly from the NFSv2 RPC language
>> specification.
>> 
>> The benefits for NFSv2 are marginal. When we eventually convert
>> newer NFS versions to use xdrgen, I expect a reduction in human
>> coding errors, improved spec compliance, and better memory safety
>> for those more complex NFS programs.
>> 
>> These patches have been lightly tested with fstests run against an
>> xfs export.

> This all looks like a fairly sane and straightforward conversion, but
> it's too much to review in detail. It's almost a shame to do this at a
> time when we're talking about deprecating v2, but if it makes ongoing
> maintenance easier, then I'm on board.

NFSv3 and NFS_ACL v3 are staying around, and they are currently
fairly intertwined with the NFSv2 XDR code. So part of this
conversion *will* live on even after NFSv2 support is removed,
since it de-tangles NFSv2 and NFSv3 to some extent.


> Also, there are 2 patches that were sent as part of this series, but
> seem to be a separate series:
>
> [PATCH v1 1/2] NFSD: map fh_verify() status codes for NFS_ACLv2 replies
> [PATCH v1 2/2] NFSD: map fh_verify() status codes for NFS_ACLv3 replies
>
> Did you mean to send those separately?

I didn't. Those were already sent and the patch email files
were loitering in the same directory as the 27 NFSv2 conversion
patches.


-- 
Chuck Lever (Come to NFS bake-a-thon! https://nfsv4bat.org)
