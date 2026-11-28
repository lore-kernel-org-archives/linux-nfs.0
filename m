Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.remote-ip=170.10.133.124
ARC-Seal: i=1; d=subspace.kernel.org; s=arc20261015; a=rsa-sha256; cv=none;
	t=1795824716;
	b=3WRgHyXMP4yw3WbxAjPpjJrfpbe0BttH1eQ0TxxFluyeA/MW8TM8/zHatqlzu1QrxVxd
	 nV0tKAD9JkzIM4MiyVJqu6tMgj6d24flTl45cwEj2U06r7zeTh45emU7X3XK6eLIIMJDb
	 kcDb6lWbIw65x2PnoVRMlsCocZ9mBNAkuOW70of5bYRyOq0Cxc39PE9zzYzGeH6EmBx46
	 K1fVpi1ZutWrel+KvFdGoYHEyCN1IUYaB0j/au0Xaf+9jDgLb2Cx81JJAxnllRZhPMVep
	 4zKH8gHVm8aXgQ8LIlXazBsFmW7IRgaug3twSHWAmapa8qZZucHKUbJDmBlbyAjWqZg==
ARC-Message-Signature: i=1; d=subspace.kernel.org; s=arc20261015;
	a=rsa-sha256; c=relaxed/relaxed; t=1795824716;
	h=DMARC-Filter:DKIM-Signature:Received:X-MC-Unique:
	 X-Mimecast-MFC-AGG-ID:Received:DKIM-Signature:X-Google-DKIM-Signature:
	 X-Gm-Message-State:X-Gm-Gg:X-Received:X-Received:Received:Message-ID:
	 Date:MIME-Version:User-Agent:Subject:From:To:Cc:References:
	 Content-Language:In-Reply-To:Content-Type:Content-Transfer-Encoding;
	bh=9otkCcCpQCAi7y4HrqDFDPtYryM9TNy2e/+Khy/s/4A=;
	b=kIs+q5e+WfIqnEG6dl3IDsac+KhrCc/1pFgu85j+ViNXxnsxl+g8/UpoGXK7henzT0+K
	 PWUHYJyKjdJsN5tn9VcfEkPPsZbBJsXwwHAznCpkzJVKMkPeDEh7GvpL0ORFgjmXSpXtc
	 /xPDfsPYG+DSHPeSvQjGmoXmWR03CsB0GTU0Um3mbAJUsUXx2y7QbXa7hdOr+cOlZQVsL
	 5FFwoJRo58Ku0O8lHXWUcUJwiO+glR/QIOEq+/WoxBtmVEkCKqLFRMzPcz7AepWViIHT0
	 bOKC+BSpS02Y/6JFc4xytMGO0OLr/jzDIriF6U5Lw1QuwhsRDB+77uZeH1C7AvDjXxw==
ARC-Authentication-Results: i=1; smtp.subspace.kernel.org; 
	dmarc=pass header.from=redhat.com;
	spf=pass smtp.mailfrom=redhat.com;
	dkim=pass header.d=redhat.com header.i=@redhat.com header.a=rsa-sha256 header.s=mimecast20190719 header.b=cM2Cesk0;
	dkim=pass header.d=redhat.com header.i=@redhat.com header.a=rsa-sha256 header.s=google header.b="fDrzR7/j";
	arc=none smtp.remote-ip=170.10.133.124
Received: from us-smtp-delivery-124.mimecast.com (us-smtp-delivery-124.mimecast.com [170.10.133.124])
	(using TLSv1.3 with cipher TLS_AES_256_GCM_SHA384 (256/256 bits)
	 key-exchange X25519 server-signature ECDSA (prime256v1) server-digest SHA256)
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 0473C606A31F
	for <linux-nfs@vger.kernel.org>; Sat, 28 Nov 2026 00:11:55 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.4.2 smtp.subspace.kernel.org 0473C606A31F
Authentication-Results: smtp.subspace.kernel.org; dmarc=pass (p=quarantine dis=none) header.from=redhat.com
Authentication-Results: smtp.subspace.kernel.org; spf=pass smtp.mailfrom=redhat.com
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (1024-bit key) header.d=redhat.com header.i=@redhat.com header.a=rsa-sha256 header.s=mimecast20190719 header.b=cM2Cesk0;
	dkim=pass (2048-bit key, unprotected) header.d=redhat.com header.i=@redhat.com header.a=rsa-sha256 header.s=google header.b=fDrzR7/j
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=redhat.com;
	s=mimecast20190719; t=1795824716;
	h=from:from:reply-to:subject:subject:date:date:message-id:message-id:
	 to:to:cc:cc:mime-version:mime-version:content-type:content-type:
	 content-transfer-encoding:content-transfer-encoding:
	 in-reply-to:in-reply-to:references:references;
	bh=9otkCcCpQCAi7y4HrqDFDPtYryM9TNy2e/+Khy/s/4A=;
	b=cM2Cesk0Mk6k7gDcutc4obSPoJ2GalnmTSQ62tXkoi6QSzQVyALp++v7YNPnzOuXmrE6oY
	9QDNmH+pj49aomap5JJxt7fT8ZRN8QB0cRrGmGHBaslamfzWfZy5ITXmzMRwG6JJTBLnPD
	phWbdtzcLiMM5rDo9sYnaVQYmK0PoSk=
