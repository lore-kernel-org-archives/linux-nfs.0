Received: from mail-ed1-f48.google.com (mail-ed1-f48.google.com [209.85.208.48])
	(using TLSv1.2 with cipher ECDHE-RSA-AES128-GCM-SHA256 (128/128 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id DC61E3769F5
	for <linux-nfs@vger.kernel.org>; Thu, 30 Jul 2026 15:03:22 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=209.85.208.48
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1785423804; cv=none; b=tntC8OdwPvtHVKVuMI4iVYcCCH/gpBiV+csqAdzgVzKYMXKHmlUks0w5CnDvR9DArJDZjnBLUJU4s9W7P3SagHOf/3g1vLIB5ZIWP8NoGQgth7nRYskdgcVMGpKRdBA9s5ZhZt3Wv59LaehKyOyneml592Lxc84N31aYZg5Sc/A=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1785423804; c=relaxed/simple;
	bh=sl+QWHjFtbNBqIyf/rEVDoZRiqifr1hht5vwSu7//gI=;
	h=From:Subject:Date:Message-Id:MIME-Version:Content-Type:To:Cc; b=kev3LMMS0CWeggMtGjKDJQFmaq/9iyNWCQN5g2MSMR4wmCXfI/nfQJf4zHIZSwI+RVeQLFXfeTqAKvCPNrpDxFJL6wS+LAdti5OeluUNy37tIACNI+qlP4Ya1RX+LtvpfF3xtZ0FZ0LMIfDz5ueexpzw57banQpswVwFzrQmQdQ=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dmarc=pass (p=none dis=none) header.from=gmail.com; spf=pass smtp.mailfrom=gmail.com; dkim=pass (2048-bit key) header.d=gmail.com header.i=@gmail.com header.b=EggsKX2y; arc=none smtp.client-ip=209.85.208.48
Authentication-Results: smtp.subspace.kernel.org; dmarc=pass (p=none dis=none) header.from=gmail.com
Authentication-Results: smtp.subspace.kernel.org; spf=pass smtp.mailfrom=gmail.com
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=gmail.com header.i=@gmail.com header.b="EggsKX2y"
Received: by mail-ed1-f48.google.com with SMTP id 4fb4d7f45d1cf-69fc6a09b5aso3735797a12.3
        for <linux-nfs@vger.kernel.org>; Thu, 30 Jul 2026 08:03:22 -0700 (PDT)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=gmail.com; s=20251104; t=1785423801; x=1786028601; darn=vger.kernel.org;
        h=cc:to:content-transfer-encoding:content-type:mime-version
         :message-id:date:subject:from:from:to:cc:subject:date:message-id
         :reply-to:content-type;
        bh=9UdmMkwBkbwHpnQxJHOFAJgHRQBiC2eogIeFtsGPq2M=;
        b=EggsKX2ywbsLYpbhN6cPLUBQ/GX+YTh94tU4rgRs89PdQdEqkxhZXWxTuBvdpSq44y
         JcQ0p0YwAr5Xw1mXaVeWME4vezJUEgMhf3ZIyYgfiugQhpHuMNbgvviPHoP1WPuDRMzh
         I7S/Zvt5HBVCYXsIddoVwkiKDrXzdFHtLC0UJXq1JbWkqrDBsuYfngG/gjT26wOvVi7U
         qAgBOhFRPNTH2W8rzFWIgS7K5S1Na/jriGMiRdYjTx/LkQ70+hKKvCVtB0MHXvbdUajY
         4JSo15GYKsvfv7zD7Si7zbTuqrdm+aU9RH5mJXDPKMymehUvzcunfFaaTOgjQdVfvgNy
         8ZQA==
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20251104; t=1785423801; x=1786028601;
        h=cc:to:content-transfer-encoding:content-type:mime-version
         :message-id:date:subject:from:x-gm-gg:x-gm-message-state:from:to:cc
         :subject:date:message-id:reply-to:content-type;
        bh=9UdmMkwBkbwHpnQxJHOFAJgHRQBiC2eogIeFtsGPq2M=;
        b=H7TxWwqNGR58tb+KmDAE+Kl7dOUM5nirQ0BvNWLgA/8XXN29PlPt77GiPqXU52eqRt
         Ng2yP8xiQMZqrOiUhokQJWtksW+kGnISynXCXim2g7vZB2kFAJQbCToMQy/7Uegi5QdH
         q5/a0kqUNFIKVl4dzOJCeMszZmJ4DGl6sa33cVdGEpNwcZBO7uFiqr/Fu20fnA/RwQ0d
         OYAOQVEnWcTmo894T+/mM8zvxLc2wp8MjnLuW5adMClaMInUFGsaXrkLky0MSq/CSwa0
         8oopDgNQ0OGCboXb7sEbesqxuUZmZJfC7+1ipkQpAjjR8Bzi+VkCxCP7P/yV6SNFhmeL
         Ia0Q==
X-Forwarded-Encrypted: i=1; AHgh+RqoHvtVyzD6WB1Cn7VhP8TOrB9M8LPdEqSQSXREQt3XqsLZvsYHrGW0d3GjP34gYAVgxVthxwCf/fg=@vger.kernel.org
X-Gm-Message-State: AOJu0YyUcFm/F4v189HIHWZC+U1phD6xCYMs3Rs+ciAU2c0THrz8YBL+
	yZDDROezBfLzdy59G52i7Am2mqksq/SGZbl2/V5CIrej7eiEzs+YHr+z
X-Gm-Gg: AR+sD11qiikVzA+j32mhIoUyHWq9SiHUuSEVx4FWoXG5+arZaqkbafkPBQm0ZvcP3lc
	y9q4AoueWYHMnYprQrmwmWRy3hsv9cw7iRew+EnHU9wopUWYHe2J2w3eb3n3ZI+LKbjuiTdr55r
	4tu/s4c0crjONE6/sgwyR3gErXBHhH3Dy7wbwkgkXHZQuye8geIh25U/UqtR+vEvA6CEIt/D/hG
	4uCR5PEp0sPXAGjUQpIYMjPWJfyR9ussS/JQfJScxoyGiArjlTHWiMSzhIyj5/xecL2tDhB5Sis
	XSDsE7W+cLdDUwQW4vKnCP5PZuROE86eNZ6a1/0bahpCIvmUWWwCixOLAnwZ5p4E5WQe4npweAd
	mArjLVEZ5y0Ci43MRVuXkXVR41strkBn9sng/lqLv3j0ipUinO5T09xs+FDpPj2ZTJAiQYRoU6H
	W8KPKlbFCEiYr4hESmnh7V7TRLMDD07uks+PTM/l+b1dJ+4tGbg9fg0zkqS2Dr4FkjN7z//V+C4
	hl2M0k5cMRfze8unPD03Bs724VcU2U4mQIF7TKUxQ5TMw==
X-Received: by 2002:a05:6402:3604:b0:6a0:32ec:511e with SMTP id 4fb4d7f45d1cf-6a090d3ef16mr386314a12.11.1785423800678;
        Thu, 30 Jul 2026 08:03:20 -0700 (PDT)
Received: from [127.0.1.1] (h-62-63-197-109.NA.cust.bahnhof.se. [62.63.197.109])
        by smtp.gmail.com with ESMTPSA id 4fb4d7f45d1cf-6a07bf18ff8sm729116a12.0.2026.07.30.08.03.17
        (version=TLS1_3 cipher=TLS_AES_256_GCM_SHA384 bits=256/256);
        Thu, 30 Jul 2026 08:03:19 -0700 (PDT)
From: Yiannis Nikolakopoulos <yiannis.nikolakop@gmail.com>
Subject: [PATCH RFC v2 0/3] Demote to lower tier using non-temporal stores
Date: Thu, 30 Jul 2026 17:02:56 +0200
Message-Id: <20260730-rfc-nt-demote-v2-0-452dbe3b5073@zptcorp.com>
Precedence: bulk
X-Mailing-List: linux-nfs@vger.kernel.org
List-Id: <linux-nfs.vger.kernel.org>
List-Subscribe: <mailto:linux-nfs+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:linux-nfs+unsubscribe@vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
X-B4-Tracking: v=1; b=H4sIAKFna2oC/3WNwQrCMBBEf6Xs2ZU0aKGeBKEf4FV6SJONjdAmb
 GJQS//dtp49zvDmzQSR2FGEUzEBU3bR+XEJcleA7tV4J3RmySCFrMRRVshW45jQ0OATobDKKmO
 NEaKCZROYrHttvhtcmwu0vzI+uwfptJpWrHcxeX5vr7nc4D8HuUSB1NW6PkhpFNnzJyTtOey1H
 6Cd5/kLyuwjvMMAAAA=
X-Change-ID: 20260526-rfc-nt-demote-0fafadfdd006
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

In most memory tiering scenarios, the memory to be demoted is expected
to be cold and most likely out of the node's last-level cache (as well
as target pages in the target node). Using non-temporal stores instead
of a standard memcpy path can reduce the cache pollution in the local
node and the bandwidth overhead to the target node. Furthermore, for
certain types of CXL devices that support in-line memory compression,
the last-level cache eviction patterns can negatively affect the
bandwidth of the device. Non-temporal stores can mitigate this.

This patch-set introduces a new migrate_mode flag for using non-temporal
stores that is used only in the demotion path. Patch 1 adds some helpers in
x86 and mm to bring non-temporal stores support to a respective folio_copy
function. Patch 2 adds the new flag and necessary changes for compatibility
with the existing behavior. Patch 3 uses the new flag for demotions.

Experimental data: in a CXL system with 1 memory expander, a microbenchmark
that allocates N=64 GB memory in the local node and then triggers demotion
using memory.reclaim, shows a practically complete elimination of read
traffic on the device, i.e. write traffic is N GB with and without the
patch, while read traffic drops from N to almost 0 with the patch.

Opens:
1. There is some "duplication" in the x86 tree and a bit in mm. Can we do
   something better there? As it is now in copy_mc_to_kernel_nt we
duplicate the machine check functionality, which if available will override
the non-temporal. We were not sure how to prioritize these two and what's
the best approach here. Can we completely skip the machine checked for this
path? Huan Nguyen has some ideas here that we will align for the next
version.
2. I am not sure how this should be structured so that it is easily
adopted in other architecture trees (e.g. aarch64). We rely on
memcpy_flushcache for x86_64 but this does not use non temporal stores
in ARM. ARM support is currently out of our scope but any input is
appreciated.

Signed-off-by: Yiannis Nikolakopoulos <yiannis.nikolakop@gmail.com>
---
Changes in v2:
- Remove the KConfig option that was guarding this feature (patch 3) and
  use it always in x86_64 and memcpy_flushcache (non-temporal stores
should be there).
- Link to v1: https://patch.msgid.link/20260526-rfc-nt-demote-v1-0-eb9c9422daef@zptcorp.com

To: Thomas Gleixner <tglx@kernel.org>
To: Ingo Molnar <mingo@redhat.com>
To: Borislav Petkov <bp@alien8.de>
To: Dave Hansen <dave.hansen@linux.intel.com>
To: x86@kernel.org
To: "H. Peter Anvin" <hpa@zytor.com>
To: Andrew Morton <akpm@linux-foundation.org>
To: David Hildenbrand <david@kernel.org>
To: Lorenzo Stoakes <lorenzo.stoakes@oracle.com>
To: "Liam R. Howlett" <Liam.Howlett@oracle.com>
To: Vlastimil Babka <vbabka@kernel.org>
To: Mike Rapoport <rppt@kernel.org>
To: Suren Baghdasaryan <surenb@google.com>
To: Michal Hocko <mhocko@suse.com>
To: Trond Myklebust <trondmy@kernel.org>
To: Anna Schumaker <anna@kernel.org>
To: Zi Yan <ziy@nvidia.com>
To: Matthew Brost <matthew.brost@intel.com>
To: Joshua Hahn <joshua.hahnjy@gmail.com>
To: Rakie Kim <rakie.kim@sk.com>
To: Byungchul Park <byungchul@sk.com>
To: Gregory Price <gourry@gourry.net>
To: Ying Huang <ying.huang@linux.alibaba.com>
To: Alistair Popple <apopple@nvidia.com>
To: Steven Rostedt <rostedt@goodmis.org>
To: Masami Hiramatsu <mhiramat@kernel.org>
To: Mathieu Desnoyers <mathieu.desnoyers@efficios.com>
To: Brendan Jackman <jackmanb@google.com>
To: Johannes Weiner <hannes@cmpxchg.org>
Cc: linux-kernel@vger.kernel.org
Cc: linux-mm@kvack.org
Cc: linux-nfs@vger.kernel.org
Cc: linux-trace-kernel@vger.kernel.org

---
Alirad Malek (3):
      mm, x86: support copying a folio using non-temporal stores
      mm: new migrate_mode flag for async using non-temporal stores
      mm: use non-temporal stores for demotion

 arch/x86/include/asm/uaccess.h |  4 ++++
 arch/x86/lib/copy_mc.c         | 26 ++++++++++++++++++++++++++
 fs/nfs/write.c                 |  2 +-
 include/linux/highmem.h        | 32 ++++++++++++++++++++++++++++++++
 include/linux/migrate_mode.h   |  9 +++++++++
 include/linux/mm.h             |  1 +
 include/trace/events/migrate.h |  1 +
 mm/compaction.c                | 18 +++++++++---------
 mm/migrate.c                   | 22 +++++++++++++++-------
 mm/util.c                      | 17 +++++++++++++++++
 10 files changed, 115 insertions(+), 17 deletions(-)
---
base-commit: 1f318b96cc84d7c2ab792fcc0bfd42a7ca890681
change-id: 20260526-rfc-nt-demote-0fafadfdd006

Best regards,
--  
Yiannis Nikolakopoulos <yiannis.nikolakop@gmail.com>

