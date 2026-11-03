Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.remote-ip=100.103.45.18
ARC-Seal: i=1; d=subspace.kernel.org; s=arc20261015; a=rsa-sha256; cv=none;
	t=1793714808;
	b=QoWxQOAejahMKEeVeKApyBHOa06Ho5I7MCOirDRnGpedmpsVppulwrYDgUtGr916eC6A
	 uOZd58sZ3BvlFijD8szxrjkImf6V30jkmtEOgoLEXpLdOW0UvTPNlI9KKmH6NSk+WOKoo
	 n4A+yh8YV0W5cNMah5htJ64dS0KMf+capKjp+n3NYACcmmVNAnd+O5LMRN6/VzAewgQ5+
	 cxzMRXe5s5ubCK6UPv2qhoqxvXDVWFh+7mnR8edp9Etz/U/eYvocdq0GhwdQ8qXufYrB4
	 Q0evH0zh0VLOSMfGsyakD+TP6TYffZBO4N+K+7qlf4sbcVmnpb0VvPFEBRaSv220omA==
ARC-Message-Signature: i=1; d=subspace.kernel.org; s=arc20261015;
	a=rsa-sha256; c=relaxed/relaxed; t=1793714808;
	h=Received:DKIM-Signature:Received:Received:X-ME-Sender:
	 X-ME-Proxy-Cause:X-ME-Proxy:Feedback-ID:Received:X-Mailer:
	 MIME-Version:X-ThreadId:Date:From:To:Cc:Message-Id:In-Reply-To:
	 References:Subject:Content-Type:Content-Transfer-Encoding;
	bh=xvQFZ/v6kc7GTHEID9MGSok2w4qCNqxYqf6XgNpZ1WY=;
	b=VVAn0kCNq9mLMLVwP1EoopgU0cZY6m4TuWjvfMSt25zG0XEboenMX9EFouhEyHk1oaUa
	 jmRGCkmT8Opw3gTretPPXPlCeB8v8V4e8ibmJtIm3NP9R02mMXMDtvBhYrQiHweVBRXci
	 CLvdAS0bUAVTLg94y42dgwQpZejB+FDi/QF2xWvnBNYdK3L3H0xr+u5nBEKdScCJ/gNjE
	 wizLRhBu5yliyB7BgLQBeL8kA4wjv+q3zCk1W1HOlGUHln6o4VHhg3PBzPK+ajbuGDHcJ
	 RUhcITW64BFB1VAzC0hXpPdhbd5Y9M2JuoVAn1aPevezp4jBHIr4Z+de2ZVTy1N2C2Q==
ARC-Authentication-Results: i=1; smtp.subspace.kernel.org; 
	dkim=pass header.d=kernel.org header.i=@kernel.org header.a=rsa-sha256 header.s=k20260515 header.b=JKOivCuM;
	arc=none smtp.remote-ip=100.103.45.18
Received: from smtp.kernel.org (quasi.space.kernel.org [100.103.45.18])
	(using TLSv1.3 with cipher TLS_AES_256_GCM_SHA384 (256/256 bits)
	 key-exchange X25519 server-signature ECDSA (prime256v1))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 37AEF606EEB7
	for <linux-nfs@vger.kernel.org>; Tue,  3 Nov 2026 14:06:47 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key, unprotected) header.d=kernel.org header.i=@kernel.org header.a=rsa-sha256 header.s=k20260515 header.b=JKOivCuM
Received: by smtp.kernel.org (Postfix) with ESMTPSA id 9DAE51F0093A;
	Tue,  3 Nov 2026 14:06:47 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=kernel.org;
	s=k20260515; t=1793714807;
	bh=xvQFZ/v6kc7GTHEID9MGSok2w4qCNqxYqf6XgNpZ1WY=;
	h=Date:From:To:Cc:In-Reply-To:References:Subject;
	b=JKOivCuM9zvCc5jlnDxGVpFReYBBp9CsyWYUjdQ0mJbWwmqvMyvXVRMp/6G5gHLsA
	 LA/i5s1fhKc3DnkutLYsgdrJclxTF10qbuDOg0GsIstg+mmvegjGNSdMA5LKwwRiIa
	 gWdukTY23xPhHZn7Y7/dit55ncfp0SBh9ozCmNQJZEcazSPwtOB/32NiApxCQ3TWec
	 FHU1LRf1XDbk3OVLlKfZdfzQiw0pLJQtwgk2AWOe1SBmZQs2/KXR7rYnX2ybZoum5l
	 YSNR5yHc1hcfZUM3YoyYpcCB7RXsy+bV4c5U4mJeMrcZ8za2GsihzfsJ75Tz4RklQM
	 uvbWYH1JIkV/A==
