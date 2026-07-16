Received: from out-173.mta1.migadu.com (out-173.mta1.migadu.com [95.215.58.173])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 34787434E53
	for <linux-nfs@vger.kernel.org>; Thu, 16 Jul 2026 17:00:53 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=95.215.58.173
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1784221255; cv=none; b=RfGsqpYrJWTpDwtAtqULrWhtoOxBkiamQ9bczmxeArXSquVGGGiDPF6F0pct24upogP6svR8LeMSGmVy++7D19FYLcI6gry42HLh45smfu/o3ijwYpKSY3BIDPeT1T02SDtBwQqVY8EL5OytOKiV5ZmLmxWekKZ+FRn8R+tf0VI=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1784221255; c=relaxed/simple;
	bh=ryLZfzu7w/33tZHMEAX5YS1AtIi6A75xAvSnQuDhpy8=;
	h=Mime-Version:Content-Type:Date:Message-Id:To:Cc:Subject:From:
	 References:In-Reply-To; b=K4CgQvOU50sAP8hvDID10GIa0U4xctAl1hdCbl9mSJ0GHNqWbr7VlHpTa3ZRiD5EJj+dQK1XORvxeEQgsrtGGTlCi2Ww2ujK2S4G7YL8BVQ0MXtUnsB4Rx7otg7ocF8HkNTicBI7nwQc8x8nzmw11M4xLecE2jaSehKotFB186A=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dmarc=pass (p=none dis=none) header.from=linux.dev; spf=pass smtp.mailfrom=linux.dev; dkim=pass (1024-bit key) header.d=linux.dev header.i=@linux.dev header.b=gKXuKFc/; arc=none smtp.client-ip=95.215.58.173
Authentication-Results: smtp.subspace.kernel.org; dmarc=pass (p=none dis=none) header.from=linux.dev
Authentication-Results: smtp.subspace.kernel.org; spf=pass smtp.mailfrom=linux.dev
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (1024-bit key) header.d=linux.dev header.i=@linux.dev header.b="gKXuKFc/"
Precedence: bulk
X-Mailing-List: linux-nfs@vger.kernel.org
List-Id: <linux-nfs.vger.kernel.org>
List-Subscribe: <mailto:linux-nfs+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:linux-nfs+unsubscribe@vger.kernel.org>
Mime-Version: 1.0
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=linux.dev; s=key1;
	t=1784221248;
	h=from:from:reply-to:subject:subject:date:date:message-id:message-id:
	 to:to:cc:cc:mime-version:mime-version:content-type:content-type:
	 content-transfer-encoding:content-transfer-encoding:
	 in-reply-to:in-reply-to:references:references;
	bh=ryLZfzu7w/33tZHMEAX5YS1AtIi6A75xAvSnQuDhpy8=;
	b=gKXuKFc/Zc+x61YZilf5Od0LX0/TnweLJkY6B0iS5dDK1rmx2rZT6ibR+q4XB4vp98ECAJ
	usgRE3P9Y3i2YNrl1JiIwqE/t23GTZbcDGdg5R0zMUXBaD+s+ENmZK2riqG0XJstPAQl7N
	n59nA6ONzcF/mPCm/md31OknwLidCVI=
Content-Transfer-Encoding: quoted-printable
Content-Type: text/plain; charset=UTF-8
Date: Thu, 16 Jul 2026 17:00:38 +0000
Message-Id: <DK05N5JBJWQB.2QSODJ6JABRIN@linux.dev>
To: "Brendan Jackman" <jackmanb@google.com>, "Andrew Morton"
 <akpm@linux-foundation.org>, "David Hildenbrand" <david@kernel.org>,
 "Lorenzo Stoakes" <ljs@kernel.org>, "Liam R. Howlett" <liam@infradead.org>,
 "Vlastimil Babka" <vbabka@kernel.org>, "Mike Rapoport" <rppt@kernel.org>,
 "Suren Baghdasaryan" <surenb@google.com>, "Michal Hocko" <mhocko@suse.com>,
 "Johannes Weiner" <hannes@cmpxchg.org>, "Zi Yan" <ziy@nvidia.com>, "Matthew
 Wilcox (Oracle)" <willy@infradead.org>, "Jan Kara" <jack@suse.cz>, "Joshua
 Hahn" <joshua.hahnjy@gmail.com>, "Byungchul Park" <byungchul@sk.com>,
 "Gregory Price" <gourry@gourry.net>, "Ying Huang"
 <ying.huang@linux.alibaba.com>, "Alistair Popple" <apopple@nvidia.com>,
 "Hugh Dickins" <hughd@google.com>, "Baolin Wang"
 <baolin.wang@linux.alibaba.com>, "Chris Li" <chrisl@kernel.org>, "Kairui
 Song" <kasong@tencent.com>, "Kemeng Shi" <shikemeng@huaweicloud.com>, "Nhat
 Pham" <nphamcs@gmail.com>, "Baoquan He" <baoquan.he@linux.dev>, "Barry
 Song" <baohua@kernel.org>, "Youngjun Park" <youngjun.park@lge.com>, "Joerg
 Roedel (AMD)" <joro@8bytes.org>, "Will Deacon" <will@kernel.org>, "Robin
 Murphy" <robin.murphy@arm.com>, "Huacai Chen" <chenhuacai@kernel.org>,
 "WANG Xuerui" <kernel@xen0n.name>, "Thomas Gleixner" <tglx@kernel.org>,
 "Chuck Lever" <cel@kernel.org>, "Jeff Layton" <jlayton@kernel.org>,
 "NeilBrown" <neil@brown.name>, "Olga Kornievskaia" <okorniev@redhat.com>,
 "Dai Ngo" <Dai.Ngo@oracle.com>, "Tom Talpey" <tom@talpey.com>, "Trond
 Myklebust" <trondmy@kernel.org>, "Anna Schumaker" <anna@kernel.org>, "David
 S. Miller" <davem@davemloft.net>, "Eric Dumazet" <edumazet@google.com>,
 "Jakub Kicinski" <kuba@kernel.org>, "Paolo Abeni" <pabeni@redhat.com>,
 "Simon Horman" <horms@kernel.org>
Cc: <linux-kernel@vger.kernel.org>, <linux-mm@kvack.org>,
 <linux-fsdevel@vger.kernel.org>, <iommu@lists.linux.dev>,
 <loongarch@lists.linux.dev>, <linux-nfs@vger.kernel.org>,
 <netdev@vger.kernel.org>
Subject: Re: [PATCH 2/3] mm, treewide: replace __folio_alloc_node() with
 folio_alloc_node()
X-Report-Abuse: Please report any abuse attempt to abuse@migadu.com and include these headers.
From: "Brendan Jackman" <brendan.jackman@linux.dev>
References: <20260716-folio-alloc-cleanups-v1-0-5363b8e92d33@google.com>
 <20260716-folio-alloc-cleanups-v1-2-5363b8e92d33@google.com>
In-Reply-To: <20260716-folio-alloc-cleanups-v1-2-5363b8e92d33@google.com>
X-Migadu-Flow: FLOW_OUT

On Thu Jul 16, 2026 at 2:30 PM UTC, Brendan Jackman wrote:
> Commit 5b584d2d22dca ("mm: remove __alloc_pages_node()") removed the __

Oh, I just remembered this commit hash is unstable. In fact it's already
wrong.

> variant of alloc_pages_node(), after users had been migrated off it,
> since it just complicates the API (requiring users to handle
> NUMA_NO_NODE, or risking hotplug bugs) for no real benefit.

