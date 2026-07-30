Received: from us-smtp-delivery-124.mimecast.com (us-smtp-delivery-124.mimecast.com [170.10.133.124])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id AC872412280
	for <linux-nfs@vger.kernel.org>; Thu, 30 Jul 2026 11:31:57 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=170.10.133.124
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1785411119; cv=none; b=hAiLPvZrWuuPDwKh/lhK1KIpvJ4vvfvyplrI64lPHWiFHciZ8L/EcGbSWgmEEeBeZko4dB6eCBG1S91BRKhaRc2IVbFTW1/7r+OfjaNg6cO3Chr9jqWs8f2LDph4tB+NCKFw5PS5krd/ya/CTFikucxsH/SXyyE6NuYlW9Z3qi8=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1785411119; c=relaxed/simple;
	bh=e232u/Y12qKTZX5OlS3gcTSH0tBMZOJ1MXCtIWOiahs=;
	h=Message-ID:Date:MIME-Version:Subject:To:Cc:References:From:
	 In-Reply-To:Content-Type; b=AfRrQE3YBkpzBksuOi71UNpXHeUdQSgqr6pE/cSt9KGzCZdZXLfCfXXlbkaMMmvlMca+NSMlTaqroiyJYSTbk/Bb9vTZxStrsLgE56AKoKXfSvNceAyXaIFJXc4CEW6PaDKwWz9o3mt2WFDfkGr95kFpqjccBXIdSduQs2mnDpc=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dmarc=pass (p=quarantine dis=none) header.from=redhat.com; spf=pass smtp.mailfrom=redhat.com; dkim=pass (1024-bit key) header.d=redhat.com header.i=@redhat.com header.b=UgW8w8lL; dkim=pass (2048-bit key) header.d=redhat.com header.i=@redhat.com header.b=lAb2wxe/; arc=none smtp.client-ip=170.10.133.124
Authentication-Results: smtp.subspace.kernel.org; dmarc=pass (p=quarantine dis=none) header.from=redhat.com
Authentication-Results: smtp.subspace.kernel.org; spf=pass smtp.mailfrom=redhat.com
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (1024-bit key) header.d=redhat.com header.i=@redhat.com header.b="UgW8w8lL";
	dkim=pass (2048-bit key) header.d=redhat.com header.i=@redhat.com header.b="lAb2wxe/"
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=redhat.com;
	s=mimecast20190719; t=1785411116;
	h=from:from:reply-to:subject:subject:date:date:message-id:message-id:
	 to:to:cc:cc:mime-version:mime-version:content-type:content-type:
	 content-transfer-encoding:content-transfer-encoding:
	 in-reply-to:in-reply-to:references:references;
	bh=K/oim8867mZQgToMOzPg8eJIB7HeZ+BxcHHpVKJYTOE=;
	b=UgW8w8lLg2yWWiSSi+dB89/nGj6f6ieCuPrlR46n7n8sVnUxp2Vt+vkiIAVo33Vbe04mUL
	6NRNTdcoCHvW9b/a8gyNz0Zm/d7lxCwrkYMIn82MQNtBXpNHrQbWf1v3WYkw9MBY97hzdX
	u6dPqxmYnPopcL6qECzpGD2kXq1w+5g=
Received: from mail-qt1-f200.google.com (mail-qt1-f200.google.com
 [209.85.160.200]) by relay.mimecast.com with ESMTP with STARTTLS
 (version=TLSv1.3, cipher=TLS_AES_256_GCM_SHA384) id
 us-mta-282-6wopuiJJN76w9EPBLhkRNg-1; Thu, 30 Jul 2026 07:31:55 -0400
