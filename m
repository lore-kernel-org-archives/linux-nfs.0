Received: from casper.infradead.org (casper.infradead.org [90.155.50.34])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id B72262FFF8B;
	Mon, 25 May 2026 17:55:51 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=90.155.50.34
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1779731752; cv=none; b=HJImi6lB7f3X7nfOtv4EeHQyOLnqgEfZYJlxZxglez3uVpfdmE8dcjP60rHPP7Px6HkNrOvAbUGLf8+iqA+PmwtgdTcON+GFYnzOoKFAT/SKMqL+C3IcvH738da4wm0aYak3RVEV0EHNP8A5wB2AkG/eTYh03a0g5z1pFNAWs3o=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1779731752; c=relaxed/simple;
	bh=5YL6HSkMXE8sg9IfrQO9LGoZdlBO3EtC4IxekeYbMaA=;
	h=Date:From:To:Cc:Subject:Message-ID:References:MIME-Version:
	 Content-Type:Content-Disposition:In-Reply-To; b=uHb4i1jFtfcki7R3FoMKlOD0E3oqFcZMONHfWgJtNjP5hCoyboX8yyU+ptY3dvfTsWmSkyhC2S6+W5GtJwI2XlPs6fDTJYordbiGw1aaRT9EafQwhUFS6rLDB5j7NE1x7ETzkWb1EKuKRDAYG87/g+iqTSi+ov54vPF2iztlyxg=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dmarc=pass (p=none dis=none) header.from=infradead.org; spf=none smtp.mailfrom=infradead.org; dkim=pass (2048-bit key) header.d=infradead.org header.i=@infradead.org header.b=b0R5jvc3; arc=none smtp.client-ip=90.155.50.34
Authentication-Results: smtp.subspace.kernel.org; dmarc=pass (p=none dis=none) header.from=infradead.org
Authentication-Results: smtp.subspace.kernel.org; spf=none smtp.mailfrom=infradead.org
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=infradead.org header.i=@infradead.org header.b="b0R5jvc3"
DKIM-Signature: v=1; a=rsa-sha256; q=dns/txt; c=relaxed/relaxed;
	d=infradead.org; s=casper.20170209; h=In-Reply-To:Content-Type:MIME-Version:
	References:Message-ID:Subject:Cc:To:From:Date:Sender:Reply-To:
	Content-Transfer-Encoding:Content-ID:Content-Description;
	bh=5YL6HSkMXE8sg9IfrQO9LGoZdlBO3EtC4IxekeYbMaA=; b=b0R5jvc3CRgQVq11325LstRMSF
	oKrblBL52SG7Mz6mDBUW/VCNZ8uBa48sWIpmj+aRuCqaV96ZG/Ic5uQrXVPhUdvtGe7ow122bVaIA
	g64TjlVIqJhmFIPhQ9wCX+ubNuU00b1Fk/phktSUzfKmvgsd/u/it9xu6ryC8NFJ8P8L+jQzq7Il9
	5Fcvr4m7lX8njEgphrHxwGeZ8FFYx/Xu4BrbZv62N2oeayt3Hw7hBPI37P8QlLz3vlr2IuyQc45/N
	JHeYVvUx9P7eOgJIhlxz42kjYZ7QlYPwj3MS8hyE/Lij4+DuMW47u5AhZAN8hmywk06dPCe0yGVYs
	7c6BglcA==;
Received: from willy by casper.infradead.org with local (Exim 4.99.1 #2 (Red Hat Linux))
	id 1wRZWY-0000000HaDk-1h3I;
	Mon, 25 May 2026 17:55:34 +0000
Date: Mon, 25 May 2026 18:55:34 +0100
From: Matthew Wilcox <willy@infradead.org>
To: David Laight <david.laight.linux@gmail.com>
Cc: Jan Kara <jack@suse.cz>, "Mike Rapoport (Microsoft)" <rppt@kernel.org>,
	Jan Kara <jack@suse.com>, Mark Fasheh <mark@fasheh.com>,
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
	Christian Brauner <brauner@kernel.org>,
	Dave Kleikamp <shaggy@kernel.org>, Theodore Ts'o <tytso@mit.edu>,
	Miklos Szeredi <miklos@szeredi.hu>,
	Andreas Hindborg <a.hindborg@kernel.org>,
	Breno Leitao <leitao@debian.org>, Kees Cook <kees@kernel.org>,
	"Tigran A. Aivazian" <aivazian.tigran@gmail.com>,
	linux-kernel@vger.kernel.org, linux-fsdevel@vger.kernel.org,
	ocfs2-devel@lists.linux.dev, linux-nilfs@vger.kernel.org,
	linux-nfs@vger.kernel.org, jfs-discussion@lists.sourceforge.net,
	linux-ext4@vger.kernel.org, linux-mm@kvack.org
Subject: Re: [PATCH 10/17] jbd2: replace __get_free_pages() with kmalloc()
Message-ID: <ahSNFmwAA17pMy6o@casper.infradead.org>
References: <20260523-b4-fs-v1-0-275e36a83f0e@kernel.org>
 <20260523-b4-fs-v1-10-275e36a83f0e@kernel.org>
 <2omm5gmnv2khshoxkrag5rusd3qzrsqyjgsef2syxgryrtg6vq@ao7oabqwebgo>
 <20260525182134.04045610@pumpkin>
Precedence: bulk
X-Mailing-List: linux-nfs@vger.kernel.org
List-Id: <linux-nfs.vger.kernel.org>
List-Subscribe: <mailto:linux-nfs+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:linux-nfs+unsubscribe@vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20260525182134.04045610@pumpkin>

On Mon, May 25, 2026 at 06:21:34PM +0100, David Laight wrote:
> Would kvalloc() be more appropriate here?

no

> Does __get_free_pages() return physically contiguous memory?

yes
