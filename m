Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.remote-ip=170.10.129.124
ARC-Seal: i=1; d=subspace.kernel.org; s=arc20261015; a=rsa-sha256; cv=none;
	t=1794664211;
	b=cSbujjTbY6dqfX8Ue3pRQzcI70ghMOrtbVmYEIXlv8jcFLhfZGL6KnShWvThR5rmdohL
	 aDQeWSmbXZH67KHPHoDJeJz/QroXrRTYGFehBEaqja0bNn75YuZEspMsAxaZ80GFghe1e
	 ogqEY8KUfdVDfTa2wHVAuS3GxmZ7Y9vvgaU4T1Z12X0lRGpMsJlswzOZ4cF5AWSfxmNnK
	 +kbFUVH0PZs7klBAbD6lyPOtHjo5OAcFfVSNV0TVIC00LCtzV+6WbqmjlrL24bL4Rmqs1
	 fJW4nZe2bXTRka+1erqZmidEdUNNE6KhUuHsaoIaUGkjakmE7UPWZXZacm6JwpGUe8w==
ARC-Message-Signature: i=1; d=subspace.kernel.org; s=arc20261015;
	a=rsa-sha256; c=relaxed/relaxed; t=1794664211;
	h=DMARC-Filter:DKIM-Signature:Received:X-MC-Unique:
	 X-Mimecast-MFC-AGG-ID:Received:DKIM-Signature:X-Google-DKIM-Signature:
	 X-Gm-Message-State:X-Gm-Gg:X-Received:X-Received:Received:Message-ID:
	 Date:MIME-Version:User-Agent:Subject:To:Cc:References:
	 Content-Language:From:In-Reply-To:Content-Type:
	 Content-Transfer-Encoding;
	bh=4YzoJGegLfItOLY+IVEzekWm9Pz06JwsipBm6nVoJOo=;
	b=N56Svpxv7XS5ScrcbWEm7u8FVO9yTSiyYNKcQRzdYc5KgrICv0H0PI8OX4kfAmNx1+p4
	 PTa5ztbKjL7BbvniOU1cgKxtv4hI3xo9hJAgICoe1bWSXirdo0UX2NpAJdH9FnsTUJBcE
	 zP0tyM14uxEun1GHXUlv2ARD0fZoSvgqvrvu+jLvA4tpGJdkwK2ULTd2CcYcmuwujkaLv
	 FGM+BN5j4STNTy2tzqZy+VSAXUgijjuHRvLyCGdBIzz1ayZC9XUCKEhkhK/XoD5d7amw2
	 QfBKWibdwaQqVLDDCsvULUW8QxtH+e9EOQueTCTOxwUeJgzM3RZxPXBE7peqGlfHauA==
ARC-Authentication-Results: i=1; smtp.subspace.kernel.org; 
	dmarc=pass header.from=redhat.com;
	spf=pass smtp.mailfrom=redhat.com;
	dkim=pass header.d=redhat.com header.i=@redhat.com header.a=rsa-sha256 header.s=mimecast20190719 header.b=SWzBBlU0;
	dkim=pass header.d=redhat.com header.i=@redhat.com header.a=rsa-sha256 header.s=google header.b="saE/Di6T";
	arc=none smtp.remote-ip=170.10.129.124
Received: from us-smtp-delivery-124.mimecast.com (us-smtp-delivery-124.mimecast.com [170.10.129.124])
	(using TLSv1.3 with cipher TLS_AES_256_GCM_SHA384 (256/256 bits)
	 key-exchange X25519 server-signature ECDSA (prime256v1) server-digest SHA256)
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 677C1606A333
	for <linux-nfs@vger.kernel.org>; Sat, 14 Nov 2026 13:50:10 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.4.2 smtp.subspace.kernel.org 677C1606A333
