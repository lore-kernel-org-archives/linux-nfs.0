Received: from mail-ot1-f51.google.com (mail-ot1-f51.google.com [209.85.210.51])
	(using TLSv1.2 with cipher ECDHE-RSA-AES128-GCM-SHA256 (128/128 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id C7EED4DA9BA
	for <linux-nfs@vger.kernel.org>; Fri, 16 Oct 2026 15:36:17 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=209.85.210.51
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1792164979; cv=none; b=QgioINqYRXqXvhC1XTzdKtRKK687A5EvQs/jdELSfD/Fov8K6f+taO+TShxm58Cpz26iMK4GjFYEKA5icHToQ676dDcZEXEIhdeXZ/CzmoqE+/XStXUWCzg25x8Fw0eESjDcJiu6/nuZePs2Y9h8LL2Aq6sWcx/C+b9jfYSdYd4=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1792164979; c=relaxed/simple;
	bh=0yRPDap4esDl76+FEHmUuaDNc8qa7omtSHQhGmcTbtU=;
	h=From:To:Cc:Subject:Date:Message-ID:In-Reply-To:References:
	 MIME-Version:Content-Type; b=rxOXu+CacA4yHT9svO+ylEGEQidEEjLSlqUP+me0KcpvyJXzfa9Z3GRz4ko/BCAogPrdMSVL2V1lh2UO1Yl5Q1w28Ug/liPeYYPBep/mLwmOp9fpRtsFShovdQMOuLgiuVRUtaMl+3OUGrdBxpLQhuKhT8Uq/WIeEedol06Jep8=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dmarc=pass (p=quarantine dis=none) header.from=hammerspace.com; spf=pass smtp.mailfrom=hammerspace.com; dkim=pass (2048-bit key) header.d=hammerspace.com header.i=@hammerspace.com header.b=f/1VQhXA; arc=none smtp.client-ip=209.85.210.51
Authentication-Results: smtp.subspace.kernel.org; dmarc=pass (p=quarantine dis=none) header.from=hammerspace.com
Authentication-Results: smtp.subspace.kernel.org; spf=pass smtp.mailfrom=hammerspace.com
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=hammerspace.com header.i=@hammerspace.com header.b="f/1VQhXA"
Received: by mail-ot1-f51.google.com with SMTP id 46e09a7af769-7f432ac553fso6720948a34.3
        for <linux-nfs@vger.kernel.org>; Fri, 16 Oct 2026 08:36:17 -0700 (PDT)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=hammerspace.com; s=google; t=1792164976; x=1792769776; darn=vger.kernel.org;
        h=content-type:mime-version:references:in-reply-to:message-id:date
         :subject:cc:to:from:from:to:cc:subject:date:message-id:reply-to
         :content-type;
        bh=dGRFsoI37EZtITqC7lNGXtb4cq5JxauEPW0sfje8uQA=;
        b=f/1VQhXAYst8srmQRilAyaOEj/T3nFxlUqN2pKkhG186n+mB0ZrO8LiTEkduOL/rXM
         TIEk7icdFUzcgCfMX2D0x9s5DPzKD8CPbIuxVCd1ckE6PKhIVOxfYv9UbBmmjHtb2JK2
         L8iHLmesyrARi8+PyYUwLI7RL/5fNSbPcGExcaJpkbd+hWOST/DYKf8rNyQt89/negXS
         L264YnJSmnmVNTaxM1O3AI4t0ms3Dpr78Tr7ClJroOGXFVbVe9mvL1bbKTtveDwxJ3ej
         Up0pWK09rH4357O6vhkhVwR0Zdv34GTfyY9NfqOZ9x4dzGELmlWHpa3UKqnxqsHzoSMd
         GdDw==
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20260707; t=1792164976; x=1792769776;
        h=content-type:mime-version:references:in-reply-to:message-id:date
         :subject:cc:to:from:x-gm-gg:x-gm-message-state:from:to:cc:subject
         :date:message-id:reply-to:content-type;
        bh=dGRFsoI37EZtITqC7lNGXtb4cq5JxauEPW0sfje8uQA=;
        b=Etn0Dz5lHTO7F4anoC4wTjqNJyM5LpugNNwJXfwDVEES6WISGSKhcrAKdlL5R6Qwoh
         p2iuesx4jQZMc1Z9nFdx6BARr5mv+4U2EBJT72SOiBTTaTF7dh96qWxjOwiKUbj/6WDx
         dyeqtdXOTSkgPdeHW/D3zrpa/ZeuN/CPuP45jUkZLoGkYRiat2PLqdlTD5kFh/Oz4mCa
         Fxjw1oXCz5TAGx+SqUVdIzB0/mHjqtLXDq8bXump6+m+vH5wTpcrBliP0YH+g/BUraMw
         jmgup7o9XsqaM/kMKpdJzjFh2pwU6iHDm4Fbb2l+rkVeZaAwrmHwFHEIGKCYweacWoLW
         VL5Q==
X-Forwarded-Encrypted: i=1; AKwUvBwUnPIvu3J7HnJIPTRrUmyC9Y8CxDcqJMXoijeYrZ+VO0jsGWnYlnUpi8+If+L7wGhwA4nV6mPR0/g=@vger.kernel.org
X-Gm-Message-State: AFq9FYKuXnKpbnOwXuQAGv9Mtone1DnjjKDFUhBBY2jba/DxJUPtRmwH
	JmcjRRPjInDnxQYit/U+diez6tH0MBaa5Iel9Fr/18rQY2GJLF/ZvLaAm1ckBpJezps=
X-Gm-Gg: AYBFou11Kc6xOqmL3RXOJs6WsNS/WY5W/FfQP3kqXYxNaZA5FeAQu8fg4Hrvx7sskQt
	cwQH6y+QJs8zlsQSmDp3TWNxaVZE0tK48v3FHmFWGTSzP+PcNVyE5VwPTwck9CdgC7vUKy27vCJ
	f5ktc7NSHNe3Y/wuoL3KwwWEZA2VsnjJtalbIr1eKoTreYVYPdHcCOOoYE5JnvO9z38Q9Fx8gGj
	lsVJbrs8iEVY+oSI5RcW6lNVC7qrGauJTB+5cavJamjOKsjVCg6EJpKuZdVA4H6VBD1ARGpL3hs
	0g5lpxI9GLqJflJoFoGAu8VJLiXOvtp/VQsq1PUAoQn4zyJRnSGtjpWeCp2Q5ojaqQh2/Q0DvmL
	q02Y0lm5NVTyR54Qup68l4g761WUcr9+cYSXCl4UrbMchF1SbKfS7Z0dVzskfBnZq0LMUmgpk6T
	RdgFDNymZyAGiQxVx/IVzB5Im/4X9ltzCo3wqOb4K2WTwa+sxMG+PvVwqMPEtGzmkfnndqb2CaF
	YjcWpOBRWPMGoUw/A==
X-Received: by 2002:a05:6830:6604:b0:822:e9bf:6445 with SMTP id 46e09a7af769-83094e7df4amr21696572a34.9.1792164976237;
        Fri, 16 Oct 2026 08:36:16 -0700 (PDT)
Received: from [192.168.254.51] ([66.97.168.37])
        by smtp.gmail.com with ESMTPSA id 46e09a7af769-842a4a00f0asm1917535a34.5.2026.10.16.08.36.15
        (version=TLS1_3 cipher=TLS_AES_256_GCM_SHA384 bits=256/256);
        Fri, 16 Oct 2026 08:36:15 -0700 (PDT)
From: Benjamin Coddington <ben.coddington@hammerspace.com>
X-Google-Original-From: Benjamin Coddington <bcodding@hammerspace.com>
To: Jeff Layton <jlayton@kernel.org>
Cc: Steve Dickson <steved@redhat.com>, linux-nfs@vger.kernel.org
Subject: Re: [PATCH nfs-utils 4/7] exportfs/mountd/exportd: get export
 features from the netlink policy
Date: Fri, 16 Oct 2026 11:36:14 -0400
X-Mailer: MailMate (2.0r6272)
Message-ID: <08D3D3E6-A6FE-4337-8A79-8EC8A9960191@hammerspace.com>
In-Reply-To: <20261016-netlink-noproc-v1-4-42791f4b6eb5@kernel.org>
References: <20261016-netlink-noproc-v1-0-42791f4b6eb5@kernel.org>
 <20261016-netlink-noproc-v1-4-42791f4b6eb5@kernel.org>
Precedence: bulk
X-Mailing-List: linux-nfs@vger.kernel.org
List-Id: <linux-nfs.vger.kernel.org>
List-Subscribe: <mailto:linux-nfs+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:linux-nfs+unsubscribe@vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain

On 16 Oct 2026, at 10:15, Jeff Layton wrote:

> diff --git a/support/include/exportfs.h b/support/include/exportfs.h
> index 97d62ff4b157..a7c145543075 100644
> --- a/support/include/exportfs.h
> +++ b/support/include/exportfs.h
> @@ -170,9 +170,15 @@ struct nfskey *			key_lookup(char *hname);
>  struct nfsd_export_policy {
>  	unsigned int	flags;		/* export flags it knows */
>  	unsigned int	secinfo_flags;	/* flags that may vary per flavor */
> +	int		max_attr;	/* highest svc_export netlink attribute,

^^ the value gets copied in from the export_policy_dump, but never used.  Do
you need this somewhere else?

Ben
