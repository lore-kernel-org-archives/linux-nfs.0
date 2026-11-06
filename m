Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.remote-ip=209.127.231.113
ARC-Seal: i=1; d=subspace.kernel.org; s=arc20261015; a=rsa-sha256; cv=none;
	t=1793955072;
	b=kTnKwd4TtSWL3lbRYO3vFxCViWw4F3/mABMuotYRKD1YR4AMyncWrf5z66UvX6ZmaRTH
	 RTmZIhKXtU2dVFPH3NDY9T2+LUlgy6b4YmKwdgEmaPayiHeA6+1Se3o7yLifnX58309Ja
	 0Lkyl8XZqqUx9U8P33zYuDwz3+O/9iDWxGnZEZUtcoI3veeKpOv24/exeeZhCnVOUqmhy
	 sTpERGXI5N2bHOje+7hvTJCqy6ad+l7H6fOlSC+kJSwG4dshd3Bj0MirRQjcuCci4K+ql
	 a0eSjfO4UAXy+PtgnzweotGTZuXgsa1mHo3749uxc/rXbt+kREit9tVLlJlyu10mHxA==
ARC-Message-Signature: i=1; d=subspace.kernel.org; s=arc20261015;
	a=rsa-sha256; c=relaxed/relaxed; t=1793955072;
	h=DMARC-Filter:DKIM-Signature:To:Content-Transfer-Encoding:Subject:
	 Content-Type:X-Original-From:X-Lms-Return-Path:Cc:Date:Message-Id:
	 In-Reply-To:X-Mailer:From:Mime-Version:References;
	bh=uw2jcbo2K94Ipub2qP4Q99pSQbMkC01ncZoy8NZ7ZtE=;
	b=ty0+XR4x3XmbVTJ7pnMVeqUalI+6YM/i2WGbuSvlfn+U0frcUhj+HCAzL1d6xlh4Cq09
	 pMdP1DZwynO91M/QyMQejPISrFLsvckw0Qa8lT/QufwKazr8bicE+sn+YfcY/BJfhseWL
	 MtmzifOjQrB1QEMFu7RqF4ESoS+Ge4PlGpQpIpppIGIasQ1gZXbtkOpmr1eYI07f8Cj8y
	 m9p1iq9l/hV3ytfZUqKOmGAkaLKWMr8LXgYXgqG/6Wc7TsikGLl5gLj0kbRspjIMk1Wbk
	 HCzmudfx1a3IzR1MlQ8Zr9OncS3WGtpGsViZRBba49ef7N7YNpE9TEIiFJQeP5BqM+w==
ARC-Authentication-Results: i=1; smtp.subspace.kernel.org; 
	dmarc=pass header.from=bytedance.com;
	spf=pass smtp.mailfrom=bytedance.com;
	dkim=pass header.d=bytedance.com header.i=@bytedance.com header.a=rsa-sha256 header.s=2212171451 header.b="PA/XBQAm";
	arc=none smtp.remote-ip=209.127.231.113
Received: from va-2-113.ptr.blmpb.com (va-2-113.ptr.blmpb.com [209.127.231.113])
	(using TLSv1.3 with cipher TLS_AES_128_GCM_SHA256 (128/128 bits)
	 key-exchange X25519 server-signature ECDSA (prime256v1) server-digest SHA256)
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id BCE86606A32E
	for <linux-nfs@vger.kernel.org>; Fri,  6 Nov 2026 08:51:10 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.4.2 smtp.subspace.kernel.org BCE86606A32E
Authentication-Results: smtp.subspace.kernel.org; dmarc=pass (p=quarantine dis=none) header.from=bytedance.com
Authentication-Results: smtp.subspace.kernel.org; spf=pass smtp.mailfrom=bytedance.com
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key, unprotected) header.d=bytedance.com header.i=@bytedance.com header.a=rsa-sha256 header.s=2212171451 header.b=PA/XBQAm
DKIM-Signature: v=1; a=rsa-sha256; q=dns/txt; c=relaxed/relaxed;
 s=2212171451; d=bytedance.com; t=1793955065; h=from:subject:
 mime-version:from:date:message-id:subject:to:cc:reply-to:content-type:
 mime-version:in-reply-to:message-id;
 bh=uw2jcbo2K94Ipub2qP4Q99pSQbMkC01ncZoy8NZ7ZtE=;
 b=PA/XBQAmEx8IsPS/7OJFQLeZ4Vjk/Xgf6CGt3AkrAKm6p3LefoZj01Twa7vDqugD69JTCX
 OoLavvqGtxiChoXZtxmsdKYlGIOffsC3eZp2ygVGEhoOVkIQv/V0wdij/ExxrW9gptS4sC
 huFbds+bdNGUJQ5pscQMUUnTSvwRyhYbmRpMSuoA+T2UFt+TfZJvf67gSlEl3Zn81x+XTK
 mQqcX7/6ZQthHCYwoS+rLfXUyD2l4P7ZcBA9bUtUSn1hRuYf/bd4ZCUgVcf/YA5GdKe8D1
 AI1y+Li+bj7iFxzsRI/E00L2eRhtPBCcqpeBV17nEuyFfspF748Rn6I2/QnlNA==
