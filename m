Received: from smtp.kernel.org (aws-us-west-2-korg-mail-alma10-1.taild15c8.ts.net [100.103.45.18])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id B4E6755C312;
	Tue, 22 Sep 2026 15:31:30 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=100.103.45.18
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1790091091; cv=none; b=eydvb8VjEs9Uur6DiQznYL9pJbJx2XMCBNuCAbHU/yvl1S8L4wBoCh+qZ613Ltusxt6ZQLOo9f8eY+YqilUetkhK9kjfNGN2JRInRg7GdxW1Ze8i4jvBc4a/qaPO5oIQbZsu6WbuwSfAEhhIg/wSawlWBIdgEmIoYO/MEKpwRdI=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1790091091; c=relaxed/simple;
	bh=NALfkOxOZukdaM9bPf10hwBO/x1kAs+vxmEyMf4s694=;
	h=Date:From:To:Cc:Subject:Message-ID:References:MIME-Version:
	 Content-Type:Content-Disposition:In-Reply-To; b=GaZYUXX7pLzOKkV97cKsyoTrGWhkL96dOJR5Z+TdCfJtnOp/DDZ06gzxhoAqf6xX+f/e8KH9ydEWNoBCvspeerSfyfccGMYCcDR2DLFshMuFBFys2sBJxfMz1M9ZTFvT8djzeNSp4oDgHYJKzugYRZN5M6h9WX+Tc51KgAbMsuA=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.b=oxgbajWA; arc=none smtp.client-ip=100.103.45.18
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.b="oxgbajWA"
Received: by smtp.kernel.org (Postfix) with ESMTPSA id 971F71F00893;
	Tue, 22 Sep 2026 15:31:26 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=kernel.org;
	s=k20260515; t=1790091090;
	bh=VFYj6sjedfWGEBuGl++9heS9zoD83sYWZIxoZFH52Mw=;
	h=Date:From:To:Cc:Subject:References:In-Reply-To;
	b=oxgbajWAx+ewgz3EYGgJPYtZfNNrVy2jiDvlrL0XB6QieOmgNe9oJ8tWYTAmWkd4E
	 40O1bShYyuGwabzOZg2yryGvTCOWVoLErNmP15TezU6CcK1+IP50a2puK4iDmaw6R3
	 PCwUfPw/jYwdSq8HtaOBJAU/3KQvk7VOfDVSLU+W6MZTQuGVG14os2s8QuaTXuRpZy
	 c1E7BQMp5Oh5V6N9yXEOXRU2Ns8Xz5BjaAREZfd68p1jzII0svn4YeEB6D4D+XgUXP
	 mn6RKCk0xuOhAtFCkmd48wAcJ6k5w8jrTIJhK2olCjTjtXsHqi1z/Ac++TcJ8CKg7E
	 LVSLUkJaZCs2w==
