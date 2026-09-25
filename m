Received: from smtp.kernel.org (aws-us-west-2-korg-mail-alma10-1.taild15c8.ts.net [100.103.45.18])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id EEE6A4A499F;
	Fri, 25 Sep 2026 13:59:31 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=100.103.45.18
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1790344775; cv=none; b=ED8tT5NnEKz2BzlaIGi1QQOz2ZK8qImLzzGSLEKMEUqjkwj+I3wcE+I4ro8vfWxqD35FIQ06Vh5IDhyLm6g6o53iDo7X1pAgL9isGmCEIqfcJPZjkzRSRzcUQk2cCuKvVTmwfuARzhsCeD9Kiytv9ZynfWQ2xmsTy9Y+46mnZAs=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1790344775; c=relaxed/simple;
	bh=VGDbu4uIJLPw1TGkkVc2+ocldC9tMEr5E65/QcthV1I=;
	h=MIME-Version:Date:From:To:Cc:Message-Id:Subject:Content-Type; b=EteTPDdjtsyf6jSF6pWa+uOk2VCQ2xZJKpj+uoBUIeGuA07AtdVXNmVHgrgbZ4CuoHr0vn6bJuXGSsZGIJcjvixCPHL6e4IzllSf7yS4MNcqnvsR/m7qskA0j2hFpzPvj84nOSqP7WxCGq5Luy4DvJ3hQEOLGiYZXYMXhtSb9gY=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.b=N/bglYDt; arc=none smtp.client-ip=100.103.45.18
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.b="N/bglYDt"
Received: by smtp.kernel.org (Postfix) with ESMTPSA id 99E301F000FF;
	Fri, 25 Sep 2026 13:59:29 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=kernel.org;
	s=k20260515; t=1790344769;
	bh=dDCeHyIUItIJsmrlTXcpEu8AnNuUKo3pSvzsmalxGHw=;
	h=Date:From:To:Cc:Subject;
	b=N/bglYDt1AoQLMGSjYtyDNWahWNCHwK9IYrIY+0pFzawGNlibqEjskOth4zKt/t0d
	 UZr16y4S1uqXNZAk03PsH3VKZ4WgYXYBKvrQjVjm1aZqahf4iVT5C/hF+fzUXAjcwr
	 13lzwvjVXWye9FGm2te7PhqV4nlIJqBmqrwexWOpqYvoewm8698sE+y+08Y35ReIQZ
	 kpcjHG1oXpgWUfWeLrPFHfMIpnSpl/0iLDxCqRpsQXXH/VqHtYo+PV8tNPg0zpEv02
	 /ZGGRms8Hx5uLoMe84IP7MkjHKEF4mr4VJCRAJL7JuEyVuD/ijxixSz6h7HSgDYHhQ
	 /nYSNJYuThjZg==
Received: from phl-compute-10.internal (phl-compute-10.internal [10.202.2.50])
	by mailfauth.phl.internal (Postfix) with ESMTP id 84B97F40066;
	Fri, 25 Sep 2026 09:59:28 -0400 (EDT)
Received: from phl-imap-15 ([10.202.2.104])
  by phl-compute-10.internal (MEProxy); Fri, 25 Sep 2026 09:59:28 -0400
X-ME-Sender: <xms:QH62agMwTDG47yRJSFt2Bhr9XCORpGN-jWp9jW55Hx01pP4ck-8XpA>
    <xme:QH62ahz35Sji2hEUcVWys0YQ9S40wDQqjQWPPThvU-nZ3tYCJOFnZnTEs9lbayBmO
    fN5kToNhTLA_7_R0IAaKwXtc_J38bT56MJreXnRua-PbZFDgbj7A-c>
