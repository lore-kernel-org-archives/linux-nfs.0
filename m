Received: from zeniv.linux.org.uk (zeniv.linux.org.uk [62.89.141.173])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 2CDD853F9C3;
	Mon, 19 Oct 2026 14:05:27 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=62.89.141.173
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1792418731; cv=none; b=tToQikHJ5Inuc7Kh9zoEyC9yZg72o/laRqoPeDUKjlBusCVU9zK8e+g8fsG/gegLmvidax2qzeGcDfeuTbHcHdEHT/aI4nBXuCiqXa70rDQKwZkUu/aUsNwcgZDkALXjUMtzIyH7vcQdQys/BojyJZYjAdHWVKCRmKUX2EhfcOY=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1792418731; c=relaxed/simple;
	bh=K5PydyQLdYBtN4u6RKjnU0fAlJGOyamu5EKde7vpDjI=;
	h=Date:From:To:Cc:Subject:Message-ID:References:MIME-Version:
	 Content-Type:Content-Disposition:In-Reply-To; b=aTRWTj6+1W51ifH+7y/NvLodmmTb9iVxRJqTkdIlSJkT7/W42OdIaAPeib4nCuLMuq7+8y7dROwnJBw6H9mOAGIX0pvFYqsRNJuF7D506v6LSZlqk8tMvYd8jeqQ4xmdmV8UJD7J4qUl2ZlmieyyAgaLGZtg+ROaE+SZgIHDuFY=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dmarc=pass (p=none dis=none) header.from=zeniv.linux.org.uk; spf=none smtp.mailfrom=ftp.linux.org.uk; dkim=pass (2048-bit key) header.d=linux.org.uk header.i=@linux.org.uk header.b=GK4/Alvu; arc=none smtp.client-ip=62.89.141.173
Authentication-Results: smtp.subspace.kernel.org; dmarc=pass (p=none dis=none) header.from=zeniv.linux.org.uk
Authentication-Results: smtp.subspace.kernel.org; spf=none smtp.mailfrom=ftp.linux.org.uk
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=linux.org.uk header.i=@linux.org.uk header.b="GK4/Alvu"
DKIM-Signature: v=1; a=rsa-sha256; q=dns/txt; c=relaxed/relaxed;
	d=linux.org.uk; s=zeniv-20220401; h=Sender:In-Reply-To:Content-Type:
	MIME-Version:References:Message-ID:Subject:Cc:To:From:Date:Reply-To:
	Content-Transfer-Encoding:Content-ID:Content-Description;
	bh=LjELfxqfQ8p94xSLF9FbczLIj3CRUCGTwxUa13CZ4bw=; b=GK4/Alvu2cybzGYBOSjT360xgR
	RfYskh/3r4foti620Cr/qB32Ub0E7kQPZh40dWLURZ1KJ4LZHQFuMDE8mVTVSLHIFoHXr9WaioJwf
	mQCyRogSot9njYyYw+yLHU4Xmb3JQ+B5XYJ0hltLIFFvw/voyfQFPv/nErt2vMhAYNTre2IDcttUW
	EPuO2pobb0DudcoQWRJVvjRBwwdOZo/vHAnFpY9PLS1mO5u0IkRSNBCHIcStuZMlOs2AJLGBuOEE/
	KlHpgGlDNFly5vkAvWJsx5cqnpgUzlopnuMQpik/Zv3HCPoMaZiCmFdgQumiGCfp+rC4gknaTqqyv
	gWuZ/Z4A==;
Received: from viro by zeniv.linux.org.uk with local (Exim 4.99.5 #2 (Red Hat Linux))
	id 1xInzL-0000000CVTC-2v9U;
	Mon, 19 Oct 2026 14:05:19 +0000
Date: Mon, 19 Oct 2026 15:05:19 +0100
From: Al Viro <viro@zeniv.linux.org.uk>
To: Avi Weiss <thnkslprpt@gmail.com>
Cc: Trond Myklebust <trondmy@kernel.org>, Anna Schumaker <anna@kernel.org>,
	Chuck Lever <cel@kernel.org>, Jeff Layton <jlayton@kernel.org>,
	NeilBrown <neil@brown.name>,
	Olga Kornievskaia <okorniev@redhat.com>,
	Dai Ngo <Dai.Ngo@oracle.com>, Tom Talpey <tom@talpey.com>,
	linux-nfs@vger.kernel.org, linux-kernel@vger.kernel.org
Subject: Re: [PATCH] sunrpc: instantiate rpc_pipefs dentry before publishing
 it
Message-ID: <20261019140519.GJ989762@ZenIV>
References: <20261019101117.54038-1-thnkslprpt@gmail.com>
Precedence: bulk
X-Mailing-List: linux-nfs@vger.kernel.org
List-Id: <linux-nfs.vger.kernel.org>
List-Subscribe: <mailto:linux-nfs+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:linux-nfs+unsubscribe@vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20261019101117.54038-1-thnkslprpt@gmail.com>
Sender: Al Viro <viro@ftp.linux.org.uk>

On Mon, Oct 19, 2026 at 01:11:17PM +0300, Avi Weiss wrote:
> rpc_mkpipe_dentry() publishes pipe->dentry before
> d_make_persistent() attaches its inode. A concurrent
> rpc_queue_upcall() or rpc_timeout_upcall_queue() can
> conceivably dereference the dentry while d_inode() is NULL.

Details, please...  I have no objections against the reordering
per se, but I would like to understand the scenario leading to
such a concurrent call.
