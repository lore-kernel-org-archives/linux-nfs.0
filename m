Received: from smtp.kernel.org (aws-us-west-2-korg-mail-alma10-1.taild15c8.ts.net [100.103.45.18])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 66B903AEF30
	for <linux-nfs@vger.kernel.org>; Tue,  9 Jun 2026 18:55:01 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=100.103.45.18
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1781031302; cv=none; b=RBSUh/oE5NZFT2xGVV32QDmbOmculVoy8iaRtxjILQw/WKjT720edGdSfv3OzC+0qYYShsxlbs87JUqn0cLDFqEa5Dmk3HVNBbr0Qy3FMrtfQiM/hV5hH/7FtUBKzOHVxCxwVEXj+hS9dut0eVdzQkXAuaVkFC6rJfCLn/+d2G4=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1781031302; c=relaxed/simple;
	bh=A/eIXOo/JATBHzFdXaOYpHGmRhy/QM6ZfMygpy0hYyo=;
	h=MIME-Version:Date:From:To:Cc:Message-Id:In-Reply-To:References:
	 Subject:Content-Type; b=Lf8BayPO5r0y13Ym73RCZPaABuzit8PriaPjgcYPXtsnrOGJGoO0xJ1wrTZWajVz/DDHGo8Ku7Hb1r67ng9TpGP49FUUMAscQaBe5nLQdxOnhWDp9cgSVtM0fdR00NK6Rx4T48QaFdumnq3N4lKum6aiEZx+R+UpGioN+2wd2R4=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.b=Mw2I8XJL; arc=none smtp.client-ip=100.103.45.18
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.b="Mw2I8XJL"
Received: by smtp.kernel.org (Postfix) with ESMTPSA id C86EE1F00898;
	Tue,  9 Jun 2026 18:55:00 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=kernel.org;
	s=k20260515; t=1781031301;
	bh=RGayj3EPEyW5089OIaXcYNbn/0ET4KOcMbJw2winxU0=;
	h=Date:From:To:Cc:In-Reply-To:References:Subject;
	b=Mw2I8XJLMt2onLJe9nWC2GZhxhWi8zfGMtl/B0tCFAwHc705jalIDWvJU/v4sAeaC
	 kxdP4DgHzpcl0llmNnv+Ofwby+0cygSYvF0BlQjO8vEPayiS/WE0myCz+Y/HOrw1ec
	 I4H1Zil81EtnKd94JfiVwZx5vfMCchwRW6wr5jLox1j1TjvpTx/1ogZWRSK2Op06qI
	 1DIWbaruxGC9CsuVLlVeQ2h/mf5x12zve65YxS5N4SXq0WzR1R4l1uUsyDIjZrxIn+
	 x0BNUyDaT29AXBwGAh2VD2qAHM8xT+1k25sk6MZgxkiutKvkjEfOOF2bv6JOVPRD92
	 E7JF4FHMNWmDw==
Received: from phl-compute-02.internal (phl-compute-02.internal [10.202.2.42])
	by mailfauth.phl.internal (Postfix) with ESMTP id 17581F40068;
	Tue,  9 Jun 2026 14:55:00 -0400 (EDT)
Received: from phl-imap-04 ([10.202.2.82])
  by phl-compute-02.internal (MEProxy); Tue, 09 Jun 2026 14:55:00 -0400
X-ME-Sender: <xms:g2EoauWHEsvJgMR53JJQL8E-zjzLaj8Wedkh_UNkZPlnxsIs7F23VA>
    <xme:g2EoalZuptXfIi9w0pyrQ6IaCAtkAa1lRT1SeGTn4axm9A29PDwgpk0ZrotrUCKdd
    WQa06Z5Ont5_7OBApbuNotCfeirCKkTcICqJuUXBYf4run4Z-n5Zzs>
X-ME-Proxy-Cause: dmFkZTG0vcQMtM9rJJwi56/yDuZoleG0rCH5L0wD0NAvop4Ds8OPEkw/dtuRssna4SatzE
    Vk6t4qctsS1+BvVh6cek0JFGEQGjzEM/HA0dk3aDmkB0CACh6OyTEOtjDHia6IqYnVbwBU
    DVpZ0ivAzPum8UQ/yI1kJskLlqaYM+MyXsHht6dR4CRCxZGtrwxXNAAi1YioNRu2GJHtni
    6EnI3oO0dd4sdsa94iXFbj+KL1LB/mHnz2kr83KjM8D26DcJa2MlL1ZzSaire5RamJY5wA
    x9TvBkWxVBwfjOTrazISaBCNx6OoSoqqLRoEEWoJUZwYbhGbwAzUO3R+HIAsN+dDaAuUf3
    W+ttynM+ugX8QyH49acjcvc/m3XBU0GRQhGW9H+GeHD2oG+Vh60sJKQIb9wc456OKEwlU9
    dMRpiLfMqyRmzSkH52EGi/+n8ITwuX7wFWrSFR5hVIivbdHHQatRl1BSk1itNV/ti8XjaP
    2+0Fhfbdc6KZb0yfQ1Kha4N0vTuOrsQ2U4fDlHa/85oCOaaxqLMAC+ikYPlaak7k5riAIa
    uLwiEUDYzLvz+pi51dE5RQHpRoYNsKv2UNW6wKkWZSl/D6DlG0VACfJn5KlHYjvEdFnOZ1
    qoIPEYcK+v0+cBkwHg2cl8IWHgSoPGw2PBGPDDcGsqePOKOUIBXKvl+PpMng
