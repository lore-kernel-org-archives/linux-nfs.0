Received: from mail-wm1-f43.google.com (mail-wm1-f43.google.com [209.85.128.43])
	(using TLSv1.2 with cipher ECDHE-RSA-AES128-GCM-SHA256 (128/128 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 3CB34146D42
	for <linux-nfs@vger.kernel.org>; Tue,  2 Jul 2024 07:59:50 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=209.85.128.43
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1719907191; cv=none; b=henVQFhPpM7fCV/P7TM1b54MkE6CYga5Ioo1PQ8BNP+p60G2hrugTSBgNZb5KT9C45X8ZPkP0mlUpXseniI72UDCQPMrCsG7rk7+wNdbQRWVL8RwhOvFwWiCF4ub58ugweXfnJFlfSvo5NAWmj5sm9a+zOFCMfhN0u4ny8CkBdI=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1719907191; c=relaxed/simple;
	bh=nWpDQmZNg8zKVk12QskQ7NNS05C4fI/JmZBKLdKyu8Q=;
	h=Message-ID:Date:MIME-Version:Subject:To:Cc:References:From:
	 In-Reply-To:Content-Type; b=j+qcZ5L0vNHsyCnOzUbCmsp0wMd3YkrH84jdGfg7QLKu44tH7DNN+ujCUvll6mvtkSU+bnWAOcutsvBVBsy8KXeGD347KEzuyeTmVS7PvlUsgUzKpehaaBrTQhzkLYPIve1faGyV9l0BIBUvysV+SCO5NMI71Ouro9Vq9fwQkIY=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dmarc=none (p=none dis=none) header.from=grimberg.me; spf=pass smtp.mailfrom=gmail.com; arc=none smtp.client-ip=209.85.128.43
Authentication-Results: smtp.subspace.kernel.org; dmarc=none (p=none dis=none) header.from=grimberg.me
Authentication-Results: smtp.subspace.kernel.org; spf=pass smtp.mailfrom=gmail.com
Received: by mail-wm1-f43.google.com with SMTP id 5b1f17b1804b1-424aa86cc79so3413685e9.1
        for <linux-nfs@vger.kernel.org>; Tue, 02 Jul 2024 00:59:49 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20230601; t=1719907188; x=1720511988;
        h=content-transfer-encoding:in-reply-to:from:content-language
         :references:cc:to:subject:user-agent:mime-version:date:message-id
         :x-gm-message-state:from:to:cc:subject:date:message-id:reply-to;
        bh=nWpDQmZNg8zKVk12QskQ7NNS05C4fI/JmZBKLdKyu8Q=;
        b=DBdbFGE8Qw5BLYagGjl9IxTVVkbgGPFgK/76cSj7UwOhBYUMA3GsUhqXHF7tDwMn1N
         EO0YdigXNx6ecmYeVdcHN0Qg+DS4GLHl1fL89qK0r9OYR4rNIThiIg09dCWzg0nDfDfD
         zeSMGXQTIKg1t+0wJuEQ9/esAKDfNP2tVp4nZxN8/MGFVHdcogOfLOh8R0CSWX7YvnvD
         IOgr7kYf4sDIybMVI5iTSQHOD+uXastr0UqvFRDSY84Z0Vgh64lkDf228vbhUsRgDPSt
         2hVxL01HrohuYQreSjLWqabIR9bMMZrs7fuKrOIiRBKasWRY0VpRaZ87A5Y5X7rrFhZ6
         K+pQ==
X-Gm-Message-State: AOJu0Yy4XNOc9U4lULi8II03Bxebpv2flTbgtqgxvROBiLrRvd3zu3rv
	DVKcQf2r/O/P9cVYyTFteKjHDTC95J0IpTIKGphN9Ogm82RsPEfI
X-Google-Smtp-Source: AGHT+IHu3usf2FzRy6qdSfDY/Clmzq9KIkDnnavyS9nhmuCYCXfjOhuJTuWAn3VL1b4p4SMWD9iATA==
X-Received: by 2002:a05:600c:35d2:b0:425:73b8:cc5d with SMTP id 5b1f17b1804b1-4257a053e3fmr58558695e9.1.1719907188472;
        Tue, 02 Jul 2024 00:59:48 -0700 (PDT)
Received: from [10.50.4.180] (bzq-84-110-32-226.static-ip.bezeqint.net. [84.110.32.226])
        by smtp.gmail.com with ESMTPSA id 5b1f17b1804b1-42578800bf1sm88424785e9.1.2024.07.02.00.59.47
        (version=TLS1_3 cipher=TLS_AES_128_GCM_SHA256 bits=128/128);
        Tue, 02 Jul 2024 00:59:48 -0700 (PDT)
Message-ID: <ff49c8b8-ee6f-4895-9be9-0b705fed3b45@grimberg.me>
Date: Tue, 2 Jul 2024 10:59:47 +0300
Precedence: bulk
X-Mailing-List: linux-nfs@vger.kernel.org
List-Id: <linux-nfs.vger.kernel.org>
List-Subscribe: <mailto:linux-nfs+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:linux-nfs+unsubscribe@vger.kernel.org>
MIME-Version: 1.0
User-Agent: Mozilla Thunderbird
Subject: Re: [PATCH 6/7] nfs: move nfs_wait_on_request to write.c
To: Christoph Hellwig <hch@lst.de>, Trond Myklebust <trondmy@kernel.org>,
 Anna Schumaker <anna@kernel.org>
Cc: linux-nfs@vger.kernel.org
References: <20240701052707.1246254-1-hch@lst.de>
 <20240701052707.1246254-7-hch@lst.de>
Content-Language: en-US
From: Sagi Grimberg <sagi@grimberg.me>
In-Reply-To: <20240701052707.1246254-7-hch@lst.de>
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 7bit

Reviewed-by: Sagi Grimberg <sagi@grimberg.me>
