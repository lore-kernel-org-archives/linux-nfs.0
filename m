Received: from smtp.kernel.org (aws-us-west-2-korg-mail-alma10-1.taild15c8.ts.net [100.103.45.18])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 872F039B489;
	Thu, 11 Jun 2026 09:10:08 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=100.103.45.18
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1781169009; cv=none; b=ndaWSLbxLAb8VL2FfjUxmUkxS2AAxJgkjckpAG+q4U6q07Q7zQRH0DIjKjohJsovhKAPkLEt9wczt9QaPrREKVViab+4pajUVDM5A6WGG/+q7tqd2Unu1E9xHA3uRNL9eRU9tbzlZ93gzgCb05YGe5UlcTGOA9L1YizhkV/edLg=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1781169009; c=relaxed/simple;
	bh=7ro/wNC2XlBxgc1ytrPdZWWhEcQ86baWNS7lObN8Wsc=;
	h=Date:From:To:Cc:Subject:Message-ID:References:MIME-Version:
	 Content-Type:Content-Disposition:In-Reply-To; b=C1n0el5nPp8Zbe01MJ8tGT/kQTLPg/hM1hYuhgHmD8xX0IYSVzskizNQWJsya71VDnC0YtMTv3pVYukoee6+ylp0TQF/6S0rgh/FtNMpMC1+hi9xXpv8o9tMdx7UfeAT4ZJb6nNwmAuy21WCDZtdcXn9icnpxpUg1FcHzfLtJDs=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.b=fPtzfzGE; arc=none smtp.client-ip=100.103.45.18
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.b="fPtzfzGE"
Received: by smtp.kernel.org (Postfix) with ESMTPSA id B91A51F00898;
	Thu, 11 Jun 2026 09:09:59 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=kernel.org;
	s=k20260515; t=1781169008;
	bh=RfIkCcdblNK9CftEwDsBO/uWm7/F942mXwD6xGSPOQ8=;
	h=Date:From:To:Cc:Subject:References:In-Reply-To;
	b=fPtzfzGEJFYZ4r9C5JW6EWJJCF584zY5w6oMBp8rYhkTyeCSNXVG8Au+IV1+dNDdd
	 OjTWGscPWvBqdZ2tNbDWg6h50AIHpzelD59trF8BEIcIwr4MI/4QXCMCKdGAoI94Mn
	 DugjFq5FMnmZqKZPntfDEJFgYqGK3JTCO0wYhoV4XfSAmCg3LoL4s0NCbSY87SXGdd
	 lIoNbEwaIZQdNTNTGkOHSesk6vni01mQ1c/DuaI8Tr2NMd3SDxgiZM0D7hfNAI8V41
	 N527kBZlZDF9Rbrm1FBVIptR07rwTfzgG4mPebsS1Q5UonPhpGxzx6OV+FU+aSKQfb
	 0xc5VjaRAgPkQ==
Date: Thu, 11 Jun 2026 12:09:55 +0300
From: Mike Rapoport <rppt@kernel.org>
To: Zi Yan <ziy@nvidia.com>
Cc: Jan Kara <jack@suse.com>, Mark Fasheh <mark@fasheh.com>,
	Joel Becker <jlbec@evilplan.org>,
	Joseph Qi <joseph.qi@linux.alibaba.com>,
	Ryusuke Konishi <konishi.ryusuke@gmail.com>,
	Viacheslav Dubeyko <slava@dubeyko.com>,
	Trond Myklebust <trondmy@kernel.org>,
	Anna Schumaker <anna@kernel.org>,
	Chuck Lever <chuck.lever@oracle.com>,
	Jeff Layton <jlayton@kernel.org>, NeilBrown <neil@brown.name>,
	Olga Kornievskaia <okorniev@redhat.com>,
	Dai Ngo <Dai.Ngo@oracle.com>, Tom Talpey <tom@talpey.com>,
	Alexander Viro <viro@zeniv.linux.org.uk>,
	Christian Brauner <brauner@kernel.org>, Jan Kara <jack@suse.cz>,
	Dave Kleikamp <shaggy@kernel.org>, Theodore Ts'o <tytso@mit.edu>,
	Miklos Szeredi <miklos@szeredi.hu>,
	Andreas Hindborg <a.hindborg@kernel.org>,
	Breno Leitao <leitao@debian.org>, Kees Cook <kees@kernel.org>,
	"Tigran A. Aivazian" <aivazian.tigran@gmail.com>,
	linux-kernel@vger.kernel.org, linux-fsdevel@vger.kernel.org,
	ocfs2-devel@lists.linux.dev, linux-nilfs@vger.kernel.org,
	linux-nfs@vger.kernel.org, jfs-discussion@lists.sourceforge.net,
	linux-ext4@vger.kernel.org, linux-mm@kvack.org
Subject: Re: [PATCH 00/17] replace __get_free_pages() call with kmalloc()
Message-ID: <aip7Y3UHmXsdX8OH@kernel.org>
References: <20260523-b4-fs-v1-0-275e36a83f0e@kernel.org>
 <3FD8E1FD-6E18-46D9-AE93-00FA1A66C775@nvidia.com>
Precedence: bulk
X-Mailing-List: linux-nfs@vger.kernel.org
List-Id: <linux-nfs.vger.kernel.org>
List-Subscribe: <mailto:linux-nfs+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:linux-nfs+unsubscribe@vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <3FD8E1FD-6E18-46D9-AE93-00FA1A66C775@nvidia.com>

On Fri, Jun 05, 2026 at 04:00:33PM -0400, Zi Yan wrote:
> On 23 May 2026, at 13:54, Mike Rapoport (Microsoft) wrote:
> 
> > This is a (small) part of larger work of replacing page allocator calls
> > with kmalloc.
> 
> Is the goal to get rid of __get_free_page(s)()?

Yes, eventually.

My initial intention a few month ago was to remove the ugly casts [1], but
then willy pointed out that Linus objected to something like this [2] and
it looks like more than a decade old technical debt.

Since there are more than 600 or those it will take a while to convert
suitable gfp calls to kmalloc.
Afterwards we can re-evaluate what APIs we want to provide for allocations
that must have actual pages.

[1] https://lore.kernel.org/all/20251018093002.3660549-1-rppt@kernel.org/
[2] https://lore.kernel.org/all/CA+55aFwp4iy4rtX2gE2WjBGFL=NxMVnoFeHqYa2j1dYOMMGqxg@mail.gmail.com/ 

 
> Thanks.

-- 
Sincerely yours,
Mike.
