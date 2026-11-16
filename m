Authentication-Results: smtp.subspace.kernel.org; arc=pass header.oldest-pass=0 smtp.remote-ip=85.215.255.25
ARC-Seal: i=2; d=subspace.kernel.org; s=arc20261015; a=rsa-sha256; cv=pass;
	t=1794833020;
	b=iQFDAWHp4KGOGE3j7msZ9kvHrwFvrC1fFmt+pPHFlc+GE1vlofqeotVXx4QG1+QpipF8
	 XGhWALHpm1pOunOJF6sE7vylTo2WCob1fIMEXTTXtLco97ZExMNn6f9Q822tWj9HwzFbE
	 Tz6KRQjDytFHWhkzV+xRSxa7hhaIfXdUIZopMdOYwy6zD0ZSuxRBsUC0NthG2mIs2FL7f
	 lx+pl3scX8XeEHyAE2E6iKdfPKqVJqHZU2/A5RsVaOjBPSqnhm5sDS6IJxhR+axn7351K
	 mhqgpkAn8LXDcEXmEPqJc8icgz06k93/TTP0rlmkOcESx8pBjid/RxbtwfgOTUPZwkg==
ARC-Message-Signature: i=2; d=subspace.kernel.org; s=arc20261015;
	a=rsa-sha256; c=relaxed/relaxed; t=1794833020;
	h=DMARC-Filter:X-RZG-CLASS-ID:DKIM-Signature:DKIM-Signature:X-RZG-AUTH:
	 Received:Received:Message-ID:Date:MIME-Version:User-Agent:
	 Content-Language:To:Cc:From:Subject:Autocrypt:Content-Type:
	 Content-Transfer-Encoding;
	bh=rP6i96EuKAu2OHvzCFEJt5PO096jDPgjmWWJsNCSW5Q=;
	b=0H18Plgpxv505pBwi0kvSRpUcaCFRFViIaez56fw6wJAJR6qo+ZMVZgPQgwyQjm9xP9L
	 a7owvGqomPasawBk5Swo8gA+afbo+1MV8Iq8HH3ZeYPZKgglSV9kfMT5tqs3vZW1Fgjtq
	 Rg0DIv1lTOEIAw0PpNPtN5Py/qsJJ3yhiq+1h3K0h6q8XDOk5d5iYKR/FsoEbtSwNNbsb
	 kJ8W2cnSRu9PK63jfuXDURIq57UMEFCQosdSZkQz5+IEGnwbb4aFK1FGKVogHHHFUXQun
	 4J2EqHesejgi83K9zc0AHiu+iNgMt4HgvKY4WbJKdh+MTKrNFvqVqYD7PX2nEY2i1sQ==
ARC-Authentication-Results: i=2; smtp.subspace.kernel.org; 
	dmarc=pass header.from=garloff.de;
	spf=none smtp.mailfrom=garloff.de;
	dkim=pass header.d=garloff.de header.i=@garloff.de header.a=rsa-sha256 header.s=strato-dkim-0002 header.b=K6UFnV1Y;
	dkim=pass header.d=garloff.de header.i=@garloff.de header.a=ed25519-sha256 header.s=strato-dkim-0003 header.b="PD6p/kUr";
	arc=pass header.oldest-pass=0 smtp.remote-ip=85.215.255.25
Received: from mo4-p00-ob.smtp.rzone.de (mo4-p00-ob.smtp.rzone.de [85.215.255.25])
	(using TLSv1.3 with cipher TLS_AES_256_GCM_SHA384 (256/256 bits)
	 key-exchange X25519 server-signature ECDSA (prime256v1) server-digest SHA256)
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id C25E1606A32A;
	Mon, 16 Nov 2026 12:43:38 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.4.2 smtp.subspace.kernel.org C25E1606A32A
Authentication-Results: smtp.subspace.kernel.org; dmarc=pass (p=reject dis=none) header.from=garloff.de
Authentication-Results: smtp.subspace.kernel.org; spf=none smtp.mailfrom=garloff.de
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key, unprotected) header.d=garloff.de header.i=@garloff.de header.a=rsa-sha256 header.s=strato-dkim-0002 header.b=K6UFnV1Y;
	dkim=pass header.d=garloff.de header.i=@garloff.de header.a=ed25519-sha256 header.s=strato-dkim-0003 header.b=PD6p/kUr
