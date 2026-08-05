Received: from out30-98.freemail.mail.aliyun.com (out30-98.freemail.mail.aliyun.com [115.124.30.98])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 13922360EF2;
	Wed,  5 Aug 2026 14:14:54 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=115.124.30.98
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1785939304; cv=none; b=D9nrIDTPSVgAsfsWtoQmDZliigRsIFZfiE0+cfldjfg2W055QAGzNIugQHVd6yaMS300z05A5TMHmWPhqcODj2XagUNLFXx9Q4We3oEfYZZILRs6oHQVe7PXvz7zr5rKd5IWaZBnPh7tJ02EEXScA5c0pxqDutOYa/82XkGmqOo=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1785939304; c=relaxed/simple;
	bh=sHISbQRVT8OOfRaHccMY/K9NONhXWRGgQh9pCdeLPc8=;
	h=From:To:Cc:Subject:In-Reply-To:References:Date:Message-ID:
	 MIME-Version:Content-Type; b=aH4sadDY6lWVp9VgfBjDB8ArVNZqT2JvF5um9scvDf+ZM87odP5+fLbQZE6m614UV/KFPnYxjvYeY0er0Rxk61y9gWbwK1oa6+9u2iz6SV6la+M8as3HocXSX1gtsa28NyKtpeEkGCEIAfHLR/bnC9O4o1ge0JDTH52uu+qKiVg=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dmarc=pass (p=none dis=none) header.from=linux.alibaba.com; spf=pass smtp.mailfrom=linux.alibaba.com; dkim=pass (1024-bit key) header.d=linux.alibaba.com header.i=@linux.alibaba.com header.b=ZK8qMVIN; arc=none smtp.client-ip=115.124.30.98
Authentication-Results: smtp.subspace.kernel.org; dmarc=pass (p=none dis=none) header.from=linux.alibaba.com
Authentication-Results: smtp.subspace.kernel.org; spf=pass smtp.mailfrom=linux.alibaba.com
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (1024-bit key) header.d=linux.alibaba.com header.i=@linux.alibaba.com header.b="ZK8qMVIN"
DKIM-Signature:v=1; a=rsa-sha256; c=relaxed/relaxed;
	d=linux.alibaba.com; s=default;
	t=1785939292; h=From:To:Subject:Date:Message-ID:MIME-Version:Content-Type;
	bh=0SLaqhckWEc3QyNtTsd3YEo6O8h5dl7e0vqZloeFzhQ=;
	b=ZK8qMVINKJ+hRPDpmNR+IJgH2s4v5DPRRPXCkLrLbZ7QbIPDec6q7NqWjfwaBG/3NdW0G9Pso+tTOT9N1BYZujyQzMRjRmc/TI3HjA7l9BE5pBZGNj/Qb4S5gKZ+5YOGevndjoYWRE9h3869c6suUWX4aJi2u1fa0ASAWkAFIqE=
X-Alimail-AntiSpam:AC=PASS;BC=-1|-1;BR=01201311R151e4;CH=green;DM=||false|;DS=||;FP=0|-1|-1|-1|0|-1|-1|-1;HT=maildocker-contentspam033045098064;MF=ying.huang@linux.alibaba.com;NM=1;PH=DS;RN=48;SR=0;TI=SMTPD_---0X8RNYkg_1785939272;
Received: from DESKTOP-5N7EMDA(mailfrom:ying.huang@linux.alibaba.com fp:SMTPD_---0X8RNYkg_1785939272 cluster:ay36)
          by smtp.aliyun-inc.com;
          Wed, 05 Aug 2026 22:14:48 +0800
