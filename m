Received: from us-smtp-delivery-124.mimecast.com (us-smtp-delivery-124.mimecast.com [170.10.133.124])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id D66182FD67D
	for <linux-nfs@vger.kernel.org>; Sat, 12 Sep 2026 14:32:14 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=170.10.133.124
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1789223536; cv=none; b=SuxSp0eK+u4AOjkiFQ6sVUB3ZbWINRSGiZLZgVnNYDaARsM1LWKKGk6QBV++pseQAFPazQgs3uL0tMnCji1EvT4E96l1XeBUusxmlbjEn+tdcJY/dTA0+EJIi7JUXYTBdTi9YPbCOoAdFMi9vVKhUpMiTZqj1ny3jtdzsfMttlk=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1789223536; c=relaxed/simple;
	bh=D1xVcOyFbnJt+kPfw69TJZZSpZW+Lrht9+VuWgQGaeA=;
	h=Message-ID:Date:MIME-Version:Subject:To:Cc:References:From:
	 In-Reply-To:Content-Type; b=WGjAk52pi44LijQU655zv+Ho5/iEQctIdipD6jMlsGk+DhzM8fxQFt9Xbqq0rKoinJTO1Wa/zbV1aPiHxuun6sSXBevkDSQULiPDddAploUn81Hnc6mJKKH8QxHcJ3R+m8S57nb+bUEOmWhfjfWw+4OokE+3jEKd4dkO846TI3M=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dmarc=pass (p=quarantine dis=none) header.from=redhat.com; spf=pass smtp.mailfrom=redhat.com; dkim=pass (1024-bit key) header.d=redhat.com header.i=@redhat.com header.b=EDu5iGbq; dkim=pass (2048-bit key) header.d=redhat.com header.i=@redhat.com header.b=DMPiQ6CM; arc=none smtp.client-ip=170.10.133.124
Authentication-Results: smtp.subspace.kernel.org; dmarc=pass (p=quarantine dis=none) header.from=redhat.com
Authentication-Results: smtp.subspace.kernel.org; spf=pass smtp.mailfrom=redhat.com
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (1024-bit key) header.d=redhat.com header.i=@redhat.com header.b="EDu5iGbq";
	dkim=pass (2048-bit key) header.d=redhat.com header.i=@redhat.com header.b="DMPiQ6CM"
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=redhat.com;
	s=mimecast20190719; t=1789223533;
	h=from:from:reply-to:subject:subject:date:date:message-id:message-id:
	 to:to:cc:cc:mime-version:mime-version:content-type:content-type:
	 content-transfer-encoding:content-transfer-encoding:
	 in-reply-to:in-reply-to:references:references;
	bh=gvk5L2v5+pHUzFfM6MFbGKcQ1T6ijEfFhnUw0e5ucZ0=;
	b=EDu5iGbqctW28G9QDRc55xGsWGMAvbHdf3kpqBmayYhWsTFXxSEAfm3BPgpKNH3UKCcaCW
	No1YVwrL79gox/jduMOynuf1xIJqsqTcEjDQgaYyjIIc8KxyQF07PGVXsOOjy4fHsFqhsz
	HtkbB7+k5ZqhfZn3ppOdSTviUs2iul0=
Received: from mail-qt1-f200.google.com (mail-qt1-f200.google.com
 [209.85.160.200]) by relay.mimecast.com with ESMTP with STARTTLS
 (version=TLSv1.3, cipher=TLS_AES_256_GCM_SHA384) id
 us-mta-678-8PoEnIe0PGiAIUWHdOoqUw-1; Sat, 12 Sep 2026 10:32:12 -0400
X-MC-Unique: 8PoEnIe0PGiAIUWHdOoqUw-1
X-Mimecast-MFC-AGG-ID: 8PoEnIe0PGiAIUWHdOoqUw_1789223532
Received: by mail-qt1-f200.google.com with SMTP id d75a77b69052e-530d86d40abso29444391cf.1
        for <linux-nfs@vger.kernel.org>; Sat, 12 Sep 2026 07:32:12 -0700 (PDT)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=redhat.com; s=google; t=1789223532; x=1789828332; darn=vger.kernel.org;
        h=content-transfer-encoding:content-type:in-reply-to:from
         :content-language:references:cc:to:subject:user-agent:mime-version
         :date:message-id:from:to:cc:subject:date:message-id:reply-to
         :content-type;
        bh=gvk5L2v5+pHUzFfM6MFbGKcQ1T6ijEfFhnUw0e5ucZ0=;
        b=DMPiQ6CMOrdrZLPci+NOPiTOSmWpeDcb8s8cOM6VeM2fWMwkvFx9oUqM025E+dVzJW
         3LXlOSobexry8aJJ750Z/5LfKctHU9uzSkbLBmw/GVXBzaO6i+4BDJBEiZagesR72hhE
         +HSClZXYB3yqvJ8fgKkVDNwhZcSd7TU3NGxYxdvBRma3BOx3BJOojWlJ8cqf0K6MEVAv
         WWYQwx9M6/wZOfgYW+Ve3SRLuiUAInbzqamxmyzOxP+kb+Ip3CJ1UwoiczDn5jQM1geG
         gnY2MiYSUT/669ZUgQ7F5/uFzg1KWuKir3vtSy+gTNjLX0RMrk66bil34F2sCScqBKKJ
         wSOw==
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20251104; t=1789223532; x=1789828332;
        h=content-transfer-encoding:content-type:in-reply-to:from
         :content-language:references:cc:to:subject:user-agent:mime-version
         :date:message-id:x-gm-gg:x-gm-message-state:from:to:cc:subject:date
         :message-id:reply-to:content-type;
        bh=gvk5L2v5+pHUzFfM6MFbGKcQ1T6ijEfFhnUw0e5ucZ0=;
        b=oTYhDGghC2TwGz164+o6mhXJOU9RSXoLjdHAQ3QGXngHUWgdQqPhBPOP7FFRTlpacR
         10B6e+HAZAY21pKqfCl3SeWXB0H4iefOMpIJ96Ts4+3ma5eSyRb4S06csZv+YZXmhL7a
         gmZGqlEE/0cmTK8X0ED5OoekQeTUCdxzkXdDooxDNMy+SbRIFtA12i4rKlQ17a8kzvFb
         DQpS9DGwq07cdpkd4GJij8MPWSn9pzR4R37lA6st7xVjQxjdXUc7EZtdVjUGEBt2fySy
         nHfQUiuejFaQr+JvFkAWnVsC7ExXzGjnbaY72dK98nxV1RQjjWSbOv3L/rGlDd5SSylI
         uRlQ==
