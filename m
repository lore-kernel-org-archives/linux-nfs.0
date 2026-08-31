Received: from us-smtp-delivery-124.mimecast.com (us-smtp-delivery-124.mimecast.com [170.10.133.124])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 229EA3C0A13
	for <linux-nfs@vger.kernel.org>; Mon, 31 Aug 2026 22:57:55 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=170.10.133.124
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1788217077; cv=none; b=Obx5sMxnedJ5duDvQOvc9s64twPUhe57qgo1a7hTHyUxz7pz/fPUtlEsp0gj9Fwi+b3W6fTmzmJ3P3+DD37lQEn9hlBdGsgvNl529RUpL0z2i4DEOtfnaYI53ywNynKPcGGIHKxFN9DI8ARUKZi9RWOQ5MU+Vv1WMLA0X/VnxH8=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1788217077; c=relaxed/simple;
	bh=ejsLqYm2+CCJARERYwzgjk45W2YNsKYoIQQgpIoT5Sg=;
	h=Message-ID:Date:MIME-Version:Subject:To:Cc:References:From:
	 In-Reply-To:Content-Type; b=mBS0uz4ITGf930DVh+eSbQXyUT42V91ByjQpHkIVuESHW1j0My7YUUwe5I5cI2R00gNoDMMcaElq4evkgHKO0RVL1Ecq/Yc39iL/3X58otvbxU14yvMeK3ScS3PkjdGZensJTIGrzVqdav5AJj116mx0GNqLWvGhHRch1dWYPxo=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dmarc=pass (p=quarantine dis=none) header.from=redhat.com; spf=pass smtp.mailfrom=redhat.com; dkim=pass (1024-bit key) header.d=redhat.com header.i=@redhat.com header.b=BqxCzFQt; dkim=pass (2048-bit key) header.d=redhat.com header.i=@redhat.com header.b=nni4F79r; arc=none smtp.client-ip=170.10.133.124
Authentication-Results: smtp.subspace.kernel.org; dmarc=pass (p=quarantine dis=none) header.from=redhat.com
Authentication-Results: smtp.subspace.kernel.org; spf=pass smtp.mailfrom=redhat.com
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (1024-bit key) header.d=redhat.com header.i=@redhat.com header.b="BqxCzFQt";
	dkim=pass (2048-bit key) header.d=redhat.com header.i=@redhat.com header.b="nni4F79r"
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=redhat.com;
	s=mimecast20190719; t=1788217074;
	h=from:from:reply-to:subject:subject:date:date:message-id:message-id:
	 to:to:cc:cc:mime-version:mime-version:content-type:content-type:
	 content-transfer-encoding:content-transfer-encoding:
	 in-reply-to:in-reply-to:references:references;
	bh=DMaZLxB3KEmVSeScfX+IxoTZm3dmSWq5BwnA4vSL9CI=;
	b=BqxCzFQteguM52wP2z0pjZ8Hg1/tde8M6wycXVL3Txu/RGa22DUGJzJr/e+piQgRF1pImz
	J7BJgUlklzVQBLrwctDbpBm02HfsBnjpxjS28aMDFEflDmNEVOMLqbjmeHRClxznOv7J9u
	0LAyQOYl6tWWUz2QzrMUk5QtG2sxEWY=
Received: from mail-qt1-f199.google.com (mail-qt1-f199.google.com
 [209.85.160.199]) by relay.mimecast.com with ESMTP with STARTTLS
 (version=TLSv1.3, cipher=TLS_AES_256_GCM_SHA384) id
 us-mta-650-zrb2hfv_P4iQ5hlPBQPM1Q-1; Mon, 31 Aug 2026 18:57:52 -0400
