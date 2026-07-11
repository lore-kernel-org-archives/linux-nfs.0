Received: from us-smtp-delivery-124.mimecast.com (us-smtp-delivery-124.mimecast.com [170.10.129.124])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 4825F1D7E41
	for <linux-nfs@vger.kernel.org>; Sat, 11 Jul 2026 16:19:52 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=170.10.129.124
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1783786793; cv=none; b=IZGzaNYOrd/c1YbTwvJVho94YfxYVqx/ioHfVHYfaubb/MlNUEgjrgNByIvj1LJa4bbbsQwiPPcCGkpB1/VR9uX3eDwDTXD1rVRn4Q1Pmc9MpBwQIWBj30WzcB2pkfza7dN+FEI/yTg6de/qd9U7Pdw5fTSD67dVa32+Fru4JEY=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1783786793; c=relaxed/simple;
	bh=Rkw6xMTjGdbGvEim2+YACYhy6u3syPHu9rbwSiLGeyc=;
	h=Message-ID:Date:MIME-Version:Subject:To:References:From:
	 In-Reply-To:Content-Type; b=adwxQDQDQgoj3zyn0Zp5FNTr0rjzqUB2YGtVs4N5BzK/F+pdCpguZi5Za0heiEEGM2lQyNDNBMTg/JhXR5ImzzZps22AgULSgjUY8Ni3MICPi7cm9u3di8J1lQ+EUn0TSIbV377jodKFFNv6qSNOHp6lPNklMhty13ICOXdMEoM=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dmarc=pass (p=quarantine dis=none) header.from=redhat.com; spf=pass smtp.mailfrom=redhat.com; dkim=pass (1024-bit key) header.d=redhat.com header.i=@redhat.com header.b=cFyzgljT; dkim=pass (2048-bit key) header.d=redhat.com header.i=@redhat.com header.b=mrkr+/yT; arc=none smtp.client-ip=170.10.129.124
Authentication-Results: smtp.subspace.kernel.org; dmarc=pass (p=quarantine dis=none) header.from=redhat.com
Authentication-Results: smtp.subspace.kernel.org; spf=pass smtp.mailfrom=redhat.com
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (1024-bit key) header.d=redhat.com header.i=@redhat.com header.b="cFyzgljT";
	dkim=pass (2048-bit key) header.d=redhat.com header.i=@redhat.com header.b="mrkr+/yT"
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=redhat.com;
	s=mimecast20190719; t=1783786791;
	h=from:from:reply-to:subject:subject:date:date:message-id:message-id:
	 to:to:cc:mime-version:mime-version:content-type:content-type:
	 content-transfer-encoding:content-transfer-encoding:
	 in-reply-to:in-reply-to:references:references;
	bh=CIMPMt0oyv8s4zxnp8bmTRwkxjf84finyqETjiaymPw=;
	b=cFyzgljTZI2zabHTQQwMcL2rRyvkntWk772sN7Ngltp/vYNLIC/HkYilWaHagv6BiRmKVZ
	wZ48y+V/4HTWEqvTRiBR/BLJ74Ic5FkW23psg3NziYIrfCXNqDywMXlMJqCcXrBeiotOTF
	ZOsH5rEaSoSEbkp6CJoVuqWUTmqfMjo=
Received: from mail-qt1-f199.google.com (mail-qt1-f199.google.com
 [209.85.160.199]) by relay.mimecast.com with ESMTP with STARTTLS
 (version=TLSv1.3, cipher=TLS_AES_256_GCM_SHA384) id
 us-mta-497-Kvdk2IgxOm28R0yJ0IhWJQ-1; Sat, 11 Jul 2026 12:19:49 -0400
X-MC-Unique: Kvdk2IgxOm28R0yJ0IhWJQ-1
X-Mimecast-MFC-AGG-ID: Kvdk2IgxOm28R0yJ0IhWJQ_1783786789
Received: by mail-qt1-f199.google.com with SMTP id d75a77b69052e-51c2af04aeeso28500561cf.0
        for <linux-nfs@vger.kernel.org>; Sat, 11 Jul 2026 09:19:49 -0700 (PDT)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=redhat.com; s=google; t=1783786789; x=1784391589; darn=vger.kernel.org;
        h=content-transfer-encoding:content-type:in-reply-to:from
         :content-language:references:to:subject:user-agent:mime-version:date
         :message-id:from:to:cc:subject:date:message-id:reply-to:content-type;
        bh=CIMPMt0oyv8s4zxnp8bmTRwkxjf84finyqETjiaymPw=;
        b=mrkr+/yTxnfkrxKlWOjB4Qh6RJ6cPhMMGx4rPCFQkra3bbf0PG/Xk9lMTC1UqYY84A
         XglkRHd3x1+MAZFvhTSYcdOlwov1Zp/t3ZqfUIEl+vLtd2qgt5dZUOfJ375twQiVTSvx
         K77AYh8jZwI9sQSQjtXIM6LqYvixbq1/FQ15TVxuQlEf5ggup7GXS6EdCnRpOgobn9iy
         Gi6lUpXBazzjUWG4mAd379aUZ4RnF0IX/LC4vEQhHKfo/SgC7QDMp0XudJ+7dw1KucG+
         0PRfP5QQtAsBybjCAECkjP7/bLc7rcKgfEBT6VoL6j4FN6XRGyH5XTIrI9cAT3a0YoAg
         6rZQ==
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20251104; t=1783786789; x=1784391589;
        h=content-transfer-encoding:content-type:in-reply-to:from
         :content-language:references:to:subject:user-agent:mime-version:date
         :message-id:x-gm-gg:x-gm-message-state:from:to:cc:subject:date
         :message-id:reply-to:content-type;
        bh=CIMPMt0oyv8s4zxnp8bmTRwkxjf84finyqETjiaymPw=;
        b=YASWZpaFzgPrG4vFWjwxs5MxEXNmkPD3R9WV0jOIUkJCynaWR4cUduoV7ldrBDvzWA
         IVmq7uL9umRLToXAUQtiFPbuLt4gssPv1ENMW0TVuwIDVzezas+R4aWg/MTSqGgFzJcW
         nqZBD1Bg2omIG6Kq9iV8y+XxvpQQqSTAZxh2+IAyl42q3q+dyqBpBIIPWhlp3TJgRHNC
         aAq1dsc5Pc892ehPIH/2MCLUirt4+K87NzPaeyqfde6vFlYdWFubVbzXRPtxOXeJftIl
         4sBsipp+DgiLVjLBhOebQU2Ne/6YwM3hAbevpAQ0Cagsdr3ShAklBlUjdt5vuQpo8Fap
         fNEQ==
