Received: from smtp.kernel.org (aws-us-west-2-korg-mail-alma10-1.taild15c8.ts.net [100.103.45.18])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 07A3B2E737E
	for <linux-nfs@vger.kernel.org>; Mon,  5 Oct 2026 17:21:46 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=100.103.45.18
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1791220908; cv=none; b=q/T6Atc5PDMKoRNYla7jF5kzKb1uWG8qCNYcNtkNnksB9SEFBNP5RLf+dw1GwPfXHiFzWvTU+XrSVVeM7/PMo/z2qRSF/eT0Wuuo/LCmuJ4gbxdpFc6y9kcp88mvCUIpnxzJPwqmGa2VqWoqZ1vvj4ZeHGlYrDQAnHDMDO6IjkA=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1791220908; c=relaxed/simple;
	bh=H/OrT8gdHLL76ODHO2zoRxiO1XQMsYfe6c6/7huv9Aw=;
	h=MIME-Version:Date:From:To:Cc:Message-Id:In-Reply-To:References:
	 Subject:Content-Type; b=QIoKtx3s2WRBMcdBoenyfqMndJl/ANUjAJKFTU9pS8f+vMVTAZpgJNqo7vVO4QqLdiAN0NmsatUULIfYUdFRnIJctuNJOzYSGmqWESLRC2BJR7S8njDrit7vgoID/GQGrQF0kiJ281uFKXB1rZJf20NlDA39Kkhx7lEAQ2/RKoc=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.b=ETEku9n7; arc=none smtp.client-ip=100.103.45.18
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.b="ETEku9n7"
Received: by smtp.kernel.org (Postfix) with ESMTPSA id 537DC1F00898;
	Mon,  5 Oct 2026 17:21:46 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=kernel.org;
	s=k20260515; t=1791220906;
	bh=tIaq/GTjqf2zjatwD0T0Ua0jABrR8voKI2Yu11fMLdU=;
	h=Date:From:To:Cc:In-Reply-To:References:Subject;
	b=ETEku9n7hDJPvlTbeKRt6FPPL0hVPfEIzuEMXoOKV7O13A+4JVJc8yLCmXjcf8mMi
	 N8GnI0kdkamnfeNwzg229uyxPN/bemSe7mRsb4Pxh4RmUiuycX2U4xCngB3ulAuHmG
	 oMgY3m7dNzwTtzz2NS6+8dKu3lOZbUuTLkPJH43miczXNKW/YvIOCnoMlOVYNFEwEK
	 cMnd2WPwiFB1Nu/3Ichj6KZzNRreiGqpGPZOnME/Ewu9lyqyRHdNbbc1uIFLXf4TKF
	 eoIU8xyawuo0c/nZJwyR+DoQ5FUkR+bkLGIEXmKNGBGv92opzxfBeh/qaBEp+3T56E
	 BmW9K22cwMqEA==
Received: from phl-compute-10.internal (phl-compute-10.internal [10.202.2.50])
	by mailfauth.phl.internal (Postfix) with ESMTP id 4A0A7F40066;
	Mon,  5 Oct 2026 13:21:45 -0400 (EDT)
Received: from phl-imap-15 ([10.202.2.104])
  by phl-compute-10.internal (MEProxy); Mon, 05 Oct 2026 13:21:45 -0400
X-ME-Sender: <xms:qdzDaqUwF63TnoQyN8n4zSAOieuozX9xXMyZvTCt49akfdo0PLlasA>
    <xme:qdzDahbIPlLcuISrV_K1rZbiqKQEarhUhfa9x4hYSzS1-O2D1MEjHytGG3uLzfr3p
    1J7Av1h_m8Oe2Xn7AlEKhYk26k2-rEb3ZkxjnxYfHO1TWsapWmwHcCb>
