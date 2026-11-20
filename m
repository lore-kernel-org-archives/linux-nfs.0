Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.remote-ip=74.125.82.44
ARC-Seal: i=1; d=subspace.kernel.org; s=arc20261015; a=rsa-sha256; cv=none;
	t=1795152044;
	b=5QAHZJs4tj6NC5LNsT3RBJ9hbrZ41i5f0x50VjDzyu0eg6yPW01w0D6vutfDCSdZcuz3
	 M0a716fPUGnLnQv2IMnHmi8O8Is1uPYO3i7b5W4zvGJLTPjvJXWxeYJQJijHab1wCeKi9
	 M1A/xYxbQiHLdN6LHdahRpeKbSGMj0uNz26fqdSOs8BIUBVU0764PFN5z+o2G/I1+r5jo
	 dZA7GXoYUTOVyV8AKKuBu7T3I/0+ULw2xgEjgxXdis+0U9R/VvEPEHTsYI+sxAte2b25z
	 LhWnAo+kJWh5XXwJJqyy9HvkFxG8Faf4LtNRyNj1hvjEiyxk3ehX+6cu00HUuCejVlQ==
ARC-Message-Signature: i=1; d=subspace.kernel.org; s=arc20261015;
	a=rsa-sha256; c=relaxed/relaxed; t=1795152044;
	h=DMARC-Filter:Received:DKIM-Signature:X-Google-DKIM-Signature:
	 X-Forwarded-Encrypted:X-Gm-Message-State:X-Gm-Gg:X-Received:Received:
	 From:To:Cc:Subject:Date:Message-ID:X-Mailer:In-Reply-To:References:
	 MIME-Version:Content-Type:Content-Transfer-Encoding;
	bh=sjwp1YVIKMqLS+iv1gHjFMiod5EBkO1U/IPlzcMfNc0=;
	b=kaUD1qFd2/yc8i5/04YkphQ9lkz2BExL/wKhC5RqZxhLWSaWLhmZuVeEC0iaIrZaGU0i
	 wbHKm5T/AJvlyb4mENnR8DvhTt9r4s0PCoVvkYzB7Z+5ambchoYjDPeU151/Cj7qT7KXv
	 DESl/I/VBMhDcRcoweG3LckuTYloh8F/UERQonoaCNToTBwsyulKz7SWZL3QiMwFOv7oX
	 uWWVVI1XHc+1w+s2OLDFZ6wLT9s/DMTt36+0M0hpImfLt705k6D8Cw65EPX4Hqko7ziEB
	 FuONeZWRBfgt0wJYiySuo+cRo9+FvMM3TiuXEARf8puRIZp36M9lRIbegSzvAJmqCBw==
ARC-Authentication-Results: i=1; smtp.subspace.kernel.org; 
	dmarc=pass header.from=gmail.com;
	spf=pass smtp.mailfrom=gmail.com;
	dkim=pass header.d=gmail.com header.i=@gmail.com header.a=rsa-sha256 header.s=20260707 header.b=d7ZlbZoH;
	arc=none smtp.remote-ip=74.125.82.44
Received: from mail-dl1-f44.google.com (mail-dl1-f44.google.com [74.125.82.44])
	(using TLSv1.3 with cipher TLS_AES_128_GCM_SHA256 (128/128 bits)
	 key-exchange X25519 server-signature ECDSA (prime256v1) server-digest SHA256)
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 786B0606A320
	for <linux-nfs@vger.kernel.org>; Fri, 20 Nov 2026 05:20:44 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.4.2 smtp.subspace.kernel.org 786B0606A320
Authentication-Results: smtp.subspace.kernel.org; dmarc=pass (p=none dis=none) header.from=gmail.com
Authentication-Results: smtp.subspace.kernel.org; spf=pass smtp.mailfrom=gmail.com
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=gmail.com header.i=@gmail.com header.a=rsa-sha256 header.s=20260707 header.b=d7ZlbZoH
Received: by mail-dl1-f44.google.com with SMTP id a92af1059eb24-1a3c08d6928so753098c88.0
        for <linux-nfs@vger.kernel.org>; Thu, 19 Nov 2026 21:20:44 -0800 (PST)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=gmail.com; s=20260707; t=1795152043; x=1795756843; darn=vger.kernel.org;
        h=content-transfer-encoding:content-type:mime-version:references
         :in-reply-to:message-id:date:subject:cc:to:from:from:to:cc:subject
         :date:message-id:reply-to:content-type;
        bh=sjwp1YVIKMqLS+iv1gHjFMiod5EBkO1U/IPlzcMfNc0=;
        b=d7ZlbZoHTePKE5KA98jrdhu5PJcoGiFLiP6nxfOIm0yZp4bQA8oUwr8Oqnuu5SS+9b
         XV5s1cCZfDJ77npozkFl7nedfRTQ43F81D/TDjeKWCKM+RipI1isbxyv/ssghOY6qBG/
         aRvX/mjcUqEu8L6FRFtSmraAZjUUVH3Mx5bdFl/UdCMKNltK813DUcE5b+VyWTtc2Tz5
         R8gq65zKpQyf0Wq+ofPFu5KHDeucmorNcuwOLf8umU7dqoEPMuxjvZkg2kMIKM75GXrM
         lM+sqwK149bveJhot7xJEkTdOi7Xhh5/cGrOJjF6tZ8EDZWt3eJ8sy5jwfbZx5wKkvFE
         dU7Q==
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20260707; t=1795152043; x=1795756843;
        h=content-transfer-encoding:content-type:mime-version:references
         :in-reply-to:message-id:date:subject:cc:to:from:x-gm-gg
         :x-gm-message-state:from:to:cc:subject:date:message-id:reply-to
         :content-type;
        bh=sjwp1YVIKMqLS+iv1gHjFMiod5EBkO1U/IPlzcMfNc0=;
        b=RVDU3WMQIjrHuwgcBQIMHKuo7Eve/A1e24FrZJWwsFl4gYIWCEq56Q8q53HhmR+kLn
         tp2pajIfPj525ppb7WBeJcQEpO1mpuNIzrYPitHD7F7IOujP/VKAp7fUeBEJhlEVrHnU
         qHgpC4GldYLU3LwPfluj5ewY2DCXRr5LIvG1KAuz+53w/QT33Dpeg8UFZkGUTg0iysBK
         BK7O23a3o9prB5pi9DB8+FbiA1A1SdPnyTaaM2RR7F8S5yaeO9os2F1gQUcK0WHLlR75
         wo208SH9/pUedoxZUctRdUWkxW1H+34O94Rs8fg0vQUGNJ8nF8agR/cPZsH2/9z6kFPr
         OaPQ==
