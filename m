Received: from mx0a-00154904.pphosted.com (mx0a-00154904.pphosted.com [148.163.133.20])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id AD5392D8796
	for <linux-nfs@vger.kernel.org>; Mon, 21 Sep 2026 04:47:38 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=148.163.133.20
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1789966060; cv=none; b=GERLed7wPufO29IiLSoaykUYA69VOV4ulzThRAvGvpFITKFeEZ0/VMLHVtot1bzw4TgJKz3brqTP45MAUxSk6wosv4gHF+STzENOLGObG/V6l/ip7LTL4PkYrSvHnwW6398b6mm8hTemzbDrZ4fhb1LYJm8kA39T6dtwlFOes4Y=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1789966060; c=relaxed/simple;
	bh=dF0B5ycoNP0kLKsb6+XjIjbPR6lYz2PA2CIh9DRNtEE=;
	h=From:To:Cc:Subject:Date:Message-ID:In-Reply-To:References:
	 MIME-Version:Content-Type; b=Hd4o0XLiZ25zBlrEfIBMBNukfzRgH75Y2mNrqhuVZaSdqV9+Lm0sPsUQznJvixyw/JQotLREpV4E39q8vKe5rF7z5XV8qRegpIhIp8F254QlPLmWvLMEC6+1SlmjPBhzC4GsjKisZMel0p9dpPvXUNgYNjokFbF6rZNSjANbOcE=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dmarc=pass (p=reject dis=none) header.from=dell.com; spf=pass smtp.mailfrom=dell.com; dkim=pass (2048-bit key) header.d=dell.com header.i=@dell.com header.b=ag9ICiHI; dkim=pass (2048-bit key) header.d=dell.com header.i=@dell.com header.b=LWuAWpbS; arc=none smtp.client-ip=148.163.133.20
Authentication-Results: smtp.subspace.kernel.org; dmarc=pass (p=reject dis=none) header.from=dell.com
Authentication-Results: smtp.subspace.kernel.org; spf=pass smtp.mailfrom=dell.com
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=dell.com header.i=@dell.com header.b="ag9ICiHI";
	dkim=pass (2048-bit key) header.d=dell.com header.i=@dell.com header.b="LWuAWpbS"
Received: from pps.filterd (m0170393.ppops.net [127.0.0.1])
	by mx0a-00154904.pphosted.com (8.18.1.11/8.18.1.11) with ESMTP id 68L3YuNh3795119
	for <linux-nfs@vger.kernel.org>; Mon, 21 Sep 2026 00:47:32 -0400
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=dell.com; h=cc
	:content-transfer-encoding:content-type:date:from:in-reply-to
	:message-id:mime-version:references:subject:to; s=smtpout1; bh=U
	RJvwibercdsYr2ynmysTBZbzcDpf8OhbLQMJAL/bC8=; b=ag9ICiHI+C131qcYU
	uOVTSNJp1GV6G4U5R55ogErDxCjfdEuEnPn4JeZ7L7QhbZddjHr2OU4Tk1ZT15QX
	aSQawNAG/bLrU4eRGR6FzRgSGrGJ/J0ehypEeWA+uD/XvoN4mD65EmIr7P2wcqXT
	ZAkj4EDHRLvdQPx+YllrMu3fO9pm5x81Dtiq6ob6YOO3+fiimKdbT62q3YOYw0EL
	fOZQSIpmjo8bgQdu5etXy9veuPYmiRZv3cN+nZjAqasSrpyD49476ye7D9x/C0AJ
	1GBb73ZHTZBZ2sLfxeS2kvwUUR3h8wA+7u+8ouOGqFTCJP2JHmLQg8Mi0pknjY/u
	YDqVg==
Received: from mx0a-00154901.pphosted.com (mx0a-00154901.pphosted.com [67.231.149.39])
	by mx0a-00154904.pphosted.com (PPS) with ESMTPS id 4gsnqecdtj-1
	(version=TLSv1.3 cipher=TLS_AES_256_GCM_SHA384 bits=256 verify=NOT)
	for <linux-nfs@vger.kernel.org>; Mon, 21 Sep 2026 00:47:32 -0400 (EDT)
Received: from pps.filterd (m0142693.ppops.net [127.0.0.1])
	by mx0a-00154901.pphosted.com (8.18.1.11/8.18.1.11) with ESMTP id 68L3Xl5l3111869
	for <linux-nfs@vger.kernel.org>; Mon, 21 Sep 2026 00:47:31 -0400