X-MC-Unique: 6wopuiJJN76w9EPBLhkRNg-1
X-Mimecast-MFC-AGG-ID: 6wopuiJJN76w9EPBLhkRNg_1785411115
Received: by mail-qt1-f200.google.com with SMTP id d75a77b69052e-51c110a3b6aso28697221cf.1
        for <linux-nfs@vger.kernel.org>; Thu, 30 Jul 2026 04:31:55 -0700 (PDT)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=redhat.com; s=google; t=1785411114; x=1786015914; darn=vger.kernel.org;
        h=content-transfer-encoding:content-type:in-reply-to:from
         :content-language:references:cc:to:subject:user-agent:mime-version
         :date:message-id:from:to:cc:subject:date:message-id:reply-to
         :content-type;
        bh=K/oim8867mZQgToMOzPg8eJIB7HeZ+BxcHHpVKJYTOE=;
        b=lAb2wxe/jihl5iS9jWDpTMfLWbYuLbD6VtFqBi4qlBdiSMTwVelzCcznfSbF/qkvFJ
         pT0wZT4nLP9oDfz1sKz3L6/HZJvVtSf8JSbLC0X8zzHc/8K9/A+tKjdX+jm0VnCb75+D
         GjhZeWUU3IhnQS4MvcqKtAsvXFz++7WxN1a679UIFVEXJxar9ZIo5t3CNV9DNPJmwtob
         dNRfAkTYfAzh/kuugToc0bZ7za+YDs9PASrdxy91lNrJ/HdxSCYS1eVO/6G6eZgl3KV8
         73IhQfRZt53wA68wVJxHQiBelcsQn79ztJrn2dSVz8DDviBRfCJqz0teV4Q8Dc99xIs2
         Z1CQ==
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20251104; t=1785411114; x=1786015914;
        h=content-transfer-encoding:content-type:in-reply-to:from
         :content-language:references:cc:to:subject:user-agent:mime-version
         :date:message-id:x-gm-gg:x-gm-message-state:from:to:cc:subject:date
         :message-id:reply-to:content-type;
        bh=K/oim8867mZQgToMOzPg8eJIB7HeZ+BxcHHpVKJYTOE=;
        b=HHpPmjQZYyjO305OBUjz+wIKJ3u+oC/UcRsmfeluNXVx+4DIcJsZeoTJD9PVvHCYol
         X1qOzKGiC3qQB0Z9w3GnYePqJckP6HZoogHsjOVK51PrE3gelt7XZBxJsG+Db5rwDnOU
         ZgA01XokwGB9+DCw0taJSWxLAgrbbimzRAl+oZd3KzVx7FPctq7RPSGseqrbqqSI+Uhh
         ywVUIRbG/EtKadnz9e5hbXZ1NSKNc9hUaJntPUGHC4KPEpVoNSBsFw8KbzO+yyrtlDNy
         +rjBJcgaTpTDRrB/WuSuanIufMaPT9ZV2Q70N4krC0YL3pXpX/zNo4koybR2rrN+oWqU
         a49g==
X-Gm-Message-State: AOJu0YyTmhfvQDMniB6ZYE4LCZddg6SqCtSOzPXOuQxoln4UevhaPExV
	OgBzsFaWi4cKlFg4SbuHeyGFrTTfCXn3/t8xBKdmYo8dBE1Ni3ZZ5+o87iC8hF/1GVYkpvi6iQx
	8NHO9a8CW44d00l4wI/ulAExsrSfZDIzqDBPtZ1NhbL4shr2QlrmE0r6p3Y46+A==
X-Gm-Gg: AR+sD11vDjVcG2TpEz0XoCP8bIUBx+HIp+sjze2EeY6phxAxMT8jr5DOfpyaZ/pqWba
	gzYoQMBk0uPR+9pvtmXCtcBfVM2RU6qzjh1NuammZRQs/shK7JCycGhiAwMq6nWzVIEolUJqxM7
	Kd7t+1klYfios7qDM8RYzXYA63k6vETM1n7KD7H8ZV63eEIzeLpeJnxix36R6kToiUln7nGJo1R
	MzlCoX3x7DdmjBcHYuvlqYeYW7B+bsr27bwIBIG03SOObIZfwnfOFjFv9hvygVTS1QqqEPcIvjn
	HbcCWNI0vE2wYyXmMv5mjOgaRxDWX6C85LwDFXsLRAskx25xBQWNz5SxvlLS1AwwwMQa9+KI1Dt
	H