X-Forwarded-Encrypted: i=1; AL+hErFcZGBFwlEurGcUGRSIHPLH46Qxa8B4T6yTRhzBm9usqXo958RsPjp6b5PSV27RzrHxQDBB3pA8jeA=@vger.kernel.org
X-Gm-Message-State: APuU4Z+NwkNavkmTmriCraOOw0Dprod519AwgrSoyJpG92gzzDPLdh87
	6rtMIM6D9bzlHOpQvDS4qUXwQP7/9QkKHlNBKayN4m4jEU96V8I2FSMBPulDT7f2
X-Gm-Gg: AYBFou0YweL7bazndyB+kbQk0TdFSXjSOQgDGyYlBjQBHFOLeZ69aTaYN7eL6HLDbRl
	4BGtNgS55s8vbq2af03m9PsyEyahLWpVIlUY1kVOb0MQLv+Z6Cdsfsa+snxdJzq0jSAhDmoL3Aa
	XPsJjslmItPD6qwrvW+Yc5QiprYhksdI7KcVeA2/qh7ZRFvuD7b0EAFCNfxVloOLyberA8K5jhi
	sFEc4FqGh55lps6l8TJSsLgcq2i75tvKu09e7Ba4bgeagIJ6M9ipoQEKFl8qwlYZFDGtR+3VqRq
	m1vicMrXwSdgyRDG3ZNFI3Rj3HGV4zJalZXcGlKAvTrI/FYDCBfCS/hs3cSELnqlvzBzeLLlUhk
	T79yjKslSrufSXuYrhjivsg41DHfF3CaxXX54JBsyc6GvHfslUxlUihL6AC28Qrl/gZ/l4I1Jql
	p8GhucLkkcbn0/Ghv0hZODQzf5aHtVDHo5kM2cfIWR3xDOjYVgg4TebWFD0k68bUXwXhe7VPkgl
	MVxGDIzbDk3tMQpg2dc4aglk2OJIEnvNk3WTyDJcXyF5349dn7WnuA5PIGPaZyaRSevxD9L9az3
	fEHll4DcXvU7mvY4lGmphrY8
X-Received: by 2002:a05:7022:f118:b0:159:2c6d:fcc3 with SMTP id a92af1059eb24-1b5568d34cbmr1497290c88.33.1795152043341;
        Thu, 19 Nov 2026 21:20:43 -0800 (PST)
Received: from houminxi ([61.170.225.237])
        by smtp.gmail.com with ESMTPSA id a92af1059eb24-1b5569bffd2sm3431647c88.0.2026.11.19.21.20.41
        (version=TLS1_3 cipher=TLS_AES_256_GCM_SHA384 bits=256/256);
        Thu, 19 Nov 2026 21:20:42 -0800 (PST)
From: Minxi Hou <houminxi@gmail.com>
To: Jeff Layton <jlayton@kernel.org>
Cc: Minxi Hou <houminxi@gmail.com>,
	calum.mackay@oracle.com,
	linux-nfs@vger.kernel.org
Subject: Re: [PATCH] flex: add ffl_flags validation test
Date: Fri, 20 Nov 2026 00:20:28 -0500
Message-ID: <20261120052028.3902687-1-houminxi@gmail.com>
X-Mailer: git-send-email 2.56.1
In-Reply-To: <5c6f120eef42aae671b49b782932076660c6cc23.camel@kernel.org>
References: <20260625083756.1799608-1-houminxi@gmail.com> <5c6f120eef42aae671b49b782932076660c6cc23.camel@kernel.org>
X-Mailing-List: linux-nfs@vger.kernel.org
List-Id: <linux-nfs.vger.kernel.org>
List-Post: <mailto:linux-nfs@vger.kernel.org>
List-Help: <mailto:linux-nfs+help@vger.kernel.org>
List-Subscribe: <mailto:linux-nfs+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:linux-nfs+unsubscribe@vger.kernel.org>
List-Owner: <mailto:linux-nfs+owner@vger.kernel.org>
Precedence: list
MIME-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 8bit

On Thu, 2026-11-19 at 09:37 -0800, Jeff Layton wrote:
> Could you take a look at the pull request here and address Chuck's
> comments?
>
> https://github.com/linux-nfs/pynfs/pull/13

Thanks, Jeff. I left a reply on PR #13 covering the XDR question and
the review comments on st_flex.py:

https://github.com/linux-nfs/pynfs/pull/13#issuecomment-7031195467

Best regards,
Minxi Hou
