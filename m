Received: from mail-oa1-f48.google.com (mail-oa1-f48.google.com [209.85.160.48])
	(using TLSv1.2 with cipher ECDHE-RSA-AES128-GCM-SHA256 (128/128 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id F32633E1729
	for <linux-nfs@vger.kernel.org>; Tue,  4 Aug 2026 12:58:42 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=209.85.160.48
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1785848326; cv=none; b=I8W1PAQkp0FBAEhEoj+ziPUmi2lbCyHIyYo2T8cll5gH2tMfj7mWpQy4GApiJNyyvFlR6GhtMYgNGVjzLF6Ez1pAVqj9Fu+Z9yUXEIHu1bX49vr6OU5O/XLev6ZQCTn+Er/63N07gDxRxqGgDKOr2Nwe7qQ8IdZo98TWCGDwqjM=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1785848326; c=relaxed/simple;
	bh=NilHV65EFykMR8k+I3A9f4u6Nw+aLVLxtlwhJ9Sqwsw=;
	h=From:To:Cc:Subject:Date:Message-ID:In-Reply-To:References:
	 MIME-Version:Content-Type; b=AEvTViGnuotbcJuDFRxtZkTTS+8j5DQAF7MMgodwdGXlBeoi2HNX+0MYmbzB5lRoCRA5GCwvLvi+12L6WZtn0xQ2/8Sx4q1ZnpozejIwZajxYCqaZ8doi7pSEX/6VBGeIWL8nkJL6vMXMai0EcDxfN6xF5tomwbI7BKCFIWGje4=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dmarc=pass (p=quarantine dis=none) header.from=hammerspace.com; spf=pass smtp.mailfrom=hammerspace.com; dkim=pass (2048-bit key) header.d=hammerspace.com header.i=@hammerspace.com header.b=fulKllkH; arc=none smtp.client-ip=209.85.160.48
Authentication-Results: smtp.subspace.kernel.org; dmarc=pass (p=quarantine dis=none) header.from=hammerspace.com
Authentication-Results: smtp.subspace.kernel.org; spf=pass smtp.mailfrom=hammerspace.com
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=hammerspace.com header.i=@hammerspace.com header.b="fulKllkH"
Received: by mail-oa1-f48.google.com with SMTP id 586e51a60fabf-448de0cc236so3955239fac.2
        for <linux-nfs@vger.kernel.org>; Tue, 04 Aug 2026 05:58:42 -0700 (PDT)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=hammerspace.com; s=google; t=1785848322; x=1786453122; darn=vger.kernel.org;
        h=content-transfer-encoding:content-type:mime-version:references
         :in-reply-to:message-id:date:subject:cc:to:from:from:to:cc:subject
         :date:message-id:reply-to:content-type;
        bh=bnlXQ9rhTqBoOv/1rtWG6bhXtpI+brfeZy53ukwIku4=;
        b=fulKllkHkilwDT0j8xSR7g+1IfpXWyG4OShDrtMcAtSXJsNadq8ipx8vjlyp2rW1g4
         uZQhdiIV7hvKzIwzre2kw9cVClbTi4IlVPzIDcU4FZ9CtwHHcCrtifkKHyBDAIHOMszG
         I11FnXQLwCoihYGKncscQ0Sj4RXzHfJna6EG7RMqNc7H4/wKEcoyMkEybv/e3P+C2jxA
         o6fZ5t2reytqcD3Pm0mstsUYTq9Q4P/x53sS6jfzOK0CQpM5roPUX9R/PEu2Qs/nd9sU
         PMbys5MbbsmbY1qTRJIh92an4vPT5jVPsCsimT3zBomufPA2LYktKjbRpPWgarIEPSxN
         O51w==
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20251104; t=1785848322; x=1786453122;
        h=content-transfer-encoding:content-type:mime-version:references
         :in-reply-to:message-id:date:subject:cc:to:from:x-gm-gg
         :x-gm-message-state:from:to:cc:subject:date:message-id:reply-to
         :content-type;
        bh=bnlXQ9rhTqBoOv/1rtWG6bhXtpI+brfeZy53ukwIku4=;
        b=GxCl9CZPel2x+So++Z3uQhDn368LjLAWk2ObyV/bJXQYJzIpdvvjLsGngxwyB4OON4
         eKFUYCgCdPXm68VMltOXFR6zEd6OgjR+Lq+FldtyaczgyOZ9UVPGdBQqyIvrHlXtFduJ
         iZebUS7Hr0pjvMmmNSJk7juJdgYznLLwN9+UcAjECz++35PwfmoIvpeI280Vlr6tvMCz
         5uFNFBqF6r1+6iiHolGI/dRvkc2zWgDp12/7cGq8MtmM0F4ItSAKDIcRSO3qX27LiY4E
         RrTQDZjlkXQW9aT0EhdwGYMbQ8Vn+97qwpiIL/+5G9tfNoDud740bomhsaj5N8Y2hgWz
         rfGw==
X-Forwarded-Encrypted: i=1; AHgh+RrDr9T3uS15dqFykO3EovIuv1iH7x3xf09YSbRKdzA/m1FQ7/fnhdfl/qSIDPXdk1N+AEiQvzNiPbo=@vger.kernel.org
X-Gm-Message-State: AOJu0YyuHFJK4uyGepnIq/e1Xjx/A9VUwsHeEGxwp1FNwSPlC6Aygiul
	Lhu8ghayksO1pA6SOsBLKuPUFZ++j8bQiAzs4Q6cwwH5/Bq979tEHIJ6EIv9ozwUGkI=
X-Gm-Gg: AR+sD12yDeYXVY2mq80h12xHOdiuy54Tu29lxm4VoMMNV+POiXYQ0NKKRQoVJxRhjGR
	jkbp97TZa/l2PKPGFvAXs800SfV66XV0q7d3+ppUMTvS3J1MbGVfPlmfbG9z0Bi7TeZ1CqjqHkK
	6NLMmeNZK4zLoMDw8GIJdl6B3Cku7djzwNLTxVwjFKtHVd9W/2GG2R7OrkaKh+WCL7lu1YXJh4Y
	AU1MLVotqu3CxyjZKY6PcFRHzsSXBIA/zt+BAg0OQ6AzgBKQG2GYj6XKjSk/AtKLoO4eY4uo9ls
	uD5I37eY0B8nW/hA+rcCjEviYLM4J62D7ykhjvsDfxAWFe+bDwrPBhv6s/1yaxTNbdXJar33rsh
	KnbthpRFMMlS/JqRcFcewefLl5TVJkVEIhl/+Wp8/sxw+DgrOcBSMQAQ3EJ4Jtsu5Rso8yeKNoN
	F77nIsBPsiQIw8vZjAOMskjsjspXreDKXFZoJGXOcxGogieb2Xpx8RlEwYkGn38WJcwnYbqjPR4
	GnpmZlQSqaTVe3012LJ
X-Received: by 2002:a05:6870:e30f:b0:43c:2d3f:95f8 with SMTP id 586e51a60fabf-4590531302emr20313757fac.0.1785848321567;
        Tue, 04 Aug 2026 05:58:41 -0700 (PDT)
Received: from [192.168.254.51] ([66.97.168.37])
        by smtp.gmail.com with ESMTPSA id 586e51a60fabf-458f60e3137sm12142877fac.7.2026.08.04.05.58.40
        (version=TLS1_3 cipher=TLS_AES_256_GCM_SHA384 bits=256/256);
        Tue, 04 Aug 2026 05:58:41 -0700 (PDT)
From: Benjamin Coddington <ben.coddington@hammerspace.com>
X-Google-Original-From: Benjamin Coddington <bcodding@hammerspace.com>
To: Vasileios Almpanis <vasilisalmpanis@gmail.com>
Cc: Trond Myklebust <trondmy@kernel.org>, Anna Schumaker <anna@kernel.org>,
 Benjamin Coddington <bcodding@redhat.com>,
 Trond Myklebust <trond.myklebust@hammerspace.com>, linux-nfs@vger.kernel.org,
 linux-kernel@vger.kernel.org
Subject: Re: [PATCH] NFS: sysfs: fix use-after-free on delayed kobject release
Date: Tue, 04 Aug 2026 08:58:39 -0400
X-Mailer: MailMate (2.0r6272)
Message-ID: <4FA2A276-5C44-4D7E-8C33-1322A7BB8AB4@hammerspace.com>
In-Reply-To: <20260803-nfs-v1-1-034176dab4a3@gmail.com>
References: <20260803-nfs-v1-1-034176dab4a3@gmail.com>
Precedence: bulk
X-Mailing-List: linux-nfs@vger.kernel.org
List-Id: <linux-nfs.vger.kernel.org>
List-Subscribe: <mailto:linux-nfs+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:linux-nfs+unsubscribe@vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: quoted-printable

On 3 Aug 2026, at 5:18, Vasileios Almpanis wrote:

> struct nfs_netns_client embeds two kobjects and is freed by
> nfs_netns_object_release(), the release function of nfs_net_kobj.
> Despite that the first one, p->kobject lives in the same allocation.
> Nothing keeps the allocation from being freed before p->kobject
> has been released.
>
> When CONFIG_DEBUG_KOBJECT_RELEASE=3Dy each release is instead deferred =
to
> a delayed_work embedded in the kobject, with an independent random
> delay, and nfs_net_kobj frees the allocation first in some of those
> cases. p->kobject's timer is then left armed inside freed memory, and
> the following splat appears:
>
>   [  139.805951][  T131] kobject: 'nfs_client' (ffff888027fdb800): kobj=
ect_release, parent 0000000000000000 (delayed 300)
>   [  139.808019][  T131] kobject: 'net' (ffff888027fdb898): kobject_rel=
ease, parent 0000000000000000 (delayed 100)
>
>   BUG: KASAN: slab-use-after-free in __run_timers+0x932/0x980
>   Write of size 8 at addr ffff888027fdb868 by task swapper/0/0
>
> Reproduced on a KASAN kernel with CONFIG_NFS_FS=3Dy and
> CONFIG_DEBUG_KOBJECT_RELEASE=3Dy by:
>
>   for i in $(seq 16); do unshare -n true; done; sleep 20
>
> Give p->kobject a reference on nfs_net_kobj for its whole lifetime and
> drop it from nfs_netns_client_release(), so the allocation is always
> freed after p->kobject has been released.
>
> Fixes: e96f9268eea6 ("NFS: Make all of /sys/fs/nfs network-namespace un=
ique")
> Signed-off-by: Vasileios Almpanis <vasilisalmpanis@gmail.com>

Reviewed-by: Benjamin Coddington <bcodding@hammerspace.com>

Ben
