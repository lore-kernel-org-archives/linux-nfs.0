Received: from mx0a-00154904.pphosted.com (mx0a-00154904.pphosted.com [148.163.133.20])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id CCC5C44A3EB;
	Fri, 28 Aug 2026 13:34:06 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=148.163.133.20
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1787924058; cv=none; b=nl8rWNGPIPxLpSJhUOxF4Qwo61PPVrTCtT3aiffSHYsdTFA33/gPzQV7rGQaFEqXls2+wJy/iD6lLvGoVIYChK5fC5R9PpgUnxf69mwND/4Gf1Yt6q4HefQa+pNdHofhHd4tz3rdcX4S7yrRLd/WsRLb7gQyETDolj8/bpqpfTU=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1787924058; c=relaxed/simple;
	bh=xc/gjn9dctudtpqhIH46mmiFNi7ncSKNCVPeVsRTyks=;
	h=From:To:Cc:Subject:Date:Message-ID:In-Reply-To:References:
	 MIME-Version; b=OlEHfSt6kDpB0ldiPlbOeQuuGfe6R00+jTU6IZWbGRd4sce7CU74ge5/Nsb2HvwhaDsT/EISG3GiiXvvDMQremW+CDe6nOjQ7pqBMD22qIJx+0xp6qf3thwz1Xei4rAWEbg9Hd9VDsBZZMYnDq6m1ocRSeer+5rdqERbrpgBa8I=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dmarc=pass (p=reject dis=none) header.from=dell.com; spf=pass smtp.mailfrom=dell.com; dkim=pass (2048-bit key) header.d=dell.com header.i=@dell.com header.b=lkpXkFHc; dkim=pass (2048-bit key) header.d=dell.com header.i=@dell.com header.b=C9AWk9Te; arc=none smtp.client-ip=148.163.133.20
Authentication-Results: smtp.subspace.kernel.org; dmarc=pass (p=reject dis=none) header.from=dell.com
Authentication-Results: smtp.subspace.kernel.org; spf=pass smtp.mailfrom=dell.com
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=dell.com header.i=@dell.com header.b="lkpXkFHc";
	dkim=pass (2048-bit key) header.d=dell.com header.i=@dell.com header.b="C9AWk9Te"
Received: from pps.filterd (m0170392.ppops.net [127.0.0.1])
	by mx0a-00154904.pphosted.com (8.18.1.11/8.18.1.11) with ESMTP id 67SDRmfG3418430;
	Fri, 28 Aug 2026 09:33:59 -0400
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=dell.com; h=cc
	:content-transfer-encoding:date:from:in-reply-to:message-id
	:mime-version:references:subject:to; s=smtpout1; bh=xc/gjn9dctud
	tpqhIH46mmiFNi7ncSKNCVPeVsRTyks=; b=lkpXkFHcM2ZJy3qb3i9LjzG10o5F
	FI0tAgJO6VMOilzjYli7HOXB1UroTtQu6U8n02FH1QXSWrGItIas5DptA67O7DC2
	wG5J6XXqiG9dDU+jfczhr10j35VL/IsjwnAL8HUJSG4aK0nWcj71iV9srWUHRkTO
	Kt9TQi/RqDhFO3fmAwUyva4krrdlTgHiIc5fMLEnFYtGPVo+d/Sm3Z7rqVpSpHk7
	6ZWSJv6RtafnaUG3R3TokejbAG78hbu665oXUUZLI2TE202KFaepN2mQnX6Zfjmx
	g+uAJlJH3ZJ4sH5nHKobC1rBhtSsPgZy4WjbMh022m6BzjKKFcwJ9r9Tng==
Received: from mx0a-00154901.pphosted.com (mx0a-00154901.pphosted.com [67.231.149.39])
	by mx0a-00154904.pphosted.com (PPS) with ESMTPS id 4g9x2tk2a2-1
	(version=TLSv1.3 cipher=TLS_AES_256_GCM_SHA384 bits=256 verify=NOT);
	Fri, 28 Aug 2026 09:33:59 -0400 (EDT)
Received: from pps.filterd (m0133268.ppops.net [127.0.0.1])
	by mx0a-00154901.pphosted.com (8.18.1.11/8.18.1.11) with ESMTP id 67SDRIEr254631;
	Fri, 28 Aug 2026 09:33:58 -0400
