Received: from zeniv.linux.org.uk (zeniv.linux.org.uk [62.89.141.173])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 3A11C156F45;
	Sat, 15 Aug 2026 05:04:02 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=62.89.141.173
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1786770246; cv=none; b=tw5XTMBtOm5+3qTdicMDgurD/1VBjJK6WqcCGfgSNTbkqQgiW6Iqhgt2inm7OZqZpKFEIa0Bcu3HyHjsSbZhE42XI6N5TM1h62WDPWPY5C82cggO2xjwjuOUflwCqf3uwza/mXEb2B+W4q6+yw3lQzd2uglMM9/IbaiRXx7jZe4=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1786770246; c=relaxed/simple;
	bh=sD+y5AAbOFIJ8I+E5bM4G/BAU/2IVubeEV9oWIOb6a4=;
	h=Date:From:To:Cc:Subject:Message-ID:References:MIME-Version:
	 Content-Type:Content-Disposition:In-Reply-To; b=ldTESh0X+my28i/BRyw9TJo6mVp/558q0rCL3OtMKDYkD9LLHJ7e/oGuBWjolN5EDSIgOmPl0GE86+KFfSzdQuvxNpqVbj+hCaLdt3hHtdZq8ilf5fQHF84PdaJFfO9yteHjCMQm96RYtbzdV+sodHhh5KjI4sjuLXQQfQ61PIw=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dmarc=pass (p=none dis=none) header.from=zeniv.linux.org.uk; spf=none smtp.mailfrom=ftp.linux.org.uk; dkim=pass (2048-bit key) header.d=linux.org.uk header.i=@linux.org.uk header.b=LLcro41I; arc=none smtp.client-ip=62.89.141.173
Authentication-Results: smtp.subspace.kernel.org; dmarc=pass (p=none dis=none) header.from=zeniv.linux.org.uk
Authentication-Results: smtp.subspace.kernel.org; spf=none smtp.mailfrom=ftp.linux.org.uk
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=linux.org.uk header.i=@linux.org.uk header.b="LLcro41I"
DKIM-Signature: v=1; a=rsa-sha256; q=dns/txt; c=relaxed/relaxed;
	d=linux.org.uk; s=zeniv-20220401; h=Sender:In-Reply-To:Content-Type:
	MIME-Version:References:Message-ID:Subject:Cc:To:From:Date:Reply-To:
	Content-Transfer-Encoding:Content-ID:Content-Description;
	bh=TdAGf/nCkVIECkHyF2qnd1MoE6PGyFWeLuqW7f/TR2A=; b=LLcro41I2uAumEAf1TzxfqaBs1
	QbY0taO8Wny4OegJi3LxUhUb1F+pi/yIk0A/dKfu84Pqh4aRLz72lAoFKW4Q0D5Th2/gdBIsciHGS
	ML0mIAz2UNFWLYYXR2Wd3k4q5MN+cndoj+o9opwTTQhp6AOEUIV1BHKVIrCsSGl0qWIoEBWU0n1MU
	MX2SJRJXn+uJijRGS5oByYyyMcJCu6Xv+1L0JcddgPCCLxEJ1PFaeAtFljO+l1ynEc+n2TXXYT58U
	l0PWjzeJ3cHEGV7+GfuNg1eJc+PD06BqQ29+LGk23IS/fv192LFFPDXW6CxJXRuhPCDS7P6DthZTf
	TrlZf/Fg==;
Received: from viro by zeniv.linux.org.uk with local (Exim 4.99.4 #2 (Red Hat Linux))
	id 1wv6Yf-00000002k1e-25PN;
	Sat, 15 Aug 2026 05:03:52 +0000
Date: Sat, 15 Aug 2026 06:03:49 +0100
From: Al Viro <viro@zeniv.linux.org.uk>
To: NeilBrown <neil@brown.name>
Cc: Ian Kent <raven@themaw.net>, Chuck Lever <cel@kernel.org>,
	Jake Edge <jake@lwn.net>, Ilya Dryomov <idryomov@gmail.com>,
	Alex Markuze <amarkuze@redhat.com>,
	Viacheslav Dubeyko <slava@dubeyko.com>,
	Jan Harkes <jaharkes@cs.cmu.edu>, coda@cs.cmu.edu,
	Christian Brauner <brauner@kernel.org>, Jan Kara <jack@suse.cz>,
	Trond Myklebust <trondmy@kernel.org>,
	Anna Schumaker <anna@kernel.org>,
	Amir Goldstein <amir73il@gmail.com>,
	Andrew Morton <akpm@linux-foundation.org>,
	Miklos Szeredi <mszeredi@redhat.com>, autofs@vger.kernel.org,
	linux-kernel@vger.kernel.org, ceph-devel@vger.kernel.org,
	codalist@coda.cs.cmu.edu, linux-fsdevel@vger.kernel.org,
	linux-nfs@vger.kernel.org
Subject: Re: [PATCH RFC/RFT v2 00/18] Fix easy bits of the negative dentry
 problem
Message-ID: <20260815050349.GR2636677@ZenIV>
References: <20260815042707.2535717-1-neilb@ownmail.net>
Precedence: bulk
X-Mailing-List: linux-nfs@vger.kernel.org
List-Id: <linux-nfs.vger.kernel.org>
List-Subscribe: <mailto:linux-nfs+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:linux-nfs+unsubscribe@vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20260815042707.2535717-1-neilb@ownmail.net>
Sender: Al Viro <viro@ftp.linux.org.uk>

On Sat, Aug 15, 2026 at 02:21:17PM +1000, NeilBrown wrote:

> Most of d_walk() already schedules as needed, but I
>  think there is still room for improvement, but that can come later.

How the hell could it possibly schedule, when it might very well have
grabbed rename_lock?  Confused...

Al, getting through the piles of mail at the moment (sick for a month)...