Authentication-Results: smtp.subspace.kernel.org; dmarc=pass (p=quarantine dis=none) header.from=redhat.com
Authentication-Results: smtp.subspace.kernel.org; spf=pass smtp.mailfrom=redhat.com
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (1024-bit key) header.d=redhat.com header.i=@redhat.com header.a=rsa-sha256 header.s=mimecast20190719 header.b=SWzBBlU0;
	dkim=pass (2048-bit key, unprotected) header.d=redhat.com header.i=@redhat.com header.a=rsa-sha256 header.s=google header.b=saE/Di6T
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=redhat.com;
	s=mimecast20190719; t=1794664209;
	h=from:from:reply-to:subject:subject:date:date:message-id:message-id:
	 to:to:cc:cc:mime-version:mime-version:content-type:content-type:
	 content-transfer-encoding:content-transfer-encoding:
	 in-reply-to:in-reply-to:references:references;
	bh=4YzoJGegLfItOLY+IVEzekWm9Pz06JwsipBm6nVoJOo=;
	b=SWzBBlU0jVW74Z60mPW+yLevLYXXvrF2vi7tsJSYKg+W/gG0Gfm8uHPGDKqt8qGOq7ww+u
	rjld1+KTefV5Dw6F1dceMqvDSOVhUd/+3Gx8oT438w85IdVoRxgm/ayB1Jl2oNo4X8zaw1
	pwz41p0BjRDKx0BeW01jWtkRyN4sEMQ=
Received: from mail-qv1-f69.google.com (mail-qv1-f69.google.com
 [209.85.219.69]) by relay.mimecast.com with ESMTP with STARTTLS
 (version=TLSv1.3, cipher=TLS_AES_256_GCM_SHA384) id
 us-mta-189-ytThrDkoNyWU1cnho-d_yA-1; Sat, 14 Nov 2026 08:50:07 -0500
X-MC-Unique: ytThrDkoNyWU1cnho-d_yA-1
X-Mimecast-MFC-AGG-ID: ytThrDkoNyWU1cnho-d_yA_1794664207
Received: by mail-qv1-f69.google.com with SMTP id 6a1803df08f44-91eb0610cb9so23770826d6.3
        for <linux-nfs@vger.kernel.org>; Sat, 14 Nov 2026 05:50:07 -0800 (PST)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=redhat.com; s=google; t=1794664207; x=1795269007; darn=vger.kernel.org;
        h=content-transfer-encoding:content-type:in-reply-to:from
         :content-language:references:cc:to:subject:user-agent:mime-version
         :date:message-id:from:to:cc:subject:date:message-id:reply-to
         :content-type;
        bh=4YzoJGegLfItOLY+IVEzekWm9Pz06JwsipBm6nVoJOo=;
        b=saE/Di6Tn+bHtpVzacKTqnvwBIct3x9Jm/k3e+hI+IKBtAtwFWudiJadyEnSxqSVH5
         W//GHpvVyA/B+C5gRztudPLJFm6oQ7gQ5Rcy+fk3wEi0xjB/lqubajyqDRkZitC4Uo7d
         KUOLqQvxCXMWcaPW/G+8JMwffCLSgwvjMEFigq11iohf5hi21OiG5RQbqTAq4iyZXm7y
         7i4A2ip713mmWHmXUnsjTqJHDbdtug8CURowqoKAqKgFlSIlo9ba/kA/aQ66pshefJVy
         HuWLr5lXA5B2UZdGzTUZlaRptMKDplpmJjjPVeOWxq2Ue9Be0luEhIGdISkfhu3X7DPQ
         t46A==
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20260707; t=1794664207; x=1795269007;
        h=content-transfer-encoding:content-type:in-reply-to:from
         :content-language:references:cc:to:subject:user-agent:mime-version
         :date:message-id:x-gm-gg:x-gm-message-state:from:to:cc:subject:date
         :message-id:reply-to:content-type;
        bh=4YzoJGegLfItOLY+IVEzekWm9Pz06JwsipBm6nVoJOo=;
        b=tLliVyUTBtEuZ7qfz6bwDitYD7ljP6BiMGbuRmCdSQncR+zpcGX4vOjnfpwE+8y0dz
         QkR31v91+klTvo+BY8Dn06hikHb3dSRAUndfTabZ+aBMsS78FX79bQv+jJ8pIELeDIKV
         4y/47zbGHEu7pTCzJ6F2ZCN10UXbG7Tyu3za63zOYLaVwbCWvjE+N9ig9VDm0M7h9osb
         p6CZTlJf7El+l6D3oXeqQgwzdO1wxO8co5dvDWVXlrCQgZ/HDFHZ61lFU2vXu8TG9Aij
         mz0oI5K3WVH+ZKm9bw9SEt2GZ/Fl9xwjNqV4aES6ZuOLs3sbP7nIAkyv1PInR5wiUev6
         WRjw==
