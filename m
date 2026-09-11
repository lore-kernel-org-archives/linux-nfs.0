Received: from smtp.kernel.org (aws-us-west-2-korg-mail-alma10-1.taild15c8.ts.net [100.103.45.18])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 4920534252D;
	Fri, 11 Sep 2026 14:42:19 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=100.103.45.18
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1789137740; cv=none; b=DK3bxtl8hsPCLJ1WqVLBA0PeTWMSgfLGlf91senLlM5dZ9daDJpExLMguCsOVsxSoTLPH5aJ3daNMPwKFUn2bP9XrkJ8ZIe6djqDYNIqAHUH+ZkgBOcZr6DYcbholhi6vJxaK/+nnVfPUw4oDNrZiDjZGIcI4BciVPx/XcjltPQ=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1789137740; c=relaxed/simple;
	bh=ZJvILFXfqLrN6MWpCkkcmbMEe17Lgrao+NuI5sGdMUc=;
	h=MIME-Version:Date:From:To:Cc:Message-Id:In-Reply-To:References:
	 Subject:Content-Type; b=UNanHPE5xLsa5Q6PQ6ZgXu4afZwnyVr+e+NZAYeK5wduTZP2Yql532i3CfrFyB9L6F+q4CzHKP+3xWCmsab6//gCh1NwiKAUWScmnzz8tDnHo6kMtDnRiHKI8y4IyWF3UVx7BozdMwpyp4T9BhKnxpD6jQBZQ1h0VPh8r90rhSs=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.b=UTODIENp; arc=none smtp.client-ip=100.103.45.18
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.b="UTODIENp"
Received: by smtp.kernel.org (Postfix) with ESMTPSA id 6C6A21F00898;
	Fri, 11 Sep 2026 14:42:18 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=kernel.org;
	s=k20260515; t=1789137738;
	bh=jzIVeIhjtNFySoQ9axI4l0d2pzod0TfXsrojah0kEAs=;
	h=Date:From:To:Cc:In-Reply-To:References:Subject;
	b=UTODIENpMxVF5/nkgtBCeTavAEBfMZziPNDkRjSwD9xUzvnVpC2SmvzQCQC3WP2gj
	 PZn9p835lFxhDLzj7sgQFHr46TEcfvp9hBINTe8xqT5zQcRs94Th+Riw20RwXkzBGM
	 qEQww4NWThp8IoieX5/ZfSHf4Ct11aoKIGQz1IAx2Sm+rDyBZ+vYPzCm/Jm+aipWoO
	 7SB7fmfwRyEC0fmTToGKFPd2mlIY3e4hxXz0fVjp2zU6esIWKB0nwD5T6NG3LryneM
	 WlDz1jyN0mg9bhC5Ifrlfap5kBZ8OZNUSqVS61aN5sVF21+KYoTlIgyuQhSEcO0rSg
	 t0zOBPzb17BTQ==
Received: from phl-compute-02.internal (phl-compute-02.internal [10.202.2.42])
	by mailfauth.phl.internal (Postfix) with ESMTP id 89C63F40066;
	Fri, 11 Sep 2026 10:42:17 -0400 (EDT)
Received: from phl-imap-04 ([10.202.2.82])
  by phl-compute-02.internal (MEProxy); Fri, 11 Sep 2026 10:42:17 -0400
X-ME-Sender: <xms:SROkakMqrIKnZKA8ifh_ITqnOnrFMXXeuJQgiJCyxVMkTnKhg5T40g>
    <xme:SROkalwEmTx8K1Xx4vQv0h3s2UTjaaqQ4AwRIkZ0T_PixneJRXTLMtEYPKjukZomF
    ReWuhmkZXayGr3VY5cmXhZfEphhnp2zNzYa5rRCr1FJudWtfqBgqjya>
X-ME-Proxy-Cause: dmFkZTEwmORBrOBGy3zchLvhuyGMAGTNVOECzxDrR6LbMQMVkgoaTCjPOw4U4v1oZJFECR
    J5nc2ImjfZ3truW5TFVoBJ/YtRlHp/w2gOxNqxczC2gtjk2FDKorhF0eWgTXNl8EUKy5fB
    eLYd2Eej7ETDvX4odSByPV5jK4c0zSowsiKDs27uNcR0Z56aPbvV2F/K7h/5bh0xTYzJLT
    6hR7RULlogRzJNZeFfozIciyXTQlF6H1uEEJaMFqomteqSukJyX6V0qvfgH6n4YwTNAjEB
    hs6fgnwLmyV1NK/nAhyBzcODyHJaO80K6rlzJG3yyVeBG7nOOusgbCKRAohqZeWe+de6HU
    200eRNK6fbBySudA4kwzYmpzx7fGQ7/I+ksXOi8YlZmE9TN8Sk8V/QJmFPft6oCqsyb0a9
    04kzrsn3vWL1hMmmbjFLP6Del8QRl9HM+C50AW/MiP/bIfrRJ7o1FzBhaEqgtwlg1tcaSF
    dkNFyxkfkMVLtTsdqEhCOu+sE7ZnClEgfhSMVlq7m5RhqK+Iq7UXBtu0cyBaTciw8Lo5KY
    kNu+aC6KDiEd/ijkVdLhAWx3BBNj2jgUIREEJSJsNqSwEYXiM5VQPQy+nCpPQYC8oKch0V
    04WEx8KoiQHyi+U9mqg22OCp8zZRxHlu5qhMrsGAXb3o1jsov58D9EWPitdQ