Received: from mail-qv1-f72.google.com (mail-qv1-f72.google.com
 [209.85.219.72]) by relay.mimecast.com with ESMTP with STARTTLS
 (version=TLSv1.3, cipher=TLS_AES_256_GCM_SHA384) id
 us-mta-22-lZpPBcsONBCH6QWrVmRWYQ-1; Sat, 28 Nov 2026 00:11:52 +0000
X-MC-Unique: lZpPBcsONBCH6QWrVmRWYQ-1
X-Mimecast-MFC-AGG-ID: lZpPBcsONBCH6QWrVmRWYQ_1795824712
Received: by mail-qv1-f72.google.com with SMTP id 6a1803df08f44-920fb8b9859so86881896d6.2
        for <linux-nfs@vger.kernel.org>; Fri, 27 Nov 2026 16:11:52 -0800 (PST)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=redhat.com; s=google; t=1795824712; x=1796429512; darn=vger.kernel.org;
        h=content-transfer-encoding:content-type:in-reply-to:content-language
         :references:cc:to:from:subject:user-agent:mime-version:date
         :message-id:from:to:cc:subject:date:message-id:reply-to:content-type;
        bh=9otkCcCpQCAi7y4HrqDFDPtYryM9TNy2e/+Khy/s/4A=;
        b=fDrzR7/jCMJvR7J/bL0BJb69W4JSk0Rqa/4L9tZkteVqIx5rcQUgxDPREu2jIbu2OU
         Cb0DXW20MCzkZBaMxYOmEaQTGHoe4wYdymyzJz3ZYKgiAg+d5z+huzry1o1elO52PDT7
         eRClSbnGylyWqetM+8G4ffKCAg4EOx3OnXA/B/8+o+M2Z41SMPnO52/Zb3oukBQ2XCKX
         pELH6l7PTHZvYIJsj8AsZ3ptgLogRhNC7/HHS7p+ETFj7QbTj3EBCWz7aOdkPC94SfmQ
         Munz4OK7/M5by7k4ygiD99H0iWsiv/dMnCMdxNCIF639yjnR6gNZnoYT6JrJ54S4kDXf
         kXFw==
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20260707; t=1795824712; x=1796429512;
        h=content-transfer-encoding:content-type:in-reply-to:content-language
         :references:cc:to:from:subject:user-agent:mime-version:date
         :message-id:x-gm-gg:x-gm-message-state:from:to:cc:subject:date
         :message-id:reply-to:content-type;
        bh=9otkCcCpQCAi7y4HrqDFDPtYryM9TNy2e/+Khy/s/4A=;
        b=aZ1BwWBguBIn4H8oq/2+h3y4l5jgnyPmedrqGJq5oHnUJpJhO4qL9sHmwdQ4Br/xzS
         f1HmaGFdsgg2oqQsdI1zYqPWg29v4CkpFjIhfgwLaVRVDC/1iXe2j0B2SfSVQ9WDYgin
         TA7eInmzdJWvtNrICYEu1q14Uvh1SZfED9WkV6XlF4ncI+DXM67YRpLWokuHlWPsvIWS
         8LUX24co34k6NdYh1ek0/vZ3AdHc/61gU+uP6MjHAXuUd5czW9rRtDTPpNRoGypcbVUR
         OUegR/qKsLkcZgABneX8qSvmXApKe+tGRg0NNOzTRG46aWYSrHUeMG4HQfCGPDPbSYhk
         nlJw==
X-Gm-Message-State: APuU4Z/0TATxiAS0BoerE6dcuYqjkBiE5JGk8JPlYQXXNylakdQwgHYg
	vg0fckrWZirlWFr9tl9ArqEloilN17yXk11zcp9Vx8Tn9m2XNsn38xq0Jd6xJcR+0DariE+Fpnv
	2F8iMb5Se2/miz6UkQI4uY0bra7Ui8SCF9jMbb11yhNGspXo/C808rTrJIn1Wog==
