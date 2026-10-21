Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.remote-ip=100.103.45.18
ARC-Seal: i=1; d=subspace.kernel.org; s=arc20261015; a=rsa-sha256; cv=none;
	t=1792604143;
	b=PLhzBhrqawwcU34AXZjIbvL7L07/s/ldxWIfMUr0tj+2otHAzYVk6p2tHyDIEuDeoQxP
	 vqEPdcJ+NhFAT+rcdNTReLBO/FDOMp69thjx26LtcPNelN08UKgpL8Gz6FuU/5LMBd6d/
	 xG4rbTmm9fYycm8jeW8cdDohkrAsVQ31YhxfMj5B2st0qeJsBh/2ZcgD+XK64MFczYekz
	 HxAWhPd2/qc9nPy0HhnelnG+oFyfnbYO7PzYGUsIzyZfYX84RMC+hqxJA8tuWAQKMPlOL
	 LCib9jp3JZxIrtmfK1WVAU96kCnFHTWzm00Ao6/fCgo+/nsqNfxZhvymVyq1ff5l5yA==
ARC-Message-Signature: i=1; d=subspace.kernel.org; s=arc20261015;
	a=rsa-sha256; c=relaxed/relaxed; t=1792604143;
	h=Received:DKIM-Signature:Received:Received:X-ME-Sender:
	 X-ME-Proxy-Cause:X-ME-Proxy:Feedback-ID:Received:X-Mailer:
	 MIME-Version:X-ThreadId:Date:From:To:Cc:Message-Id:In-Reply-To:
	 References:Subject:Content-Type:Content-Transfer-Encoding;
	bh=nZQZSw18SACZ1al6YiSFkYg9oVM20D+TpFhKEJVNqeo=;
	b=F5oiohnxOdXpOrZz9cqsdexPg/Jp9zimbyj1JlG2V5newQ7WSRVpaGo5+X6xWxokQRT6
	 H2p5xvP3mYBrxgcDGSb4op4GKGZXzv4dEz2/qF1HYD3ARIzni6Hj0gmMZTomuuzRxIe4E
	 UmEXOJ2eplRjUFB+Y7V0nQYUOkByik+VFr/SoqSN4xk+lDdWtmiwFJ1siNx9FUAEWWX67
	 s1t5sxtjkSBhN+9PLE7MJXqYEEgoGZcWxQFBZzQ657wpDYeLRw92xG+myVCOsDJ7lclsG
	 Kl9FOumk7YL/S4/GWwFXnZFfdzkuMjG7P+nCQ46tW2gxYe77o+UYHsP5xiqyYcuw5qg==
ARC-Authentication-Results: i=1; smtp.subspace.kernel.org; 
	dkim=pass header.d=kernel.org header.i=@kernel.org header.a=rsa-sha256 header.s=k20260515 header.b=gtHPyv2D;
	arc=none smtp.remote-ip=100.103.45.18
Received: from smtp.kernel.org (quasi.space.kernel.org [100.103.45.18])
	(using TLSv1.3 with cipher TLS_AES_256_GCM_SHA384 (256/256 bits)
	 key-exchange X25519 server-signature ECDSA (prime256v1))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id CBEE6606A31F;
	Wed, 21 Oct 2026 17:35:42 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key, unprotected) header.d=kernel.org header.i=@kernel.org header.a=rsa-sha256 header.s=k20260515 header.b=gtHPyv2D
