Received: from mail-ed1-f50.google.com (mail-ed1-f50.google.com [209.85.208.50])
	(using TLSv1.2 with cipher ECDHE-RSA-AES128-GCM-SHA256 (128/128 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 8FC6E44162B
	for <linux-nfs@vger.kernel.org>; Thu, 30 Jul 2026 15:03:29 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=209.85.208.50
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1785423812; cv=none; b=jj4jmwU8es+b1s1t8EOP06eKRzCOJ3Q4uNt9BkcneJ/2LtEpDCwRkjY3/Ro8h2LY4OZoDO3EcnCIlmz6/FZ+9C4CgfIDBJjP0rrjojrtJG2lzpNl0VZa5/Zw8lnPTuej7TZA0TpIvdzg7cxk2+yaVmqVbYz9y0BqCiKzkymgegA=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1785423812; c=relaxed/simple;
	bh=PLHblDJYyXTlsqe+7yffW40SqnFtuBNOpxiyUDpA/Js=;
	h=From:Date:Subject:MIME-Version:Content-Type:Message-Id:References:
	 In-Reply-To:To:Cc; b=DiopcmcHwR4Kqyyqp9mpNabqQAoND+SdL0sIr0F9luOtaQJ9HcZu2V2LkXE16liAVwgL2z4c2coJkhW0s0NqalwB+21PH7bm86coYbLvqbTMTHHeVvGKcGZMcFBFQIBer0UtCwHfzBb5tC0H/L2dWrGSUyHPyxz28Xa8EiIxGpk=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dmarc=pass (p=none dis=none) header.from=gmail.com; spf=pass smtp.mailfrom=gmail.com; dkim=pass (2048-bit key) header.d=gmail.com header.i=@gmail.com header.b=AnVz+PrL; arc=none smtp.client-ip=209.85.208.50
Authentication-Results: smtp.subspace.kernel.org; dmarc=pass (p=none dis=none) header.from=gmail.com
Authentication-Results: smtp.subspace.kernel.org; spf=pass smtp.mailfrom=gmail.com
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=gmail.com header.i=@gmail.com header.b="AnVz+PrL"
Received: by mail-ed1-f50.google.com with SMTP id 4fb4d7f45d1cf-69fab5a852cso3313221a12.0
        for <linux-nfs@vger.kernel.org>; Thu, 30 Jul 2026 08:03:29 -0700 (PDT)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=gmail.com; s=20251104; t=1785423808; x=1786028608; darn=vger.kernel.org;
        h=cc:to:in-reply-to:references:message-id:content-transfer-encoding
         :content-type:mime-version:subject:date:from:from:to:cc:subject:date
         :message-id:reply-to:content-type;
        bh=jbxhIHpP+P+duAb0b+RpjF7CmIf+HVEI8a2PNCDtUeY=;
        b=AnVz+PrLnbk6AzMQ0Yuxn+6uilON49za8ASZjVWYMAyDVDlrKxuy66/hW+5iQCPPxF
         GwV/X3M+f+urHvIVucTbgw8srrb4lfcnEkT0EFLK6eHy6Ux4xfO5hRvQIxlC21WQN00Z
         CGM12gU5uukZ98XLvm23Y8AakvglUutncVvNS1KcPhYHAFAuHyfj3o6kJ9+ReNipBKE/
         nGxe+yoHuQfe6uo1rd1MT8Ht8WoYHxd4H1YrB76h3k1TMlhRbh1FlVyH+2Zjo5MvZt+H
         1ei7Sf8fCWboWSvtuBXQDeP3DqRVxPxBzEDqYwFD8kFEW/FfakRO/Itmb025p78oNE0P
         1EYA==
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20251104; t=1785423808; x=1786028608;
        h=cc:to:in-reply-to:references:message-id:content-transfer-encoding
         :content-type:mime-version:subject:date:from:x-gm-gg
         :x-gm-message-state:from:to:cc:subject:date:message-id:reply-to
         :content-type;
        bh=jbxhIHpP+P+duAb0b+RpjF7CmIf+HVEI8a2PNCDtUeY=;
        b=SCLuX9o+hsfsNvuBQtsrmeKVs+AEJ/ZF1Vx0HQH/zTImBjLcNa78QDiHagg1tRWlt8
         cIshI+VTZjtddxOF1/hSwvjfb4TbHYVmrlse03fpQqRFrkRaBe+3HpPoinbdS6jR4hyB
         1Lns5s1mGkVyY2zt91rGkDR/fgeZNcT5jTH3DSAVALZsXE6DLOc7xPmgcLR+5eVtSVBf
         fIMBFweRrMlVSQyFN9ehTYiXNY44VO+jRLfU+ZRpD+t6d7VS3m4OYNMwnkYh0M6TOJfE
         un7p5VVSe14GXIlEvJKhWb/kbIM181V9caVJtPxn6qO1L/C8OtSKfWxvHOwocDtGfNXG
         0gHw==
X-Forwarded-Encrypted: i=1; AHgh+Rq4HYHRnC+2pCVdXJNH7gBhPzjPgygIvXBJxNlpreyrJwLM2WbAJpSiUaofGWzKkhsU9vu1L6P66xY=@vger.kernel.org
X-Gm-Message-State: AOJu0YyLv64LGC42YNcTTNiHvWZGJ60JWOu7FikDvHqwLfj9nzejDVEl
	76NpiKYkXrH7y2jxAJmO+cL7moD7t4joQduTY15+oOqrAJ+uTYFxZM15
X-Gm-Gg: AR+sD11ryYz4qpqLVfwFimxfy7VKvRQD6xu14xGT5zhJZBXxaXqKf5+gWkvZQcZk/wH
	1oxM1+DYGmhRAM9sK0rli3j5eK54NzUnFjqzcczAAyTQY2ipMziOVwvrpFQsiXqTozWsilN/6LO
	H7Tm3k+zzqA/ku1Zg6AmzGKgUWoc0CNEwA5my5CMTlSQJiuHI/KjTMVtv434t7qh4UELdR7yg1I
	VUU+VD6BSlMxEVm7wHv6AZnBpsFZshzYH9prBmPbPLdYlX85kQoPBnpCRC9Eyo8HvoVboiuSXnY
	Y95uzaTitnwDq3c5ASNsJfTljUkxMgNUbXcg6JCsJlfzY+J6i5g5laqpj07H022Ygu3ER+KiXj6
	oKGOXqT3ksNW2WIBzZ36IVrg/U6+A+Osw0chN26EbafY+3OwpGnrxVmagiqIWzZ+hscQ7jDNQnv
	XZV4RiBZFBS7TJ/bPis4zZVfnZ1k5TmHSLw4og+vY5BTYRYW5NLn5vZjoZdHQIxBrdJdWpRM9od
	37twQJ1ARqZZyjwBuhAjIdav0v7rKKekA==
X-Received: by 2002:a05:6402:5418:b0:697:e953:d14d with SMTP id 4fb4d7f45d1cf-6a07b8148acmr1397265a12.17.1785423807694;
        Thu, 30 Jul 2026 08:03:27 -0700 (PDT)
Received: from [127.0.1.1] (h-62-63-197-109.NA.cust.bahnhof.se. [62.63.197.109])
        by smtp.gmail.com with ESMTPSA id 4fb4d7f45d1cf-6a07bf18ff8sm729116a12.0.2026.07.30.08.03.25
        (version=TLS1_3 cipher=TLS_AES_256_GCM_SHA384 bits=256/256);
        Thu, 30 Jul 2026 08:03:27 -0700 (PDT)
From: Yiannis Nikolakopoulos <yiannis.nikolakop@gmail.com>
Date: Thu, 30 Jul 2026 17:02:59 +0200
Subject: [PATCH RFC v2 3/3] mm: use non-temporal stores for demotion
Precedence: bulk
X-Mailing-List: linux-nfs@vger.kernel.org
List-Id: <linux-nfs.vger.kernel.org>
List-Subscribe: <mailto:linux-nfs+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:linux-nfs+unsubscribe@vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Message-Id: <20260730-rfc-nt-demote-v2-3-452dbe3b5073@zptcorp.com>
References: <20260730-rfc-nt-demote-v2-0-452dbe3b5073@zptcorp.com>
In-Reply-To: <20260730-rfc-nt-demote-v2-0-452dbe3b5073@zptcorp.com>
To: Thomas Gleixner <tglx@kernel.org>, Ingo Molnar <mingo@redhat.com>, 
 Borislav Petkov <bp@alien8.de>, Dave Hansen <dave.hansen@linux.intel.com>, 
 x86@kernel.org, "H. Peter Anvin" <hpa@zytor.com>, 
 Andrew Morton <akpm@linux-foundation.org>, 
 David Hildenbrand <david@kernel.org>, 
 Lorenzo Stoakes <lorenzo.stoakes@oracle.com>, 
 "Liam R. Howlett" <Liam.Howlett@oracle.com>, 
 Vlastimil Babka <vbabka@kernel.org>, Mike Rapoport <rppt@kernel.org>, 
 Suren Baghdasaryan <surenb@google.com>, Michal Hocko <mhocko@suse.com>, 
 Trond Myklebust <trondmy@kernel.org>, Anna Schumaker <anna@kernel.org>, 
 Zi Yan <ziy@nvidia.com>, Matthew Brost <matthew.brost@intel.com>, 
 Joshua Hahn <joshua.hahnjy@gmail.com>, Rakie Kim <rakie.kim@sk.com>, 
 Byungchul Park <byungchul@sk.com>, Gregory Price <gourry@gourry.net>, 
 Ying Huang <ying.huang@linux.alibaba.com>, 
 Alistair Popple <apopple@nvidia.com>, Steven Rostedt <rostedt@goodmis.org>, 
 Masami Hiramatsu <mhiramat@kernel.org>, 
 Mathieu Desnoyers <mathieu.desnoyers@efficios.com>, 
 Brendan Jackman <jackmanb@google.com>, Johannes Weiner <hannes@cmpxchg.org>
Cc: David Rientjes <rientjes@google.com>, 
 Davidlohr Bueso <dave@stgolabs.net>, Fan Ni <nifan.cxl@gmail.com>, 
 Frank van der Linden <fvdl@google.com>, Jonathan Cameron <jic23@kernel.org>, 
 Raghavendra K T <rkodsara@amd.com>, 
 "Rao, Bharata Bhasker" <bharata@amd.com>, SeongJae Park <sj@kernel.org>, 
 Wei Xu <weixugc@google.com>, Xuezheng Chu <xuezhengchu@huawei.com>, 
 Yiannis Nikolakopoulos <yiannis@zptcorp.com>, dimitrios@palyvos.net, 
 Ryan Roberts <ryan.roberts@arm.com>, Huan Nguyen <nhuhuan@google.com>, 
 linux-kernel@vger.kernel.org, linux-mm@kvack.org, linux-nfs@vger.kernel.org, 
 linux-trace-kernel@vger.kernel.org, 
 Yiannis Nikolakopoulos <yiannis.nikolakop@gmail.com>, 
 Alirad Malek <alirad.malek@zptcorp.com>
X-Mailer: b4 0.15.2

From: Alirad Malek <alirad.malek@zptcorp.com>

Memory demoted to a lower tier is assumed to be cold and most likely out of
the CPU's last level cache. Additionally, in certain demotion targets (e.g.
CXL devices with compressed memory) the bandwidth can be negatively
impacted by the eviction patterns of the last level cache when standard
memcpy is used. In supported architectures (currently X86_64), use the
MIGRATE_ASYNC_NON_TEMPORAL_STORES flag in demotions to trigger the folio
copy path using non-temporal stores.

Signed-off-by: Alirad Malek <alirad.malek@zptcorp.com>
Co-developed-by: Yiannis Nikolakopoulos <yiannis.nikolakop@gmail.com>
Signed-off-by: Yiannis Nikolakopoulos <yiannis.nikolakop@gmail.com>
---
 mm/migrate.c | 10 +++++++++-
 1 file changed, 9 insertions(+), 1 deletion(-)

diff --git a/mm/migrate.c b/mm/migrate.c
index ff6cf50e7b0b..c7c62700d541 100644
--- a/mm/migrate.c
+++ b/mm/migrate.c
@@ -862,7 +862,10 @@ static int __migrate_folio(struct address_space *mapping, struct folio *dst,
 	if (folio_ref_count(src) != expected_count)
 		return -EAGAIN;
 
-	rc = folio_mc_copy(dst, src);
+	if (mode == MIGRATE_ASYNC_NON_TEMPORAL_STORES)
+		rc = folio_mc_copy_nt(dst, src);
+	else
+		rc = folio_mc_copy(dst, src);
 	if (unlikely(rc))
 		return rc;
 
@@ -2081,6 +2084,11 @@ int migrate_pages(struct list_head *from, new_folio_t get_new_folio,
 	LIST_HEAD(split_folios);
 	struct migrate_pages_stats stats;
 
+	if (IS_ENABLED(CONFIG_X86_64) &&
+		IS_ENABLED(CONFIG_ARCH_HAS_UACCESS_FLUSHCACHE) &&
+		reason == MR_DEMOTION && mode == MIGRATE_ASYNC)
+		mode = MIGRATE_ASYNC_NON_TEMPORAL_STORES;
+
 	trace_mm_migrate_pages_start(mode, reason);
 
 	memset(&stats, 0, sizeof(stats));

-- 
2.43.0

