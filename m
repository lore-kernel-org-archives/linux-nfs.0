Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.remote-ip=51.159.188.251
ARC-Seal: i=1; d=subspace.kernel.org; s=arc20261015; a=rsa-sha256; cv=none;
	t=1793743526;
	b=GnGm4Q61Ur5Fly0382LSX/b4MbYjMBRf+tzhtcYQCNTM1YY/7cKjGl+OkKVnvIqJX0id
	 qxWpWqg1E2K4YUACWda2YD+kTPBqhz1H+89yWJuxNhyTrtWJuBfPBu4sRbiL967njf/L2
	 Y2q7brw8LLoWvB1AFLNUTcn72bkD7uOlM2iD2SmsnGTI7ztLekAL8UpVrDJ/ef2KKM5WR
	 FN8IgXA9EGcH7gDAOlVG6C8PnTkm52doRqx7gpd4WL9crhrTOi4hBgKpWeMw1aCw3Y0GY
	 9IEIFdS3LnZkmzuOQ7LKmyOXYoWJCNzSfhpc67MO5ikQM5ifNisCCsC8vAZ686OSAKg==
ARC-Message-Signature: i=1; d=subspace.kernel.org; s=arc20261015;
	a=rsa-sha256; c=relaxed/relaxed; t=1793743526;
	h=DMARC-Filter:DKIM-Signature:Received:MIME-Version:Date:From:To:Cc:
	 Subject:In-Reply-To:References:User-Agent:Message-ID:X-Sender:
	 Content-Type:Content-Transfer-Encoding:X-AntiAbuse:X-AntiAbuse:
	 X-AntiAbuse:X-AntiAbuse:X-AntiAbuse:X-Get-Message-Sender-Via:
	 X-Authenticated-Sender:X-Source:X-Source-Args:X-Source-Dir;
	bh=AgLKVlRkqPiLSuw4Z+srhuJR/iNuFqY3i6iDhNusZnQ=;
	b=rWSPwWbR8XR8JqPoX/1RHYaHXGmypYQZ2XnQQwkYNB4O6W+yJ+w085YC3fnTYrAbE3Xc
	 b95Xz3wlI7epVq3N9+nihz2P3c/2je4Hd5OgequkkRKaSNs1PUaO8rznxE04F9xQ5sPnK
	 FhEs0M0v6IkzqBlbinUjjjx5CxTBvnqUiA/mzV5cR+ryHkkQA4JmCj0+14OnbpCBP4wZ5
	 hKjYqVLGoFoLEAPLPKNGO1WEu4wlceOcLmxaB6rXZ+w+WKOU3+EhBFUAbtGowonU12WRk
	 N+jJKVGtdUjGFeGnHKJganSGIsDhX55aQXVQWw0uG8TCmr78pbCpbUJGwn7I7DxvlHw==
ARC-Authentication-Results: i=1; smtp.subspace.kernel.org; 
	dmarc=pass header.from=oss.cyber.gouv.fr;
	spf=pass smtp.mailfrom=oss.cyber.gouv.fr;
	dkim=pass header.d=oss.cyber.gouv.fr header.i=@oss.cyber.gouv.fr header.a=rsa-sha256 header.s=default header.b="fg/7lbbw";
	arc=none smtp.remote-ip=51.159.188.251
Received: from oss.cyber.gouv.fr (oss.cyber.gouv.fr [51.159.188.251])
	(using TLSv1.3 with cipher TLS_AES_256_GCM_SHA384 (256/256 bits)
	 key-exchange X25519 server-signature ECDSA (prime256v1) server-digest SHA256)
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 31836606A338;
	Tue,  3 Nov 2026 22:05:25 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.4.2 smtp.subspace.kernel.org 31836606A338
Authentication-Results: smtp.subspace.kernel.org; dmarc=pass (p=none dis=none) header.from=oss.cyber.gouv.fr
Authentication-Results: smtp.subspace.kernel.org; spf=pass smtp.mailfrom=oss.cyber.gouv.fr
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key, unprotected) header.d=oss.cyber.gouv.fr header.i=@oss.cyber.gouv.fr header.a=rsa-sha256 header.s=default header.b=fg/7lbbw
DKIM-Signature: v=1; a=rsa-sha256; q=dns/txt; c=relaxed/relaxed;
	d=oss.cyber.gouv.fr; s=default; h=Content-Transfer-Encoding:Content-Type:
	Message-ID:References:In-Reply-To:Subject:Cc:To:From:Date:MIME-Version:
	Reply-To:Sender:Content-ID:Content-Description:Resent-Date:Resent-From:
	Resent-Sender:Resent-To:Resent-Cc:Resent-Message-ID;
	bh=AgLKVlRkqPiLSuw4Z+srhuJR/iNuFqY3i6iDhNusZnQ=; b=fg/7lbbwMS1PYvnCL221YseJpt
	dtdCQGOOoyi369U+eFEquwidCmUkyzbzzehVC/tc+z3C0JvG5CpD3Z/cmPI41Ha8UOdnpPrpNX8Pg
	B+4nHuKzagW41CUou/UMmgWa/7UjnR0/1o0RZdB6AXJfkOdILm5WIjqIV+a26AxgeBkBYhYhHNi1K
	0CRDaIZaFtP86FxcLKVg57Y5avRdiC47Mg8b2OuxncVudDm79OASZBG7O9kBRnJYFxpW8JkoLMpLG
	YC73OLpzEguVOqZM/EC1Sk2z8X8JWgDM7TZuXi2MJSqaybFSEOO0hLYzRfslTI135KUhsBSdXa3f+
	bnEo+ccg==;
