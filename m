Received: from mail-pj1-f43.google.com (mail-pj1-f43.google.com [209.85.216.43])
	(using TLSv1.2 with cipher ECDHE-RSA-AES128-GCM-SHA256 (128/128 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id D4D7735AC00
	for <linux-nfs@vger.kernel.org>; Tue, 14 Jul 2026 16:28:51 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=pass smtp.client-ip=209.85.216.43
ARC-Seal:i=2; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1784046533; cv=pass; b=rN//csf72MYRo/mjow5uuLGe2TAGzEANdZJpa/0L6qNxyoqiAvswb6twKxmS6wZ6mJhSwHwDmLNt8ZTlVgZWIV8ljy6hwu5IBCJvvM8K3SNZG0oO28omG8UmZxrKIx9lPBm23ydh2pDECrpR1AUvRY7M6qBZnCWJyDGGKgC4Xl0=
ARC-Message-Signature:i=2; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1784046533; c=relaxed/simple;
	bh=r4ZPvkO0PIZxr5jG05A7aDkTNcKWmjPv1UmdQa03p9c=;
	h=MIME-Version:From:Date:Message-ID:Subject:To:Content-Type; b=lfp45KPhWPCodlUQMn6yJ6dkDL4rXT5MFjLZrJ38odGkSqkAGuF45gwf8JDateIGvJEAQMMmdAUEU3MIz7Yea0I4nXG1f6Gdh3zG3rcqxM6USAh7TnFvP8Vk6gRFbXZjA0QRne3d18GlUZZggodCc+7lxuQOTW1/hWXkRpuMTZU=
ARC-Authentication-Results:i=2; smtp.subspace.kernel.org; dmarc=pass (p=none dis=none) header.from=selfcaring.info; spf=pass smtp.mailfrom=selfcaring.info; dkim=pass (2048-bit key) header.d=selfcaring-info.20251104.gappssmtp.com header.i=@selfcaring-info.20251104.gappssmtp.com header.b=feaEwNie; arc=pass smtp.client-ip=209.85.216.43
Authentication-Results: smtp.subspace.kernel.org; dmarc=pass (p=none dis=none) header.from=selfcaring.info
Authentication-Results: smtp.subspace.kernel.org; spf=pass smtp.mailfrom=selfcaring.info
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=selfcaring-info.20251104.gappssmtp.com header.i=@selfcaring-info.20251104.gappssmtp.com header.b="feaEwNie"
Received: by mail-pj1-f43.google.com with SMTP id 98e67ed59e1d1-38d489b6b71so4416193a91.0
        for <linux-nfs@vger.kernel.org>; Tue, 14 Jul 2026 09:28:51 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1784046531; cv=none;
        d=google.com; s=arc-20260327;
        b=NAoXgmShkEnACp1lWHrqk7Q5srdFadN5LNgHw2Qkf3gC1qPXZLrbbtF5VsYue7leeW
         mtF+Pxs7ljXpjkqtkDNxYSw8g+4vSAt505tsoFkgNSDTYQfa5Yfh23/XqTHdY9P0Pa0y
         3iXsq54kCbjvXOzoDxxYYBEomMUobTdPubm3scRSLGxAIrV7Z7f06r5PMg/nZcLOtp+u
         E7vAX1up34jEyrH+Y1qlm2ktfpdb7WCZHy1ace8B3pfMMMV89CPWsBEQhNIwSQBfXNUK
         g2jqkT46Jcmj/VmYARhe9dqhYgCBI6diYFc/98bARPBvDFgpUOYDzjz/cJiOEHMtFk83
         Dd/g==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20260327;
        h=to:subject:message-id:date:from:mime-version:dkim-signature;
        bh=r4ZPvkO0PIZxr5jG05A7aDkTNcKWmjPv1UmdQa03p9c=;
        fh=Mys3y4MwsHRytUQMpdfGBn3oGRYLcLloxNwkFYMYMmg=;
        b=ph5hKCCApmv/vh2GknxQ2Y7+F17BQ8bbrS1u10q/Aw6vj4SMM4tEsZajFQQuGDbrfV
         fOUOHkJ/572wnPAvKkiodkEcYHWVlsjOryWUWPQyZEc7AoN0jw0jEEycQerSOMWT4Pj+
         BHL2bCWKHSSnAqdndqzPdyVCAFd0wUoaoPYO8GZsH9mJD9UZGXza5Hqb5EgWtuEPUNh0
         Os+AD8RJhX8+hL+lTNNKiD4ldmVAvKbY0JYi1I94hKbNYhBTX04jO7jvEpbTGpbNOG21
         /i/1e1qC7vGqeZ4xVWDgaU4jAep2qCavgbyM+HWFtaDdPWf1vz4ggINaChhyTc4hk366
         yMvw==;
        darn=vger.kernel.org
ARC-Authentication-Results: i=1; mx.google.com; arc=none
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=selfcaring-info.20251104.gappssmtp.com; s=20251104; t=1784046531; x=1784651331; darn=vger.kernel.org;
        h=content-type:to:subject:message-id:date:from:mime-version:from:to
         :cc:subject:date:message-id:reply-to:content-type;
        bh=r4ZPvkO0PIZxr5jG05A7aDkTNcKWmjPv1UmdQa03p9c=;
        b=feaEwNie8KXh85bqJC8XYufRhQiQf17ib5Azk4DHivl/6HB8/2gNVwio2Mz0TZLahB
         TY7mTH/Sw+WGnT+EQ8bz9Idsek7xY2rC10TY6of7gaDNxzXH9jusTGZKFqvcHBD48Wva
         x0HF6GQrkKDV3y+8gz87ZUVZtNRmNdiKejdOvJ9FRE9lo8QGg6F0KCk/0mfGD2QfqgWi
         JLVA0hV2zb3lXgaQgZkycUzwTqkGBZFX2M01P35SFsX85G2teecWryTNq413qzMYCCT0
         BeajbRdpnNoJrZ+UM3VrVqX9171oZMuHxXbktGoJge+aqGJlurKM9QVSgb42iHDSaL4H
         Q1Kw==
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20251104; t=1784046531; x=1784651331;
        h=content-type:to:subject:message-id:date:from:mime-version:x-gm-gg
         :x-gm-message-state:from:to:cc:subject:date:message-id:reply-to
         :content-type;
        bh=r4ZPvkO0PIZxr5jG05A7aDkTNcKWmjPv1UmdQa03p9c=;
        b=OFUwsDM3EUXvMtyUrG0c+CJqJ2xyhwczQ3LZCJZ7atBAYZRLAgqRTxXXZqJte2haQY
         V2ha9MVSsjsTz/XMTev1zZOFEcerDoRF4ouzG8E5Us1J7WKfikma8IBkDpii80iYXj/8
         ackdR3ZKdLDaXmgZotVURszelJQIaEQgx6MEXJRiRwue2QBdkyVpfqFCmeNi3xAvds/0
         hXBTtrpzejVBAHU4jo28vzQCk0Wqq0ohtezUIsq5LugFPpxdtXVSYGNHXh5bf6nfA5v2
         5Ao5jDtWPX4T2scvnBC6hPKjKpAXE8KxVK5SDS5ZF4noDFfFTOKvoEac08BkkAIQK1Ja
         ReaA==
X-Gm-Message-State: AOJu0YzRG5xGAo11ZlUUDxOa7eOXDrbeSE5Pp31qe9YblyShhvyqFx+/
	aulpfrY4tYYXgsc1PpxN/cJRY5ud7ZUSoapWUvPxZgUN7qNNnIXLWTYUYdYsdoh2L00tRtNMe7I
	281eZHCsDgpuSBDzoqCw4v8zAVc3Xax2HaYCsLKVngYaiUGMNLSD7
X-Gm-Gg: AfdE7ckdsZE9atKBcFYD99LYnlEjjrdZ4XxxKDc2ALBhvG2Kge4xH47c6K4C5akU/S5
	2gEogas27/jgIXi0xp+i6nfGQdDTwyDAH4lGRs/jw/ldxUgkB6+2t+UmLw9w4CGW/zKuiLekN+h
	rQiv7a7KiEm/cK6IzhSPu0RXBk1LA0h7qZzSEHCqAjvmkU6QytMaWnwUPQyHT+3+s9xsRRlWXa6
	AJpYbquIxacE2lvT0977qr5AH32HZ71YTTEQ15oGrTbgLlppVczqHVVM/r0vvzUPznXlfL2I7O/
	CQGyf60z9juqxh5ifs4EZmDH4g==
X-Received: by 2002:a17:90b:3951:b0:37e:b6a:6cdf with SMTP id
 98e67ed59e1d1-38e17e44414mr3813424a91.20.1784046531193; Tue, 14 Jul 2026
 09:28:51 -0700 (PDT)
Received: from 785115219520 named unknown by gmailapi.google.com with
 HTTPREST; Tue, 14 Jul 2026 12:28:50 -0400
Received: from 785115219520 named unknown by gmailapi.google.com with
 HTTPREST; Tue, 14 Jul 2026 12:28:50 -0400
Precedence: bulk
X-Mailing-List: linux-nfs@vger.kernel.org
List-Id: <linux-nfs.vger.kernel.org>
List-Subscribe: <mailto:linux-nfs+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:linux-nfs+unsubscribe@vger.kernel.org>
MIME-Version: 1.0
From: Brad Krause <brad.krause@selfcaring.info>
Date: Tue, 14 Jul 2026 12:28:50 -0400
X-Gm-Features: AUfX_mxmMmioNqwLQy8iJyeR7M9MrP3ExhlJg13vAXHsBjYkxZfM91RST5JnH8s
Message-ID: <CAAxYpsa0vbQsMhaA2bO5gPrWfTRS+58L3FmpbvnO4tEXwkU+vQ@mail.gmail.com>
Subject: Thoughts on Our Collaboration Idea?
To: linux-nfs@vger.kernel.org
Content-Type: text/plain; charset="UTF-8"

Hi,

I wanted to check in to see if the article proposal on self-care
strategies for cancer patients resonates with your audience. I believe
these insights could greatly benefit those seeking support.

If you already responded, thanks for that and sorry for the repeat.

Best,
Brad
