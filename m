Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.remote-ip=209.85.160.42
ARC-Seal: i=1; d=subspace.kernel.org; s=arc20261015; a=rsa-sha256; cv=none;
	t=1793058262;
	b=R7HFiUYIaM2O4z49b+NxGFZfi0ZmmcUlA07gY9qZB8ednaW3lCO7/31qw68lGeGEJGDe
	 NtlHjU13ZGCVC5lyVXbOlRWKeNAY+gKH8p5+LV5GYxkEv55lXDQe95nJn1DRTSpw0YwNm
	 U5RqsZ1pDlhdenha/brDl3SjkSWsw5tsaI8P9fUZ4wtOsKObOCCV/PlDW+r7ZmCmyA4lW
	 2npANe8ctOyHb3T1Sb+84wfouteGxAgLHoFGiEPbTiP4aTFa8sRLoqK1QrUa4WRDskLJN
	 ESD7MTSu6Gh6hTJFQwp9jS+QirJavTItNqzQULp8obGbyoAQZfVymV5dsLvcjgQvQkw==
ARC-Message-Signature: i=1; d=subspace.kernel.org; s=arc20261015;
	a=rsa-sha256; c=relaxed/relaxed; t=1793058262;
	h=DMARC-Filter:Received:DKIM-Signature:X-Google-DKIM-Signature:
	 X-Gm-Message-State:X-Gm-Gg:X-Received:Received:From:
	 X-Google-Original-From:To:Cc:Subject:Date:X-Mailer:Message-ID:
	 In-Reply-To:References:MIME-Version:Content-Type:
	 Content-Transfer-Encoding;
	bh=IYtPiKQaOepWd6dhkXMRUBUfHAWsPVK7jupgm9kyE58=;
	b=AuJpEArbkueoZiAfuw8916z4GLDU2o5vPwtAGCYbluIyDpPc040V0I9GiDtfr+VLbjmw
	 /ko3qDaserqH5/lpD8zeDosjLSlLmq+FaCLNX4WSkDelaMIVx7h1l+Au1TPxR5xKV90yG
	 mj9rBUlyPiSARwH+Jovl84/Qjc6CuxxF7cPnryiZxxHiZvw4S7b9a2ZwNttKXIyOmylNY
	 +yrA4LzVR6PAdPKDR2Q5LT214qjWORBIIqk11emXBU+2dQKhRRMSpHhPIIflbhlJpEuG8
	 1XiJsjwGuM6JEVs38mdhvvyxIfdHCDpm/aULN2SNvL+TFLNFZ7Ud+TNVUi6lFTEjLmw==
ARC-Authentication-Results: i=1; smtp.subspace.kernel.org; 
	dmarc=pass header.from=hammerspace.com;
	spf=pass smtp.mailfrom=hammerspace.com;
	dkim=pass header.d=hammerspace.com header.i=@hammerspace.com header.a=rsa-sha256 header.s=google header.b=NgRCOMjK;
	arc=none smtp.remote-ip=209.85.160.42
Received: from mail-oa1-f42.google.com (mail-oa1-f42.google.com [209.85.160.42])
	(using TLSv1.3 with cipher TLS_AES_128_GCM_SHA256 (128/128 bits)
	 key-exchange X25519 server-signature ECDSA (prime256v1) server-digest SHA256)
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 1AA52606A31A
	for <linux-nfs@vger.kernel.org>; Mon, 26 Oct 2026 23:44:21 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.4.2 smtp.subspace.kernel.org 1AA52606A31A
Authentication-Results: smtp.subspace.kernel.org; dmarc=pass (p=quarantine dis=none) header.from=hammerspace.com
Authentication-Results: smtp.subspace.kernel.org; spf=pass smtp.mailfrom=hammerspace.com
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key, unprotected) header.d=hammerspace.com header.i=@hammerspace.com header.a=rsa-sha256 header.s=google header.b=NgRCOMjK
Received: by mail-oa1-f42.google.com with SMTP id 586e51a60fabf-4a85c656c58so1248754fac.3
        for <linux-nfs@vger.kernel.org>; Mon, 26 Oct 2026 16:44:21 -0700 (PDT)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=hammerspace.com; s=google; t=1793058261; x=1793663061; darn=vger.kernel.org;
        h=content-transfer-encoding:content-type:mime-version:references
         :in-reply-to:message-id:date:subject:cc:to:from:from:to:cc:subject
         :date:message-id:reply-to:content-type;
        bh=IYtPiKQaOepWd6dhkXMRUBUfHAWsPVK7jupgm9kyE58=;
        b=NgRCOMjKqZLQ1xcqLNkNjJMFSB0dQfJQySsC0B6iAl74VmMwkk0pKB0/LsCc90b1Pc
         TvaP27cXASQlfENkoPzi38mDwubjSTMZquvNrBzKINzRpq3e+3wAkPGOEk+WjUUwbGe7
         rKnMdu83Y8XbMp88hSw6JlrnUNELXVVRuZgSCb5hZSAO7bwv0i4HI26liO2CtlmqYgfZ
         8UX8KzANHbxjFvsJ0C+yBwgyOoJkXh+1lh3O9k+iUNvOktuxir3wFGNmyuNrlUlzHjHo
         O87+vgVBnxR3sjfwAqUBYL7mfHfanH00iFSCppGQud0JQSQ2uKoh/b05bmufPhi5IOeF
         JG2Q==
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20260707; t=1793058261; x=1793663061;
        h=content-transfer-encoding:content-type:mime-version:references
         :in-reply-to:message-id:date:subject:cc:to:from:x-gm-gg
         :x-gm-message-state:from:to:cc:subject:date:message-id:reply-to
         :content-type;
        bh=IYtPiKQaOepWd6dhkXMRUBUfHAWsPVK7jupgm9kyE58=;
        b=GE7EWgWRyDQuTz3lUJAPfIagtUQ+BnzzCwIMox3U+/A1MASkV9ClXyMAwSpeYOK9iM
         pGneqrluwsdw0G52L9/QIYhf3P0vXdHrakGRtsk5OA1UWSWaWFBaVtDK7MbnCisCR6qr
         eHfTtgu29qVsreSGVbfZVWUf+Dw8+KCeBzpGxSm6uR23FN8LwlklEuYm218C+cTZOUI6
         BDkPWRB5jCpZtxEEvnoHOBb5cAfag/0iObFKqhF/nRMEdGzAmxoV9hY+U35saaSMjnnI
         asu0P7tevS7QQkX873nrUdSso5EzSHCezdfdc0ywe7LWkmwUqDHI4JcvICeeTtOVAuR4
         D4FA==
