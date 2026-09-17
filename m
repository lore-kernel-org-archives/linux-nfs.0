Received: from mx0b-00154904.pphosted.com (mx0b-00154904.pphosted.com [148.163.137.20])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 37CB6392C25
	for <linux-nfs@vger.kernel.org>; Thu, 17 Sep 2026 08:11:10 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=148.163.137.20
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1789632672; cv=none; b=W1vNTQ8rIotKLgxzh143qGD52bsqNlghpqeeOStW9DRNJfwgHIA0cLPOrv4nycLUcAvqNsZN3kH5fIQADI+URfIreBGGb6anrV3aMkvAt4SgBFaNPDyVPDBoDGcsnDWUJ5cVEMIt3NDRiAQmLtwW5zGHfCfR/UfYRBLEWBZqX1s=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1789632672; c=relaxed/simple;
	bh=NTfGq/qvit8BjzPz+XxKzHFT2xIX+unRsUjOnxanPWw=;
	h=From:To:Cc:Subject:Date:Message-ID:In-Reply-To:References:
	 MIME-Version:Content-Type; b=FRF9JXvmQBQ7qNk5+BrxARpCRYhICYxYYQm4mgwpmVX0HHMjp4v7sDuCTdMn1G05n1NGaYRf2wykOuuL2OauaPOY07lZUpgybkD3Wd1oiGv7cgRGSg+uaacnGG+FGqODlXJwXwSumEUBRoi+IqLrV+caEyHXegjbZqbVq3bgOQs=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dmarc=pass (p=reject dis=none) header.from=dell.com; spf=pass smtp.mailfrom=dell.com; dkim=pass (2048-bit key) header.d=dell.com header.i=@dell.com header.b=Bw2HQy0l; dkim=pass (2048-bit key) header.d=dell.com header.i=@dell.com header.b=ImZ/jcLy; arc=none smtp.client-ip=148.163.137.20
Authentication-Results: smtp.subspace.kernel.org; dmarc=pass (p=reject dis=none) header.from=dell.com
Authentication-Results: smtp.subspace.kernel.org; spf=pass smtp.mailfrom=dell.com
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=dell.com header.i=@dell.com header.b="Bw2HQy0l";
	dkim=pass (2048-bit key) header.d=dell.com header.i=@dell.com header.b="ImZ/jcLy"
Received: from pps.filterd (m0170395.ppops.net [127.0.0.1])
	by mx0b-00154904.pphosted.com (8.18.1.11/8.18.1.11) with ESMTP id 68H63OJA1924667
	for <linux-nfs@vger.kernel.org>; Thu, 17 Sep 2026 04:11:03 -0400
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=dell.com; h=cc
	:content-transfer-encoding:content-type:date:from:in-reply-to
	:message-id:mime-version:references:subject:to; s=smtpout1; bh=+
	Y4K/Qbwdu4K5q3RN9rNIHgRfxsu4971s5zltveArOE=; b=Bw2HQy0lFBIGyNgw6
	UY//BExsuusFc7QvmznOfUkaG/enIEdpSFyowsUdQj9UJhINobLow8I41GeuBqGI
	TnWpG4psbBiklur7dInZD+Wlyxa20MhSrmg6P4+GzWloqxy7EZJuthHWmH6Azwsv
	w2HN6Th5TyR/zLE4Yznh2MPRcnTCCav7Cgo3ij3v0l4pp8t8SvKt8F2NTGoj6Zjr
	VcaF9li3lVuuOn4ibuYB4gPzw30aJS9/YNEvHQ/LICdY27oFPZIGU8dxCU955U4D
	HvZvCs+mUxOByN0m1QYYAHJlD4cpVNdIAb2ER8+80RE2InR3lOkT00tOBo1CtNaG
	zi4IA==
Received: from mx0a-00154901.pphosted.com (mx0a-00154901.pphosted.com [67.231.149.39])
	by mx0b-00154904.pphosted.com (PPS) with ESMTPS id 4gn3dhn2p4-1
	(version=TLSv1.3 cipher=TLS_AES_256_GCM_SHA384 bits=256 verify=NOT)
	for <linux-nfs@vger.kernel.org>; Thu, 17 Sep 2026 04:11:03 -0400 (EDT)
Received: from pps.filterd (m0134746.ppops.net [127.0.0.1])
	by mx0a-00154901.pphosted.com (8.18.1.11/8.18.1.11) with ESMTP id 68H7464o3255272
	for <linux-nfs@vger.kernel.org>; Thu, 17 Sep 2026 04:11:02 -0400
