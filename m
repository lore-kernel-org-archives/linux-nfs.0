Authentication-Results: smtp.subspace.kernel.org; arc=pass header.oldest-pass=0 smtp.remote-ip=209.85.218.44
ARC-Seal: i=2; d=subspace.kernel.org; s=arc20261015; a=rsa-sha256; cv=pass;
	t=1795796335;
	b=HhQ+FKte4sNPRJPoLYc1HWG7JaaC///7JJu4tfDoEGkZqe5OxHJ2mox7DLrftd2mtUIm
	 zmvReriNnYtLXKiQkA9PBoR9zUAMtH/FyqSn/7bMN5lbLPTP6Leiu+seQrD1Fo7dUM77t
	 qaC2urHhMjjhTasndTHIvfhuB4WfAciUdKlOJXtrCfhXHFwMQxgUcnMkbN9wBRq/VZbNH
	 2Ah4DXR+Ze+1/i5n6wmQYTm1mjdnAHUNTGq5YFBoemYsH09/zlrrhAcZZlHUypIF9tfOI
	 WgHxpRViudq5m87SOdg4pxPJ1U9tJp8cYlCK4ohK+K4tDND+0WK4csQsz5HXkaGqnHw==
ARC-Message-Signature: i=2; d=subspace.kernel.org; s=arc20261015;
	a=rsa-sha256; c=relaxed/relaxed; t=1795796335;
	h=DMARC-Filter:Received:DKIM-Signature:X-Google-DKIM-Signature:
	 X-Forwarded-Encrypted:X-Gm-Message-State:X-Gm-Gg:X-Received:
	 MIME-Version:References:In-Reply-To:From:Date:X-Gm-Features:
	 Message-ID:Subject:To:Cc:Content-Type:Content-Transfer-Encoding;
	bh=WcqK/TokdPrpJ1SyssRoGlfCD57QN3XIIcFf/99tphc=;
	b=DWtPOWLdW3cv3x46bTKaKjncmIoGaX3SSR3bB1ri9ee46r8fUxhRZENiD/kE1O/D+nUE
	 yot/m8iCJam5u9KUbe+Yh3EYiArFFIllTzq4t90ixyRSHLC58EJvzpRSVA90ngQpq0BTX
	 0wzPPhsawgoUGJtln6vH+C2fVDWwjKT9J8Pvmy7V1wdvYpAHrumqa7Oc5YK/xL7TcaDT+
	 AHxmwl95Eu5tmnUVwzWFcbxaQRFBglgcSG68zFfQIWyuNCl7YViIqChrMNX404pU00vWq
	 9suqfq7dNQRNYFMjXzMW7j43QUKfErSGhsMtB+noFsNdMCNcElzdVkw3iMrqB/R9dgQ==
ARC-Authentication-Results: i=2; smtp.subspace.kernel.org; 
	dmarc=pass header.from=gmail.com;
	spf=pass smtp.mailfrom=gmail.com;
	dkim=pass header.d=gmail.com header.i=@gmail.com header.a=rsa-sha256 header.s=20260707 header.b="naloy12/";
	arc=pass header.oldest-pass=0 smtp.remote-ip=209.85.218.44
Received: from mail-ej1-f44.google.com (mail-ej1-f44.google.com [209.85.218.44])
	(using TLSv1.3 with cipher TLS_AES_128_GCM_SHA256 (128/128 bits)
	 key-exchange X25519 server-signature ECDSA (prime256v1) server-digest SHA256)
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id EB048606A321
	for <linux-nfs@vger.kernel.org>; Fri, 27 Nov 2026 16:18:54 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.4.2 smtp.subspace.kernel.org EB048606A321