Received: by smtp.kernel.org (Postfix) with ESMTPSA id C89561F000C7;
	Wed, 21 Oct 2026 17:35:41 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=kernel.org;
	s=k20260515; t=1792604142;
	bh=nZQZSw18SACZ1al6YiSFkYg9oVM20D+TpFhKEJVNqeo=;
	h=Date:From:To:Cc:In-Reply-To:References:Subject;
	b=gtHPyv2DytAGwXwqP6AuPtrURaFm2Es6e2+bG+60zzEQjzkkjCH2xhWwDE3vMuH+W
	 /njNlq5bKa1C0QFRO5yVl3CYVzjJuumbgjChgiKa5cNuoBqQPx3tzAXdWq2jpC+7y4
	 xfZDP8ctYNyBUsoHqGnqbHyKWFyiydtg2UVaHKz1bxT0eH2yeW7iceeNsx9xDvff0D
	 d4QWmsRgnZJm8URGCYwD8psqQME5NT4H5VD3SIk89SsgIA6HMZZEAsCYnJEPLVse/v
	 1178n3snkCX5UTsdJTmWorxjZ/Nm5yhJmvMW7+8VBnvSRDFL7n1GBpZxztin4LJw2Z
	 dpIDU4fmdMHjg==
Received: from phl-compute-10.internal (phl-compute-10.internal [10.202.2.50])
	by mailfauth.phl.internal (Postfix) with ESMTP id 05E1FF40069;
	Wed, 21 Oct 2026 13:35:41 -0400 (EDT)
Received: from phl-imap-15 ([10.202.2.104])
  by phl-compute-10.internal (MEProxy); Wed, 21 Oct 2026 13:35:41 -0400
X-ME-Sender: <xms:7PfYatFbK3SGvkv1PZ5WJiKqbnltKgPHrFocaFLc9JUp-IAv1dxn3A>
    <xme:7PfYatKxLinDI60CCDCNz6n-Sj1DQX516hiu7qtOg8hUKZlVb4_0cJO4J4axVu7QJ
    n1c5qECWdS6ItzXnr6A1UuwHQpES3rw0oSxFPHU6JXFRfYZownwzmuv>
X-ME-Proxy-Cause: dmFkZTGCRjlnSR8Neg2mpGTDvJvFQ+WyF5lNldIB0q4zon/r5UxQ070SLuVQHGmuL/1IQs
    hwZ/xhsfszkwm1t5IL5077RE9E1CmNJeGs5M0heUIqhUPsiPorYZOAoMMquElo45vQkPAL
    5o6E0JGmgCcNf4/b7AK7NvmWD3X8w88YX8WwNKFCy2mAPFdtZUSubNdlIZYjAp45PwEKqJ
    i3UG1z5Zs2Q6j+WxyzADnx++ZMd9/Av6U2d1l0Maysg4LiGWlPSZs2/UbKUPa/Sl9zQZru
    JKCpo88uCIHH/dHiqwxA1Rv195n9u+MHvTsKxE7AJcpg1u+K44QfQeHXoE0mwvDOxUQdsz
    OHmTRf4blfvfR3Bk+u0TWU/xBbokz/9rHk5FCnl/2PEY0GqpE8jafPjgMx2t9fOQOJifyb
    OvUSDTZHBf0u1XXyfa1kBlP2Boe47OSRAIwc9jb99f+EMW67C7764RfA5PznCwLRSZ9f/o
    OqZSXZnbCIdxRw/7VnpgCAqdpuDhD+HX6ju96Wrn7XD7EubQVkBsAIh+oYZKgKtNtPPOCs
    t0TXsHLIYfOm/HdEysB64ZHxkNQcWRBrSFhbbsvaJxnVRZ1lGQHczXsHXxYjzTZbwDN6kx
    XWhWdnja+2FHBWi51pwBJFQahQp7RP95auTW9R065CD/aDZKZ4I1gRWDnU2w
X-ME-Proxy: <xmx:7PfYatVD__8wXb41zYEe29XHtozznhOzv0MZZN1eY7p2KicO12w-DA>
    <xmx:7ffYaqyWNau02205DPQuCdlHluDhf9_AFQPdUjs5A-o56NnLQ2GlIQ>
    <xmx:7ffYat4ndxHHVQANfVp63WjkU7APGZB5e8ZcmmUrAQOmxScV7dZNNg>
    <xmx:7ffYash0_tdrm5M8iKwj5F7TeVZI76mm4tQp4HL6Y-vsbGuMimeBwA>
    <xmx:7ffYaohOZRNYEwZe0HcPVW550R2avMTr5rBAQvWHh4KFch9VYCrntV3W>
