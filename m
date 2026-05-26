Received: from mail-qt1-f179.google.com (mail-qt1-f179.google.com [209.85.160.179])
	(using TLSv1.2 with cipher ECDHE-RSA-AES128-GCM-SHA256 (128/128 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 3F1A4202C46
	for <linux-nfs@vger.kernel.org>; Tue, 26 May 2026 13:58:16 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=209.85.160.179
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1779803904; cv=none; b=KqaaC5rgKZBjWThbBQdvzE7/fX4TDZyN/T38RFr4J5WUo7NBapjij/dywXoK+OKGFnHYouF6Hpr7mT8PVlCt9aJX1Px4dgZ3IhunssBmuXrYHg1zV7kmVYGB7UTSbd5BJJ4lhDYRrWCum4sGKY6IHW7B2nJ9jlgQeJMSq3BulPg=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1779803904; c=relaxed/simple;
	bh=+dFASmDW5/VWwhmw+tJvrcW/sOB6oNqzhzp1PEb7+8o=;
	h=From:To:Cc:Subject:Date:Message-ID:In-Reply-To:References:
	 MIME-Version:Content-Type; b=BYuR4kCu6v3BWF/7xZsHMqAFgeZcDTuHG5EHUZtnHe6sEiiVqI9c45Sf2KfivP1rXaCta8XEAdHlMDK/JS3hTBTJkA3paca7wnEHL6XgTdg0dNrg4fTZi6oGnbWIHlpNtuiwUDADejwX/RjAy9LSku4H/MBc9keUX1s1fNcxS0Y=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dmarc=pass (p=quarantine dis=none) header.from=hammerspace.com; spf=fail smtp.mailfrom=hammerspace.com; dkim=pass (2048-bit key) header.d=hammerspace.com header.i=@hammerspace.com header.b=bEY/auBQ; arc=none smtp.client-ip=209.85.160.179
Authentication-Results: smtp.subspace.kernel.org; dmarc=pass (p=quarantine dis=none) header.from=hammerspace.com
Authentication-Results: smtp.subspace.kernel.org; spf=fail smtp.mailfrom=hammerspace.com
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=hammerspace.com header.i=@hammerspace.com header.b="bEY/auBQ"
Received: by mail-qt1-f179.google.com with SMTP id d75a77b69052e-516cc5471bdso72025901cf.2
        for <linux-nfs@vger.kernel.org>; Tue, 26 May 2026 06:58:16 -0700 (PDT)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=hammerspace.com; s=google; t=1779803892; x=1780408692; darn=vger.kernel.org;
        h=content-transfer-encoding:mime-version:references:in-reply-to
         :message-id:date:subject:cc:to:from:from:to:cc:subject:date
         :message-id:reply-to;
        bh=8MJ5R003cXqmzmJ39uzsN5RS9P4Rd1uFfYLqHUPzpFE=;
        b=bEY/auBQrPFxmhJTMo6Xz7JDHsb/MdFcyuVIbAfk9N25IHO0TsfhkCFqscTg9hvuc4
         HrU+De7H327yGSbDXdYP4P4/TiCR9scatUVIJWNdTT20JiY+CH54mNQOkexGx74xdHW9
         0xuM4AUNpTtvuDNVF6grbkknxBgUja9GGpcNsEdtzqa35RoYuywsh8kKb0WqAWEN+uTz
         wsvnuDG+eltBeEbHsvATtEQbNW4O9U+/1Z68s2/ZD6OS6683TrW3+aEOQKycV5In73H9
         qw8cLD7VnIs2H9Fz+76wnLdXETCbm1zhZ/gQBdn/Aa0rN+3u7T5MWZvjK7lktfdFX/3o
         ew3A==
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20251104; t=1779803892; x=1780408692;
        h=content-transfer-encoding:mime-version:references:in-reply-to
         :message-id:date:subject:cc:to:from:x-gm-gg:x-gm-message-state:from
         :to:cc:subject:date:message-id:reply-to;
        bh=8MJ5R003cXqmzmJ39uzsN5RS9P4Rd1uFfYLqHUPzpFE=;
        b=rQktIxtAsxniG7lNjkpTKxYQZSpTnX1b/6/Rmw/EuxWwhXeyLC8tnklPWdmPXb59F3
         TqAD/9BAfQY/QL5/UuHsb6B2zS6FSn8a+uj1svDnsbV7tjhEUPIh+OJjUsIeiQNV79bq
         XeKrhRPV6o45Y29wS6FtXIRPjin0u5cGaGvo7Y6qAl8deevPZ1XHHCHV7CzE8eKEU3ER
         jAr6l1PTKxC31EJ/x8jyH0sKEFeDL/4EGRNhaFHd9D8At32BUj22pPvCuOlocdSVZugY
         PKeVZM6zEnmhK/Lqn+i2f8GC/nJaut1TwhsNU/35cslb13xGyvTdWVARoc5DpK+mty+B
         iqxw==
X-Forwarded-Encrypted: i=1; AFNElJ9YysI1f856OGD6g3/U7dJPOz83d3AzkYRmGo9p2vN7XvEOkqbXqIa+g8gOHdx8bh/bYPgjPihftVo=@vger.kernel.org
X-Gm-Message-State: AOJu0Ywv8FtMljOHRevFzEjkjHXxpDgHmiee7RIVuBF5ehSvibVLAoFA
	/KCQNK1fck/xHt51qD4zzr69rxwRL6s3pgaJ8kXtJ5R9dHmUOkhiZaCkDgEeHI7VllY=
X-Gm-Gg: Acq92OG3wxdL4YJPAKkiPD71LC40L19psy9YRxLxto0teDUVTZuHZu+2oAm2BY3iSRP
	eP1SJtje5I6lDP9i2UbI1hWu9e/8Ry8ahLxUHZa38iUh9lIWqJ01UmyU3WO2+tDJhJFafAyaPcD
	RhMq+dvSJrh6m7D0toUxgZdnLPNOZI/BaiEsDQwMK2AiYVqtyH1W4by+KsmZv0LR7IG5G2bmg6A
	eeF7F+fxFtIgrraHnOWZL9jYDWFxYpUeZGc7h9HO2eZxvRoHLu23Ql3pi/K+2e3OtchDncKo7Zd
	+z9Hu58jJKP29KEknzPXDfqUYWWzssWNsGMAagTBJCH3k9EUfgCS7yeCW0CuexDx3S7pouBEJ0t
	mypxe+F9a9GAmJ+Mh/fxpEAwpPFoxSD8VYJ1LtlWhEDazI2TzR+O3fDWE4JUlVrzHN+q8DUj/NQ
	lNq1R8EFZcQtn2F6HPAIDz+opeUnE3QPLXIcIIvlmE
X-Received: by 2002:a05:622a:43:b0:516:ea00:2eb2 with SMTP id d75a77b69052e-516ea00353amr156007461cf.21.1779803892197;
        Tue, 26 May 2026 06:58:12 -0700 (PDT)
Received: from [192.168.37.1] ([66.97.168.37])
        by smtp.gmail.com with ESMTPSA id d75a77b69052e-51706adc9cfsm17729661cf.19.2026.05.26.06.58.11
        (version=TLS1_3 cipher=TLS_AES_256_GCM_SHA384 bits=256/256);
        Tue, 26 May 2026 06:58:11 -0700 (PDT)
From: Benjamin Coddington <ben.coddington@hammerspace.com>
X-Google-Original-From: Benjamin Coddington <bcodding@hammerspace.com>
To: NeilBrown <neil@brown.name>
Cc: Chuck Lever <cel@kernel.org>, Jeff Layton <jlayton@kernel.org>,
 linux-nfs@vger.kernel.org
Subject: Re: [PATCH 02/] nfsd: fix minor issues with atomic_create() use in
 dentry_create()
Date: Tue, 26 May 2026 09:58:10 -0400
X-Mailer: MailMate (2.0r6272)
Message-ID: <B2DB156F-1BC2-4F43-8CB0-3795621C4A06@hammerspace.com>
In-Reply-To: <20260526053004.4014491-1-neilb@ownmail.net>
References: <20260526053004.4014491-1-neilb@ownmail.net>
Precedence: bulk
X-Mailing-List: linux-nfs@vger.kernel.org
List-Id: <linux-nfs.vger.kernel.org>
List-Subscribe: <mailto:linux-nfs+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:linux-nfs+unsubscribe@vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: quoted-printable

On 26 May 2026, at 1:27, NeilBrown wrote:

>     https://sashiko.dev/#/patchset/177969022571.3379282.164487446244283=
23496@noble.neil.brown.name?part=3D1
>
>  reported a couple of edge-case problems with the use of atomic_open()
>  in dentry_create(), called from nfsd4_create_file.
>
>  These patches attempt to address those issues.
>
> NeilBrown
>
>
>  [PATCH 1/2] nfsd: fix possible fh_compose of wrong dentry in
>  [PATCH 2/2] nfsd: ensure nfsd_file_to_acquire() does not use a

Except for the subject in 2/2 ( _do_acquire), these look correct to me.  =
Thanks Neil.

For both:
Reviewed-by: Benjamin Coddington <bcodding@hammerspace.com>

Ben
