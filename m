Received: from mail-ed1-f68.google.com (mail-ed1-f68.google.com [209.85.208.68])
	(using TLSv1.2 with cipher ECDHE-RSA-AES128-GCM-SHA256 (128/128 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id DF7CE1E2847
	for <linux-nfs@vger.kernel.org>; Mon, 20 Jan 2025 14:10:32 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=209.85.208.68
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1737382234; cv=none; b=fEUcujLP1bOqR6wvw9Xn4t7qK/qLErrLyD9+RsDZL0ZuQelbmrjaT0b8wGTyADszoaPRmjbO+2O9mXyfPVyidQmClFpzIiu7j7etTPF2WxNyA97VvDqH4f9tA92/MNbgVNvT+Gwy1ono9Cy9sgDToGLDZwTTltrovb5xYuoC4xI=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1737382234; c=relaxed/simple;
	bh=Qt/Qayq19OXdKyPfXCtFn8H59qMxc17PoCb7fgfmbgY=;
	h=MIME-Version:From:Date:Message-ID:Subject:To:Content-Type; b=mdn9dg1+wepYAtNL1a/OvgmQbbrTEVgx4S3hUWG2fpKOVNQRn1Zo0eYEoYokQF74R+Dfyczi1ogj6JZf8NSfobVsv9J6xkiFzC2gqC9EfF2Gim4DP8QU0NI7FrS8DOwh9b0Bs9Zra92rSz16OJgkXzsWFxtVlYsqeAfhWVwcHA4=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dmarc=pass (p=none dis=none) header.from=gmail.com; spf=pass smtp.mailfrom=gmail.com; dkim=pass (2048-bit key) header.d=gmail.com header.i=@gmail.com header.b=DH6oKGYJ; arc=none smtp.client-ip=209.85.208.68
Authentication-Results: smtp.subspace.kernel.org; dmarc=pass (p=none dis=none) header.from=gmail.com
Authentication-Results: smtp.subspace.kernel.org; spf=pass smtp.mailfrom=gmail.com
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=gmail.com header.i=@gmail.com header.b="DH6oKGYJ"
Received: by mail-ed1-f68.google.com with SMTP id 4fb4d7f45d1cf-5d3dce16a3dso5550487a12.1
        for <linux-nfs@vger.kernel.org>; Mon, 20 Jan 2025 06:10:32 -0800 (PST)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=gmail.com; s=20230601; t=1737382231; x=1737987031; darn=vger.kernel.org;
        h=to:subject:message-id:date:from:mime-version:from:to:cc:subject
         :date:message-id:reply-to;
        bh=Qt/Qayq19OXdKyPfXCtFn8H59qMxc17PoCb7fgfmbgY=;
        b=DH6oKGYJkDnf7K+7K4B5SAcuEw2ia4X3tWAQPd2f+uFmxw0sxZxJwI6HH/src31KsA
         WXz8bgsB42n6B3F/H2fuxyXgQI1rHp++JnlPfaD7lWezdxCIAa3FUai0KeVSsMKSRN+s
         7OJ7QhDvrEGTlbmFF2P6wMkq+cranqGSlkP8Ct4YJQhALCHqXNMsPYQR7uw+nSnHEDh6
         M4E5rKpBXu5jJpcrReFZg9PrP0fbIlldJpSZgYVacv6s4wyXSUaPkhqhwQGjOC+CJcay
         YjFmMB52IcWqb+WdqaYcPyz1Yl9tapEIm972gaJ38byeCzEl8Rj6UtTSq9NY8kJLqiiK
         vzKQ==
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20230601; t=1737382231; x=1737987031;
        h=to:subject:message-id:date:from:mime-version:x-gm-message-state
         :from:to:cc:subject:date:message-id:reply-to;
        bh=Qt/Qayq19OXdKyPfXCtFn8H59qMxc17PoCb7fgfmbgY=;
        b=rytR59kGqg72nxlqlfFsxisqzivN1TijQuSIpTLxKqAtrKEc6bGZkPkDbwp+KtIWnY
         +AD2pBiLC/xHRCAyDpCj2ANBLb/G6noa2qMw8AUus1S/2uvRdKJXa+8h4NBzXrt5BsV8
         nKGDNzxEraX8Ptsv/ZPVPlRCvfrtx+LXxZ5DzihYXIQput0W/FYF8Cg20k0219mSQ1wq
         qArNcNA/hGqiA76AUinwywE81frsgUXetrKArQHCz0DXTO7ak7Chw96ZPadm+mLkHxoc
         iTG9CykXW7OwmIhGAObn9bwQawsvHiJEi6SF2Kzk1/dsQ4sZI3a4rbJDqE2EJjJtJMAW
         fbOQ==
X-Gm-Message-State: AOJu0YzuRnAcUM83OBlOUIQ4K3XsGADs8TgAzBduK0DK7WUAmeYYeTXt
	c9GwJeqMr2+/7JqlcRHIqrcZCYLHcXTOCoC8r8OI++JGRrU3mOB4wK39YGOOeCg1Zb8rntdYQds
	IuDEfYTNpgNOp8vsr7J5COaKJXqt5hS2dx+lBvw==
X-Gm-Gg: ASbGncveWc7JtCsicxQ2zTc5erOPUT6bLsjftmFAciQU1++CeihUtVMSPcpDHKMN28r
	fsNWK3fBeyd2ZERaTwfVXNvpJOspdQSu3AGV9IaepQh0t5U/LPV0=
X-Google-Smtp-Source: AGHT+IEyZynyoDSt7qIbK5xydi+Ja0PS7c59XR2cK6+xbKQ2uaXCCwPm64A83Tb+Hk+QAnqephtua79+s7aynl35gM8=
X-Received: by 2002:a05:6402:13ce:b0:5d9:6633:8e9b with SMTP id
 4fb4d7f45d1cf-5db7dc3ba04mr11357801a12.1.1737382230621; Mon, 20 Jan 2025
 06:10:30 -0800 (PST)
Precedence: bulk
X-Mailing-List: linux-nfs@vger.kernel.org
List-Id: <linux-nfs.vger.kernel.org>
List-Subscribe: <mailto:linux-nfs+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:linux-nfs+unsubscribe@vger.kernel.org>
MIME-Version: 1.0
From: Lionel Cons <lionelcons1972@gmail.com>
Date: Mon, 20 Jan 2025 15:09:54 +0100
X-Gm-Features: AbW1kvbrtBElUkML5ayMRgGxflwN3nugM1gNthKMT1ayMt4XhboxRi-etbYpGys
Message-ID: <CAPJSo4V9TssdPre+Xps6s3qa0dBAuAadJqT8=+DLzvJk-2P8CQ@mail.gmail.com>
Subject: Linux nfsd always returns { .minor=0, .major=0 } for
 FATTR4_WORD0_FSID, why?
To: linux-nfs@vger.kernel.org
Content-Type: text/plain; charset="UTF-8"

Does anyone know why the per-fileobjet attribute FATTR4_WORD0_FSID
 always returns { .minor=0, .major=0 } for a Linux nfsd?
This does not sound right.

Ref https://datatracker.ietf.org/doc/html/rfc5661#section-5.8.1.9

Lionel
