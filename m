Received: from mail-oo2-f39.google.com (mail-oo2-f39.google.com [74.125.231.167])
	(using TLSv1.2 with cipher ECDHE-RSA-AES128-GCM-SHA256 (128/128 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 5B7CD4A7CA4
	for <linux-nfs@vger.kernel.org>; Wed, 16 Sep 2026 22:31:00 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=74.125.231.167
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1789597868; cv=none; b=RSIYCQJPsbkUOm3o4zj6ppwpX+arvgmtowRKmY9YZTi4b/4MUTMz+tntAygKBNo0GbaWb7RhAVzZ0ANKVhq37jGo1MafXz1g9bzuH8GLQH2KlU8PUT6JRnI+qLgD3B0QStARNMyT6YuuAw5rDH9l5tP2pyXbcg0wYKmvHWonexg=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1789597868; c=relaxed/simple;
	bh=yERu/wvnybcug10P5T2Rm2UCtXfDlhuUZzFjyyBVnqs=;
	h=Message-ID:Date:MIME-Version:Subject:To:Cc:References:From:
	 In-Reply-To:Content-Type; b=I5AppMNsqkKAHF6gZnXZLF0+DRLkcBdrLz+bkWroWpZePsOamYtQ84K/H4nti3NmJA4kBhWnB69BBGAR2Ysa9Rj8bxytGjD/HxH4Wi5NJaO+JmsHp+WP1ghC/56WoapvMD7CUMH0ksTAquW7oVUZmUrQHO7xH8Fx3MDKVqvLQgU=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dmarc=pass (p=none dis=none) header.from=gmail.com; spf=pass smtp.mailfrom=gmail.com; dkim=pass (2048-bit key) header.d=gmail.com header.i=@gmail.com header.b=fD8rAM2R; arc=none smtp.client-ip=74.125.231.167
Authentication-Results: smtp.subspace.kernel.org; dmarc=pass (p=none dis=none) header.from=gmail.com
Authentication-Results: smtp.subspace.kernel.org; spf=pass smtp.mailfrom=gmail.com
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=gmail.com header.i=@gmail.com header.b="fD8rAM2R"
Received: by mail-oo2-f39.google.com with SMTP id 006d021491bc7-6b1ae736c63so104475eaf.1
        for <linux-nfs@vger.kernel.org>; Wed, 16 Sep 2026 15:30:59 -0700 (PDT)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=gmail.com; s=20251104; t=1789597856; x=1790202656; darn=vger.kernel.org;
        h=content-transfer-encoding:content-type:in-reply-to:from:references
         :cc:to:content-language:subject:user-agent:mime-version:date
         :message-id:from:to:cc:subject:date:message-id:reply-to:content-type;
        bh=HMBMbABjeP9Oor79poghabOIjaEM4yE3fhNYDP78qZ4=;
        b=fD8rAM2Rmm04yuNqAc2zuQ5lCz7nL+QqTi6DJPp/5bJyKDB/7/1Bt5DDIKa8qOMzYK
         tDSFy7jVDrGLA/nngFjm5uubxWohMur7JE+jpl9HeGE2rumJL7HgWd/1otmV0N2AcUK/
         PmyhLakVbvbdkOR616n/fNX6vz1pv4eVETW69SwPW2ZTwLOmJWRiXCwD4jgB04Nk03zY
         9FfjAotVmjngtgSWe3Fb0MofUdN/5gAZ03XSVzkywPWZWfkGEKR730Px0I4iDOOPG3+J
         5bmCacLy96gpeOFZRC3dYPewlvp+UMeIruxlhkXv0LAShX9nQthDGnSBEeIVjtEE4jf7
         QfDA==
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20260707; t=1789597856; x=1790202656;
        h=content-transfer-encoding:content-type:in-reply-to:from:references
         :cc:to:content-language:subject:user-agent:mime-version:date
         :message-id:x-gm-gg:x-gm-message-state:from:to:cc:subject:date
         :message-id:reply-to:content-type;
        bh=HMBMbABjeP9Oor79poghabOIjaEM4yE3fhNYDP78qZ4=;
        b=mmf7dHbFRN+i+sjGBFdewcC30hsG4ayjPq7SRJtJ/kG2PVxOO1lvXP/G4mjA0FZ83K
         kQ1fELANbfOpxFQ7OQS5IaWI05zjHPO8ZwgpRbW9uBLFtz/rIfDv/N7Zo6YIHwmF3TJi
         LnRfJEnRaVw8Ju0u58FCQT4FLTOTz4UJ/RwurqUDwWjFLxKEvH6Y58S7/A9rSvD3zFgA
         EnO0v7f62yZDf2B1HjEZp7u/nEPX8JSzhZ9/QDhEEJ8f3CqXSmMqPbgw7G7Z+SaX4jEL
         14lBrMwp7pxrv2I1xrCqw6sItArayr8Uun/GyDzJ7/+YT3mSrLgoYa5L+kWlQyQKsFgj
         yuhg==
X-Gm-Message-State: AFuF++m70fBbjGlUdApulsCuO4H/KYkY3JrBdbOmdbqsCetmyabXaf8G
	s/HjLirrVUo88fQLgcCOlDuGt5Se+wr0VekQzF2V/tZpDCVr7v+QTiS0
X-Gm-Gg: AYBFou3Ovgy1cB92jvJN8ypUoBrOl7gQbT3PHsRyHawUTX6U5cB6l5oxGCnpSPZ0Zs0
	6+pavGFDPhq1NAUnzxc0B2bhH45gTxxChubIFIm6T7iy4p/h0T5Ef9okx93HbPmiMI5OUR6ykE8
	jPxpRz8JOvh/qiaZ8EDc4aZ6mroe/u+G71jlGfcbG6Apgcs+ckNijjBJpvOa+Bmfb5N1F7Qvzs1
	52iQE5xE3Unl1EfRORwf2PLl34WyvERFt+rcYFxm1jY8ueg9hKfDkoG40UZVKPaZ9/q0D/Si23j
	Txygy8IJxnL1qhgIM3cHP11nlPNun+wUaHpE2qSIEOST+Xo0CU90V4uTEIC7h7S0TgsbYTYWB63
	Emw/OI/2fwEOM9NgXwNLBk0ysVJw1tjyuTtwf5vb9o8wHUnFYbTktHYURJnhSV2x4nfGlHW6KuH
	jJIDyYuT0ZZyDtNXzrYbdnjmgfjljSoszf8h9lLPORW4GQAR5CY+UwY+YxgJSCJrCk9uLJ25pPk
	svP0wbGhaMKP7aPrJZOU+PPkXxuDqqVlAmbJcQ0Kn4uEDj0aV94nxvR5vqJ/tpYyj+A22E1uyQC
	U/a7410=
X-Received: by 2002:a05:6820:60c:b0:6b1:9f9d:79f3 with SMTP id 006d021491bc7-6c7d0de78d6mr4639749eaf.17.1789597855729;
        Wed, 16 Sep 2026 15:30:55 -0700 (PDT)
Received: from ?IPV6:2600:1700:73d0:8030:9c73:7120:39bc:bc57? ([2600:1700:73d0:8030:9c73:7120:39bc:bc57])
        by smtp.gmail.com with ESMTPSA id a92af1059eb24-14395d5d0f3sm8825329c88.12.2026.09.16.15.30.55
        (version=TLS1_3 cipher=TLS_AES_128_GCM_SHA256 bits=128/128);
        Wed, 16 Sep 2026 15:30:55 -0700 (PDT)
Message-ID: <ff747b30-2537-4ee0-b827-beb0b7c2b323@gmail.com>
Date: Wed, 16 Sep 2026 15:30:54 -0700
Precedence: bulk
X-Mailing-List: linux-nfs@vger.kernel.org
List-Id: <linux-nfs.vger.kernel.org>
List-Subscribe: <mailto:linux-nfs+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:linux-nfs+unsubscribe@vger.kernel.org>
MIME-Version: 1.0
User-Agent: Mozilla Thunderbird
Subject: Re: issues with Linux client pNFS
Content-Language: en-US
To: Anna Schumaker <anna.schumaker@oracle.com>,
 Olga Kornievskaia <aglo@umich.edu>, Trond Myklebust <trondmy@hammerspace.com>
Cc: linux-nfs <linux-nfs@vger.kernel.org>
References: <41ee5118-027b-4630-8f02-b3a67c61b328@gmail.com>
 <6880c031-3936-4ea1-86f2-5dc6050c9051@oracle.com>
From: marc eshel <eshel.marc@gmail.com>
In-Reply-To: <6880c031-3936-4ea1-86f2-5dc6050c9051@oracle.com>
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 7bit

Hi,

I was just trying pNFS recall any but it look like the NFS client 
received but ignored the call, is that expected ?

[287100.214040] NFS: RECALL_ANY callback request from 10.11.96.99
[287100.214073] nfs4_callback_recallany: exit with status = 0

Thanks, Marc.

On 9/16/24 1:33 PM, Anna Schumaker wrote:
> Hi Marc,
>
> On 9/16/24 4:27 PM, marc eshel wrote:
>> Hi,
>>
>> Who is the current maintainer of the Linux NFS client?
> That would be me and Trond.
>
>> I have an issue with the way pNFS client is distributing the reads among the DSs and I can provide the traces if anyone cares.
> What is the problem? And sure, send along the traces! I'll try to take a look as soon as I can.
>
> Anna
>
>> Thanks, Marc.
>>
