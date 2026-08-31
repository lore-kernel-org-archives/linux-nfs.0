Received: from us-smtp-delivery-124.mimecast.com (us-smtp-delivery-124.mimecast.com [170.10.129.124])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 330DF3C062F
	for <linux-nfs@vger.kernel.org>; Mon, 31 Aug 2026 22:57:32 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=170.10.129.124
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1788217053; cv=none; b=JDX07IuuUhoCdFvNH0viBKSdKEpvs+8vUMeofMr867EV9drUGAKkyvClZvxLBc4tSMJ05i+1dIIEGOPqygTV/hICsGyY2FtETk0mFzAH9gxbh3SeXipfPvq6HQyzX6mJNE+RV7sIwBQW49+qYI4f9F6zBPl/OxHC59m1ypTn2g8=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1788217053; c=relaxed/simple;
	bh=GpeHPKTRA3D86RvukcJ0br/yc7oq5/9MGcGs5b8vqpk=;
	h=Message-ID:Date:MIME-Version:Subject:To:Cc:References:From:
	 In-Reply-To:Content-Type; b=JOJIuEGWJpPwzH1uluYwLqkYPMrqrnRWGlpQNKNthP6BNZEF/65sRj5wAD9wEq/cOW0qlA4seeRKewY1TzqAsBSdCASx4Pe1Ba7bJA0pJl1frPn2T5fT68HHHT4QbujyZATuLJbGrEy1+WsU9+e++Up94ngdyW2Bb3OzRfqt1bk=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dmarc=pass (p=quarantine dis=none) header.from=redhat.com; spf=pass smtp.mailfrom=redhat.com; dkim=pass (1024-bit key) header.d=redhat.com header.i=@redhat.com header.b=Ap/O0N5X; dkim=pass (2048-bit key) header.d=redhat.com header.i=@redhat.com header.b=qqMKjw/g; arc=none smtp.client-ip=170.10.129.124
Authentication-Results: smtp.subspace.kernel.org; dmarc=pass (p=quarantine dis=none) header.from=redhat.com
Authentication-Results: smtp.subspace.kernel.org; spf=pass smtp.mailfrom=redhat.com
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (1024-bit key) header.d=redhat.com header.i=@redhat.com header.b="Ap/O0N5X";
	dkim=pass (2048-bit key) header.d=redhat.com header.i=@redhat.com header.b="qqMKjw/g"
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=redhat.com;
	s=mimecast20190719; t=1788217051;
	h=from:from:reply-to:subject:subject:date:date:message-id:message-id:
	 to:to:cc:cc:mime-version:mime-version:content-type:content-type:
	 content-transfer-encoding:content-transfer-encoding:
	 in-reply-to:in-reply-to:references:references;
	bh=b27yAzmYBeDzHXV1ZI3AHpyzYskfL3QeAmrkEoTq8s8=;
	b=Ap/O0N5XBDoD1o0YAWV9ztcktN6SlHXHlQvjnUZOvs8KwaifZaMlkt5fp3//A9R6PTypmA
	pf9wh2ZyIADB8M604ejCuA80UTt5rwC62VbB7BNK0JCbzDiIVhupvpsUWbTRheapBAqNAz
	+YGq9OFE/y16ZQxuddyqDcyurLmXadY=
Received: from mail-qv1-f72.google.com (mail-qv1-f72.google.com
 [209.85.219.72]) by relay.mimecast.com with ESMTP with STARTTLS
 (version=TLSv1.3, cipher=TLS_AES_256_GCM_SHA384) id
 us-mta-427-jdzBeD51MgGk_BLm0fpY9w-1; Mon, 31 Aug 2026 18:57:29 -0400
