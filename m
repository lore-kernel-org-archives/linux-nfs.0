Received: from sender-of-o50.zoho.eu (sender-of-o50.zoho.eu [136.143.169.50])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 1521D496D31
	for <linux-nfs@vger.kernel.org>; Mon, 14 Sep 2026 17:26:03 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=pass smtp.client-ip=136.143.169.50
ARC-Seal:i=2; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1789406766; cv=pass; b=M/wr2EcyGwJCV+1BFT0f+6doCMAccgoXc2+hBBYaDRK4BKOK+s5VABdKbQc9VxPWyNWTKyyzgJ//Wya1znhCHz90kepDzwqIV/RJBAPSLOPcia7nCL7dEALBBXe0mbnhYTFfBwfzUBAZUM5Bl1LEUxphPIMdHyavs905XpN16NU=
ARC-Message-Signature:i=2; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1789406766; c=relaxed/simple;
	bh=uJ84wZr9oXOD9k1Po5OyPlYQVrrRveDZ/oyMxYe6KLU=;
	h=Message-ID:Subject:From:To:Cc:Date:Content-Type:MIME-Version; b=VXR/T896xGRrNcwXmC5vmhGWgLw60ZMM/70DoAB6Tt8zEumSE96gp93uY19MrlMBVe361PLyLXU/+hnlbnUux4G7km80Yl6JFEuT+GEuFtNho5Egufcz+PjebXX2OkXMKYuGidcNFcCxIJmZNSIDKUE8TI2DkVahAK5GNn2++IQ=
ARC-Authentication-Results:i=2; smtp.subspace.kernel.org; dmarc=none (p=none dis=none) header.from=uvos.xyz; spf=pass smtp.mailfrom=uvos.xyz; dkim=pass (1024-bit key) header.d=uvos.xyz header.i=carl@uvos.xyz header.b=BJQSGA90; arc=pass smtp.client-ip=136.143.169.50
Authentication-Results: smtp.subspace.kernel.org; dmarc=none (p=none dis=none) header.from=uvos.xyz
Authentication-Results: smtp.subspace.kernel.org; spf=pass smtp.mailfrom=uvos.xyz
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (1024-bit key) header.d=uvos.xyz header.i=carl@uvos.xyz header.b="BJQSGA90"
ARC-Seal: i=1; a=rsa-sha256; t=1789406751; cv=none; 
	d=zohomail.eu; s=zohoarc; 
	b=DwaYE0uZ1AZjIQTDIxoMACzufCobgVOBp9SsVNf7UU3VkwkNc4ccEND3zTX3dXA53zX3uoFxXDOgc+/mxfqe0u7Ky8yGtWic8xqoWCvSzlYROYs6NavjSb9D4zG2wzbSspwemcip+1lSM/sbaJsppH3q98lHNvfSalb3a5MpOEk=
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=zohomail.eu; s=zohoarc; 
	t=1789406751; h=Content-Type:Content-Transfer-Encoding:Cc:Cc:Date:Date:From:From:MIME-Version:Message-ID:Reply-To:Reply-To:Subject:Subject:To:To:Message-Id; 
	bh=uJ84wZr9oXOD9k1Po5OyPlYQVrrRveDZ/oyMxYe6KLU=; 
	b=bI6qEOYx65MzHa/uACwtx63mocs939oBCx65AcTkZVkXJh3XwJthANUnHqeMMmu41t8sSZEyIN6ociDqPxYNTxcpWcI4Wghsj+IoOx6md/QX6UfRxMak6or5TBurjtLcvHPUN/lP7jf8VRokvSPp93fMIXq5s7qYxP6PcQVXjFE=
ARC-Authentication-Results: i=1; mx.zohomail.eu;
	dkim=pass  header.i=uvos.xyz;
	spf=pass  smtp.mailfrom=carl@uvos.xyz;
	dmarc=pass header.from=<carl@uvos.xyz>
DKIM-Signature: v=1; a=rsa-sha256; q=dns/txt; c=relaxed/relaxed; t=1789406751;
	s=ideal; d=uvos.xyz; i=carl@uvos.xyz;
	h=Message-ID:Subject:Subject:From:From:Reply-To:Reply-To:To:To:Cc:Cc:Date:Date:Content-Type:Content-Transfer-Encoding:MIME-Version:Message-Id;
	bh=uJ84wZr9oXOD9k1Po5OyPlYQVrrRveDZ/oyMxYe6KLU=;
	b=BJQSGA90675T8yrHWGI41STW603Qjb5X3m6pkBmpr2o1ohLg3lB1FulwO2cr+nx5
	UH+gip3srPCrSGjKCZwI50+QbD0uLPSV0PKDhjVOnO/WtKV7X0YTsOGplUJQjAiWqUn
	GzYsmGHezOwU07JimBZO70e8s5NNUn0f4lw0l5eE=
Received: by mx.zoho.eu with SMTPS id 17894067486961.3739293054071595;
	Mon, 14 Sep 2026 19:25:48 +0200 (CEST)
Message-ID: <d60e48bfc7f084fb697a33733a4818fcd7abb05c.camel@uvos.xyz>
Subject: RE: FS-Cache/cachefiles not writing data in v7.2
From: Carl Klemm <carl@uvos.xyz>
Reply-To: CAPt2mGO-08X5h-v2Nm9m8E4y5X9V3BpCcoSZiqW6rd-siBBAmg@mail.gmail.com
To: linux-nfs@vger.kernel.org
Cc: daire@dneg.com
Date: Mon, 14 Sep 2026 19:25:47 +0200
Autocrypt: addr=carl@uvos.xyz; prefer-encrypt=mutual;
 keydata=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
 w5ijy8wHvtcyjBGzDVlK5a32/If3wKotN4eQYPQ==
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable
User-Agent: Evolution 3.60.2 
Precedence: bulk
X-Mailing-List: linux-nfs@vger.kernel.org
List-Id: <linux-nfs.vger.kernel.org>
List-Subscribe: <mailto:linux-nfs+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:linux-nfs+unsubscribe@vger.kernel.org>
MIME-Version: 1.0
X-ZohoMailClient: External

Hi,

I can confirm that fs-cache is broken in 7.2.4, and narrow the width
that would have to be bisected, as i just upgraded from 7.1.5 where fs-
cache still worked.

Regards
Carl
