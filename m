Received: from mout.web.de (mout.web.de [212.227.15.4])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id AF2EA15B998;
	Sat, 18 Jul 2026 06:45:54 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=212.227.15.4
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1784357156; cv=none; b=fuOFAWkTnt8ntZliGpHn7Ol1FXlezTZM92UQYYDbZWCn50GbIrmHnzEDaClLdJNpKn0yAn+ICPpnP0hSXb9Ry/i2ZXggnzxC8Aw5iRSgh6pvbLBULI5lXLj0oN6zVdcIbdurYNuz1pW0jgTC8Fe4IyR39np5j6P2AG5Qj4McR2k=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1784357156; c=relaxed/simple;
	bh=leIU3My4pvQ6/4Uvy48/kmuwCw0NNDrix0x3rLW3rCU=;
	h=Message-ID:Date:MIME-Version:Subject:From:To:Cc:References:
	 In-Reply-To:Content-Type; b=QGwJotgm5CwddC7VjPGokXoUU8lSBLgQcaQ9yocFoDxoF27XNE4bpW9QnM65bCdXMTMMzBg4rwIWzQ1i2Fqn+cE3B340PtsSjyVhnfmr9oM52bPW2wwWteAFxuTz/xAsGlzITFMECwW3cnESIyYPhx7zt6c9pPtkC5wl3byG6iQ=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dmarc=pass (p=quarantine dis=none) header.from=web.de; spf=pass smtp.mailfrom=web.de; dkim=pass (2048-bit key) header.d=web.de header.i=markus.elfring@web.de header.b=pp77hnxN; arc=none smtp.client-ip=212.227.15.4
Authentication-Results: smtp.subspace.kernel.org; dmarc=pass (p=quarantine dis=none) header.from=web.de
Authentication-Results: smtp.subspace.kernel.org; spf=pass smtp.mailfrom=web.de
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=web.de header.i=markus.elfring@web.de header.b="pp77hnxN"
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=web.de;
	s=s29768273; t=1784357144; x=1784961944; i=markus.elfring@web.de;
	bh=CvV4xlGhOqSK4/kjTKShjUinFTECAwiAG/28OgJQ26E=;
	h=X-UI-Sender-Class:Message-ID:Date:MIME-Version:Subject:From:To:
	 Cc:References:In-Reply-To:Content-Type:Content-Transfer-Encoding:
	 cc:content-transfer-encoding:content-type:date:from:message-id:
	 mime-version:reply-to:subject:to;
	b=pp77hnxN01vA5b+cCQHLqQ/tstRW7ewrNPqyhoglP5HrVXMGdHNckHZj5a5xzuox
	 G3XsmI4Efpmriom+IthVYvMz/lq6S38cBMf0EHp3UF69uwU06nVsWkKyMFgN5m8I3
	 D205PlPUoM0pjvTJ4ASoe4cDJg1QmP71YWKJul0upz9vXkznBza6URnkg7Lt5wo/I
	 WyKPXHUn0GIbpvJTGFcie5g5pBkaM73c8SvEmJnky3/WqKv7UkeWlKTfwk9YK4IX1
	 0CDDsp3p+z0ZiVHj6VMBoPCte0GXR9X2TY0uSEEbtgF8I+1S/fqS84b1fJQFJ+o/d
	 PGDW4AC4uCFJcbIqSA==
X-UI-Sender-Class: 814a7b36-bfc1-4dae-8640-3722d8ec6cd6
Received: from client.hidden.invalid by smtp.web.de (mrweb005
 [213.165.67.108]) with ESMTPSA (Nemesis) id 1McIga-1xJEE01ieq-00ZN6c; Sat, 18
 Jul 2026 08:45:44 +0200
Message-ID: <b1613a9c-b24c-4445-831f-e0ced640a80f@web.de>
Date: Sat, 18 Jul 2026 08:45:23 +0200
Precedence: bulk
X-Mailing-List: linux-nfs@vger.kernel.org
List-Id: <linux-nfs.vger.kernel.org>
List-Subscribe: <mailto:linux-nfs+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:linux-nfs+unsubscribe@vger.kernel.org>
MIME-Version: 1.0
User-Agent: Mozilla Thunderbird
Subject: Re: [PATCH] nfsd: Use seq_putc() in seq_quote_mem()
From: Markus Elfring <Markus.Elfring@web.de>
To: linux-nfs@vger.kernel.org, kernel-janitors@vger.kernel.org,
 Chuck Lever <chuck.lever@oracle.com>, Dai Ngo <Dai.Ngo@oracle.com>,
 Jeff Layton <jlayton@kernel.org>, Neil Brown <neilb@suse.de>,
 Olga Kornievskaia <kolga@netapp.com>, Tom Talpey <tom@talpey.com>
Cc: LKML <linux-kernel@vger.kernel.org>
References: <ab25204c-5a53-42e1-ab3a-c4f704ebc929@web.de>
Content-Language: en-GB, de-DE
In-Reply-To: <ab25204c-5a53-42e1-ab3a-c4f704ebc929@web.de>
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: quoted-printable
X-Provags-ID: V03:K1:5ahyQyExN0Yfbf6h0jR97t5ulHAZKQXNTNOd7mBCibQkc/eFJZJ
 6VGTj7F/gEH989nIK+ipdqFQc6lfHYqRAEt9+2BrjWm61Y/Iq+SRBl46/OPSqwDOOSIfg17
 q3cwAEm1J9TPPEYWZLJwPrlClnqtW+bH+Vwa6uYEcyV/T13IYMpDiAGWb2K6TRR6wUjUo3D
 i4XIL++dXL3veRJNKfZRA==
X-Spam-Flag: NO
UI-OutboundReport: notjunk:1;M01:P0:sDuhRTJj1CQ=;XOL8bYJFu/MzNvleV4EOfnbx967
 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

> Date: Sat, 13 Jul 2024 21:07:09 +0200
>=20
> Double quotation characters should be put into a sequence
> around other data.
> Thus use the function =E2=80=9Cseq_putc=E2=80=9D accordingly.
>=20
> This issue was transformed by using the Coccinelle software.
Why is the information =E2=80=9CState 	Rejected=E2=80=9D presented by a kn=
own communication interface
for such a development idea?
https://patchwork.kernel.org/project/linux-nfs/patch/ab25204c-5a53-42e1-ab=
3a-c4f704ebc929@web.de/

Remaining update candidate:
https://elixir.bootlin.com/linux/v7.2-rc3/source/fs/nfsd/nfs4state.c#L2886=
-L2891

Regards,
Markus
