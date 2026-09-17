Received: from mail-pz2-f16.google.com (mail-pz2-f16.google.com [74.125.228.16])
	(using TLSv1.2 with cipher ECDHE-RSA-AES128-GCM-SHA256 (128/128 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id A5A5C4EFFA2
	for <linux-nfs@vger.kernel.org>; Thu, 17 Sep 2026 15:42:50 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=74.125.228.16
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1789659776; cv=none; b=m7F/IUfkBrNF4zz8fNj70AtG+u+Z0hkh7LifF1FaRmnlUay4+zmXqHGanGD9i1JV08y+e13ZtJoImRbMho0NSXcoadQA3E5eGywVxlY3+BxecBVaPnG8XK8ND63z5HDcY75T6X1O7/3E8HHQcGLIg5RmmAFGpoHuszYnvpSxf9w=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1789659776; c=relaxed/simple;
	bh=s8PAE+ZaFj8eyg+owEYEl1hVBrezOmbFFSE1op/JV4s=;
	h=Message-ID:Date:MIME-Version:Subject:To:Cc:References:From:
	 In-Reply-To:Content-Type; b=VAxO9LsCc7/TuXkrgo7eaewh8VijkKm3zCYp7cDqRXDnrdtEG9lEKgDLF1o2Of0MAYZ1DbYUq6xHcR8w1Nya/Bfqn19kPPoJADqfY6UuPKB5+hBD4HOgFxoGJNJacSMxpEufdPZzszN/GNYBmwu3Yh3hrygpIiRb/vd4mmONg+U=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dmarc=pass (p=none dis=none) header.from=gmail.com; spf=pass smtp.mailfrom=gmail.com; dkim=pass (2048-bit key) header.d=gmail.com header.i=@gmail.com header.b=Mw4fWg2X; arc=none smtp.client-ip=74.125.228.16
Authentication-Results: smtp.subspace.kernel.org; dmarc=pass (p=none dis=none) header.from=gmail.com
Authentication-Results: smtp.subspace.kernel.org; spf=pass smtp.mailfrom=gmail.com
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=gmail.com header.i=@gmail.com header.b="Mw4fWg2X"
Received: by mail-pz2-f16.google.com with SMTP id 41be03b00d2f7-cc4d2fe2056so654651a12.2
        for <linux-nfs@vger.kernel.org>; Thu, 17 Sep 2026 08:42:49 -0700 (PDT)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=gmail.com; s=20251104; t=1789659767; x=1790264567; darn=vger.kernel.org;
        h=content-transfer-encoding:content-type:in-reply-to:from:references
         :cc:to:content-language:subject:user-agent:mime-version:date
         :message-id:from:to:cc:subject:date:message-id:reply-to:content-type;
        bh=z3KrinycGZmbqioK98byaQi4edg0eDsQ+Sn682kLNTE=;
        b=Mw4fWg2Xlb2jAnUkmbvcPd+rJzhTeK68pzkSfRvxcfjT2oJ4+I9CzkW9l6yx0s3Slw
         6C7/r9Z/+L/p235Sqe4V1e4hHvZEYyg7JYILRRasxrHW9BRbfUPQ2EUWBXwP7YX+fKCW
         VeDDadKZPqBsYr7+Hwd/8w8TZia+jHtFRLLtE5SWcDFQd0zri4VxTaN9tlMI0viRTQfW
         K5zP4q7alNBElwjw4yzB1lqyE+mLVDOSsWrDKkJM2UPfdrqoY7rFNEQNlNU3ZNwn8PHb
         wtaPEIySEiqBsYgNvFmyDKwYYoJHo8V9jQG5ashmlgCDg4nW+LxqZGrKJwo5lvJznWd6
         fVmg==
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20260707; t=1789659767; x=1790264567;
        h=content-transfer-encoding:content-type:in-reply-to:from:references
         :cc:to:content-language:subject:user-agent:mime-version:date
         :message-id:x-gm-gg:x-gm-message-state:from:to:cc:subject:date
         :message-id:reply-to:content-type;
        bh=z3KrinycGZmbqioK98byaQi4edg0eDsQ+Sn682kLNTE=;
        b=E+eKMD7lhDzHxH1bUb8gUklMLzrPVadxwszMFpHcOAzf2zxnzLy+qYFSIAsD+9BrWC
         nBmArj9SU4U3PCoD8bkADL5ANsm7PiEuGNshN0xjxmZV1JMVnC1wNeOtcavt72UOwHEb
         wkB7q5Zju1xdmoF6YD+ZOoTZzlOP2TNNyRnD2szb8Ivo9eTGmUOtdlZsI/MaGHASGGV+
         dptd5Y2KmJw65wCwTLUysJd463rCjq0cnJZpaJI+vzp/0Qbq851RYkBsIJ5AayxZYE/Z
         E6VHbEJzYE2c+75jypXUIPnlrIwGZGEiwzcEgODOcYcPB4FVpk19NhiFDXqhcoEthgX4
         q3DQ==
X-Gm-Message-State: AFuF++lmV3euHJksxSqdyA6jFFAnXr+Y2ZujPR+Zsjx4yIsoGbujnMiI
	0rvCx1MQd6HVIfma6ne9Gb4tm2P+BrYZ+sY1UsdgXV1uOkcbHNZqizdl
X-Gm-Gg: AYBFou1XFfFZqVyO7e7VHp/O4xK6AKskKsQkNKIqxiS/Cdx7YD5cUbKakxbwIoCKH2U
	6lVBpEgYZtpEoMGZzG20U6OsTIwPkyDq7OjljrPAZWL5cHi/hcwYleYY4TF5BcuNYd9eH6AX6kW
	ItjXINpBVQaKgKF9aMm1rOFggyH8F7+2b7qtCX3bsxHnTKPweGMaJQG88ixKQWhSKTb3BdS5LyZ
	AmtPUkvdSbjXP1LPT5J70C3SpZA5xT8oKVKNa343pXBOjmc0paVS/6PFmIdZ655jFL/Nv5czLa3
	P3q/AHyVXp2fRdMPLeYWTeP+WdCuNgPDMp0jcFg+0jaWzb1+tyzhJI4K+IQnr0mSxOl++Li+wWw
	6/cCJUF29Ov1wwJjc1Labe4KcdVUDyFHfKmKBKLjIUZS3SSsArboqVkPvyD5vQ8LepgaJNvEzDM
	8N7N7R3EkDbnguSTsA4fisQW+yEX27q++B0brJZ3R6BPHIp+grq9NdEqcEe6mwwSPBP6LV8V3b6
	KIUpeGBY0YTFGAwncq5aFLzTaRfuWSI8rgGlO1qBRqQiwze3QIStRuTZDJT7GX+lKdxZBZU
X-Received: by 2002:a05:6a20:4313:b0:3d7:eb3e:1c58 with SMTP id adf61e73a8af0-3dd5f4347f1mr18179463637.8.1789659766483;
        Thu, 17 Sep 2026 08:42:46 -0700 (PDT)
Received: from ?IPV6:2600:1700:73d0:8030:9d35:65d8:492a:44f9? ([2600:1700:73d0:8030:9d35:65d8:492a:44f9])
        by smtp.gmail.com with ESMTPSA id 41be03b00d2f7-cc50ab50407sm3473870a12.9.2026.09.17.08.42.45
        (version=TLS1_3 cipher=TLS_AES_128_GCM_SHA256 bits=128/128);
        Thu, 17 Sep 2026 08:42:45 -0700 (PDT)
Message-ID: <f3218169-f309-477a-b439-3d106debd053@gmail.com>
Date: Thu, 17 Sep 2026 08:42:44 -0700
Precedence: bulk
X-Mailing-List: linux-nfs@vger.kernel.org
List-Id: <linux-nfs.vger.kernel.org>
List-Subscribe: <mailto:linux-nfs+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:linux-nfs+unsubscribe@vger.kernel.org>
MIME-Version: 1.0
User-Agent: Mozilla Thunderbird
Subject: Re: issues with Linux client pNFS
Content-Language: en-US
To: Anna Schumaker <anna@nowheycreamery.com>,
 Olga Kornievskaia <aglo@umich.edu>, Trond Myklebust <trondmy@hammerspace.com>
Cc: linux-nfs <linux-nfs@vger.kernel.org>
References: <41ee5118-027b-4630-8f02-b3a67c61b328@gmail.com>
 <6880c031-3936-4ea1-86f2-5dc6050c9051@oracle.com>
 <ff747b30-2537-4ee0-b827-beb0b7c2b323@gmail.com>
 <ed2753a1-bf56-42f2-b13f-0de2711496de@app.fastmail.com>
From: marc eshel <eshel.marc@gmail.com>
In-Reply-To: <ed2753a1-bf56-42f2-b13f-0de2711496de@app.fastmail.com>
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 7bit

Hi Anna,

This fix is related to DELEGATION_RETURN only, I was trying to recall 
all file layouts.

Marc.

On 9/17/26 6:29 AM, Anna Schumaker wrote:
> Hi Marc,
>
> On Wed, Sep 16, 2026, at 6:30 PM, marc eshel wrote:
>> Hi,
>>
>> I was just trying pNFS recall any but it look like the NFS client
>> received but ignored the call, is that expected ?
>>
>> [287100.214040] NFS: RECALL_ANY callback request from 10.11.96.99
>> [287100.214073] nfs4_callback_recallany: exit with status = 0
> Trond just had a patch the other day to fix an issue with CB_RECALL_ANY.
> Any chance you're able to test it to see if it fixes your issue?
>
> https://lore.kernel.org/linux-nfs/115e4102b1bab159c25e8e903070b55cc4de77eb.1789148631.git.trond.myklebust@hammerspace.com/
>
> Thanks,
> Anna
>> Thanks, Marc.
>>
>> On 9/16/24 1:33 PM, Anna Schumaker wrote:
>>> Hi Marc,
>>>
>>> On 9/16/24 4:27 PM, marc eshel wrote:
>>>> Hi,
>>>>
>>>> Who is the current maintainer of the Linux NFS client?
>>> That would be me and Trond.
>>>
>>>> I have an issue with the way pNFS client is distributing the reads among the DSs and I can provide the traces if anyone cares.
>>> What is the problem? And sure, send along the traces! I'll try to take a look as soon as I can.
>>>
>>> Anna
>>>
>>>> Thanks, Marc.
>>>>
