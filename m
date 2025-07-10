Received: from verein.lst.de (verein.lst.de [213.95.11.211])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 66AF72701C0;
	Thu, 10 Jul 2025 07:25:22 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=213.95.11.211
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1752132323; cv=none; b=O8xnOcWL58kQC2gYUDAAVQi8nC0tx7MrqqNkoVFpndwOpCawcQx9zI7nBladQJpTgiwb9t1+3EKYTSHxT8g2l5hEeOMlQ7kFjb02K58RAjyzn1Gn/I6nj8RP6xltBui4aRsZcMls9qoCv3J5dpMH3cFHwVU9RndacUzwKPAVa/Q=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1752132323; c=relaxed/simple;
	bh=6z1Z5uUFlCZq7E2YDdQdCd6cRhu1KuYF7IR3HWNq+rQ=;
	h=Date:From:To:Cc:Subject:Message-ID:References:MIME-Version:
	 Content-Type:Content-Disposition:In-Reply-To; b=CYaak/2N/KpKIfA7tgMmqI2Y/m4hH3GVt4Ew3xQsMoNVGddU/6KKVbhS64qDvVcsaRir5mlvlZwrsMD61n2yjLdW3KBYFBaFD7f7tp2xvKfu4Ekn1yTXG/0sXtkKseMFdqeuMYP8Ront/gRiV07HUIGb0VMcBMRLj5A87bcLYyQ=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dmarc=pass (p=none dis=none) header.from=lst.de; spf=pass smtp.mailfrom=lst.de; arc=none smtp.client-ip=213.95.11.211
Authentication-Results: smtp.subspace.kernel.org; dmarc=pass (p=none dis=none) header.from=lst.de
Authentication-Results: smtp.subspace.kernel.org; spf=pass smtp.mailfrom=lst.de
Received: by verein.lst.de (Postfix, from userid 2407)
	id 057FA67373; Thu, 10 Jul 2025 09:25:18 +0200 (CEST)
Date: Thu, 10 Jul 2025 09:25:17 +0200
From: Christoph Hellwig <hch@lst.de>
To: Chuck Lever <chuck.lever@oracle.com>,
	Trond Myklebust <trondmy@kernel.org>
Cc: Anna Schumaker <anna@kernel.org>, David Howells <dhowells@redhat.com>,
	Jarkko Sakkinen <jarkko@kernel.org>, linux-nfs@vger.kernel.org,
	kernel-tls-handshake <kernel-tls-handshake@lists.linux.dev>,
	keyrings@vger.kernel.org
Subject: Re: support keyrings for NFS TLS mounts v2
Message-ID: <20250710072517.GA5891@lst.de>
References: <20250515115107.33052-1-hch@lst.de>
Precedence: bulk
X-Mailing-List: linux-nfs@vger.kernel.org
List-Id: <linux-nfs.vger.kernel.org>
List-Subscribe: <mailto:linux-nfs+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:linux-nfs+unsubscribe@vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20250515115107.33052-1-hch@lst.de>
User-Agent: Mutt/1.5.17 (2007-11-01)

Trond/Anna:

can you queue this up?  If not can you tell me what is missing?

