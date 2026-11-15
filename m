Authentication-Results: smtp.subspace.kernel.org; arc=pass header.oldest-pass=0 smtp.remote-ip=209.85.208.178
ARC-Seal: i=2; d=subspace.kernel.org; s=arc20261015; a=rsa-sha256; cv=pass;
	t=1794713502;
	b=ew+baFi0KvmKtKxH6xRWunS7nzXsZ8rvBDau/TtepRVz9jGQ+lEEDt5XYOIEKx8INh5n
	 VjzJv6YFrp6K7DS25y54cuS+xaAygSAbTv6jldr2O4cfs+0rJly8qhxxflb2KWshuyUvI
	 liCbTr4mqYGGb+tHWRUn+kTatlaD1v37enbwzNs1YO4eqy3Bms/0ANFIlSkTIgmPv1IbG
	 w9S70Ih9OQV+Stwtbvcq7K4ekVgsITM9zlWpBSpwWviY+NM4gG2jfIh9TwnY/OR50vIt1
	 DnABqSpLdNcHGDyEI+21U+tBsJPxz0x2tgQ9CB+5ElArGMfsrTO4vocpphx+9ZFyDBQ==
ARC-Message-Signature: i=2; d=subspace.kernel.org; s=arc20261015;
	a=rsa-sha256; c=relaxed/relaxed; t=1794713502;
	h=DMARC-Filter:Received:DKIM-Signature:X-Google-DKIM-Signature:
	 X-Gm-Message-State:X-Gm-Gg:X-Received:Received:Received:From:
	 MIME-Version:In-Reply-To:References:Date:X-Gm-Features:Message-ID:
	 Subject:To:Cc:Content-Type;
	bh=uarHK68V0NNroUzfV9sRD5Cd9jbZaAZM/rBGq6qMIQA=;
	b=0Gt3PKsCmdCIlukWRKQBT5eONUjg1u8+KJjGXDue9EX7l48/HK3aci78IKZ/nNj2zGae
	 fWGg1j9M1bTJiWNvmcFr9bEL0I9WlyM/5Auvcu4yi2/qjj9ppDxc43anKUJmMUk3JVowh
	 uQjfmaGZZ6KghO2bJBaSOYI+xAqbD/zgy9kbgkevbcuh+geEKHwL31Q1EEZ1/us3FIowb
	 Fvn192PXktJ+Efs6SqnBlLn/h7SKk0A/dSmf7WJ+uoUeSSXbpjzuf6iEzEc6usNfKj/d0
	 PrZvz5rkcd/90aTUeJ7utJN2MKB3xENjRICqgvICldkTbcwsi8kKeeKrrUC1Ygl1tqQ==
ARC-Authentication-Results: i=2; smtp.subspace.kernel.org; 
	dmarc=pass header.from=gmail.com;
	spf=pass smtp.mailfrom=gmail.com;
	dkim=pass header.d=gmail.com header.i=@gmail.com header.a=rsa-sha256 header.s=20260707 header.b=iHQw5QuN;
	arc=pass header.oldest-pass=0 smtp.remote-ip=209.85.208.178
Received: from mail-lj1-f178.google.com (mail-lj1-f178.google.com [209.85.208.178])
	(using TLSv1.3 with cipher TLS_AES_128_GCM_SHA256 (128/128 bits)
	 key-exchange X25519 server-signature ECDSA (prime256v1) server-digest SHA256)
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 95E2C606A327
	for <linux-nfs@vger.kernel.org>; Sun, 15 Nov 2026 03:31:41 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.4.2 smtp.subspace.kernel.org 95E2C606A327
