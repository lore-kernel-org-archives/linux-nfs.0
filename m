Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.remote-ip=100.103.45.18
ARC-Seal: i=1; d=subspace.kernel.org; s=arc20261015; a=rsa-sha256; cv=none;
	t=1794331382;
	b=FwZbHJ/wbeQ41YzhlXy+SLywCucAF9BavWOHJf5k0qiD8DlIVoF2qgxKnICilnDoNSNv
	 b9oxabfl8zuvTOxENzPbTYVjipabnOmGa/qxw28hpIiz6GGI3H/ioTGDH1UiTHRIJQA/w
	 BFY/gSjsFs4l/WBdU1I8sJ7FZ8kmqt2juTQkAMOOodbL25LU3XeZwx46mJ3Z53afxQWkV
	 l4H72L+8V+2QIllad9K4NEpSNRQzc9Xqw6yLeDA03HL1cypKa/jMiAHR8Wse1U+By8TVC
	 4Qj0qt+R7/e1CP6nRlmUiSJ4ejhJZk3txsu0QUOamfTr9xha5MHefpDA+hPk3zPbHdQ==
ARC-Message-Signature: i=1; d=subspace.kernel.org; s=arc20261015;
	a=rsa-sha256; c=relaxed/relaxed; t=1794331382;
	h=Received:DKIM-Signature:Date:From:To:Cc:Subject:Message-ID:
	 References:MIME-Version:Content-Type:Content-Disposition:In-Reply-To;
	bh=qU/YBwcBTSW09tcoeJ7GijBACLV9An/e2EuN4/Zc9Sg=;
	b=oZ4Q1a2yxr3TMNPMKEC1xXLTAKAbFl+mRh5nu8R+W1hBdhMLkk8fuj/V7dowgeGUqXcR
	 uCk6beiBVf+xO/RaSUrX/lhxQ8OblgJaU37kleVC/xGP/28A5A/WjBpABQjM+LwrEt1tx
	 oKf8f5rDj5riM24b/OVE4upi6OrVfCxdh3P9qVJfPKsaB0pyvVa+Zv0Ci3oDHauYHyFtx
	 elLtZZFPPXFpeh+Cf+fJ+lNpydsAze5Z8+RKbO3QapRkg4mXjdaCzNVproOW27m3RhQhx
	 L5zTpFr/worAwHJ703LIbIg0WRKobiS29HK0Zo9+0el13ZHRW7SIbgDvvBpDIfhR7/Q==
ARC-Authentication-Results: i=1; smtp.subspace.kernel.org; 
	dkim=pass header.d=kernel.org header.i=@kernel.org header.a=rsa-sha256 header.s=k20260515 header.b=MdpJFCRO;
	arc=none smtp.remote-ip=100.103.45.18
Received: from smtp.kernel.org (quasi.space.kernel.org [100.103.45.18])
	(using TLSv1.3 with cipher TLS_AES_256_GCM_SHA384 (256/256 bits)
	 key-exchange X25519 server-signature ECDSA (prime256v1))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 1666A606A31C;
	Tue, 10 Nov 2026 17:23:02 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.a=rsa-sha256 header.s=k20260515 header.b=MdpJFCRO
Received: by smtp.kernel.org (Postfix) with ESMTPSA id 9AC5E1F0089F;
	Tue, 10 Nov 2026 17:23:01 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=kernel.org;
	s=k20260515; t=1794331381;
	bh=qU/YBwcBTSW09tcoeJ7GijBACLV9An/e2EuN4/Zc9Sg=;
	h=Date:From:To:Cc:Subject:References:In-Reply-To;
	b=MdpJFCROGyBYcN7mWJ2h78QRBDr/Fl/ZsKQlWVpd8pwT/yq01ngNExJ8X15QOrwsR
	 sk7rL5FOYp6lPcx+x7fPzofmSxgGVAAFFGCEFCaP56Ah/LP7eSEf3RX1TCMtNt798T
	 mExzsrT7iYw6hTvC27mzgrufj/d1QZhxdsOsBdcR2H15L2qEIivVxUj8ZXVLcRxPdP
	 lJ4Aw4IpoOBm6O9FTWQ/Bfr5ALMiZqvLhRXCXfc1ikWYB5vTiTmmTHV9fmRfW6j6ZH
	 QkD3b+xn5qIF5y56iQP2D++WMSIAkzp6r/hjK81fRf5EEf+2rFl6PzUScHmIke0Jl/
	 4oDe2DIyKoqLA==
