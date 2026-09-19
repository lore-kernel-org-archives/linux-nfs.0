Received: from smtp.kernel.org (aws-us-west-2-korg-mail-alma10-1.taild15c8.ts.net [100.103.45.18])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 5D6ED2ED141
	for <linux-nfs@vger.kernel.org>; Sat, 19 Sep 2026 16:11:41 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=100.103.45.18
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1789834302; cv=none; b=fdfTRU0eCxqsqHisf/WXmouHtTovlz2WCFNR+iq/Izmn1fHEZ72dCt1xdR5DNYucYSLyszzGJ1V5NT4Me1vJsfvSVBbYC5DfIF4G3GG0UC0xw2Az4n1eRfz0aQsoa5NlofNHPQ9kdKzQ2qKnRT5hKGf0h1UJYd4aQMXvystMWAc=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1789834302; c=relaxed/simple;
	bh=eEnSPjzGwbm92SQ4gh4C5u9LvJVtJ4nM76fDHPq64R0=;
	h=MIME-Version:Date:From:To:Cc:Message-Id:In-Reply-To:References:
	 Subject:Content-Type; b=Tf+o2DffwnepTWwDON0jt9cjIk/JJkE6lcGxHQqJaxQxuEZDAUEoHWbcXhefLiAlAYK4b4ATggCwH0b5eFsmSlZPWqZFVljpa1ReqWCRigcKPoNy5VKyqEjCCWiHBzuxsW4ANIRn0uTUeX24l2OTkiP0V0xzdnQcuTdmDoghdGc=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.b=Tj5RW8/t; arc=none smtp.client-ip=100.103.45.18
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.b="Tj5RW8/t"
Received: by smtp.kernel.org (Postfix) with ESMTPSA id A4D921F00893;
	Sat, 19 Sep 2026 16:11:40 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=kernel.org;
	s=k20260515; t=1789834300;
	bh=44cYfAhHvog+0OWjXfCaJkzwGaXsMAj5yteR4Z1pqhU=;
	h=Date:From:To:Cc:In-Reply-To:References:Subject;
	b=Tj5RW8/tFPdMeO2u1lbH0f6pw+JywRbcl4rB2vMJ5T0+srAAsHU0uLWg45LHfuqBX
	 RxbkIsFKGeqPa8xy0tzwtGqk9tIZRhIj3b5xbujd2zPucvvlWdCElxG5QIsUHLIKsV
	 kX7Et3psRHncUL2/Qle66bM3913Nn01J2jJwYasD6XEzJIpzOlmaf+E4rz0oOMH3Et
	 g7ozK2cN0ccPMY+jt/ub1mS9xVSNZefU3c0+79Ey6RaFesHSJigsCmJ7HZLAP7j643
	 WrxUhD7Hpe1qu4Ao9xU7iFiqZLbr8WDb1jm1hRTJwZLP6Se8FQagbu58Rqk+liGLip
	 5hNrRvBfnHjMA==
Received: from phl-compute-10.internal (phl-compute-10.internal [10.202.2.50])
	by mailfauth.phl.internal (Postfix) with ESMTP id DE07CF40066;
	Sat, 19 Sep 2026 12:11:39 -0400 (EDT)
Received: from phl-imap-15 ([10.202.2.104])
  by phl-compute-10.internal (MEProxy); Sat, 19 Sep 2026 12:11:39 -0400
X-ME-Sender: <xms:O7Suaocdc_4fi1xAH7n7MASuT4TLS_Jt7kRwllz43hR6S7VAUIc2rg>
    <xme:O7SualCwjenNeP5owjfVf6uHySbu6o7VNUKSd9sYJLYioh5TibFsOFmcyDtqmQwxW
    wkU7PxoYfLXn10Viut9xmG37TRmGp23YooQmhyYxbYDIWMsLKiY3Cb4>