X-ME-Proxy: <xmx:SROkag_8z9uP_9JLO5ZduPwGRTlpUP9N0WB5xIHVgk2nZGa7B4Gsxg>
    <xmx:SROkavNrRTmFmfEeqPy2L_agaH8-t6TyapvNg0J1L37FYLLpkX3Nsg>
    <xmx:SROkakBTeZg_vTh0vALjOVczFdGXjF4Zr3i9wkyVu45qysK6cBKkww>
    <xmx:SROkajM-HjnNKkhhbrnzPCnppt0i5UIffb_nUUfSBxFV6_5dhpKHbQ>
    <xmx:SROkarcwtIhmUVQd1bpKyDgzOjqhiVgafjQoFG157NF0xl7QXNk3G0lT>
Feedback-ID: i20964851:Fastmail
Received: by mailuser.phl.internal (Postfix, from userid 501)
	id 6D9A7B6006E; Fri, 11 Sep 2026 10:42:17 -0400 (EDT)
X-Mailer: MessagingEngine.com Webmail Interface
Precedence: bulk
X-Mailing-List: linux-nfs@vger.kernel.org
List-Id: <linux-nfs.vger.kernel.org>
List-Subscribe: <mailto:linux-nfs+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:linux-nfs+unsubscribe@vger.kernel.org>
MIME-Version: 1.0
X-ThreadId: AyyZ_jHnZjjs
Date: Fri, 11 Sep 2026 10:41:57 -0400
From: "Anna Schumaker" <anna@kernel.org>
To: "Pranjal Shrivastava" <praan@google.com>, linux-nfs@vger.kernel.org,
 "Trond Myklebust" <trondmy@kernel.org>
Cc: "Chuck Lever" <cel@kernel.org>, "Jeff Layton" <jlayton@kernel.org>,
 linux-kernel@vger.kernel.org, "Christoph Hellwig" <hch@lst.de>,
 "Logan Gunthorpe" <logang@deltatee.com>, "Jason Gunthorpe" <jgg@ziepe.ca>,
 linux-pci@vger.kernel.org, linux-rdma@vger.kernel.org,
 "Shivaji Kant" <shivajikant@google.com>
Message-Id: <0b3d8f13-e691-411a-a507-d3e6bd1608c6@app.fastmail.com>
In-Reply-To: <aqP6nM7OSX087UCs@google.com>
References: <20260814143255.861084-1-praan@google.com>
 <aqP6nM7OSX087UCs@google.com>
Subject: Re: [PATCH v6 0/5] nfs: modernize direct I/O path
Content-Type: text/plain
Content-Transfer-Encoding: 7bit

Hi Pranjal,

On Fri, Sep 11, 2026, at 8:57 AM, Pranjal Shrivastava wrote:
> On Fri, Aug 14, 2026 at 02:32:50PM +0000, Pranjal Shrivastava wrote:
>> Modernize the NFS Direct I/O path as a preparatory step to enable PCI
>> Peer-to-Peer DMA (P2PDMA) support. Following feedback on the initial
>> RFC [1], the modernization and architectural changes are split into
>> different series. Additionally, based on the discussion in the v2 [2]
>> of this series, the migration of NFS Direct I/O to folios would be
>> handled in a separate follow-up series.
>> 
>> Currently, NFS O_DIRECT relies on the legacy iov_iter_get_pages_alloc2()
>> API which does not support the pinning requirements for P2P memory.
>> The implementation moves NFS to the modern iov_iter_extract_pages() API.
>> 
>
> Gentle ping on this series. 
> (I realized that I sent it close to the merge window, Apologies).
>
> Please let me know if anything else needs to be done for this..

Thanks for the ping! The plan right now is to send it along as part of
the 7.4 merge window. I haven't pushed out a public linux-next branch
yet, but when I do these patches will be included.

I hope this helps!
Anna

>
> [...]
>
>> 
>> [v6]
>>  - Fixed double unpin bugs pointed out by Sashiko:
>>    https://sashiko.dev/#/patchset/20260810195040.2877784-1-praan%40google.com
>>  - Added R-bs from Christoph (due since v4)
>> 
>> [v5]
>>  - https://lore.kernel.org/all/20260810195040.2877784-1-praan@google.com/
>>  - Fixed an iov_iter_revert oops in nfs_direct_extract_pages().
>>  - Fixed a refcount underflow in nfs_direct_release_pages() during
>>    swap-over-NFS by ensuring we do not call put_page() on unpinned memory.
>>  - Rebased on fs-next
>> 
>
> [...]
>
> Thanks,
> Praan
