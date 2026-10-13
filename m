Received: from smtp.kernel.org (aws-us-west-2-korg-mail-alma10-1.taild15c8.ts.net [100.103.45.18])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 6507453B61F
	for <linux-nfs@vger.kernel.org>; Tue, 13 Oct 2026 19:44:42 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=100.103.45.18
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1791920683; cv=none; b=Vdu1P4q2AYNu9Rv1O0rR1Iw4wBtqkl/JK1zJSxxhNfg4xQAZpVqDqIls2FU/40d49+Dp8Wd+Zobo8w7LxViXfvY2d3EE/jU+obKI52k6iCJBUh9VZVrrABkzuDXuT9g+bREsrUKt5Nx5TIqPmx/OpEA9D+n1oEg4Ga8mlttNydc=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1791920683; c=relaxed/simple;
	bh=TSQnK7LzGwPI7c8uOT5uY1n/Tokhp+Aw+bkKi+bHZFg=;
	h=MIME-Version:Date:From:To:Message-Id:In-Reply-To:References:
	 Subject:Content-Type; b=lXG7VWIGDNrpNxex7vzdM7YLSVjT8f6lBPmRVc9ocgD5A5vXngXbWfYilvEskPFKXF5sllnn//rty+k6Rb3OIc9IN6AzcF6H/mJseVF5IKE+4J8cUau9MszA4gu7cbvzUokDYIKBwQRzp3XQChryfCjy1xK6Mp1HZO6fzDILcfY=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.b=CD+/Ne6h; arc=none smtp.client-ip=100.103.45.18
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.b="CD+/Ne6h"
Received: by smtp.kernel.org (Postfix) with ESMTPSA id C90C01F00893
	for <linux-nfs@vger.kernel.org>; Tue, 13 Oct 2026 19:44:41 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=kernel.org;
	s=k20260515; t=1791920681;
	bh=TSQnK7LzGwPI7c8uOT5uY1n/Tokhp+Aw+bkKi+bHZFg=;
	h=Date:From:To:In-Reply-To:References:Subject;
	b=CD+/Ne6hwuvMi00DUQgTdGb5nfw4xPftrBTljcqnOpezQzpwaoxzmouX4NUJY23ed
	 dZWHeNlO60R76DJqL/WB81nHFvbNHNkntp2dtJXAjgc9r6fk3mmwm6NRbgAY9eyQMO
	 wBK4ZloXQ9pmWh4LSrfQdv4pDO0E0zPsQpTvlfrkTctMBz4SeAIGV8SpJml2I9BL4i
	 AduSIMH0WS4iXswhy9Nrrzju708iS0dJKWRoGVOQn5+nxpIhbYDfyQaNbNtSqPkjDq
	 iOe4GXEVlVrzzRWRueMBk72LJ61HZwk4OFzLlg/m0kIQw/HI9fm1BYR7qR5b5TmqCB
	 nICssx+g2geDg==
Received: from phl-compute-10.internal (phl-compute-10.internal [10.202.2.50])
	by mailfauth.phl.internal (Postfix) with ESMTP id 345C8F40068;
	Tue, 13 Oct 2026 15:44:41 -0400 (EDT)
Received: from phl-imap-15 ([10.202.2.104])
  by phl-compute-10.internal (MEProxy); Tue, 13 Oct 2026 15:44:41 -0400
X-ME-Sender: <xms:KYrOanD0c42Uk-ThIa1bWc8fipqWdje7fe_O0Q-dm_ysIXQ8Jde2OA>
    <xme:KYrOaoWHyrrxzeu9bYwJcMBA15ump6YnhbTMOp4sZIRGp1IhO34eBfEMNG4HNQ9dv
    1jIrvB9COY0k0-AKkDByqgftkxDagXS4HXmr613PLdoH5A2t85e1a1V>
X-ME-Proxy-Cause: dmFkZTFkU8FcWHCv9cL9e/1xagwAnvQZdMuC3DUduZExj+4XkxbLWA5ZPJfzBLUNw1VN4x
    l5oPTRQ3brWdyCkVls4Y79ZDmTalW1xt2KHjmrgyfgpUdIKZo7q6Ot/YeZ0KSmz8Pk2Xi9
    NmhhE2kd1anBSVhLMdJArg/Wi6iIqpfd5tr83sfOyypvrTxa2SlsQYpYapoI5ervyaHrRa
    7Sv9TPn0mAcbeoRSDHDM54pSN8s4oOuzmhUhyBy5lrU1it3Heraf9x4GeTFFFrNm85qEoy
    R4IDyjKWunjQ6CeKqTrL0PHVvxLbswhXbz5FB6rz54P8IXsXrmeqadcIEEwSKE2rKaiRI3
    qEeF2uRb3uAWSD6L4ycEXKF04wNSrhDKmQ2InAEZ6s8usQpVdvM2uSUcltEUH8InUWAxAb
    ZmgeCLF6/YNvoKi4T+ra4n7uKIK6Sb8fZMvPWX0XlA1G90GK0B3CZLs+28ArtZf03wEBXv
    PX+LdApxeCzd7XrA8efa/ySdt0JYUQpIlTxK9bwd9eE7oeMdvvwkwyuTSSLEw7xPbCqXk8
    2Rjrk5T8A4UWa+uq0Y/JQb7HPaRxGd82v630JCYnxKn2NidIk1QVZbVRwC6ID6cUVr6cIG
    fFnaGgjzmspZ+xKbVTKzPCuTnvhYcch9ZS8yofBtz5kOI0vbW0AL+22i6SfQ
