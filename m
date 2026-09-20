Received: from smtp.kernel.org (aws-us-west-2-korg-mail-alma10-1.taild15c8.ts.net [100.103.45.18])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id D719B1A6820
	for <linux-nfs@vger.kernel.org>; Sun, 20 Sep 2026 17:48:26 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=100.103.45.18
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1789926507; cv=none; b=vErog7rOHpkGacJx/oWWK0TED9rg+Q5/dz04UVGGWlSaUTLnaOyzp5n8ueLBixeYyIAZepxA6BR/7Cgcn1F3en1hCRVDsAcLgODJexZKm8ajzfcnvO7sygHTWpq6289EtrFnfGr7HAt//abySioPRBUoClIrDZio8qiuefLDoq8=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1789926507; c=relaxed/simple;
	bh=WFNK5KNpJU+fww2mF73SECR4dx/v4+MR5nGGTgd8KcU=;
	h=MIME-Version:Date:From:To:Cc:Message-Id:In-Reply-To:References:
	 Subject:Content-Type; b=Kye0tsRdMmZLp1VPjiaLiMRJB7tiwhqi4G17dDjeLV67LoFmRTEMNRGnzOgugErFU5aJnIbIGiFtg6fs2cfzOHvC3AnWfT254JQBW3/nsTpTuXxGZN3F8c09iUrwsK4GQVLU0XKMCx3IgDGrYnhbvsvG7+tFWrxYgmZv6zd7yDQ=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.b=k6TYQKVw; arc=none smtp.client-ip=100.103.45.18
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.b="k6TYQKVw"
Received: by smtp.kernel.org (Postfix) with ESMTPSA id 517A91F00893;
	Sun, 20 Sep 2026 17:48:26 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=kernel.org;
	s=k20260515; t=1789926506;
	bh=y172gQUO8LKzNjt+0Aq65XmL+fp1n6Fr6QixvUUzqb0=;
	h=Date:From:To:Cc:In-Reply-To:References:Subject;
	b=k6TYQKVwu+wlEqgWy2n6LX4gt8SOx0Md4I60ylS39anJIihAUVHGDia0lFYy3rpGx
	 6XFImZIT9aw0GZkhpubn4SJsCXkfbULr97ByFuEm0RdWcERcfhdXblp1veupmGI7AV
	 rVBJOzxuKWv+JOA0nQYFi0Ono7+39xeB7rI0OzXShhpLFOV5Z9FlgUvxJ8ixFR8PYu
	 fjoGr12jlJV8fAGnC2WI6pQXKG9wAcZIv3iArWMuSg6Bi6k2nWxMvyRfJepZ7xj8EL
	 j+nzQZK7xa9IvjyFFLUYZsSueJJ0n+1EDrKbSYL5Jo56/YlvmRJtm++62FxuL2IzNP
	 k+HcRzDpOPPTA==
Received: from phl-compute-10.internal (phl-compute-10.internal [10.202.2.50])
	by mailfauth.phl.internal (Postfix) with ESMTP id 7A7C4F40069;
	Sun, 20 Sep 2026 13:48:25 -0400 (EDT)
Received: from phl-imap-15 ([10.202.2.104])
  by phl-compute-10.internal (MEProxy); Sun, 20 Sep 2026 13:48:25 -0400
X-ME-Sender: <xms:aRywauuem5T2upr7vlvQjZgICFRpbqBZbxsOyXSspxqfjPhO1iI7QQ>
    <xme:aRywauSfPD27xD3Gac38sUt2uuQB8AyAg37WqP752p2USlrB-b8mc-cmgTzUNP6kF
    rAHPTnc38QRSmIH9jhN2pJ4WhGisdZ-knW7pdpy0_8USJNkS3WLJX0>
