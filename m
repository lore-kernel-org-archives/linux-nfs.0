Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.remote-ip=209.85.221.50
ARC-Seal: i=1; d=subspace.kernel.org; s=arc20261015; a=rsa-sha256; cv=none;
	t=1795443330;
	b=vkhuHer9sFL9PjD94WW3OZy81dpMRFxtvyAZ01rJZvfeXmln7+8NIOXyAk2i/nwG8tlM
	 5DU5TkxzoHAlpFOV6p1HXmvy9sQXkOVB28UBw9iPpw691RMAoxqxmakWQZNNiNJjmC3oa
	 DHpxhLmoWgqHgeGzzioBpyKWFeOWc05dj1aiXi2pC9fAru1QgaCUIAy+7DB50AG3X8XmE
	 FbVZ4aJfJfq4gvQW0DgNcbxdx7a3dlykIKDP4Hzz0Kl7mo3jBbiRPdMNb+0LPzoHzjHZi
	 lonwVN05ZFfjomxAOF+MzZWFW+HEBfY4w3K+mfE2e4vs9fpx56TMdHJskqewvHZ7/0A==
ARC-Message-Signature: i=1; d=subspace.kernel.org; s=arc20261015;
	a=rsa-sha256; c=relaxed/relaxed; t=1795443330;
	h=DMARC-Filter:Received:DKIM-Signature:X-Google-DKIM-Signature:
	 X-Forwarded-Encrypted:X-Gm-Message-State:X-Gm-Gg:X-Received:Received:
	 Mime-Version:Content-Type:Date:Message-Id:Cc:Subject:From:To:X-Mailer:
	 References:In-Reply-To;
	bh=SVkCiAZ9hVspPzZuKZbqXCYeKQk4BcDbwlCFk9p1ut0=;
	b=a/aWaBEGwbH6nviXHoBBazgRRoDxi+hLtgNmAY50ht7Gbr+2adFeMBXNsh85LfyXHBIc
	 2j4+LNFV1lPmTMsea7pJ9JkSS0AxxxjJMnGVkMeK6CCQq/nU3xYDmg+9zRLYXWYFYiNig
	 xM92wJ/vgQB10JJ8vcbnXZWUgZTvcB3Oc6AH8ESweRiohvSrEVry03x0hZ7GF8m+cWGoA
	 Y9jOHgcC+aLbnQmjkvwQTGwizLp2mEdcZSmcH8S4W50nVyp48MSKMYTQnJInpxpvIvlGH
	 SrDPc5l998Fcqxmw1O5vOBD3L8toS4QaBvpU5yQlPEi2yOUwqu4OoGyl1/Ekq+iQIng==
ARC-Authentication-Results: i=1; smtp.subspace.kernel.org; 
	dmarc=pass header.from=gmail.com;
	spf=pass smtp.mailfrom=gmail.com;
	dkim=pass header.d=gmail.com header.i=@gmail.com header.a=rsa-sha256 header.s=20260707 header.b=LhurUaLd;
	arc=none smtp.remote-ip=209.85.221.50
Received: from mail-wr1-f50.google.com (mail-wr1-f50.google.com [209.85.221.50])
	(using TLSv1.3 with cipher TLS_AES_128_GCM_SHA256 (128/128 bits)
	 key-exchange X25519 server-signature ECDSA (prime256v1) server-digest SHA256)
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 8EC28606A336
	for <linux-nfs@vger.kernel.org>; Mon, 23 Nov 2026 14:15:29 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.4.2 smtp.subspace.kernel.org 8EC28606A336
