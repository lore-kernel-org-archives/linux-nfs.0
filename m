Authentication-Results: smtp.subspace.kernel.org; arc=pass header.oldest-pass=0 smtp.remote-ip=209.85.222.41
ARC-Seal: i=2; d=subspace.kernel.org; s=arc20261015; a=rsa-sha256; cv=pass;
	t=1794328699;
	b=VIilfwlbnz4gwvkHQlS2xCfw7mnvCYUhVPEtEVyTt6rmaj6bzV/oVpOK1CakazVwqSTh
	 U29fPlxB0N0QYjQTeAKX7DPfyJYH0jgBw+BQU2/uJEEIWx1hfDlRcKnhoWmey+1SDaXqe
	 emJr8CM6h8cuFeqG3GtIlAYeuzffWDfZ3j2UWbCfeOeIUC2uXancpTVAKWEu7RuuVVlUE
	 hiybykrTFZzApd3etVpEJbHcxqhfr8T0SiLgHoGwly+xdsMTBkBYQQHFBcZdfksjjZucs
	 t+mVjF1dGMtwpeiLiwM5nd2+Ve+z4UAp6l41qeGKrdW7ibhLllX2yFH9WuZSQr6lJzw==
ARC-Message-Signature: i=2; d=subspace.kernel.org; s=arc20261015;
	a=rsa-sha256; c=relaxed/relaxed; t=1794328699;
	h=DMARC-Filter:Received:DKIM-Signature:X-Google-DKIM-Signature:
	 X-Gm-Message-State:X-Gm-Gg:X-Received:Received:MIME-Version:From:Date:
	 X-Gm-Features:Message-ID:Subject:To:Content-Type;
	bh=Md3qjZ3OlFers8a6hkWOTRNriKeii47YydFvk5jk7Uw=;
	b=dQ1EwXnXhN2a9GfYoWYCtrycv9zL2BfN875JWlpRV7jIY/Ha3U5PfD7KJDx4e/46EjHe
	 FiuJ7PH+Ve4BJxcwaaAcR0v1ut8FeNEmvOrctyBIuQyUXpKqJFeqz0yPvr87nANq9Wuu9
	 DsvPQwruPpDlfbxdqXtlkvT9/AoJ+Nvem4i43ozS5V1zrE+RksFdf1KRqok/i4dTnWdoh
	 t8OjNGAiT3Chk+wlnlpWnnddWZ+fMRYdmRXdW7Hvxqsxfr3WpuX0ElAEZ/F9KP/HoIFlZ
	 cWH9MRyhlSqtnrfzXZQnWQIkMuepH2nP5m14rgdEblGow/R6NXxPcLbuKhCtkZLIziA==
ARC-Authentication-Results: i=2; smtp.subspace.kernel.org; 
	dmarc=pass header.from=spiritfinder.org;
	spf=pass smtp.mailfrom=spiritfinder.org;
	dkim=pass header.d=spiritfinder-org.20260707.gappssmtp.com header.i=@spiritfinder-org.20260707.gappssmtp.com header.a=rsa-sha256 header.s=20260707 header.b=r29lfv2X;
	arc=pass header.oldest-pass=0 smtp.remote-ip=209.85.222.41
Received: from mail-ua1-f41.google.com (mail-ua1-f41.google.com [209.85.222.41])
	(using TLSv1.3 with cipher TLS_AES_128_GCM_SHA256 (128/128 bits)
	 key-exchange X25519 server-signature ECDSA (prime256v1) server-digest SHA256)
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id D7092606A20A
	for <linux-nfs@vger.kernel.org>; Tue, 10 Nov 2026 16:38:18 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.4.2 smtp.subspace.kernel.org D7092606A20A
