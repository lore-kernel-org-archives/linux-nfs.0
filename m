Received: from verein.lst.de (verein.lst.de [213.95.11.211])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 7EBCB3603D8;
	Thu, 23 Apr 2026 05:20:08 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=213.95.11.211
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1776921609; cv=none; b=ZHjPCZ0sQ6QM6czVOqo4otktqu/lPwpDtvyrw/a3LQZzTkIAa6bElLuNbnAE5VU2UAyvVBEZSb1lXrrd4JK2PB7l2fA019dWIultZz+Ld9VFzPfAPanwV/kI50/zrLEgLZpy+G7bsD5SaozMUE7pmYjXHm8nmSYxRyJ6cZztSwg=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1776921609; c=relaxed/simple;
	bh=kt56FqSe1jfrbbuY/LnA5QGyZo9puDHHCoXrlvYsZyQ=;
	h=Date:From:To:Cc:Subject:Message-ID:References:MIME-Version:
	 Content-Type:Content-Disposition:In-Reply-To; b=ByvfdgzVo3clnhIXv8uDiWxiM/pPA4G7pU+bN7sdF5zxT2pUyrj9PWs4jnFcLJtXC0dg7puVLYPGraCcz/ilpXE+KFGzZcTOa0jqH4pDrC7m5AB85x5wDT8+Pk9b9uq7/X4+hEfjlVPxf6a9wip1w1ymlP40/n1hy8wDHrcen+w=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dmarc=pass (p=none dis=none) header.from=lst.de; spf=pass smtp.mailfrom=lst.de; arc=none smtp.client-ip=213.95.11.211
Authentication-Results: smtp.subspace.kernel.org; dmarc=pass (p=none dis=none) header.from=lst.de
Authentication-Results: smtp.subspace.kernel.org; spf=pass smtp.mailfrom=lst.de
Received: by verein.lst.de (Postfix, from userid 2407)
	id 0359068B05; Thu, 23 Apr 2026 07:20:05 +0200 (CEST)
Date: Thu, 23 Apr 2026 07:20:05 +0200
From: Christoph Hellwig <hch@lst.de>
To: Werner Kasselman <werner@verivus.ai>
Cc: Trond Myklebust <trondmy@kernel.org>, Anna Schumaker <anna@kernel.org>,
	Christoph Hellwig <hch@lst.de>,
	"linux-nfs@vger.kernel.org" <linux-nfs@vger.kernel.org>,
	"linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
	"stable@vger.kernel.org" <stable@vger.kernel.org>
Subject: Re: [PATCH 0/2] pnfs/blocklayout: harden GETDEVICEINFO volume
 parser
Message-ID: <20260423052005.GA28150@lst.de>
References: <20260421100338.1227152-1-werner@verivus.com>
Precedence: bulk
X-Mailing-List: linux-nfs@vger.kernel.org
List-Id: <linux-nfs.vger.kernel.org>
List-Subscribe: <mailto:linux-nfs+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:linux-nfs+unsubscribe@vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20260421100338.1227152-1-werner@verivus.com>
User-Agent: Mutt/1.5.17 (2007-11-01)

On Tue, Apr 21, 2026 at 10:03:40AM +0000, Werner Kasselman wrote:
> A standalone test exercising all three bug classes and the fixes is at:
>   tools/testing/pnfs-blocklayout/test-volume-parser.c

Not really, but maybe you wanted to send it out? :)

