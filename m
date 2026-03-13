Received: from forward500d.mail.yandex.net (forward500d.mail.yandex.net [178.154.239.208])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 0CCED3806BD
	for <linux-nfs@vger.kernel.org>; Fri, 13 Mar 2026 08:23:09 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=178.154.239.208
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1773390193; cv=none; b=FYEPbs6MxFLuU5JVJqPYoAJOrsYiq9vRPHN1aB3/GKHq1C+YX4wsPXa3DctFJWGRedNV39IsJyBXUXsxuxhNqfHM9p46qfbkAVK2by2+qqdMmGum9PD4RT82qW1O+XZWEMgtev80MdHbp5TJv6sNsTS5P7RgTZeDoE47C82ZwC4=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1773390193; c=relaxed/simple;
	bh=w0eRequuHtUU3t57PxFMIKZKMFSRnx6SYTh8GitRcbQ=;
	h=Message-ID:Subject:From:To:Cc:Date:In-Reply-To:References:
	 Content-Type:MIME-Version; b=aZt0qupB3kqaZCBCAf+qo2N7sg0FqY4d5wWVgiQP34/C5lV/PyFMjqbdmZGDIAzMk7x0uFbIx+OFMZo3CN9P7eSX/yrki7pXhAU7zxLuUgS7C+fmxj8sPjEs+8QUgZa+Vb89RKCcZhAwKVoe/6loQVGaq6f5OtQ9egisn2+aRSM=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dmarc=pass (p=none dis=none) header.from=yandex.ru; spf=pass smtp.mailfrom=yandex.ru; dkim=pass (1024-bit key) header.d=yandex.ru header.i=@yandex.ru header.b=DA8Tc+Qx; arc=none smtp.client-ip=178.154.239.208
Authentication-Results: smtp.subspace.kernel.org; dmarc=pass (p=none dis=none) header.from=yandex.ru
Authentication-Results: smtp.subspace.kernel.org; spf=pass smtp.mailfrom=yandex.ru
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (1024-bit key) header.d=yandex.ru header.i=@yandex.ru header.b="DA8Tc+Qx"
Received: from mail-nwsmtp-smtp-production-main-80.klg.yp-c.yandex.net (mail-nwsmtp-smtp-production-main-80.klg.yp-c.yandex.net [IPv6:2a02:6b8:c42:3cca:0:640:f0e1:0])
	by forward500d.mail.yandex.net (Yandex) with ESMTPS id 08AF18150F;
	Fri, 13 Mar 2026 11:17:50 +0300 (MSK)
Received: by mail-nwsmtp-smtp-production-main-80.klg.yp-c.yandex.net (smtp/Yandex) with ESMTPSA id mHDGJ6QGn4Y0-I7Sp0Vhw;
	Fri, 13 Mar 2026 11:17:49 +0300
X-Yandex-Fwd: 1
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=yandex.ru; s=mail;
	t=1773389869; bh=w0eRequuHtUU3t57PxFMIKZKMFSRnx6SYTh8GitRcbQ=;
	h=References:Date:In-Reply-To:Cc:To:From:Subject:Message-ID;
	b=DA8Tc+QxrxqN8+CG64U8znLlqvSXd+FThavmgN5z8FRVtVu15ZMS+SmDGH3zMYVrA
	 70CwcRI0NA2OEo0FT4XwiVfg25MhmAU8iFTgKCFJGzSPva9nhNhAR6+cB1+sMe9q/6
	 yvsTxjdmDolQiklfXPS9PsanTiiay/vIKW9kYGlo=
Authentication-Results: mail-nwsmtp-smtp-production-main-80.klg.yp-c.yandex.net; dkim=pass header.i=@yandex.ru
Message-ID: <c5752c9db1c678e7b637dd0fdf1986e43b123b53.camel@yandex.ru>
Subject: Re: [PATCH] nfsd: simplify nfsd4_interssc_connect()
From: Dmitry Antipov <dmantipov@yandex.ru>
To: Chuck Lever <cel@kernel.org>, Chuck Lever <chuck.lever@oracle.com>, Jeff
 Layton <jlayton@kernel.org>
Cc: NeilBrown <neil@brown.name>, Olga Kornievskaia <okorniev@redhat.com>, 
 Dai Ngo <Dai.Ngo@oracle.com>, Tom Talpey <tom@talpey.com>,
 linux-nfs@vger.kernel.org
Date: Fri, 13 Mar 2026 11:17:48 +0300
In-Reply-To: <03562c81-1de2-45a1-8d0f-e37e3d8de063@app.fastmail.com>
References: <20260312120720.27899-1-dmantipov@yandex.ru>
	 <03562c81-1de2-45a1-8d0f-e37e3d8de063@app.fastmail.com>
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable
User-Agent: Evolution 3.58.3 (3.58.3-1.fc43) 
Precedence: bulk
X-Mailing-List: linux-nfs@vger.kernel.org
List-Id: <linux-nfs.vger.kernel.org>
List-Subscribe: <mailto:linux-nfs+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:linux-nfs+unsubscribe@vger.kernel.org>
MIME-Version: 1.0

On Thu, 2026-03-12 at 22:03 -0400, Chuck Lever wrote:

> The old code zero-initialized ipaddr via kzalloc, so an rpc_ntop()
> failure (return 0) would produce an empty string. The new stack buffer
> is uninitialized. If rpc_ntop() returns 0, snprintf formats
> uninitialized stack bytes into raw_data.

This may be easily fixed with =3D {0} (but it doesn't matter if you're
strongly against stack allocation in this case).

>=20
> The kernel community has a general preference for heap allocation of
> buffers to keep stack frames small. The kernel stack is typically only
> 8=E2=80=9316 KB and shared across the entire call chain. While 64 bytes a=
lone
> isn't alarming, this function already has struct sockaddr_storage (128
> bytes) on the stack, and the cumulative effect matters more than any
> single buffer.

If 64 + 128 is alarming enough for a single function, wouldn't you think th=
at
typical current values of -Wframe-larger-than are too large and better to b=
e
reduced to, say, 512 or even smaller?

Dmitry
