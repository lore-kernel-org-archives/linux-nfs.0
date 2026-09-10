Received: from smtp.kernel.org (aws-us-west-2-korg-mail-alma10-1.taild15c8.ts.net [100.103.45.18])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id E4C5158FD3D
	for <linux-nfs@vger.kernel.org>; Thu, 10 Sep 2026 19:44:07 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=100.103.45.18
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1789069449; cv=none; b=tWH3XFUTxhS5/TK1QmSd/6tRbAj7tJG7L4PrqIuHiL+1iWS9ML8zkWimtj74UWKrAvtC1P3VA2+wkh839baEZjsIQIFTG7ieaOYPFQ4nff7EL8nZLcAvV/0Spl8p2d9sL21jc9TqmT9OULuvIcpg7QysulgFWTE/j7qVXn3Ehxs=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1789069449; c=relaxed/simple;
	bh=NDSmdLHNLWZfPpisRsXI3ev57yKL/qz1yWxAPWKXxb8=;
	h=MIME-Version:Date:From:To:Cc:Message-Id:In-Reply-To:References:
	 Subject:Content-Type; b=uC5FIXk/8x/b5lG9jXHWeCjMcJ9B0Uqb0fWnNsnocDejKx3CFolZWYO02c3xGGKEz5AjK2CruVWx0K7Cx4iXPc9GRHGbiD3sy59iLpaHTKTtDptUaynsEmSJeKK+fpJl69bDQCAxrmX0vDWFIeoWPqpmOJ/Ha9eT4ucONJsyZt8=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.b=Jsk4fAD/; arc=none smtp.client-ip=100.103.45.18
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.b="Jsk4fAD/"
Received: by smtp.kernel.org (Postfix) with ESMTPSA id 253221F00893;
	Thu, 10 Sep 2026 19:44:07 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=kernel.org;
	s=k20260515; t=1789069447;
	bh=ttSVIgdk6jH8bW95abHDSQ4zzL4XFOk8AZIYRLz2bPA=;
	h=Date:From:To:Cc:In-Reply-To:References:Subject;
	b=Jsk4fAD/stluB1otq6yPS0SNLTbCJA2CIqJZtGYg7zwlzgerDQuFvdRC5k/9pogI6
	 Op+gjIm2ap7jFtls92KxzMMX4h66bvSMmMHp07SddWref3JyG7EsVhl/BqkbRfeE0q
	 BL01XzG0qLRqtyzFCynTkhSuzV7TCo5m8RVlaTjrBPa/UTd9md7FUfu5TUYhwqgYUh
	 Lq3HbAonsOOtlosDUF/72Q3LRkF0tK7mQyj9BeEUqKmEGuYJBp9ZgYHAhP6j3f0uOK
	 O+1RZcLt/JsL59F3767CRBkRJPf7YgclstfN637mKvYg2LMHbSKQwvnsm0NoqWju3o
	 iGYnUcCXSjkag==
Received: from phl-compute-10.internal (phl-compute-10.internal [10.202.2.50])
	by mailfauth.phl.internal (Postfix) with ESMTP id 5409CF40066;
	Thu, 10 Sep 2026 15:44:06 -0400 (EDT)
Received: from phl-imap-15 ([10.202.2.104])
  by phl-compute-10.internal (MEProxy); Thu, 10 Sep 2026 15:44:06 -0400
X-ME-Sender: <xms:hgijatKendLiks4omkEsjnbVtgo8EeL0t5PHiSRnAqNLmocqac1yoA>
    <xme:hgijaj8f9KryBBd-Wa3prBy92nayzUYhelSCOwricspCMOg5bfW-mba8zM4qRvrez
    U5YYCpax1-2_n8TdPt1hDacRBqEsZw4KOgIYyVt7UyELf8tetUbXTOF>
X-ME-Proxy-Cause: dmFkZTGl8jAL90lzK/34eQf8aVRvno66hAYp5+OuxVRYrHeZj1EltiDgZxZbX4j9X1xw7k
    SoKl5QPlUS+u8UrRf1KPVt4jdN9AANu828pfpIMkeRllfJ+7HG8/JI8w6brtq194NzYinV
    u5blyXe0ylJHsfEYsXHoaxQgjVKzPJAg49SIu+SCENSCEiPLVFVfNMLVH8aAN7KiDlwCOP
    yKPHMZfJJl70l9hUFhc6YwD1YmIR0xxMCKRf5fjxpDJWyx341zYE4hzg2kGIg9BW+huVLQ
    9+PY7GtVQU83wwyn//1C+rZq14X6lnn8AL14atGkw6lb0xazizBtCtvca5KD6we0iXRZfM
    GmueDg922+WBGaUl7iADNOf+v4OHV0QzqvDQWWC1Usl+BkndA8l8BIN7PEK6OAHC8U79zO
    3YmHSKZWiN4nD4wEqf18qQDnkkl/QYW5f5/YIanHr0CneYb5COkyu6C4A3NRg4j2XbRpCy
    5pJYcEoalPrQiGALxrG5vUXDGi1/dnrH0dQCHXSZmoAN9W3q4B6Wv/owivCIOSXDxZfdcT
    PJeSDnnLzhbUYLYcESavzlWi2yNsEvgdZuL+DDGDGylxCH36TUMDuY8d1VMLQvFFNnhBG+
    pEcI7PWyCCK4Xdsre9NdGKBsHGyKvjYCRjI328qfIzzBUGE16RDQhFCQFCZA
