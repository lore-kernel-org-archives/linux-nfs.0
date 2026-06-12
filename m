Received: from mail-ej1-f50.google.com (mail-ej1-f50.google.com [209.85.218.50])
	(using TLSv1.2 with cipher ECDHE-RSA-AES128-GCM-SHA256 (128/128 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id BFC073C0A09
	for <linux-nfs@vger.kernel.org>; Fri, 12 Jun 2026 20:18:40 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=pass smtp.client-ip=209.85.218.50
ARC-Seal:i=2; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1781295525; cv=pass; b=kB3LLg4wOQKq+zBBZIuUPFykYtXXgmEGBrqlieyzlYbHTkkGBU+ZYPVIwQuEhpZdwL0EvKvzsYUd8NgAUfHry55T4B7lrgyxtFFSOEJoIjaiXRkuPYiGxN04JWce1g7s/3aNdmZjUXH5vyp3obvB60d4Zd+eZ7iuyjlGYqiPVxM=
ARC-Message-Signature:i=2; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1781295525; c=relaxed/simple;
	bh=5A0XLoDWHSZQyPjX4MHAlPTHjEtx0svtMgsKxzyunNs=;
	h=MIME-Version:From:Date:Message-ID:Subject:To:Content-Type; b=eEO94Eh6vL0SAzbZoKahu2MOxMdkw8gZ71cvETZDInAcTpE4OkHL3fSJQZ+qZEhPjhgW2KAIE2HA0OpAazC5X8sON9yCldhgil8lpzf1kdGAY5/IPk2r19597dZEBXqLzeahg1Z0JOk6vn/ECam0P9AHo0Zol3o/w7g1LXm8lKI=
ARC-Authentication-Results:i=2; smtp.subspace.kernel.org; dmarc=pass (p=none dis=none) header.from=soloparent.net; spf=pass smtp.mailfrom=soloparent.net; dkim=pass (2048-bit key) header.d=soloparent-net.20251104.gappssmtp.com header.i=@soloparent-net.20251104.gappssmtp.com header.b=UWsGK+8w; arc=pass smtp.client-ip=209.85.218.50
Authentication-Results: smtp.subspace.kernel.org; dmarc=pass (p=none dis=none) header.from=soloparent.net
Authentication-Results: smtp.subspace.kernel.org; spf=pass smtp.mailfrom=soloparent.net
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=soloparent-net.20251104.gappssmtp.com header.i=@soloparent-net.20251104.gappssmtp.com header.b="UWsGK+8w"
Received: by mail-ej1-f50.google.com with SMTP id a640c23a62f3a-bebde89cfd3so170146866b.2
        for <linux-nfs@vger.kernel.org>; Fri, 12 Jun 2026 13:18:40 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1781295519; cv=none;
        d=google.com; s=arc-20240605;
        b=lYskdn1DNcFpssDtPQylqcUvGm5hzaIIPidE4d2r2FyeRkJ7zems9l4eCX5rMV+oOd
         8xs/pxeLT7z8zBGr3H4t6OvQ4mlDa7hBU7PHZdAQVlJcS6QpkKDIXqYQ72vGURwSgj/U
         /PHn/y9S2NbcWW9zW/hTzk/ktc1cevXJVYqG5G4c7UagmJjkDPMfg2IwnIlD4eLAq551
         2oXq1c9ROxcn2bFyCjb4+rR/h0SyHmUSQY6rJCnsoLsF47d6ONDSK6Yrm2wt/80HYVw2
         +uCN9wbDLgkdQJO0c2LKTTkywt/F0VpY9QS+BUEvVe0CwhcX11cokg2rkWnd14keUd6l
         cRyA==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20240605;
        h=content-transfer-encoding:to:subject:message-id:date:from
         :mime-version:dkim-signature;
        bh=5A0XLoDWHSZQyPjX4MHAlPTHjEtx0svtMgsKxzyunNs=;
        fh=Mys3y4MwsHRytUQMpdfGBn3oGRYLcLloxNwkFYMYMmg=;
        b=aFaMHXER9IpGctY9HaFYkigPB1wDg08Iz/RGe4kb2lS6a6UX5HoYPoSnrSRg48wNyp
         18fhUkOtAJNigOzdhvCljTHFHq3P8Z7bMC+17l1cvquQGMP+T0QBWqQoScUkCQH3pGKI
         LZVHSGGVQrDicCf+rLqmOyunwBPoMII2A3QSuFqfYyE0CcZ3OdWz6Shi5ZTIhJQ/sRAn
         8DFS0N3vjHM0E/MB/1+kDIq+FN3AddJxeR7SllIPQlxEFk/JxbacdPQZJMfqZTITlZ9i
         UmoqQm8nhgr197Y9YG8ZIOzfdFaJAYB0WF/aMZ5vnu9vOv1DQdXZt1/rdVCm5rNQYF58
         ZLLg==;
        darn=vger.kernel.org
ARC-Authentication-Results: i=1; mx.google.com; arc=none
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=soloparent-net.20251104.gappssmtp.com; s=20251104; t=1781295519; x=1781900319; darn=vger.kernel.org;
        h=content-transfer-encoding:to:subject:message-id:date:from
         :mime-version:from:to:cc:subject:date:message-id:reply-to;
        bh=5A0XLoDWHSZQyPjX4MHAlPTHjEtx0svtMgsKxzyunNs=;
        b=UWsGK+8wGiBFdg0fm6twKGF9mvpZsrsdoAJ3rC59bbn5KOY0TFHtLE7zbwMC5wYKTz
         TPFfJ8Yfi39C4YT9wZ90P0cV64+MxWR7a5Oo9GFIjkk5XG5TwLx2Hj1/KQBaHFC+D0My
         kKf6YEQlOe62EXKb9YM4sPOp28hTh3f4iM2z6WVW8bbNoUbusIRh3u6GFM3V41//GU2q
         72UgndXEKT6dqjRa1sDOElrEriNYYYYjuEy4H8GGosTWAjaF/2/npG2XDrdMHUdzcLDz
         wRBohC+XH+wtpFbAxZ8kN78IiuW0t9E20+smqNB+vgkPNtgFkNIbhBjvQ2TO8azqXmEV
         GRpg==
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20251104; t=1781295519; x=1781900319;
        h=content-transfer-encoding:to:subject:message-id:date:from
         :mime-version:x-gm-gg:x-gm-message-state:from:to:cc:subject:date
         :message-id:reply-to;
        bh=5A0XLoDWHSZQyPjX4MHAlPTHjEtx0svtMgsKxzyunNs=;
        b=S0qCgjzqO6baOQlSqABmFtY4bLN6NV+iaYOW1IHNZuca4RXxW4lDMDvItn1ThbCX8s
         tnslajcbl6Acx7TlQmSqRo+KgJ29luGqc8U02K74Q5H/ZSD5aDTtVtIBsLu55wG49FBK
         gVZc6LYrdRZ/jn+kmPBikold1Nxrb6Fv/0FtBZ6mrmc9A2zOjaI8P0pXj9IQUjZ9Gsdz
         T0UuxjOZxsPYKfWI38tYAH23/i+OImLNvGq9InhaYfACuZNFwR7wPHyKyIjRyMTStgCt
         sdPS/gvgUzTxhiZ1dIvMEiy+xii59g3/5Kzp4TYCkWc7qwBd1zQguqKSXaNGrGKllQE5
         WJXQ==
X-Gm-Message-State: AOJu0Yw0CiASeDRrML1dZDh2xpvJiDmJA4odtmwwqcHwhaeW0/Z/1fA6
	BHqOCOhp4fShT1riNVE3O1RBHwMYG+Y0ka0B7g7wBG0BzG1dQPukHyUdX5w6EeZEdvj5DfQVlNU
	7dvk9aLKaJjgiywn2+OPB+6sB1tg68D6ElT/x9TTTnrY9cniNtIV1
X-Gm-Gg: Acq92OH1x59GrTp7+DhrKh+xXUjD+YNN4DGS2vw5vnylXLE/vRGkDkoOxNCOSjsl/Lr
	4xd6/qEY1Fz8WLqzMf+jNfjl94okbtoDCjW7arFutpxkStLbBZnJKlOzcCS6OrLIR0+ZvVLjqlZ
	guIn8mrjVmzltWFjTGEGM1p38FmcdRYZOOjd/Idso0oJfgG1M4zZrqS2Bk2w5qvmBm/JXE40klK
	eGJFLj48UNqOk78eRSIxKb9IDfOaQZlKSSpAgF4SLlHQ35OXf0FpGxwPQhV2FUhRgQSY4whKgOg
	zn3ziv0=
X-Received: by 2002:a17:907:7212:b0:bd5:7c2:7622 with SMTP id
 a640c23a62f3a-bfe2c09ded7mr230385766b.49.1781295518948; Fri, 12 Jun 2026
 13:18:38 -0700 (PDT)
Received: from 219903099946 named unknown by gmailapi.google.com with
 HTTPREST; Fri, 12 Jun 2026 15:18:38 -0500
Received: from 219903099946 named unknown by gmailapi.google.com with
 HTTPREST; Fri, 12 Jun 2026 15:18:38 -0500
Precedence: bulk
X-Mailing-List: linux-nfs@vger.kernel.org
List-Id: <linux-nfs.vger.kernel.org>
List-Subscribe: <mailto:linux-nfs+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:linux-nfs+unsubscribe@vger.kernel.org>
MIME-Version: 1.0
From: Joshua Bennett <josh@soloparent.net>
Date: Fri, 12 Jun 2026 15:18:38 -0500
X-Gm-Features: AVVi8CfSu0TWibMxKx9NnOmWYJfuO2sz7r4JAKjzrm0hiNRwfR8_EUlLk7TWSSo
Message-ID: <CALeeH=8zRuEsmG44j__EFjMDcnZTMD8n37xx6nQ4urjBWE+Dbg@mail.gmail.com>
Subject: Quick question for you
To: linux-nfs@vger.kernel.org
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable

Hey there,

Adolescence can bring some big feelings, and for many kids, anxiety is
one of the biggest. When parents and kids tackle it together, it=E2=80=99s
amazing how much lighter the load can feel.

As a single parent to my two beautiful daughters, Hope and Sara Beth,
I know how important it is to build trust, keep communication open,
and make sure our kids feel heard. I=E2=80=99m writing an article that shar=
es
ways families can team up to navigate adolescent anxiety and come out
stronger on the other side.

I think this could really resonate with your audience, and I=E2=80=99d love
for you to feature it on your site. Want me to send over the draft?

Best,
Joshua Bennett
josh@soloparent.net


P.S. If you're interested in a different article topic than the one I
suggested, please let me know, and I'll tailor my ideas to better suit
your site. I write in a way that connects with readers on a deeper
level while boosting visibility across AI and search platforms.