Authentication-Results: smtp.subspace.kernel.org; dmarc=pass (p=none dis=none) header.from=gmail.com
Authentication-Results: smtp.subspace.kernel.org; spf=pass smtp.mailfrom=gmail.com
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=gmail.com header.i=@gmail.com header.a=rsa-sha256 header.s=20260707 header.b=iHQw5QuN
Received: by mail-lj1-f178.google.com with SMTP id 38308e7fff4ca-3adef2bf7acso3356731fa.1
        for <linux-nfs@vger.kernel.org>; Sat, 14 Nov 2026 19:31:41 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1794713500; cv=none;
        d=google.com; s=arc-20260327;
        b=hWwOAU8LCVgwntzjTp5VUdMqTJWx5fBFlnHnqs2q4bOLTx3MoareaYWuMXL9FPeXfn
         8A6X8hfbwKWYjBkzRYPFvypivwikBy5p5WAwTPZ8Q/rnoitN0ZnIeQLZhdF98Zt0iiqD
         DW8RBNRwk02kcaBo2xY1eayGjMj6Mao/a+Lx0zN3pNNXcVzf3a65HO5dnF+tpI1IN6pT
         qdXOWHOpCQZo4a9hcVuqwhhAqZuzWgByv+E/DaIaSJOa0j5WDRZBjhSrY1X0dVBU/UPt
         vrWWJWDzkMMBiRApHzpjnSoddahb9ZbAgWUbpRMwIPfVWJlBSU8KZEsjkK8N63PZEhhz
         meYw==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20260327;
        h=cc:to:subject:message-id:date:references:in-reply-to:mime-version
         :from:dkim-signature;
        bh=uarHK68V0NNroUzfV9sRD5Cd9jbZaAZM/rBGq6qMIQA=;
        fh=ymfhShoCUKxLn7czh2H3/oZetPTS67X53Vhfwc0U5jI=;
        b=SERrHKrkXX65HVhyclRLIoizELj1x8gsp7Yu3z/73DX1/7W1WIsYEf1weSVKkh69p1
         FhI0uc40GinOQJw0nMTySnwTjgk/VH9kXkhSpejGxo14nAUtVACt+1d8kLAf0DqnpU2Y
         LibdPGBDGVIDRms4KT1Re1jphO8pxHkdRXa1fTTFERlwu2sV9df6gSA1oP0mYryO6o4Z
         X2s88Jdbgqd1GFLDkzdxQhzF3YjGoihPkG+ek3WE6ypMCkUKUS80Qn4tbLM5hzTlpyk7
         VBGEPuiMRco5Nf/Conx//rTSn6ZPY12itZ4hadQn63W0mn5smN2wLeySRoXYSIvazSXd
         g2gA==;
        darn=vger.kernel.org
ARC-Authentication-Results: i=1; mx.google.com; arc=none
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=gmail.com; s=20260707; t=1794713500; x=1795318300; darn=vger.kernel.org;
        h=content-type:cc:to:subject:message-id:date:references:in-reply-to
         :mime-version:from:from:to:cc:subject:date:message-id:reply-to
         :content-type;
        bh=uarHK68V0NNroUzfV9sRD5Cd9jbZaAZM/rBGq6qMIQA=;
        b=iHQw5QuNcqWP7kXnaqRRrGHX1I1bcbY+vQyndXLqfl2X3VMVcVydHosMOH89Pgmy16
         PkIgdkQoegfNGE/lykt66IUCYnkn81I2XJv/siFAxlH8hgimRudxBWlelz3tLIPfdSWb
         llSuD1jD1WZJ8R2lGPGwFLl9UUA7JSbVFfhpvsR1Bj5g/TQuB3C2sKrRXeFWIr4s0BhP
         /M0sPZbvDdpwQx+qaNIcl35VcAatSjngYnJf7NlrCoOK4h0hi3PYIt2JZvv/ceJuWug5
         Y3IjZDsVTRBQjshmK/3c3bJFi7YVWlNk8xZYtRcMLvFa6Ss/GFch39PVLaGgxa9KTkD1
         jGvA==
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20260707; t=1794713500; x=1795318300;
        h=content-type:cc:to:subject:message-id:date:references:in-reply-to
         :mime-version:from:x-gm-gg:x-gm-message-state:from:to:cc:subject
         :date:message-id:reply-to:content-type;
        bh=uarHK68V0NNroUzfV9sRD5Cd9jbZaAZM/rBGq6qMIQA=;
        b=WK3Iv/dGMD2xISJYwooCR+2BFfZHTNopT+FIBEEC5EPppsCd+3sLs/6zgtTsxCHEAf
         y8kg0vAYeDuLjvk00YsMvsxa10rfABWk2VrKWCjT7F71N4z3z9tQIdmL1pitFkE/NgQn
         JSc9cESd2sgJgzJjxxhFw1wqX6ib/7tno0clG8S6eD6UJR4D0XUYBIDZ/41C3JWS+b2C
         JKVqITinlgk235WyKTKCR+m+BrLx0lHBdcTGbCvqqo72mB3zASPN2ewOzPwIHgnI65FB
         gfndrkHHRNGQpP2soGnK5YA3zKKH/EcLfXDYKYht6s72pSAYi/ZCZwk8XX9iHpTzqqro
         WHcQ==
