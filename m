Received: from verein.lst.de (verein.lst.de [213.95.11.211])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 13BF12E9757
	for <linux-nfs@vger.kernel.org>; Thu, 18 Dec 2025 09:35:01 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=213.95.11.211
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1766050504; cv=none; b=Z5EYlQRtwpqDD+ZIvf/ejQ/tmEGgGaAseAPL+iS/ngvzIMWnNgPoi0ls2+aNm/qB+uMFxiy9z8h/ylBRYlPv0CeOkoyCi1f0FDi24pdXUAV6wfAwt4Ylnq21RYpIDGVzUTjoVmD22KWj+aFbM++PJnYkErNlqCoHL9hEVAojYbM=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1766050504; c=relaxed/simple;
	bh=qdw/MOLk3IesSigZZwwxwFLgVgvqfRq7DY9XU/BFrVY=;
	h=Date:From:To:Cc:Subject:Message-ID:References:MIME-Version:
	 Content-Type:Content-Disposition:In-Reply-To; b=Lak5cxfMC8LaA9POK2FkSekNRt+/kGtf6VoLBrs1XR+O5zicTDQmFx++c40wjs0eESeWXYXOFe6ilNef6ZCVaO26M0CFIXwSAfNd5XYx5WONIW9lfHyLdEoky2dVplioJ1FFiZ6zoF0g/vYSU+dvwWularHCrozK9w6ZZA7yaIk=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dmarc=pass (p=none dis=none) header.from=lst.de; spf=pass smtp.mailfrom=lst.de; arc=none smtp.client-ip=213.95.11.211
Authentication-Results: smtp.subspace.kernel.org; dmarc=pass (p=none dis=none) header.from=lst.de
Authentication-Results: smtp.subspace.kernel.org; spf=pass smtp.mailfrom=lst.de
Received: by verein.lst.de (Postfix, from userid 2407)
	id 207D568B05; Thu, 18 Dec 2025 10:34:59 +0100 (CET)
Date: Thu, 18 Dec 2025 10:34:58 +0100
From: Christoph Hellwig <hch@lst.de>
To: Dai Ngo <dai.ngo@oracle.com>
Cc: chuck.lever@oracle.com, jlayton@kernel.org, neilb@ownmail.net,
	okorniev@redhat.com, tom@talpey.com, hch@lst.de,
	linux-nfs@vger.kernel.org
Subject: Re: [PATCH 3/3] NFSD: Prevent redundant SCSI fencing operations
Message-ID: <20251218093458.GC9235@lst.de>
References: <20251215181418.2201035-1-dai.ngo@oracle.com> <20251215181418.2201035-4-dai.ngo@oracle.com>
Precedence: bulk
X-Mailing-List: linux-nfs@vger.kernel.org
List-Id: <linux-nfs.vger.kernel.org>
List-Subscribe: <mailto:linux-nfs+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:linux-nfs+unsubscribe@vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20251215181418.2201035-4-dai.ngo@oracle.com>
User-Agent: Mutt/1.5.17 (2007-11-01)

This should probably be kept with the previous patch it is closely
related.

