Received: from mail-oa1-f48.google.com (mail-oa1-f48.google.com [209.85.160.48])
	(using TLSv1.2 with cipher ECDHE-RSA-AES128-GCM-SHA256 (128/128 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 8D237401A33
	for <linux-nfs@vger.kernel.org>; Mon,  7 Sep 2026 07:04:58 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=pass smtp.client-ip=209.85.160.48
ARC-Seal:i=2; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1788764700; cv=pass; b=Ud8TzNmBcUa+1ebk7/C6cWpyPYEaGP3490Z5U//wo2oBqO9Xht9OtrqlOz5+DC+6XFqByyyPXoXu7P8ryqqBirxNq+Xbf+E3ZGmbFH0B7aQPc89+3Oy2l/EZh2rPN8qapJFDCOeXC4xUCUf5zS4h60YYP2sGH4Epg1/nz/hTQ/4=
ARC-Message-Signature:i=2; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1788764700; c=relaxed/simple;
	bh=0CCGiiIeWvPb4311KaiE6hW5g0F/hpyy4lrowmZQ8TI=;
	h=MIME-Version:From:Date:Message-ID:Subject:To:Content-Type; b=TQlTsGH0WOwXnrCvIZl4UdxrGWYAb7AeDWt3F1sIJWHLIiIyFYV4aJkaX5yMfrWKXydLAK639s3TNu84j3sngu6XAMc91V2fqV9eHCf14QdSpP09kfG5rCthvIBMIGP/t56o3LCp9coeEOkTTaoo3CNTiDgDKoZeeERhRin02xM=
ARC-Authentication-Results:i=2; smtp.subspace.kernel.org; dmarc=pass (p=none dis=none) header.from=gmail.com; spf=pass smtp.mailfrom=gmail.com; dkim=pass (2048-bit key) header.d=gmail.com header.i=@gmail.com header.b=EAY1doR0; arc=pass smtp.client-ip=209.85.160.48
Authentication-Results: smtp.subspace.kernel.org; dmarc=pass (p=none dis=none) header.from=gmail.com
Authentication-Results: smtp.subspace.kernel.org; spf=pass smtp.mailfrom=gmail.com
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=gmail.com header.i=@gmail.com header.b="EAY1doR0"
Received: by mail-oa1-f48.google.com with SMTP id 586e51a60fabf-46adfc81112so1886515fac.3
        for <linux-nfs@vger.kernel.org>; Mon, 07 Sep 2026 00:04:58 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1788764697; cv=none;
        d=google.com; s=arc-20260327;
        b=KMpKvKn3zblpB2YSgC0mwCC1xDNFF+cAhr8E+HCtHKGKRxQUxknSqlHiPs5TFWiVRv
         YsVqZxkbzAhOJWs7TuH1HAFEiZBBfdbQDPbcD6myqfSwJSz5Y1SjHDO87GomPFF5oVqv
         ucSsGDkExaHUwhu8hMgsn7NzIuscdmTQkfREHw5c6V1jpFzcD/ZcTf2wMCFQbLlunkjk
         ek7B39EAay+DJu79e5dzvaWDtcZzLBbTNAWxsIAHSkvElqdpa8NW9sK8TG7NfRggKjAI
         gPPmO7WTPBbFUnqS6Frlf+/tSLyP1bCEb1PlcD1m8mVdLOPYDkom8NU/4CSYvTSZcXx8
         wzqg==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20260327;
        h=to:subject:message-id:date:from:mime-version:dkim-signature;
        bh=0CCGiiIeWvPb4311KaiE6hW5g0F/hpyy4lrowmZQ8TI=;
        fh=iH8IFx3HN3IphP1osPc0S1Tkr8PGuPvup4sf6JWGuQk=;
        b=pMyGKtwMasDAAsPQY0bjbvyVrxQcGA2fS6ReJ6Vmd4rXk77O2ua4QCaUqTkslfAS2c
         8JciENNSjwhqtQweLwVA+/lKSuuZw+2qvp4BYivcUEtDk7Zu7BOo15VdauS90jVAT+dE
         QX3URCl01Tn0Mtt7UWgfR5T/9QD8Tkut77aPSMD+IrJPaW3dlQhm9SYfqZhdMDqfgvs3
         AAKOSVA1QGbQXdBxwDkhvUzgrY+rY/EX5YXNzz7FcBNG6s6WDmLBOcrdiJaBamw9tMzj
         LPTq0jzfHZZ6oyfc7CMdS+SBG4H8pWquqEMmcoMdACZwr5V6fV/smfHAcxXfGbAmaOCm
         jaSg==;
        darn=vger.kernel.org
ARC-Authentication-Results: i=1; mx.google.com; arc=none
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=gmail.com; s=20251104; t=1788764697; x=1789369497; darn=vger.kernel.org;
        h=content-type:to:subject:message-id:date:from:mime-version:from:to
         :cc:subject:date:message-id:reply-to:content-type;
        bh=0CCGiiIeWvPb4311KaiE6hW5g0F/hpyy4lrowmZQ8TI=;
        b=EAY1doR0vKrpWYpSiaBF8N8ri23sVrcKuYybaKmUXn18GgOEvsycCDz0FjumUC0rEX
         rvYizNu/pUos5814olQY2eHLlvdMG7ZND8i2E93LhG7eSpbd02NjIE1QprW4axHNHUhY
         dCEYCpIvVHTVidZdnSXlfSgGyS9aYeM5Vbha6MElqpL4QK8MorRJ+snj16BW7NTdw1zS
         j4qfbAUokwl/dVpqailJF5/4QxeSoZ68lLuNwnocX6bh8FeUF9GqWNtgBBKkUBImNXOy
         H+jHdeN4n42zizYK6N3EHi89O+eQURIkQX4caOG4mVSdkHnJyZAO1sQBaLWqk+vhuHx3
         qpIQ==
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20251104; t=1788764697; x=1789369497;
        h=content-type:to:subject:message-id:date:from:mime-version:x-gm-gg
         :x-gm-message-state:from:to:cc:subject:date:message-id:reply-to
         :content-type;
        bh=0CCGiiIeWvPb4311KaiE6hW5g0F/hpyy4lrowmZQ8TI=;
        b=MFBStXCq9AOzwSbOpEcXx2A1Gl/Up+tBOj1NUNqDL0TCsZPP1EBLFpcQGnfoTm3rbc
         DO5TrZUqPA1dnQuHgdoVwgKorGfSukqw3nW7VgrH+19TyC+vXwFtKUpP7AQyoQG9CZf7
         1f/tSWl5gH0+M2za4wa1JVIBgtSlNiaEEUFjUfQ9eEigkexW6El4FG4KzP7W6LerBicw
         iOPyK6lEgrRhfQNtDZjUl3mBanz47rEG3/LnJJFazrrm+w7dtS+yz4EjVBZ4UasMVJhe
         NlolODNPfneyjV7U2+ZMHzC3Q+WHI3AptsMovGjkKP39/nvK5EFxNQUloIfhV8zZL/gg
         +a8g==
X-Forwarded-Encrypted: i=1; AKwUvBy9YyHzq2LQNi4kg3VNZtkB/za7a9bYx3in2zbbQWqPZFLRyordgCiykK0O9y9aor80MvQYC+KgyDw=@vger.kernel.org
X-Gm-Message-State: AFuF++ksFgrg5Wh8NLMjdvAd9GvyYZgfqHmFBXLZFZ5kjlGmtB7BBYUt
	/uFdvFjTJRFrNdI3R8LWfJ0bzGUS/Ul4m7c2+GR2idISK3REpvlJ7gpIDkwgFlnSxhQS4U5PhWo
	wYCUUU2SwOYq9uiImE/hM7ztxrhzrYsyKzA==
X-Gm-Gg: AYBFou1Zs/0Vj9ThPRW+ItUbnL5VD26R9LWdegaI8qYrspw0LGA/21ebwgeT6cpwUqy
	cL/v5lLkXxeXrHjXr28brtyOzm9XnASnUXkfPecHgCAdsQtaUcs0/o+pOdDK55vJ0TiUlEuIdVx
	BH0YmFhczgCC2Q6I+O1TUqqs3hxl55MZxxT0wLr5261J5BytIlh6JLbnlvC+Kdl2tw6SmE7hFmq
	kAeMZeKxBuD//QX9/SyE8EOUv9IMZEngWODbg9Z5VfNjJFvuvFi7m+zem016TCIAJXzuQGWx6KU
	m2iPWVhJf0trteqkhJu44ZOdsTDn8cn8dlD6vfkYAe36Iv2zyDL2+ZNa
X-Received: by 2002:a05:6870:1d1:b0:463:aaa2:3b8b with SMTP id
 586e51a60fabf-4754e35c295mr15228955fac.0.1788764697367; Mon, 07 Sep 2026
 00:04:57 -0700 (PDT)
Precedence: bulk
X-Mailing-List: linux-nfs@vger.kernel.org
List-Id: <linux-nfs.vger.kernel.org>
List-Subscribe: <mailto:linux-nfs+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:linux-nfs+unsubscribe@vger.kernel.org>
MIME-Version: 1.0
From: Cedric Blancher <cedric.blancher@gmail.com>
Date: Mon, 7 Sep 2026 09:04:00 +0200
X-Gm-Features: AcwNN1WX3ynF3X-j5HJRN244xmyDUXV8w1aYNehSUD95Bn5SbhY5Vc28pCQPFXI
Message-ID: <CALXu0UcHNQMV0nfuGKypCM+rR0t5Jovj+f+h50yffQyj0eO+EA@mail.gmail.com>
Subject: Linux VFS layer+nfsd name cache case-insensitive filename matching?
To: linux-fsdevel <linux-fsdevel@vger.kernel.org>, 
	Linux NFS Mailing List <linux-nfs@vger.kernel.org>
Content-Type: text/plain; charset="UTF-8"

Good morning!

Below is a FreeBSD question, but I think this applies to Linux too:
How does the Linux VFS layer handle case-insensitive matching in the
name cache? And as an extension, how does nfsd handle name matching -
callback into VFS layer?

Ced

---------- Forwarded message ---------
From: Jasmin Dave <jasmin.dave.math@gmail.com>
Date: Mon, 7 Sept 2026 at 00:54
Subject: FreeBSD VFS layer name cache case-insensitive filename matching?
To: <freebsd-hackers@freebsd.org>


Hello,

Does the FreeBSD VFS layer name cache support case-insensitive
filename matching?

Thanks, Jasmin
--
Jasmin Dave - Math (Quaternions!), Coding, Simulations

--
Cedric Blancher <cedric.blancher@gmail.com>
[https://plus.google.com/u/0/+CedricBlancher/]
Institute Pasteur
