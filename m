Received: from smtp.kernel.org (aws-us-west-2-korg-mail-alma10-1.taild15c8.ts.net [100.103.45.18])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 79A3F399CE6;
	Thu,  4 Jun 2026 08:19:49 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=100.103.45.18
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1780561190; cv=none; b=FJBeKr6wN/r1iaYkUyAlrjKQ2M19SDGFVKjqp5SmMpV09Dv6Hocfu8mSF/bTX5/vgTAUWiiQxPRLe8+VMVtfsEqmUJI8YcdbgTxpM6vho3d8hSWU7ouLzPGbTTH/I6N6DoEHnpM1gq/YCMRbxg38po5iPPFSGI+qYyaa8JIfxgo=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1780561190; c=relaxed/simple;
	bh=/evIT5vb6i4hmiSR/DqXqCIK7Dt9ZYUmHTA2i2WiJrs=;
	h=Date:From:To:Cc:Subject:Message-ID:References:MIME-Version:
	 Content-Type:Content-Disposition:In-Reply-To; b=sMJRdoaxQzmsm3VEvq1nIXIS8WQiSKblDoQc+Jwp5MVQ1IbMvaT/Ecn96LCgCyQ40UIajrPN/P9LS3sNQPDvTyHCLemhjJRHFFsYXg7CuT0avlieRYpWVcwMgVEwNAY7d+02bfdCZSHzYHqpZyNG8QVovx9A4vXThSjJwtd+UIk=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.b=JLGNfpBV; arc=none smtp.client-ip=100.103.45.18
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.b="JLGNfpBV"
Received: by smtp.kernel.org (Postfix) with ESMTPSA id 22A541F00898;
	Thu,  4 Jun 2026 08:19:44 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=kernel.org;
	s=k20260515; t=1780561189;
	bh=VYrxUKw/nh6sRJP9IfEqp4mWcwg9s0A3xJ2XpyHROBU=;
	h=Date:From:To:Cc:Subject:References:In-Reply-To;
	b=JLGNfpBVWfxx36KiLlC/Qk6guC48/mOVATLoN0gRvinE3JqF/dmnpgSEVDgo5m5wl
	 4mg3VeKl2WZ3ZL7uUamdewZdngdomlZ6X6PiRl+0W1WjYT49F0fqHq9oQDahh/FgiU
	 NPrDSHB4ukNxZGeMeT7Pu8Gb/voiWcC87EjQCKfWD1a7f2wBIZZ3sE9LN7hv/N3cNn
	 g9L/AYaG1fISV6GRH4UfdAso0HrIeA5xmwpXp1ZLRW89DBM7uBFJBNiV+43JCUcrMg
	 8ijKgiGABkij3S42taF8WOO1JWTJXJ4SD7SGASh4uVhwShnaMgqGd3HRx4vhGrrGWa
	 xYhR0FerEMfaQ==
Date: Thu, 4 Jun 2026 10:19:43 +0200
From: Christian Brauner <brauner@kernel.org>
To: Mike Snitzer <snitzer@kernel.org>
Cc: Jeff Layton <jlayton@kernel.org>, 
	Alexander Viro <viro@zeniv.linux.org.uk>, Jan Kara <jack@suse.cz>, 
	"Matthew Wilcox (Oracle)" <willy@infradead.org>, Andrew Morton <akpm@linux-foundation.org>, 
	David Hildenbrand <david@kernel.org>, Lorenzo Stoakes <ljs@kernel.org>, 
	"Liam R. Howlett" <Liam.Howlett@oracle.com>, Vlastimil Babka <vbabka@kernel.org>, 
	Mike Rapoport <rppt@kernel.org>, Suren Baghdasaryan <surenb@google.com>, 
	Michal Hocko <mhocko@suse.com>, Jens Axboe <axboe@kernel.dk>, 
	Ritesh Harjani <ritesh.list@gmail.com>, Chuck Lever <chuck.lever@oracle.com>, 
	linux-fsdevel@vger.kernel.org, linux-kernel@vger.kernel.org, linux-nfs@vger.kernel.org, 
	linux-mm@kvack.org
Subject: Re: [PATCH v7 3/3] mm: kick writeback flusher for IOCB_DONTCACHE
 with targeted dirty tracking
Message-ID: <20260604-feind-eisblock-fischen-80a2d23c2300@brauner>
References: <20260511-dontcache-v7-0-2848ddce8090@kernel.org>
 <20260511-dontcache-v7-3-2848ddce8090@kernel.org>
 <20260511-zusieht-amputation-efe8b5058cb7@brauner>
 <7c0880ee25b13f64f71319203fcd7105f54e5ad0.camel@kernel.org>
 <20260511-caravan-behaupten-0402c454c22d@brauner>
 <aiAvWRr_3Y07Ba0V@kernel.org>
Precedence: bulk
X-Mailing-List: linux-nfs@vger.kernel.org
List-Id: <linux-nfs.vger.kernel.org>
List-Subscribe: <mailto:linux-nfs+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:linux-nfs+unsubscribe@vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Disposition: inline
In-Reply-To: <aiAvWRr_3Y07Ba0V@kernel.org>

On Wed, Jun 03, 2026 at 09:42:49AM -0400, Mike Snitzer wrote:
> On Mon, May 11, 2026 at 04:06:42PM +0200, Christian Brauner wrote:
> > On Mon, May 11, 2026 at 09:53:21AM -0400, Jeff Layton wrote:
> > > 
> > > That does look much cleaner. Do you want to just make that change or
> > > would you rather I resend?
> > 
> > I'll just fold it. I already have 1157 mails. I don't need more. :D
> > 
> 
> Hey Christian,
> 
> Did you happen to pick this series up from Jeff?  Not seeing it in any
> of your vfs-7.2 topic branches.
> 
> I could easily just not be looking in the correct place.

No, you were right to remind me! vfs-7.2.writeback!
