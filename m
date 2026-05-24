Received: from smtp.kernel.org (aws-us-west-2-korg-mail-alma10-1.taild15c8.ts.net [100.103.45.18])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 6F6262C08AC
	for <linux-nfs@vger.kernel.org>; Sun, 24 May 2026 17:45:19 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=100.103.45.18
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1779644720; cv=none; b=GsOzEOVk/02xHULkHUZ68oC1m8VRlD/PQWnTutI2f5tkjOKqOOQJn1+ovTBFC68MfkE6G58vzWFIXev+xrr6XSzfFfwyMYAihwJdfQGK0c++cTc6uUe54nqi/rhlorpZEjb2rWIqYH3s1wXo7AD9xTgbCx1DIQF5aazNq9GNyig=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1779644720; c=relaxed/simple;
	bh=GK1nD3ajcY2pPggLmMRttJYSQZrKVjfNRrsOW4guF3E=;
	h=MIME-Version:Date:From:To:Cc:Message-Id:In-Reply-To:References:
	 Subject:Content-Type; b=UYyFoZcRosHELyba58Qlp0EorebTRYjJXuMCJhljoGoTXfDcA0AIHMuud5lE/i+LpX5k+D9dHe2SYvpMG+0lhxq3usQ0cYsTRD5kvvXtDS+F9ViJrhUoMb+y4VrTSkT5jA75kzYdHKJNpMpbF9A7CYVzqDaCuYKzH7MjHyJs/TU=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.b=ABWIYGlu; arc=none smtp.client-ip=100.103.45.18
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.b="ABWIYGlu"
Received: by smtp.kernel.org (Postfix) with ESMTPSA id BAE531F000E9;
	Sun, 24 May 2026 17:45:18 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=kernel.org;
	s=k20260515; t=1779644719;
	bh=8Csb39+q5PVvsjPEw/Rh4ECCPvM0CI5p6rMb8tuDyjw=;
	h=Date:From:To:Cc:In-Reply-To:References:Subject;
	b=ABWIYGluxpLwZWOlqtE+nUc3k1DPPMXEN5AkzVKjht02XTsIt+3pwAkmIK0KqhsFr
	 5EB5LZaip3/jzoDe5z0qClaRTQSQLoTDyt+0y47gADaXEo5Wp/Ht4xid4Sm3gWu/AJ
	 5iuiXE8H0puJWFOm8L9PqjzFDaN+6pfhP134Em04r13kj9cWd14p3TOetasaIJvm/X
	 UH03p3SntdYCGPTfM7R60GM4qw3uequANno5Hf2AUk2GuzkV1V6J0kZgaZPkNe8e1G
	 QBM47Xx17wrRnNUKEoBQNYhnyU+HS/9QlhSSXKspzX2gHJzqCUpdnNwBulpx0B30zd
	 id2Pi037Y9wvg==
Received: from phl-compute-10.internal (phl-compute-10.internal [10.202.2.50])
	by mailfauth.phl.internal (Postfix) with ESMTP id DAE64F40072;
	Sun, 24 May 2026 13:45:17 -0400 (EDT)
Received: from phl-imap-15 ([10.202.2.104])
  by phl-compute-10.internal (MEProxy); Sun, 24 May 2026 13:45:17 -0400
X-ME-Sender: <xms:LTkTakY8WQ7LZ-hKEzcYfrIrX6nWSSMxpV_aqFnwLT6aacMesv8-qw>
    <xme:LTkTaqNhPGhkWdj_Hl_f0DQON6q-Uxe9PrJZ81zRS5jkDut3OmZNKaViJ9SYc9jWH
    Ym93NTO3Sb7M7-2cJvRBqdLDleEP87iXb_iE8XkGNgKX_PIyWW19tDc>
X-ME-Proxy-Cause: gggruggvucftvghtrhhoucdtuddrgeefhedrtddtgdduheeiheeiucetufdoteggodetrf
    dotffvucfrrhhofhhilhgvmecuhfgrshhtofgrihhlpdfurfetoffkrfgpnffqhgenuceu
    rghilhhouhhtmecufedttdenucesvcftvggtihhpihgvnhhtshculddquddttddmnecujf
    gurhepofggfffhvfevkfgjfhfutgfgsehtjeertdertddtnecuhfhrohhmpedfvehhuhgt
    khcunfgvvhgvrhdfuceotggvlheskhgvrhhnvghlrdhorhhgqeenucggtffrrghtthgvrh
    hnpefhffekffeftdfgheeiveekudeuhfdvjedvfedvueduvdegleekgeetgfduhfefleen
    ucevlhhushhtvghrufhiiigvpedtnecurfgrrhgrmhepmhgrihhlfhhrohhmpegthhhutg
    hklhgvvhgvrhdomhgvshhmthhprghuthhhphgvrhhsohhnrghlihhthidqudeifeegleel
    leehledqfedvleekgeegvdefqdgtvghlpeepkhgvrhhnvghlrdhorhhgsehfrghsthhmrg
    hilhdrtghomhdpnhgspghrtghpthhtohepkedpmhhouggvpehsmhhtphhouhhtpdhrtghp
    thhtohepnhgvihhlsegsrhhofihnrdhnrghmvgdprhgtphhtthhopehjlhgrhihtohhnse
    hkvghrnhgvlhdrohhrghdprhgtphhtthhopegurghirdhnghhosehorhgrtghlvgdrtgho
    mhdprhgtphhtthhopegthhhutghkrdhlvghvvghrsehorhgrtghlvgdrtghomhdprhgtph
    htthhopehokhhorhhnihgvvhesrhgvughhrghtrdgtohhmpdhrtghpthhtohepthhomhes
    thgrlhhpvgihrdgtohhmpdhrtghpthhtoheplhhinhhugidqkhgvrhhnvghlsehvghgvrh
    drkhgvrhhnvghlrdhorhhgpdhrtghpthhtoheplhhinhhugidqnhhfshesvhhgvghrrdhk
    vghrnhgvlhdrohhrgh