Authentication-Results: smtp.subspace.kernel.org; dmarc=pass (p=none dis=none) header.from=gmail.com
Authentication-Results: smtp.subspace.kernel.org; spf=pass smtp.mailfrom=gmail.com
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=gmail.com header.i=@gmail.com header.a=rsa-sha256 header.s=20260707 header.b=LhurUaLd
Received: by mail-wr1-f50.google.com with SMTP id ffacd0b85a97d-490d59c3f0aso1544017f8f.1
        for <linux-nfs@vger.kernel.org>; Mon, 23 Nov 2026 06:15:29 -0800 (PST)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=gmail.com; s=20260707; t=1795443328; x=1796048128; darn=vger.kernel.org;
        h=in-reply-to:references:to:from:subject:cc:message-id:date
         :content-type:mime-version:from:to:cc:subject:date:message-id
         :reply-to:content-type;
        bh=SVkCiAZ9hVspPzZuKZbqXCYeKQk4BcDbwlCFk9p1ut0=;
        b=LhurUaLdrrD6el1BtOOCJ70R+8KqK05u0u89mfuXWG8+J9Bw3rVb386658OMP5zMq0
         decyq5yItprIln2niTvSLmNubbRMdoF++9VmjkmrA05HZdXvZxDurdMDYBuXSM2/ru83
         DL0zGzc4TqwjCvYZ5gt34/pSFJf4/mCtDoKXgpXPt+Sv7g1Y86AFw3XQ6uM+o5M48dZA
         fsqr7/KfuhPw2PRwDKKUwpkICKW7wj5qvnFdYfxcb8shaROlLIM069A9F1sNO6bSCk2N
         auXzk8QjTdj3SnDJjqubihTVZqQWZzgbhHEkWSyJVafh+Xk4iboolLWwWkG1XoRweIGi
         qdfg==
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20260707; t=1795443328; x=1796048128;
        h=in-reply-to:references:to:from:subject:cc:message-id:date
         :content-type:mime-version:x-gm-gg:x-gm-message-state:from:to:cc
         :subject:date:message-id:reply-to:content-type;
        bh=SVkCiAZ9hVspPzZuKZbqXCYeKQk4BcDbwlCFk9p1ut0=;
        b=At3Lf5paThODQgW6XQUovnNNftKd01WWnct1+qLGssf4ROfL3RYc91JiX6dOfdEVVu
         fWNz10UnBdEAJtLwcr4QJs6axNf5+QKVKNqaSHvQvM8iLLAkjPRrmADekfzUD9oNpxAn
         h5mf28PthEnPyNHTdFJw5BUmvGo6GKwlWpmI7nMzwmPszgInWi7YYyyEX9eI0q4NqtGx
         M1Z/MK8MAtsofxqs7rMEOXgn2EbarhJuqNxDabhAQmNCG7LCgvQ0rdFlcgYcaLtUK8W9
         4D03pvX3z8VdG1kdlbE7d5fL9/BLTeN0q9MxgBOqiTDuA3MELLvOIV314MCfcvOQvLWa
         r3Bw==
X-Forwarded-Encrypted: i=1; AL+hErFWXWue9aVOastqIyu7nmUhwPoF1rL1bQbOjpTFURXzg4e3Q7xQs/lHtIgaoLSpJsy+bq/7Tdf4O0M=@vger.kernel.org
X-Gm-Message-State: APuU4Z+t41S/nPOn4nu0B8CV5CeqMy01x9RXJcd9t4Pif2Pqgs5nFcui
	IlPPb2Wpfo2/1DCG16D045OA33siVnaYIAHH8GIeD9XRuGniXNRspvJy
X-Gm-Gg: AZFdTZdDmlAWCP4oLfCqOg3fIVCjybqlYmddNIhgrhDH6yMPbUdekV7wgG4MZ4TpIJ5
	1qjrpI4kXABSGsv1D2gvSfwKLvkIRPORoE1ycGdP+NbpcdRopV/pqlbau1EBQ5AVWOAr/CUSWEx
	KwReJIyw2tUqVC8gTcL9/2Sv/FWkIVMv+xWQ8OCcVTapB3OU9Cw16rCt0tMIZ5eLh20w8Jf9mge
	3rNbYM4BRWhMXN4kmIXtT7DpqQnBowsjY8QDHgtZgs1/SzJa0t9JNdOSzcXmDxL24JMeyqQQUaV
	2zmqycebAbz8oPq11wMqGbXJiX2/fhhxO+x9tgKy9FUuuNf8xF/N/kTgiaVnePSmUOGVpPOi0cg
	+SOt9qGDuWe6pPNnc5HM61gah1qx5u5qQmTyis5MVWzvU5tx5/s9YjJED1SZ9tZ3wwkoiVI3+fx
	K6UMH+T0OD3cy1sVjQ65rVPFdlT4v+Xiu8j/MpF4Ep9vF/+XFO8mqkdhOwrEzPLodus9IL0zArk
	Ot1RMW+PJ4tZ7Y2xebDIddFz52t4xWmnbFwYQmL+Gb/nd5kG2rl1g134BoOKzKAvZ/nxWjNVzuo
	WFcjFs3PzNbbdVDX5reQcy0GOQo=
X-Received: by 2002:a05:6000:4b0f:b0:48e:d7c:4bc8 with SMTP id ffacd0b85a97d-4abad6a1782mr21438558f8f.7.1795443327853;
        Mon, 23 Nov 2026 06:15:27 -0800 (PST)
Received: from localhost ([2001:b07:5d26:7a6a:365a:60ff:fe0d:cfc6])
        by smtp.gmail.com with ESMTPSA id ffacd0b85a97d-4ad6403fdbbsm15815535f8f.15.2026.11.23.06.15.26
        (version=TLS1_3 cipher=TLS_AES_128_GCM_SHA256 bits=128/128);
        Mon, 23 Nov 2026 06:15:27 -0800 (PST)
