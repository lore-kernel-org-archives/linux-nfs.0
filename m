Received: from smtp.kernel.org (aws-us-west-2-korg-mail-1.web.codeaurora.org [10.30.226.201])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 71E3D3603EB
	for <linux-nfs@vger.kernel.org>; Fri, 13 Mar 2026 17:49:04 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=10.30.226.201
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1773424144; cv=none; b=f+U1SjEIuMhBOIluXU78MevPQ7ZiYrm8MXGcJCYvXuNKK0KRI8cGtXStfC/EdK64hFX+K1Vn+kMzpdy58ikSb56okgFlbE9mm0UOSpJ8RHc3B7kRR1O32LWgzfwHW21bMBwcV2SJbe1s7RCeHQqHJVQuxiE9DzZu+AshyYkwcK4=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1773424144; c=relaxed/simple;
	bh=zDwADjWpnjyA5zdBzz3UyfYVzDnPB7Z8QI+gZLhCmmI=;
	h=MIME-Version:Date:From:To:Cc:Message-Id:In-Reply-To:References:
	 Subject:Content-Type; b=gQC5+JWIJBu7vXovVvKtP3mdF39EshzR46ou2PbpBOpd3Fgc45eLDwDDf9eS/ZnL3ZlQfVUGcazUdWWHfLbr9WZTpPs0ieEppa+eodbVCVetJ/fmS1B0itnMV7BP1ayGA8stJ4xfNYTPOpqqO0gCuJLe/XeUMUUePyV7iihGIjs=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.b=lf/HJn/Y; arc=none smtp.client-ip=10.30.226.201
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.b="lf/HJn/Y"
Received: by smtp.kernel.org (Postfix) with ESMTPSA id D3FAEC19424;
	Fri, 13 Mar 2026 17:49:03 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/simple; d=kernel.org;
	s=k20201202; t=1773424144;
	bh=zDwADjWpnjyA5zdBzz3UyfYVzDnPB7Z8QI+gZLhCmmI=;
	h=Date:From:To:Cc:In-Reply-To:References:Subject:From;
	b=lf/HJn/YsjpBwax6T8GW9qY0sOJM0WSDL8K3rBLMcAo3SfJLyZLu4WWw+pEjzM0Ww
	 jdBwKEN+Pag/HXJlYA7jfdsvhilEpncugyznmWhENuPyYpPIjVuVNMLjH5aIgcPnt8
	 TmBCHiJmLLvTHerDVMqHdGXRsuGVeoAbdbfV1wj0SxTDtURKVHNwkh9aBpevYJOlhA
	 tk+67fmTGEE8oe0E44nJEbklYu4Alea6SBUSYXSwI4/oUtEBbliqWKN5OoA3hZdPZA
	 maw2hQnjxaic4qGrWFkBceCW7xCyxmmi220Pb+WmZIvRKx1Fa8/IN8iIRc1HOizNVL
	 nyA7JuewrTFSA==
Received: from phl-compute-02.internal (phl-compute-02.internal [10.202.2.42])
	by mailfauth.phl.internal (Postfix) with ESMTP id 05A3FF40068;
	Fri, 13 Mar 2026 13:49:03 -0400 (EDT)
Received: from phl-imap-04 ([10.202.2.82])
  by phl-compute-02.internal (MEProxy); Fri, 13 Mar 2026 13:49:03 -0400
X-ME-Sender: <xms:Dk60aZqRRusSHWyxen_Rud4wOmSEClGPkD08ELRLHdZUXojRYXTXzw>
    <xme:Dk60aWcuYzXFm8xND4cm1nfgbx_rUf9dxBmbB3e1tD6vrix9IoBLEFjCUPUYHQRyI
    f078clRnn0oA6mQBt_oWIkw3jhyPJc2pkn-DSdCPVjqC5pqMul4YyA>
X-ME-Proxy-Cause: gggruggvucftvghtrhhoucdtuddrgeefgedrtddtgddvledtfedtucetufdoteggodetrf
    dotffvucfrrhhofhhilhgvmecuhfgrshhtofgrihhlpdfurfetoffkrfgpnffqhgenuceu
    rghilhhouhhtmecufedttdenucesvcftvggtihhpihgvnhhtshculddquddttddmnecujf
    gurhepofggfffhvfevkfgjfhfutgfgsehtqhertdertdejnecuhfhrohhmpedftehnnhgr
    ucfutghhuhhmrghkvghrfdcuoegrnhhnrgeskhgvrhhnvghlrdhorhhgqeenucggtffrrg
    htthgvrhhnpeduueevgeffledvledvieffheevvddvteeffeegfefhvddtueffgfetvefh
    veetleenucevlhhushhtvghrufhiiigvpedtnecurfgrrhgrmhepmhgrihhlfhhrohhmpe
    grnhhnrgdomhgvshhmthhprghuthhhphgvrhhsohhnrghlihhthidqudeijeejuddvtdej
    ledqfeefvddvfeegjeduqdgrnhhnrgeppehkvghrnhgvlhdrohhrghesnhhofihhvgihtg
    hrvggrmhgvrhihrdgtohhmpdhnsggprhgtphhtthhopeehpdhmohguvgepshhmthhpohhu
    thdprhgtphhtthhopehjlhgrhihtohhnsehkvghrnhgvlhdrohhrghdprhgtphhtthhope
    htrhhonhgumhihsehkvghrnhgvlhdrohhrghdprhgtphhtthhopegrghhlohesuhhmihgt
    hhdrvgguuhdprhgtphhtthhopehlihhnuhigqdhkvghrnhgvlhesvhhgvghrrdhkvghrnh
    gvlhdrohhrghdprhgtphhtthhopehlihhnuhigqdhnfhhssehvghgvrhdrkhgvrhhnvghl
    rdhorhhg