Date: Tue, 22 Sep 2026 15:31:25 +0000
From: Jaegeuk Kim <jaegeuk@kernel.org>
To: Nanzhe Zhao <nzzhao.sigma@gmail.com>
Cc: Zi Yan <ziy@nvidia.com>, Qi Zheng <qi.zheng@linux.dev>,
	Matthew Brost <matthew.brost@intel.com>,
	Alistair Popple <apopple@nvidia.com>, ceph-devel@vger.kernel.org,
	Eric Biggers <ebiggers@kernel.org>, xen-devel@lists.xenproject.org,
	Gregory Price <gourry@gourry.net>,
	Arnaldo Carvalho de Melo <acme@kernel.org>,
	linux-fscrypt@vger.kernel.org,
	Shuah Khan <skhan@linuxfoundation.org>,
	David Hildenbrand <david@kernel.org>,
	Suren Baghdasaryan <surenb@google.com>,
	linux-kernel@vger.kernel.org, Nico Pache <nico.pache@linux.dev>,
	linux-perf-users@vger.kernel.org,
	Oleksandr Tyshchenko <oleksandr_tyshchenko@epam.com>,
	Masami Hiramatsu <mhiramat@kernel.org>,
	Jiri Olsa <jolsa@kernel.org>, linux-fsdevel@vger.kernel.org,
	Andrew Morton <akpm@linux-foundation.org>,
	Trond Myklebust <trondmy@kernel.org>,
	Mark Rutland <mark.rutland@arm.com>, linux-doc@vger.kernel.org,
	Dave Hansen <dave.hansen@linux.intel.com>,
	Hongbo Li <hongbohbli@tencent.com>,
	Ying Huang <ying.huang@linux.alibaba.com>,
	Stefano Stabellini <sstabellini@kernel.org>,
	Vlastimil Babka <vbabka@kernel.org>,
	Sergey Senozhatsky <senozhatsky@chromium.org>,
	Byungchul Park <byungchul@sk.com>,
	linux-trace-kernel@vger.kernel.org,
	Lorenzo Stoakes <ljs@kernel.org>,
	Joshua Hahn <joshua.hahnjy@gmail.com>,
	Barry Song <baohua@kernel.org>, Kairui Song <kasong@tencent.com>,
	"Theodore Y. Ts'o" <tytso@mit.edu>,
	Muchun Song <muchun.song@linux.dev>,
	linux-f2fs-devel@lists.sourceforge.net,
	Minchan Kim <minchan@kernel.org>, Lance Yang <lance.yang@linux.dev>,
	Thomas Gleixner <tglx@kernel.org>, Anna Schumaker <anna@kernel.org>,
	Pratyush Yadav <pratyush@kernel.org>,
	Alex Markuze <amarkuze@redhat.com>,
	Alexander Shishkin <alexander.shishkin@linux.intel.com>,
	linux-mtd@lists.infradead.org, Chunhai Guo <guochunhai@vivo.com>,
	Jonathan Corbet <corbet@lwn.net>, Dev Jain <dev.jain@arm.com>,
	"Matthew Wilcox (Oracle)" <willy@infradead.org>,
	Viacheslav Dubeyko <slava@dubeyko.com>,
	Gao Xiang <xiang@kernel.org>, Wei Xu <weixugc@google.com>,
	Baoquan He <baoquan.he@linux.dev>,
	James Clark <james.clark@linaro.org>,
	Steven Rostedt <rostedt@goodmis.org>,
	Borislav Petkov <bp@alien8.de>,
	Baolin Wang <baolin.wang@linux.alibaba.com>,
	Shakeel Butt <shakeel.butt@linux.dev>,
	Tal Zussman <tz2294@columbia.edu>,
	Ilya Dryomov <idryomov@gmail.com>,
	Oscar Salvador <osalvador@suse.de>, linux-nfs@vger.kernel.org,
	linux-mm@kvack.org, linux-erofs@lists.ozlabs.org,
	Mike Rapoport <rppt@kernel.org>, Ian Rogers <irogers@google.com>,
	Michal Hocko <mhocko@suse.com>, Jan Kara <jack@suse.cz>,
	Peter Zijlstra <peterz@infradead.org>,
	Dave Young <ruirui.yang@linux.dev>,
	Yuanchu Xie <yuanchu@google.com>,
	"Liam R. Howlett" <liam@infradead.org>,
	"H. Peter Anvin" <hpa@zytor.com>, Yue Hu <zbestahu@gmail.com>,
	Rakie Kim <rakie.kim@sk.com>, Richard Weinberger <richard@nod.at>,
	x86@kernel.org, Ingo Molnar <mingo@redhat.com>,
	Axel Rasmussen <axelrasmussen@google.com>,
	Ryan Roberts <ryan.roberts@arm.com>,
	Pasha Tatashin <pasha.tatashin@soleen.com>,
	Usama Arif <usama.arif@linux.dev>,
	Jeffle Xu <jefflexu@linux.alibaba.com>,
	Namhyung Kim <namhyung@kernel.org>, Juergen Gross <jgross@suse.com>,
	kexec@lists.infradead.org, Adrian Hunter <adrian.hunter@intel.com>,
	Johannes Weiner <hannes@cmpxchg.org>,
	Mathieu Desnoyers <mathieu.desnoyers@efficios.com>
Subject: Re: [f2fs-dev] [PATCH v5 00/17] Remove PG_private by using
 page/folio->private checks instead
Message-ID: <arKfTXizFeTeKYDx@google.com>
References: <20260920-remove-pg_private-v5-0-bb68b6a21869@nvidia.com>
 <20260922041600.1240429-1-zhaonanzhe@xiaomi.com>
Precedence: bulk
X-Mailing-List: linux-nfs@vger.kernel.org
List-Id: <linux-nfs.vger.kernel.org>
List-Subscribe: <mailto:linux-nfs+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:linux-nfs+unsubscribe@vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20260922041600.1240429-1-zhaonanzhe@xiaomi.com>

On 09/22, Nanzhe Zhao wrote:
> Hi Zi Yan,
> 
> Thanks for the series. The cleanup is a nice help for the f2fs
> large-folio work -- it removes the page-based private-flag plumbing that
> my series would otherwise have to carry itself.
> 
> My large-folio series v2 [1] can be rebased on top of this series. The
> only overlap is the PAGE_PRIVATE_* flag helpers, which I can re-express
> on top of the F2FS_FOLIO_PRIVATE_* names while keeping the
> f2fs_folio_state indirection.
> 
> Jaegeuk, do you have a preference on the ordering here? My personal
> suggestion would be to review and merge this series first, and I'll
> rebase on top of it.

Let's keep working on the f2fs tree, since we should not merge this in my tree.
Later, we'd need to prepare how to address the merge conflict.

> 
> [1] https://lore.kernel.org/linux-f2fs-devel/20260915041909.2903887-1-zhaonanzhe@xiaomi.com/
> 
> Thanks,
> Nanzhe
> 
> 
> _______________________________________________
> Linux-f2fs-devel mailing list
> Linux-f2fs-devel@lists.sourceforge.net
> https://lists.sourceforge.net/lists/listinfo/linux-f2fs-devel