Received: from esapsmtpat04.us.dell.com (esapsmtpat04.us.dell.com [143.166.211.147])
	by mx0a-00154901.pphosted.com (PPS) with ESMTPS id 4gbb09g9v5-1
	(version=TLSv1.3 cipher=TLS_AES_256_GCM_SHA384 bits=256 verify=FAIL);
	Fri, 28 Aug 2026 09:33:58 -0400 (EDT)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
  d=dell.com; i=@dell.com; q=dns/txt; s=smtpdev1;
  t=1787924038; x=1819460038;
  h=from:to:cc:subject:date:message-id:in-reply-to:
   references:mime-version:content-transfer-encoding;
  bh=xc/gjn9dctudtpqhIH46mmiFNi7ncSKNCVPeVsRTyks=;
  b=C9AWk9TehLr/tvcrquhifXTV5OVQjTULDLg+jDbThF3KC03jFxiyeCT6
   eXdYA/JPBJPcrjI0ZQQYqBCqOZi9hl68Aecr5YAnQB9/JtIWVWTHEYkb/
   rkvpPKA1UfyJQGOSQuBFOELH5XOrny71mbWICXtRqfG6QlKamly1Da3IL
   xHpDSEqwH4NkfximOxHb7uf77oAKKqgtvh0wjGZkVJ4Cq6X1MoDinv6Xs
   AFt42dyerHdwon87zk1UXixAmoy9l1XFw186CZAtwshRl0T/dgo6OLQoK
   7wB4io/TBr/97TQ1hU47uzINvPPkmogDor2LPLmWAw9kdvbNEoqjTWQqi
   A==;
X-CSE-ConnectionGUID: 1/RNS+EOT/6yfIish/4bLw==
X-CSE-MsgGUID: q2hD7lK3SXSMZn9+YmzL1Q==
X-LoopCount0: from 10.94.8.206
X-MS-Exchange-CrossPremises-AuthAs: Internal
Received: from w-96j1th4.apac.dell.com (HELO W-96J1TH4.blr.amer.dell.com) ([10.94.8.206])
  by esapsmtpat04.us.dell.com with ESMTP/TLS/TLS_AES_256_GCM_SHA384; 28 Aug 2026 13:33:54 +0000
From: Prabhakar Pujeri <prabhakar.pujeri@dell.com>
To: Chuck Lever <cel@kernel.org>, Jeff Layton <jlayton@kernel.org>
Cc: Prabhakar Pujeri <prabhakar.pujeri@dell.com>, NeilBrown <neil@brown.name>,
        Olga Kornievskaia <okorniev@redhat.com>, Dai Ngo <Dai.Ngo@oracle.com>,
        Tom Talpey <tom@talpey.com>, Donald Hunter <donald.hunter@gmail.com>,
        Jakub Kicinski <kuba@kernel.org>, linux-nfs@vger.kernel.org,
        linux-kernel@vger.kernel.org
Subject: Re: [PATCH v1 1/3] nfsd: report NFSv4 grace state through Netlink
Date: Fri, 28 Aug 2026 13:33:51 +0000
Message-ID: <20260828133351.923-1-prabhakar.pujeri@dell.com>
X-Mailer: git-send-email 2.53.0
In-Reply-To: <1c53950d-66ba-490a-872f-b2318c584d3c@app.fastmail.com>
References: <cover.1787638668.git.prabhakar.pujeri@dell.com> <3fd25e2178458fbb44f57f1b0e068c12a6503d17.1787638668.git.prabhakar.pujeri@dell.com> <1046756851d9d7d688ac612a7f175e48745d2b84.camel@kernel.org> <20260827045139.4353-1-prabhakar.pujeri@dell.com> <1c53950d-66ba-490a-872f-b2318c584d3c@app.fastmail.com>
Precedence: bulk
X-Mailing-List: linux-nfs@vger.kernel.org
List-Id: <linux-nfs.vger.kernel.org>
List-Subscribe: <mailto:linux-nfs+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:linux-nfs+unsubscribe@vger.kernel.org>
MIME-Version: 1.0
Content-Transfer-Encoding: 8bit
X-Proofpoint-Virus-Version: vendor=baseguard
 engine=ICAP:2.0.293,Aquarius:18.0.1176,Hydra:6.1.134,FMLib:17.12.100.49
 definitions=2026-08-28_04,2026-08-27_02,2025-10-01_01