X-ME-Proxy-Cause: dmFkZTGkZjGcwhKmJONeWxojVw+uyJsf2YHF1ah4dWJ2XhE/CgB5CBmonY+Bl70K/kMYdR
    z9Giym1+FkeE/FXTxcb3ubsUdso//8qgdJSV0ZdL1RlCNXXe2gB02TV824gACleP5h5ZKo
    nCbTYEQeqZBPpZ2O1JXXONLA8qxl+BjXNsnHNg0j48xzw9t2hDOHHnK7kslT1Ih8+GBarb
    BlZ8wkGVrlKQmZ7cM5zjy8Ol/H0+ToG8aEjwlUm6H3RNzj+UetITaH2xQdZUMlXjnzOflr
    /7tP6liW3gr4NPyEH2SSOb9eynjB11NcJB4hdSTiFWUqIiza/FWaVsipNRBQyABTy5d5DQ
    hXKcVE4lVOnY+OcaatopZT6yM2SMSC4fxvugewJuXurcD68+9yJOffI0LEO20hMN58koAb
    07COqCr9UrWTAVzn8zcxQ3u3iyDW6e4VAl++FwFHLNCBpToqI/zoeNm5Qnzo7d1H1EO63h
    yj5m8rEiz4Wipiey4U5T+mhOIvIQQtpgrzWXidf1fEMBgxom2cvKdLJWf5r+bTtvkTbGwm
    gvFr/JPmeMxtHXCQPMQf/Nt50nHjtUYUUAcgD3XyX04wa4P5gOQ6ZPOXQJMWrXeYaFmiZH
    WKSUalKot+V+Zcy8N98M/iQ/BELFmvZKIWZP03udXreKlUwJWynJXgsvfdVQ
X-ME-Proxy: <xmx:aRywagFvaYRUvdH4U7YY6r5SI8KXEoMELxXMFCk1EQQloLwNu5nIJg>
    <xmx:aRywaqCXOtzaoq7s3vTbgIYIjI9_MFl1A4Q3Js-iJQvLSQwbXVUIPw>
    <xmx:aRywaoUjYThaDQsZXaP3xNaEdwNFzOh37GXwKG90EfrtPZmkNuh6ug>
    <xmx:aRywamr9Lq485Ax84wyxbNJcscOrAyQJPpXfXG0jYIguI0Ao5Z-pyA>
    <xmx:aRywasR9QV_IoWrGShhm4DJN0fcTTR0WY0AIOHqhGYjEQA1UUNk1nGML>
Feedback-ID: ifa6e4810:Fastmail
Received: by mailuser.phl.internal (Postfix, from userid 501)
	id 5EECB780075; Sun, 20 Sep 2026 13:48:25 -0400 (EDT)
X-Mailer: MessagingEngine.com Webmail Interface
Precedence: bulk
X-Mailing-List: linux-nfs@vger.kernel.org
List-Id: <linux-nfs.vger.kernel.org>
List-Subscribe: <mailto:linux-nfs+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:linux-nfs+unsubscribe@vger.kernel.org>
MIME-Version: 1.0
X-ThreadId: AnM6P3MynuMo
Date: Sun, 20 Sep 2026 13:47:57 -0400
From: "Chuck Lever" <cel@kernel.org>
To: NeilBrown <neil@brown.name>
Cc: "Jeff Layton" <jlayton@kernel.org>,
 "Olga Kornievskaia" <okorniev@redhat.com>, "Dai Ngo" <Dai.Ngo@oracle.com>,
 "Tom Talpey" <tom@talpey.com>, "Rick Macklem" <rmacklem@uoguelph.ca>,
 linux-nfs@vger.kernel.org
Message-Id: <5dccb160-8bf5-4a27-a6ab-3dcb47f87c23@slotpi15m67>
In-Reply-To: <178977244520.207413.3893450376967484226@noble.neil.brown.name>
References: <20260918-duplicate-reply-cache-v5-0-b6aba9ebf2f4@kernel.org>
 <20260918-duplicate-reply-cache-v5-1-b6aba9ebf2f4@kernel.org>
 <178977244520.207413.3893450376967484226@noble.neil.brown.name>
Subject: Re: [PATCH v5 01/11] NFSD: Remove hard cap on duplicate reply cache size
Content-Type: text/plain
Content-Transfer-Encoding: 7bit

On Fri, Sep 18, 2026, at 7:00 PM, NeilBrown wrote:
> This patch looks good and does what it says on the tin....
> But that formula at the end (which the patch doesn't change) looks weird.
>
> As you note in the table above, 8GB on 4K pages results in 92681 target
> cache entries.
> 8GB with 64K pages comes to 370727 cache entries - 4 times as many.
> That doesn't seem justified.
>
> If we made it
>
>     32 * int_sqrt(low_pages << (PAGE_SHIFT-10))
> or even
>     int_sqrt(low_pages << PAGE_SHIFT)
>
> it would be 92681 entries no matter the page size which is what the
> original table says.
>
> Does this need fixing?  Should we fix it now?

I'll add it as a separate patch ahead of the cap removal, using

   int_sqrt(low_pages << PAGE_SHIFT)

The table in the comment then matches on every page size, so the
"with 4 KB pages" qualifier goes away.


-- 
Chuck Lever (Come to NFS bake-a-thon! https://nfsv4bat.org)
