Received: from smtp.kernel.org (aws-us-west-2-korg-mail-alma10-1.taild15c8.ts.net [100.103.45.18])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id DC4B039795B
	for <linux-nfs@vger.kernel.org>; Mon, 31 Aug 2026 21:13:56 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=100.103.45.18
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1788210838; cv=none; b=ZPm5zdwe55GW+n5V9ACePvdz8vrfslE0UJIglVlH3Xy2oYOeal4GO0H3p7ZyYa/j0QoJqDO3MD4bk/B1RTI27W+ypGpv3ljDGm3Uv+M0wokhuLSD2GvCIHpUIpPSIWMw2NyQIMkxI8pO/TsB9Gy5/D+R9QwLV6n8n6Puo6HogZY=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1788210838; c=relaxed/simple;
	bh=3Mu0ZS/vdmoAIfpl1jI0jJw23lmPVLfN11LqPzPs69w=;
	h=MIME-Version:Date:From:To:Cc:Message-Id:In-Reply-To:References:
	 Subject:Content-Type; b=nHcuN6LsYQUVlwQF2AcsM1JRVDE5Mx++NEVQuIuqL/JUdwOrjZmbi3UKoFPh1SfFo1vv1SGHX7AuHPVPBRfmb/ADd/8UA7oNSZK7+GPENN7jXMQu/Us6QYI5WWSOQmCAkgOa/8oLfaGxYYX4Jb1HBGy9/nwT366zHbTLAUPp+dU=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.b=fU7Lneap; arc=none smtp.client-ip=100.103.45.18
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.b="fU7Lneap"
Received: by smtp.kernel.org (Postfix) with ESMTPSA id 6C75B1F00A3E;
	Mon, 31 Aug 2026 21:13:56 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=kernel.org;
	s=k20260515; t=1788210836;
	bh=3Mu0ZS/vdmoAIfpl1jI0jJw23lmPVLfN11LqPzPs69w=;
	h=Date:From:To:Cc:In-Reply-To:References:Subject;
	b=fU7Lneap6MDtCyzTOvv/+vlcX62T/D9aE/P8k1ewQOVVAb0UYyCHJkU5GAgI7W3cf
	 2tIqcOjuPdS29Bi6hvz79QGtrIcTPjh/0FGXdMzsbXOggnw4AuFKG8cnWbTTzt77Wo
	 Cs2uY6CFZw4UVxhT+pn3CiRAi3pi3WFFTJT8KioC9y/M/kupbH3BXXGsCFiZI/Cpa1
	 THaRfC0ujw791OYq6Tv1DFb9UNG1OthflawmaTxUciLW99BvnXgVjG+y9RzV9O9R45
	 Uvp6K/Ia6Dkm+WhgNeiaYAV7vvNENGyi3rFjpLnYLP2JHk001FSHlUeL4VhAjJ+BuI
	 QQoRxeSqtdMKA==
Received: from phl-compute-10.internal (phl-compute-10.internal [10.202.2.50])
	by mailfauth.phl.internal (Postfix) with ESMTP id 84F2BF4006A;
	Mon, 31 Aug 2026 17:13:55 -0400 (EDT)
Received: from phl-imap-15 ([10.202.2.104])
  by phl-compute-10.internal (MEProxy); Mon, 31 Aug 2026 17:13:55 -0400
X-ME-Sender: <xms:k-6VamjzKOLJQE_M9R7QTMa-0y7xWAYZI15u1gOD2IFPgF2fF2IsOA>
    <xme:k-6Vah3njYWbvAAeJusA_4odXB4tpHMLFlJ5RmMHp5cg9w4UAOB1074RWkejJRrx6
    Bn70F-psCKId-0-WThCP7xJm5WBlR5XNCeidwUbqhWdgn0aAtf9fWwO>
