Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.remote-ip=100.103.45.18
ARC-Seal: i=1; d=subspace.kernel.org; s=arc20261015; a=rsa-sha256; cv=none;
	t=1794931322;
	b=IuLb8O8CQiQ2nhcgG7s8ZkHDwMejNvcjeZcveWSLOfO4f7GxLYNIISbU6h7U7tpgpMr3
	 Li4nVZiGYkgu5dQsU+ia89QtkPHRkA60GcFIFuSLhGgaZ77rH61y87OEZhY4HkxcCF63L
	 VTsdQgrFZ9dz5sW1LRCjWKavoOHitPYvYPUSeL3OWnC0ZmxDqJTp5HPhKFIcNdJF/gn2o
	 NCzsX7AxOZWnM70v2HpNC90EhiFe1mUUdvlbrdz2u2hIVFm2dUb9cvoDYTMyHIAMhMV/f
	 oRYXSNrBkYiHdm/z3It5z1g8TEwIDV+xOBAH59r1F2Y/vXvjb222HcHNM+1y2IfGp2A==
ARC-Message-Signature: i=1; d=subspace.kernel.org; s=arc20261015;
	a=rsa-sha256; c=relaxed/relaxed; t=1794931322;
	h=Received:DKIM-Signature:Received:Received:X-ME-Sender:
	 X-ME-Proxy-Cause:X-ME-Proxy:Feedback-ID:Received:X-Mailer:
	 MIME-Version:X-ThreadId:Date:From:To:Cc:Message-Id:In-Reply-To:
	 References:Subject:Content-Type:Content-Transfer-Encoding;
	bh=8dQuOIle4rsGjSRLWax9iSEZECutg15QwtM4OXLgIbw=;
	b=aoXiCgWhOIv0UoMH5qxuAxtUT+i7rOUhVrDtrXB/8ZHfAyjpLX9WXLHl0vZlvFPe0m7I
	 KdAUx2FdMCwzUMwF7wTB/9L1ELRQPIeLkJXIdpylNvUn/1+PbpTS2MAkfSCVFf0yDgkVm
	 iKjuT/aJWq0H3TUl3WOjS+/MQ2055iPpHKBdZ6ZIOq6pQPyotl0oZhhLRObLaPkn4Hl8n
	 2Xk70kUZvO9Zf/KqDtwcy59/7MQpr5LS6Y66yBIUuHd3L9eyDueR9dwJcpJl/yZBP66XY
	 3hq9PtyL/Lo7HbBOI9n1O/4iunWQBtRL6chOi6Ilp0lGCC9E59PTy2XtJGYIa48wcaw==
ARC-Authentication-Results: i=1; smtp.subspace.kernel.org; 
	dkim=pass header.d=kernel.org header.i=@kernel.org header.a=rsa-sha256 header.s=k20260515 header.b=nLCPMGhw;
	arc=none smtp.remote-ip=100.103.45.18
Received: from smtp.kernel.org (quasi.space.kernel.org [100.103.45.18])
	(using TLSv1.3 with cipher TLS_AES_256_GCM_SHA384 (256/256 bits)
	 key-exchange X25519 server-signature ECDSA (prime256v1))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 49401606A31C
	for <linux-nfs@vger.kernel.org>; Tue, 17 Nov 2026 16:02:02 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.a=rsa-sha256 header.s=k20260515 header.b=nLCPMGhw
Received: by smtp.kernel.org (Postfix) with ESMTPSA id E5BEB1F000C5;
	Tue, 17 Nov 2026 16:02:01 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=kernel.org;
	s=k20260515; t=1794931322;
	bh=8dQuOIle4rsGjSRLWax9iSEZECutg15QwtM4OXLgIbw=;
	h=Date:From:To:Cc:In-Reply-To:References:Subject;
	b=nLCPMGhw4fadybR/aNPq0uRtWFJIF+2f4hg35BUYSO5ED+50fDHVgwCePe+NKLB87
	 9JFkZ/1w5CVFqs8ymOICBUzhnojupPahPolSZy8L6iqWsvP2yMwa+eFucdbipPA4WH
	 sOdhXBeZWgRxWx/M0EI59A9CvB0m5bPoz6iFTzWu/wJLts6pXCx3zlYiUD4doM93bB
	 kmUTo5Cdict4WVoPT1WjWlTN0oGvfob7XUN/DOagLiU/e6nD1kLEvywZ3mLQUjhwVy
	 qQnN8yQ91Dv4nIK7VwW0yu4SuotCRNQZJpxmp27RgYNqh8rwX4C37LXfSSInrVSZev
	 bn2FS7LCKGEng==
Received: from phl-compute-02.internal (phl-compute-02.internal [10.202.2.42])
	by mailfauth.phl.internal (Postfix) with ESMTP id 37583F40066;
	Tue, 17 Nov 2026 11:02:01 -0500 (EST)
Received: from phl-imap-04 ([10.202.2.82])
  by phl-compute-02.internal (MEProxy); Tue, 17 Nov 2026 11:02:01 -0500
X-ME-Sender: <xms:eXr8atZqNrc5ZENbfDtDVS1YaMSIP-bSqdHRYoXj7uaTZtJjist3NQ>
    <xme:eXr8avOU_tJ9nCoj-iQ5tvGSMPSjw6iJPbx3x8LlV2V_hZ07y_MSAnUl3Wsxb8s3m
    0tAejubR-bDHza1HN6Wt19bTumEKJjA9SFRmI7Zr6Gnblio8J9D4iG->