Authentication-Results: smtp.subspace.kernel.org; dmarc=pass (p=none dis=none) header.from=spiritfinder.org
Authentication-Results: smtp.subspace.kernel.org; spf=pass smtp.mailfrom=spiritfinder.org
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key, unprotected) header.d=spiritfinder-org.20260707.gappssmtp.com header.i=@spiritfinder-org.20260707.gappssmtp.com header.a=rsa-sha256 header.s=20260707 header.b=r29lfv2X
Received: by mail-ua1-f41.google.com with SMTP id a1e0cc1a2514c-990703f817fso1000022241.1
        for <linux-nfs@vger.kernel.org>; Tue, 10 Nov 2026 08:38:18 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1794328698; cv=none;
        d=google.com; s=arc-20260327;
        b=IJeW/BU+Jkh312/yh3BCDLmyEsyJG+OZ7Mtpl0wISSY8Kgt8sJhOL2a4ZIW5ImxlY0
         gJLNcVFSnMRXOi5a/rzxuj1ylrVDkWOVb+Vf61aNxkwOpNqD9h12wF8qhSYjWGMIRMNF
         aslzcCnapCXbDyp95wIp5aIuhsNLyphGgXd1IZZKcI7rL0iRzJqqmR/KW2IQ/kB+kGpv
         ESQePjjuuMUfOi17gkU7vh84+rAdBR1/HM55Zchz3o28u5zQHydHUyf1DR0uA1gLKdVc
         Z39HaPIxMsiSUT455OBB5W4AIP/XLS073THDNDfZfb8XCFR7eH70cwVWgdjFLN2iZIku
         KGjA==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20260327;
        h=to:subject:message-id:date:from:mime-version:dkim-signature;
        bh=Md3qjZ3OlFers8a6hkWOTRNriKeii47YydFvk5jk7Uw=;
        fh=Mys3y4MwsHRytUQMpdfGBn3oGRYLcLloxNwkFYMYMmg=;
        b=i4az6fnHrsI95AdFZCFJpz/QOKSo5Y2cuCkfjVdPvdRu48cH0eUCYkvqYgyBJUW6Dh
         luBQvFuAAgIOgptEz07XZaKPLS+aHZXrSM/DHsGGaHdSt3QlXeHrLnv/a46zfgNf4QBU
         A6Idcfs6YnzMzTTn2zDH1Cl8WRz8YNOkbiHAV4NE6S+PRtAvMwsteehju48fhh53tua4
         bav8SNfs9rM3PcDUOtkviM36U7s1Mj4MS0iqaD3Tfp+vajWDKHv8BK65OKupo43+SGLp
         xjPQj2Nn0IrSQbHMr8A4K4yS8MpEHm3zRgIaSjMVYTvx7+1NY/Iq2NVa7e0ggRP6teft
         mnag==;
        darn=vger.kernel.org
ARC-Authentication-Results: i=1; mx.google.com; arc=none
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=spiritfinder-org.20260707.gappssmtp.com; s=20260707; t=1794328698; x=1794933498; darn=vger.kernel.org;
        h=content-type:to:subject:message-id:date:from:mime-version:from:to
         :cc:subject:date:message-id:reply-to:content-type;
        bh=Md3qjZ3OlFers8a6hkWOTRNriKeii47YydFvk5jk7Uw=;
        b=r29lfv2X/Xlvx1F4WFs4SJao+OMTv6hQ7KT3OnLr+UK7U+d/oeSYD67DYs4Z7rwTfl
         68eF+NSRY1/ePgFX2mU8a6XYAtlPny3A/goG13eGgq6YE72jQs4BSiR5YWrq40GjK1xI
         rWfXK8Wv2V0m/gzY8GRphvv+YYIypLfd+Acx/PPXWT96dwzO3F9/njIjRnmcL/ckBcSH
         RkL5OyqSf3aHz+vlrqE3jG6ilq9qFxAgnXXtWIe3lFJOOE80wkT7aUsvW2vpZP3vhUVo
         Qo5zV/sJXyV3kgU5BvvHKGL9bbks9hBsLOhBb3oRQYSqpNzcvBWkNCHB9dyzVPe+yt7a
         1TRg==
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20260707; t=1794328698; x=1794933498;
        h=content-type:to:subject:message-id:date:from:mime-version:x-gm-gg
         :x-gm-message-state:from:to:cc:subject:date:message-id:reply-to
         :content-type;
        bh=Md3qjZ3OlFers8a6hkWOTRNriKeii47YydFvk5jk7Uw=;
        b=v1MBpnq+/KAvvylASWyJSFtudqHo35uDWQyaVzSeRbu9uXRo4aqPIwQNB5V7ox9CXt
         ediJvJBZWFah4n+bonSItg5Wabw2sfjyLg7FA1GkLEWOPVUtWhypL810hI7FMcBLV6op
         TnVGIffGJgrCQfEmYbhsqfFNlsPk8t5CY9eIMvqP2wA0sATm/KUMisuYPdrZpgsbetmL
         f3ql3jHnfQptxA3/PQdxWH1govVBdBQ8swhnyOqYqS0GxkRxGc7LjnBvoMxqKXTf5ien
         594qZkfFH5bu5diGntS8k8sEXZq7vex78oBjnM+lxZihXDfU5gHb/tt27dUrhtyXFzpy
         3rYQ==