Received: from esapsmtplv03.us.dell.com (esapsmtplv03.us.dell.com [143.166.203.148])
	by mx0a-00154901.pphosted.com (PPS) with ESMTPS id 4grbg90saf-1
	(version=TLSv1.3 cipher=TLS_AES_256_GCM_SHA384 bits=256 verify=FAIL)
	for <linux-nfs@vger.kernel.org>; Thu, 17 Sep 2026 04:11:02 -0400 (EDT)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
  d=dell.com; i=@dell.com; q=dns/txt; s=smtpdev1;
  t=1789632663; x=1821168663;
  h=from:to:cc:subject:date:message-id:in-reply-to:
   references:mime-version:content-transfer-encoding;
  bh=+Y4K/Qbwdu4K5q3RN9rNIHgRfxsu4971s5zltveArOE=;
  b=ImZ/jcLyuMqNmJ8Hi79rDnAkQxL3KLKtyVL+UO3pChG8SrVHkgTdzsWK
   nBg9L/sJ7fOtDm4Q47TA+Ku95ZkRoVp+HqBJVtGuZtHK6fjQrUO/HMSG4
   DtTIOzUeMhzXfDsMAX3yFvMxDYhHK3vhGZ3ebdD+jKUGl2DBMO+rLRe/W
   7gtdySPIxt7w4Jxfe3+7DQDVxvwCUnmO4dGQ+qqOPssaB2nbAPED28zS4
   Qo4OaVW5HX4RMsexpI95hCKF+LrTVDuE5qjRvKpQhZNqtjsrm/vqDp0Vq
   MWJcPJJ2Ni4mHE17PHc7BlBE71x3vlTQAjOChsU+EeAhz5jHxUHW9DQ8X
   A==;
X-CSE-ConnectionGUID: 0ckS3bVVSg6Se/I5t7axZA==
X-CSE-MsgGUID: H+7KQsD7RcGpzAz6xbom8g==
X-LoopCount0: from 10.94.9.174
X-MS-Exchange-CrossPremises-AuthAs: Internal
Received: from w-96j1th4.apac.dell.com (HELO W-96J1TH4.blr.amer.dell.com) ([10.94.9.174])
  by esapsmtplv03.us.dell.com with ESMTP/TLS/TLS_AES_256_GCM_SHA384; 17 Sep 2026 08:11:00 +0000
From: Prabhakar Pujeri <prabhakar.pujeri@dell.com>
To: Roberto Bergantinos Corpas <rbergant@redhat.com>
Cc: Prabhakar Pujeri <prabhakar.pujeri@dell.com>,
        Trond Myklebust <trondmy@kernel.org>, Anna Schumaker <anna@kernel.org>,
        linux-nfs@vger.kernel.org
Subject: Re: NFS: return DENIED in decode_lock_denied if we cannot decode owner
Date: Thu, 17 Sep 2026 08:10:57 +0000
Message-ID: <20260917081057.14836-1-prabhakar.pujeri@dell.com>
X-Mailer: git-send-email 2.53.0
In-Reply-To: <20260916124509.587700-1-rbergant@redhat.com>
References: <20260916124509.587700-1-rbergant@redhat.com>
Precedence: bulk
X-Mailing-List: linux-nfs@vger.kernel.org
List-Id: <linux-nfs.vger.kernel.org>
List-Subscribe: <mailto:linux-nfs+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:linux-nfs+unsubscribe@vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 8bit
X-Proofpoint-Virus-Version: vendor=baseguard
 engine=ICAP:2.0.293,Aquarius:18.0.1176,Hydra:6.1.134,FMLib:17.12.100.49
 definitions=2026-09-17_01,2026-09-16_02,2025-10-01_01
X-Proofpoint-Spam-Details: rule=outbound_notspam policy=outbound score=0
 malwarescore=0 lowpriorityscore=0 impostorscore=0 clxscore=1015
 suspectscore=0 adultscore=0 bulkscore=0 spamscore=0 priorityscore=1501
 phishscore=0 classifier=typeunknown authscore=0 authtc= authcc=
 route=outbound adjust=0 reason=mlx scancount=1 engine=8.22.0-2609040000
 definitions=main-2609170110
X-Authority-Analysis: v=2.4 cv=JpBkP84C c=1 sm=1 tr=0 ts=6aaba097 cx=c_pps
 a=j0++y401J6f/BxNAf5EDow==:117 a=iGMIhCliR854E25UHWhNxg==:17
 a=kj9zAlcOel0A:10 a=VdqzKS8jKosA:10 a=ke5jqHz-1hQA:10
 a=VkNPw1HP01LnGYTKEx00:22 a=6gNNCFAoQcIphELLPWWu:22 a=Qy6CKLcU0MZ4grw4BCWD:22
 a=iLNU1ar6AAAA:8 a=RjG8LU8udxzbqfzCoY8A:9 a=CjuIK1q_8ugA:10
 a=gbU3OgOOxF9bX48Letew:22
