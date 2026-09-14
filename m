Received: from us-smtp-delivery-124.mimecast.com (us-smtp-delivery-124.mimecast.com [170.10.133.124])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id B6AB836E484
	for <linux-nfs@vger.kernel.org>; Mon, 14 Sep 2026 05:06:09 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=170.10.133.124
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1789362371; cv=none; b=Gr33Td4eR1TmiHE7RBtG2O/P5q2N3EDzbHKw7BJ6cWc3YrIuqUipdt7oj6mIIQaSIJUo5YSzzcFlNC/PN133nXNXDkpWj4wCMQPvchwhgxI6WFobht9YIKKdJB+NjVFWaXJm6FiFTDnfh9LEk7Vs1c9Q+nsGCgt8u1uzdS4o97I=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1789362371; c=relaxed/simple;
	bh=DpEMN5dyf5griPOXPjDcCaqJx4pTy/gW8R7CPF2hG2I=;
	h=Message-ID:Date:MIME-Version:Subject:To:References:From:
	 In-Reply-To:Content-Type; b=WlrGR/sJB8+KscqTUpqtTsoPqVQnu0gflpCM6ZBs7xjpRhcGnaPQprhU+av1hycpMT8T+NjvGBfko1LoTqXgTZixWur4XqZTguz5CRMr8iGq0Guth56SN+9TpS4Ff7WI770PMP/YN7ofX8ZnuOLZeW/tADHpluvpLoTwaBncrpY=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dmarc=pass (p=quarantine dis=none) header.from=redhat.com; spf=pass smtp.mailfrom=redhat.com; dkim=pass (1024-bit key) header.d=redhat.com header.i=@redhat.com header.b=FHQeAeqU; dkim=pass (2048-bit key) header.d=redhat.com header.i=@redhat.com header.b=WcUTr24v; arc=none smtp.client-ip=170.10.133.124
Authentication-Results: smtp.subspace.kernel.org; dmarc=pass (p=quarantine dis=none) header.from=redhat.com
Authentication-Results: smtp.subspace.kernel.org; spf=pass smtp.mailfrom=redhat.com
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (1024-bit key) header.d=redhat.com header.i=@redhat.com header.b="FHQeAeqU";
	dkim=pass (2048-bit key) header.d=redhat.com header.i=@redhat.com header.b="WcUTr24v"
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=redhat.com;
	s=mimecast20190719; t=1789362368;
	h=from:from:reply-to:subject:subject:date:date:message-id:message-id:
	 to:to:cc:mime-version:mime-version:content-type:content-type:
	 content-transfer-encoding:content-transfer-encoding:
	 in-reply-to:in-reply-to:references:references;
	bh=vjjF5pYt7IIJ0i5eJDtmUH/gOlkkN+2X5V6fUJeFMzI=;
	b=FHQeAeqUyoXF+DZjPX26rfCw9LWU9DF4qh42zRZxy3xzrM9JtusLEYLJyHYgQkdM4X18c7
	o/zBFnaK0cixtyNwm7Qhssi9j70WZfc+EYghMm8/wTSbnXH0yoW5s+yZPu+RWou6w6fkW5
	LcpabvG9BByaeLkYHkYTlnksj2I2SbI=
Received: from mail-qk1-f199.google.com (mail-qk1-f199.google.com
 [209.85.222.199]) by relay.mimecast.com with ESMTP with STARTTLS
 (version=TLSv1.3, cipher=TLS_AES_256_GCM_SHA384) id
 us-mta-502-JXeIMU4RMFiZASSKTG2q1g-1; Mon, 14 Sep 2026 01:06:07 -0400
X-MC-Unique: JXeIMU4RMFiZASSKTG2q1g-1
X-Mimecast-MFC-AGG-ID: JXeIMU4RMFiZASSKTG2q1g_1789362366
Received: by mail-qk1-f199.google.com with SMTP id af79cd13be357-93a0312937eso168524285a.1
        for <linux-nfs@vger.kernel.org>; Sun, 13 Sep 2026 22:06:07 -0700 (PDT)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=redhat.com; s=google; t=1789362366; x=1789967166; darn=vger.kernel.org;
        h=content-transfer-encoding:content-type:in-reply-to:from
         :content-language:references:to:subject:user-agent:mime-version:date
         :message-id:from:to:cc:subject:date:message-id:reply-to:content-type;
        bh=vjjF5pYt7IIJ0i5eJDtmUH/gOlkkN+2X5V6fUJeFMzI=;
        b=WcUTr24vPJ+PNcyCLmSZXxRDezswbmwsHY3vkc+iOgNIb7ywqED3qvIU+SfOcITrDx
         ASh/9DDPx40J1WPllzs6lt2+H2ENgoZvOVJ7YkxNDCtJUFOgP1YMO7h7gkUgFWr1epzX
         2roRVStCB+BRx1MDDewjqFHTfREAO7ianbTHOftlXEerwDu5hdw6gdPCaGG096c3YW3M
         j/64VuCssfzHRw8IUzm01wz8Fn55EncnibK93oWwHZd+jIzZLm1OaiuuCaFUVOEfNv6M
         Zr1MFXopvRgqqNPyv+R5D3fcoTPXQ4S0JfuwmXrcmcdOHJ2fec+zfaiRt5C57aHxPplY
         yDjA==
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20251104; t=1789362366; x=1789967166;
        h=content-transfer-encoding:content-type:in-reply-to:from
         :content-language:references:to:subject:user-agent:mime-version:date
         :message-id:x-gm-gg:x-gm-message-state:from:to:cc:subject:date
         :message-id:reply-to:content-type;
        bh=vjjF5pYt7IIJ0i5eJDtmUH/gOlkkN+2X5V6fUJeFMzI=;
        b=abteSozrQO8vRibjNamh8OhT+9/V6UXkinGs21a/2fHDoSJXAPAxzWShmg8n7jxDeT
         dLHGxs5+z2fww2btqer4/jKBLstMyFYt8DdwSFYJjiac9uuQ8mrCoN1/w+r+jftk/h75
         kCM8hVjIEYMz7/8pRugIwjVYsM/kJq2waUUNmcspcfcD8xheoP6Eck1QCMmOOElPhcsZ
         R1kQJ3gwgW+Y9eD2SYAwZkbH+pqEBLcQuYQq2+vONWAU2vpGpe5GK7vzQLk9yu/TpPXt
         Ug2x4cYek+AghWojk7zp0CnFlWCaSfBp+IOdddq56OmwihVsrdRkzNIQBvfW8GFbou5T
         HbnQ==