X-ME-Proxy: <xmx:hgijajd6FF1IlyAVes_htyHZEd2DaE7sO4PziFrGBxXbpZ19_rmC_Q>
    <xmx:hgijaqkKVMayF8TgopXoOFOCtfTLxVJ3h72gHUEF9NuBHt7JeH2FUg>
    <xmx:hgijalwf3_A8mcCnPrvwbkn3mKPwx9uNyneXwsZa681UQr8c8DtCcw>
    <xmx:hgijatO487koBTqhmn2KY2r8RXeT7_Qet85bg4ml4BzVXIeTdqOczA>
    <xmx:hgijamhN_ZaxHCung245f-VzSxKMi-XmvHdi1y5irVLyA5PW7HYQsL6e>
Feedback-ID: ifa6e4810:Fastmail
Received: by mailuser.phl.internal (Postfix, from userid 501)
	id 27E987811F0; Thu, 10 Sep 2026 15:44:06 -0400 (EDT)
X-Mailer: MessagingEngine.com Webmail Interface
Precedence: bulk
X-Mailing-List: linux-nfs@vger.kernel.org
List-Id: <linux-nfs.vger.kernel.org>
List-Subscribe: <mailto:linux-nfs+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:linux-nfs+unsubscribe@vger.kernel.org>
MIME-Version: 1.0
X-ThreadId: AU_HLaoPh8kZ
Date: Thu, 10 Sep 2026 15:43:44 -0400
From: "Chuck Lever" <cel@kernel.org>
To: "Jeff Layton" <jlayton@kernel.org>
Cc: "Trond Myklebust" <trondmy@kernel.org>,
 "Anna Schumaker" <anna@kernel.org>, NeilBrown <neil@brown.name>,
 "Olga Kornievskaia" <okorniev@redhat.com>, "Dai Ngo" <Dai.Ngo@oracle.com>,
 "Tom Talpey" <tom@talpey.com>, "David S. Miller" <davem@davemloft.net>,
 "Eric Dumazet" <edumazet@google.com>, "Jakub Kicinski" <kuba@kernel.org>,
 "Paolo Abeni" <pabeni@redhat.com>, "Simon Horman" <horms@kernel.org>,
 "Donald Hunter" <donald.hunter@gmail.com>, "Shuah Khan" <shuah@kernel.org>,
 linux-nfs@vger.kernel.org, linux-kernel@vger.kernel.org,
 netdev@vger.kernel.org, linux-kselftest@vger.kernel.org
Message-Id: <73066b7b-119a-47f4-9ca1-2f2432c3c6a3@slotpi15m67>
In-Reply-To: <20260910-nfsd-norpcb-v1-2-b4d5182d634c@kernel.org>
References: <20260910-nfsd-norpcb-v1-0-b4d5182d634c@kernel.org>
 <20260910-nfsd-norpcb-v1-2-b4d5182d634c@kernel.org>
Subject: Re: [PATCH 2/5] NFSD: add a userspace-rpcbind flag to listener_set
Content-Type: text/plain
Content-Transfer-Encoding: 7bit

On Thu, 10 Sep 2026, Jeff Layton wrote:
> Describe the interface that lets a caller take over rpcbind registration.

> --- a/Documentation/netlink/specs/nfsd.yaml
> +++ b/Documentation/netlink/specs/nfsd.yaml
> @@ -483,13 +527,22 @@ operations:
>      -
>        name: listener-set
> -      doc: set nfs running sockets
> +      doc: >-
> +        set nfs running sockets. A request that carries userspace-rpcbind
> +        is answered with a reply rather than a bare ack, and the addr list
> +        in that reply names only the listeners that have an rpcbind netid.

"listeners that have an rpcbind netid" overstates the set. RDMA
listeners have netids (rdma, rdma6) but are omitted from the
reply.

Following the way Solaris handles RDMA transport, NFSD never
registered RDMA itself, so that is not a regression, but the doc
should say what your filter actually selects.


>        attribute-set: server-sock
>        flags: [admin-perm]
>        do:
>          request:
>            attributes:
>              - addr
> +            - userspace-rpcbind
> +        reply:
> +          attributes:
> +            - addr
> +            - userspace-rpcbind
> +            - rpcbind

The spec declares an unconditional reply, but patch 4 sends one only
when the request carried userspace-rpcbind. ynl has no way to express
a conditional reply, and no other in-tree spec does this.

Either always send the reply (drop the userspace_rpcbind gate in
patch 4, so a plain caller simply ignores it), or leave listener-set
without a reply and put the registration data in a separate get
operation. I lean toward always replying; that's is a little more
"declarative".


-- 
Chuck Lever (Come to NFS bake-a-thon! https://nfsv4bat.org)