X-Received: by 2002:ac8:5750:0:b0:51b:ef2c:7bf0 with SMTP id d75a77b69052e-52b384c6e18mr21435331cf.35.1785411114641;
        Thu, 30 Jul 2026 04:31:54 -0700 (PDT)
X-Received: by 2002:ac8:5750:0:b0:51b:ef2c:7bf0 with SMTP id d75a77b69052e-52b384c6e18mr21435081cf.35.1785411114245;
        Thu, 30 Jul 2026 04:31:54 -0700 (PDT)
Received: from [172.31.1.12] ([70.105.250.248])
        by smtp.gmail.com with ESMTPSA id 6a1803df08f44-908324f3099sm15731886d6.38.2026.07.30.04.31.53
        (version=TLS1_3 cipher=TLS_AES_128_GCM_SHA256 bits=128/128);
        Thu, 30 Jul 2026 04:31:53 -0700 (PDT)
Message-ID: <c62e53e3-139a-43aa-bc7b-e4c3d47fa6d8@redhat.com>
Date: Thu, 30 Jul 2026 07:31:52 -0400
Precedence: bulk
X-Mailing-List: linux-nfs@vger.kernel.org
List-Id: <linux-nfs.vger.kernel.org>
List-Subscribe: <mailto:linux-nfs+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:linux-nfs+unsubscribe@vger.kernel.org>
MIME-Version: 1.0
User-Agent: Mozilla Thunderbird
Subject: Re: ANNOUNCE: nfs-utils-2.9.2 released.
To: mjnowen@gmail.com
Cc: Linux NFS Mailing list <linux-nfs@vger.kernel.org>,
 "linux-fsdevel@vger.kernel.org" <linux-fsdevel@vger.kernel.org>
References: <dc0f6f41-84be-4a70-92db-89890bded3ab@redhat.com>
 <CADFF-zfEws+xZ_tOqhC8uJZAFZvwMDtZ5yagDP9x7Umq6zabDA@mail.gmail.com>
Content-Language: en-US
From: Steve Dickson <steved@redhat.com>
In-Reply-To: <CADFF-zfEws+xZ_tOqhC8uJZAFZvwMDtZ5yagDP9x7Umq6zabDA@mail.gmail.com>
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 7bit



On 7/29/26 11:14 AM, Mike Owen wrote:
> I don't see this release tagged via git here:
> https://git.linux-nfs.org/?p=steved/nfs-utils.git;a=summary
> Forgot to tag?
I did... It is there now!

Thank you for pointing this out!

steved.
> 
> On Wed, 29 Jul 2026 at 15:48, Steve Dickson <steved@redhat.com> wrote:
>>
>> Hello,
>>
>> This is a fairly large release...
>>
>> A number of memory leaks fixed (from AI)
>> A number of netlinks fixes/enhances
>> A number of exportfs fixes/enhances
>> A new nfs-iostat option
>> A number of gcc/warnings fixes
>>
>> The tarballs can be found in
>>     https://www.kernel.org/pub/linux/utils/nfs-utils/2.9.2/
>> or
>>     http://sourceforge.net/projects/nfs/files/nfs-utils/2.9.2
>>
>> The change log is in
>> https://www.kernel.org/pub/linux/utils/nfs-utils/2.9.2/2.9.2-Changelog
>> or
>> https://sourceforge.net/projects/nfs/files/nfs-utils/2.9.2/2.9.2-Changelog
>>
>> The git tree is at:
>>      git://linux-nfs.org/~steved/nfs-utils
>>
>> Please send comments/bugs to linux-nfs@vger.kernel.org
>>
>> steved.
>>
>>
> 