Authentication-Results: smtp.subspace.kernel.org; dmarc=pass (p=none dis=none) header.from=gmail.com
Authentication-Results: smtp.subspace.kernel.org; spf=pass smtp.mailfrom=gmail.com
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=gmail.com header.i=@gmail.com header.a=rsa-sha256 header.s=20260707 header.b=naloy12/
Received: by mail-ej1-f44.google.com with SMTP id a640c23a62f3a-c4395d31228so1413793666b.1
        for <linux-nfs@vger.kernel.org>; Fri, 27 Nov 2026 08:18:54 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1795796333; cv=none;
        d=google.com; s=arc-20260327;
        b=Lhvnjmd4KClOorhGuMYnRF5vnfHaMvE9D+xcrzqWfp+98omrwYORtYmRqL5DHk0+cz
         tP2exmpfd+7r9UVznf+D9bfjIFyPNQhYhbcZzip/rXh+F3409FZu7VDVOwTWWDpuL4rT
         ksFAILG8ITPDNsBsf+uk1WEwJN7g9shShTUlnU1neHyNv6YNr6dnXhgVg8Vb67Couwt4
         nbv2TsWmKXmZx/Yhx6qG1M+Zboxb1fgNodNejoPlPiI84lO++HCLP3LCnVuhdqOXre08
         F7+KAGQUvTEPnaCX1ZTjAxdlv3WiOo//5sBGf3ej1FlmCRkFfV3JWgnY9NXElNDdDkBU
         DH8A==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20260327;
        h=content-transfer-encoding:cc:to:subject:message-id:date:from
         :in-reply-to:references:mime-version:dkim-signature;
        bh=WcqK/TokdPrpJ1SyssRoGlfCD57QN3XIIcFf/99tphc=;
        fh=Y3SeugpUl2P9gYa9uqF4FrYKTEPqez9Vt6GJcA1HWDk=;
        b=ix8slC5CR/D2NUb8QyFfoP1w6/qXo1Z2X/6Sm3s8soSKjQv6UPOJUJ5+4wpXbd6ZLs
         nRs5ophBEWvLbpUD4CDLbpSk6tkqfNNr+DO6kbzKHy+v5dDPtEFUOibsPD7GfrX+1Jyq
         0Ya9n9X+zDj69TZ3p6sx4KIhS4OBbXqToGs9rOVq1yATOk3+QRegWZBJB4CBxw8Ssdhm
         lzjIPS/VC2XU0D6zhmcchawhBLJ5IWhMB3e2w3t4p4s220EGvV5NwlILTsawddBW1czM
         HWKVkGmGzlH8jpM7x/kQYpeSpKgEwYgrE/tO+2fmUfpxcjD4Yp/fD9Yo5J8StaFk3cos
         WWag==;
        darn=vger.kernel.org
ARC-Authentication-Results: i=1; mx.google.com; arc=none
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=gmail.com; s=20260707; t=1795796333; x=1796401133; darn=vger.kernel.org;
        h=content-transfer-encoding:content-type:cc:to:subject:message-id
         :date:from:in-reply-to:references:mime-version:from:to:cc:subject
         :date:message-id:reply-to:content-type;
        bh=WcqK/TokdPrpJ1SyssRoGlfCD57QN3XIIcFf/99tphc=;
        b=naloy12//Z/JEicfOBVG7/emu8n6hsVyuTwhG/APX5YJILPJ+Ejhpn8jBE4NDP7/lK
         g0UksYAE6Bdao6mTsS9kfqJqJTBy4iSLcQUfz2p6ydY9idCCIBNNnumqk9ahTewMQrhJ
         T08f33nweDrOyw3pKSkr1Qkrkked0vr7ZHwRDHta+TN6WG0oGzqsuhDrEOx72fBh5WU0
         oYgUXVXd1tU/mzTeQ0mzsTJviZuAX74N/jPwzeSjBiwxnyK0h0TealYMchARBmDUZIOX
         ViMp+AC7Q+jtL9fE4jDvp/Jor7sArB0DX5YSBPvQ3+fL8nmRlQu5cAOGwV0tlnPOhQ6L
         rUvg==
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20260707; t=1795796333; x=1796401133;
        h=content-transfer-encoding:content-type:cc:to:subject:message-id
         :date:from:in-reply-to:references:mime-version:x-gm-gg
         :x-gm-message-state:from:to:cc:subject:date:message-id:reply-to
         :content-type;
        bh=WcqK/TokdPrpJ1SyssRoGlfCD57QN3XIIcFf/99tphc=;
        b=dGvHZPtM/Umfdka9CqYkXuDI17uRvK5d5xljqlsvyiKF5LfWqQgJxLeJjPbOMDyyko
         51R4cWX4TG5kY3A8G2sLstYXBZZyvPzdDeEBXWNT+oVd6N0LeMTiGUqvGWsRb+ZphFrQ
         TySIuUlFK9NFHV8Tw9vgIFabldF6dwX3iscBwNOSW1Gf4y2m9TFEWFOaLUl9qzvoyguP
         rRTIQ3Nuex/31L1fxd+V2XWKPjWVeveHoZKmTYr2wQ7lzwaNNJrvRONdrmoDFrcWPiVy
         KoHAkMggrpOFXgcaB3v9dIIqIQVIWxGNCE1BAEuBxTn9bKUbuWB/gZXtl1rKYo0I0BIE
         2eyw==
X-Forwarded-Encrypted: i=1; AL+hErFWkBnQoZ8zki8ZFSXjklF6PbVFxwA1afaIVbR2V7SXzpLAH4HN+Gn4HcLFSIrueB+66IrBaF/7hPA=@vger.kernel.org
X-Gm-Message-State: APuU4Z9/+ktgSn+RVNIkthWFdZMqDzuvG1Suoj1mwUoZBgAZ7w6lsgtJ
	Hj/aHfu9ySiW2PUK4oodQSEWVl/zlAm0yvbz05Ejx7ct7FqS6tcJLnVLYEQCRYzPPaAH54FwXon
	aMnf4IMguGTN1yfYUPxpgt8d17NieKl0=