X-ME-Proxy-Cause: dmFkZTE5mgiRz6mNB6ZihE6ucsOeaZi3xIivo2eBrMy9HEDJH+eU5xF1rE0mGLPYoyhiqG
    Z2dqB53OsHqXHWjivUViSdUHuVFTvGIgi2AlMUi++Zxvj8Mej8kJmAZf2zrbZrb++G1y26
    Pn0DOPRgRpRVTRQDIAgyMPit7x1ElfW+J1HKQefgGGqqehU/Md2spjxoo0XbCJMcE44ISA
    qVJBCodl8uShcgEPHyzeGrb37S6fJSmFxaN9EK8gniYQAXepXhrr4xvVetFc27GX59Wx60
    IQzJQmx0gNafJLY1f3tGlHmiE7c4jJAe0quPu5fAZC+GRKPakY5ArhWyml+8cTVsOp3uPe
    JaDM8UX3VCYjzP7LwSsTJ88EEEYGfdmJI3l5CG2ftGWboArS2jANxzMhl8v987vF+GUct0
    008TzyqivFgcYWDYJ6pDxjA5WK3IFQ9p4Id9UFhByklQDgx/wY99Y6zRCMDWt+GCloqvEB
    zFeIPAYei8qp4/I7XJOh5Kol9wcBcC5CN+Z7HFOhbRdEtzO6GzNenJ7gmL8yUGBNFxl0VM
    qXqTHE0LLzGD1j7xS5EiEkSXPDaNz+77owQYHR5MFI9DEiyYTKtZ3UuI/PBs6RGgrHeQ+7
    kb3LAmp1J7+i0CPNYzMWyO78rP466sFntLXBGJXNL9Tbgmx9B10+HNRB9VkA
X-ME-Proxy: <xmx:qdzDan48d1qqIIu2DB0La6B-PT-UqLaGK-1ojLIA8hpVlxTwlXuMGA>
    <xmx:qdzDauYf5zL2fNIigVytera_B5an2kOEdsFUa1BKilJcKKaPDokMMg>
    <xmx:qdzDauj1LmQBQVg0T2o7nktMZofaSw3vDSSAyFPMDuqYS-LUOMdBsQ>
    <xmx:qdzDan99yb6B0tH1fyknNlBmlFh4JUQULV3Hl8xTKxkTi4cxpUsJTg>
    <xmx:qdzDahrR12tBUZ1y2eFd29fDCXy2Xacv2AWiz7K6nCVBIUakZ4QGt4Bd>
Feedback-ID: ifa6e4810:Fastmail
Received: by mailuser.phl.internal (Postfix, from userid 501)
	id 1FB30780075; Mon,  5 Oct 2026 13:21:45 -0400 (EDT)
X-Mailer: MessagingEngine.com Webmail Interface
Precedence: bulk
X-Mailing-List: linux-nfs@vger.kernel.org
List-Id: <linux-nfs.vger.kernel.org>
List-Subscribe: <mailto:linux-nfs+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:linux-nfs+unsubscribe@vger.kernel.org>
MIME-Version: 1.0
X-ThreadId: AB0QkRkUO1Do
Date: Mon, 05 Oct 2026 13:21:23 -0400
From: "Chuck Lever" <cel@kernel.org>
To: "Benjamin Coddington" <ben.coddington@hammerspace.com>
Cc: "Jeff Layton" <jlayton@kernel.org>, NeilBrown <neil@brown.name>,
 linux-nfs@vger.kernel.org, "Daire Byrne" <daire@dneg.com>
Message-Id: <347a4b4f-8860-48c4-9d21-9f2a0c7ca229@app.fastmail.com>
In-Reply-To: <05C0FB93-B5F1-41C7-9559-C4E6554CE8A7@hammerspace.com>
References: <cover.1790953694.git.bcodding@hammerspace.com>
 <cb5d00b3-008f-4876-b284-c8cbabfea3ad@slotpi15m67>
 <05C0FB93-B5F1-41C7-9559-C4E6554CE8A7@hammerspace.com>
Subject: Re: [PATCH RFC 0/2] SUNRPC: dispatch ready transports round-robin across
 clients
Content-Type: text/plain
Content-Transfer-Encoding: 7bit



On Mon, Oct 5, 2026, at 10:46 AM, Benjamin Coddington wrote:
> I know all three of you said no tunables in June.  I'd put this closer to
> exports than to a tunable: it tells the server who is who.  Neil floated
> an export flag for marking clients on the first thread.  I'd do it through
> the nfsd netlink interface so it's per-net and not a module parameter.

I'm not sure how an admin would set such a tunable for a workload that
has to handle more than one of the fairness behaviors.

Scheduling, like getting old, is hard.


> It does raise the bar on the cost question.  If nothing is configured then
> everyone pays for the two-level queue and gets nothing for it, so the
> answer on your "alone" numbers has to be zero, not small.
>
> Would you take something like that?  I'd rather ask before I build it.

The "take/reject" question is answered by looking at patches and test
results, neither of which exist before a prototype is built. The best I
can do a priori is to say "that looks promising or that might suck."

I'll try to think about it more.


-- 
Chuck Lever (Come to NFS bake-a-thon! https://nfsv4bat.org)
