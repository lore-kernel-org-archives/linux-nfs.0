Received: from verein.lst.de (verein.lst.de [213.95.11.211])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 8766C2F290A
	for <linux-nfs@vger.kernel.org>; Tue, 15 Sep 2026 06:38:52 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=213.95.11.211
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1789454334; cv=none; b=ejlvOQrGZNp9zKXA8FiS9BF509RxScPvS+JoS0/EEDy9H0qN1mUiuftHuIGKS5C0GUF5Af4DHtMzPKBsIatkR5GKR1tiDFKGMpg5awFJw/NDsl7jkRwGElQXEccor0kwVhEiqYvQkuyx1dmK6cgGsisoK9cKRhPLmG/Xkfl2cC4=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1789454334; c=relaxed/simple;
	bh=M7NmYC/Iylm9myghHwqILim55SAUt9QrM+UZYk0eJlw=;
	h=Date:From:To:Cc:Subject:Message-ID:References:MIME-Version:
	 Content-Type:Content-Disposition:In-Reply-To; b=TG2FiiT5oJpRK0DkhoF5CAd2rN1Ha6kXkfO+UJzgJldEU/tlwTnvJD0ww0frOMpfRc/naX8Iyhp33547GRRlA+UYJSclIQUgk7s3lAYZE2dV/3W/Ioyvvq44it/+UCPPubZUYPRXZjI1HWIXakHnuhnR5qx01KJ/D+RIeitBVU4=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dmarc=pass (p=none dis=none) header.from=lst.de; spf=pass smtp.mailfrom=lst.de; arc=none smtp.client-ip=213.95.11.211
Authentication-Results: smtp.subspace.kernel.org; dmarc=pass (p=none dis=none) header.from=lst.de
Authentication-Results: smtp.subspace.kernel.org; spf=pass smtp.mailfrom=lst.de
Received: by verein.lst.de (Postfix, from userid 2407)
	id DC25F68C4E; Tue, 15 Sep 2026 08:38:48 +0200 (CEST)
Date: Tue, 15 Sep 2026 08:38:48 +0200
From: Christoph Hellwig <hch@lst.de>
To: Trond Myklebust <trondmy@kernel.org>
Cc: linux-nfs@vger.kernel.org, Christoph Hellwig <hch@lst.de>
Subject: Re: [PATCH] NFSv4: Fix a regression in the handling of
 CB_RECALL_ANY
Message-ID: <20260915063848.GA13345@lst.de>
References: <115e4102b1bab159c25e8e903070b55cc4de77eb.1789148631.git.trond.myklebust@hammerspace.com>
Precedence: bulk
X-Mailing-List: linux-nfs@vger.kernel.org
List-Id: <linux-nfs.vger.kernel.org>
List-Subscribe: <mailto:linux-nfs+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:linux-nfs+unsubscribe@vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <115e4102b1bab159c25e8e903070b55cc4de77eb.1789148631.git.trond.myklebust@hammerspace.com>
User-Agent: Mutt/1.5.17 (2007-11-01)

Looks good:

Reviewed-by: Christoph Hellwig <hch@lst.de>

