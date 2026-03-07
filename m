Received: from us-smtp-delivery-124.mimecast.com (us-smtp-delivery-124.mimecast.com [170.10.129.124])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 412DD2F7462
	for <linux-nfs@vger.kernel.org>; Sat,  7 Mar 2026 20:39:37 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=170.10.129.124
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1772915978; cv=none; b=X54QuykvGzCXLTcUY5sJ568t7Ny/nGrKOy7PG7T4a07YLg0FJ/wH3EcGGgqf0UIm2hrQ9JtvwxoGBju3CX1KTSlkXGt5LhCddDp2ia/l75UWXHSfsjU94CDT8qqYqg/D7bYDfsUKWBELnBX16fVaVPO+ugrQRjULWLs+fSeq1ww=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1772915978; c=relaxed/simple;
	bh=1wNXwrUo3UJjkzs5KJCShM2dOrnW6rmk1ulLrPJOqAU=;
	h=Message-ID:Date:MIME-Version:From:Subject:To:Cc:Content-Type; b=DfMOWptt1PHgrAZVgJO3FBCi5wr9Q9V65uNbXpu8gEyCEdTZ8sg2LhCeqcHb0fIOfSGseIu+V/7rKnq6Ca2M1qe/RgOcGbZJigLaZG2AqxV14bDGulQTe8TiiGECZWVRDdCcAeFTg5+IArdMmHnkVdtKtiiyEB5cx1QTux9yf7I=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dmarc=pass (p=quarantine dis=none) header.from=redhat.com; spf=pass smtp.mailfrom=redhat.com; dkim=pass (1024-bit key) header.d=redhat.com header.i=@redhat.com header.b=FFb6uIx5; dkim=pass (2048-bit key) header.d=redhat.com header.i=@redhat.com header.b=K4tA227I; arc=none smtp.client-ip=170.10.129.124
Authentication-Results: smtp.subspace.kernel.org; dmarc=pass (p=quarantine dis=none) header.from=redhat.com
Authentication-Results: smtp.subspace.kernel.org; spf=pass smtp.mailfrom=redhat.com
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (1024-bit key) header.d=redhat.com header.i=@redhat.com header.b="FFb6uIx5";
	dkim=pass (2048-bit key) header.d=redhat.com header.i=@redhat.com header.b="K4tA227I"
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=redhat.com;
	s=mimecast20190719; t=1772915976;
	h=from:from:reply-to:subject:subject:date:date:message-id:message-id:
	 to:to:cc:cc:mime-version:mime-version:content-type:content-type:
	 content-transfer-encoding:content-transfer-encoding;
	bh=T9OxiP3l3t/dSfco7PULw7gMtUpegbGKrMUBctUMchM=;
	b=FFb6uIx5kS7ctTahWPukZ5iL4WPM92b4kqn3koNSKTBW5AwSxKfrZSKngC65t6wbCcuHdk
	JDF1XDDIxmN1SqVHz493wKPVsvCQnuOsXdR8kGgICfBFGF7zvT3cw3WkbRAzgUJfYE6mlA
	wj07Sgl6X0m+mX+wZIwwp7tnjhQafMs=
Received: from mail-qv1-f71.google.com (mail-qv1-f71.google.com
 [209.85.219.71]) by relay.mimecast.com with ESMTP with STARTTLS
 (version=TLSv1.3, cipher=TLS_AES_256_GCM_SHA384) id
 us-mta-459-O1nouLYmNQuJBU4gc7ksOQ-1; Sat, 07 Mar 2026 15:39:35 -0500
X-MC-Unique: O1nouLYmNQuJBU4gc7ksOQ-1
X-Mimecast-MFC-AGG-ID: O1nouLYmNQuJBU4gc7ksOQ_1772915974
Received: by mail-qv1-f71.google.com with SMTP id 6a1803df08f44-8950562d351so977718946d6.3
        for <linux-nfs@vger.kernel.org>; Sat, 07 Mar 2026 12:39:35 -0800 (PST)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=redhat.com; s=google; t=1772915973; x=1773520773; darn=vger.kernel.org;
        h=content-transfer-encoding:content-language:cc:to:subject:from
         :user-agent:mime-version:date:message-id:from:to:cc:subject:date
         :message-id:reply-to;
        bh=T9OxiP3l3t/dSfco7PULw7gMtUpegbGKrMUBctUMchM=;
        b=K4tA227IdFgBbZ9kxBUSZmaCbTXTp1GXLoSbJCEkK/o8pry0gnijLUTHuHJDt0iSYP
         k8Gvkc7/Pw7qPtyZSyn31Tr6Man8RCN6H51LaZmm0rrWOHoQKmJFxavTXrxloGq6+ZEB
         UmP6bcFVRig5IKIUZKH/PyHAGh7ppUizLOCHoThp1kxvVZsk+bqLttLDA44mZF8gqAXH
         V2wDqpVJFPjzAv0zapNhyJm+cDcEbDpVC6byDfBJmETjI7Xvh8sgONykYGuAcHOFzLQj
         fbMkzDwvUj3yc0aGRZAujs11KseidZrVoZMDvgF8xnItmhCkz7aXy7CoiyVLpvsYqXls
         vvsA==
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20230601; t=1772915973; x=1773520773;
        h=content-transfer-encoding:content-language:cc:to:subject:from
         :user-agent:mime-version:date:message-id:x-gm-gg:x-gm-message-state
         :from:to:cc:subject:date:message-id:reply-to;
        bh=T9OxiP3l3t/dSfco7PULw7gMtUpegbGKrMUBctUMchM=;
        b=pctkZFhJ+z5XJ67Spk6vZ1DNv2BFPv1cQWn4LSmYptVDjl5qS/PlboivJFhPfmpcs7
         LcEQWkKIhtnO8IqaghoV5o9mBHdcBKVrWw6jtWn84XDCWgHbC9n7CSYbp8+Vq2avhFHb
         3Rd5mGqScAI2zIty9mD3sId6sp1hrLAJlreJb4DgF7hyOK2H8ZU7DLTv+N8BIgWddhgA
         NcOpSeBUskPdrCOuLik/gWMfxfdxoCEEu/R4HIS/4fERJzPqi2j4rXHvHn+D4/huSI5r
         EcbfzYEz2a7du2KzaEt1NItIs2PH/IbQ8BmiS4vVtSjPyh6L7IHmuX4v/KTW0U1J0D+V
         CVWA==
