Received: from mail-ot1-f52.google.com (mail-ot1-f52.google.com [209.85.210.52])
	(using TLSv1.2 with cipher ECDHE-RSA-AES128-GCM-SHA256 (128/128 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id B751536E48C
	for <linux-nfs@vger.kernel.org>; Thu,  8 Oct 2026 19:34:31 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=209.85.210.52
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1791488072; cv=none; b=BJcSydArUbw/uDRTm8rOcNAjstdKOr+1gtlGSQK4BCfphN0EBWLMSY8OSZmTlvagzZjg2eXuyweUvBLoHQTQJWSGKwB8Uvz3+buoD7sUXFMUa3AA9QtB2ap+jaka+s0genoG+hHxTLsRWYdlrxP4rUi/eLovC0Lx/50ylgR06eY=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1791488072; c=relaxed/simple;
	bh=19jW3Qx+Jy662tYn7041IzoUAhSyUrJo+m+PIsD1QHY=;
	h=From:To:Cc:Subject:Date:Message-ID:In-Reply-To:References:
	 MIME-Version:Content-Type; b=IsljOeCvCkn8G7c8ei7xch7RGosbCK+R94hj157cxp0IDENxWm+iHyw6Sr8CIdC9t6TVt1KooZVDmgVE56SRCCiOcv0Nhqyohlc+8mYzgCTyyMKFnqU3210Zf/Omrl3/QM2OrW7LsrO6fKSTaDpxeuFWwhWZmWZQjHOm4T87ZpA=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dmarc=pass (p=quarantine dis=none) header.from=hammerspace.com; spf=pass smtp.mailfrom=hammerspace.com; dkim=pass (2048-bit key) header.d=hammerspace.com header.i=@hammerspace.com header.b=LEkrB06Q; arc=none smtp.client-ip=209.85.210.52
Authentication-Results: smtp.subspace.kernel.org; dmarc=pass (p=quarantine dis=none) header.from=hammerspace.com
Authentication-Results: smtp.subspace.kernel.org; spf=pass smtp.mailfrom=hammerspace.com
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=hammerspace.com header.i=@hammerspace.com header.b="LEkrB06Q"
Received: by mail-ot1-f52.google.com with SMTP id 46e09a7af769-81c5aac8478so2128099a34.0
        for <linux-nfs@vger.kernel.org>; Thu, 08 Oct 2026 12:34:31 -0700 (PDT)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=hammerspace.com; s=google; t=1791488070; x=1792092870; darn=vger.kernel.org;
        h=content-type:mime-version:references:in-reply-to:message-id:date
         :subject:cc:to:from:from:to:cc:subject:date:message-id:reply-to
         :content-type;
        bh=mwrqHWtebrfUIg7ZBybI4lUXgraiwzf2BBKtXejFd0A=;
        b=LEkrB06QG4PAwu9Ip0vytz6DgEjaPWuw7VxIj/rTa5sJ5G047bLMiSQVQ3YIYP+e82
         S0ZOFL7AZtvWM4sxWvTyxyDLGi7kL9UAozZGizpRyu51EU5eiPhA/QNOjwsi5519pqsn
         7ZZA6e6npW+K0HBy8yVVTK5IsswwtFNu/lekcA5a6Srx7aqy3n7Y6X5n1Xy0WU+AYBYR
         22D/NVCinO9RlHs+QvyMigL2oLTmY9dReDOHRMSsAPmHLZ4Zb3ScEAI5OKKfEhk3kFeN
         0mgH+gVBhT+KSF9DqYCH0za5C/poJO8xAknTSAzoc8o+2NzJtD53Ir0DjBYqQRFBxFk+
         vGUg==
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20260707; t=1791488070; x=1792092870;
        h=content-type:mime-version:references:in-reply-to:message-id:date
         :subject:cc:to:from:x-gm-gg:x-gm-message-state:from:to:cc:subject
         :date:message-id:reply-to:content-type;
        bh=mwrqHWtebrfUIg7ZBybI4lUXgraiwzf2BBKtXejFd0A=;
        b=DONO+Yc5cD3dC6Uc8j0uVrSeR+CqXUoOVnntPKbE2N3HVzo0NRPWwk9jz8Zs3Pc5xZ
         eiLC7y+jOAedVSwD8Z7OjioYl3elVjP6ulxxUtbit9dCHkuzu1rpYYlirM+HXOpYQnk7
         1UX691fcCF73zyx1/OMI0H5h30ElwQLiitaG1YSKj6Kud7lzQ8KJg2LJTC441WSsu5If
         bVqw/FHMbsHHPlJt6IAJQoVEc3KuDUqGKlXHiZrRcJ/2p4TocyYugFxAp/tUyRcVljha
         ySFhwkt/h0PI4arunqpNLua1TrQcCnQHxRZOr0fKXFApqBaQxlzcfy8y/PT4Hj6/WIX5
         XmJA==
X-Forwarded-Encrypted: i=1; AKwUvBytocccGYt7Vzh3jYCP2BguIHztYdDTu6lBzNyRp8WpWoDfCQa6Ht90TTwD5Gvb+Y/zwznEIqFdh3k=@vger.kernel.org
X-Gm-Message-State: AFuF++nnXrgBByWNREmOr+gUqu8mDNUP85d35c8ZvaAbuUXzn95PVS8E
	Osksoh2voIyAMH9r+wFKoWD9xyIighEtEM+bVvsNxFqyyGsIvIchDDx810oi9u+0rUo=
X-Gm-Gg: AYBFou0MrLDk6O78gVstEPgpQINHZLZfJaaWUlO/dZDhFsP0GsshnErPZrM3ariUYWn
	cGW6mJh9bIIb70C+UlxYmPiPKeeqwzQyTcgFrEV+DV5IkeGkuEUicSuPAXZeCIsacV2qMzIcRkS
	u7O2NkQxpro4x8GEG7G07dQeYiMLUo9ZPXr49k3qZibyIdgkoyx/BNqOoR78873YikNeuLrWWP+
	K4I4xifVcvxzKwj0EdLYey/tvLdKGwmiOac6bhXn/feaoptR10F/1L2RCMgV9WJE+fyYIOyHBxn
	fNOe/18a/KZqRBPyp9NcHQO0RjDpaJJzX7GMN0Y9/tFLH7rQyuEjabujXaMK++5sfeuMUJdzVb7
	eADlzaQcXIPQxIr2cPOeW1A22iT5AOKHE49Ui+d7p/wetHAJq1QFpRVZq2jqK441UyYEWawEfxo
	2TV7SYxAWfuSyFBV4Es1+n+5DKoVkhZcwWoqEG5WeDuPr3bgPkcT9Vo6SUzfZcaRAyWIPJJcBSi
	+MLtv0YweinDKNx4w==
X-Received: by 2002:a05:6808:10c4:b0:4f3:9349:15e with SMTP id 5614622812f47-4fc476a4ea5mr6766409b6e.41.1791488070378;
        Thu, 08 Oct 2026 12:34:30 -0700 (PDT)
Received: from [192.168.254.51] ([66.97.168.37])
        by smtp.gmail.com with ESMTPSA id 5614622812f47-50b54836ad1sm214579b6e.9.2026.10.08.12.34.29
        (version=TLS1_3 cipher=TLS_AES_256_GCM_SHA384 bits=256/256);
        Thu, 08 Oct 2026 12:34:29 -0700 (PDT)
From: Benjamin Coddington <ben.coddington@hammerspace.com>
X-Google-Original-From: Benjamin Coddington <bcodding@hammerspace.com>
To: Rushil Patel <rushil.patel@gsacapital.com>
Cc: Benjamin Coddington <ben.coddington@hammerspace.com>,
 linux-nfs@vger.kernel.org, Trond Myklebust <trondmy@kernel.org>,
 Anna Schumaker <anna@kernel.org>,
 Valentino Aguiar <valentino.aguiar@gsacapital.com>
Subject: Re: [RFC PATCH] NFSv4.1: don't stall installing an OPEN stateid after
 a failed CLOSE
Date: Thu, 08 Oct 2026 15:34:27 -0400
X-Mailer: MailMate (2.0r6272)
Message-ID: <327DB787-70B2-45A4-B5FD-7F49531B317B@hammerspace.com>
In-Reply-To: <20261008191903.1770486-1-rushil.patel@gsacapital.com>
References: <20261008160253.1702053-1-rushil.patel@gsacapital.com>
 <3E653493-0BDC-487C-92ED-9647E5D8CDE0@hammerspace.com>
 <20261008191903.1770486-1-rushil.patel@gsacapital.com>
Precedence: bulk
X-Mailing-List: linux-nfs@vger.kernel.org
List-Id: <linux-nfs.vger.kernel.org>
List-Subscribe: <mailto:linux-nfs+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:linux-nfs+unsubscribe@vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain

On 8 Oct 2026, at 15:19, Rushil Patel wrote:

> Hi Ben,
>
>> I think the server is broken here, and the client's wait is doing what
>> it's supposed to do.
>
> Agreed on the server being broken. We've since isolated this to ONTAP's
> Concurrent Open Close path. Disabling COC removes the reproducer, and
> re-enabling it restores the stalls with the client, kernel, mount and
> workload unchanged. We also have both replies captured on the same
> session, with matching filehandle and full stateid identity. We're taking
> that to NetApp.
>
>> The client already handles the compliant case: OLD_STATEID goes through
>> nfs4_refresh_open_old_stateid(), waits for the OPEN's update, and then
>> close_prepare sees the new opener and doesn't send anything. There's
>> no 5 second stall.
>
> Understood. I'm not arguing that the compliant case is mishandled, or
> that the ordering guard should be removed.
>
> The question I was trying to get at is whether we can handle this
> particular server failure more gracefully.

The maintiners (Trond, Anna) would have to answer that one.  In the past
there's been a strong position of not taking fixes in the client for server
bugs.

Ben