X-ME-Proxy-Cause: dmFkZTF0n7cxv0ybYRGaMhfDpl2fZClcjI/n1DqEH/Pb0GdJYGPo74fM/8sVrz5iSKgdG0
    8jTTLMTdxo4bUPS1yPPwQh3DUH04PGD3adpYOEmBa1PST+h4esFda3sM/OTp31k9kvOl2v
    aDBXjjmo2Vi+gYROOfEFsRoUMu6FgIp/Aj7wmPv8yQbLIr+EeY7+LzZtI6pMHKtZm6cvQm
    B/OOC13z9+/5VbiySISP+BQpKATXRnVcQmTr8ZQ5k0LoiwFdB1CooN5VGgmKnYxXVBdzee
    BIWjCNGvcb5Zue1wsqJtnhsciNMsNYVg94LQ6U0mSO9fGPQzzOHaKBAIAO9RkCK7BBZJHs
    LyOhfQ0kYH5RU+ncplPGcFKTBVB5jALPsev4gn0Ugzep6SQlRyFr+FGmJaPqJK3vJURZKV
    3OyX/k4mxAz/fYXSa4MH3AiM7VSF8Y9A9crzTwKnCbI2op5bu4b7wd0Yo/63g5m2c00m7m
    uKNqOEegMSzlMR+PLUyjUyEEobkG85+E4SzDf0Wz4aIUbRuv8hA4h5n0KKF88u2A2hUFyn
    sEWzkj2JcWzy1VGwAImRhuHY7dDgYVjfWYenk4XaIShiQF0m9Fdiy9xy+8rejjC8NbgrgA
    /NYbXSkEAxlruQaBmSoI4JJaunh8xy55FpKp4+ttwOY+Qz18asdhbvDenlyA
X-ME-Proxy: <xmx:O7Suaj2iE_tDVLyOnTzsqIfkyiOM9q40dkpxxUM3Ned9pvgScGkGXg>
    <xmx:O7SuaixQCpCzw_m7wPLJMUWTI5T3jrqYsrnJrirEeBh7CVpQZsTGlg>
    <xmx:O7SuaiF_sPBARME7IiGveu4SaZ8Uujs34qu815vn-I1jZHlSLpaqPQ>
    <xmx:O7SuatYmFzDI8kneFnudZ44-8H9M2nZ30d6uv-k1cxkhzmjzb9DpnA>
    <xmx:O7SuasAo4htcvRQJ2f2mpr527rAvwjTrLnC5V3XXsCqF4kuXzLHybKN8>
Feedback-ID: ifa6e4810:Fastmail
Received: by mailuser.phl.internal (Postfix, from userid 501)
	id 6EC52780070; Sat, 19 Sep 2026 12:11:39 -0400 (EDT)
X-Mailer: MessagingEngine.com Webmail Interface
Precedence: bulk
X-Mailing-List: linux-nfs@vger.kernel.org
List-Id: <linux-nfs.vger.kernel.org>
List-Subscribe: <mailto:linux-nfs+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:linux-nfs+unsubscribe@vger.kernel.org>
MIME-Version: 1.0
X-ThreadId: Ahez1a8JXu07
Date: Sat, 19 Sep 2026 12:11:11 -0400
From: "Chuck Lever" <cel@kernel.org>
To: NeilBrown <neil@brown.name>
Cc: "Jeff Layton" <jlayton@kernel.org>,
 "Olga Kornievskaia" <okorniev@redhat.com>, "Dai Ngo" <Dai.Ngo@oracle.com>,
 "Tom Talpey" <tom@talpey.com>, "Rick Macklem" <rmacklem@uoguelph.ca>,
 linux-nfs@vger.kernel.org
Message-Id: <85a7313b-6c69-41bd-9a12-18ab4fec4b5b@app.fastmail.com>
In-Reply-To: <178977475436.207413.9806283444174908649@noble.neil.brown.name>
References: <20260918-duplicate-reply-cache-v5-0-b6aba9ebf2f4@kernel.org>
 <20260918-duplicate-reply-cache-v5-11-b6aba9ebf2f4@kernel.org>
 <178977475436.207413.9806283444174908649@noble.neil.brown.name>
Subject: Re: [PATCH v5 11/11] NFSD: Remove DRC checksum and payload_misses stat
Content-Type: text/plain
Content-Transfer-Encoding: 7bit



On Fri, Sep 18, 2026, at 7:39 PM, NeilBrown wrote:

> If we get a request on a particular transport and it is a good match
> for a request that we recently replied to on the same transport, then
> the chance of it being a timed-out retransmit is 100%.  A client that
> re-uses xids that quickly is buggy, isn't it?
> So if nfsd_cacherep_acked() then I think we can ignore the request.
> In fact if the "found" reply was sent on the same xprt that we received
> a new request on, I think we can ignore the new request even if the
> reply hasn't been acked yet.

Just to be clear, by "ignore" do you mean "drop the request" or "reply
with the cached reply" ?


> Everything else in the series is good and I really appreciate how
> thoroughly you have explained the logic in a lot of places.

Thanks, your comments have made this a much better implementation.

-- 
Chuck Lever (Come to NFS bake-a-thon! https://nfsv4bat.org)