X-Proofpoint-GUID: Wrgk9VQThWoC4YBISuTXhjGKu2gpNCZs
X-Proofpoint-Spam-Details-Enc: AW1haW4tMjYwOTE3MDEwOSBTYWx0ZWRfXxGmP95XnbATl
 /9sZIpV1O6xM7n7pFa231II+V56F91Rcm67CW5PGIz2XgCO8tZLRGNB4HF181hwjlgXC9YRiiO7
 pshCDAM1YvY0D4KGelhBDXYaOAXuWNJoPXizLi2I4FdpDkycdnq7oPdY3g6eQf/PrXxhtXVzdY4
 MiYU2yBG2mh6tBkMTw3pYjmgnI2hVqZi6/hz8JaZEyGud0cny/OIh0GQ0HYSPab9a6QUhk2O3tu
 b+eV7IXzAqYWn+Da+4hc7v5416462iWdH40bI1FJSEd5xNFGzaHTwknNd8Y6206trKgfcXbPR0y
 hyVFQeHDEW1vDq8YztaMVsjLVkmwWmR7KJPJqoySFxY5iMGRIqyvSUgvXI9PAdXD6dFgqRICTDy
 CorqXO4S2WddP6uGAsQI2vPaZQmtEjkX8G5YLo8U3H6yVcMLZn8MSuDeGw95OZsnS2sNOLXMNIq
 EkBuEpugC62tZMIvPRg==
X-Proofpoint-ORIG-GUID: Wrgk9VQThWoC4YBISuTXhjGKu2gpNCZs
X-Proofpoint-Spam-Info: AW1haW4tMjYwOTE3MDEwOSBTYWx0ZWRfX+diGwF//QHd+
 3oMz90gSKu4gDN9sz+LdiNR7vceXOAfIBhXwO/8W/krE001AUjbwWaOlKvNQvPpqZB3aRrA6YM2
 LbFohDkYJb8gNmjIj3d4zoN2GXQwNQo=
X-Proofpoint-Spam-Details: rule=notspam policy=default score=0
 lowpriorityscore=0 adultscore=0 phishscore=0 malwarescore=0 bulkscore=0
 impostorscore=0 spamscore=0 clxscore=1015 priorityscore=1501 suspectscore=0
 classifier=typeunknown authscore=0 authtc= authcc= route=outbound adjust=0
 reason=mlx scancount=1 engine=8.22.0-2609040000 definitions=main-2609170109

Hi Roberto,

Nice catch. I walked the caller paths against this and the reasoning
holds:

- decode_lock() passes fl = NULL and retries internally; decode_lockt()
  uses only offset/length/type, all decoded from the fixed 32-byte
  header before the owner field is reached. Nobody reads the owner
  bytes, so the removed EIO branch was the last consumer of that
  xdr_inline_decode() result, and its removal cannot leave a half-filled
  file_lock behind.
- The first 32-byte decode check still returns EIO on a truncated
  reply, so a genuinely malformed DENIED still fails early.
- The likely() inversion is real: decode failure is not the common case
  in a function that exists precisely because a denial always carries
  an owner.
- The "last operation" justification is, if anything, conservative --
  decode_lock()/decode_lockt() return non-zero status to the compound
  decode loop, which stops at this op either way, so pointer
  advancement would be moot even with more ops queued.

> 	p = xdr_inline_decode(xdr, namelen); /* variable size field */
> -	if (likely(!p))
> -		return -EIO;
> +	/* We have an owner here, return DENIED */
> +
>  	return -NFS4ERR_DENIED;

nit: the blank line between the comment and the return is unusual; I
would keep the comment immediately above the return.

> After commit 43502f6e8d1e ("NFS: fix open_owner_id_maxsz and related
> fields.")we dramatically changed the size of the LOCK/LOCKT reply
> buffer

nit: missing space -- "fields.") we dramatically changed". A few lines
further down the changelog also has "20bytes" -> "20 bytes".

No test evidence came with the posting. For a two-line decode tweak I
do not consider that a blocker, though a synthetic oversized-owner
reply (pynfs or a mangled-RPC test harness) would make a fine selftest
someday.

With the changelog nits fixed:

Reviewed-by: Prabhakar Pujeri <prabhakar.pujeri@dell.com>
