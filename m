Received: from mail-oi2-f11.google.com (mail-oi2-f11.google.com [74.125.231.203])
	(using TLSv1.2 with cipher ECDHE-RSA-AES128-GCM-SHA256 (128/128 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id A6F463793DC
	for <linux-nfs@vger.kernel.org>; Fri, 25 Sep 2026 15:55:47 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=pass smtp.client-ip=74.125.231.203
ARC-Seal:i=2; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1790351749; cv=pass; b=mwmjLP7AmanMyin+JwinancOz7mlIjz/AsP0pfj0V0oDjcFZfXUmDwLoLuJOaNljCApGFrzbTo6seSOJHV0OGWetBLSXaqzIMSv8DiquIUyYAWdZkhNOIzotkwvI4/pkQmzeP0FPznCez9KwYacBKEIy/ZdUhHyXuF/Zb8rIUOI=
ARC-Message-Signature:i=2; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1790351749; c=relaxed/simple;
	bh=fNEDZ8HWgIsZwtF0GmCwTLByGY4becmkdcVSNKAdeJc=;
	h=MIME-Version:From:Date:Message-ID:Subject:To:Content-Type; b=NZwacwkq0OTZg93kaOO6u5mfQ+sabwCXoKi9/M6+zv2832dn1Ym+6rPM40l2G90cdiqoEVqowLMOCBd0ajFfw8ESDfJ5JCyZHaCLML7MjdygZN/bf5w95cHhVeULHmfsFfMABbkvz9xYVQMQaMeX66vwU0NbUzN2PXr4iv4zflk=
ARC-Authentication-Results:i=2; smtp.subspace.kernel.org; dmarc=pass (p=none dis=none) header.from=gmail.com; spf=pass smtp.mailfrom=gmail.com; dkim=pass (2048-bit key) header.d=gmail.com header.i=@gmail.com header.b=TNEswJwU; arc=pass smtp.client-ip=74.125.231.203
Authentication-Results: smtp.subspace.kernel.org; dmarc=pass (p=none dis=none) header.from=gmail.com
Authentication-Results: smtp.subspace.kernel.org; spf=pass smtp.mailfrom=gmail.com
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=gmail.com header.i=@gmail.com header.b="TNEswJwU"
Received: by mail-oi2-f11.google.com with SMTP id 5614622812f47-4c112aaaee4so373813b6e.0
        for <linux-nfs@vger.kernel.org>; Fri, 25 Sep 2026 08:55:47 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1790351746; cv=none;
        d=google.com; s=arc-20260327;
        b=nEdHSfzfhXL5sq/xNGXOx18hS2xXK7ZnOJT09GXriyYmdCh4H4Gi8JZ6AS5xTLZR+x
         i6ZZJ+10UUP8F7ZhhEFpyIZREIZxZkVQ/07HYPVsA8iYHlGNAjLqE8w1v8TF0azkTsKu
         BjxSVqhhCyhuiRD4lJN9hZ4FTbF74S+l+Rc4Yr7nETfRd/tGsUnMo4lMzxozQvtglqKc
         eLvpjS65OuPdm3rXsyAypJDuE8owGLYilLjwobJ4GuGKYOaq3K/fiL2v6aMTuyqs+d3m
         lwwz+zepWtAVK62qHq111XubRjAg0mgOokvXP6AD2UDvWVVUr1lYglfwy7/WlPzAOTbs
         insg==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20260327;
        h=to:subject:message-id:date:from:mime-version:dkim-signature;
        bh=ioxdiZmWaPzqzijm9AOPCSSjM4t1R+JDuC6raTuXsUc=;
        fh=A3pMOUK00huGibGCZBFsLekFLVbB5hHGKjUNNKwO+5E=;
        b=Y/49AepWeslYzMgNSR46dMRMd0IQDcSo6DauCW+QxCIqNi8vPq79bFzJrAbzWLp6/o
         iBuDvVYk241/2BU3CvSZ9FiWpzwhkvRkP3x35puvzgqjHXeJ9/aycHUY7sHmyMaf6saN
         NbywyHxv16oNNZmXb0NoUQoPG12rFQVIGAuM9/c2+wlOYylnHeqAUc518xJRoU2VrIT6
         vBbSGiMpR/nIUKRAgevWPz0lpLTiO8TyAxGSDduOrTBytg+a9PCzbUlwWF+G7pBKNIbO
         xxUna3wogeGq5NmNN0qobLkDlbt2KxTg0GF5xpSIIgo/g6fFEQiTJvJUqOvlsA3zIZbj
         zyuA==;
        darn=vger.kernel.org
ARC-Authentication-Results: i=1; mx.google.com; arc=none
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=gmail.com; s=20251104; t=1790351746; x=1790956546; darn=vger.kernel.org;
        h=content-type:to:subject:message-id:date:from:mime-version:from:to
         :cc:subject:date:message-id:reply-to:content-type;
        bh=ioxdiZmWaPzqzijm9AOPCSSjM4t1R+JDuC6raTuXsUc=;
        b=TNEswJwUHukzCTlQd+WGT9k0E6gLo212AxKJll9r+cuwmC89MARl7NT9XuJoZdjHGF
         5MDxD75su8dLkrVyxtxj3Bq8J/EmwoRdRx2w1sExJqu6o5uX5qb9iXz6VW/1skHey+lp
         KkBQm1GjXPMozyWQg+Rs1QdPWyc4TwkJAHWKfmuJsOKFIk2z4LTXLcnoc1uIXfuSxGmI
         PYBM1BIYVv0oC9Qmaacma+6NrnKvOyHMbdPNAoq1gZRx0Sm6bM+g6JHrtsRBfOw+fGBp
         gAlwMx+TcjETHBPeOY1ITjqOHqr8RkgELyViae8dPH5Aj7iqmkSbJu8x7FIfSDtOCQKy
         OlYQ==
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20260707; t=1790351746; x=1790956546;
        h=content-type:to:subject:message-id:date:from:mime-version:x-gm-gg
         :x-gm-message-state:from:to:cc:subject:date:message-id:reply-to
         :content-type;
        bh=ioxdiZmWaPzqzijm9AOPCSSjM4t1R+JDuC6raTuXsUc=;
        b=XWTp65yXxplS6UNOHTv6Ogfdk7pALvID6HDEzWns8oNzJZJqRAFxhPSPexoijSO6Iw
         xoN3mAo2wU9C8eLplaHXcDpTN/WGLkkZLbvMphjHqO7705etlRpK9q6cnCNvS7ciQ8U8
         dT1SNdLivHyDQ0E8T1agsYQUkdm7aXS2hKUoLI31iNykjQ+uBMhnV9qz2oOfrAkgpSSz
         z8bvT8IeSwKNn1bt9OxTRQBk96v6XUzYLbVdK3PjAZ09b5pSrC7UdVV9sba8oOGfipIg
         02ZAEVIfqgufZWLXKRsOiYGCARjPdUkpauK9gcQO546XaFF1YrYMNOGYH2Oclcla3f7X
         EyEw==
X-Gm-Message-State: AFuF++nB96nzXC5ZniiabqlTaQ06DkILEeq6DFQGwBp5Kkbz/waO7uYK
	+rkdVKKyKilgrgWlUQKw/RUJMZoYotF9aNf0uGxT82GnSMsSMkUdMe0XvusWf6sJFVerRqaVLhG
	9P1FRhjCpIb1otUqjqtqld/CLfzVBcvSqs34nEu19mYIUh5A=
X-Gm-Gg: AYBFou0RXwPEERcRKMD/v7lM6k/2qPlWVQnbALebU/E7YYV4MVXxcmEEMKCQEjvhSuF
	TC566Gg+tbhV4I8xqnmiXFoMYedg2gggP5BVKBwNqscoKJya4zS/HLbFfhfkNMItdCSBHj4uMao
	Zq9Hqjf9MUbgKL6GIY4cSqmWUSt3dsI7FQPF4gwufzIxUoDZxwP9hf43lfS6SLXG5Z72Pfie59q
	IVvZozqsKWh78Q0pH2sCe7QiP2d594HkpTdjrOK9eLZkTPq8HVrvclhXpoRVqaLwe7HbGk/KUzn
	oaxxZPtEj+WM0KCFUo2CSqQC0+Wu72/98fDf4Agufe8Jh+oTvwGlZCE=
X-Received: by 2002:a05:6808:4494:b0:4c3:440f:d7e with SMTP id
 5614622812f47-4d72c042e68mr6278643b6e.13.1790351746275; Fri, 25 Sep 2026
 08:55:46 -0700 (PDT)
Precedence: bulk
X-Mailing-List: linux-nfs@vger.kernel.org
List-Id: <linux-nfs.vger.kernel.org>
List-Subscribe: <mailto:linux-nfs+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:linux-nfs+unsubscribe@vger.kernel.org>
MIME-Version: 1.0
From: Jasmin Dave <jasmin.dave.math@gmail.com>
Date: Fri, 25 Sep 2026 17:55:10 +0200
X-Gm-Features: AclHuK_YqUKd65Oo9dyMCkeywcPIXRiAwTEDCk3S4jdnkeX1ZvlaTw1FO8WIf4M
Message-ID: <CAHvsQGPXA+boPzZ_87XoxFFSn8-2TNhMXnmR9Rd+jB9dFcF+Kg@mail.gmail.com>
Subject: Multilayer auth with Linux NFSv4.1/TLS?
To: Linux NFS Mailing List <linux-nfs@vger.kernel.org>
Content-Type: text/plain; charset="UTF-8"

Hello,

we have to add multilayer authentication to our department NFSv4.1
servers. We already deploy krb5i/krb5p, but due to gov requirements
around NIST2&friends we have to add another layer.

Can NFS over TLS help with this? How can I set this up?

Thanks, Jasmin
-- 
Jasmin Dave - Math (Quaternions!), Coding, Simulations
