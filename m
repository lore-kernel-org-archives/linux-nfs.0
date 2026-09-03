Received: from smtp.kernel.org (aws-us-west-2-korg-mail-alma10-1.taild15c8.ts.net [100.103.45.18])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 0DD0D37FF53;
	Thu,  3 Sep 2026 16:11:04 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=100.103.45.18
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1788451866; cv=none; b=YJnZE4o/+nhg7hgl67cJliBGprlblhdpqzJhzh0rsiFdf7yf0jiPcD5Wg39hHA+aC5NXxJw0qwAphzoNp2HWPROBKm5mCy5Yke65PyvS5A0hpqmzILxT9Zom5HpBAVx4OBnN/+l9QL7ZQf3S/rnH1x6iDvbaVtAkdsT1XwvXXto=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1788451866; c=relaxed/simple;
	bh=EZkrPu4MIblzYuAARYgWy6bsvyK3BVJiKofRW0Irh5c=;
	h=Content-Type:MIME-Version:Subject:From:Message-Id:Date:References:
	 In-Reply-To:To:Cc; b=H2x2ZvJg9evdsSqyhV4088y7rZ/fasm5n9TeWwOZ2tzytkPpSoMoZrQPPtxnu1SyGN0rszNNxUS2YIWPTDsPmA5nM8LDIqHpfXw/vYm0bcnpjR+6dB0BIlsvb62ROrQA/PBh3Na9kZa64+rjMr3PA0II+NSDp5ZMpj8K5zcaET8=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.b=JxlK65jB; arc=none smtp.client-ip=100.103.45.18
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.b="JxlK65jB"
Received: by smtp.kernel.org (Postfix) with ESMTPSA id 929241F00A3D;
	Thu,  3 Sep 2026 16:11:04 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=kernel.org;
	s=k20260515; t=1788451864;
	bh=0GGJyshhlAlKfjOpgr7j97Mh0m1+5qav5ykVgFpFUIA=;
	h=Subject:From:Date:References:In-Reply-To:To:Cc;
	b=JxlK65jBcGgrsk9TAjqXxFnNxMSr2EUzOMWx942qjPBc2ybpTNX4WvsfPUiPxOaFl
	 CvaTGDSQ1oizIiQKMXWYE2OVnwqIcGg5ydGC/+fP1+mqJ1GuK69hXukg6W16b7JT1r
	 w2aaHejOOmNUZBUXMT7w7PrSbcyV2uNkwH9yBFLEDwdRzAceRy7X++SL5zY6FEYsfi
	 FKkGMEhCG0T0FcIFQ+7naHWPwvlEPmk672vo9ZWS+QDqA+Td4EZLGZ+BJGrxKQ67ij
	 TyZdI3BpB9bpqUcAWwS6PSI4Q7NaBwZ/Wa6AfOhrb223ZyOEtRQ2bZ96TF514AV+At
	 BAPEfyocjj+3A==
Received: from [10.30.226.235] (localhost [IPv6:::1])
	by aws-us-west-2-korg-oddjob-rhel9-1.codeaurora.org (Postfix) with ESMTP id 1986738119CB;
	Thu,  3 Sep 2026 16:10:07 +0000 (UTC)
Content-Type: text/plain; charset="utf-8"
Precedence: bulk
X-Mailing-List: linux-nfs@vger.kernel.org
List-Id: <linux-nfs.vger.kernel.org>
List-Subscribe: <mailto:linux-nfs+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:linux-nfs+unsubscribe@vger.kernel.org>
MIME-Version: 1.0
Content-Transfer-Encoding: 8bit
Subject: Re: [f2fs-dev] [PATCH RFC 00/14] Remove PG_private by using
 page/folio->private checks instead
From: patchwork-bot+f2fs@kernel.org
Message-Id: 
 <178845180590.3423963.571905514968785918.git-patchwork-notify@kernel.org>