X-Forwarded-Encrypted: i=1; AKwUvBwRMhIHoqKv5+XJknH+4ps2ulssFrs82XVIXF/zOpnLSL7P2z4AjoAC2GnfBRZCpexxQ5CV196xePU=@vger.kernel.org
X-Gm-Message-State: AFuF++kZcrJqgG7EkyLekkDHqm8X4zpy69UC7bung4ug3S/5Fvedjxmn
	I7QHwGZZp85P/yBJYf8AYXSXGBsXb5cuI6TVLnL4o1Hghc/qbbBdCy8n2hZxzhQKz87JoPc85pZ
	26KYbhnoFfa50nifsHEfO7GCbiel0IkNkkIRYm5eZIEIzyKSr+CChJtPz8K70og==
X-Gm-Gg: AYBFou3cwO5dmFdgHi3gJeL54285YRbcPziBO5DfcDyk/14/GNhCXDQgjIFpFW+ZsRv
	Kq4++tK0WuI4wYvwhIDSdf28p/WIH8OM17d8BHsh9I/UQSUjeSTijuHsKe2m5nDVBztamKAZ4QN
	Awkk5FU3lFE04OasXjfhtddDJq4znMlIruSE4yFBzFHTI0oVCfEAxQ2o07oTxU3iO7oQAqsAl2/
	LbA070NmP+Vv1/OL6+t2Kj9WxsU2NFPiHLubv3LU9HBJfwFFefDZreFgeWXQlmXXqvKjDQURyBZ
	FQw+63K77jHrlXvYD8m4yW1Rdf3ijTc1qSXcVgwh/+BPKgOHEQkNR9qkg0wBap70fBzuUtrC8Yw
	=
X-Received: by 2002:a05:620a:4688:b0:939:6de7:8765 with SMTP id af79cd13be357-93a29bd4700mr120607185a.44.1789362366461;
        Sun, 13 Sep 2026 22:06:06 -0700 (PDT)
X-Received: by 2002:a05:620a:4688:b0:939:6de7:8765 with SMTP id af79cd13be357-93a29bd4700mr120603385a.44.1789362365907;
        Sun, 13 Sep 2026 22:06:05 -0700 (PDT)
Received: from [172.31.1.12] ([70.105.247.246])
        by smtp.gmail.com with ESMTPSA id af79cd13be357-93a2d4514c7sm25314385a.28.2026.09.13.22.06.04
        (version=TLS1_3 cipher=TLS_AES_128_GCM_SHA256 bits=128/128);
        Sun, 13 Sep 2026 22:06:05 -0700 (PDT)
Message-ID: <3890c344-1f97-4813-b9b5-4bd9a6830497@redhat.com>
Date: Mon, 14 Sep 2026 01:06:04 -0400
Precedence: bulk
X-Mailing-List: linux-nfs@vger.kernel.org
List-Id: <linux-nfs.vger.kernel.org>
List-Subscribe: <mailto:linux-nfs+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:linux-nfs+unsubscribe@vger.kernel.org>
MIME-Version: 1.0
User-Agent: Mozilla Thunderbird
Subject: Re: [PATCH 0/3] gssd, idmapd: validate names before using them
To: Prabhakar Pujeri <prabhakar.pujeri@dell.com>, linux-nfs@vger.kernel.org
References: <20260831104211.2297-1-prabhakar.pujeri@dell.com>
Content-Language: en-US
From: Steve Dickson <steved@redhat.com>
In-Reply-To: <20260831104211.2297-1-prabhakar.pujeri@dell.com>
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 7bit



On 8/31/26 6:42 AM, Prabhakar Pujeri wrote:
> These fixes validate externally supplied names before treating them as C
> strings.  They correct an uninitialized read in an error path, keep idmapd
> inside the fixed NAMETOID field, and reject server hostnames that do not
> fit in gssd's destination buffer.
> 
> The series is based on current nfs-utils master.  A fresh autotools build
> and make check complete successfully; the statd integration test is skipped
> when its required service environment is unavailable.
> 
> Prabhakar Pujeri (3):
>    gssd: fix use of uninitialized memory in error message
>    idmapd: validate NAMETOID names within their fixed-size field
>    gssd: reject server hostnames that do not fit
> 
>   utils/gssd/gssd.c      | 2 +-
>   utils/gssd/krb5_util.c | 9 +++++++--
>   utils/idmapd/idmapd.c  | 7 +++----
>   3 files changed, 11 insertions(+), 7 deletions(-)
> 
Committed... (tag: nfs-utils-2-9-3-rc3)

steved.