X-ME-Proxy: <xmx:hGEoautAe-1TtFilFXc_vLs2m1RiNuU60EcZo9jl7kZWvP24yYgTQA>
    <xmx:hGEoaj16gEbyRQh28CSQXEZuJ0g3lxlHuDuHsuY4rJ8kcatI2Z2ogQ>
    <xmx:hGEoaq7nfIf7DoaqmIkfiE7WeR3Zz1csm7Ax8CSIXYZXArcs2BtkhQ>
    <xmx:hGEoalOqjv5sQt0rPsSIxkWS9UFQemXGDpDmBNQSaGjAwPc6i55yqA>
    <xmx:hGEoauEbeClV5qUrjQmCXCqo93tKLgDZRg1IPGt6Zem3K4Lfh8bGBMPS>
Feedback-ID: i20964851:Fastmail
Received: by mailuser.phl.internal (Postfix, from userid 501)
	id CE5EDB6006E; Tue,  9 Jun 2026 14:54:59 -0400 (EDT)
X-Mailer: MessagingEngine.com Webmail Interface
Precedence: bulk
X-Mailing-List: linux-nfs@vger.kernel.org
List-Id: <linux-nfs.vger.kernel.org>
List-Subscribe: <mailto:linux-nfs+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:linux-nfs+unsubscribe@vger.kernel.org>
MIME-Version: 1.0
X-ThreadId: A8villCpd8mN
Date: Tue, 09 Jun 2026 14:54:39 -0400
From: "Anna Schumaker" <anna@kernel.org>
To: "Marco Crivellari" <marco.crivellari@suse.com>,
 linux-kernel@vger.kernel.org, linux-nfs@vger.kernel.org,
 netdev@vger.kernel.org
Cc: "Tejun Heo" <tj@kernel.org>, "Lai Jiangshan" <jiangshanlai@gmail.com>,
 "Frederic Weisbecker" <frederic@kernel.org>,
 "Sebastian Andrzej Siewior" <bigeasy@linutronix.de>,
 "Michal Hocko" <mhocko@suse.com>, "Trond Myklebust" <trondmy@kernel.org>,
 "Chuck Lever" <chuck.lever@oracle.com>, "Jeff Layton" <jlayton@kernel.org>,
 NeilBrown <neil@brown.name>, "Olga Kornievskaia" <okorniev@redhat.com>,
 "Dai Ngo" <Dai.Ngo@oracle.com>, "Tom Talpey" <tom@talpey.com>,
 "David S. Miller" <davem@davemloft.net>,
 "Eric Dumazet" <edumazet@google.com>, "Jakub Kicinski" <kuba@kernel.org>,
 "Paolo Abeni" <pabeni@redhat.com>, "Simon Horman" <horms@kernel.org>
Message-Id: <d9242324-720c-448f-9723-e11f0158f4b1@app.fastmail.com>
In-Reply-To: 
 <CAAofZF5_MRtySWTMs-J3T676FwjJiLDpYLRWmsFaSXePo3nZPg@mail.gmail.com>
References: <20260507130117.252825-1-marco.crivellari@suse.com>
 <CAAofZF5_MRtySWTMs-J3T676FwjJiLDpYLRWmsFaSXePo3nZPg@mail.gmail.com>
Subject: Re: [PATCH v2] xprtrdma: Move long delayed work on system_dfl_long_wq
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: quoted-printable

Hi Marco,

On Fri, Jun 5, 2026, at 4:12 AM, Marco Crivellari wrote:
> Hi,
>
> On Thu, May 7, 2026 at 3:01=E2=80=AFPM Marco Crivellari
> <marco.crivellari@suse.com> wrote:
>> [...]
>>  net/sunrpc/xprtrdma/transport.c | 3 ++-
>>  1 file changed, 2 insertions(+), 1 deletion(-)
>
> Gentle ping.

Thanks for the ping! I've had the patch in my
testing branch for a bit, and just pushed it
out to my linux-next for the next merge.

Anna

>
> Thanks!
>
> --=20
>
> Marco Crivellari
>
> SUSE Labs