X-ME-Proxy: <xmx:KYrOaptXZJDctZFzGPrUIjWo7dYMY31qTVrY_6vH5iG0N20E5C7lxg>
    <xmx:KYrOagbYLPa9GClc-5O1OcJJwuHlxh6q6J8igcXWT1ijC7NUhWulNw>
    <xmx:KYrOakXce14BKD2tQmwLB-wSAhq4CGgIBQD6IcrXr4kBUGbU7vjGRw>
    <xmx:KYrOas6y1gWvZzSlD8UV0H6nEychacg5sSUS9ulghe81Y0Yd3q7leA>
    <xmx:KYrOanjoi7YBik9ubXgYfBXkvlIHGMTLQGIeE2WA3c-HB0M9Lk2SCmYk>
Feedback-ID: ifa6e4810:Fastmail
Received: by mailuser.phl.internal (Postfix, from userid 501)
	id 1A157782738; Tue, 13 Oct 2026 15:44:41 -0400 (EDT)
X-Mailer: MessagingEngine.com Webmail Interface
Precedence: bulk
X-Mailing-List: linux-nfs@vger.kernel.org
List-Id: <linux-nfs.vger.kernel.org>
List-Subscribe: <mailto:linux-nfs+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:linux-nfs+unsubscribe@vger.kernel.org>
MIME-Version: 1.0
X-ThreadId: A7Qpu3LgJ76B
Date: Tue, 13 Oct 2026 15:44:20 -0400
From: "Chuck Lever" <cel@kernel.org>
To: =?UTF-8?Q?Aur=C3=A9lien_Couderc?= <aurelien.couderc2002@gmail.com>,
 linux-nfs@vger.kernel.org
Message-Id: <53126e21-1f5e-45b2-8a20-2f231020b86f@app.fastmail.com>
In-Reply-To: 
 <CA+1jF5rfRgf6T312L0Ziwubx=8NXSUqrscQEkD2rY7mdve3RKg@mail.gmail.com>
References: <20261009-acl-mode-v3-0-ba487c5e66e0@kernel.org>
 <20261009-acl-mode-v3-8-ba487c5e66e0@kernel.org>
 <CA+1jF5pyuVULzoAjbfCLDjwwOwHQP7sG29G-dkG9ZSOdVShHWg@mail.gmail.com>
 <dc1342d1-3c6f-4ebe-a093-2c2f876d32dc@app.fastmail.com>
 <CA+1jF5rfRgf6T312L0Ziwubx=8NXSUqrscQEkD2rY7mdve3RKg@mail.gmail.com>
Subject: Re: [PATCH pynfs v3 8/9] Add tests for SETATTR with MODE and ACL
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: quoted-printable



On Tue, Oct 13, 2026, at 9:29 AM, Aur=C3=A9lien Couderc wrote:
> On Sun, Oct 11, 2026 at 6:37=E2=80=AFPM Chuck Lever <cel@kernel.org> w=
rote:
>>
>>
>>
>> On Sun, Oct 11, 2026, at 5:40 AM, Aur=C3=A9lien Couderc wrote:
>> > What about testing FATTR4_MODE_SET_MASKED too? IMO this is a better
>> > way to set the mode, because it is atomic and might fit better with
>> > ACLs because it only sets intended mode bits.
>>
>> So, this thread is a repost of last year's pynfs ACL+MODE tests. I was
>> trying to include only fixes and clean-ups.
>>
>> To be clear, are you asking for an additional pynfs test, or for
>> additional logic in the Linux in-kernel NFS server? Or both?
>
> First I was thinking only about a pynfs test for
> FATTR4_MODE_SET_MASKED, but then I found out that Linux does not
> support it. IMO the answer is therefore "BOTH". But first the test,
> because we need to test this in ganesha too.

I'll make a note of the ganesha interest and look into implementing
both.


--=20
Chuck Lever (Come to NFS bake-a-thon! https://nfsv4bat.org)