X-ME-Proxy: <xmx:Dk60aa1Xm-1ZH1nKoqXXQ9CWnJ_sxUSpiFyv7Ubn4vB3QN-dmpYc-Q>
    <xmx:Dk60aWAcYpkLgnnwj40KdUMrAcuN8zlWph3KUd9-rK9rwr90tK2qYw>
    <xmx:Dk60aeec_TKUoukr06PbV3PmH1xwSYwlGXS4RtDoUwsEBTIQo8ZLrg>
    <xmx:Dk60ab6ZWH_-QJxnujMjz7GPtViCLCB7UGL76aiTbSIDpiNKV5RU2w>
    <xmx:D060aZWExZpxjeSNMkzFlr1ELD_LQcojv2_TvpxO8UufBHx9G9kGjGrK>
Feedback-ID: i20964851:Fastmail
Received: by mailuser.phl.internal (Postfix, from userid 501)
	id DBB8BB6006E; Fri, 13 Mar 2026 13:49:02 -0400 (EDT)
X-Mailer: MessagingEngine.com Webmail Interface
Precedence: bulk
X-Mailing-List: linux-nfs@vger.kernel.org
List-Id: <linux-nfs.vger.kernel.org>
List-Subscribe: <mailto:linux-nfs+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:linux-nfs+unsubscribe@vger.kernel.org>
MIME-Version: 1.0
X-ThreadId: AzcN01bUS9zc
Date: Fri, 13 Mar 2026 13:48:42 -0400
From: "Anna Schumaker" <anna@kernel.org>
To: "Olga Kornievskaia" <aglo@umich.edu>, "Jeff Layton" <jlayton@kernel.org>
Cc: "Trond Myklebust" <trondmy@kernel.org>, linux-nfs@vger.kernel.org,
 linux-kernel@vger.kernel.org
Message-Id: <42c59ab6-9de3-4062-b8be-651f7f21400a@app.fastmail.com>
In-Reply-To: 
 <CAN-5tyHJhwJU=71gxiKJYFnJFGA5xWUg0CQpbJ9=YgqMVi72RQ@mail.gmail.com>
References: <20260305-nfs-7-1-v1-0-e2200f69e543@kernel.org>
 <CAN-5tyHJhwJU=71gxiKJYFnJFGA5xWUg0CQpbJ9=YgqMVi72RQ@mail.gmail.com>
Subject: Re: [PATCH 0/2] nfs: delegated attribute fixes
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: quoted-printable

Hi Olga,

On Fri, Mar 13, 2026, at 11:58 AM, Olga Kornievskaia wrote:
> I can confirm that generic/221 and generic/728 no longer fail with
> this patch series applied.

Thanks for checking that. Can we add your "Tested-by" to the commits?

Anna

>
> On Thu, Mar 5, 2026 at 1:53=E2=80=AFPM Jeff Layton <jlayton@kernel.org=
> wrote:
>>
>> This patchset fixes a couple of test failures in xfstests when delega=
ted
>> timestamps are enabled. Please consider for v7.1!
>>
>> Signed-off-by: Jeff Layton <jlayton@kernel.org>
>> ---
>> Jeff Layton (2):
>>       nfs: fix utimensat() for atime with delegated timestamps
>>       nfs: update inode ctime after removexattr operation
>>
>>  fs/nfs/inode.c          |  9 +--------
>>  fs/nfs/nfs42proc.c      | 18 ++++++++++++++++--
>>  fs/nfs/nfs42xdr.c       | 10 ++++++++--
>>  include/linux/nfs_xdr.h |  3 +++
>>  4 files changed, 28 insertions(+), 12 deletions(-)
>> ---
>> base-commit: c107785c7e8dbabd1c18301a1c362544b5786282
>> change-id: 20260305-nfs-7-1-9f71bcde58c5
>>
>> Best regards,
>> --
>> Jeff Layton <jlayton@kernel.org>
>>
