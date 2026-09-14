Received: from smtp.kernel.org (aws-us-west-2-korg-mail-alma10-1.taild15c8.ts.net [100.103.45.18])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id DDDC435C19F;
	Mon, 14 Sep 2026 03:40:02 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=100.103.45.18
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1789357204; cv=none; b=Bz1bbXd7g4NUI3TERWNuqN74MGxTnxFVv/D9qfJCGbjIX8y4dSddxUAnVMoTQIuvvk2/BeXDP4tQoGeCHS3hWoXy5e+9HCO4f4f3ab9myjIDqevIEHGYe4mLj2MGVr9PmIX4JoGEBfYl9t/v2xxBGZdS3JvdFhbEK1T6yDoyIp4=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1789357204; c=relaxed/simple;
	bh=1A6s3fqev0839R6hce//sj+/jCLqDJTSBW2SC0bjfpA=;
	h=Date:From:To:Cc:Subject:Message-Id:In-Reply-To:References:
	 Mime-Version:Content-Type; b=YAIijsDBCk/O1l5y7L4q9Ort/+eTEJIG8ZLJxbEq+oY7rKz6bFNyRj9Uk57UkpPJq5pN4eizEHIJ6GE+Am3ubyyHbleMWkup/vT1EXfckm2ZsjQl9gIO10FbbWTE/3qXytcuLSj8wKwVcaGw4LgMoyauMnmGeuUqm/bVrKwe8EI=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dkim=pass (1024-bit key) header.d=linux-foundation.org header.i=@linux-foundation.org header.b=pHy6fbef; arc=none smtp.client-ip=100.103.45.18
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (1024-bit key) header.d=linux-foundation.org header.i=@linux-foundation.org header.b="pHy6fbef"
Received: by smtp.kernel.org (Postfix) with ESMTPSA id 92FF91F000FF;
	Mon, 14 Sep 2026 03:39:59 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
	d=linux-foundation.org; s=korg; t=1789357202;
	bh=x5zisV7HoQ8XMweM1XOT4E07P1NlnKsteMfQzVmO4Js=;
	h=Date:From:To:Cc:Subject:In-Reply-To:References;
	b=pHy6fbeflVTU8QtsqFS5eh8OvOR3ntwRr+lHZYMkoAT3ltm91/zKHpwN5XKZntEOS
	 ILIVvwKavB+/VLgc77oFP5R90/PbqE2ALcouMF/TdFK9XZ9ovr5QioyLZB1yLh6r2e
	 gdt1bOJXa+0zPlb1i7I7WNxSlmbqXRfHn0UsNCp4=