X-ME-Proxy-Cause: dmFkZTGjf+4bKVq1PkNfhFOYw+exy4I5ViAoUAkccg5gDSV5VV/jV6DnYEOj6Lmu/Obqxo
    0/H4MFVtfW4Xm8L/lwmsxAhdJZXWPdZU1hdGY66NJc3moz3BqR6jzqEoB7byvrfYvvKkqq
    KGJoU1yD3GaVPKjSPoAyrWBFlhQlDAiI8qbzi97JzgAsY+4cA9RFJWKBVE6iP/yZx3TYWC
    b4oLvtmo4kBZ3Nig1PT84t7KHsOYz5baXA+aeRJ/tN504wmUeWH82E7GR0mrcDmrcr9+jm
    PFKb2qLKx+z+5yjZd3h/VknwD2hTZyJAr5iGakwWMSCJlmgeZ31x/RqpJB25jwYaFS0ote
    pQ42haHf4wm53tfCEbTFCOr2dVq9JB2uMaCTMUjeWo3jJD97QEs4PGGoJlk3njhGW7nmay
    +bJQIdXMBW9Z/t3RwNyLg475aFm4kgKNWIh00Mo86M7XqzEGr3KwBM2wlybpghDMGTPBa6
    r8jHY9BF/uYBkDGWn0yMdP8Miui5jXsWk9KlgPNBs5X1EbG3f7yphBQ5RTzEsn+8VU9Ul/
    9CEHEEE359DBEBmkFZcwnf+SRVbe0qrWVtBeuqWw4WnGe+P8MUU4QP3Poo2HqwOlXR1T5I
    tx3xP/M0r/D0+rJfId50PUL74vMQJ25A0rBSOO2yZ6y/elLzsdTaL63K4bmw
X-ME-Proxy: <xmx:QH62ajxL9Far9atOv4ljdvEMiMexqHPE7_xPG7iqtyugzNNs4zy91A>
    <xmx:QH62arZxfe9r0hlNAJQVnv56Tg_4ftbRrjCUS21thLNmdwdjFC42VQ>
    <xmx:QH62alT4LcJMXVkEGCYKjpi_sH-vJMvTuJWG3ttpcBJ5I2o_uwFlYw>
    <xmx:QH62alz0TCMDnWhCqccEtfQEnUAenyol_2WnEDyiAV-5b-dQOGsEMQ>
    <xmx:QH62av3ACKY63mdH4ebFrsnMvhif443yxag8Du2hjcrwAMq5T2JqKhkw>
Feedback-ID: ifa6e4810:Fastmail
Received: by mailuser.phl.internal (Postfix, from userid 501)
	id 5558F780070; Fri, 25 Sep 2026 09:59:28 -0400 (EDT)
X-Mailer: MessagingEngine.com Webmail Interface
Precedence: bulk
X-Mailing-List: linux-nfs@vger.kernel.org
List-Id: <linux-nfs.vger.kernel.org>
List-Subscribe: <mailto:linux-nfs+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:linux-nfs+unsubscribe@vger.kernel.org>
MIME-Version: 1.0
Date: Fri, 25 Sep 2026 09:59:08 -0400
From: "Chuck Lever" <cel@kernel.org>
To: kernel-tls-handshake@lists.linux.dev
Cc: linux-nfs@vger.kernel.org
Message-Id: <4b423b72-14ad-4f5e-ae5f-7e7ef6df7c0c@app.fastmail.com>
Subject: Development of ktls-utils now under github.com/linux-nfs/ktls-utils
Content-Type: text/plain
Content-Transfer-Encoding: 7bit

The time has come to retire the use of github.com/oracle/ktls-utils
in favor of a community-managed repo. oracle/ktls-utils will no
longer get new development work, and will be archived.

ktls-utils releases, issues, and the wiki have been copied to

  https://github.com/linux-nfs/ktls-utils

where development of new ktls-utils releases will continue. I will
update the CONTRIBUTING and README information to reflect the change.


-- 
Chuck Lever (Come to NFS bake-a-thon! https://nfsv4bat.org)
