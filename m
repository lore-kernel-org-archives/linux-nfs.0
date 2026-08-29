Received: from us-smtp-delivery-124.mimecast.com (us-smtp-delivery-124.mimecast.com [170.10.133.124])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id D41E53D45D4
	for <linux-nfs@vger.kernel.org>; Sat, 29 Aug 2026 21:28:23 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=170.10.133.124
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1788038905; cv=none; b=beAtUwf3wfl9L3af0Fp/C4ROD27tZR+9XJhO/BZUt+GwPImk0NfXQ5ZSBxjZ5lKy0auwRUU+B1WOWB6rl39yq1tllMzMAzINzMInKfy+yOSO6ZLsUpOeyYfLmfOBJIlgtTu1365ba6qCHuBSyEK/K0/thVME5rFzBJX+IE4aPvw=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1788038905; c=relaxed/simple;
	bh=t9YrrL8WX44PKD7UZ/5B4K7hShNQTu+CKPYJKl4LCrQ=;
	h=Message-ID:Date:MIME-Version:Subject:To:Cc:References:From:
	 In-Reply-To:Content-Type; b=hq04CepY91vbfufZk7tDnDkFLvI2fgn0Zrhcc5BRC/C0gn0MQCUFlmWy3WB9nJ8xIlRQ4RbrbNZheoDSt666zVAz9/5UekP0p16FUKda9Z3RzYnUgLGHQrxsUjhdWzGOhHfxD15BSkOn6Fm2GWrpATexbByeNFr++D6tZstECkc=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dmarc=pass (p=quarantine dis=none) header.from=redhat.com; spf=pass smtp.mailfrom=redhat.com; dkim=pass (1024-bit key) header.d=redhat.com header.i=@redhat.com header.b=HIgrJEDt; dkim=pass (2048-bit key) header.d=redhat.com header.i=@redhat.com header.b=p1IufqC2; arc=none smtp.client-ip=170.10.133.124
Authentication-Results: smtp.subspace.kernel.org; dmarc=pass (p=quarantine dis=none) header.from=redhat.com
Authentication-Results: smtp.subspace.kernel.org; spf=pass smtp.mailfrom=redhat.com
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (1024-bit key) header.d=redhat.com header.i=@redhat.com header.b="HIgrJEDt";
	dkim=pass (2048-bit key) header.d=redhat.com header.i=@redhat.com header.b="p1IufqC2"
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=redhat.com;
	s=mimecast20190719; t=1788038902;
	h=from:from:reply-to:subject:subject:date:date:message-id:message-id:
	 to:to:cc:cc:mime-version:mime-version:content-type:content-type:
	 content-transfer-encoding:content-transfer-encoding:
	 in-reply-to:in-reply-to:references:references;
	bh=afoMkcogJ5WMHTwPu275qMnQPiqhjwIchcnwz9IGULA=;
	b=HIgrJEDtAtOnQ3qp7B4aqZyAhBlZBGII6mR5BBZcBTCItU6OEXTbUuF9LjMv7S3U6NnP48
	6rM9QKSLfovla2YV1eb7nf1rQj0pyr5ry37bWdSZOPTqdT6E6PfzfwLz/7O9pNrQZ/OcgW
	Sfv8FIneeIunv5GRjaZgFX+zUV19uSc=
Received: from mail-qv1-f70.google.com (mail-qv1-f70.google.com
 [209.85.219.70]) by relay.mimecast.com with ESMTP with STARTTLS
 (version=TLSv1.3, cipher=TLS_AES_256_GCM_SHA384) id
 us-mta-146-BODd6n6CMkqz-j8OU7ZsGQ-1; Sat, 29 Aug 2026 17:28:21 -0400
