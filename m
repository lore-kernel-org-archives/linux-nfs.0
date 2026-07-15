Received: from verein.lst.de (verein.lst.de [213.95.11.211])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 470F325B0AC
	for <linux-nfs@vger.kernel.org>; Wed, 15 Jul 2026 04:41:36 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=213.95.11.211
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1784090499; cv=none; b=EzbnqjJwofPCG8ek24zUI0Mve+cWwIk1I/twVcqmECSzYlPSrg5rN1TyRf+DLcH6JOoijJ8b+PWPsuBU/8rZlLiVmz9f7My4+EB4+jwjDVkXcqF+4h+fpH7kgt3EcDbbvy6q04EzvHtRZcdz7a5oXwFZermISCAVdYi4vtz60QE=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1784090499; c=relaxed/simple;
	bh=M7NmYC/Iylm9myghHwqILim55SAUt9QrM+UZYk0eJlw=;
	h=Date:From:To:Cc:Subject:Message-ID:References:MIME-Version:
	 Content-Type:Content-Disposition:In-Reply-To; b=jd+SXouNxEWAN0v4LBLKO0y04m1zG8qDzJ7zi9iEpl7NbC+5SNoXxYDpSp4UkAkrjwL48FHa/PS4sDhPmuaf+iFGznTwR2CdoCLzcEEGi9LELvL+tHyQDy6t/U+FHx8TA8ca2mWm+V/6S+HwrU5DzoQt2a+Z0GSp/kB/aw+q26M=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dmarc=pass (p=none dis=none) header.from=lst.de; spf=pass smtp.mailfrom=lst.de; arc=none smtp.client-ip=213.95.11.211
Authentication-Results: smtp.subspace.kernel.org; dmarc=pass (p=none dis=none) header.from=lst.de
Authentication-Results: smtp.subspace.kernel.org; spf=pass smtp.mailfrom=lst.de
Received: by verein.lst.de (Postfix, from userid 2407)
	id E1A5C68C7B; Wed, 15 Jul 2026 06:41:33 +0200 (CEST)
Date: Wed, 15 Jul 2026 06:41:33 +0200
From: "hch@lst.de" <hch@lst.de>
To: Nate Prodromou <nate@prodromou.com>
Cc: "trond.myklebust@hammerspace.com" <trond.myklebust@hammerspace.com>,
	"anna@kernel.org" <anna@kernel.org>, "hch@lst.de" <hch@lst.de>,
	"linux-nfs@vger.kernel.org" <linux-nfs@vger.kernel.org>
Subject: Re: [PATCH] NFS: fix delegation_hash_table leak when
 nfs4_server_common_setup() fails
Message-ID: <20260715044133.GA16065@lst.de>
References: <SA1P220MB14925066FEE37CAC1C083DEBC8F92@SA1P220MB1492.NAMP220.PROD.OUTLOOK.COM>
Precedence: bulk
X-Mailing-List: linux-nfs@vger.kernel.org
List-Id: <linux-nfs.vger.kernel.org>
List-Subscribe: <mailto:linux-nfs+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:linux-nfs+unsubscribe@vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <SA1P220MB14925066FEE37CAC1C083DEBC8F92@SA1P220MB1492.NAMP220.PROD.OUTLOOK.COM>
User-Agent: Mutt/1.5.17 (2007-11-01)

Looks good:

Reviewed-by: Christoph Hellwig <hch@lst.de>

