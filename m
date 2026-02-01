Received: from us-smtp-delivery-124.mimecast.com (us-smtp-delivery-124.mimecast.com [170.10.133.124])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 3283019B5A7
	for <linux-nfs@vger.kernel.org>; Sun,  1 Feb 2026 17:33:30 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=170.10.133.124
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1769967212; cv=none; b=pjzE1SJ4YT22C8YxUG7IP7cR9IBiEMbSqL6gRGjGegrz2ZNpnuzbad0yQeyEZgVoUdZ1d3sg3Iw+LHys7tWKx7q+DhwOrnLFlIjATWDMxxDMUKwmLaNaIV2fvoRuGCDNHCpHJTrkGXFIzq694tUX5dXHp1HUcundzukpBAhz7S8=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1769967212; c=relaxed/simple;
	bh=sxWKQj9VeucVVV2SsbUamP/F7fYaVlnREJUD2nzBCsE=;
	h=Message-ID:Date:MIME-Version:Subject:To:References:From:
	 In-Reply-To:Content-Type; b=Ei3y1hhuaUK+kYPEZqczTTtNz6dk7FCJQrDX1bx8FiWgtkhjrvclXL9gWlQNNdZrjaB2Jn2jLDd97esWffd2DjbZtJal2tOlNN3G96i6jGSXLRZYnDOrg9OmaNxODc+wEB4VjV87KF7cfy/9Xp8uLPnTiXApMoLxAuJWQx9HeyM=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dmarc=pass (p=quarantine dis=none) header.from=redhat.com; spf=pass smtp.mailfrom=redhat.com; dkim=pass (1024-bit key) header.d=redhat.com header.i=@redhat.com header.b=HCWCoTi/; dkim=pass (2048-bit key) header.d=redhat.com header.i=@redhat.com header.b=RHIszShN; arc=none smtp.client-ip=170.10.133.124
Authentication-Results: smtp.subspace.kernel.org; dmarc=pass (p=quarantine dis=none) header.from=redhat.com
Authentication-Results: smtp.subspace.kernel.org; spf=pass smtp.mailfrom=redhat.com
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (1024-bit key) header.d=redhat.com header.i=@redhat.com header.b="HCWCoTi/";
	dkim=pass (2048-bit key) header.d=redhat.com header.i=@redhat.com header.b="RHIszShN"
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=redhat.com;
	s=mimecast20190719; t=1769967210;
	h=from:from:reply-to:subject:subject:date:date:message-id:message-id:
	 to:to:cc:mime-version:mime-version:content-type:content-type:
	 content-transfer-encoding:content-transfer-encoding:
	 in-reply-to:in-reply-to:references:references;
	bh=tiYrqbaKbxxXFLMzZONba2Fvbwtzh3S8Q+2giBnLKYM=;
	b=HCWCoTi/PjlGyhFZjO33SpHGDLBp/iFbLKFQnXyJNCZ0paQHPm9NADl7xZYsI/IXiYeGqj
	kNe1TgKcUIzZvL6+d2SGoeykoPwhbgd8v8D6CPnCIHnNSnUIJ4GzfhdPKOs8qx3MNgPvcG
	aoRNgX1BAaFaSk1qCUXr6V+D1yV50fA=
Received: from mail-qk1-f200.google.com (mail-qk1-f200.google.com
 [209.85.222.200]) by relay.mimecast.com with ESMTP with STARTTLS
 (version=TLSv1.3, cipher=TLS_AES_256_GCM_SHA384) id
 us-mta-662-X7d3S2HkN_Sg74KJH7x9gA-1; Sun, 01 Feb 2026 12:33:28 -0500