Date: Thu, 03 Sep 2026 16:10:05 +0000
References: <20260731-remove-pg_private-v1-0-142c97ba3562@nvidia.com>
In-Reply-To: <20260731-remove-pg_private-v1-0-142c97ba3562@nvidia.com>
To: Zi Yan <ziy@nvidia.com>
Cc: david@kernel.org, willy@infradead.org, akpm@linux-foundation.org,
 muchun.song@linux.dev, ljs@kernel.org, liam@infradead.org, vbabka@kernel.org,
 rppt@kernel.org, surenb@google.com, mhocko@suse.com,
 baolin.wang@linux.alibaba.com, nico.pache@linux.dev, ryan.roberts@arm.com,
 dev.jain@arm.com, baohua@kernel.org, lance.yang@linux.dev,
 usama.arif@linux.dev, gourry@gourry.net, ying.huang@linux.alibaba.com,
 apopple@nvidia.com, hannes@cmpxchg.org, qi.zheng@linux.dev,
 shakeel.butt@linux.dev, kasong@tencent.com, mark.rutland@arm.com,
 irogers@google.com, jack@suse.cz, linux-doc@vger.kernel.org,
 amarkuze@redhat.com, peterz@infradead.org, kexec@lists.infradead.org,
 dave.hansen@linux.intel.com, ruirui.yang@linux.dev, adrian.hunter@intel.com,
 linux-mm@kvack.org, hongbohbli@tencent.com, hpa@zytor.com,
 guochunhai@vivo.com, skhan@linuxfoundation.org, ceph-devel@vger.kernel.org,
 baoquan.he@linux.dev, matthew.brost@intel.com, anna@kernel.org,
 sstabellini@kernel.org, zbestahu@gmail.com, rakie.kim@sk.com,
 minchan@kernel.org, richard@nod.at, x86@kernel.org, ebiggers@kernel.org,
 alexander.shishkin@linux.intel.com, mingo@redhat.com, slava@dubeyko.com,
 weixugc@google.com, yukuai@fygo.io, xen-devel@lists.xenproject.org,
 xiang@kernel.org, magiclinan@didiglobal.com, mhiramat@kernel.org,
 joshua.hahnjy@gmail.com, xiao@kernel.org, byungchul@sk.com,
 james.clark@linaro.org, acme@kernel.org, linux-raid@vger.kernel.org,
 linux-fscrypt@vger.kernel.org, bp@alien8.de, rostedt@goodmis.org,
 linux-mtd@lists.infradead.org, axelrasmussen@google.com,
 jefflexu@linux.alibaba.com, namhyung@kernel.org, jaegeuk@kernel.org,
 yuanchu@google.com, idryomov@gmail.com, osalvador@suse.de, jgross@suse.com,
 pratyush@kernel.org, linux-nfs@vger.kernel.org, tytso@mit.edu,
 oleksandr_tyshchenko@epam.com, song@kernel.org, corbet@lwn.net,
 pasha.tatashin@soleen.com, linux-kernel@vger.kernel.org,
 linux-f2fs-devel@lists.sourceforge.net, linux-perf-users@vger.kernel.org,
 senozhatsky@chromium.org, tglx@kernel.org, jolsa@kernel.org,
 linux-fsdevel@vger.kernel.org, mathieu.desnoyers@efficios.com,
 linux-trace-kernel@vger.kernel.org, linux-erofs@lists.ozlabs.org,
 trondmy@kernel.org

Hello:

This patch was applied to jaegeuk/f2fs.git (dev)
by Jaegeuk Kim <jaegeuk@kernel.org>:

On Fri, 31 Jul 2026 22:13:23 -0400 you wrote:
> Hi all,
> 
> This patchset removes PG_private to make space for upcoming PG_folio
> (reserved as __PG_folio) for identifying pages from a folio (more details
> in Note below). Instead of checking PG_private, all code is changed to
> check page/folio->private != NULL instead.
> 
> [...]

Here is the summary with links:
  - [f2fs-dev,RFC,06/14] fs/f2fs: stop using PG_private
    https://git.kernel.org/jaegeuk/f2fs/c/5ad9409a9533

You are awesome, thank you!
-- 
Deet-doot-dot, I am a bot.
https://korg.docs.kernel.org/patchwork/pwbot.html