Date: Sun, 13 Sep 2026 20:39:59 -0700
From: Andrew Morton <akpm@linux-foundation.org>
To: Zi Yan <ziy@nvidia.com>
Cc: David Hildenbrand <david@kernel.org>, "Matthew Wilcox (Oracle)"
 <willy@infradead.org>, Muchun Song <muchun.song@linux.dev>, Lorenzo Stoakes
 <ljs@kernel.org>, "Liam R. Howlett" <liam@infradead.org>, Vlastimil Babka
 <vbabka@kernel.org>, Mike Rapoport <rppt@kernel.org>, Suren Baghdasaryan
 <surenb@google.com>, Michal Hocko <mhocko@suse.com>, Baolin Wang
 <baolin.wang@linux.alibaba.com>, Nico Pache <nico.pache@linux.dev>, Ryan
 Roberts <ryan.roberts@arm.com>, Dev Jain <dev.jain@arm.com>, Barry Song
 <baohua@kernel.org>, Lance Yang <lance.yang@linux.dev>, Usama Arif
 <usama.arif@linux.dev>, Gregory Price <gourry@gourry.net>, Ying Huang
 <ying.huang@linux.alibaba.com>, Alistair Popple <apopple@nvidia.com>,
 Johannes Weiner <hannes@cmpxchg.org>, Qi Zheng <qi.zheng@linux.dev>,
 Shakeel Butt <shakeel.butt@linux.dev>, Kairui Song <kasong@tencent.com>,
 linux-mm@kvack.org, linux-kernel@vger.kernel.org, Minchan Kim
 <minchan@kernel.org>, Sergey Senozhatsky <senozhatsky@chromium.org>, Peter
 Zijlstra <peterz@infradead.org>, Ingo Molnar <mingo@redhat.com>, Arnaldo
 Carvalho de Melo <acme@kernel.org>, Namhyung Kim <namhyung@kernel.org>,
 Thomas Gleixner <tglx@kernel.org>, Borislav Petkov <bp@alien8.de>, Dave
 Hansen <dave.hansen@linux.intel.com>, x86@kernel.org, Mark Rutland
 <mark.rutland@arm.com>, Alexander Shishkin
 <alexander.shishkin@linux.intel.com>, Jiri Olsa <jolsa@kernel.org>, Ian
 Rogers <irogers@google.com>, Adrian Hunter <adrian.hunter@intel.com>, James
 Clark <james.clark@linaro.org>, "H. Peter Anvin" <hpa@zytor.com>,
 linux-perf-users@vger.kernel.org, Juergen Gross <jgross@suse.com>, Stefano
 Stabellini <sstabellini@kernel.org>, Oleksandr Tyshchenko
 <oleksandr_tyshchenko@epam.com>, xen-devel@lists.xenproject.org, Eric
 Biggers <ebiggers@kernel.org>, "Theodore Y. Ts'o" <tytso@mit.edu>, Jaegeuk
 Kim <jaegeuk@kernel.org>, linux-fscrypt@vger.kernel.org, Oscar Salvador
 <osalvador@suse.de>, Chao Yu <chao@kernel.org>,
 linux-f2fs-devel@lists.sourceforge.net, Tal Zussman <tz2294@columbia.edu>,
 Gao Xiang <xiang@kernel.org>, Jan Kara <jack@suse.cz>, Yue Hu
 <zbestahu@gmail.com>, Jeffle Xu <jefflexu@linux.alibaba.com>, Sandeep
 Dhavale <dhavale@google.com>, Hongbo Li <hongbohbli@tencent.com>, Chunhai
 Guo <guochunhai@vivo.com>, linux-erofs@lists.ozlabs.org,
 linux-fsdevel@vger.kernel.org, Steven Rostedt <rostedt@goodmis.org>, Masami
 Hiramatsu <mhiramat@kernel.org>, Mathieu Desnoyers
 <mathieu.desnoyers@efficios.com>, Matthew Brost <matthew.brost@intel.com>,
 Joshua Hahn <joshua.hahnjy@gmail.com>, Rakie Kim <rakie.kim@sk.com>,
 Byungchul Park <byungchul@sk.com>, Axel Rasmussen
 <axelrasmussen@google.com>, Yuanchu Xie <yuanchu@google.com>, Wei Xu
 <weixugc@google.com>, linux-trace-kernel@vger.kernel.org, Trond Myklebust
 <trondmy@kernel.org>, Anna Schumaker <anna@kernel.org>,
 linux-nfs@vger.kernel.org, Ilya Dryomov <idryomov@gmail.com>, Alex Markuze
 <amarkuze@redhat.com>, Viacheslav Dubeyko <slava@dubeyko.com>,
 ceph-devel@vger.kernel.org, Song Liu <song@kernel.org>, Yu Kuai
 <yukuai@fygo.io>, Li Nan <magiclinan@didiglobal.com>, Xiao Ni
 <xiao@kernel.org>, linux-raid@vger.kernel.org, Richard Weinberger
 <richard@nod.at>, Zhihao Cheng <chengzhihao1@huawei.com>,
 linux-mtd@lists.infradead.org, Baoquan He <baoquan.he@linux.dev>, Pasha
 Tatashin <pasha.tatashin@soleen.com>, Pratyush Yadav <pratyush@kernel.org>,
 Jonathan Corbet <corbet@lwn.net>, Dave Young <ruirui.yang@linux.dev>, Shuah
 Khan <skhan@linuxfoundation.org>, kexec@lists.infradead.org,
 linux-doc@vger.kernel.org
Subject: Re: [PATCH v4 00/16] Remove PG_private by using page/folio->private
 checks instead
Message-Id: <20260913203959.6b46b0b5a052aec818a7f267@linux-foundation.org>
In-Reply-To: <20260913-remove-pg_private-v4-0-848550f7574e@nvidia.com>
References: <20260913-remove-pg_private-v4-0-848550f7574e@nvidia.com>
X-Mailer: Sylpheed 3.8.0beta1 (GTK+ 2.24.33; x86_64-pc-linux-gnu)
Precedence: bulk
X-Mailing-List: linux-nfs@vger.kernel.org
List-Id: <linux-nfs.vger.kernel.org>
List-Subscribe: <mailto:linux-nfs+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:linux-nfs+unsubscribe@vger.kernel.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit

On Sun, 13 Sep 2026 22:23:58 -0400 Zi Yan <ziy@nvidia.com> wrote:

> This patchset removes PG_private to make space for upcoming PG_folio for
> identifying pages from a folio (more details in Note below). Instead of
> checking PG_private, all code is changed to check page/folio->private !=
> NULL instead.
> 
> MM people are cc'd on all patches and subsystem people are cc'd on the
> cover letter and corresponding patches.
> 
> Patch 6 is picked up separately in f2fs tree, but since mm-new does not
> have it yet, it is sent for MM testing.

AI review claims to have found a pre-existing critical level deadlock
in f2fs:

	https://sashiko.dev/#/patchset/20260913-remove-pg_private-v4-0-848550f7574e@nvidia.com

it also had a few things to say about this patchset and, as always,
hugetlb.c.


Thanks, The MM bits appear adequately reviewed and review of the non-MM
bits are, as usual:

  Great to have but I won't permit lack of other-than-MM review to
  block MM improvements.

So I'll queue it all up and shall push it into -next after a few days.

Acks from non-MM maintainers are appreciated.

If a non-MM patch appears in linux-next I'll autodrop the mm.git copy
of that patch.