ARC-Seal: i=1; a=rsa-sha256; t=1794833011; cv=none;
    d=strato.com; s=strato-dkim-0002;
    b=mhbPuL1Vs/EocHO9MK/CVVFXofUtA/Qm7Px2ZxcaopN1focCvHE9rliRFLTS2O1Czg
    6JgAgK3N7Dqbbe8Qv64e2x2IN8ibALK/BwHDUv9DQRf66dpQjOhJRNnLLGmgK82KGijX
    DCiZYvjSMxzRVTyOc2KuJqvdhiK3VHIK/r4UPgZ5cf2ZXOktFTgkFH65luJeCkvSDD+q
    cays8bJZKnDrk4vnXbIIxcPtyogaiePC3g2qN6yvSx+SiENOLRQ3O9M9WBVvTLAdeQzA
    NgMVdrihSAgvl00IpzP6kfjwb2BgQe3zVitAlBhJ+YCfq4Qs1L5h5mt+7YTvXueJeC4D
    u2ug==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; t=1794833011;
    s=strato-dkim-0002; d=strato.com;
    h=Subject:From:Cc:To:Date:Message-ID:Cc:Date:From:Subject:Sender;
    bh=rP6i96EuKAu2OHvzCFEJt5PO096jDPgjmWWJsNCSW5Q=;
    b=p1onapQJtbPfJTFcSMOEPbY0RfnNhIEKqKSVCNL6E6fu++GEzWNCxaZftYBcIEzm/v
    WwmglzruN5iikP7wByAycpUYjFYp8AAdiXpMKU/nydiBnxS0jgBlk3mkxP/Qbp+uAVtW
    uunmufFYdkDlfL8VVbegS/6L1hkx8BI/Ht8fpqY0mKSbMpuLX3OCslWZaisXQFKkiKT5
    Y5cGIxBS38tTmyDsTf5KFbowFbq7+u2XLvmSiuKeqWEnCVuMM8d0njucdZHN8Iyvs0Vx
    ZuV+p8MVwZ6VHGxCgvfubP9Q58D4BH8m/icdpPLu3pQ2Et/BFLQQLATFPRNCrQ79sihi
    iE5A==
ARC-Authentication-Results: i=1; strato.com;
    arc=none;
    dkim=none
X-RZG-CLASS-ID: mo00
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; t=1794833011;
    s=strato-dkim-0002; d=garloff.de;
    h=Subject:From:Cc:To:Date:Message-ID:Cc:Date:From:Subject:Sender;
    bh=rP6i96EuKAu2OHvzCFEJt5PO096jDPgjmWWJsNCSW5Q=;
    b=K6UFnV1Yhm/sqedQHK/QKDcX7+zN6xj2HKdH/WMQdMcFKbXbD9trhz0Mq+oRBJcBYs
    kfjccFrBYf7bw7hTptRc34US9j0dLvOiMZlfOzFEAyXyBz+OWY4MEMgTRdlPXhqKnzVY
    lYc0ZYygR+ld4Vcj/0uxMZK2llQKR6WOGLyy2hAl/IIBpv9R9CnT7ifgGaQJ2HB0U0w8
    RCftixBY8AZya5GTHkPF2gfNfNdATc5FOt8KvoBwTqz9oAdvh5viTu72torWtd9DufwB
    utMWqjsgBATlYZUE9FbfEWcpvnEwyHIMtzsEcTJyAtefr1tS7GYyGJPihDJJgN/CUb/k
    mRbw==
DKIM-Signature: v=1; a=ed25519-sha256; c=relaxed/relaxed; t=1794833011;
    s=strato-dkim-0003; d=garloff.de;
    h=Subject:From:Cc:To:Date:Message-ID:Cc:Date:From:Subject:Sender;
    bh=rP6i96EuKAu2OHvzCFEJt5PO096jDPgjmWWJsNCSW5Q=;
    b=PD6p/kUrTYHaLDYuWAan79Tl9lrk6uTXfHCEHnCuQdPkGfTn90h/+l48SiYDLkJpqr
    TrBeIeFV+7NcU9fbaACg==
X-RZG-AUTH: ":J3kWYWCveu3U88BfwGxYwcN+YZ41GOdzUdLW+J8VEEt2hpSnX3ozh1rmPvw="
Received: from mail.garloff.de
    by smtp.strato.de (RZmta 55.6.3 DYNA|AUTH)
    with ESMTPSA id L82ab22AGChUEBW
	(using TLSv1.3 with cipher TLS_AES_256_GCM_SHA384 (256 bits))
	(Client did not present a certificate);
    Mon, 16 Nov 2026 13:43:30 +0100 (CET)
Received: from [192.168.155.137] (ap5.garloff.de [192.168.155.10])
	by mail.garloff.de (Postfix) with ESMTPSA id 6862F60AA5;
	Mon, 16 Nov 2026 13:43:30 +0100 (CET)
