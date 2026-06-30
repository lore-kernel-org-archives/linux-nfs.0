Received: from mail-wm1-f47.google.com (mail-wm1-f47.google.com [209.85.128.47])
	(using TLSv1.2 with cipher ECDHE-RSA-AES128-GCM-SHA256 (128/128 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id E6AE43EF670
	for <linux-nfs@vger.kernel.org>; Tue, 30 Jun 2026 10:22:33 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=209.85.128.47
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1782814955; cv=none; b=vCvboTbD/yX8aHun9MxsefxnkiLAFfAYNzF8+f73tvO1/WXdyYexWCVs/0kJBsYE4W5DE+UGVo48o+Es/58gdZqKu6IwpLKsPCNXYsX1dmZvkHxzbpOqcfnSZuEIt9r6DwZx/MmquWFkFQCKTrKrfq9TcmYH8VPQCkNb00W9G/Q=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1782814955; c=relaxed/simple;
	bh=W3QIhHui5sACyeafMJCdCxKaxwJ/5JwxUciGy0YZlU4=;
	h=Message-ID:Date:MIME-Version:Subject:To:Cc:References:From:
	 In-Reply-To:Content-Type; b=cMkCcq6jkdYu6tXU8pNpk09fTQfRT6vzTj15+fH/yThl4Hsft/XUJUO39dyb1iPL+Nl8IclBov2QSOH86SCStHV+6JISBeY6GrWpVsO71duuGSmasbCj6di0rAvvKdkXqovqayWvKcSv9CZgKOuBt7+sOtzrx19SXarwm/WZZEk=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dmarc=pass (p=quarantine dis=none) header.from=vastdata.com; spf=pass smtp.mailfrom=vastdata.com; dkim=pass (2048-bit key) header.d=vastdata.com header.i=@vastdata.com header.b=JxdHXPT+; arc=none smtp.client-ip=209.85.128.47
Authentication-Results: smtp.subspace.kernel.org; dmarc=pass (p=quarantine dis=none) header.from=vastdata.com
Authentication-Results: smtp.subspace.kernel.org; spf=pass smtp.mailfrom=vastdata.com
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=vastdata.com header.i=@vastdata.com header.b="JxdHXPT+"
Received: by mail-wm1-f47.google.com with SMTP id 5b1f17b1804b1-493b691cb44so10359485e9.0
        for <linux-nfs@vger.kernel.org>; Tue, 30 Jun 2026 03:22:33 -0700 (PDT)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=vastdata.com; s=google; t=1782814952; x=1783419752; darn=vger.kernel.org;
        h=content-transfer-encoding:in-reply-to:from:content-language
         :references:cc:to:subject:user-agent:mime-version:date:message-id
         :from:to:cc:subject:date:message-id:reply-to;
        bh=W3QIhHui5sACyeafMJCdCxKaxwJ/5JwxUciGy0YZlU4=;
        b=JxdHXPT+OtOvcnx0XhrQo359RYJpXZhc5/MIjlLPTqFuSxfvwg+t2d9yYuVNmxcUYM
         V/vzXf00Edk75bZPGA25Lpk6GPG64jkkGHpjwHFMcZi8p6dLv5a2SLqKpTkiffic+74C
         Ao6SDKkucmEbFxjaKksk91D4VWe5EAGZ9XeCwO5uMglPwzalOb+zrxvIZXnu5/de8Mqu
         5GDuI/hIRNPLJo53DeyYWm3f1k6EqusSvEDiLvw8EIx3ZFrRygl3LG76y5d2OCj+WVCz
         sVsunKc5z686nCWHC++2gbNqB4+N08CEsV29VFSwv1ZvfRpKFPpbF1qfg/dkjpNU55HN
         c9og==
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20251104; t=1782814952; x=1783419752;
        h=content-transfer-encoding:in-reply-to:from:content-language
         :references:cc:to:subject:user-agent:mime-version:date:message-id
         :x-gm-gg:x-gm-message-state:from:to:cc:subject:date:message-id
         :reply-to;
        bh=W3QIhHui5sACyeafMJCdCxKaxwJ/5JwxUciGy0YZlU4=;
        b=l3Lf4ouiQEjP9dGSewCzkneXevkR33YmkFJR8ADeFFiZJY7fuerWWmdDf38Z1BmRFj
         c5LgVVUVHz7ux4jtXOCdJBBldM34tn48KzT51CQB9+qQWx26R8OwEEFyRwsKitHLUvZ1
         BM4w7n4eGfzL5gKrU9Kyo362nJtSD4u73tBG8j4eQqtZjYzzPNCUGKHvq+7gO7z2QwWZ
         By/QN6YkwuVTEtAQg8kEtItToL3KI/KPsZKrqQ8Jix/yUGUPHuiDqz/y7vqmbRZlZyhZ
         rHtCL7c0LtkKCS6sF8EIW5T0GvrEEd4PI3EuNHf2hzsBCnngPDZpbfsiCG5SHwe7292v
         CCsQ==
X-Gm-Message-State: AOJu0YzutXlHRE4XH+qUvE31VOBLIQwklgTEkCsOLqd1C5TXjrP9xNwr
	timfDTsCWIRTAA6QhBHqvZyvjabP12aEW2PX6BwxQhletANt6XSKZ87qIII61ZLIrg==
X-Gm-Gg: AfdE7cmq8tE25K4ewBJvp+egu45AyOQWxOw9Ap+baS3IjkxafvtnIbKof2nkR1wF9gL
	X8+TEdjzbQbP62G8lVLLcAin641gfn71RluYkm//SL71zNekoGqXAe3EHJbknzCvY+qf8RGlb0E
	MH7izQQy4Oa51eYP/scuMlxwZh77ujNDCm3I7fVDj3+J7DpCHX9swrPMnO85f14l6Tr3G02CKME
	iqeORfQf8GqePMnZc53l5gjbrcP2Xt6u2vAe/mgVp6YjRed56mhSyFtbvqmkddcuhxfZFdL5zUn
	ZBmu8eKlM23L2VTDSrwRsZCoQHkGXJgmbK3utuySClKP27QlFQgzFgaL5yRdjK8/wffpHGESRn4
	RNH1YpRKrP5Oz0FVETKROGI+q2Zr9S4UadKbjyOL3N0mIDJUmFAvzEgMstPmh+2UieuZyb68crL
	DdCdegAMYDMZ0Vfk6YrqR6Z61a2f8VxXvf9rXK5zzVxB5OyGyRhYI2zsasoBA/eF8R3hU2rdNxG
	GRSTZL4/ZyXTQv4b0HJNw==
X-Received: by 2002:a05:600c:3114:b0:492:5e71:f6ab with SMTP id 5b1f17b1804b1-493b82ae6e8mr46957835e9.20.1782814952393;
        Tue, 30 Jun 2026 03:22:32 -0700 (PDT)
Received: from [10.50.4.64] (bzq-84-110-32-226.static-ip.bezeqint.net. [84.110.32.226])
        by smtp.gmail.com with ESMTPSA id 5b1f17b1804b1-493b8cd2a3esm62474275e9.4.2026.06.30.03.22.30
        (version=TLS1_3 cipher=TLS_AES_128_GCM_SHA256 bits=128/128);
        Tue, 30 Jun 2026 03:22:31 -0700 (PDT)
Message-ID: <27ab9b8b-7b50-497a-880d-593eb07694b6@vastdata.com>
Date: Tue, 30 Jun 2026 13:22:30 +0300
Precedence: bulk
X-Mailing-List: linux-nfs@vger.kernel.org
List-Id: <linux-nfs.vger.kernel.org>
List-Subscribe: <mailto:linux-nfs+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:linux-nfs+unsubscribe@vger.kernel.org>
MIME-Version: 1.0
User-Agent: Mozilla Thunderbird
Subject: Re: [PATCH] nfs: fix ENXIO on O_CREAT open of existing symlink over
 NFSv3
To: trondmy@kernel.org, anna@kernel.org, neil@brown.name
Cc: linux-nfs@vger.kernel.org
References: <20260614122911.3485467-1-michael.nemanov@vastdata.com>
Content-Language: en-US
From: Michael Nemanov <michael.nemanov@vastdata.com>
In-Reply-To: <20260614122911.3485467-1-michael.nemanov@vastdata.com>
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 7bit



On 14/06/2026 15:29, Michael Nemanov wrote:
> When open(2) is called with O_CREAT on a path that already exists as a
> symlink, over an NFSv3 mount with a cold dcache, the kernel returns
> ENXIO instead of following the symlink to its target.
> ...

Trying again