X-Proofpoint-Spam-Details: rule=outbound_notspam policy=outbound score=0
 bulkscore=0 malwarescore=0 clxscore=1015 phishscore=0 adultscore=0
 lowpriorityscore=0 suspectscore=0 spamscore=0 priorityscore=1501
 impostorscore=0 classifier=typeunknown authscore=0 authtc= authcc=
 route=outbound adjust=0 reason=mlx scancount=1 engine=8.22.0-2606150000
 definitions=main-2608280117
X-Proofpoint-Spam-Details-Enc: AW1haW4tMjYwODI4MDExNyBTYWx0ZWRfXwbj0p36z3NVY
 0N73266y7o0LhItd+Etpg3m8E2ihFiJgItRCAc6hulbY2TXIE4+qCHqg6hlzNOZZ00aqIyD+fCm
 c2qN0dnu2SW0Sje5cn0U186eFkddFmLTCejdx7qDcLbOnDuf9GH0moNOuCubPjs6ASWkk6ma94c
 9GuZfT7NWBZsJJvdxVrUPgTw71P31GXuJk4KGHj+63PBqwIaKjmDw5YEWIuXeG4vZJTHp8Ohp8e
 BSR4HkPZKHLk7Bn1khYEH2u5XZIoMTS/EXAvPczWmbn8gpSdUw5NJ49GQC7E4afN1ZLDLzLZKSJ
 OjsxCeTUb2OB6QU7NA2awE05QVKb+34uMwyi2sMmhHLGKK4pEzWnDpfY03fmRtn+fSh+keCOAmd
 dp3IYnYjShmBsn8pYmRieOdQgdsLfjq5BI5EXPz4GuFn/Hyc+qmev6gC3eJkb/MZKmf5GhldKul
 LHRFz9r3C6uDadP2WJw==
X-Proofpoint-GUID: JRm0P04Wok8Ds6y0MbKvxwJvWr_ly6fr
X-Authority-Analysis: v=2.4 cv=QYhWeMbv c=1 sm=1 tr=0 ts=6a918e47 cx=c_pps
 a=j0++y401J6f/BxNAf5EDow==:117 a=xQoiRHjKKYbJmV+sD1MyuQ==:17
 a=Sv0fKeRqtYgA:10 a=ke5jqHz-1hQA:10 a=VkNPw1HP01LnGYTKEx00:22
 a=6gNNCFAoQcIphELLPWWu:22 a=m3zZTHMLHbwB7Lmtoed2:22 a=kz_WCJu1lKwFQU8Hqq0A:9
 a=zZCYzV9kfG8A:10 a=gbU3OgOOxF9bX48Letew:22
X-Proofpoint-Spam-Info: AW1haW4tMjYwODI4MDExNyBTYWx0ZWRfX9cV9YAo2S+8F
 jwWkU22VtgsOQ1DyqvD1RKlWr+8x7d8j8SOsdvBW67fGpsh1hTEidD0APAFH2XUOOOTIiEXSfVQ
 aFHdKx20X8GAHPXFIJvGZs3iJrA8ads=
X-Proofpoint-ORIG-GUID: JRm0P04Wok8Ds6y0MbKvxwJvWr_ly6fr
X-Proofpoint-Spam-Details: rule=notspam policy=default score=0 adultscore=0
 clxscore=1015 malwarescore=0 lowpriorityscore=0 phishscore=0 suspectscore=0
 impostorscore=0 bulkscore=0 spamscore=0 priorityscore=1501
 classifier=typeunknown authscore=0 authtc= authcc= route=outbound adjust=0
 reason=mlx scancount=1 engine=8.22.0-2606150000 definitions=main-2608280117

On Thu, 2026-08-27 at 09:06 -0400, Chuck Lever wrote:
> I'd like any new API to avoid foreclosing the ability to move exports
> in and out of grace individually.

Thanks, that makes sense. A network-namespace-wide boolean would remain
useful as an aggregate, but the current single attribute does not make
its scope explicit enough for future per-export grace.

I will avoid freezing that ABI in this reroll. I'll drop the
grace-reporting patch from the client-visibility v2 and post the client
dump and state-count patches separately.

I'll follow up with a dedicated grace-status proposal whose records
carry an explicit scope, so it can represent the server-wide state today
and individual exports later. I also prefer to get agreement on the
export identity before adding that part speculatively.

Does that direction address your concern?

Thanks,
Prabhakar