X-ME-Proxy-Cause: dmFkZTFhJHBwoqF6Ryog7cXyYQ6B2v65uQyFAzCHs//3DUY/IDp7QkGcrIjlH48GWdNMLu
    wblIj0vTy7kglkLjiIgb8JvDwPw7LD+ylm2c9bxEb014W7t4dpVVE99B/pyV5amwN0ubNg
    3BKeYti9IcRF+UzOHxf9Gtn/r70G883GsNHu3qcVScrZ64udUg8HmGRI1oJhoL9hFJCSu2
    hoR7uwPYtVTRWEK6mtGCPmrg4vDwNmv9bWKGhfMboOWxsoYJ2yEgQ3WJI20p0AZ3BSeB+G
    fWpUfmUwsEMCFvDAK7SQqfILWw648Josmes8uK0nGeD7oKeUbabSuSZISPP1XwQD1u57tp
    LiBbpq+FM2QUvudBziC25XOw3h9yAuMSHoEfuCSa8tMG2MozNNDPyJhWp8w5S2b2Rz4Pk8
    VISmsmPybZrNV29DzD4LN3c/UWSuAP6QuZB+Fx9nZXhBfN6M9Pxn71e6uKT1UA3UFJynrW
    AY8VZXumFTIC0QuXkhfc1t4Ubtc5sbbtk+cikPjSMJGJFV0YTBJWsPGicnbM6WHOfxbrAW
    K471SmEnpmXNDZnaTbq0mHXXOnpep046K55lZel6SLnMChTOXa064ePQuNXOpmQf/ch0xQ
    jMptL0Cc74tyxTA9bFR0iFhkxNvn3CySYQza6oE+KVSH1wHVYbwJVAdDBWsg
X-ME-Proxy: <xmx:k-6VaiC_lIAr4FrWx5T5LQfG_D1fI9W_6FcXcnUZj7qfqiIuNINfjA>
    <xmx:k-6VavkhAYWdlA8-0HGfg2Yv_zxPOGUABqpEY5UqMxOh24OF6vCfMw>
    <xmx:k-6VagMFq0E3EzO6AhEcQLRlHR5qvD2XW5zO8dnN8ofUASyEoENHZg>
    <xmx:k-6Vas9LGK7l-4sp5i_bm253vPpYcFMLpFn8WG4IIlPGysI0Do8W4A>
    <xmx:k-6VaiGqCO1tmBwQZHDMZKgIcM0BTgUQpJnSYImSC0ov_Mo6EuU4_-7h>
Feedback-ID: ifa6e4810:Fastmail
Received: by mailuser.phl.internal (Postfix, from userid 501)
	id 67EDC7811F0; Mon, 31 Aug 2026 17:13:55 -0400 (EDT)
X-Mailer: MessagingEngine.com Webmail Interface
Precedence: bulk
X-Mailing-List: linux-nfs@vger.kernel.org
List-Id: <linux-nfs.vger.kernel.org>
List-Subscribe: <mailto:linux-nfs+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:linux-nfs+unsubscribe@vger.kernel.org>
MIME-Version: 1.0
Date: Mon, 31 Aug 2026 17:13:34 -0400
From: "Chuck Lever" <cel@kernel.org>
To: manjunath.b.patil@oracle.com, "Petr Vorel" <pvorel@suse.cz>
Cc: "Dai Ngo" <Dai.Ngo@oracle.com>, "Anna Schumaker" <anna@kernel.org>,
 "Jeff Layton" <jlayton@kernel.org>, linux-nfs@vger.kernel.org,
 NeilBrown <neil@brown.name>, "Olga Kornievskaia" <okorniev@redhat.com>,
 "Tom Talpey" <tom@talpey.com>, "Trond Myklebust" <trondmy@kernel.org>
Message-Id: <37e366a9-3ad9-41bd-93ab-e264e95ad596@app.fastmail.com>
In-Reply-To: <2d9dc79f-1d98-4a6d-9dbf-201fc8a90828@oracle.com>
References: <20260819173055.1956882-1-manjunath.b.patil@oracle.com>
 <20260820111303.455807-1-pvorel@suse.cz>
 <8e43238e-f06d-4da1-a898-2bdc1d827e81@oracle.com>
 <20260820185922.GA511595@pevik>
 <2d9dc79f-1d98-4a6d-9dbf-201fc8a90828@oracle.com>
Subject: Re: [PATCH] SUNRPC: add transport details to timeout diagnostics
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: quoted-printable



On Mon, Aug 31, 2026, at 3:33 PM, manjunath.b.patil@oracle.com wrote:

> I also noticed that the Patchwork event shows the patch as "Not Applic=
able":
>
> https://patchwork.kernel.org/api/1.2/events/?patch=3D14757794
>
> Could you clarify what that means for this submission?

The kernel patchwork service applies only to NFSD. Your patch is for
the Linux NFS client, so it=E2=80=99s =E2=80=9CNot Applicable=E2=80=9D t=
o NFSD. The NFS
client maintainers need to respond to your review request.
