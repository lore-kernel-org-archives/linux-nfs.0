Received: from zeniv.linux.org.uk (zeniv.linux.org.uk [62.89.141.173])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 0C202392C42;
	Wed,  3 Jun 2026 19:26:02 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=62.89.141.173
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1780514764; cv=none; b=A97Sa5dqxQ/hHy9a9CEb8xFahSK/JqzFjNmJ081T7OWctxWTESICqIAUDbJubiMscnrLaHh83Vf9r9otShKG/l701Kp49cg85vhoBs/CAMoxhquWO7kCFCB4HJrZLY1BPyG3FTr1g8yunydzRcI0REiMDxcrnu+g3QCRSCD2B6I=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1780514764; c=relaxed/simple;
	bh=QVlkX2E8iDFOe4j5RGhchIX1THfbnqzA1888jRaMDw0=;
	h=Date:From:To:Cc:Subject:Message-ID:References:MIME-Version:
	 Content-Type:Content-Disposition:In-Reply-To; b=U81jljkhwOzZs0ZuTVDrP1SBRlJ2vT+Z/0iaiGxTJHrBVEyA39ZM7pl6VUXRCf3XsOUi1R4Oettyw0l+EB9UQQgorGK05BeTuyX2MCi0AKEkj2P6mHd/LygDYEkgOEU0KOVzwAzY2L8HTEvfUgGVjXkHodtzQw+Ix0/6MH6IiVg=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dmarc=pass (p=none dis=none) header.from=zeniv.linux.org.uk; spf=none smtp.mailfrom=ftp.linux.org.uk; dkim=pass (2048-bit key) header.d=linux.org.uk header.i=@linux.org.uk header.b=M6f7FF3J; arc=none smtp.client-ip=62.89.141.173
Authentication-Results: smtp.subspace.kernel.org; dmarc=pass (p=none dis=none) header.from=zeniv.linux.org.uk
Authentication-Results: smtp.subspace.kernel.org; spf=none smtp.mailfrom=ftp.linux.org.uk
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=linux.org.uk header.i=@linux.org.uk header.b="M6f7FF3J"
DKIM-Signature: v=1; a=rsa-sha256; q=dns/txt; c=relaxed/relaxed;
	d=linux.org.uk; s=zeniv-20220401; h=Sender:In-Reply-To:Content-Type:
	MIME-Version:References:Message-ID:Subject:Cc:To:From:Date:Reply-To:
	Content-Transfer-Encoding:Content-ID:Content-Description;
	bh=g/2xJpnHysjfxcynfshyRZy4HNP70kVBpzuH7PUMLlc=; b=M6f7FF3JUO32ezTogdRHjBIFKi
	Ttv32gXMj2PnBa2iuQSb9FpSru1s5MCDYuXQ72RWUGuwA+JZK9fuPqIVflvF0i8zSE4o/yjc7cRjM
	wbEx3oK3mtwXOYrP84os1dns3+WmRL1qjXoIuIwjTtnMJMVxOhJmhTgKGJAY1UzIABSsdUQnA5lyS
	r2VaHxfkgHcZDotJiIIFo7pSf0PGWa3nWN8cefRqsDGX/BobtEpBbMzKjP5BU43ol5lve3mLTbGx5
	MTSS1pN/4EaYk2h1zbFECZgooMSgIkFtQHJSz/d0movlCyiDXeszkuaiQOQvTwhJfCgWp8zf37jj7
	RescRvVw==;
Received: from viro by zeniv.linux.org.uk with local (Exim 4.99.2 #2 (Red Hat Linux))
	id 1wUrDz-0000000FKCy-0s9k;
	Wed, 03 Jun 2026 19:25:59 +0000
Date: Wed, 3 Jun 2026 20:25:59 +0100
From: Al Viro <viro@zeniv.linux.org.uk>
To: Jann Horn <jannh@google.com>
Cc: Christian Brauner <brauner@kernel.org>, Jan Kara <jack@suse.cz>,
	Chuck Lever <chuck.lever@oracle.com>,
	Jeff Layton <jlayton@kernel.org>,
	Amir Goldstein <amir73il@gmail.com>, linux-fsdevel@vger.kernel.org,
	linux-nfs@vger.kernel.org, linux-kernel@vger.kernel.org,
	stable@vger.kernel.org
Subject: Re: [PATCH] fhandle: fix UAF due to unlocked ->mnt_ns read in
 may_decode_fh()
Message-ID: <20260603192559.GC2636677@ZenIV>
References: <20260603-vfs-fhandle-uaf-fix-v1-1-ff64ee367e4d@google.com>
 <20260603181523.GW2636677@ZenIV>
 <20260603182454.GX2636677@ZenIV>
 <CAG48ez0Jte3UE8wn9Ljs3o2uVDFB24Zbp9zBdaj+D5c4R0+TSQ@mail.gmail.com>
 <20260603185324.GA2636677@ZenIV>
 <20260603190225.GB2636677@ZenIV>
 <CAG48ez34NaE5DCdC=VQWFRPds6JHwGq2YJDF5e6XUtGPNfQq+g@mail.gmail.com>
Precedence: bulk
X-Mailing-List: linux-nfs@vger.kernel.org
List-Id: <linux-nfs.vger.kernel.org>
List-Subscribe: <mailto:linux-nfs+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:linux-nfs+unsubscribe@vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <CAG48ez34NaE5DCdC=VQWFRPds6JHwGq2YJDF5e6XUtGPNfQq+g@mail.gmail.com>
Sender: Al Viro <viro@ftp.linux.org.uk>

On Wed, Jun 03, 2026 at 09:08:26PM +0200, Jann Horn wrote:

> (And there's also that weird detail of how, for anonymous namespaces,
> the active refcount isn't used and AFAICS never actually drops to
> zero...)

More like "is always 1 and we skip decrement when we decide to drop
that", really.

> So I guess I'll write "Containing namespace (active or deactivating,
> non-refcounted)."?

That would probably do for now...  The lifecycle for mnt_namespace
really needs to be documented; right now we have a maze of twisty
little functions around that area and it takes quite a non-trivial
amount of searching to recall the names - and I am familiar with
the area ;-/