X-MC-Unique: jdzBeD51MgGk_BLm0fpY9w-1
X-Mimecast-MFC-AGG-ID: jdzBeD51MgGk_BLm0fpY9w_1788217049
Received: by mail-qv1-f72.google.com with SMTP id 6a1803df08f44-90e87478402so47577156d6.1
        for <linux-nfs@vger.kernel.org>; Mon, 31 Aug 2026 15:57:29 -0700 (PDT)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=redhat.com; s=google; t=1788217049; x=1788821849; darn=vger.kernel.org;
        h=content-transfer-encoding:content-type:in-reply-to:from
         :content-language:references:cc:to:subject:user-agent:mime-version
         :date:message-id:from:to:cc:subject:date:message-id:reply-to
         :content-type;
        bh=b27yAzmYBeDzHXV1ZI3AHpyzYskfL3QeAmrkEoTq8s8=;
        b=qqMKjw/gUGy9T9SE8O0ypEvyFkMCKXwK6EOyQydRHEgbg6nbi8Rq2ga4uEOW48++wo
         fvmoHPTbBRFcbfWIxMtD28YzYMik8mnajfQOEg+/HvaWcoZsZRFNw66vv80DCsJqTwxw
         aAoeuABmj9kPEiv8A1kMCKfiCb20DxCtJ7NsOZX55X5uTfxIU6FePgJcKfNL0opBMhKX
         rN5ZvfuHl8QmGqFNam4C0q3xQluyb7PWx5PlZo239ZjbEoASsuMhjh2m9YZcfyQhSLIy
         gNfbG9yYGUaqby8NYGigOl6dFMunDj4gf3xp/nGLc1Xg34q3Wn5kicAHzR2VwMNYbd88
         JcEQ==
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20251104; t=1788217049; x=1788821849;
        h=content-transfer-encoding:content-type:in-reply-to:from
         :content-language:references:cc:to:subject:user-agent:mime-version
         :date:message-id:x-gm-gg:x-gm-message-state:from:to:cc:subject:date
         :message-id:reply-to:content-type;
        bh=b27yAzmYBeDzHXV1ZI3AHpyzYskfL3QeAmrkEoTq8s8=;
        b=WbOKILtez9zNh5Kzt/M4vX49vNPhHLBIwp/kPLve7Vqmb6cMPxlO0C6fNFbFNQH7Jb
         oFsQk/NEIRbdeJZZu4oswm9/DWLDfUAVqzVhhzUCFA79nQYo/GJInYYhA6CdSY2JPMbj
         jRTfdyFfNgliq973LXovPkib9KIVhfp1oyK/fegwb8DyymUIcwsun6RF5bS9I3MELLO2
         3hoH+ygHW4TnjHXxghrCZiwH2zob1b0w5Jlpl/2y8gBQg6iaOvO54h4wDcl0K6gtL4DK
         X7dcFEL1dwtUkpEk0VswaasONlfvCHaTml1cgooU838p0c6JgmMLj//3QlXfqaR9Ompj
         yZEQ==
X-Gm-Message-State: AFuF++n3WxhnKCiTz6nOBzgVAR1kuFvTDzEc15baV5yD+amJyQGEzqDG
	Bmr/tgvneTKjGL+ZnBkJI2ZdTV9lH+59prszeaYbKkzd9u1VNTOK2WI3UEUokpbaGeJzQ7bYVWl
	aFhAOgwX0BmxWEh6QQpJOce7gBRKZ/vNCdsnvAGFkqTchrqcQ2XqncJ5MeoaUGBqY2WFw4A==
X-Gm-Gg: AYBFou2P7gU60gHuve/wiS4uABAVmj8gvgCBze+ojhXAhgEfPvVlrhnK36mK6dvKVzm
	vJuN+6gZhowyyjIHqDjA7L+5szty14UFD+M2rLYUa9vVA3u8Hwty57+kjY4sa+hPQnne65/gtYI
	t9PKHcuAi2MltReXY+VkMJu8gNVI3Av1Od47CZ0vJienIbDtkvUVrNTocBLBEV0afxofr+Vt/Jb
	G25yjjOVgNrQld/Ti4jIXuiOtv0n6iP5oGGXRlcR2aUFM6DCpYrOXDqCCwPlYvxvjG3lwH9h0of
	U4l5iHcOXCvzzjfI/ijZXa91svJGcVcxQA+Lkp9yGvA/1jUQo0sZ43qKKJaqChz2pGWh1VuWLgq
	0yEL+pn7vuZC7dBlngeRbXQmzrROYupQz2MckGowK4GemcrAn
X-Received: by 2002:a05:6214:20a6:b0:908:951f:415 with SMTP id 6a1803df08f44-90ce0c5a74dmr357284446d6.13.1788217049137;
        Mon, 31 Aug 2026 15:57:29 -0700 (PDT)
X-Received: by 2002:a05:6214:20a6:b0:908:951f:415 with SMTP id 6a1803df08f44-90ce0c5a74dmr357284046d6.13.1788217048718;
        Mon, 31 Aug 2026 15:57:28 -0700 (PDT)
Received: from ?IPV6:2603:6000:1d40:9300:d6cc:b253:d867:f7d1? ([2603:6000:1d40:9300:d6cc:b253:d867:f7d1])
        by smtp.gmail.com with ESMTPSA id 6a1803df08f44-90ce4516af8sm94671016d6.38.2026.08.31.15.57.26
        (version=TLS1_3 cipher=TLS_AES_128_GCM_SHA256 bits=128/128);
        Mon, 31 Aug 2026 15:57:28 -0700 (PDT)
Message-ID: <e5c7570a-394b-4851-abd3-c49389b58c47@redhat.com>
Date: Mon, 31 Aug 2026 17:57:26 -0500
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