X-MC-Unique: zrb2hfv_P4iQ5hlPBQPM1Q-1
X-Mimecast-MFC-AGG-ID: zrb2hfv_P4iQ5hlPBQPM1Q_1788217072
Received: by mail-qt1-f199.google.com with SMTP id d75a77b69052e-52fc1e88189so65313131cf.1
        for <linux-nfs@vger.kernel.org>; Mon, 31 Aug 2026 15:57:52 -0700 (PDT)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=redhat.com; s=google; t=1788217072; x=1788821872; darn=vger.kernel.org;
        h=content-transfer-encoding:content-type:in-reply-to:from
         :content-language:references:cc:to:subject:user-agent:mime-version
         :date:message-id:from:to:cc:subject:date:message-id:reply-to
         :content-type;
        bh=DMaZLxB3KEmVSeScfX+IxoTZm3dmSWq5BwnA4vSL9CI=;
        b=nni4F79r5luaPd3+wcywlcfmAWygqUiJTCLiYUWfm9EHi+oS5ncXFlbl72pGbzrF/d
         2Z24V+RpNPnmD5SebC2PduFC8GeggUFm5Fv8j9zDXBjp2dJywRXYWd2NtEeCTf5yisVJ
         nvlNbDqlTAlKUBAnRnt7GPRM41Bb53JZLtjdJDsROpE3Twc5h/4WJk56kBT0FLJxwwPd
         HdmnrQTpr2kpyew21EQR4ZhMVjE8cUOlmFpHR48FmtOELSpLFk1xzCvDdS7ksUrLCj2n
         UdwMGBhOZY4lQEqecXcGIeIG5I1a4I7O3I3MeADxiSlhmPlZW07q95VhhkT9ZE1/2YIb
         RoVA==
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20251104; t=1788217072; x=1788821872;
        h=content-transfer-encoding:content-type:in-reply-to:from
         :content-language:references:cc:to:subject:user-agent:mime-version
         :date:message-id:x-gm-gg:x-gm-message-state:from:to:cc:subject:date
         :message-id:reply-to:content-type;
        bh=DMaZLxB3KEmVSeScfX+IxoTZm3dmSWq5BwnA4vSL9CI=;
        b=JOzUmP+raFEmZSrNjDUoACzXSmjy+MmbBOAQaR2RG4cnnCDNCJwKUHu86G8rGH5VNR
         jP3mJd5HvuZet1UhK9tG7JBF2SrspiKIuqnFtWQcnz6kwkcYfqUZZuHssat78VxJNHN3
         bHkz2kgX+l4oDBZvCmWuzp7aWQj5eJEP1cBlX1EK7OJPy8hJzARITiSjvSCKJZde0eY8
         uJ1Ha5SN/89s8o/GkGWxfmwzmAm25fGUnxw3XMA6f+RosUAnd7ymWPj3jJJKSzgXAy4O
         GL5Pik+Z+6RCcfgnlQKcXc/5+2mlom+J6XaTLh903WznejnN5xUI1M3wLJLY+CDGVV2s
         DEQw==
X-Gm-Message-State: AFuF++l5czoNdbveYCZBSpgczfJ8yOcRrSDJIayayRTe47/hR/vaE0dc
	oQ0BucXeAZmrL9jYSf50pwa+6QlIwXO3+wG53C3EdTmB3poYKjw2wX9fxWpv9ETkic61L+kBCFg
	7RouuiZ3NA2YzmCL0GSIEMNCygLTaPybfs0JRU98I48g8fi4DrWK5haU98XRqiA==
X-Gm-Gg: AR+sD11FxqYjpHXMBO7Z3YCr2w9p/BhivSnbu1FBqrHMPEmAjRU30S0WXFolY8Gy3/W
	iZAX++SG23HkzPZeH0hY5h0F83L5kcAc9UzLaXOVFmsCSTeYU0nSGocE1oSOSG6raJ7YxE3RSdt
	kuOodx9zrcBTxoTDCygbK0veSRABzI+PNg3BkvjMLf2UK7wxR24WlwYEd3/7FuxON2IGZJk3K6y
	Rk2XOwCp/3SF3DruQqQbGwrgwD2XrtXhX8VYi9syYKDo8zNJXn83CSB2ErhiGaIMwH9sfigyCSR
	87g8QcNZjfRsBNBzDV5qx2RtwGYZ23SiiPbJoYu3fbVnRcmzYrorA0nScradRXPq3UIzMG3mWg8
	bYR2+5G64h7R80f/oqsQDGoR6FtjxUNdy4ZUHKIyJuzN5kdRd
