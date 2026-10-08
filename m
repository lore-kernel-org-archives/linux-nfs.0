Received: from mail-oi1-f173.google.com (mail-oi1-f173.google.com [209.85.167.173])
	(using TLSv1.2 with cipher ECDHE-RSA-AES128-GCM-SHA256 (128/128 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 899DE3876BE
	for <linux-nfs@vger.kernel.org>; Thu,  8 Oct 2026 16:24:12 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=209.85.167.173
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1791476653; cv=none; b=c3ph0aq8mWNp+lkWr0aIfnQ0x57R6GSS+qeqh7en55iYaczWlZXF0bH3rGr2Nsi7arAQARXMD0Hq8UP6RcUTYJVithQ5Ge9UPBqMz0KsDja4usuYWLLEba7R/pb/PKeoplYuDGzUmQdUUD3KUTIyzd10Gs5yPAuvNsehI+xfAr4=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1791476653; c=relaxed/simple;
	bh=Mp/66VQF5NnPunZehPO1e6gXCIRNhdXjv8mR7THonYk=;
	h=From:To:Cc:Subject:Date:Message-ID:In-Reply-To:References:
	 MIME-Version:Content-Type; b=nxXrI431OeRW/3EiytYkC9CLH7Tc6Lg8RKI+2goLoWxuY3EqV7am3JDdrb77zwly0W17bgK+D6NjgVty7LwYhYaCvQbd1lPRba3C3pV4zqt6vh4qeg25KVTRq9P0YMiUSs9f2ebeonEbNAQ8/qrOe7vGCXkUg7N0NBXOZ834n84=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dmarc=pass (p=quarantine dis=none) header.from=hammerspace.com; spf=pass smtp.mailfrom=hammerspace.com; dkim=pass (2048-bit key) header.d=hammerspace.com header.i=@hammerspace.com header.b=pjtLo1Ut; arc=none smtp.client-ip=209.85.167.173
Authentication-Results: smtp.subspace.kernel.org; dmarc=pass (p=quarantine dis=none) header.from=hammerspace.com
Authentication-Results: smtp.subspace.kernel.org; spf=pass smtp.mailfrom=hammerspace.com
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=hammerspace.com header.i=@hammerspace.com header.b="pjtLo1Ut"
Received: by mail-oi1-f173.google.com with SMTP id 5614622812f47-4f5e6517982so1200685b6e.2
        for <linux-nfs@vger.kernel.org>; Thu, 08 Oct 2026 09:24:11 -0700 (PDT)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=hammerspace.com; s=google; t=1791476651; x=1792081451; darn=vger.kernel.org;
        h=content-type:mime-version:references:in-reply-to:message-id:date
         :subject:cc:to:from:from:to:cc:subject:date:message-id:reply-to
         :content-type;
        bh=zROTYuStcmUUU7SZTuWd+lcCLDSVoy7e+xWeai+YrWY=;
        b=pjtLo1UtJizQLgMQ+spzhoMOG+/dF/Pkh0PBLuP+iqDXN8sHZ+AWOMlDq7CBmAh1x5
         uftV4v7LUD1tH7Cu6CzSVbKoq93CuvnYXMJe/Sgcgwh26muFZyX2s8S/0gh/IVwK+soT
         Gi9fEBL0QKe9Cdw5GtmxkbmXc3jMF29P0WeBX6uj1PCXoFVLz5suJFS2jAC3EczPMpXs
         riFLxRzDTgO6JsAKnGS9isgxeLvToPoRO+47mJ0IYQssac6Bz1MaquDX2wLApchSYOEj
         j+lHlSYbJ3gcQHSnr7k7LavUafYTqwC3/J7h4QvUK4R5HoQpXgDPEovv1ayz9vGAuwZy
         zHow==
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20260707; t=1791476651; x=1792081451;
        h=content-type:mime-version:references:in-reply-to:message-id:date
         :subject:cc:to:from:x-gm-gg:x-gm-message-state:from:to:cc:subject
         :date:message-id:reply-to:content-type;
        bh=zROTYuStcmUUU7SZTuWd+lcCLDSVoy7e+xWeai+YrWY=;
        b=MHPtDL5V5pR1XUos3Kb9F0g4z9hraB0o6xIoBDYh8NBNJifKhHBlfs7Ji7d9q553h4
         Yyrr9pn8IRjOtFnv2WTpYIiK5WOtZNIteQ1iqlFR1FEjpWS0GjP8TYd53G99QH5H86R8
         YiQWEnqFfthtJxbn3cn3DVtmt1KrLD2GQUjp+J435EOrqZHWi0/CPeXmQS0rOYwxcyhK
         k4Rznmgp2bQvUpYgNfFu8SQktV2qJMfDO3edu9CBeV/1K+9znGiU8VxhYEUVWA/kPU9d
         oDwlRspYM2HKgbtZbJ/W8u0agoovwdW7QrizYWd0Qx4BwTdRE1k8ys5VADbTRXG+T+QD
         38Vw==
X-Gm-Message-State: AFuF++k6YxQyAtetg+d4EjzzdU4qKkneNAeWxToMJaV5pfJ0dhFAv2pH
	Bhz1x2KKtuDRF9oqeJV/9tQuTuatiVKV6sIBtsjP3Xssh5SWG1M6k1AprlGm9dDyhMg=
X-Gm-Gg: AYBFou3PF2YnBjea27nyFGDvmVNq03HvfxdLXu8h8+7dSaHOG6JhhVnvLiibLe50Etm
	lYhg+mrw2NiDfnUbkkgkIjJdI4A+mcfLU6mbBc/m+P8CKKoA6zpPW51mxFbQYZGtvbgrEKZLv6R
	BXWj8MvFFTC8eNk2AbOOfjcoR3afvMwkdtbRbUArwtat6BH9WEbbxffOHwT7kAmRcnQfOJuTAz6
	htpVUVQBrVpfA1fx9LhJ67PgHdWtkpv7DbgZeL5+5fLFBY1Ot3Wmb/dPI0YHaEt33ukeSJOD4qb
	/n5nuuGbYLjyFLK8x5V13LzXrgSpFbbQ2G+92zVlGrIGKOtwLhB7HjRflnFcJwBNix6ZZVaYgVD
	kb/m44gbjKlq/SNQwTlrt3NnVWU2kpk1mqZSS/rxqZqzUILytuLxlvXxyrnsDJo7JqewN1yu6kk
	jVtB5/4HWLxRDz2iVftMt9erFtHI7wagiSvTERQkZJOr/7gG+QFseorvdYHK/D14WrRaLX5TtbR
	ByXdCYUSvo2mfKKRQ==
X-Received: by 2002:a05:6808:10c5:b0:4b9:e5fa:8a14 with SMTP id 5614622812f47-4fc46c9115emr7948340b6e.25.1791476650763;
        Thu, 08 Oct 2026 09:24:10 -0700 (PDT)
Received: from [192.168.254.51] ([66.97.168.37])
        by smtp.gmail.com with ESMTPSA id 5614622812f47-4fc49a71636sm5583746b6e.16.2026.10.08.09.24.07
        (version=TLS1_3 cipher=TLS_AES_256_GCM_SHA384 bits=256/256);
        Thu, 08 Oct 2026 09:24:10 -0700 (PDT)
From: Benjamin Coddington <ben.coddington@hammerspace.com>
X-Google-Original-From: Benjamin Coddington <bcodding@hammerspace.com>
To: Rushil Patel <rushil.patel@gsacapital.com>
Cc: linux-nfs@vger.kernel.org, Trond Myklebust <trondmy@kernel.org>,
 Anna Schumaker <anna@kernel.org>,
 Valentino Aguiar <valentino.aguiar@gsacapital.com>
Subject: Re: [RFC PATCH] NFSv4.1: don't stall installing an OPEN stateid after
 a failed CLOSE
Date: Thu, 08 Oct 2026 12:24:06 -0400
X-Mailer: MailMate (2.0r6272)
Message-ID: <3E653493-0BDC-487C-92ED-9647E5D8CDE0@hammerspace.com>
In-Reply-To: <20261008160253.1702053-1-rushil.patel@gsacapital.com>
References: <20261008160253.1702053-1-rushil.patel@gsacapital.com>
Precedence: bulk
X-Mailing-List: linux-nfs@vger.kernel.org
List-Id: <linux-nfs.vger.kernel.org>
List-Subscribe: <mailto:linux-nfs+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:linux-nfs+unsubscribe@vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain

On 8 Oct 2026, at 12:02, Rushil Patel wrote:

> With NFSv4.1 the client sends OPEN and CLOSE for the same open owner in
> parallel. If a full CLOSE of open stateid A:n races an OPEN of the same
> file and the server rejects the CLOSE with NFS4ERR_BAD_STATEID, the
> client clears NFS_OPEN_STATE but leaves A:n cached in open_stateid. When
> the racing OPEN's reply then arrives carrying A:n+1,

I think the server is broken here, and the client's wait is doing what
it's supposed to do.

There's no order the server could have processed these two in that
gives you CLOSE(A:1) -> BAD_STATEID and OPEN -> A:2.  If the OPEN went
first, A:2 is current and the CLOSE has to get NFS4ERR_OLD_STATEID
(RFC 8881 section 8.2.2 -- that section uses this exact OPEN vs CLOSE
race to explain why CLOSE carries a non-zero seqid).  If the CLOSE went
first, A:1 was current and the CLOSE should have succeeded.  Then the
OPEN gets a new stateid at seqid 1, or reuses "other" with seqid
continuity (8.2.4), but in no case does the CLOSE fail.

The client already handles the compliant case: OLD_STATEID goes through
nfs4_refresh_open_old_stateid(), waits for the OPEN's update, and then
close_prepare sees the new opener and doesn't send anything.  There's
no 5 second stall.

> The server-side reason for the rejection is not established here.

You don't need it -- the two replies contradict each other on their own.
You probably need to file a NetApp bug, capture both replies on one session
- that should be enough for them.

Ben
