Received: from us-smtp-delivery-124.mimecast.com (us-smtp-delivery-124.mimecast.com [170.10.133.124])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 6F6424BCADF
	for <linux-nfs@vger.kernel.org>; Wed, 29 Jul 2026 14:28:12 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=170.10.133.124
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1785335294; cv=none; b=tZlPg+icX/HzgRcIqdMMn7+UtvwuVvUlVCVDh5haZGz8vv+dm7ZIFAjp1Lw/G4G1k3Vc5AqT39GXqQ064rD1WMtOcZti//M2vCtkCNkE3v03sKI6l0gt03/cRG1/5XBpWRis23llymdB2gMp7OQGlKqRV2H7Szuvv6+HQCgKFtw=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1785335294; c=relaxed/simple;
	bh=+ErPDlVZblZibFShKcxn5UgTNOCXIxQNPxLF9T8ZPtM=;
	h=Message-ID:Date:MIME-Version:From:Subject:To:Cc:Content-Type; b=NfbcdS57nCOt8AtMDi6JKy/GBT+xL6rrjeK7omtFQZg8EGcH1/+M8XxZdQX3Udf1GYhOJEFfXWKmfZ0SbyRvrVr9CvTG5WTbmYVvV/c1o7zJSiq6V8cJWzAcxT5+k9rf1JV9iMxgwhxf9MikT8mlablRn2ZR/K4E9qivRQXkP6I=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dmarc=pass (p=quarantine dis=none) header.from=redhat.com; spf=pass smtp.mailfrom=redhat.com; dkim=pass (1024-bit key) header.d=redhat.com header.i=@redhat.com header.b=dUuFFD+x; dkim=pass (2048-bit key) header.d=redhat.com header.i=@redhat.com header.b=QOdzqYrv; arc=none smtp.client-ip=170.10.133.124
Authentication-Results: smtp.subspace.kernel.org; dmarc=pass (p=quarantine dis=none) header.from=redhat.com
Authentication-Results: smtp.subspace.kernel.org; spf=pass smtp.mailfrom=redhat.com
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (1024-bit key) header.d=redhat.com header.i=@redhat.com header.b="dUuFFD+x";
	dkim=pass (2048-bit key) header.d=redhat.com header.i=@redhat.com header.b="QOdzqYrv"
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=redhat.com;
	s=mimecast20190719; t=1785335291;
	h=from:from:reply-to:subject:subject:date:date:message-id:message-id:
	 to:to:cc:cc:mime-version:mime-version:content-type:content-type:
	 content-transfer-encoding:content-transfer-encoding;
	bh=EGak2HM83KvOa4m0yEIRICa7eaSA5C6mu7yl+7kc2TU=;
	b=dUuFFD+xw4A36dGQE2JqLTO9lyj3u4NHA+5NsGEQSCJBW0/oReHzBMj79l9vmyDAGP0rl2
	dshyOJf8oJ7NVYjeTV2JTMsh4AU32rp7fnlYTEFuoLMsO93wl8111nCbLy1nJFnxmAbcxl
	0HbcKtuBxa3EQ8nW01Gnu32Akwhours=
Received: from mail-ej1-f69.google.com (mail-ej1-f69.google.com
 [209.85.218.69]) by relay.mimecast.com with ESMTP with STARTTLS
 (version=TLSv1.3, cipher=TLS_AES_256_GCM_SHA384) id
 us-mta-94-v0oZ2XunP826k65EVL9jVg-1; Wed, 29 Jul 2026 10:28:08 -0400
X-MC-Unique: v0oZ2XunP826k65EVL9jVg-1
X-Mimecast-MFC-AGG-ID: v0oZ2XunP826k65EVL9jVg_1785335287
Received: by mail-ej1-f69.google.com with SMTP id a640c23a62f3a-c1686e23b9cso89199366b.0
        for <linux-nfs@vger.kernel.org>; Wed, 29 Jul 2026 07:28:08 -0700 (PDT)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=redhat.com; s=google; t=1785335287; x=1785940087; darn=vger.kernel.org;
        h=content-transfer-encoding:content-type:content-language:cc:to
         :subject:from:user-agent:mime-version:date:message-id:from:to:cc
         :subject:date:message-id:reply-to:content-type;
        bh=EGak2HM83KvOa4m0yEIRICa7eaSA5C6mu7yl+7kc2TU=;
        b=QOdzqYrvcBDZItcawKA2gXEbi3xur3wWOcHJpcxJx91boXxW1haR3V1TCZAtZC++No
         VWW5DFxP4Q2I7UePksigdle4PIHfMqRea0uDkJsONXBwkIE8ByZHRJscgRRfwikUyDoh
         e95wrDLMg6Lh3LznTjt3E1Dee9kZlIVyjhNVO4Di/4a/7ZcCNssBbNGYzRzxVAcBO+vi
         wUIBwZKDQMZYclx9aPBzWurFfy0k13gzz7rptAa93arjYAljXv/jXINdodwOsYI+VmKw
         Q35Q1i/HzUiR//Aw4oPtV2OOXlJupqdXah+vMY928RtCJQJsO49spVzAnummBzfkaj8l
         Og/Q==
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20251104; t=1785335287; x=1785940087;
        h=content-transfer-encoding:content-type:content-language:cc:to
         :subject:from:user-agent:mime-version:date:message-id:x-gm-gg
         :x-gm-message-state:from:to:cc:subject:date:message-id:reply-to
         :content-type;
        bh=EGak2HM83KvOa4m0yEIRICa7eaSA5C6mu7yl+7kc2TU=;
        b=Gk3yXNaycgI8SJrr1y5Nqpun55YRTyD67jxlUMzpIv++jV9Sxy0t/QL1MO4+lhiSFh
         5e5w61NKXVwf3/mWneiw158a7OyhedkW9TYkLST3mO6n+2I+PxdjfiQiowsyoFyvad57
         5KbuXKf6/5qv4O9CFTLlAbQkeTo3VCKKJ/LIPQKH+1pMK+ETFR6p2Ro9ZgAMhVtLF84L
         BL30ErUaEYpRxLuF16wKIlTbnoKzz36Pze1j/dDGOC0VqONIaG+z39xjm8UzO/CqpNMx
         erlkIuuBAhaxZNiNtoJ5FXQyiWUDqdnqCItIv80NuFC7z/hLWixzWYtWHoE0ZBcHohE6
         TDLw==