X-Gm-Message-State: APuU4Z9kk3+OgFUlDhu7we45pQZrInzfau34iLzySoQ4Cn3Yc4XK3UKN
	qnpw5wzj8s68kAk4wfK5jkz0N2j1E4hY7kJPsjH55Q3wMBKJYn1c4j564wndaEoYVsNjMQtET9o
	/HywA+IDpEL32mO1q3p4o0BVbS1MjTaQbPbX5uE1J09p0yEVr45rrXzqG6z59rDd0QBprZQ==
X-Gm-Gg: AYBFou2ws48alkvwMIqgb2C28sshJeBaDnZgzi9YjQhwoGUdWtWWrx16RYXxzor4pRN
	kaUoBBOxTsSv2QlgBChhG/8yqdCjmjJ0QKMMtR4WLE5tNhXnFz88EsAQ+5Od3i4aMDB90p7qA3f
	9QNtAx6FyleGuGyLDS/7cdyDyjWRax0SP7GFtn3qDRTJUK8LyI/1VxOPU23ew9GxXRkiQ8yVOtu
	VYJsHZBtFJqDbRTvIy9jU9u37leMNM5aWv/1UUkUCuLd90zkq2U7CWGR1JexsYmo+uDLCRoF5Xg
	nn1B2bQsJ1Dy/L1lufG6J20cmA/a7jn0kK1P2c9f+6PCScUQzCZrGpJi0L28VWAjnIkYabS3HcG
	rtWgE/HkL9VAa5IZM5A1DkK5wwmIyZFgqok7kwgbEszlzAANG
X-Received: by 2002:a05:620a:688b:b0:93a:2221:5460 with SMTP id af79cd13be357-9494bbe7d6bmr847362985a.40.1794664207060;
        Sat, 14 Nov 2026 05:50:07 -0800 (PST)
X-Received: by 2002:a05:620a:688b:b0:93a:2221:5460 with SMTP id af79cd13be357-9494bbe7d6bmr847360785a.40.1794664206587;
        Sat, 14 Nov 2026 05:50:06 -0800 (PST)
Received: from [172.31.1.12] ([70.105.240.105])
        by smtp.gmail.com with ESMTPSA id af79cd13be357-9494c831b7dsm411291485a.20.2026.11.14.05.50.05
        (version=TLS1_3 cipher=TLS_AES_128_GCM_SHA256 bits=128/128);
        Sat, 14 Nov 2026 05:50:05 -0800 (PST)
Message-ID: <eb2ae2a0-6b8f-4482-97bd-f84942692feb@redhat.com>
Date: Sat, 14 Nov 2026 08:50:04 -0500
X-Mailing-List: linux-nfs@vger.kernel.org
List-Id: <linux-nfs.vger.kernel.org>
List-Post: <mailto:linux-nfs@vger.kernel.org>
List-Help: <mailto:linux-nfs+help@vger.kernel.org>
List-Subscribe: <mailto:linux-nfs+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:linux-nfs+unsubscribe@vger.kernel.org>
List-Owner: <mailto:linux-nfs+owner@vger.kernel.org>
Precedence: list
MIME-Version: 1.0
User-Agent: Mozilla Thunderbird
Subject: Re: [nfs-utils PATCH 0/2] sm-notify: fix IPv4/IPv6 host notification
To: Scott Mayhew <smayhew@redhat.com>
Cc: linux-nfs@vger.kernel.org
References: <20261021224004.2273010-1-smayhew@redhat.com>
Content-Language: en-US
From: Steve Dickson <steved@redhat.com>
In-Reply-To: <20261021224004.2273010-1-smayhew@redhat.com>
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 7bit



On 10/21/26 6:40 PM, Scott Mayhew wrote:
> This series fixes sm-notify failing to notify peers in mixed IPv4/IPv6
> setups.
> 
> Patch 1 fixes the address-list rotation in notify_host(), which orphaned
> addresses and sent the first packet to the wrong address, so a host with
> multiple addresses could never be reached.
> 
> Patch 2 reworks sm-notify to use a separate socket per address family
> instead of a single IPv6 socket relying on IPv4-mapped addresses.  This
> removes the dependence on IPv4-mapped IPv6 addresses and lets a specific
> source address (-v / outgoing-addr) notify peers of both families.
> 
> Scott Mayhew (2):
>    sm-notify: fix multihomed address rotation and first-attempt address
>      choice
>    sm-notify: use a separate socket per address family
> 
>   utils/statd/sm-notify.c | 255 ++++++++++++++++++++++++++--------------
>   1 file changed, 164 insertions(+), 91 deletions(-)
> 
committed... (tag: nfs-utils-3-1-2.rc3

steved

