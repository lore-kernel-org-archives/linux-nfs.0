Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.remote-ip=213.95.11.211
ARC-Seal: i=1; d=subspace.kernel.org; s=arc20261015; a=rsa-sha256; cv=none;
	t=1793204326;
	b=ZOUTvwdNJ1JMRLghSug0bfApw1pOgcCkHR/N/YFuqyQc5DQjTjZAl+9Ae/QzzWYG2gCv
	 FKJG1HvlaumGuj2puzo9BET1aOAUl3NlIcuh/856lM+VVhLGiZIF7nkEZhKpOxCanaI7n
	 UhR2irx0GlxuXvJsX71R+E52r8ka1L3gxpqGqssTQXG45G2+Yc0LeTonVd8a3pIIZ6SKd
	 8N0EJfg+KkyARBEN7o1AzIEryhaLfkifTwKIFHPrqcD1F9zmpcULVgAYLJ5K2O0o60hHz
	 AoHcz58DBUr1dcnBvyId6nsPTAfXCQzM1dYq55EyddvOdJ1ii8RZaE592n5yU4GTOTw==
ARC-Message-Signature: i=1; d=subspace.kernel.org; s=arc20261015;
	a=rsa-sha256; c=relaxed/relaxed; t=1793204326;
	h=DMARC-Filter:Received:Date:From:To:Cc:Subject:Message-ID:References:
	 MIME-Version:Content-Type:Content-Disposition:In-Reply-To:User-Agent;
	bh=M7NmYC/Iylm9myghHwqILim55SAUt9QrM+UZYk0eJlw=;
	b=ECJcg1gS7MN4wC1eS4HBhyBFm9Bf/fwppRuI0aAbVtg3t/N9bwA0Pow+dFYtoSExrKLO
	 cM2qHUuilE8VcokBB17NqxOfvSeDsdFmyg9F4OtFY1hqBj0WMpiFLotO7FQWd/lqR4oW0
	 DzNad2CeRBY4WQzU2blslBShjfeCaj+L6VbuRc3atAQJMLlw0H7phEb4cO0uDNO44s2Om
	 i6t48SJJzK4tE6ibSXG+aAziIERJ/CA75CDVLB0L6KHktM2ckStQt9wT2VlnQO1pVh4Sq
	 R46ASf9kDSXAi2nqjKA245sVtUnZRJ30AJVlgD34xRp2XIhS10w10AU4DE+tm+imMzQ==
ARC-Authentication-Results: i=1; smtp.subspace.kernel.org; 
	dmarc=pass header.from=lst.de;
	spf=pass smtp.mailfrom=lst.de;
	arc=none smtp.remote-ip=213.95.11.211
Received: from verein.lst.de (verein.lst.de [213.95.11.211])
	(using TLSv1.2 with cipher ECDHE-ECDSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 8C272606A31A
	for <linux-nfs@vger.kernel.org>; Wed, 28 Oct 2026 16:18:45 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.4.2 smtp.subspace.kernel.org 8C272606A31A
Authentication-Results: smtp.subspace.kernel.org; dmarc=pass (p=none dis=none) header.from=lst.de
Authentication-Results: smtp.subspace.kernel.org; spf=pass smtp.mailfrom=lst.de
Received: by verein.lst.de (Postfix, from userid 2407)
	id 55D3568AFE; Wed, 28 Oct 2026 17:18:42 +0100 (CET)
Date: Wed, 28 Oct 2026 17:18:42 +0100
From: Christoph Hellwig <hch@lst.de>
To: Benjamin Coddington <ben.coddington@hammerspace.com>
Cc: Trond Myklebust <trondmy@kernel.org>, Anna Schumaker <anna@kernel.org>,
	linux-nfs@vger.kernel.org, Daejun Park <daejun7.park@samsung.com>
Subject: Re: [PATCH v2 2/2] pnfs/blocklayout: report data lost to a failed
 LAYOUTCOMMIT
Message-ID: <20261028161842.GB21989@lst.de>
References: <cover.1792157092.git.bcodding@hammerspace.com> <f1a9f1337cbbb4039a29fb5808d8c2944b9a112c.1792157092.git.bcodding@hammerspace.com>
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
In-Reply-To: <f1a9f1337cbbb4039a29fb5808d8c2944b9a112c.1792157092.git.bcodding@hammerspace.com>
User-Agent: Mutt/1.5.17 (2007-11-01)

Looks good:

Reviewed-by: Christoph Hellwig <hch@lst.de>