X-Gm-Message-State: AOJu0YxGoQt3Uv/+Z+vzkzBjm6f8x5ELbNqzoIMPeuR6GK5s5BDyO690
	WK+2z0iMPrTuAsuPoD5dIOPxGmocNeQZlHH4Qbu4aHg1SbdjcOdhhOpck3uAEGq8QLRTct34Hev
	TqTlgWt0h9GW1rOhYfhM7OCTQXit32JoljVn00VDJFfQdFir9Gj3w0Mg1V6R90FDA+QDOpKReS0
	1BjsgFIaCZcIWuFwtyK/ZSdexhcX4RKf0InPUCbF4jOuM=
X-Gm-Gg: ATEYQzzbJxiKta5ta3RocPOy7tbotmwrjSC12+prVZDDT9yJTF45gAGfd5FHY6/9zoc
	YhG24wkPRI6eZa7etxpq378G4BkhmhW4nj0kvLb0GqchB9Wmu8ykmXjALYRRnd3svUNnPZhxjwF
	BPSRXQT8ZXTP78wPhATmDDt9zj84Q1x6gBuzSUBOhsVbsJUqeDULJoVmtv1yDAgyzYJIPlpFc3D
	Ryy+ssQQ3qB1S3k61nGck4wdlQONF2njlHaCjy7+93I6SuRjN+LS7rGH/8NxaicB+OVs0PbCU1d
	UWTqGnpO+px2i5ZMJVsjiVY2If9DZX11m9uaYNv2Bc6fVh/UGaGiZLwWB9Epc/RHZoIPNRQY3vX
	Jf0UAAEzoB1UsNicMC8aK
X-Received: by 2002:a05:620a:2946:b0:8c6:a8a6:e164 with SMTP id af79cd13be357-8cd6d4b504cmr848458885a.45.1772915972834;
        Sat, 07 Mar 2026 12:39:32 -0800 (PST)
X-Received: by 2002:a05:620a:2946:b0:8c6:a8a6:e164 with SMTP id af79cd13be357-8cd6d4b504cmr848457185a.45.1772915972417;
        Sat, 07 Mar 2026 12:39:32 -0800 (PST)
Received: from [172.31.1.12] ([70.105.240.20])
        by smtp.gmail.com with ESMTPSA id af79cd13be357-8cd6f56da77sm389027585a.44.2026.03.07.12.39.31
        (version=TLS1_3 cipher=TLS_AES_128_GCM_SHA256 bits=128/128);
        Sat, 07 Mar 2026 12:39:31 -0800 (PST)
Message-ID: <4d58bf28-a3e0-4496-bae8-05387da27054@redhat.com>
Date: Sat, 7 Mar 2026 15:39:30 -0500
Precedence: bulk
X-Mailing-List: linux-nfs@vger.kernel.org
List-Id: <linux-nfs.vger.kernel.org>
List-Subscribe: <mailto:linux-nfs+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:linux-nfs+unsubscribe@vger.kernel.org>
MIME-Version: 1.0
User-Agent: Mozilla Thunderbird
From: Steve Dickson <steved@redhat.com>
Subject: ANNOUNCE: nfs-utils-2.8.6 released.
To: Linux NFS Mailing list <linux-nfs@vger.kernel.org>
Cc: "linux-fsdevel@vger.kernel.org" <linux-fsdevel@vger.kernel.org>
Content-Language: en-US
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 7bit

Hello,

This release contains the following:

     * CVE-2025-12801 resolved
     * gssd improvements.
     * nfsrahead updates.
     * nfsdctl fixes.
     * A number of other bug fixes.

The tarballs can be found in
   https://www.kernel.org/pub/linux/utils/nfs-utils/2.8.6/
or
   http://sourceforge.net/projects/nfs/files/nfs-utils/2.8.6

The change log is in
https://www.kernel.org/pub/linux/utils/nfs-utils/2.8.6/2.8.6-Changelog
or
  http://sourceforge.net/projects/nfs/files/nfs-utils/2.8.6/2.8.6-Changelog

The git tree is at:
    git://linux-nfs.org/~steved/nfs-utils

Please send comments/bugs to linux-nfs@vger.kernel.org

steved.