X-Gm-Message-State: AOJu0Yy/BgUOOA2/BWAtYdcE3crINg0TCbbTAvMkYlrSX7mo8XR9q1qq
	8DdayrsQ5WajcgX7FbRq4HosmMaaFqb13KKuotFUfGftViQLJ8gBOZNU7fgU7J3FvonPWaDxV3S
	4aQX106ThXUrgNof9xHn69ySgSaztda6iuhrBrR9kBElMxkSV33VwQ5h4QZKcjUq0jT2EaXGmk4
	WdOc3B2LL2kbCEBst1HGpSD//iLMBLTGJorXN6JScyax0=
X-Gm-Gg: AR+sD11RebLynpBkD7TzQDWx/edAn1EIOE+Fd3tDVTCpj5nfHPEdNOnnVnI0Dh7lkeO
	Q6Y9sWFPD/nAZonr47fWe/lWaAKnHpqQtKOCFHTr2p7cUUg/DYaCQfhvOI4ISE7v2SNMEx5vQqU
	CElYUk6RybgOe+I5ZcFxlCG5jxKWVarfRjF9e1MiNCbXxjnjimWy3aIef8nlyhWbC0YcJTYj17g
	Gu1vF8uReHgCDnyx/A6U6viT0INKtzWPUFBmn6evv8EdJ1aMWRuDNMrgZ+GseQ6RJdfHcj3UdaU
	h/cVjADA8GOUDQ7K/CeIDraCLl2jaaiF7u0Cw+0dh5RY27PZs+AZEPpL4s1Cr4lhsQJrtWKkvMM
	s
X-Received: by 2002:a17:906:f583:b0:c12:1651:17b2 with SMTP id a640c23a62f3a-c1f71e900c0mr379746766b.9.1785335286824;
        Wed, 29 Jul 2026 07:28:06 -0700 (PDT)
X-Received: by 2002:a17:906:f583:b0:c12:1651:17b2 with SMTP id a640c23a62f3a-c1f71e900c0mr379744266b.9.1785335286365;
        Wed, 29 Jul 2026 07:28:06 -0700 (PDT)
Received: from [172.31.1.12] ([70.105.250.248])
        by smtp.gmail.com with ESMTPSA id 4fb4d7f45d1cf-6a050c49f7dsm957349a12.18.2026.07.29.07.28.04
        (version=TLS1_3 cipher=TLS_AES_128_GCM_SHA256 bits=128/128);
        Wed, 29 Jul 2026 07:28:05 -0700 (PDT)
Message-ID: <dc0f6f41-84be-4a70-92db-89890bded3ab@redhat.com>
Date: Wed, 29 Jul 2026 10:28:04 -0400
Precedence: bulk
X-Mailing-List: linux-nfs@vger.kernel.org
List-Id: <linux-nfs.vger.kernel.org>
List-Subscribe: <mailto:linux-nfs+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:linux-nfs+unsubscribe@vger.kernel.org>
MIME-Version: 1.0
User-Agent: Mozilla Thunderbird
From: Steve Dickson <steved@redhat.com>
Subject: ANNOUNCE: nfs-utils-2.9.2 released.
To: Linux NFS Mailing list <linux-nfs@vger.kernel.org>
Cc: "linux-fsdevel@vger.kernel.org" <linux-fsdevel@vger.kernel.org>
Content-Language: en-US
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 7bit

Hello,

This is a fairly large release...

A number of memory leaks fixed (from AI)
A number of netlinks fixes/enhances
A number of exportfs fixes/enhances
A new nfs-iostat option
A number of gcc/warnings fixes

The tarballs can be found in
   https://www.kernel.org/pub/linux/utils/nfs-utils/2.9.2/
or
   http://sourceforge.net/projects/nfs/files/nfs-utils/2.9.2

The change log is in
https://www.kernel.org/pub/linux/utils/nfs-utils/2.9.2/2.9.2-Changelog
or
https://sourceforge.net/projects/nfs/files/nfs-utils/2.9.2/2.9.2-Changelog

The git tree is at:
    git://linux-nfs.org/~steved/nfs-utils

Please send comments/bugs to linux-nfs@vger.kernel.org

steved.