X-Gm-Message-State: AFuF++maZt3tkrZ02A0FrdgK1Dy15fp7XPFMGkBNEVaRUpYl6MO933F/
	o3gTuLqU7GlH3xc2SMXivQlI0ab7BR7MHQyYuj0+9ItPPvtIqRAKjbCrnXDrmIDS0Wp30c3z0bn
	kvX2BOtpz6PTyQWn9fuLqM5UQ0rQ334EvTLlQrbcvZNNNDTjlHGU3BIfPN/IP/w==
X-Gm-Gg: AYBFou0Sn+wtCY4vKOooyuk1Ilv9RMFW9jD1QP5isc6xovO6G7Y0AzRdgT9Q/aG9E0m
	F+KQIbmEJUP/u+SI9yeVCmbgabcZSaY9RMStmapBCz7O5VbkpiZQUxGKMvq42jkk0Cl5h0hvocE
	2IhFourHVIi+jlrdYN+hTFoBFj6BZP0V8Mw1CXr1qshiJ4SA9Nr8Urg5YxwLEZNE+BCA0KUhYqR
	nZwJ50AdJ1Kji9TVel1rivdhagqNZ3uBQ/WYq/qDEzr+53skPv+WeLcGXShFZf7WUTUzLVh7yip
	rg6RNcmiWWRv5X+6Yj0TQAsuD9kRO7ozh9y5tc4zqcF3OuKz1CyQozootYPB+WKkQ+LDZpdt5Us
	=
X-Received: by 2002:a05:622a:420a:b0:517:5b2c:6aae with SMTP id d75a77b69052e-530c851081bmr163051851cf.13.1789223531590;
        Sat, 12 Sep 2026 07:32:11 -0700 (PDT)
X-Received: by 2002:a05:622a:420a:b0:517:5b2c:6aae with SMTP id d75a77b69052e-530c851081bmr163051071cf.13.1789223531162;
        Sat, 12 Sep 2026 07:32:11 -0700 (PDT)
Received: from [172.31.1.12] ([70.105.244.208])
        by smtp.gmail.com with ESMTPSA id 6a1803df08f44-9120f45f1fdsm47566436d6.16.2026.09.12.07.32.08
        (version=TLS1_3 cipher=TLS_AES_128_GCM_SHA256 bits=128/128);
        Sat, 12 Sep 2026 07:32:10 -0700 (PDT)
Message-ID: <ddf3ee0e-7647-49a0-8f18-e3b8314eeab4@redhat.com>
Date: Sat, 12 Sep 2026 10:32:06 -0400
Precedence: bulk
X-Mailing-List: linux-nfs@vger.kernel.org
List-Id: <linux-nfs.vger.kernel.org>
List-Subscribe: <mailto:linux-nfs+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:linux-nfs+unsubscribe@vger.kernel.org>
MIME-Version: 1.0
User-Agent: Mozilla Thunderbird
Subject: Re: [rpcbind PATCH 0/6] rpcbind: various hardening fixes
To: Scott Mayhew <smayhew@redhat.com>
Cc: linux-nfs@vger.kernel.org
References: <20260903174245.1213147-1-smayhew@redhat.com>
Content-Language: en-US
From: Steve Dickson <steved@redhat.com>
In-Reply-To: <20260903174245.1213147-1-smayhew@redhat.com>
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 7bit



On 9/3/26 1:42 PM, Scott Mayhew wrote:
> Various hardening fixes for rpcbind.  Many of these are related to
> CALLIT/BCAST/INDIRECT processing, which in theory should be disabled
> when --enable-rmtcalls was not passed to the configure script, except
> currently that only prevents the forwarding port from being created.
> Patch 3/6 addresses this by completely disabling remote call
> functionality when --enable-rmtcalls is unset.
> 
> Scott Mayhew (6):
>    rpcbind: only log failures in check_callit() if connection logging is
>      enabled
>    rpcbind: bound stats lists in rpcbs_getaddr() and rpcbs_rmtcall()
>    rpcbind: fully disable remote calls when --enable-rmtcalls is unset
>    rpcbind: restrict RPCBPROC_GETSTAT to loopback callers
>    rpcbind: check for null netmask in addrmerge()
>    rpcbind: only free the forward slot if the reply xid matched the
>      request xid
> 
>   src/pmap_svc.c     |  2 ++
>   src/rpcb_stat.c    | 37 ++++++++++++++++++++++++++++++++++---
>   src/rpcb_svc.c     |  2 ++
>   src/rpcb_svc_4.c   |  2 ++
>   src/rpcb_svc_com.c | 24 ++++++++++++++++++++----
>   src/rpcbind.h      |  5 +++++
>   src/security.c     | 16 +++++++++++-----
>   src/util.c         |  3 ++-
>   8 files changed, 78 insertions(+), 13 deletions(-)
> 
Committed... (tag: rpcbind-1_2_9-rc3)

steved.