X-ME-Proxy: <xmx:LTkTamYui3tgdJJUNY30fI9IX_P0WI1Sj-67SW7EIlV1VeacE6w5GQ>
    <xmx:LTkTalZjssBgyvLok1IcLlddb6sHXeEM-KsY2BcunlStzL6Vf9pB1g>
    <xmx:LTkTajLgPvvJ7afolITxy9If1sXGeealXwTSZwLD_y1EF7Nf3hOWTw>
    <xmx:LTkTaptB_rMoVaovb7IGhrhCfBg0d_okfTNppjcEIvr5EpNOgxV-EA>
    <xmx:LTkTavUFNX42syWf1DB3HrYgKlVE2oLI5QKCan9afJO5LeA_FEDw8VTu>
Feedback-ID: ifa6e4810:Fastmail
Received: by mailuser.phl.internal (Postfix, from userid 501)
	id 3B777780070; Sun, 24 May 2026 13:45:17 -0400 (EDT)
X-Mailer: MessagingEngine.com Webmail Interface
Precedence: bulk
X-Mailing-List: linux-nfs@vger.kernel.org
List-Id: <linux-nfs.vger.kernel.org>
List-Subscribe: <mailto:linux-nfs+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:linux-nfs+unsubscribe@vger.kernel.org>
MIME-Version: 1.0
X-ThreadId: AiOgYnK8JZko
Date: Sun, 24 May 2026 13:44:57 -0400
From: "Chuck Lever" <cel@kernel.org>
To: "Jeff Layton" <jlayton@kernel.org>,
 "Chuck Lever" <chuck.lever@oracle.com>, NeilBrown <neil@brown.name>,
 "Olga Kornievskaia" <okorniev@redhat.com>, "Dai Ngo" <Dai.Ngo@oracle.com>,
 "Tom Talpey" <tom@talpey.com>
Cc: linux-nfs@vger.kernel.org, linux-kernel@vger.kernel.org
Message-Id: <815a405e-b1da-4887-ba10-c0b435131325@app.fastmail.com>
In-Reply-To: <1d7dda4d0181f60362ca27c3404dc55710bca775.camel@kernel.org>
References: <20260523-dir-deleg-fixes-v1-0-142c884f85ce@kernel.org>
 <20260523-dir-deleg-fixes-v1-4-142c884f85ce@kernel.org>
 <1d7dda4d0181f60362ca27c3404dc55710bca775.camel@kernel.org>
Subject: Re: [PATCH 4/4] nfsd: fix ino_t format specifier in nfsd_handle_dir_event
 tracepoint
Content-Type: text/plain
Content-Transfer-Encoding: 7bit


On Sun, May 24, 2026, at 8:09 AM, Jeff Layton wrote:
> On Sat, 2026-05-23 at 12:17 -0400, Jeff Layton wrote:
>> inode->i_ino is now a u64. Use the same size for the tracepoint.
>> 
>> Signed-off-by: Jeff Layton <jlayton@kernel.org>
>> ---
>>  fs/nfsd/trace.h | 4 ++--
>>  1 file changed, 2 insertions(+), 2 deletions(-)
>> 
>> diff --git a/fs/nfsd/trace.h b/fs/nfsd/trace.h
>> index 3d0f0bd30d90..1d5d11f914f2 100644
>> --- a/fs/nfsd/trace.h
>> +++ b/fs/nfsd/trace.h
>> @@ -1384,7 +1384,7 @@ TRACE_EVENT(nfsd_handle_dir_event,
>>  	TP_STRUCT__entry(
>>  		__field(u32, mask)
>>  		__field(dev_t, s_dev)
>> -		__field(ino_t, i_ino)
>> +		__field(ino_t, u64)
>
> My apologies. This should read:
>
>                 __field(u64, i_ino)
>
> I had the fix in my tree and forgot to commit it before sending. Would
> you like me to resend this one, or do you just want to fix it up?
>
>>  		__string_len(name, name ? name->name : NULL,
>>  				   name ? name->len : 0)
>>  	),

I fixed this in place and pushed out the update to nfsd-testing.


-- 
Chuck Lever