X-Received: by 2002:a05:622a:1f8f:b0:530:6d8:2324 with SMTP id d75a77b69052e-53006d82caamr178210491cf.22.1788217072094;
        Mon, 31 Aug 2026 15:57:52 -0700 (PDT)
X-Received: by 2002:a05:622a:1f8f:b0:530:6d8:2324 with SMTP id d75a77b69052e-53006d82caamr178210061cf.22.1788217071663;
        Mon, 31 Aug 2026 15:57:51 -0700 (PDT)
Received: from ?IPV6:2603:6000:1d40:9300:d6cc:b253:d867:f7d1? ([2603:6000:1d40:9300:d6cc:b253:d867:f7d1])
        by smtp.gmail.com with ESMTPSA id d75a77b69052e-52fbe5824f3sm81061831cf.10.2026.08.31.15.57.50
        (version=TLS1_3 cipher=TLS_AES_128_GCM_SHA256 bits=128/128);
        Mon, 31 Aug 2026 15:57:51 -0700 (PDT)
Message-ID: <583683ff-bfb0-4b89-aa96-9bfa4edbdeb8@redhat.com>
Date: Mon, 31 Aug 2026 17:57:50 -0500
Precedence: bulk
X-Mailing-List: linux-nfs@vger.kernel.org
List-Id: <linux-nfs.vger.kernel.org>
List-Subscribe: <mailto:linux-nfs+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:linux-nfs+unsubscribe@vger.kernel.org>
MIME-Version: 1.0
User-Agent: Mozilla Thunderbird
Subject: Re: [PATCH] rpcctl: SyntaxWarning: 'return' in a 'finally' block
To: Salvatore Bonaccorso <carnil@debian.org>,
 Anna Schumaker <Anna.Schumaker@Netapp.com>
Cc: linux-nfs@vger.kernel.org, 1144982@bugs.debian.org,
 "Trent W. Buck" <trentbuck@gmail.com>
References: <20260822144142.682662-1-carnil@debian.org>
Content-Language: en-US
From: Steve Dickson <steved@redhat.com>
In-Reply-To: <20260822144142.682662-1-carnil@debian.org>
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 7bit



On 8/22/26 10:41 AM, Salvatore Bonaccorso wrote:
> Trent W. Buck reported that when using rpcctl with Python 3.14
> version, a SyntaxWarning warning is issued on the use of return in the
> finally block in the read_info_file function.
> 
> Replace the finally clause with an except BaseException, and dedent the
> return by one level up.
> 
> Reported-by: "Trent W. Buck" <trentbuck@gmail.com>
> Link: https://docs.python.org/3/whatsnew/3.14.html#pep-765-control-flow-in-finally-blocks
> Closes: https://bugs.debian.org/1144982
> Signed-off-by: Salvatore Bonaccorso <carnil@debian.org>
Committed... (tag: nfs-utils-2-9-3-rc2)

steved.
> ---
>   tools/rpcctl/rpcctl.py | 5 +++--
>   1 file changed, 3 insertions(+), 2 deletions(-)
> 
> diff --git a/tools/rpcctl/rpcctl.py b/tools/rpcctl/rpcctl.py
> index 29ae7d26f50e..42e238ca1c52 100755
> --- a/tools/rpcctl/rpcctl.py
> +++ b/tools/rpcctl/rpcctl.py
> @@ -43,8 +43,9 @@ def read_info_file(path):
>           with open(path) as info:
>               lines = [line.split("=", 1) for line in info if "=" in line]
>               res.update({key: int(val.strip()) for (key, val) in lines})
> -    finally:
> -        return res
> +    except BaseException:
> +        pass
> +    return res
>   
>   
>   class Xprt:

