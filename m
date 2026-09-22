Received: from smtp.kernel.org (aws-us-west-2-korg-mail-alma10-1.taild15c8.ts.net [100.103.45.18])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 0EA6854280D
	for <linux-nfs@vger.kernel.org>; Tue, 22 Sep 2026 14:06:40 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=100.103.45.18
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1790086003; cv=none; b=Q9zCmthnO+CVHy7yroSjVplVgRxMjIMkQAdQCgAPBVFtRvvg3VDDI8G9a2VQIWZ/5ZP6SHPsW7k+3BUfjKBOMOSdCVG1sCpPqlW9ttZYKhqLvdNQKyWb3+APbFzISaA6WGw/p3qde3IkbWuXWZ0BXXwJBi4W1mOVliyVUz8yX+o=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1790086003; c=relaxed/simple;
	bh=8YT7zCTEOtTi+DhThW3Q2EI4+sV3BD+6ovKn3PFEKsM=;
	h=MIME-Version:Date:From:To:Cc:Message-Id:In-Reply-To:References:
	 Subject:Content-Type; b=htLqakg+fSv85GY0+VFJXg9Na0wDCSNyq1h/lrGvm8huSGYKlorECesyQZ3tXfqrCdX658AOHh+O4HqQiteaX5RzuwMK8QC2gqZFLSHW/Yx+9QJi9G7QcBHtz33o7j/pEXLYXWhHV1DWUv0RTPSOHKTkFDaC8ZjNRriAtsSt6IA=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.b=GtdqFT2/; arc=none smtp.client-ip=100.103.45.18
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.b="GtdqFT2/"
Received: by smtp.kernel.org (Postfix) with ESMTPSA id 6B0651F000FF;
	Tue, 22 Sep 2026 14:06:40 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=kernel.org;
	s=k20260515; t=1790086000;
	bh=L//P5NyOuHR1Jrk9NeNBtxDdceW2fcOYPJ4vvra3O+o=;
	h=Date:From:To:Cc:In-Reply-To:References:Subject;
	b=GtdqFT2/zw30B2Q2Ul14yhkeTcdg4jIzh5ovaw2xMPbdPmJ/W3aFiLXLATevDCCiK
	 WNaznQr7psEdEbX53GAJXR2iqlmPzzNeDJoh85xPSSfmMak5HNDmvSxcSlU1S9Qaxn
	 EaTre23Qrw6hFDEnDEsT04kaUpMsQAkYJKYTweYlmZatdrCfsNuKul34CyOPHDT9/P
	 iYBbb1BiOjz4ZJ24ejy3N6tHjCTw5Xbl1Ll/GZF1Esp3/I4XUGfGg/h9m++852BS5c
	 Dq2e8JupGtLz+kIt9rc6DABIQbTCTP/nNzgz7abLa703crVeEqFrSil3HUMb/KkyDz
	 JOrAFRFsYi2zg==
Received: from phl-compute-10.internal (phl-compute-10.internal [10.202.2.50])
	by mailfauth.phl.internal (Postfix) with ESMTP id 3CCF7F40068;
	Tue, 22 Sep 2026 10:06:39 -0400 (EDT)
Received: from phl-imap-15 ([10.202.2.104])
  by phl-compute-10.internal (MEProxy); Tue, 22 Sep 2026 10:06:39 -0400
X-ME-Sender: <xms:b4uyapW-vT9BiWbzHHcbEpzKuNDKnEGNMWt4oPwAQCXcyb6C6M8x4g>
    <xme:b4uyakbX7l_7sfNG8qI46yZQ4qNOzingX8sETZ6HO4Bqn6ifbi3h_Vi8LsW-Gphj5
    HCT8HQtpkpVQZsnt7Hxucc4SvH-vtUictTuyQo0JrhS4xs3-d9F7s3D>