X-Gm-Gg: AZFdTZeO2O/MSByuIDI6CCPy5pLn56K1vLdueKu02NjEWTf5FPysjWeppwEuF0zQ+Gd
	8rovdD12zceWs8neMDX7dX0eGGt/Pp/SI77A17NGmt2xl2LVSdS/NXjt0RPZkeOdD+pxXLlokq2
	eLkfapqFmbtKleKC0QAhGt6SJaz/slDUPsSDlEvQExPEt5u8QeM/McUYRdpSJZ7OgrzBejsWLow
	tMRfXL6vLkRGPFCJKIfQQFsjOoOcL7KajEF8XZrxh7Qz5IMTbqcoYIVQTxzMGF7yqOfc242ImRs
	Z5Psq4Rhqa9RUNzI+6/VVCkU+yJvqesTXMGu8mfHufPOPwpHfYA8Z3v92bvGjygG+OVKAawx01h
	EkAkDFzP9x8+I6sy1tqlQhgmT2DBXL/UWzNSPk8NamRRnTnGdQDeESdExt9kfM0eTDbMmuA==
X-Received: by 2002:a05:6402:e05:b0:6af:80c4:8981 with SMTP id
 4fb4d7f45d1cf-6ba37e890fcmr19985269a12.26.1795796332918; Fri, 27 Nov 2026
 08:18:52 -0800 (PST)
X-Mailing-List: linux-nfs@vger.kernel.org
List-Id: <linux-nfs.vger.kernel.org>
List-Post: <mailto:linux-nfs@vger.kernel.org>
List-Help: <mailto:linux-nfs+help@vger.kernel.org>
List-Subscribe: <mailto:linux-nfs+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:linux-nfs+unsubscribe@vger.kernel.org>
List-Owner: <mailto:linux-nfs+owner@vger.kernel.org>
Precedence: list
MIME-Version: 1.0
References: <DMZ4VQ7SZ07T.29WMPQ0BQZGSS@gmail.com> <20261119153222.65195-1-lauri.gates@gmail.com>
 <20261127-disput-nestbau-wahlparty-c189ad680243@brauner>
In-Reply-To: <20261127-disput-nestbau-wahlparty-c189ad680243@brauner>
From: Amir Goldstein <amir73il@gmail.com>
Date: Fri, 27 Nov 2026 17:18:39 +0100
X-Gm-Features: Aa3M54qCjcbbYjv0mzgNqjSQ7Sw_WVEr_GJN4PX5Bm9lrA0JqzVoRsl7zVlER60
Message-ID: <CAOQ4uxhE38TnXseMOyWY1OvidBWew2hAYAV+rYeTPaqRYZb45g@mail.gmail.com>
Subject: Re: Concurrent FIEMAP on reflinked files serialises on the AGF buffer lock
To: Christian Brauner <brauner@kernel.org>
Cc: Lauri Gates <lauri.gates@gmail.com>, koraynilay <koray.fra@gmail.com>, 
	Dave Chinner <dgc@kernel.org>, Christoph Hellwig <hch@infradead.org>, linux-xfs@vger.kernel.org, 
	Carlos Maiolino <cem@kernel.org>, "Darrick J. Wong" <djwong@kernel.org>, linux-api@vger.kernel.org, 
	linux-fsdevel@vger.kernel.org, linux-btrfs@vger.kernel.org, 
	ocfs2-devel@lists.linux.dev, linux-nfs@vger.kernel.org, 
	linux-cifs@vger.kernel.org
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable

On Fri, Nov 27, 2026 at 1:44=E2=80=AFPM Christian Brauner <brauner@kernel.o=
rg> wrote:
>
> On Thu, Nov 19, 2026 at 05:32:22PM +0200, Lauri Gates wrote:
> > One constraint for that case: the flag has to stay out of
> > FS_XFLAGS_MASK. As I read your fileattr_to_file_attr(), every bit in
> > FS_XFLAGS_MASK is reported as supported on every filesystem, so a
> > plain flag there would read as "supported, not shared" on btrfs.
>
> Right.
>
> > Christian, with this mask on the way, would you take a plain flag
> > (say FS_XFLAG_MAYSHARE, "may have extents shared with another file")
> > that filesystems advertise through fsx_xflags_mask? If so, I'll build
> > the RFC on top of koraynilay's series instead of using the inverted
> > FS_XFLAG_NOSHARED.
>
> Yes, a plain flag is fine. It's simply the stx_attributes_mask model.
> Filesystems that have support raise the flag in the mask and everyone
> else just doesn't. I see that Amir's busy discussing some details in v2
> so maybe base the RFC on that series, I guess.

FWIW, I think the v2 posted API is a solid candidate wrt the UAPI -
The AT_FILEATTR_ opt-in and the struct extension leave very little
open questions - the remaining discussion over v2 and obviously needed v3
is around implementation and the fine details of the contract, but for a si=
mple
readonly flag like FS_XFLAG_MAYSHARE, it is very clear how it behaves.

Thanks,
Amir.