X-ME-Proxy-Cause: dmFkZTGiqzDOQ4dYAUkzGh3gKKpsl7uvXYrYucKxOINwEAUs4vSs0sxA70lhaNViQ4Vsl0
    X9Gmeo6gVKsTba2z6SHEk79IGmqNG9b2+inZhGr7ihH0RaVMEjDp3959Q6PCv+7B0VCEgv
    010WJDqcPk4l0r8O2GTUUx6P5NmSL2FhP0RP1ZPecG/yBlMRPRz35DVZ3vGxbb1nXq6hVY
    ussXHXszXhI807tg03HKKoesX4I58/BX/b+okydbAvrvbdSuegHLRSouGEd2WO2+xfQwvm
    Rna3aE6wlNBz23F4xomDwokreTT3klSllzKnyjcWk9ojHBzZ20+1qNQasICQPck5cgTEpX
    cFmHExreciHEDiWfVLGAvVkXn/aASYwsWGWdkjH7qOdNfJy4RbaWVBjmt0uBs35MbHMNV+
    3Isjvdp7pUyMW5qRCtlNSrdWhpzsCX3DcSgyf73rIajqd1kOwcX7ZQpMYgf7dYWUaP1lkp
    6xTXFugKyq9wiq2HyFN5LgH6L3RHNzb8Yh2DkF+TCuch8oEfR2BF5Ebi6nC6v5EnWnqUlD
    YejYLPyTUZZ8zFZTuZuT8xupfRtu+Yw93+akDbxyIMa3yGD6vdNJYYzWKo6orvqMVPyaRF
    2OlZI4LKzwrxuKUGYcCFLhcQ2JkjzUiQr/47VmtxHp+q+d4pSkR83UwikXkw
X-ME-Proxy: <xmx:eXr8ahcFF9OWY3O3v5WnHycFwYOGQOZID6GRy7YwKLXhBEffvzKWSA>
    <xmx:eXr8agv_NLhB3BPxdEFmx9yQXL0DFXI33XFHcfcXQGIyfztEE_sm7A>
    <xmx:eXr8aqk27uidUXeZb11PDnocazPusbMIgf9nY5zes10vu9xfR6QCuw>
    <xmx:eXr8aqx1USgdN2tYyJ9DeRIlpJihkPyq3-KOmYpjSIWt1NF7IR0K2w>
    <xmx:eXr8akPqMFPy2VqyMM22tsZrtXd_4FK81ctW4ifEAUxA0F8hyj6kjRft>
Feedback-ID: i20964851:Fastmail
Received: by mailuser.phl.internal (Postfix, from userid 501)
	id 0991EB6006E; Tue, 17 Nov 2026 11:02:01 -0500 (EST)
X-Mailer: MessagingEngine.com Webmail Interface
X-Mailing-List: linux-nfs@vger.kernel.org
List-Id: <linux-nfs.vger.kernel.org>
List-Post: <mailto:linux-nfs@vger.kernel.org>
List-Help: <mailto:linux-nfs+help@vger.kernel.org>
List-Subscribe: <mailto:linux-nfs+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:linux-nfs+unsubscribe@vger.kernel.org>
List-Owner: <mailto:linux-nfs+owner@vger.kernel.org>
Precedence: list
MIME-Version: 1.0
X-ThreadId: A1ErcsuEOLNc
Date: Tue, 17 Nov 2026 11:01:40 -0500
From: "Anna Schumaker" <anna@kernel.org>
To: NeilBrown <neil@brown.name>, "Trond Myklebust" <trondmy@kernel.org>
Cc: "Jeff Layton" <jlayton@kernel.org>,
 "Jonathan Flynn" <jonathan.flynn@hammerspace.com>, linux-nfs@vger.kernel.org
Message-Id: <759d7deb-f380-4094-bb6b-35a4db945d56@app.fastmail.com>
In-Reply-To: <179488445814.1728055.9049767251296971441@noble.neil.brown.name>
References: <20261109005504.1804605-1-neilb@ownmail.net>
 <179488445814.1728055.9049767251296971441@noble.neil.brown.name>
Subject: Re: [PATCH v5 0/8] nfs: prepare for locking changes.
Content-Type: text/plain
Content-Transfer-Encoding: 7bit

Hi Neil,

On Mon, Nov 16, 2026, at 10:00 PM, NeilBrown wrote:
> Hi Anna/Trond,
> is there any chance this series might land for the next merge window?

That's what I was expecting. The patches looked okay to me!

Anna

>
> Thanks,
> NeilBrown
>
>
> On Mon, 09 Nov 2026, NeilBrown wrote:
>> In this v5 I've dropped "nfs: fix nfs_call_unlink()" because it enabled code that was
>> buggy.  I have ideas how to fix this properly but it belongs in a separate series.
>> 
>> I've also revised the barriers in "nfs: fix open-blocking with d_fsdata", thanks
>> in part to Jonathan's input.
>> 
>> I think the rest is unchanged.
>> 
>> Thanks,
>> NeilBrown
>> 
>>  [PATCH v5 1/8] nfs: fix open-blocking with d_fsdata
>>  [PATCH v5 2/8] nfs: remove d_drop()/d_alloc_parallel() from
>>  [PATCH v5 3/8] nfs: use d_splice_alias() in nfs_link()
>>  [PATCH v5 4/8] nfs: don't d_drop() before d_splice_alias()
>>  [PATCH v5 5/8] nfs: don't d_drop() before d_splice_alias() in
>>  [PATCH v5 6/8] nfs: Use d_alloc_trylock() in nfs_prime_dcache()
>>  [PATCH v5 7/8] nfs: use d_alloc_trylock() in silly-rename
>>  [PATCH v5 8/8] nfs: use d_duplicate()
>> 
>>