X-ME-Proxy-Cause: dmFkZTGrdFg+p1NEcMQqgNPzVSTWrwg0fiEELVFhhoBp2f+DUziSJk1MdsO4OypE12VT1Q
    DseutIxhZfb8rcnKiPI7dBbYC5OAekK7MnaejmiXbzYmA841FT60o4jPM7co0LcE8Dcali
    4+1n2GIEHGotrN9dAE3kBO9shwLsK9BaFcRF8mOoDSM7T4FbJQ5JzPQ33zOAHFXSBJORuj
    UcZXsPPLkxUTcktsbSrXg1b67bl+/q7V/UxTfiMYPT1vzUGM1lSwBcGjVlcU6Nn/D/eu0J
    h0CILJAPSEX/D8Ang29e52FrREU7+0pD79mGl6PISHgE5TzJlHfn/7BfLwCsu35TQCZBpM
    v63P54tsWi7BIH08ADpzFATQ/Yq4AVvSOJamWu7lXiO2VQxXHIFj5Ok7qXj6ik9kGSvFP+
    W4VYueg0hA4X8gj2haD3/HqWAO121JpvC30J4S2CXELTIAdLsiWpqR8pWlydeORlhKpbbh
    znWU4Gk2VflSJqPmA5g5DuemC6dl+9jmYsumYsU0JmrcJcDRV2PMPsM07NwjnQ0LEL2ttb
    qlWSOG6gLfFs5JSWET+QyZuL9qKwFeiE1zIgzhaM6q9UdO2NKxOkEzxOOTYZkifuTGxeJj
    THIIsANAj0SHEebejcvq8ioCGGYlpItn3LK/op0p5n6y/ENDuK6Jv775CUeQ
X-ME-Proxy: <xmx:b4uyatxK71TEC9QeIW6FAt4SWR2Up86zzADpN9V7nO3_3HCyAFJjzw>
    <xmx:b4uyaseiv8FNjyvTjzDsBUP3lNnE_BJtQM4t7-m2twu48aiZ7QvhoQ>
    <xmx:b4uyaqCDfAl7kZ0GU0KZ1LAW8EuyE4zf69c51_J3kvmamoSCSyJyVA>
    <xmx:b4uyao4EF8iEG6sWvNijjNDCySqm37oOGCakuGn3IfKm320tMZwgGw>
    <xmx:b4uyarfBemmT6PaP2DuWrkHPHQAMb-DVwOifGyjeHEIEpSL2419pJb-5>
Feedback-ID: ifa6e4810:Fastmail
Received: by mailuser.phl.internal (Postfix, from userid 501)
	id 1406E780070; Tue, 22 Sep 2026 10:06:39 -0400 (EDT)
X-Mailer: MessagingEngine.com Webmail Interface
Precedence: bulk
X-Mailing-List: linux-nfs@vger.kernel.org
List-Id: <linux-nfs.vger.kernel.org>
List-Subscribe: <mailto:linux-nfs+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:linux-nfs+unsubscribe@vger.kernel.org>
MIME-Version: 1.0
X-ThreadId: AVt1c__qMuMw
Date: Tue, 22 Sep 2026 10:06:08 -0400
From: "Chuck Lever" <cel@kernel.org>
To: "Mayank Jangid (OpenSec Intelligence)" <mayank.jangid.moon@gmail.com>
Cc: jlayton@kernel.org, neil@brown.name, okorniev@redhat.com,
 Dai.Ngo@oracle.com, tom@talpey.com, linux-nfs@vger.kernel.org,
 linux-kernel@vger.kernel.org, security@kernel.org,
 "Kushal Khemka" <kushalkhemka559@gmail.com>,
 "Kkartik Aggarwal" <aggarwalkkartik@gmail.com>
Message-Id: <29830200-dcb0-452f-9e19-80a595b46fe7@slotpi15m67>
In-Reply-To: <20260922112608.1256363-1-mayank.jangid.moon@gmail.com>
References: <20260922112608.1256363-1-mayank.jangid.moon@gmail.com>
Subject: Re: [PATCH] nfsd: prevent NFSv4.1 SEQUENCE reply-cache overflow
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: quoted-printable

On 9/22/26 7:26 AM, Mayank Jangid (OpenSec Intelligence) wrote:
> nfsd4_sequence() narrows the reply buffer to the session cached-respon=
se
> limit before accepting the slot sequence ID. A client can negotiate
> ca_maxresponsesize_cached down to NFSD_MIN_HDR_SEQ_SZ, leaving no stor=
age
> in the slot trailing sl_data[] array.

Thanks for the report and the patch. J=C3=A9r=C3=A9my Jean reported the =
same
issue in August, and a fix for it is already queued in the nfsd-testing
branch:

  https://lore.kernel.org/linux-nfs/20260817-jean-v1-0-9e356596ab85@kern=
el.org/

Patch 1/2 there adds the same pre-flight check of the SEQUENCE reply
size before nfsd4_sequence() narrows the buffer and accepts the slot,
and patch 2/2 sets op->status when an operation header cannot be
encoded. Your patch does the same two things, so I won't apply it on
top of that series.

If you can test the queued fix against your reproducer and confirm it
addresses the overflow you found, a Tested-by: on that thread would be
welcome.

--=20
Chuck Lever (Come to NFS bake-a-thon! https://nfsv4bat.org)