Feedback-ID: ifa6e4810:Fastmail
Received: by mailuser.phl.internal (Postfix, from userid 501)
	id D6715782738; Wed, 21 Oct 2026 13:35:40 -0400 (EDT)
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
X-ThreadId: AwLsEl3CooH3
Date: Wed, 21 Oct 2026 13:35:20 -0400
From: "Chuck Lever" <cel@kernel.org>
To: "Jan Koester" <jan.koester@tuxist.de>
Cc: "Christian Brauner" <brauner@kernel.org>,
 "Alexander Viro" <viro@zeniv.linux.org.uk>,
 "Serge E. Hallyn" <serge@hallyn.com>, "Jan Kara" <jack@suse.cz>,
 "Theodore Y. Ts'o" <tytso@mit.edu>, "Paul Moore" <paul@paul-moore.com>,
 "Arnd Bergmann" <arnd@arndb.de>, linux-fsdevel@vger.kernel.org,
 linux-api@vger.kernel.org, linux-security-module@vger.kernel.org,
 linux-arch@vger.kernel.org, linux-ext4@vger.kernel.org,
 linux-nfs@vger.kernel.org, linux-cifs@vger.kernel.org,
 netdev@vger.kernel.org, audit@vger.kernel.org, keyrings@vger.kernel.org,
 linux-kernel@vger.kernel.org
Message-Id: <fd20b840-350e-469c-9fd2-008fa0ded62a@slotpi15m67>
In-Reply-To: 
 <f444dffc8e6bf98bf44c02456adc2de40e4ecd95.1792552161.git.jan.koester@tuxist.de>
References: <cover.1792552161.git.jan.koester@tuxist.de>
 <f444dffc8e6bf98bf44c02456adc2de40e4ecd95.1792552161.git.jan.koester@tuxist.de>
Subject: Re: [RFC PATCH v2 40/41] nfsd, nfs: carry UUID and GUID owners as their text
 form
Content-Type: text/plain
Content-Transfer-Encoding: 7bit

On 10/20/26 11:16 PM, Jan Koester wrote:
> Encode such an id as its text form -- "xxxxxxxx-xxxx-xxxx-xxxx-
> xxxxxxxxxxxx" for a UUID, the same in braces for a GUID -- in both
> directions on the server and the client, and take such a string (it
> has no '@', so it can't be a user@domain name) as that id again.

A bare UUID in an owner, owner_group, or ACE 'who' string is a new
owner-string syntax for NFSv4, one that only Linux would recognize.
Thus it isn't interoperable with other NFSv4 stacks as proposed
here.

RFC 8881 Section 5.9 says a string without an '@' that is not a
decimal number means no translation was available and the receiver
"should not use that string as a basis for translation into its
own internal format." RFC 8000 Section 6.1 forbids bare numeric
ids in multi-domain deployments because they collide; the same
applies to bare UUIDs, and more so to GUIDs.

If you are serious about pursuing this, you'll have to start by
raising the proposed wire format on nfsv4@ietf.org before the
Linux kernel's NFS stack commits to it.

With nfs4_disable_idmapping and AUTH_SYS, numeric_name_to_id() and
encode_ascii_id() handle decimal ids in the kernel because there is
nothing to look up. Recognizing the text form in that branch only
would be the natural analogue once the format is agreed. Everything
else should go through the idmapper: extend the nametoid/idtoname
channels and the client keyring upcall to carry a 128-bit id, and
let rpc.idmapd and nfsidmap decide which strings map to which ids.
As written, the UUID check runs before idmapd for every name and
auth flavor, bypassing the cache and any site policy.

So my general preference for NFSv4 would be to pass the new format
up to the user space idmapper instead of handling these in-kernel
with no opportunity to apply local policy.


-- 
Chuck Lever (Come to NFS bake-a-thon! https://nfsv4bat.org)
