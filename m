Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.remote-ip=212.227.17.20
ARC-Seal: i=1; d=subspace.kernel.org; s=arc20261015; a=rsa-sha256; cv=none;
	t=1793111797;
	b=twTKCRL1tSRsKhOoFh7EBua9pmhqDDwvoQiBTUY4l9Jb1Z2XDraC5TFK31VJ3cq7mKi5
	 joZm8ZzrxLu0CnPr13jbD8rwnnGsBLFGAbRY1yC0EMkADdKvVVHoEtkJHKyUkqRp/gssG
	 PPyop0cPUWuZmhpGctz5EhVk/iiD0NLDubMCWmvLajXmbaB6JafK4ShEMkEmAkdEoSzeo
	 Ju8+8Y7g2t6n09yjJZel9zwAB/UT59MDGV9F3TWyGStw0Sf/+BlvPq9zHSTRSom1RDfPQ
	 zhk90Pi84mz4XT9NtBkUHrPTv0OZzTC+m2w4c4qA1aCIBeil1xxwT6YktXt8KkYAw6A==
ARC-Message-Signature: i=1; d=subspace.kernel.org; s=arc20261015;
	a=rsa-sha256; c=relaxed/relaxed; t=1793111797;
	h=DMARC-Filter:DKIM-Signature:X-UI-Sender-Class:Received:From:To:Cc:
	 Subject:Date:Message-ID:X-Mailer:In-Reply-To:References:MIME-Version:
	 Content-Transfer-Encoding:X-Provags-ID:X-Spam-Flag:UI-OutboundReport;
	bh=UY/q+V17bLKcZT3p9EqOhC94nNx6IyZyoAkIGgiwmfs=;
	b=Q2L6bSM1t4VEPDnIl+sA36FcC8okpGDSPNaDMxwjR3chWC6cEw6lmyVKDmyD4zo2ULZ3
	 iXFjUXFMb2HRkOBXJ65lXCxx0Wn4FP880vdMmTWaG7gn2XkC/z18sKedAgzzG9kUISVDD
	 YZcD3RgYiw/11KjMzqzVP6l2uLNcAJi58gjQDsF7LCmeHYPd1VYi5hTuiykwmMSUpxtrq
	 iCUvUFPz4+7i97v4St9llUJKAAdGFiPMxZSDUjimsB4ACLzoE1zaN8HzWykLhcPLyzZGm
	 tDaCoucKPGxyPClGICfadj/YzYzsM4FrZFuUs+SWLCXau6a5ap4QrOovVavcAVP6A4g==
ARC-Authentication-Results: i=1; smtp.subspace.kernel.org; 
	dmarc=pass header.from=gmx.de;
	spf=pass smtp.mailfrom=gmx.de;
	dkim=pass header.d=gmx.de header.i=f3lix.dev@gmx.de header.a=rsa-sha256 header.s=s31663417 header.b=VXgrZD9f;
	arc=none smtp.remote-ip=212.227.17.20
Received: from mout.gmx.net (mout.gmx.net [212.227.17.20])
	(using TLSv1.3 with cipher TLS_AES_256_GCM_SHA384 (256/256 bits)
	 key-exchange ECDHE (prime256v1) server-signature ECDSA (prime256v1) server-digest SHA256)
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 25170606A31A;
	Tue, 27 Oct 2026 14:36:35 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.4.2 smtp.subspace.kernel.org 25170606A31A
