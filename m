Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.remote-ip=213.95.11.211
ARC-Seal: i=1; d=subspace.kernel.org; s=arc20261015; a=rsa-sha256; cv=none;
	t=1794409928;
	b=MWPJKmPyp8wx+wGW7VKUKHdaMXkk6tsOcpRoNXGlWeRhpmrfU+LuN/+Fbw0rSmN2giCF
	 zhUx5VkcGmilppk9o666JBYv8eJva8qD0It9DQ8F97ft/fHSVLj4GS3diqBvcPeFTi/d/
	 gUl8aap5dMBwOif5ts3ECTXN3w/CwhsOLxKjyPkTCAgC33wYX+50RkAHwrwhahJbSvLsU
	 XTFQSGheD13JTP19bHaOro5xVetjkD17JcXXuiMOcbz9mUFkFPgUCIXaEDissL/3z/IxR
	 1GEh9utTXqsBSZ2CjGwkiWDIX/d4lsYs/anBHXm44f8cKvEt2XglCkJBMUPieT2ddKw==
ARC-Message-Signature: i=1; d=subspace.kernel.org; s=arc20261015;
	a=rsa-sha256; c=relaxed/relaxed; t=1794409928;
	h=DMARC-Filter:Received:Date:From:To:Cc:Subject:Message-ID:References:
	 MIME-Version:Content-Type:Content-Disposition:In-Reply-To:User-Agent;
	bh=dehBO8Yxo1qlGsyLOmGqdqT0CExk2sS3MX1Vk4oa/6A=;
	b=DbhAT6FgGRL3UmCOe8v7NLD7ilAdyvziIOjYNx3OXqQf0y1zEOUqvTCitYOphUofvTdU
	 fvjQBy7iA0nJJ5s1k8s9TYNxV3KWWBMuQtNFCSsPpSLwCKfzV5xk3lojvnD2P69rUW3u4
	 4hO5Z9dYMOA7KMuaujF2k20ovhu/LVsDvgCcwZP9ICypkUAldvF0vk5uX3FB3/R4I3lgO
	 10xMB7+vfNUYAwZbSJqZr9DO3uN3Kaj5XIl/m+FpaCq9TSJBiSl/Lai778mLWbBqsW6Ga
	 sYkATyl8o1KkffkKQNybi0mnoB7kjkOn8R3CoebYoM3ax26NHBWREbsvq5y00q9+o7A==
ARC-Authentication-Results: i=1; smtp.subspace.kernel.org; 
	dmarc=pass header.from=lst.de;
	spf=pass smtp.mailfrom=lst.de;
	arc=none smtp.remote-ip=213.95.11.211
Received: from verein.lst.de (verein.lst.de [213.95.11.211])
	(using TLSv1.2 with cipher ECDHE-ECDSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id B90E5606A326;
	Wed, 11 Nov 2026 15:12:07 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.4.2 smtp.subspace.kernel.org B90E5606A326
Authentication-Results: smtp.subspace.kernel.org; dmarc=pass (p=none dis=none) header.from=lst.de
Authentication-Results: smtp.subspace.kernel.org; spf=pass smtp.mailfrom=lst.de
Received: by verein.lst.de (Postfix, from userid 2407)
	id 52A7668D16; Wed, 11 Nov 2026 16:12:03 +0100 (CET)
Date: Wed, 11 Nov 2026 16:12:02 +0100
From: Christoph Hellwig <hch@lst.de>
To: Christian Brauner <brauner@kernel.org>
Cc: linux-fsdevel@vger.kernel.org, Jann Horn <jannh@google.com>,
	Chris Mason <mason@kernel.org>, Josef Bacik <josef@toxicpanda.com>,
	Christoph Hellwig <hch@lst.de>, linux-block@vger.kernel.org,
	linux-kernel@vger.kernel.org, linux-nvme@lists.infradead.org,
	Alexander Viro <viro@zeniv.linux.org.uk>, Jan Kara <jack@suse.cz>,
	linux-scsi@vger.kernel.org, target-devel@vger.kernel.org,
	driver-core@lists.linux.dev, linux-mm@kvack.org,
	bpf@vger.kernel.org, linux-security-module@vger.kernel.org,
	selinux@vger.kernel.org, apparmor@lists.ubuntu.com,
	linux-nfs@vger.kernel.org, netdev@vger.kernel.org,
	fuse-devel@lists.linux.dev, linux-efi@vger.kernel.org,
	xen-devel@lists.xenproject.org, ocfs2-devel@lists.linux.dev,
	linux-s390@vger.kernel.org, linuxppc-dev@lists.ozlabs.org,
	linux-usb@vger.kernel.org, Amir Goldstein <amir73il@gmail.com>,
	linux-erofs@lists.ozlabs.org, linux-kselftest@vger.kernel.org
Subject: Re: [PATCH RFC 38/41] fuse: refuse files on pseudo filesystems as
 passthrough backing files
Message-ID: <20261111151202.GA11391@lst.de>
References: <20261110-work-loop-pseudo-v1-0-4c998976c6c7@kernel.org> <20261110-work-loop-pseudo-v1-38-4c998976c6c7@kernel.org>
X-Mailing-List: linux-nfs@vger.kernel.org
List-Id: <linux-nfs.vger.kernel.org>
List-Post: <mailto:linux-nfs@vger.kernel.org>
List-Help: <mailto:linux-nfs+help@vger.kernel.org>
List-Subscribe: <mailto:linux-nfs+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:linux-nfs+unsubscribe@vger.kernel.org>
List-Owner: <mailto:linux-nfs+owner@vger.kernel.org>
Precedence: list
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20261110-work-loop-pseudo-v1-38-4c998976c6c7@kernel.org>
User-Agent: Mutt/1.5.17 (2007-11-01)

I've seen setups where people use fuse to mediate access to sysfs
sysfs in odd ways.  No idea if that's still around, but if so, this
patch will break it.