X-Mailing-List: linux-nfs@vger.kernel.org
List-Id: <linux-nfs.vger.kernel.org>
List-Post: <mailto:linux-nfs@vger.kernel.org>
List-Help: <mailto:linux-nfs+help@vger.kernel.org>
List-Subscribe: <mailto:linux-nfs+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:linux-nfs+unsubscribe@vger.kernel.org>
List-Owner: <mailto:linux-nfs+owner@vger.kernel.org>
Precedence: list
Mime-Version: 1.0
Content-Type: multipart/signed;
 boundary=d4d0d8ea600ad9a6a0e804d6ccca97eae7564ecdc87e5749b6027a98fdf4;
 micalg=pgp-sha512; protocol="application/pgp-signature"
Date: Mon, 23 Nov 2026 15:15:25 +0100
Message-Id: <DN2NJH234CC4.2LSWRSOO4TX5I@gmail.com>
Cc: "Namjae Jeon" <linkinjeon@kernel.org>, "Hyunchul Lee"
 <hyc.lee@gmail.com>, "Alexander Viro" <viro@zeniv.linux.org.uk>, "Christian
 Brauner" <brauner@kernel.org>, "Chuck Lever" <cel@kernel.org>, "Jeff
 Layton" <jlayton@kernel.org>, "Jan Kara" <jack@suse.cz>, "Darrick J . Wong"
 <djwong@kernel.org>, "Amir Goldstein" <amir73il@gmail.com>,
 =?utf-8?q?Pali_Roh=C3=A1r?= <pali@kernel.org>, "Lauri Gates"
 <lauri.gates@gmail.com>, "Christoph Hellwig" <hch@infradead.org>, "Dave
 Chinner" <dgc@kernel.org>, <linux-btrfs@vger.kernel.org>,
 <linux-xfs@vger.kernel.org>, <linux-kernel@vger.kernel.org>,
 <linux-fsdevel@vger.kernel.org>, <ntfs@lists.linux.dev>,
 <linux-nfs@vger.kernel.org>, <linux-api@vger.kernel.org>
Subject: Re: [PATCH 1/3] vfs: use goto out on error in vfs_fileattr_set()
From: "koraynilay" <koray.fra@gmail.com>
To: "Andrey Albershteyn" <aalbersh@kernel.org>, "koraynilay"
 <koray.fra@gmail.com>
X-Mailer: aerc 0.22.0-0-gc2f86b7abde3
References: <20261122000856.536902-1-koray.fra@gmail.com>
 <20261122000856.536902-2-koray.fra@gmail.com>
 <awP8S5KF9v-nqWVY@aalbersh-thinkpadx1carbongen13.rmtcz.csb>
In-Reply-To: <awP8S5KF9v-nqWVY@aalbersh-thinkpadx1carbongen13.rmtcz.csb>

--d4d0d8ea600ad9a6a0e804d6ccca97eae7564ecdc87e5749b6027a98fdf4
Content-Transfer-Encoding: quoted-printable
Content-Type: text/plain; charset=UTF-8

On Mon Nov 23, 2026 at 9:42 AM CET, Andrey Albershteyn wrote:
> On 2026-11-22 01:08:54, koraynilay wrote:
>> Switch from using if (!err) { ... } to the cleaner if (err) goto out;
>> in the main body of vfs_fileattr_set().
>>=20
>> Signed-off-by: koraynilay <koray.fra@gmail.com>
>
> Looks good to me
> Reviewed-by: Andrey Albershteyn <aalbersh@kernel.org>

Thank you, can I add this tag to the v2 version of this patch (since it
won't be changed, and link to this thread in the comment section of the
patch)?

Thanks,
koraynilay

--d4d0d8ea600ad9a6a0e804d6ccca97eae7564ecdc87e5749b6027a98fdf4
Content-Type: application/pgp-signature; name="signature.asc"

-----BEGIN PGP SIGNATURE-----

iHUEABYKAB0WIQSgVimKafU5DQMcjcDmj22qf5IGXAUCawRKfQAKCRDmj22qf5IG
XGk/AP9j2YLEmAts6UKmrX6qw0EDoHRjv0eLrfHDRJfhkjSDdQEAixfLgqqT3tMt
wDbEqGGddyloPl2sCvNgcE83htldvgM=
=8yb/
-----END PGP SIGNATURE-----

--d4d0d8ea600ad9a6a0e804d6ccca97eae7564ecdc87e5749b6027a98fdf4--