X-MC-Unique: BODd6n6CMkqz-j8OU7ZsGQ-1
X-Mimecast-MFC-AGG-ID: BODd6n6CMkqz-j8OU7ZsGQ_1788038900
Received: by mail-qv1-f70.google.com with SMTP id 6a1803df08f44-90cd16a0bc1so48933636d6.0
        for <linux-nfs@vger.kernel.org>; Sat, 29 Aug 2026 14:28:21 -0700 (PDT)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=redhat.com; s=google; t=1788038900; x=1788643700; darn=vger.kernel.org;
        h=content-transfer-encoding:content-type:in-reply-to:from
         :content-language:references:cc:to:subject:user-agent:mime-version
         :date:message-id:from:to:cc:subject:date:message-id:reply-to
         :content-type;
        bh=afoMkcogJ5WMHTwPu275qMnQPiqhjwIchcnwz9IGULA=;
        b=p1IufqC2srQIwk3Bzo0vTsaR6eWZh2JJ8iw6VTzE//CULi9AZlDEwNFHgxz+uYIcSZ
         Ozq5jyFF9KH08pu9Wsh91B0g1MbkEZyRzHFGWC1Tjg5KxDmSOQ5kkO+JNGHXrTeYYULD
         yGkxtknT3TvifV/QqDfRu0u+fQUrcQREiapYejLkwtvIaF7EqRyOG1s3KHs33bh1Rv4f
         vx5dyH/C5ZsmsCOoA5lA8KpxS25SFfMB/4MHa5W34whpkV/T0z2UsMJB2cemDYBw3IrD
         wjvNpzU2RxHHhimQHDOLSahQ7B2PqgB2AHz1LEQA96/MhwZDA3mju1l0HaKcJt8nsvsG
         PrKw==
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20251104; t=1788038900; x=1788643700;
        h=content-transfer-encoding:content-type:in-reply-to:from
         :content-language:references:cc:to:subject:user-agent:mime-version
         :date:message-id:x-gm-gg:x-gm-message-state:from:to:cc:subject:date
         :message-id:reply-to:content-type;
        bh=afoMkcogJ5WMHTwPu275qMnQPiqhjwIchcnwz9IGULA=;
        b=syPz2SmSYsy+feDnJZKkU9jTab/iRaF6sl4R0Ph6WN5mxJNlZS0ShE/BxFQIqh98Tb
         705gc6ODkFyrFPvohBMiNXBEVdSvgRLxU6q/e+fRJcON385TnwkezaLlyW1nBFNz6W+x
         evbWq/fNxI9W+OulD7TYolxgMilxjLWIMpMuDgEHAf+UFjfQQP3znHkes3/q8Nmxwd9y
         9Z5ixUm8pc5UHx5vJkEOskXDzyP6q107dbD1/Bf5dxM5ruRzCxJ82aayiP9j9CQ7Oyqa
         8lkGSelfWFlvCwkIhmStb13PH7jiCFCyQfcUrKh4MTqAq7GM3k5AXKoOrI/Two5zxfIJ
         Wvkw==
X-Forwarded-Encrypted: i=1; AKwUvByeqsGuYGb+Wh9QW7TPkcyFU5pcFsfn/qns1qvauIWXm0yRtwNybQGsmd6c1Ir5+do9/y7PKCPmnrw=@vger.kernel.org
X-Gm-Message-State: AFuF++mP6YB03at6Z9ZUy0ckgoGTafe9xvSfmVf/wzfhJNYexaYKxr01
	U361qAetrRrxFLqVKTNfRuxN2jRmzuXly5C+UnnIuiZZEZcFYeQl12o2zCxHgUbdPpakQkAOOLn
	gB/vLMD0hcu1yM3VyiB3lYEj+vfOR4CTWr1HS6Vw6zRwztRwyIAmNypA9mrFGuw==
X-Gm-Gg: AYBFou1iAI2cJIZ6zAdESwI1dU5ixvyaDNccV+PR/fHkU02pr+yMuD1spk8KOR1ISGO
	pZwaElZviQAFByF8dPkBLMG0FXjBWdVkDdkMPQrJ6k0P0qmaK1x5XIde/LcF+gLJTfAAePMMwN6
	WrpU1sgF+8qH3dTjgiOgC8H/3iwQbekvFyC4Fi9XvTrnghoT4aIfJ9pOyLIBXBR3KN2vKNWXn7b
	AnGoJdiGxcelE2DiykaIde2aVc16IJbaPTMHpU/RHKPvmq6pqMR4sAMh4pBGCxkMjSE9nVA9ydQ
	F8HTbkftVYuRqjLXQNJLDg3s9wH4loN1Dy6jNUxcpngGWDsLkoud1kYd0YLgSsm+Qfk+45JUU3j
	avi0Fq6gNktVRjy578Ic6gdg1hFihgrGDCbiRKNEUydz6Ywe3
X-Received: by 2002:a05:6214:2683:b0:907:5c68:54d1 with SMTP id 6a1803df08f44-90ce0ef51dcmr191613406d6.18.1788038900475;
        Sat, 29 Aug 2026 14:28:20 -0700 (PDT)
X-Received: by 2002:a05:6214:2683:b0:907:5c68:54d1 with SMTP id 6a1803df08f44-90ce0ef51dcmr191613176d6.18.1788038900092;
        Sat, 29 Aug 2026 14:28:20 -0700 (PDT)
