Received: from us-smtp-delivery-124.mimecast.com (us-smtp-delivery-124.mimecast.com [170.10.133.124])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 681974BEE5E
	for <linux-nfs@vger.kernel.org>; Sat, 12 Sep 2026 15:31:55 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=170.10.133.124
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1789227116; cv=none; b=Hp7N9HEik0AwRxnwKqsHfTIt+atoZNwcTbBdA7d427DS5o5BZPUNA5v3lHGlmIYADDpbL2d5eeZkxnKPshhRwejMwJARRrilhgVyEzP5zs9Z0AQgh7KHdhoWYjfIzywcgFhOsCSvO2IBcHepWbCYka706/U8B26aYtmXLbWuHAY=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1789227116; c=relaxed/simple;
	bh=waDtqor00ivUS/FUxM9do2EXFOYSH+ErmqzWsplr6yI=;
	h=Message-ID:Date:MIME-Version:From:Subject:To:Cc:Content-Type; b=Hd9qu+ADm2ER6mx4ZKqbR4aPcPB6wWfbAfWOSVv9AC5ciM6phlE2hUR5nyxAVJYCOk4GtU7JUYA3vQxuNz7HgG03PSskUNe9//M2DBuv2pf6SAQjIsFxqd5LoEKXVDBoKKgaGHILbZensJnu34lrmgiW2qqwBYPMMxTScg0I2kw=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dmarc=pass (p=quarantine dis=none) header.from=redhat.com; spf=pass smtp.mailfrom=redhat.com; dkim=pass (1024-bit key) header.d=redhat.com header.i=@redhat.com header.b=KyOWOu0h; dkim=pass (2048-bit key) header.d=redhat.com header.i=@redhat.com header.b=ZGlnlEjs; arc=none smtp.client-ip=170.10.133.124
Authentication-Results: smtp.subspace.kernel.org; dmarc=pass (p=quarantine dis=none) header.from=redhat.com
Authentication-Results: smtp.subspace.kernel.org; spf=pass smtp.mailfrom=redhat.com
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (1024-bit key) header.d=redhat.com header.i=@redhat.com header.b="KyOWOu0h";
	dkim=pass (2048-bit key) header.d=redhat.com header.i=@redhat.com header.b="ZGlnlEjs"
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=redhat.com;
	s=mimecast20190719; t=1789227114;
	h=from:from:reply-to:subject:subject:date:date:message-id:message-id:
	 to:to:cc:cc:mime-version:mime-version:content-type:content-type:
	 content-transfer-encoding:content-transfer-encoding;
	bh=tZHZIr8nt1xjTkUQonIeH2+sNdcuc3AFD+c39WFtFCs=;
	b=KyOWOu0homSXUAF2i/IYETql43fy46qQghDElpT6WMM9AMkTdZwPjRSdmpKNl9Mbxw2VFg
	vC3xUYQmfMK+BIirsrYB379UIaPzHQjGA4cwCFnxZu/7GviydLa+1x2rnonB+z6KzlNjX4
	t7sA1HCkAHlyicHFWJFUplsU5Cxi1XU=
Received: from mail-oa1-f70.google.com (mail-oa1-f70.google.com
 [209.85.160.70]) by relay.mimecast.com with ESMTP with STARTTLS
 (version=TLSv1.3, cipher=TLS_AES_256_GCM_SHA384) id
 us-mta-354-7ywj8mgwOs6g2F4gs_F0Wg-1; Sat, 12 Sep 2026 11:31:52 -0400
X-MC-Unique: 7ywj8mgwOs6g2F4gs_F0Wg-1
X-Mimecast-MFC-AGG-ID: 7ywj8mgwOs6g2F4gs_F0Wg_1789227112
Received: by mail-oa1-f70.google.com with SMTP id 586e51a60fabf-456ab1a7f2cso2745540fac.3
        for <linux-nfs@vger.kernel.org>; Sat, 12 Sep 2026 08:31:52 -0700 (PDT)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=redhat.com; s=google; t=1789227112; x=1789831912; darn=vger.kernel.org;
        h=content-transfer-encoding:content-type:content-language:cc:to
         :subject:from:user-agent:mime-version:date:message-id:from:to:cc
         :subject:date:message-id:reply-to:content-type;
        bh=tZHZIr8nt1xjTkUQonIeH2+sNdcuc3AFD+c39WFtFCs=;
        b=ZGlnlEjsO9rEBSPvXE++VI1AP77uFLVq1pxMup2gHrNDCvnsbidfEYVbqqFLohmPS6
         U6L3EdXu0b2nm++JCpFqJw36G8fDIUjTG9RwvbNt5LArFIJJKn0oyy4AIAV6oDUnxZm5
         QxzWzvlWfooLQ10BUeciUGcZXC5cMSGkbnt5yCHctmOtifrjuxNILQaENqnz+YEumnxE
         w+j0R7LyxcP85UneK0Rst79ihxO1cCZRHkniF9rI5NN/LBV3iiVXEIju41OBD3FlObfe
         idSjh2R4WLKyqI+B/UY/Lom8+9u1LkZ1tukLMalrAiZTPhA2+FrYrMSFemuBEfQv2//5
         ztTQ==
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20251104; t=1789227112; x=1789831912;
        h=content-transfer-encoding:content-type:content-language:cc:to
         :subject:from:user-agent:mime-version:date:message-id:x-gm-gg
         :x-gm-message-state:from:to:cc:subject:date:message-id:reply-to
         :content-type;
        bh=tZHZIr8nt1xjTkUQonIeH2+sNdcuc3AFD+c39WFtFCs=;
        b=Q9HIK92Im5lz07ZnPIOT1UmzUqmD3bDWrBCLryk49QrdgR1FK3Qf5BalgipGJrNiO1
         Wi6IV/H5FIf/5VIllrhtTvFCEF99Poo42R8ChnovsZzAqfKDHJxhTldsh3Q9XgasyW+G
         CCwwAg9uoVTimwS7rpiQw62cbXpCJc5fRXGlfK/Lxez+fN+E6mcN3IT/y/t4axi8sL+9
         2hDhAKWCerGGJh6TSjcnzh+7xBBm087S0K2IHtcsEt2FQcCTT0xDKfHXTAUqqIrfxM4d
         RbFuojljeW5X88DGlbMSgzXvZ1THuUjMyDEQBnHhTKwSk+solLKr2/3T3BD6Cm96OAXQ
         8YnQ==