From: "Huang, Ying" <ying.huang@linux.alibaba.com>
To: Yiannis Nikolakopoulos <yiannis.nikolakop@gmail.com>
Cc: Thomas Gleixner <tglx@kernel.org>,  Ingo Molnar <mingo@redhat.com>,
  Borislav Petkov <bp@alien8.de>,  Dave Hansen
 <dave.hansen@linux.intel.com>,  x86@kernel.org,  "H. Peter Anvin"
 <hpa@zytor.com>,  Andrew Morton <akpm@linux-foundation.org>,  David
 Hildenbrand <david@kernel.org>,  Lorenzo Stoakes
 <lorenzo.stoakes@oracle.com>,  "Liam R. Howlett"
 <Liam.Howlett@oracle.com>,  Vlastimil Babka <vbabka@kernel.org>,  Mike
 Rapoport <rppt@kernel.org>,  Suren Baghdasaryan <surenb@google.com>,
  Michal Hocko <mhocko@suse.com>,  Trond Myklebust <trondmy@kernel.org>,
  Anna Schumaker <anna@kernel.org>,  Zi Yan <ziy@nvidia.com>,  Matthew
 Brost <matthew.brost@intel.com>,  Joshua Hahn <joshua.hahnjy@gmail.com>,
  Rakie Kim <rakie.kim@sk.com>,  Byungchul Park <byungchul@sk.com>,
  Gregory Price <gourry@gourry.net>,  Alistair Popple <apopple@nvidia.com>,
  Steven Rostedt <rostedt@goodmis.org>,  Masami Hiramatsu
 <mhiramat@kernel.org>,  Mathieu Desnoyers
 <mathieu.desnoyers@efficios.com>,  Brendan Jackman <jackmanb@google.com>,
  Johannes Weiner <hannes@cmpxchg.org>,  David Rientjes
 <rientjes@google.com>,  Davidlohr Bueso <dave@stgolabs.net>,  Fan Ni
 <nifan.cxl@gmail.com>,  Frank van der Linden <fvdl@google.com>,  Jonathan
 Cameron <jic23@kernel.org>,  Raghavendra K T <rkodsara@amd.com>,  "Rao,
 Bharata Bhasker" <bharata@amd.com>,  SeongJae Park <sj@kernel.org>,  Wei
 Xu <weixugc@google.com>,  Xuezheng Chu <xuezhengchu@huawei.com>,  Yiannis
 Nikolakopoulos <yiannis@zptcorp.com>,  dimitrios@palyvos.net,  Ryan
 Roberts <ryan.roberts@arm.com>,  Huan Nguyen <nhuhuan@google.com>,
  linux-kernel@vger.kernel.org,  linux-mm@kvack.org,
  linux-nfs@vger.kernel.org,  linux-trace-kernel@vger.kernel.org,  Alirad
 Malek <alirad.malek@zptcorp.com>
Subject: Re: [PATCH RFC v2 2/3] mm: new migrate_mode flag for async using
 non-temporal stores
In-Reply-To: <20260730-rfc-nt-demote-v2-2-452dbe3b5073@zptcorp.com> (Yiannis
	Nikolakopoulos's message of "Thu, 30 Jul 2026 17:02:58 +0200")
References: <20260730-rfc-nt-demote-v2-0-452dbe3b5073@zptcorp.com>
	<20260730-rfc-nt-demote-v2-2-452dbe3b5073@zptcorp.com>
Date: Wed, 05 Aug 2026 22:14:31 +0800
Message-ID: <87h5l88xiw.fsf@DESKTOP-5N7EMDA>
User-Agent: Gnus/5.13 (Gnus v5.13)
Precedence: bulk
X-Mailing-List: linux-nfs@vger.kernel.org
List-Id: <linux-nfs.vger.kernel.org>
List-Subscribe: <mailto:linux-nfs+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:linux-nfs+unsubscribe@vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=ascii

Yiannis Nikolakopoulos <yiannis.nikolakop@gmail.com> writes:

[snip]

> diff --git a/include/linux/migrate_mode.h b/include/linux/migrate_mode.h
> index 265c4328b36a..f7186e705b48 100644
> --- a/include/linux/migrate_mode.h
> +++ b/include/linux/migrate_mode.h
> @@ -3,6 +3,8 @@
>  #define MIGRATE_MODE_H_INCLUDED
>  /*
>   * MIGRATE_ASYNC means never block
> + * MIGRATE_ASYNC_NON_TEMPORAL_STORES means never block and use non-temporal
> + * stores if supported by the architecture
>   * MIGRATE_SYNC_LIGHT in the current implementation means to allow blocking
>   *	on most operations but not ->writepage as the potential stall time
>   *	is too significant
> @@ -10,10 +12,17 @@
>   */
>  enum migrate_mode {
>  	MIGRATE_ASYNC,
> +	MIGRATE_ASYNC_NON_TEMPORAL_STORES,
>  	MIGRATE_SYNC_LIGHT,
>  	MIGRATE_SYNC,
>  };

Is it better to turn migrate_mode parameter into migrate_flags?

---
Best Regards,
Huang, Ying