X-MC-Unique: X7d3S2HkN_Sg74KJH7x9gA-1
X-Mimecast-MFC-AGG-ID: X7d3S2HkN_Sg74KJH7x9gA_1769967208
Received: by mail-qk1-f200.google.com with SMTP id af79cd13be357-8c70b4b53e4so1652107185a.1
        for <linux-nfs@vger.kernel.org>; Sun, 01 Feb 2026 09:33:28 -0800 (PST)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=redhat.com; s=google; t=1769967208; x=1770572008; darn=vger.kernel.org;
        h=content-transfer-encoding:in-reply-to:from:content-language
         :references:to:subject:user-agent:mime-version:date:message-id:from
         :to:cc:subject:date:message-id:reply-to;
        bh=tiYrqbaKbxxXFLMzZONba2Fvbwtzh3S8Q+2giBnLKYM=;
        b=RHIszShNcA4RLRLst820LvPJtile3HWk8HFt1UtQHU7ou37hFESvOVJ6KxxP7o3ok0
         pxyDl+Y0PJowfJUF6zkAKsD6q4Gh4L8uSEBhE+E1mbRIeer5kglCTMiLv/AJ4kOoUbvq
         IaPv/33ve5ka48DguQOT6JHgjvsEBHUqUzs3y2CGXeV6IUoiXlu907Vr+UlUaE/oB4mU
         pULkLwgbVQCJGeyj0ODyogMFhIC8CaGlWpJV2b/Z0yrQhoXJx62d4keFoqLhzANUaE7d
         6VvuyTv3W7LL+vI/aEIvapWR5Lo+eGJDLcVoVyEmMP9+qeV1NpgaRYU7IR8qmR1QQCP2
         328w==
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20230601; t=1769967208; x=1770572008;
        h=content-transfer-encoding:in-reply-to:from:content-language
         :references:to:subject:user-agent:mime-version:date:message-id
         :x-gm-gg:x-gm-message-state:from:to:cc:subject:date:message-id
         :reply-to;
        bh=tiYrqbaKbxxXFLMzZONba2Fvbwtzh3S8Q+2giBnLKYM=;
        b=hNqFsN7cNxiJEDugQjh40TEUJOs6/IJ2gYN3xhRXvXpM8eoVyDWFEx1j6mnkbkA/TQ
         v0QhavE27r09hoVcRcgnzEcn+WlWKvfdi+rYWGM237w1g5qKoyfRgZs9Gp5g+GvuCK+v
         n5P8QVHvQg346hhi9dwJzG2jOAdq9MqEYAqfDAsKUiRnn1aZShKHO6CEhdjM+x4SSyXs
         N7CDbjnquuc2dFiT6AtQgJL1dTMGuyGKpTdnJ00kalGW0i7G66WjztDkGvwZ9UNQW5Mt
         CS6OpMc+rcBdvJlxxRRATBHjf3VvyQ232bf/fQH15/952XlQ4mhxWe8E+7rPuR/2Q/n8
         SH1Q==
X-Forwarded-Encrypted: i=1; AJvYcCU4v1VBFJud+tNjE45AaWH7xLMiXkVeDJxbs07D/XYzExj6AS2DyX+Cp3Ipa5s3sL/UOZB2fWM59QA=@vger.kernel.org
X-Gm-Message-State: AOJu0YyIZtofJTBBK6S5FknzlhDCf63Hc1PJT/JYFyLb3rdF2J4Ue2VM
	6cv35SWyl+pSomXN/LPFeixIflq/4AVQx4xEeXR5Og+EcuEhw7rCBpyUzmjM8DQCyu3h7/XN4nq
	Qj9cyuu+QWictK2fjiOEJFFnagi5frVBDm2ZAF3rS1urfiK00tJzJmYZuSBADEVejkjSvQg==