Received: from esapsmtplv03.us.dell.com (esapsmtplv03.us.dell.com [143.166.203.148])
	by mx0a-00154901.pphosted.com (PPS) with ESMTPS id 4gtue4sbrp-1
	(version=TLSv1.3 cipher=TLS_AES_256_GCM_SHA384 bits=256 verify=FAIL)
	for <linux-nfs@vger.kernel.org>; Mon, 21 Sep 2026 00:47:31 -0400 (EDT)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
  d=dell.com; i=@dell.com; q=dns/txt; s=smtpdev1;
  t=1789966051; x=1821502051;
  h=from:to:cc:subject:date:message-id:in-reply-to:
   references:mime-version:content-transfer-encoding;
  bh=URJvwibercdsYr2ynmysTBZbzcDpf8OhbLQMJAL/bC8=;
  b=LWuAWpbST7WtxhMo2z5X/iCvgNIbwZhl4AqjbS1F8xjN7asQ2nUJYYjW
   IHIR3kn9kF8lhSZSJKdsHGu+AC/ITo704LDcS2NQJgS6XeCniC5ivF11q
   y7lFrA3p3QRKU6tJUDhIMBU0Jrqgri6wM+NgV2fU30opI6Eldy7W8rnei
   hJy731mGWkHH+LhrsBNxOkAqreKaaNuCTc6w+a0OHPuPDdU47bBLMzpgs
   VZMayjv7AIwV8R4BUIM/hOKFk7PgTbIcDHTZV/TF+b3CqB12r+Fzt1+bN
   DALZzOgSITh5tk5eO91C137Cw6okpEqG3iEzFaZgpjWlcnJ/E/Ji8dHLB
   A==;
X-CSE-ConnectionGUID: L+rvk/IOQmKKwt9zs+BcsA==
X-CSE-MsgGUID: 32y3jpiKTdGbfwXKQIF25Q==
X-LoopCount0: from 10.94.9.174
X-MS-Exchange-CrossPremises-AuthAs: Internal
Received: from w-96j1th4.apac.dell.com (HELO W-96J1TH4.blr.amer.dell.com) ([10.94.9.174])
  by esapsmtplv03.us.dell.com with ESMTP/TLS/TLS_AES_256_GCM_SHA384; 21 Sep 2026 04:47:29 +0000
From: Prabhakar Pujeri <prabhakar.pujeri@dell.com>
To: =?UTF-8?q?J=C3=A9r=C3=A9my=20Jean?= <Jeremy.Jean@oss.cyber.gouv.fr>
Cc: Prabhakar Pujeri <prabhakar.pujeri@dell.com>,
        Trond Myklebust <trondmy@kernel.org>, Anna Schumaker <anna@kernel.org>,
        linux-nfs@vger.kernel.org
Subject: Re: [v2] SUNRPC: restrict integrity replies to authenticated payload
Date: Mon, 21 Sep 2026 04:47:23 +0000
Message-ID: <20260921044723.24601-1-prabhakar.pujeri@dell.com>
X-Mailer: git-send-email 2.53.0
In-Reply-To: <20260920210712.2887738-2-Jeremy.Jean@oss.cyber.gouv.fr>
References: <20260920210712.2887738-2-Jeremy.Jean@oss.cyber.gouv.fr>
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
 definitions=2026-09-21_02,2026-09-16_02,2025-10-01_01
X-Proofpoint-Spam-Details: rule=outbound_notspam policy=outbound score=0
 priorityscore=1501 clxscore=1015 malwarescore=0 spamscore=0 impostorscore=0
 bulkscore=0 phishscore=0 adultscore=0 lowpriorityscore=0 suspectscore=0
 classifier=typeunknown authscore=0 authtc= authcc= route=outbound adjust=0
 reason=mlx scancount=1 engine=8.22.0-2609040000 definitions=main-2609210065
X-Proofpoint-GUID: rlxVPDDYGyFF6pvyCFzj3YKB826xRpf6
X-Authority-Analysis: v=2.4 cv=PYFqFShd c=1 sm=1 tr=0 ts=6ab0b6e4 cx=c_pps
 a=j0++y401J6f/BxNAf5EDow==:117 a=iGMIhCliR854E25UHWhNxg==:17
 a=kj9zAlcOel0A:10 a=VdqzKS8jKosA:10 a=ke5jqHz-1hQA:10
 a=VkNPw1HP01LnGYTKEx00:22 a=6gNNCFAoQcIphELLPWWu:22 a=2Lpba0WeoN7BYVdwMO11:22
 a=VwQbUJbxAAAA:8 a=iLNU1ar6AAAA:8 a=pyH2Cm81XVhuXgnS-V0A:9 a=3ZKOabzyN94A:10
 a=CjuIK1q_8ugA:10 a=gbU3OgOOxF9bX48Letew:22