To: <nhuhuan@google.com>
Content-Transfer-Encoding: 7bit
Subject: Re: [RFC PATCH v3 0/3] mm: use non-temporal stores for demotion
Content-Type: text/plain; charset=UTF-8
X-Original-From: Li Zhe <lizhe.67@bytedance.com>
X-Lms-Return-Path: <lba+26aed94f7+7c0e03+vger.kernel.org+lizhe.67@bytedance.com>
Cc: <Liam.Howlett@oracle.com>, <akpm@linux-foundation.org>, 
	<alirad.malek@zptcorp.com>, <anna@kernel.org>, <apopple@nvidia.com>, 
	<bharata@amd.com>, <bp@alien8.de>, <byungchul@sk.com>, 
	<dave.hansen@linux.intel.com>, <dave@stgolabs.net>, <david@kernel.org>, 
	<dimitrios.palyvos@zptcorp.com>, <fvdl@google.com>, <gourry@gourry.net>, 
	<hannes@cmpxchg.org>, <hpa@zytor.com>, <jackmanb@google.com>, 
	<jic23@kernel.org>, <joshua.hahnjy@gmail.com>, 
	<linux-kernel@vger.kernel.org>, <linux-mm@kvack.org>, 
	<linux-nfs@vger.kernel.org>, <linux-trace-kernel@vger.kernel.org>, 
	<ljs@kernel.org>, <mathieu.desnoyers@efficios.com>, 
	<matthew.brost@intel.com>, <mhiramat@kernel.org>, <mhocko@suse.com>, 
	<mingo@redhat.com>, <nifan.cxl@gmail.com>, <rakie.kim@sk.com>, 
	<rientjes@google.com>, <rkodsara@amd.com>, <rostedt@goodmis.org>, 
	<rppt@kernel.org>, <ryan.roberts@arm.com>, <shivankg@amd.com>, 
	<sj@kernel.org>, <surenb@google.com>, <tglx@kernel.org>, 
	<trondmy@kernel.org>, <vbabka@kernel.org>, <weixugc@google.com>, 
	<x86@kernel.org>, <xuezhengchu@huawei.com>, 
	<yiannis.nikolakop@gmail.com>, <yiannis@zptcorp.com>, 
	<ying.huang@linux.alibaba.com>, <ziy@nvidia.com>
Date: Fri,  6 Nov 2026 16:50:19 +0800
Message-Id: <20261106085019.90487-1-lizhe.67@bytedance.com>
In-Reply-To: <20261103223025.2482227-1-nhuhuan@google.com>
X-Mailer: git-send-email 2.45.2
From: "Li Zhe" <lizhe.67@bytedance.com>
X-Mailing-List: linux-nfs@vger.kernel.org
List-Id: <linux-nfs.vger.kernel.org>
List-Post: <mailto:linux-nfs@vger.kernel.org>
List-Help: <mailto:linux-nfs+help@vger.kernel.org>
List-Subscribe: <mailto:linux-nfs+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:linux-nfs+unsubscribe@vger.kernel.org>
List-Owner: <mailto:linux-nfs+owner@vger.kernel.org>
Precedence: list
Mime-Version: 1.0
References: <20261103223025.2482227-1-nhuhuan@google.com>

On Tue, 3 Nov 2026 14:30:22 -0800, Huan Nguyen wrote:

> Using non-temporal stores and prefetching on x86 bypasses CPU cache
> allocation, protecting active workload working sets and improving
> demotion throughput.

Could you show some real workload numbers for this? I am wondering
whether the reduced cache allocation and improved demotion throughput
also translate into visible application-level benefits.

> - Memory ordering:
>   Add a wmb() barrier at the end of folio_mc_copy_nt() to ensure weakly
>   ordered non-temporal stores are drained before page tables are updated.

I have not looked into all the details here, so I may be missing
something. But before migration completes, there should eventually be a
publication step that makes the new folio visible. In theory, that
publication step should already provide the required ordering before
userspace can observe the new folio. So I wonder whether the wmb() in
folio_mc_copy_nt() is really needed here.

Thanks,
Zhe