X-Gm-Gg: AZuq6aLDF9dthniGZtEZegKVcEvopBmpcY/2e9yXGBKssvaS3tTF++PJIMa7uXnQ3oj
	mA0OYnJpYG1CRv8O7C7BzZvUxv6KewzdDz2rcaGH00XslhXEVbhX4x1Z5eBUjmGIblw7hoy+nSF
	Xggu9zGYjSfnS+xwh4DAQsLZFOj+OYiabLquMX3ofslfpROzqCK4tWnpirWjIkM+zoI1RI5dPeZ
	/yESx0zVzj6E5FJ4V6ivGGrJQbXr4ncsi1C4o1WNYfDYT2icckeETgeFjVAWerwLPuYJrSAYHQs
	W/DPDQX3ELvteOunIjQRPnGWqlFXa9Q8kN9P9BcwOkGHX+5bUqmpdOA+LzPbFVCJPF8tPEgeWPO
	SnH8Vt7ex
X-Received: by 2002:a05:620a:690d:b0:8b2:e069:6911 with SMTP id af79cd13be357-8c9eb2e84a3mr1340637185a.59.1769967207639;
        Sun, 01 Feb 2026 09:33:27 -0800 (PST)
X-Received: by 2002:a05:620a:690d:b0:8b2:e069:6911 with SMTP id af79cd13be357-8c9eb2e84a3mr1340634285a.59.1769967207191;
        Sun, 01 Feb 2026 09:33:27 -0800 (PST)
Received: from [172.31.1.12] ([70.105.242.59])
        by smtp.gmail.com with ESMTPSA id af79cd13be357-8c711d433adsm1082753685a.39.2026.02.01.09.33.25
        (version=TLS1_3 cipher=TLS_AES_128_GCM_SHA256 bits=128/128);
        Sun, 01 Feb 2026 09:33:25 -0800 (PST)
Message-ID: <bab4411d-ca11-4ce7-9d27-29d171c01cae@redhat.com>
Date: Sun, 1 Feb 2026 12:33:25 -0500
Precedence: bulk
X-Mailing-List: linux-nfs@vger.kernel.org
List-Id: <linux-nfs.vger.kernel.org>
List-Subscribe: <mailto:linux-nfs+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:linux-nfs+unsubscribe@vger.kernel.org>
MIME-Version: 1.0
User-Agent: Mozilla Thunderbird
Subject: Re: [nfs-utils PATCH 02/10] mountstats: fix a typo in man page
To: "Seiichi Ikarashi (Fujitsu)" <s.ikarashi@fujitsu.com>,
 "'linux-nfs@vger.kernel.org'" <linux-nfs@vger.kernel.org>
References: <OSZPR01MB777224FD0BF094808D113DC0889EA@OSZPR01MB7772.jpnprd01.prod.outlook.com>
Content-Language: en-US
From: Steve Dickson <steved@redhat.com>
In-Reply-To: <OSZPR01MB777224FD0BF094808D113DC0889EA@OSZPR01MB7772.jpnprd01.prod.outlook.com>
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 7bit



On 1/29/26 3:50 AM, Seiichi Ikarashi (Fujitsu) wrote:
> Signed-off-by: Seiichi Ikarashi<s.ikarashi@fujitsu.com>
Committed... (tag: nfs-utils-2-8-5-rc3)

steved.

> ---
>   tools/mountstats/mountstats.man | 2 +-
>   1 file changed, 1 insertion(+), 1 deletion(-)
> 
> diff --git a/tools/mountstats/mountstats.man b/tools/mountstats/mountstats.man
> index d5595fc7..b2940f67 100644
> --- a/tools/mountstats/mountstats.man
> +++ b/tools/mountstats/mountstats.man
> @@ -47,7 +47,7 @@ mountstats \- Displays various NFS client per-mount statistics
>   .RI [ mountpoint ] ...
>   .P
>   .SH DESCRIPTION
> -.RB "The " mountstats " command displays various NFS client statisitics for each given"
> +.RB "The " mountstats " command displays various NFS client statistics for each given"
>   .IR mountpoint .
>   .P
>   .RI "If no " mountpoint " is given, statistics will be displayed for all NFS mountpoints on the client."
> -- 2.47.3
> 