Received: from [::1] (port=59178 helo=pf-012.whm.fr-par.scw.cloud)
	by pf-012.whm.fr-par.scw.cloud with esmtpa (Exim 4.100.1)
	(envelope-from <jeremy.jean@oss.cyber.gouv.fr>)
	id 1xOMdA-0000000Ec72-1Kna;
	Tue, 03 Nov 2026 23:05:23 +0100
X-Mailing-List: linux-nfs@vger.kernel.org
List-Id: <linux-nfs.vger.kernel.org>
List-Post: <mailto:linux-nfs@vger.kernel.org>
List-Help: <mailto:linux-nfs+help@vger.kernel.org>
List-Subscribe: <mailto:linux-nfs+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:linux-nfs+unsubscribe@vger.kernel.org>
List-Owner: <mailto:linux-nfs+owner@vger.kernel.org>
Precedence: list
MIME-Version: 1.0
Date: Tue, 03 Nov 2026 23:05:22 +0100
From: =?UTF-8?Q?J=C3=A9r=C3=A9my_Jean?= <jeremy.jean@oss.cyber.gouv.fr>
To: =?UTF-8?Q?J=C3=A9r=C3=A9my_Jean?= <Jeremy.Jean@oss.cyber.gouv.fr>
Cc: Trond Myklebust <trondmy@kernel.org>, Anna Schumaker <anna@kernel.org>,
 linux-nfs@vger.kernel.org, linux-kernel@vger.kernel.org,
 stable@vger.kernel.org
Subject: Re: [PATCH] NFS: blocklayout: reject oversized SCSI designators
In-Reply-To: <20260826080736.1431809-2-Jeremy.Jean@oss.cyber.gouv.fr>
References: <20260826080736.1431809-2-Jeremy.Jean@oss.cyber.gouv.fr>
User-Agent: Roundcube Webmail/1.6.20
Message-ID: <c65fcdbf90ff456f00a80bbb1086fbca@oss.cyber.gouv.fr>
X-Sender: jeremy.jean@oss.cyber.gouv.fr
Content-Type: text/plain; charset=UTF-8;
 format=flowed
Content-Transfer-Encoding: 8bit
X-AntiAbuse: This header was added to track abuse, please include it with any abuse report
X-AntiAbuse: Primary Hostname - pf-012.whm.fr-par.scw.cloud
X-AntiAbuse: Original Domain - vger.kernel.org
X-AntiAbuse: Originator/Caller UID/GID - [47 12] / [47 12]
X-AntiAbuse: Sender Address Domain - oss.cyber.gouv.fr
X-Get-Message-Sender-Via: pf-012.whm.fr-par.scw.cloud: authenticated_id: jeremy.jean@oss.cyber.gouv.fr
X-Authenticated-Sender: pf-012.whm.fr-par.scw.cloud: jeremy.jean@oss.cyber.gouv.fr
X-Source: 
X-Source-Args: 
X-Source-Dir: 

On 2026-08-26 10:07, Jérémy Jean wrote:
> A SCSI GETDEVICEINFO reply can encode designator_len as 0xffffffff.  
> The
> current signed field turns that into -1, so the size check is bypassed 
> and
> the value is converted to SIZE_MAX for xdr_inline_decode() and 
> memcpy().
> 
> The attacker model considers a controlled NFSv4.1+ server and a client
> already mounted to that server. An OOB read can be triggered in the 
> client
> on a file read. KASAN reports:
> 
>   BUG: KASAN: out-of-bounds in bl_alloc_deviceid_node+0x616/0x1110
>   Read of size 18446744073709551615
>   ...
>   __asan_memcpy+0x23/0x60
>   bl_alloc_deviceid_node+0x616/0x1110
>   nfs4_find_get_deviceid+0x565/0x810
>   bl_alloc_lseg+0x638/0x12d0
>   pnfs_layout_process+0x2b6/0xcf0
>   nfs4_proc_layoutget+0x4b3/0xd30
> 
> 
> The fix stores the length as u32 and reject oversized values before 
> decoding.
> The check is moved up before the call to xdr_inline_decode().
> 
> [...]

Hello,

Did you have time to look into that?
The OOB read is currently still present.

Thanks,
Jérémy
