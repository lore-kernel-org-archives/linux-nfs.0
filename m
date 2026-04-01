Received: from verein.lst.de (verein.lst.de [213.95.11.211])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id BE0E54657DA;
	Wed,  1 Apr 2026 14:27:47 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=213.95.11.211
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1775053669; cv=none; b=bocCxh6jAs1L+yr4S9BCl4oMJxA5SHeaIWe119RTTi7b2nxkBmhERoHthEuhNdfBcWSfaChjrd4qtu13RVC6la4xqMSHq1zVK1vMiJ+ZZW41rea3171O8S5QalncDYVS4AL5JczGPORPR8DilCMyO8H3n3Kqh0qA5G5rF9cJ88g=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1775053669; c=relaxed/simple;
	bh=WnImCkZ1Mdm+jMGMpClHqPFH1tVwepQ6nt/xEYCLy5Y=;
	h=Date:From:To:Cc:Subject:Message-ID:References:MIME-Version:
	 Content-Type:Content-Disposition:In-Reply-To; b=XdzOm+fuNXfgcKGffTDbRTGyPFqgGKR7F+xDVevsZLzs+NWQcpymyfTHrYkADYA7CUqru3r0XFNvMR1wGQnKZpGLhi3mgXZtC3IBRBB4wNCW0n8BnjsHtuRm7oiVsSDmBE29uuqzHjXa5ojxQFLTS0qPNgRzS4sYDyxIJYpYNpA=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dmarc=pass (p=none dis=none) header.from=lst.de; spf=pass smtp.mailfrom=lst.de; arc=none smtp.client-ip=213.95.11.211
Authentication-Results: smtp.subspace.kernel.org; dmarc=pass (p=none dis=none) header.from=lst.de
Authentication-Results: smtp.subspace.kernel.org; spf=pass smtp.mailfrom=lst.de
Received: by verein.lst.de (Postfix, from userid 2407)
	id 95A7068C4E; Wed,  1 Apr 2026 16:27:43 +0200 (CEST)
Date: Wed, 1 Apr 2026 16:27:43 +0200
From: Christoph Hellwig <hch@lst.de>
To: Jeff Layton <jlayton@kernel.org>
Cc: Christoph Hellwig <hch@lst.de>, Chuck Lever <chuck.lever@oracle.com>,
	Amir Goldstein <amir73il@gmail.com>, NeilBrown <neil@brown.name>,
	Olga Kornievskaia <okorniev@redhat.com>,
	Dai Ngo <Dai.Ngo@oracle.com>, Tom Talpey <tom@talpey.com>,
	linux-nfs@vger.kernel.org, linux-fsdevel@vger.kernel.org
Subject: Re: [PATCH 2/4] exportfs: split out the ops for layout-based block
 device access
Message-ID: <20260401142743.GB22685@lst.de>
References: <20260331153406.4049290-1-hch@lst.de> <20260331153406.4049290-3-hch@lst.de> <a916e82550e128c22c0e559b16f68b8cd56c8b05.camel@kernel.org>
Precedence: bulk
X-Mailing-List: linux-nfs@vger.kernel.org
List-Id: <linux-nfs.vger.kernel.org>
List-Subscribe: <mailto:linux-nfs+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:linux-nfs+unsubscribe@vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <a916e82550e128c22c0e559b16f68b8cd56c8b05.camel@kernel.org>
User-Agent: Mutt/1.5.17 (2007-11-01)

On Tue, Mar 31, 2026 at 01:24:23PM -0400, Jeff Layton wrote:
> Meh, ok. Almost doesn't seem worthwhile, but I guess the result is a
> bit cleaner layering-wise.

It also avoid pulling extra includes into exportfs.h only needed for
the new block layout inline helpers added in the last patch.