X-Gm-Message-State: APuU4Z+53tCuhMOp3ZQsVakQqh6Uf5snlSs3kOJP/7PqeiP/EAmFA9ji
	t078xMaISPUwcnEk2kY2Gjyx0aYrjrpM/L9ztc6Tjgv0i10ogUWkGRMT/V3otP/tIofUnJtvhmX
	ZqAN4m0ajrEPtVAoFLUv78kH8E7Ngg+Y=
X-Gm-Gg: AYBFou1q3XZPUK0D4GWtD2CdgTQnBmEaRo2eSsTYoXWUPusXF9iKc6Gwlm+vajaS7iN
	AgAicUSSVcdLBy9MooX8Bw9fUuc6nNwxN+/fD4bL4W8Ubdy3fl2dys2IX6l6S9BUPu1lIqNl/9x
	hj1rhFs8vek/o6WxrrJ2NtFR7gh55tEUDvrBwrL5XCXWWBCPiGKpZ+iNf/1fScSawXIy0mXNUP/
	pYAHpJIJO3I0orx4ukcuh/FKHoMwOIt33mC3KrrRXRQEFVeZv35SPOftTvfW+dyyOL3Jx79qEF0
	gujKFBUq3H7ESFErbEDbw4huokKZwOmnmKwBKWv5UX/yp3ofup6Jbd2q22VKMP/M3fdAENdvBje
	s1kIgAnHHgnAL71o1LfsmRgISptoMdSfVyH7u2KpFP5PQLJTbxiSLZ8gYGg==
X-Received: by 2002:a05:6512:1393:b0:5c1:57d2:c1d7 with SMTP id
 2adb3069b0e04-5c170b874famr2746085e87.5.1794713499536; Sat, 14 Nov 2026
 19:31:39 -0800 (PST)
Received: from 779715102257 named unknown by gmailapi.google.com with
 HTTPREST; Sat, 14 Nov 2026 19:31:39 -0800
Received: from 779715102257 named unknown by gmailapi.google.com with
 HTTPREST; Sat, 14 Nov 2026 19:30:40 -0800
From: =?UTF-8?B?7YyM656R7IOI?= <lhjnano@gmail.com>
X-Mailing-List: linux-nfs@vger.kernel.org
List-Id: <linux-nfs.vger.kernel.org>
List-Post: <mailto:linux-nfs@vger.kernel.org>
List-Help: <mailto:linux-nfs+help@vger.kernel.org>
List-Subscribe: <mailto:linux-nfs+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:linux-nfs+unsubscribe@vger.kernel.org>
List-Owner: <mailto:linux-nfs+owner@vger.kernel.org>
Precedence: list
MIME-Version: 1.0
In-Reply-To: <CAN+dWLYt7=WDO-wGHt5_1K2JcqDgrHs1bX2WBOvaTt-PFi1meg@mail.gmail.com>
References: <CAN+dWLYt7=WDO-wGHt5_1K2JcqDgrHs1bX2WBOvaTt-PFi1meg@mail.gmail.com>
Date: Sat, 14 Nov 2026 19:31:39 -0800
X-Gm-Features: AclHuK-E06dBZ8QAgphPjw5_iDMBzemXM43I8b_FVi4xx2f01SXlkjlw5KWNgQA
Message-ID: <CAN+dWLYfneZ_sovRz0wzQr3ckA2VVJKNbcKYwRhJFHvPo8dMXQ@mail.gmail.com>
Subject: Re: [PATCH nfs-utils] nfsdcld: signal readiness only after the pipefs
 watch is installed
To: SteveD@redhat.com
Cc: linux-nfs@vger.kernel.org, cel@kernel.org
Content-Type: text/plain; charset="UTF-8"

Hi Steve,

Friendly ping on this patch when you have a moment.
Please let me know if any changes or additional details are needed.

Thanks,
HeonJe