X-Gm-Message-State: AFuF++kHVnCh6EBSIRrYon7/PruyR+wrLDtxXgo7gM0zcRoHQh5668XF
	AC8Alr2I93LdIDiAJFiuf5Ee2xxFQeD2kHNxtxNWPqMbyMyQO4vK9XYUKUBPeKYAk2pNpYhILqh
	nJHTP193VhK+AJ6HAHS2sZuSmBihjnL6PVmyyo0OxACYGTdTTHe3TNIGOzdDSv+IqAwRt+g==
X-Gm-Gg: AYBFou3ERVStSd27IKaog7AKElbX+doNun7lF9kLIWb0UuaKG6/FKiRAqpWXDDzanEM
	mNmPRmMGo8F1ET4JVyVu8QKcFKCcvfRfzGBQbbXb/a4ugfc6gZtQ6Ss+cNpMk+mlgCkTA8Ars/8
	9ZNgby8HX0hTgoNI2FD2SJfd9KfBC/Y6y5h28nMPQEpHpcXajHbApt6Z0gX/fW559rGeldotgEN
	ZhZex4ZXtUyLa1ZAqXkL/WOdGK/piyxlFIdXmfNyxY7Ad5lSsqqd0pYlAuFckX7cDbfqH5qTcgO
	9ccGxCbnkRgjglHXsEDLsVXB+0YHP+hB8XQG0X0B1uijKSg6vc+CW4IjJpG7vBfFEty+xBhh3hQ
	=
X-Received: by 2002:a05:6808:4f26:b0:4c2:63b:e5f6 with SMTP id 5614622812f47-4c319d49dd9mr8021002b6e.19.1789227112064;
        Sat, 12 Sep 2026 08:31:52 -0700 (PDT)
X-Received: by 2002:a05:6123:45:b0:5c6:64ac:d6f3 with SMTP id 71dfb90a1353d-5c8462832a9mr3225923e0c.3.1789227085060;
        Sat, 12 Sep 2026 08:31:25 -0700 (PDT)
Received: from [172.31.1.12] ([70.105.240.165])
        by smtp.gmail.com with ESMTPSA id 6a1803df08f44-9120f4dd2f2sm49326926d6.44.2026.09.12.08.31.24
        (version=TLS1_3 cipher=TLS_AES_128_GCM_SHA256 bits=128/128);
        Sat, 12 Sep 2026 08:31:24 -0700 (PDT)
Message-ID: <d99e5b38-262d-49a3-998f-3650e52e5889@redhat.com>
Date: Sat, 12 Sep 2026 11:31:23 -0400
Precedence: bulk
X-Mailing-List: linux-nfs@vger.kernel.org
List-Id: <linux-nfs.vger.kernel.org>
List-Subscribe: <mailto:linux-nfs+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:linux-nfs+unsubscribe@vger.kernel.org>
MIME-Version: 1.0
User-Agent: Mozilla Thunderbird
From: Steve Dickson <steved@redhat.com>
Subject: ANNOUNCE: rpcbind-1.3.1 released.
To: libtirpc <libtirpc-devel@lists.sourceforge.net>
Cc: Linux NFS Mailing list <linux-nfs@vger.kernel.org>
Content-Language: en-US
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 7bit

This release contains:
     - Full tuning off remote calls when --enable-rmtcalls is not set
     - Restrict RPCBPROC_GETSTAT to loopback callers
     - A couple buffer overflow fixes.

Both the tarball and change log can be found at
   http://sourceforge.net/projects/rpcbind

The git tree was moved to:
    git://linux-nfs.org/~steved/rpcbind.git

Please send comments/bugs to linux-nfs@vger.kernel.org and/or
libtirpc-devel@lists.sourceforge.net

steved.

