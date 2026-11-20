Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.remote-ip=213.95.11.211
ARC-Seal: i=1; d=subspace.kernel.org; s=arc20261015; a=rsa-sha256; cv=none;
	t=1795191201;
	b=U0BXLDV5PWazQsq7CCy7be5qSMl0rKv5XpHRjbREHq6Lp7m7TDsRjby1+oI+9fCpnlnW
	 MW3TZ4yFUUqKgu9kDOiWOP51dJNaJIxDDuWQ46zC3nbc6eibrBAEUQp+4pjzzf6L7yQHb
	 tjZIuKSC/oNBDrAH/FLueS/M/LKyfOaHUtGb6JIGcW+xdE2n/U/kTCx9v8sN81QEE8S+f
	 O0fjrHRkJulmZ+/ZfY9KXWk4xCfv5nMfbkdiHT3jU9606zegwPwamz7GyXR69hp+uPsFQ
	 CVkA1EWAJzi1zk5uBm+nQ/mCVDdiI4/pmtGhJFP0kb4gvywYcPhd7RDLYeSOaQbHL8A==
ARC-Message-Signature: i=1; d=subspace.kernel.org; s=arc20261015;
	a=rsa-sha256; c=relaxed/relaxed; t=1795191201;
	h=DMARC-Filter:Received:Date:From:To:Cc:Subject:Message-ID:References:
	 MIME-Version:Content-Type:Content-Disposition:In-Reply-To:User-Agent;
	bh=M7NmYC/Iylm9myghHwqILim55SAUt9QrM+UZYk0eJlw=;
	b=VV64GlbcrTWQBgcoyPryNZVH3escJ6LYUL7ghoJh36VxXmvOyIFKZHznfHahYpiJugVI
	 nozUUSGy/bhSdBa41Tty5JWgI8dIvuheOzpoPUfv083fZ8dBbP8jUlGfLgqxrgAHLaENO
	 G2I3J6v/4YWeGc0npT46AxbQUYaXA27I1jCSfAzD2oggEdGvGlXr4tdHfo1EAw25CveK8
	 ALmqpSKQDbidlH0u3Ly2E2THYhtPcbLU6oVYwKEvboozqHS1xLxQzRcKapeXyPZHrkX+H
	 uTDxqZCAn1fIl0hDwwpOXG28ASlB8j/znsKYk9u/fVzH8nMgXVkZ9tJZORUNxkcTVZw==
ARC-Authentication-Results: i=1; smtp.subspace.kernel.org; 
	dmarc=pass header.from=lst.de;
	spf=pass smtp.mailfrom=lst.de;
	arc=none smtp.remote-ip=213.95.11.211
Received: from verein.lst.de (verein.lst.de [213.95.11.211])
	(using TLSv1.2 with cipher ECDHE-ECDSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 0024C606A32C
	for <linux-nfs@vger.kernel.org>; Fri, 20 Nov 2026 16:13:20 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.4.2 smtp.subspace.kernel.org 0024C606A32C
Authentication-Results: smtp.subspace.kernel.org; dmarc=pass (p=none dis=none) header.from=lst.de
Authentication-Results: smtp.subspace.kernel.org; spf=pass smtp.mailfrom=lst.de
Received: by verein.lst.de (Postfix, from userid 2407)
	id BE4546732A; Fri, 20 Nov 2026 17:13:17 +0100 (CET)
Date: Fri, 20 Nov 2026 17:13:17 +0100
From: Christoph Hellwig <hch@lst.de>
To: Chuck Lever <cel@kernel.org>
Cc: Christoph Hellwig <hch@lst.de>, Jeff Layton <jlayton@kernel.org>,
	NeilBrown <neil@brown.name>,
	Olga Kornievskaia <okorniev@redhat.com>,
	Dai Ngo <Dai.Ngo@oracle.com>, Tom Talpey <tom@talpey.com>,
	Sergey Bashirov <sergeybashirov@gmail.com>,
	Konstantin Evtushenko <koevtushenko@yandex.com>,
	linux-nfs@vger.kernel.org
Subject: Re: [PATCH 2/4] NFSD: Allocate the layoutupdate extent array with
 kvzalloc_objs()
Message-ID: <20261120161317.GB31082@lst.de>
References: <20261119-blocklayout-decode-stream-v1-0-d71322f42c28@kernel.org> <20261119-blocklayout-decode-stream-v1-2-d71322f42c28@kernel.org>
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
In-Reply-To: <20261119-blocklayout-decode-stream-v1-2-d71322f42c28@kernel.org>
User-Agent: Mutt/1.5.17 (2007-11-01)

Looks good:

Reviewed-by: Christoph Hellwig <hch@lst.de>

