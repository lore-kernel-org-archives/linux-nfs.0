Received: from mail-pj2-f12.google.com (mail-pj2-f12.google.com [74.125.227.140])
	(using TLSv1.2 with cipher ECDHE-RSA-AES128-GCM-SHA256 (128/128 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id E9A103B71D3
	for <linux-nfs@vger.kernel.org>; Thu, 17 Sep 2026 19:00:11 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=74.125.227.140
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1789671613; cv=none; b=uhq3jqZsju8vkGkrzqigwSOvLKxws45n4sUCaoz6qMR4LR2PBN0EkC9lM7BlHmsbuTMDpre8sCaM0g5+CX2FtJm9rJS+qni2ufQ2UP+HUB8osnkVIBIt4tTYLF4SbJiko6hJoyna5VxLEmbDyfs00JLlLbljEBBadNFLDnraDGU=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1789671613; c=relaxed/simple;
	bh=zcyvpnSCvZDo9C07vjUctkM67dCNwvt6gbwxxFXqHW8=;
	h=Message-ID:Date:MIME-Version:Subject:From:To:Cc:References:
	 In-Reply-To:Content-Type; b=SpRubYNlVCaYVPJOygQOqiBwMgAFtSVp7IIDTrGsNUuVNa9i4eRPi0iKS5dd9gQirferrOHPR02weMww0LySmG3duYbpeT2o8qRUapS/XRF341JV+62IYgMe7OopN2DdwI91+QDAoDL7S9BDHNdcMiQU8MfzcjmULjsbZbGET3w=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dmarc=pass (p=none dis=none) header.from=gmail.com; spf=pass smtp.mailfrom=gmail.com; dkim=pass (2048-bit key) header.d=gmail.com header.i=@gmail.com header.b=ZaKT8ml3; arc=none smtp.client-ip=74.125.227.140
Authentication-Results: smtp.subspace.kernel.org; dmarc=pass (p=none dis=none) header.from=gmail.com
Authentication-Results: smtp.subspace.kernel.org; spf=pass smtp.mailfrom=gmail.com
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=gmail.com header.i=@gmail.com header.b="ZaKT8ml3"
Received: by mail-pj2-f12.google.com with SMTP id d9443c01a7336-2d747f0b25dso12995275ad.2
        for <linux-nfs@vger.kernel.org>; Thu, 17 Sep 2026 12:00:11 -0700 (PDT)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=gmail.com; s=20251104; t=1789671611; x=1790276411; darn=vger.kernel.org;
        h=content-transfer-encoding:content-type:in-reply-to:references:cc:to
         :from:content-language:subject:user-agent:mime-version:date
         :message-id:from:to:cc:subject:date:message-id:reply-to:content-type;
        bh=szS/urPqRVYtnZVSFIOA9nbunMszopOFKEErUE0oGjQ=;
        b=ZaKT8ml383W9eJVSRIWFUMLE9jJQ8a4bHnZM0dwNZiirgm/y25lmXnqkPF+F9RO2GT
         eWbKthpeWBh70Q0ADvY14SUlsWMkKxmYlh1zfCjV95O7cG8qEK7JPCWw0JP0g49V9hxY
         5pWWGWFH7sXdrJ0HpVWv6ptELnHfUEiUOQuM3J797zVS2O1BO1jgT5iKsCiA90ukRd1l
         nXhavgsbjL2WOZw0NduY7lInsL0sOiM/+aM6HwkcyiEj3ExcPI8HqdsU7L5bpb89/S1h
         M5YvqBEiKkgpZJGtJxBFkCpUjosecuE4yQZCkEx4dSt9DDH/ZPhxvpdkzGN2npnGbxFB
         3z4w==
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20260707; t=1789671611; x=1790276411;
        h=content-transfer-encoding:content-type:in-reply-to:references:cc:to
         :from:content-language:subject:user-agent:mime-version:date
         :message-id:x-gm-gg:x-gm-message-state:from:to:cc:subject:date
         :message-id:reply-to:content-type;
        bh=szS/urPqRVYtnZVSFIOA9nbunMszopOFKEErUE0oGjQ=;
        b=kmXBi39CWh37Mb5AVztcjvfb5eqU6CFLtrj5qU6i5QXJ42mOy4Xy9RFY9clTBKcjTm
         Pmu6mkHyMCapS+T7LuIbdiU0HOqTzCLrwFaPnABvwAbZXIoHIvA6Qr0IU7AO/X5svDDN
         kmBW2xqWxCSNIAzpEDj58cXgCx37yGacI8J9OcwevIsCUqPJFleO0p6b3wbEeeqGxySV
         htdpeY1Tx8C/08CyWgsJKO4JJ127xbGt25hU7WtPXM7F2n94il5DMvFwXDEQCa3Qmquq
         FjzdnLWcE+zHj/Nh+im14q3hEzQ8WOBeVNURAwp1gNIZlEci5dc+5J3FVznW7BZ8j6RE
         /ZWA==
X-Gm-Message-State: AFuF++lgLTIu9KhnYJPRpgA2NJVP9ChXkPkfLu/GxvR0LtqVqep0n9fb
	oxTYMMs9LMwTYdRUWHe9S5dHeqdzECG6ABXJW6CP7hjQ+nLWeNqGJfNp
X-Gm-Gg: AYBFou2fw8ZHTpfGch/9aYet3FxxyCbxKlABt47Yy1kdEJs0GGi4nv8EwA3SnQ3tKFV
	2GDdvKvfVV9izV/mr7VKA9rQxjKcqP27Gn6TlPdqTE0yTCgkV74nBafM6s/gnHLtRd3+LDvzH4P
	Uzr6z2cQTbyAk2NuyQFwtXRpQF9B1vDLv8AQG2r34Q9arY3aPc1tAKo6MooRNTfVVsKLx+fBdws
	tr4GNUgwR0cs6djXRGquH3R5AjfLTO6n0zddY7mU6vdj7Dutm6ZQTP3e0Xrju6+N1nEEQHjIsRl
	aClMzUyzu+kAfASY529OZIMpFIdK5kA/Lr97TIFR36uUUmH3BXR9HM7GrAaFlUynetQz3tJbt1U
	BqMSK2+HxTG7D/XEM+GZEmhVvUnMhYFbur0A6miAJpBGY23ftHg/ovlhyB3VhcjShjTsOlEZWM8
	X+L3Nxl5Azmt98iMo8vVIGiMfwVlzO2MF61jjUX41Wpdgp6FuZ16jORN3B0inDADcTkdfGzace+
	gB07A2bRfLyFHqVWr0f2Qice9cIp6x3cmZ19x8bkrLPqIyrezRuwpnfuygaNFSea5Vn6VdS
X-Received: by 2002:a17:903:2a8f:b0:2d9:1dee:43db with SMTP id d9443c01a7336-2ddb1b7ac15mr2361425ad.15.1789671610940;
        Thu, 17 Sep 2026 12:00:10 -0700 (PDT)
Received: from ?IPV6:2600:1700:73d0:8030:9d35:65d8:492a:44f9? ([2600:1700:73d0:8030:9d35:65d8:492a:44f9])
        by smtp.gmail.com with ESMTPSA id 5a478bee46e88-33bf5ac47cfsm15604494eec.17.2026.09.17.12.00.10
        (version=TLS1_3 cipher=TLS_AES_128_GCM_SHA256 bits=128/128);
        Thu, 17 Sep 2026 12:00:10 -0700 (PDT)
Message-ID: <0fc174bd-ec6b-45a6-be73-221d5b2b3518@gmail.com>
Date: Thu, 17 Sep 2026 12:00:09 -0700
Precedence: bulk
X-Mailing-List: linux-nfs@vger.kernel.org
List-Id: <linux-nfs.vger.kernel.org>
List-Subscribe: <mailto:linux-nfs+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:linux-nfs+unsubscribe@vger.kernel.org>
MIME-Version: 1.0
User-Agent: Mozilla Thunderbird
Subject: Re: issues with Linux client pNFS
Content-Language: en-US
From: marc eshel <eshel.marc@gmail.com>
To: Anna Schumaker <anna@nowheycreamery.com>,
 Olga Kornievskaia <aglo@umich.edu>, Trond Myklebust <trondmy@hammerspace.com>
Cc: linux-nfs <linux-nfs@vger.kernel.org>
References: <41ee5118-027b-4630-8f02-b3a67c61b328@gmail.com>
 <6880c031-3936-4ea1-86f2-5dc6050c9051@oracle.com>
 <ff747b30-2537-4ee0-b827-beb0b7c2b323@gmail.com>
 <ed2753a1-bf56-42f2-b13f-0de2711496de@app.fastmail.com>
 <f3218169-f309-477a-b439-3d106debd053@gmail.com>
In-Reply-To: <f3218169-f309-477a-b439-3d106debd053@gmail.com>
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 7bit

Hi Anna,

Reading the code around this patch it looks like some other flags are 
checked, so I tried to add RCA4_TYPE_MASK_OTHER_LAYOUT_MAX and with this 
flags file layout recall did work.

Thanks, Marc.

On 9/17/26 8:42 AM, marc eshel wrote:
> Hi Anna,
>
> This fix is related to DELEGATION_RETURN only, I was trying to recall 
> all file layouts.
>
> Marc.
>
> On 9/17/26 6:29 AM, Anna Schumaker wrote:
>> Hi Marc,
>>
>> On Wed, Sep 16, 2026, at 6:30 PM, marc eshel wrote:
>>> Hi,
>>>
>>> I was just trying pNFS recall any but it look like the NFS client
>>> received but ignored the call, is that expected ?
>>>
>>> [287100.214040] NFS: RECALL_ANY callback request from 10.11.96.99
>>> [287100.214073] nfs4_callback_recallany: exit with status = 0
>> Trond just had a patch the other day to fix an issue with CB_RECALL_ANY.
>> Any chance you're able to test it to see if it fixes your issue?
>>
>> https://lore.kernel.org/linux-nfs/115e4102b1bab159c25e8e903070b55cc4de77eb.1789148631.git.trond.myklebust@hammerspace.com/ 
>>
>>
>> Thanks,
>> Anna
>>> Thanks, Marc.
>>>
>>> On 9/16/24 1:33 PM, Anna Schumaker wrote:
>>>> Hi Marc,
>>>>
>>>> On 9/16/24 4:27 PM, marc eshel wrote:
>>>>> Hi,
>>>>>
>>>>> Who is the current maintainer of the Linux NFS client?
>>>> That would be me and Trond.
>>>>
>>>>> I have an issue with the way pNFS client is distributing the reads 
>>>>> among the DSs and I can provide the traces if anyone cares.
>>>> What is the problem? And sure, send along the traces! I'll try to 
>>>> take a look as soon as I can.
>>>>
>>>> Anna
>>>>
>>>>> Thanks, Marc.
>>>>>