X-Forwarded-Encrypted: i=1; AHgh+Rpd3Bohr9OrZiQLyYtVnz+XGpTiZl7T0nL1zUf/wTU7AwTl9EcBgDZPKtE4LmKuLRS5tkDspUKB39A=@vger.kernel.org
X-Gm-Message-State: AOJu0Yw6CYTVLZ0dU/wHvR2sgwzRdfjt9NFchfONOaLirq/IzzyrHJCO
	/QFNSc8GfaGBMDh6l73uzrErZBk7uqfRr7v//eKRyZ8N5KmAVZgTV6zSoMTk4xmO09XYrW/1rjd
	Z61MhYbyOR0Hu/mN/pANngZpcsBpkF2I60XpFz869vIedBdBWfTaCggHPZIN5CA/yN4bAnA==
X-Gm-Gg: AfdE7cltbZWkd7cnaF5RgghRvoTgkU/s5kt6ruRkKeBSym4HJXRoXx7L9uro2Oy3ss7
	SA+nA0YwuzW+E48p9UgEwmXVSfCrwrfRjr9n/qKS2F99O1NTZxTVWsFfxjYo20GCLfOmR9JlmJl
	2sG37McVNiz9W6LS68LWO6YYlX+oRo+gEeUh3TTKeBlP/fJHzaQDWbrZ6G6ffhQlA0zednsWRIl
	nYjA7EeDy0Yj23GLCNNAoJYtKI/GkuaczCfn+IdCq4WODv3LwnqkSZPG0C3P8JbIuA0bffojvpx
	R6WsPYmLA+iLk7wZdXNGwJsYZC1aOblWQTzg6O07i4C/yg1zY7eo8So7z+D2q8G/VaNEYBm7BmO
	SzsDfIEkGm/Q=
X-Received: by 2002:ac8:57cd:0:b0:51c:f8f:13b with SMTP id d75a77b69052e-51caa1286ddmr83394561cf.23.1783786789007;
        Sat, 11 Jul 2026 09:19:49 -0700 (PDT)
X-Received: by 2002:ac8:57cd:0:b0:51c:f8f:13b with SMTP id d75a77b69052e-51caa1286ddmr83394381cf.23.1783786788603;
        Sat, 11 Jul 2026 09:19:48 -0700 (PDT)
Received: from [172.31.1.12] ([70.105.248.123])
        by smtp.gmail.com with ESMTPSA id 6a1803df08f44-8ffd87cacb8sm69347796d6.49.2026.07.11.09.19.47
        (version=TLS1_3 cipher=TLS_AES_128_GCM_SHA256 bits=128/128);
        Sat, 11 Jul 2026 09:19:47 -0700 (PDT)
Message-ID: <20b583fd-cf4d-45ec-9c86-32a96ba819bc@redhat.com>
Date: Sat, 11 Jul 2026 12:19:47 -0400
Precedence: bulk
X-Mailing-List: linux-nfs@vger.kernel.org
List-Id: <linux-nfs.vger.kernel.org>
List-Subscribe: <mailto:linux-nfs+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:linux-nfs+unsubscribe@vger.kernel.org>
MIME-Version: 1.0
User-Agent: Mozilla Thunderbird
Subject: Re: [PATCH 0/2] rpc.gssd: Two resource leaks
To: tbecker@redhat.com, linux-nfs@vger.kernel.org
References: <20260703163946.2185163-1-tbecker@redhat.com>
Content-Language: en-US
From: Steve Dickson <steved@redhat.com>
In-Reply-To: <20260703163946.2185163-1-tbecker@redhat.com>
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 7bit



On 7/3/26 12:39 PM, tbecker@redhat.com wrote:
> From: Thiago Becker <tbecker@redhat.com>
> 
> Patch 1 drops a reference to clnt_info when alloc_upcall_info fails.
> Patch 2 frees the thread attributes before returning from
> start_upcall_thread.
> 
> Both leaks were identified by claude sonnet 4.5, among some amount of
> false positives that were hand filtered.
> 
> Thiago Becker (2):
>    rpc.gssd: Decrement client referece count on error paths
>    rpc.gssd: Call pthread_attr_destroy before returning from
>      start_upcall_thread
> 
>   utils/gssd/gssd_proc.c | 4 ++++
>   1 file changed, 4 insertions(+)
> 
Committed... (tag: nfs-utils-2-9-2-rc5)

steved.