X-Gm-Gg: AZFdTZdL7gK7Yu/oV/jkrMx0eZ4PgXP/mZdm5FsviJNtZBh+NDRCS8HBwPlmPiSEe2c
	3gAZKkJwgvh4Njbv58p547hIyyA/CQa6Aj1zYs0TW3AVtkm2GGySge6ungPdkPKGAubsXhREaZI
	6jJtEjOLj3kernhsaXGRzK1S3afHlf1y6wDFq8W0NRVV3znKpbih7WNwC/LFE+Yn6pDk2/dyRHd
	YWrH6TWL0XRln6g34fuC03qypvLo2JOdZCZS54sI8VUTVFnA78ElO2H7AFkDwg6WQtVzyT8xT36
	/xUayiBN9+wnBbT6TBHo9TKH21kx7HZVw3+p4G7qNE5iJ/C2CmQC1wHL0Uot29iOPV1ZkSZvGKH
	QY18E/6IMZIcG0yo5qIqWQH27iPJmloeKU8n6P6iNq0Podg==
X-Received: by 2002:a05:620a:28c2:b0:949:b1b5:bd6 with SMTP id af79cd13be357-949ba9b7e70mr5002934485a.15.1795824712130;
        Fri, 27 Nov 2026 16:11:52 -0800 (PST)
X-Received: by 2002:a05:620a:28c2:b0:949:b1b5:bd6 with SMTP id af79cd13be357-949ba9b7e70mr5002930885a.15.1795824711723;
        Fri, 27 Nov 2026 16:11:51 -0800 (PST)
Received: from [172.20.1.138] ([8.9.41.138])
        by smtp.gmail.com with ESMTPSA id af79cd13be357-949bb40efc4sm1939365785a.36.2026.11.27.16.11.50
        (version=TLS1_3 cipher=TLS_AES_128_GCM_SHA256 bits=128/128);
        Fri, 27 Nov 2026 16:11:50 -0800 (PST)
Message-ID: <05905333-2b43-4b8c-bbdc-02b4b3d0b98f@redhat.com>
Date: Fri, 27 Nov 2026 19:11:49 -0500
X-Mailing-List: linux-nfs@vger.kernel.org
List-Id: <linux-nfs.vger.kernel.org>
List-Post: <mailto:linux-nfs@vger.kernel.org>
List-Help: <mailto:linux-nfs+help@vger.kernel.org>
List-Subscribe: <mailto:linux-nfs+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:linux-nfs+unsubscribe@vger.kernel.org>
List-Owner: <mailto:linux-nfs+owner@vger.kernel.org>
Precedence: list
MIME-Version: 1.0
User-Agent: Mozilla Thunderbird
Subject: Re: [PATCH 1/1] libtirpc: add missing boundary restriction to
 xdr_rpc_gss_unwrap_data
From: Steve Dickson <steved@redhat.com>
To: Olga Kornievskaia <okorniev@redhat.com>
Cc: linux-nfs@vger.kernel.org, libtirpc <libtirpc-devel@lists.sourceforge.net>
References: <20261109154641.55252-1-okorniev@redhat.com>
 <15377fb2-2e80-4509-833f-d0ebc882c0b2@redhat.com>
Content-Language: en-US
In-Reply-To: <15377fb2-2e80-4509-833f-d0ebc882c0b2@redhat.com>
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 8bit

Correction...

On 11/27/26 2:21 PM, Steve Dickson wrote:
> 
> 
> On 11/9/26 10:46 AM, Olga Kornievskaia wrote:
>> Add a boundary restriction to the xdr_rpc_gss_buf() call for the 
>> RPCSEC_GSS_SVC_PRIVACY case.
>>
>> Fixes: 65d27459fe56 ("libtirpc: Bound maxsize in 
>> xdr_rpc_gss_unwrap_data() decode calls"
>> Signed-off-by: Olga Kornievskaia<okorniev@redhat.com>
>> ---
>>   src/authgss_prot.c | 2 +-
>>   1 file changed, 1 insertion(+), 1 deletion(-)
>>
>> diff --git a/src/authgss_prot.c b/src/authgss_prot.c
>> index c7de1fd..620b294 100644
>> --- a/src/authgss_prot.c
>> +++ b/src/authgss_prot.c
>> @@ -254,7 +254,7 @@ xdr_rpc_gss_unwrap_data(XDR *xdrs, xdrproc_t 
>> xdr_func, caddr_t xdr_ptr,
>>       }
>>       else if (svc == RPCSEC_GSS_SVC_PRIVACY) {
>>           /* Decode databody_priv. */
>> -        if (!xdr_rpc_gss_buf(xdrs, &wrapbuf, (u_int)-1)) {
>> +        if (!xdr_rpc_gss_buf(xdrs, &wrapbuf, RPCSEC_GSS_MAX_UNWRAP)) {
>>               LIBTIRPC_DEBUG(1, ("xdr_rpc_gss_unwrap_data: decode 
>> databody_priv failed"));
>>               return (FALSE);
>>           }
>> -- 2.52.0
>>
> Committed... (tag: libtirpc.1.3.8-rc1)
tag: libtirpc.1.3.9-rc1

steved