X-Gm-Message-State: APuU4Z+At2sVYUkOG5WrLL32Iik4fVY/Ku8boa5IVZ6uY8pR4866FJUk
	32J1FiVLEA/zFDx6P6XmuOWQ4cHcRRPp/SA9dgzAaD2KI4E8q1K2DvZfywTpXPFGsnSbRubY9pA
	leAhwxOgjjdZ6KNMec/z2l7dcimeflk5yxbA883TBjugSFfycxFXE
X-Gm-Gg: AYBFou0fydKvwPkJSUuJJrbH+bdCs9yhH9Jo5fKPwxtANT4482WBDDG1lhzaPYY1L2z
	XHEnAz1U7mWw5c2fdnCl2/jdnIlqeqLjhi/Prg2yzzuDRrU9VJAC2Ljhh2VaDExPx7U9j7rij7N
	V7t7LAiGShNJirYAaTYv/LBxEQUbOsEUa5afjjpp4bGROBBgVLVGf+7kaHTQ4vyfyUzfhUxOK14
	XeIYKBuCA1k3jZw2uQldwTJgB4CxcbyWNKvO/5camY9wCL501CfSS4J9o2C3GGgelTSbSq/MLlk
	Ez8GHm65TSJ9Ks29ffGvIeskQRXhu70pCMg6sqxDvtfD+XHiamOVDk8V8exbkYc+rG9fHWeuzdl
	D0DGOiufcgRDEeJ2PrjxiwHNSl+OiwnYxGZpl1i56w6LGvjvwqBV2LH6av/02JPO43QM=
X-Received: by 2002:a05:6102:162c:b0:7cc:1274:aba3 with SMTP id
 ada2fe7eead31-7d301bcac0emr1304096137.22.1794328697662; Tue, 10 Nov 2026
 08:38:17 -0800 (PST)
Received: from 559722579009 named unknown by gmailapi.google.com with
 HTTPREST; Tue, 10 Nov 2026 08:38:16 -0800
X-Mailing-List: linux-nfs@vger.kernel.org
List-Id: <linux-nfs.vger.kernel.org>
List-Post: <mailto:linux-nfs@vger.kernel.org>
List-Help: <mailto:linux-nfs+help@vger.kernel.org>
List-Subscribe: <mailto:linux-nfs+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:linux-nfs+unsubscribe@vger.kernel.org>
List-Owner: <mailto:linux-nfs+owner@vger.kernel.org>
Precedence: list
MIME-Version: 1.0
From: Jennifer Scott <info@spiritfinder.org>
Date: Tue, 10 Nov 2026 08:38:16 -0800
X-Gm-Features: AclHuK_z-yeFtKLkP1bT4ZNNcbqcFZqFFt-0t-4bR66hKTIO1ZAOwoCkY4jpmM0
Message-ID: <CAGB68TUEg8aOeY5cGCMnyj4A9UJDs+mNCH6rkSMc20-gweYM1g@mail.gmail.com>
Subject: Building Healthy Habits Together
To: linux-nfs@vger.kernel.org
Content-Type: text/plain; charset="UTF-8"

Hi,

I just wanted to follow up and see if you had a moment to consider my
proposal about sharing insights on breaking unhealthy habits. I
believe the topic could provide valuable perspectives for your
audience.

If you already responded, thanks for that and sorry for the repeat.

Take care,
Jennifer