Received: from phl-compute-10.internal (phl-compute-10.internal [10.202.2.50])
	by mailfauth.phl.internal (Postfix) with ESMTP id D4D70F40067;
	Tue,  3 Nov 2026 09:06:46 -0500 (EST)
Received: from phl-imap-15 ([10.202.2.104])
  by phl-compute-10.internal (MEProxy); Tue, 03 Nov 2026 09:06:46 -0500
X-ME-Sender: <xms:durpaq0XmXEGaNipxDJx6sAcc4_6MF4DTGVGlppBY5cjNs-vK1yFfQ>
    <xme:durpan5Wf54Ycx_6DskgcsxA1b9-v5fi3VAvCKuTvwPbeIxP-z2XqMjNYG7PWQFXL
    oc5FXIZOnfEyIrd-iHpT8s3REngQj9BgFwEn5SAIcbvZTk4nVv0s4F7>
X-ME-Proxy-Cause: dmFkZTFy0L05d9uD78zkGdwcJCb86cXltBLzUGDgy+LT6NioesssvQJwLPwES3CG7zMILk
    UfdEM7wendlaj+hFKKHOLrAeIx88lH9cnpstgB/12/0FaUJO8llNP+iuPAZhVk6TeXroSW
    s+Sn6ZDRVwJEimTHOH0/xxX1sF/WqCilRC58EkM1jpdUqYTaFVYz0HI6dhXpsyu9SLxxw/
    xIS8FygDDVwe1iPGchC0EGFCp/FcGflutNpc1MTz+7LwPIU/B81Et/fRpHEZv1hiGHLh4e
    KcEcSkNhbQQ0ub6nX4iDSOcAuUPW3pwtbpUcr1XcLOJpmsSVBLPF1hgCqit64kkUC51iJO
    ALzNzVpdjx+/Qvk/piitnLGQHNGH+19XwppsgFXlqycexKFC4QyeqXB+uunV7AFryRUpFl
    3X+HZidwzgP4Wq3H/kolIPDQwvMeKejCwNeLW1lJd7eaXYj+StyE0wvj0OBBvMs2n+xOdo
    0kjnxPYYMJkUTaFxzIpjvv/hYI3LqwnnokSvGIMx7RZDI4KGxEC1FDdo7noS8pb6gtyupZ
    TVSbP3Tj04SjbnhlXvUh1zned/V3TAUz9OXJibaivczgaMC/NoNFes+FAXs5JU8A280ojs
    bo4UPvLGFkEX8NrF8a8/Kl4KFYWrPmbiyMATAtXwel9z3T4Jhgh4OQT+ek6A
X-ME-Proxy: <xmx:durpatxq1AFo1fzSg3ncDmUOxpeSt21Imu78TcsOyRLQi8AiuYCCWg>
    <xmx:durpalCrDdOSN_8zLXS39fgFOUQYovaaC0OpRwXlxdW1Tn8DhvlqEQ>
    <xmx:durpaqZM3dzcvQvD2mvBuv71ChI4myc0nvEp9Y5TNmgTIxj9YWPuvg>
    <xmx:durpathHsIQ5zXkId3cvPTZYCMcEX4oOGH9-Idi5Qw2p7hce2rzjqw>
    <xmx:durpas6wjdgUh_Ve0qgYJS6ezhyY-DI_scbkVzQHBcg3CAWSEFUBX-70>
Feedback-ID: ifa6e4810:Fastmail
Received: by mailuser.phl.internal (Postfix, from userid 501)
	id B5AE6782738; Tue,  3 Nov 2026 09:06:46 -0500 (EST)
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
X-ThreadId: A94A4md1mbWN
Date: Tue, 03 Nov 2026 09:06:26 -0500
From: "Chuck Lever" <cel@kernel.org>
To: VeroFess <coderzeng@gmail.com>
Cc: linux-nfs@vger.kernel.org, jlayton@kernel.org
Message-Id: <a36427bb-c62a-4b8c-a6fd-4b4901ab7e3e@slotpi15m67>
In-Reply-To: <20261103013237.1174538-1-coderzeng@gmail.com>
References: <20261103013237.1174538-1-coderzeng@gmail.com>
Subject: Re: [PATCH 0/3] NFSD: Apply all export checks when a compound changes exports
Content-Type: text/plain
Content-Transfer-Encoding: 7bit

On Tue, 03 Nov 2026 09:32:34 +0800, VeroFess wrote:
> When a compound moves the current filehandle into another export,
> NFSD does not always apply all of that export's checks.

Thanks for the report and the patches.

Two comments about the series: first, LOOKUP is a frequent operation,
so I want to be careful about adding more logic there; second, there
are better ways to layer the helpers, IMO. I'll run with this, and
add a Reported-by: VeroFess to each patch before posting here for
review.


-- 
Chuck Lever (Come to NFS bake-a-thon! https://nfsv4bat.org)