X-Proofpoint-ORIG-GUID: rlxVPDDYGyFF6pvyCFzj3YKB826xRpf6
X-Proofpoint-Spam-Info: AW1haW4tMjYwOTIxMDA2NSBTYWx0ZWRfX/uqRc9h/771K
 bK4HRasXj4YLOkyw5ks9vyGFP77sjdOpTW/kaxTTDvr4tMtJv+439mDREwYxCOfPULcpX62R+1M
 YtaWjcX5DJW5oLd6qPBKYFfQsRQ1IFw=
X-Proofpoint-Spam-Details-Enc: AW1haW4tMjYwOTIxMDA2NSBTYWx0ZWRfX594KbowRem3N
 TGEkvV2L/EsdR3u1AKNFOs1C7olnMErXR3pOESvjFw/1w+b7R9YU0scleCic89tNDXJc5XbbJgd
 euanvA2vqptj5xEB6cDeYrnHfL7Pd2oE4fGp9UqvNBmokIz6vFC7yekX8H2SrIB+yS20TL7zy3y
 cBKXGX1r91rI2aDrIFPCYN1Bd9wkWe228Z5Sn4e9F3AQFEv9Pi9vBT096wzE1cDLGjdenJC63Y4
 dSs4KvQBIjd1kgF4iuBEdx7rCJd4xFvNvIV75lzLGYurq5x+6fjAN6Fx8s6GDFPM4G1D7hcnSUD
 jSOo1HAp1Wv4PjpaV+hbtJdBX+p81tZxvqKe5iFjjgEjlPIm0M/+NnkUVGgbWMa4rdaz+0GSJhN
 luN7OoQZMWSLw+PoE4LdpuTK3N9kZFKiqLzXCNQ0SUMgn9kBpwW3c7c73KyLXgCrYhLy3G/pJ15
 wpoZDY2p8gxDW8zcF4w==
X-Proofpoint-Spam-Details: rule=notspam policy=default score=0 impostorscore=0
 malwarescore=0 lowpriorityscore=0 adultscore=0 clxscore=1015 spamscore=0
 suspectscore=0 priorityscore=1501 bulkscore=0 phishscore=0
 classifier=typeunknown authscore=0 authtc= authcc= route=outbound adjust=0
 reason=mlx scancount=1 engine=8.22.0-2609040000 definitions=main-2609210065

Hi Jérémy,

Walked v2 against v7.3-rc4, including Chuck's v1 notes. Looks good
overall -- inline comments below.

> -	if (len & 3)
> +	if (len < XDR_UNIT || len & 3)
>  		goto unwrap_failed;

This is the load-bearing check now that the dead v1
xdr_stream_remaining() guard is gone: it keeps the (len - XDR_UNIT)
arithmetic well-defined at the truncation site and rejects a body with
no room for the mandatory sequence number. Nothing between the seqno
decode and the truncation touches the stream, so
remaining - (len - XDR_UNIT) cannot underflow.

> -	if (xdr_decode_word(rcv_buf, offset, &len))
> +	if (xdr_decode_word(rcv_buf, offset, &mic.len))
>  		goto unwrap_failed;
>  	offset += sizeof(__be32);
> -	if (offset + len > rcv_buf->len)
> +	if (offset + mic.len > rcv_buf->len)
>  		goto unwrap_failed;
> -	mic.len = len;
> -	mic.data = kmalloc(len, GFP_KERNEL);
> +	mic.data = kmalloc(mic.len, GFP_KERNEL);

Behavior-preserving (bounds check still precedes kmalloc) and it drops
the v1 reuse of @len for two different objects -- rslack now reads
mic.len explicitly, same value, clearer code.

> +	/* Expose only the authenticated payload to the decoder. */
> +	xdr_truncate_decode(xdr, xdr_stream_remaining(xdr) -
> +			    (len - XDR_UNIT));

Correct: xdr_truncate_decode() removes its argument from the end of
the stream (xdr->buf->len -= nbytes), so this leaves exactly the
authenticated payload visible once gss_verify_mic() succeeds; the
checksum object and anything appended after it vanish from the
decoder's view.

Chuck's v1 note that gss_krb5_verify_mic_v2() covers only cksum_len
still stands and needs no change; rcv_buf->len bounds mic.len either
way.

Two small things:

- The trailer does not match Documentation/process/coding-assistants.rst,
  which wants the literal "LLM" token first, e.g. "Assisted-by: LLM
  Codex". Worth fixing on respin or at apply time.
- Fixes: points at Linux-2.6.12-rc2 and this is integrity-bypass class,
  so I would add Cc: stable@vger.kernel.org.

Reviewed-by: Prabhakar Pujeri <prabhakar.pujeri@dell.com>