Authentication-Results: smtp.subspace.kernel.org; dmarc=pass (p=quarantine dis=none) header.from=gmx.de
Authentication-Results: smtp.subspace.kernel.org; spf=pass smtp.mailfrom=gmx.de
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key, unprotected) header.d=gmx.de header.i=f3lix.dev@gmx.de header.a=rsa-sha256 header.s=s31663417 header.b=VXgrZD9f
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=gmx.de;
	s=s31663417; t=1793111773; x=1793716573; i=f3lix.dev@gmx.de;
	bh=UY/q+V17bLKcZT3p9EqOhC94nNx6IyZyoAkIGgiwmfs=;
	h=X-UI-Sender-Class:From:To:Cc:Subject:Date:Message-ID:In-Reply-To:
	 References:MIME-Version:Content-Transfer-Encoding:cc:
	 content-transfer-encoding:content-type:date:from:message-id:
	 mime-version:reply-to:subject:to;
	b=VXgrZD9fms8kKLq64GH/szoyCUbcbtMUyLe4Bu95FIXweTPpbjK7eTcRHToSTOHH
	 WxFq/SCP9t7jhxjA8u4iw38W62rKPUVrFVu8MXmHvwWzDxC93PD/fRmq9q4pczKuU
	 Xx00SR6FssQC5Z9ECTHmYgPB/zSveo4CARkYLHQ2c99thKRP4V2Zm4a66TxE8+bdN
	 8Qgi5DuaPkcdVlY9uk+6EfO+WkP1+xiUbNgTEIlp6uVjp6Sg++EY0ZNQKS2QSh5wz
	 PB4FtTcUs3bDTc8Kg1HUvBchq8b1391rp3/klD8gIRPlyV59Y1ajsbY7+bGf3NmYU
	 eta6mi/DCqn2Xx26GA==
X-UI-Sender-Class: 724b4f7f-cbec-4199-ad4e-598c01a50d3a
Received: from client.hidden.invalid by mail.gmx.net (mrgmx104
 [212.227.17.168]) with ESMTPSA (Nemesis) id 1MRTRN-1x9w9g0aqj-00KPRZ; Tue, 27
 Oct 2026 15:36:13 +0100
From: Felix Hoffmann <f3lix.dev@gmx.de>
To: Cedric Blancher <cedric.blancher@gmail.com>
Cc: Trond Myklebust <trondmy@kernel.org>,
	Anna Schumaker <anna@kernel.org>,
	Peng Tao <tao.peng@primarydata.com>,
	linux-nfs@vger.kernel.org,
	linux-kernel@vger.kernel.org
Subject: Re: [PATCH] NFSv4.2: request mode after CLONE
Date: Tue, 27 Oct 2026 15:35:33 +0100
Message-ID: <20261027143533.180820-1-f3lix.dev@gmx.de>
X-Mailer: git-send-email 2.43.0
In-Reply-To: <CALXu0UcEbcHbb4F+pKG1vM5XmgTcuHiLn8Y6y_hQJAYjMdZeMg@mail.gmail.com>
References: <CALXu0UcEbcHbb4F+pKG1vM5XmgTcuHiLn8Y6y_hQJAYjMdZeMg@mail.gmail.com>
X-Mailing-List: linux-nfs@vger.kernel.org
List-Id: <linux-nfs.vger.kernel.org>
List-Post: <mailto:linux-nfs@vger.kernel.org>
List-Help: <mailto:linux-nfs+help@vger.kernel.org>
List-Subscribe: <mailto:linux-nfs+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:linux-nfs+unsubscribe@vger.kernel.org>
List-Owner: <mailto:linux-nfs+owner@vger.kernel.org>
Precedence: list
MIME-Version: 1.0
Content-Transfer-Encoding: 8bit
X-Provags-ID: V03:K1:+Ot7cH/XlFMJjHTmIWAgwaH1afgtgxyrb7i60XcwwkpmhKx0EvA
 6mO9lIKRS2YLA4wC3/eTJlhlJQsFYghw7mu+patIPQZef5yPBJZbYwLL5ocw1hgXNGtaDkN
 sSkYeBg0Uuozr080LRWzq5i8Wj4GCTGE+yT/IoLlGczbDlaXYQFBPVezkGd/+ItntW62WmR
 Wh50uZagq1175Lv6eUjFg==
X-Spam-Flag: NO
UI-OutboundReport: notjunk:1;M01:P0:LkbEEzJzsKA=;VtznkxntkMn5IRFfGzW9sHsccvG
 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
 dXTd9voQwBQh1PTFIgxaOKhOVj+AWyvusV56Ts=

Hi Ced,

Thanks for checking. No, I have not reported or submitted this issue to
FreeBSD, libnfs, or any other NFS client implementation. I only submitted
it here for the Linux NFS client.

Do you think I should report it to them as well?

Best,
Felix