Message-ID: <35138d17-c7ed-4705-b66c-8c84f44525ac@garloff.de>
Date: Mon, 16 Nov 2026 13:43:27 +0100
X-Mailing-List: linux-nfs@vger.kernel.org
List-Id: <linux-nfs.vger.kernel.org>
List-Post: <mailto:linux-nfs@vger.kernel.org>
List-Help: <mailto:linux-nfs+help@vger.kernel.org>
List-Subscribe: <mailto:linux-nfs+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:linux-nfs+unsubscribe@vger.kernel.org>
List-Owner: <mailto:linux-nfs+owner@vger.kernel.org>
Precedence: list
MIME-Version: 1.0
User-Agent: Mozilla Thunderbird
Content-Language: en-US
To: Jeff Layton <jlayton@kernel.org>
Cc: linux-fsdevel@vger.kernel.org, Chuck Lever <cel@kernel.org>,
 Neil Brown <neil@brown.name>, Jan Kara <jack@suse.cz>,
 linux-nfs@vger.kernel.org
From: Kurt Garloff <kurt@garloff.de>
Subject: Re: [PATCH v3 0/3] fs/nfsd: accept a backdated timestamp from a
 delegation holder
Autocrypt: addr=kurt@garloff.de; keydata=
 xsFNBFPOcbQBEACwCji59LkgneDQbfcGS3EZW+Ez35y30Bpq3GJPHf9/nq8D7Q8LhjIvHOd9
 ky/FFNr8dx7f6lRqQUrcaeA7dasJwJjLBzkKEVKnZwHS3ytsi0lzlc+UcxdePYBsvT7mx1dD
 aCaibPkqUHxYSpRfPQXxaWT11CMmYuAKDdUdnuXl/b7Z5X+xQofiYjwOxMXCz4EgrfLq41/G
 Y1sAyNxdZexz2cjTWKImO/vCBPe84tt6lJR3fwanLSNJCgZv5jYLelLQVr/Las4gIoqAyIg7
 X/mbkzMeaAMMJwCJo9buo4d6LTQ6vV1KzCKZxzlLUzzxyDRxfB6yHsGVBtaCHqbWQIXIijUD
 x8I7uHN7ZS1fHnunKJ3raZbcIEQ5g2Y5i8fkKNGzdKIQOS75VvDaBExEpNIhSWXvDHyrj7nq
 f2fJGJqy0ZYuoLJhnD0X99LrrHjR6sJIVGm3SWfESckPAFexM7U8rZmZxkN3MmE6rHJJya0y
 TDb4oeMO1+swokQ1CKbl+robI6X5Um4nWh2K+28CJBU0BMjbhDsUh8KWwuCsUUbHezS5SPm+
 9b5Bjudozgjnjb2GjGS4ZSJST08VkaibdN/KfIYnPt2qlYHk4qEcoN7uySnztRa/ZpgkjeGp
 Bp0qivLb0ZFq0eDb/m2odCHW0KTbI+WFg6VAuXO94hVfM+NHMwARAQABzR5LdXJ0IEdhcmxv
 ZmYgPGt1cnRAZ2FybG9mZi5kZT7CwZcEEwEKAEECGwMFCwkIBwMFFQoJCAsFFgIDAQACHgEC
 F4ACGQEWIQRmafc0DTHpXsVWVJDeTxs6K//FvwUCao2AzgUJHGM5LAAKCRDeTxs6K//Fv0xP
 D/9EllXqipsSfWFrE3/x2E/zhVgDwWyAmiFA8twwISNq+R+G17gycK5cj3kykzG0ygeJ6MuF
 ojLrWGTlbblwOIr5Yx0Enr9VzJxMQUmrglDOoSxi/SzRCgcV3VSQ9Bi26MDt2SL2IyqjBByX
 L9Vo7VaSN4FZAO1CsDjtnpoEhSpKWT1Ub2YHbFf0W+K4ONpT+v+ubrg/PbWDPblNSOR2ubf3
 IMcYo+dpnmKN9+ONqtqXb+X4uuIqAekUNIRcbSK81S6pQV2cQEY6sQdz/U7JFnnC785H7E8i
 G4ZYE2OpjX03s8bl0o4MKBKfjqHFlXEkdcvSb1hE6VNmWDWpwwx3lCB1vOlwFhFsGdGkRY/8
 brr5eI0037iVfCOsGkaepoJN8ABPjamK+ee2c7o3LoRlRopXkzt7iq6I7j4daYD1XbcOVPCq
 zIPBj7qIkpOg7ZQgSNTehxnm38Q+qO4ezQEpRJ0zYpdRKS6r5Q/7C3obfU5orIcqkB5QCiwO
 ELFCI6+NjeNFNyWzk4PXd/+AwCsKhKy1tv0k8a8dRZsrcE2WoRBw+SE6O2BIwLGWlGvkkp28
 lZB//D1MV5aJPFViR+d5f1+Mj8uAOADSF/6rJolMx49DBwDDQDqkOJ8Pt9UkLA7rdT8uPEt8
 bFbHHs9rcgYuIgu6xeAUwTi/CZkPpjJJfCkIAM7BTQRTznG0ARAAun+5wyqvP6Fe1KkE8cAl
 z6pPAvscC5fxP8QZqrYcQgy1tcCiSyWuTcf1Zbb62JEdfgVrH908lirUjkinkpGMq0sN82Qv
 JD+41vF+OFnUbLDqb02pKIt0y8jhVOYT86Aa3Q3F7eql/mVQA1UJVbF/7Jc+nmyau18bzOFr
 /CNpnJ8x6ZZs8fgiZGalVmPGcj1+L5DwiuJxvr/xCMY3+WEiDjqTgEQ8EPOxaG/DRokWIci+
 AdKslT6kA+JAlKiBF4agg3nCokVCVGIbw/egyivla+/BBq/FaS958hhPanUFq/tCNPbDVB2g
 T5J7/N2j6rLYnBmc+XO5lCQypwAU8waJ4+BJRjuYmD7aXsBOgn0dX/fN8OpVIEyH6hfHSCkT
 a6ltNBs3QMPmZi1JHI0dGeWSZ6Wb1Tw33fQzzAyEAZm43NH0YTZGCS/9+xgH7WFl2fHtQXza
 MzGvcBRpbxYnQGZlupkXZICgGHguDi9Z54iZ3gXV8r84kdRlhmkiE+6QjQMi4tzBxBdRcIV2
 dpX6Xp3Mzaqp6Blz3DBEtFk9mrvXgt+BNsxHc8xtR86imzXAHjAcDf41XcJvZvI6lGYrgREt
 XzkxYB9EAaC3kYv2ZDeq10eNBv7ZYLFoCcrHMC1XnI0IkM/zgEzvN+1T+zPI4DtoZ98isveA
 pohKA69o7HmVo/UAEQEAAcLBfAQYAQoAJgIbDBYhBGZp9zQNMelexVZUkN5PGzor/8W/BQJq
 jYDOBQkcYzksAAoJEN5PGzor/8W/CBIP+wU3jNOU+oMCZmuLLLDavdENikn1+V1mrB+uBVpY
 MBqXK2kju28DgBOmK4t5dYAzj1MlLtgmpZLYhw6rEJw/nKhmWIFdOYT1OB61Jg0kakimfCz7
 6jvsjFQu7gWvbFczUmfzxtgLPwmhjFhlc7RSaBRajH/xGrfe5Net1TAFs4Vaaxk5ZvVyk5Pv
 ORZlHqOwrZBMHDI1h99c7LoUAHYRBqWz+dOI28cPWlZxvQJABWiOmX4zrwluyYvtaVFl8qtT
 ngOqxNyUftyKqkbWxBF9YZLLYdCYcqhSkQ0fq5u+zJ287dYxCvjAUTwdcJuRSTf6ktyhdmVZ
 pCJlbf6Vgzusu3xxGNG2lE91iWWWfiryxljtt0SBlDZSOXKcH8nspWsedRddd4J6XY64iC8x
 ACkldRdUOy97SlzY/FlyBq5uY/olykkxthQGLoRHfgpWBslxAj0ylabR76PK9JZ0DVJTTiH8
 hXgBFPrYaCrTcLG+r1/XdQxYM9mxOeDkMqQp5vP8InaonjeAyA6jbjCyVbGsGNDEgM2P2kYr
 1ToMdg29hUYlxQfRezUe0SjPgyKT2g0EmoxQ0JHya08v4pQgdLi95Gh/hzTDj39JwPq0hvzL
 2e7GAR1JDSySO5NS0UhZJjmMD/Hzly6DQiQThLqYrevdxsXWh8EnqQswT8lj24aRIXeo
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 7bit

Hi Jeff,

thanks for your nfsd patches to accept backdated stamps from a
delegation holder!
Without them, I can't even extract a tarball with correct timestamps,
which is pretty ridiculous.
This breaks compilation of some source trees hosted on a Linux knfsd,
e.g. openwrt.

I applied your patches against 7.3.4 and they fix the issue.

Tested-by: Kurt Garloff <kurt@garloff.de>

-- 
Kurt Garloff <kurt@garloff.de>, Cologne