Received: from ?IPV6:2603:6000:1d40:9300:d6cc:b253:d867:f7d1? ([2603:6000:1d40:9300:d6cc:b253:d867:f7d1])
        by smtp.gmail.com with ESMTPSA id 6a1803df08f44-90ce4460e56sm47954986d6.14.2026.08.29.14.28.17
        (version=TLS1_3 cipher=TLS_AES_128_GCM_SHA256 bits=128/128);
        Sat, 29 Aug 2026 14:28:18 -0700 (PDT)
Message-ID: <f4014960-f714-4d6c-be1f-f420f8a22277@redhat.com>
Date: Sat, 29 Aug 2026 16:28:16 -0500
Precedence: bulk
X-Mailing-List: linux-nfs@vger.kernel.org
List-Id: <linux-nfs.vger.kernel.org>
List-Subscribe: <mailto:linux-nfs+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:linux-nfs+unsubscribe@vger.kernel.org>
MIME-Version: 1.0
User-Agent: Mozilla Thunderbird
Subject: Re: [PATCH v1 0/3] nfsdctl: list NFSv4 clients
To: Jeff Layton <jlayton@kernel.org>,
 Prabhakar Pujeri <prabhakar.pujeri@dell.com>
Cc: cel@kernel.org, linux-nfs@vger.kernel.org
References: <cover.1787639206.git.prabhakar.pujeri@dell.com>
 <b5e772f9d0e0aaae7e36320032518ce57139170d.camel@kernel.org>
Content-Language: en-US
From: Steve Dickson <steved@redhat.com>
In-Reply-To: <b5e772f9d0e0aaae7e36320032518ce57139170d.camel@kernel.org>
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 7bit



On 8/28/26 10:37 AM, Jeff Layton wrote:
> On Tue, 2026-08-25 at 06:52 +0000, Prabhakar Pujeri wrote:
>> Add the userspace consumer for the companion NFSD Netlink client-state
>> series, whose cover Message-ID is:
>>
>>    <cover.1787638668.git.prabhakar.pujeri@dell.com>
>>
>> The series mirrors the kernel ABI split:
>>
>>    1. Display the explicit recovery-grace value returned by threads-get.
>>    2. Add a privileged `nfsdctl clients` table for basic client state.
>>    3. Extend the table with session and stateid record counts.
>>
>> Attribute presence remains the compatibility boundary. An older kernel
>> omits the grace value, and missing count attributes are displayed as
>> dashes. The bundled UAPI header permits building before the new kernel
>> header is installed. The configure probe requires the final count
>> attribute, so a system header containing only the base client command also
>> falls back to the complete bundled copy.
>>
>> Validation performed:
>>
>>    - full nfs-utils build at each applicable patch state
>>    - final `make check`: no failures; one environment-dependent test skipped
>>    - bundled nfsd Netlink UAPI compared byte-for-byte with the kernel copy
>>    - two-vCPU QEMU test with a live NFSv4.2 loopback mount
>>    - grace yes/no transitions displayed by `nfsdctl threads`
>>    - live client row showing one session, open stateid, lock stateid, and
>>      delegation stateid; zero layout stateids
>>    - callback, reclaim, lease, peer-address, and client-ID fields checked
>>
>> The series is based on the current nfs-utils master branch. The exact base
>> is recorded in the base-commit trailer below.
>>
>> Prabhakar Pujeri (3):
>>    nfsdctl: report NFSv4 grace state
>>    nfsdctl: add a command to list NFSv4 clients
>>    nfsdctl: display per-client NFSv4 state usage
>>
>>   configure.ac                   |   2 +-
>>   support/include/nfsd_netlink.h |  41 +++++
>>   utils/nfsdctl/nfsdctl.8        |  22 ++-
>>   utils/nfsdctl/nfsdctl.adoc     |  15 +-
>>   utils/nfsdctl/nfsdctl.c        | 268 +++++++++++++++++++++++++++++++++
>>   5 files changed, 345 insertions(+), 3 deletions(-)
>>
>>
>> base-commit: 67ed1bdb1af1c70a5fd3b377a997401b7676b827
> 
> Sashiko has some comments about this that probably need to be addressed
> before we apply these. There is potential for a softlockup in patch #3,
> in particular:
> 
> https://sashiko.dev/#/patchset/cover.1787638668.git.prabhakar.pujeri%40dell.com
Okay... I'll wait to apply them until things get sorted out... but
I will keep them on my todo list...

steved.