X-Gm-Message-State: AFq9FYIirmNaYFlGFJkvkpX2oSls5UpogW47Mf5AZwr+YUClWyWeJRZP
	5D5XGdI7dTzso4sRR/ue0b3L7khnP6reI/f2CCip1kYBHu6n3bIXa8h6KCNzXA+e4L2ntyGMkn/
	2CQ1u
X-Gm-Gg: AYBFou1hy/gkOgUFoy1eDPAHpWASx00Gb4sPI6jRImVt3S7t7ZVSDBq4deAyMj9Nmvp
	JeWK+xSYpe0xTDRV+y0nwYqxjfCGow/ahsrMm57KAUUYwgeQZ3h9x8TKrE3zvAY/nz4PrLzONCy
	1V7diacbM9gdaP7V1KqqG7AOrX6DPRNBnysBjHN725UZrTSxp//JDwMhSZI3/BV0ipQYGnmEIhq
	WFMlJHNJBK+ySkONOrWmAyXIHqQyBDAy+JzS5OptpMAKpkiDqzcLrN5k/3gq0KPSMhDPiuvPUWo
	tvQQglaqPXLjvpi4kCjOZ8ICCvmxq/v2YQWjhroqxfMhfLNCsRkyWNsvSNHey2gXKlgl86N9OYx
	7DOKU8RlmsOLWNX3Vz/QlGGPNXiSPlg5x9HCesNslpwhdjABlzw5MiVbtU1favK+U5xy1eR3aB2
	JS8trvJcNc90YK5dIktHw1/jwHV59jg3x/94mon5ureLL+PQ943/occCORJiFCdp5oh7Po+fa7x
	lh/HDASXPWnP5H76cxNbE7W4BIMAxRnzsylXEUS6yZcVlwOEOZBkFN5WGrV6zKdlz3q/OJOu2yD
	FZw=
X-Received: by 2002:a05:6870:40c9:b0:4a6:9418:da4e with SMTP id 586e51a60fabf-4a83f6af848mr4812859fac.60.1793058260900;
        Mon, 26 Oct 2026 16:44:20 -0700 (PDT)
Received: from [192.168.254.51] ([12.117.181.174])
        by smtp.gmail.com with ESMTPSA id 586e51a60fabf-4a8431c012esm6022880fac.11.2026.10.26.16.44.19
        (version=TLS1_3 cipher=TLS_AES_256_GCM_SHA384 bits=256/256);
        Mon, 26 Oct 2026 16:44:20 -0700 (PDT)
From: Benjamin Coddington <ben.coddington@hammerspace.com>
X-Google-Original-From: Benjamin Coddington <bcodding@hammerspace.com>
To: Jorge Mora <jmora1300@gmail.com>
Cc: linux-nfs@vger.kernel.org, trondmy@kernel.org, anna@kernel.org,
 Rakesh.Bhargava@netapp.com, Mohit.Kumar@netapp.com, mora@netapp.com
Subject: Re: [PATCH] NFSv4/flexfiles: calculate stripe boundaries from the
 file offset
Date: Mon, 26 Oct 2026 16:44:18 -0700
X-Mailer: MailMate (2.0r6272)
Message-ID: <17C675FE-0C61-412B-ADA1-882013ACC7B7@hammerspace.com>
In-Reply-To: <20261024140811.51694-1-mora@netapp.com>
References: <20261024140811.51694-1-mora@netapp.com>
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

On 24 Oct 2026, at 7:08, Jorge Mora wrote:

> From: Rakesh Bhargava <Rakesh.Bhargava@netapp.com>

Hi Jorge, Rakesh — this is the same change as "NFSv4/flexfiles: Bound page
coalescing on the absolute stripe offset" (v4 06/24 of the flexfiles
device-notification series), which Anna has in her linux-next as
a84c62c4f037. Your base, 18a80121193c, is from Trond's tree and predates it.

Ben