Date: Tue, 10 Nov 2026 12:23:00 -0500
From: Mike Snitzer <snitzer@kernel.org>
To: Matthew Wilcox <willy@infradead.org>, Jan Kara <jack@suse.cz>,
	linux-mm@kvack.org, Christian Brauner <brauner@kernel.org>,
	linux-fsdevel@vger.kernel.org
Cc: Chuck Lever <cel@kernel.org>, Jeff Layton <jlayton@kernel.org>,
	linux-nfs@vger.kernel.org, Jens Axboe <axboe@kernel.dk>
Subject: MM/iomap review of this v10 patchset is needed please [was: Re:
 [PATCH v10 7/7] NFSD: drop a shared boundary page only once both WRITEs have
 written it]
Message-ID: <avNS9HrDV8TbDTqH@kernel.org>
References: <20261103211754.35352-1-snitzer@kernel.org>
 <20261103211754.35352-8-snitzer@kernel.org>
 <20261104091543.GA31130@lst.de>
 <autk-osSQ8l2LKz1@kernel.org>
 <20261105075935.GA18069@lst.de>
 <29851456-2e7c-48a7-bf00-11a1f1a35024@app.fastmail.com>
 <au0H_TZCp1Snf_5U@kernel.org>
X-Mailing-List: linux-nfs@vger.kernel.org
List-Id: <linux-nfs.vger.kernel.org>
List-Post: <mailto:linux-nfs@vger.kernel.org>
List-Help: <mailto:linux-nfs+help@vger.kernel.org>
List-Subscribe: <mailto:linux-nfs+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:linux-nfs+unsubscribe@vger.kernel.org>
List-Owner: <mailto:linux-nfs+owner@vger.kernel.org>
Precedence: list
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <au0H_TZCp1Snf_5U@kernel.org>

[Cc: trimmed given To: refocused to required audience]

On Thu, Nov 05, 2026 at 05:49:33PM -0500, Mike Snitzer wrote:
> 
> I suspect MM engineers have just been busy with the merge window.
> Hopefully Willy and/or Jens will give v10 the courtesy of fair review?

I checked with Jens to see if he'd have time to review v10 but he is
unable due to his attention being needed elsewhere.

So Willy, Jan, Christian: can you please coordinate on reviewing this
v10 submission with consideration for 7.5?

Probably worth me restating this note from the cover-letter:
https://lore.kernel.org/linux-nfs/20261103211754.35352-1-snitzer@kernel.org/

"Merging: Chuck suggested taking the series through the mm tree.  1/7 to
6/7 apply cleanly to each of these mm branches:

  mm-unstable  0ea6dc8c4a21 ("fs/proc/task_mmu: fix lost maps entries above 2^63")
  mm-new       74d73ffcffe0 ("riscv: mm: fix concurrency in mark_new_valid_map()")
  mm-stable    6628e7d4c6b2 ("Linux 7.4-rc1")

7/7 needs the NFSD direct-mode changes that are in cel/nfsd-testing.
The whole series applies to cel/nfsd-testing at 693afd3ce9ae ("NFSD:
Defer the PUTFH export security flavor check"), where each patch builds
with W=1 with no warnings.  So 7/7 could follow in the nfsd tree once
the mm part is merged."

(and I have just revalidated that patches 1-6 still apply cleanly to
the latest mm trees listed above, with commits 93d7a816a2df,
488f62a72b8e and fa4ad798f6f6 respectively)

Thanks,
Mike
