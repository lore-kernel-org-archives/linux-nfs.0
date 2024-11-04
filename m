Received: from verein.lst.de (verein.lst.de [213.95.11.211])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 762A7178CEC
	for <linux-nfs@vger.kernel.org>; Mon,  4 Nov 2024 07:31:02 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=213.95.11.211
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1730705465; cv=none; b=mT4rtsNC3ciGuBNg7ruM+DJpqFYJJJaFh4xjaj5JWs+5C6VtRIaAZUcbHM0+o4X3eAJyidmHGUEQDflG3/Zqb09kjg4owQZbuqOiub4xhg8pepDB/7aCXi71PpY8iv5CUCEGSWwVyGD/CRjInKfYG0NRv4/3AxIaqHSdWcLsu0A=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1730705465; c=relaxed/simple;
	bh=M7NmYC/Iylm9myghHwqILim55SAUt9QrM+UZYk0eJlw=;
	h=Date:From:To:Cc:Subject:Message-ID:References:MIME-Version:
	 Content-Type:Content-Disposition:In-Reply-To; b=DYYyrCBCObiNl654XYMIc9bVIgWs8p041pFS6yd9fr+jObyNfs0+PdTFCqVD23ggDPrZg5HngbB/hhP+hP/f4wEa7R8O9FuoUBvjTEKzmTTLwaaJjlSyOzerXiVgs0PqNO4pHTiQwhheMOYBdB7IJrYh98vxofx3p80W5S2t/Sk=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dmarc=none (p=none dis=none) header.from=lst.de; spf=pass smtp.mailfrom=lst.de; arc=none smtp.client-ip=213.95.11.211
Authentication-Results: smtp.subspace.kernel.org; dmarc=none (p=none dis=none) header.from=lst.de
Authentication-Results: smtp.subspace.kernel.org; spf=pass smtp.mailfrom=lst.de
Received: by verein.lst.de (Postfix, from userid 2407)
	id DAA9F68AFE; Mon,  4 Nov 2024 08:30:58 +0100 (CET)
Date: Mon, 4 Nov 2024 08:30:58 +0100
From: Christoph Hellwig <hch@lst.de>
To: Benjamin Coddington <bcodding@redhat.com>
Cc: Alasdair Kergon <agk@redhat.com>, Mike Snitzer <snitzer@kernel.org>,
	Mikulas Patocka <mpatocka@redhat.com>,
	Christoph Hellwig <hch@lst.de>, dm-devel@lists.linux.dev,
	linux-nfs@vger.kernel.org
Subject: Re: [PATCH v2] dm: add support for get_unique_id
Message-ID: <20241104073058.GA20575@lst.de>
References: <701894fdf55ce2cb379eb26f6ee0536f96103ab9.1730387019.git.bcodding@redhat.com>
Precedence: bulk
X-Mailing-List: linux-nfs@vger.kernel.org
List-Id: <linux-nfs.vger.kernel.org>
List-Subscribe: <mailto:linux-nfs+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:linux-nfs+unsubscribe@vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <701894fdf55ce2cb379eb26f6ee0536f96103ab9.1730387019.git.bcodding@redhat.com>
User-Agent: Mutt/1.5.17 (2007-11-01)

Looks good:

Reviewed-by: Christoph Hellwig <hch@lst.de>

