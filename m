Received: from mail-ej1-f48.google.com (mail-ej1-f48.google.com [209.85.218.48])
	(using TLSv1.2 with cipher ECDHE-RSA-AES128-GCM-SHA256 (128/128 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id A68833515F3
	for <linux-nfs@vger.kernel.org>; Mon, 14 Sep 2026 12:44:48 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=pass smtp.client-ip=209.85.218.48
ARC-Seal:i=2; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1789389890; cv=pass; b=bjbXXAMjNi9VstAOvOnpk4R26Dd3HuFDSzh7YYyYT41c3rCs2vbPE55NdED/+ev6VV/95ED7TuftBN1S5/zdVU8q71P7uPbNDW1Dou51Ujls8t12AZPNZ/ess8uoYV+qd5RxjIcVDCvPP5OQZZSHZA3/PAlW79TuQiOgM6fYEoI=
ARC-Message-Signature:i=2; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1789389890; c=relaxed/simple;
	bh=WbjWLrJuytRFM91Ma1nL9r4IDIukQz83BUCOmZATXZs=;
	h=MIME-Version:From:Date:Message-ID:Subject:To:Content-Type; b=nfM65MDNtqBa6+X2Fxs+4U/M7Q5jWGy2ySbnzpw/6PT00/WNPBPVV9TqdbmQRdKJaST9uKBAN6q4Da3KcuzGg7nM2vV54QxLnU9lzgOodOzTpIeG0YUdBj6eHhWvczQQNZK/EVMa0bqjHrKDA5Hji2JPz0M5LbvyOku/qgHNUY8=
ARC-Authentication-Results:i=2; smtp.subspace.kernel.org; dmarc=pass (p=quarantine dis=none) header.from=dneg.com; spf=pass smtp.mailfrom=dneg.com; dkim=pass (2048-bit key) header.d=dneg.com header.i=@dneg.com header.b=pOf2z34I; arc=pass smtp.client-ip=209.85.218.48
Authentication-Results: smtp.subspace.kernel.org; dmarc=pass (p=quarantine dis=none) header.from=dneg.com
Authentication-Results: smtp.subspace.kernel.org; spf=pass smtp.mailfrom=dneg.com
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=dneg.com header.i=@dneg.com header.b="pOf2z34I"
Received: by mail-ej1-f48.google.com with SMTP id a640c23a62f3a-c262204cc80so447356766b.3
        for <linux-nfs@vger.kernel.org>; Mon, 14 Sep 2026 05:44:48 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1789389887; cv=none;
        d=google.com; s=arc-20260327;
        b=dCCcZkIFRQiJwj0wDLWEeIhTP8EPUA6DXf4pASonVchZSJK9LrxOT7agBoSXB1GCfN
         unXLKOgI7tJocY46KnhDlbMXzLFzsoA6aHrzyC4M2LKdfHfz4RrQNXcoI5rQd4KhV++f
         4u9giHurDjySa44nlHLhc/T/yRuXMyc9s9iyxcYbBu+T5PnaOQHwRgQ9qKjiTtcI/sgy
         XONmYUoCqMIeSdC/QAp9FWgMYCoRv5sXpNspNzwMn3qQ0eyCccCaiYx5hRU2NmDxQ8Fe
         TG5PwaTHdelsSp5HXxtVy4/U9dxhQtgBQoTKY69mYAkK3h/VL2QozBzqM9rimFc+t5/z
         hw3g==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20260327;
        h=to:subject:message-id:date:from:mime-version:dkim-signature;
        bh=WbjWLrJuytRFM91Ma1nL9r4IDIukQz83BUCOmZATXZs=;
        fh=A6VhHI7NKHnmfjjs9vgKiwsl8TnYIjA9XaJXQoRXXsA=;
        b=bWu30r//QUr8PmzWIYQEIooTXVUrkUOVNfFDxQ2zMWcTrGG3vVMT3xTYgh0VcnUopO
         xa8lca+E3K4mIv22/vpvwvnTAnO62uAeWloQhtTVnuMOiEJK/sVejmmCGiOjbc/T00go
         UJNEjK2HLy7Oiu23oWI3YnQ3gdLevA3TDuv37lclHTIXnE6asdfWjBX6qB+8Jl/xsxwy
         zxRmC6FzbiyIFLclF9/NC4/JS2qkGnUDrVrW6roAGtiIDAdXf/H32KapO7UXXOUwkGG9
         BsZiR7Ag7cqlVlqjPCJgLk4ipaaO8r7FW5gw1vSYDf67T4dFDS6QqcuQc8MfdxaL1ldO
         LEFg==;
        darn=vger.kernel.org
ARC-Authentication-Results: i=1; mx.google.com; arc=none
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=dneg.com; s=google; t=1789389887; x=1789994687; darn=vger.kernel.org;
        h=content-type:to:subject:message-id:date:from:mime-version:from:to
         :cc:subject:date:message-id:reply-to:content-type;
        bh=WbjWLrJuytRFM91Ma1nL9r4IDIukQz83BUCOmZATXZs=;
        b=pOf2z34IXptnx7BN3qQ+ibIuQQax5jKR8yk9Dp1tTIJA0BsbvzQwPbYyBJX4V+WPSw
         KNhN7fZ5CyxLIJZJ7gvVkBtLIcWwoF8CvcREegMqC7x6U8XN0d+ZzWirxnawON1GSQZD
         YDO5MHcAD9TZxqX6eV6mFxc4/2KgrhoNdZCeFmwg8AAstb8Ujlg7iHmzOAVGVENzeaDl
         7M9qKuXRWO5+nl+U1fyAsa4ry90he83B+IKCYNIw8iwcB6KCxPJADGzo3OY2kUu5tuAS
         bPxi3J0+O7B8fpOT4wqpb67WhrpAC4PnK1+zsgtk8FqBvdeshg1XMbH/kDRj52gKlUH5
         IqMg==
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20251104; t=1789389887; x=1789994687;
        h=content-type:to:subject:message-id:date:from:mime-version:x-gm-gg
         :x-gm-message-state:from:to:cc:subject:date:message-id:reply-to
         :content-type;
        bh=WbjWLrJuytRFM91Ma1nL9r4IDIukQz83BUCOmZATXZs=;
        b=USxjpdsJI03MRTBXKULorsqorSJLIz3qJId/lcsKzGTpz5qBXwkZNxOCLFYyf5796Y
         FCh7CKhhGoP2yh3wJMdLgXjd8cqISWStjzOl6GFgijEm03UDO2WUL46qsI/9QzJ7Jl/M
         rIwSdfjR4UmChGWligit9Y6mzDj+Z88b5Vp9UOmWpYVDr7Mic6XQuwJTLhE7VQ90n3j4
         w70rl1HmzdkUbg3AzxLKRTN7fpzpLlgQi3vlzaSqgWh39JmjeGNss+7ub/wW1M8sgJuZ
         68kAYSiyVDbs3d8WTYBblz92b1KTy/RIu+jjo+TkYzTj+6c/GUVIqw1EwTxbxnCP3BD2
         edgA==
X-Gm-Message-State: AFuF++nBQyaFRJh+NFTuV6QV5YiliLjl/v5vGd0M6bbI8/A9HJ0o/+uQ
	mfeACYGarwDJC8SOBDBTdp5y1/u0Yiu8F4VPy8Ic/DzgKfpYOJUuxNU9Y1Fm9+9D9VmQjr6NZ/3
	IrG6U+kl6O9YpNSuUExF/PjeqUTqmAh5xOSsA67d++Mk1qKstBtTW
X-Gm-Gg: AYBFou1vNAevQbXZihRCT0JXyHme65dfn3UCr7jOIc9b6/T4PNJZjpM/sDXKewTwZjP
	jICqZrUCqDcp45Xnn/+Kcp1t10dGJY5J5G7wnlVQ02bd9VlRHIUNI1w+waDUkHMe9R4VyiF3k/w
	uP5wFs0zZC3I5+AExEWgPNTA2MumcIkTOvp+KNBF5LcxoO2Q+zWIMxvPGLCcJXUttPLYzgai3dn
	rxajK4G7lagS70D3tP5a8ic6r/E8FW2+d0o60siZgCmpmqAhNL+JS6S+xv2UJXU32o2bECf6U4A
	2HzEgkKWKWUCZm/7/si/Nv9MJsVjZ0PFEuswhG/12GYqEqGWxMmRMaGIvkxiSymx/6K7+nPNwPV
	Dhy55mj59GWg=
X-Received: by 2002:a17:907:9616:b0:c29:349e:7c1d with SMTP id
 a640c23a62f3a-c29b879a34fmr151538466b.49.1789389886743; Mon, 14 Sep 2026
 05:44:46 -0700 (PDT)
Precedence: bulk
X-Mailing-List: linux-nfs@vger.kernel.org
List-Id: <linux-nfs.vger.kernel.org>
List-Subscribe: <mailto:linux-nfs+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:linux-nfs+unsubscribe@vger.kernel.org>
MIME-Version: 1.0
From: Daire Byrne <daire@dneg.com>
Date: Mon, 14 Sep 2026 13:44:10 +0100
X-Gm-Features: AcwNN1VGajW7D4epoXNFKejHy3O2RTOJWTCediBUQzGJy5Mp4LZScZB4CPIPENk
Message-ID: <CAPt2mGO-08X5h-v2Nm9m8E4y5X9V3BpCcoSZiqW6rd-siBBAmg@mail.gmail.com>
Subject: FS-Cache/cachefiles not writing data in v7.2
To: linux-nfs <linux-nfs@vger.kernel.org>
Content-Type: text/plain; charset="UTF-8"

Hi,

I was keen to start testing the various scalability improvements since
v6.18 and so jumped straight to v7.2.

But there seems to be an issue with fscache/cachefiles (mount -o
vers=3,fsc) whereby it is creating the sparse files on disk, but is
not actually populating them with data.

I checked v7.1 but that seems to be working fine. The only related
merge in v7.2 I could see was the removal of fscache as a backend for
EROFS.

Maybe that took with it something that is affecting the NFS case too?

Daire
