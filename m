Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.remote-ip=213.95.11.211
ARC-Seal: i=1; d=subspace.kernel.org; s=arc20261015; a=rsa-sha256; cv=none;
	t=1793696945;
	b=wxeNwpkObaJWF/0ThS5a5d8MnXgpkR4qx+iKaR6SSu1L/0EIP6+tlxaFEaQ6kAITdj7H
	 K79N3j07KVbWrhEbda1QWKdmatXYiP7exH9hd6B7qnPg+z5IQNYWtJ7MKr5ht9WNSjwzm
	 59umxrDBBzoEU2kl4CP5uRZhTs2LQybMvLRjv5D4lPd6C+rklCpR4P10LANL+Fb0Nhpdr
	 4IzMvcuNqS4xHU/QO1wUc3IUXLVbHyAxDDazjdNx1uSLkGTZdB7LYkcoZS085av3OTW/6
	 E46KHhGAUEkDupQkTkCfelMN/W6F179jhNkCiCD3ulYRK+Z83Zhy8Rqj159Kvhe5tYQ==
ARC-Message-Signature: i=1; d=subspace.kernel.org; s=arc20261015;
	a=rsa-sha256; c=relaxed/relaxed; t=1793696945;
	h=DMARC-Filter:Received:Date:From:To:Cc:Subject:Message-ID:References:
	 MIME-Version:Content-Type:Content-Disposition:In-Reply-To:User-Agent;
	bh=M7NmYC/Iylm9myghHwqILim55SAUt9QrM+UZYk0eJlw=;
	b=z7XJ3s90X2/SMxvNuVrRWuUzDXou57oBobwR/lpj1OXB6GvbzpbmENp5nDzoILBtqMcU
	 zMEVkspJur7l24dQ96AhidffjSYgcka/9C+SGZ32MVBJ3DAOZ3v/AtkyK4u6sPI7M4YhQ
	 4Xk0jgMhujH94B5bxYqV+FJtnddYYIEXMfibbqA7FaE9ReDDNQSSDwvLhARYSJi5VgAOr
	 LxzBDzCIOoF0Z7uKuvNXJ+y6zydRlroi6lJycW+2ajKpsYRWjWTZ1X+8UicYqrGNkQulo
	 MGN165ie1GTok35KPyFpnOGehLnnDZFdr0jX3flWoCNXaUdmirG9hkAoigIiQdPNzmg==
ARC-Authentication-Results: i=1; smtp.subspace.kernel.org; 
	dmarc=pass header.from=lst.de;
	spf=pass smtp.mailfrom=lst.de;
	arc=none smtp.remote-ip=213.95.11.211
Received: from verein.lst.de (verein.lst.de [213.95.11.211])
	(using TLSv1.2 with cipher ECDHE-ECDSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 9375A606A324
	for <linux-nfs@vger.kernel.org>; Tue,  3 Nov 2026 09:09:04 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.4.2 smtp.subspace.kernel.org 9375A606A324
Authentication-Results: smtp.subspace.kernel.org; dmarc=pass (p=none dis=none) header.from=lst.de
Authentication-Results: smtp.subspace.kernel.org; spf=pass smtp.mailfrom=lst.de
Received: by verein.lst.de (Postfix, from userid 2407)
	id 2115F68B05; Tue,  3 Nov 2026 10:09:00 +0100 (CET)
Date: Tue, 3 Nov 2026 10:08:59 +0100
From: Christoph Hellwig <hch@lst.de>
To: daejun7.park@samsung.com
Cc: Trond Myklebust <trondmy@kernel.org>, Anna Schumaker <anna@kernel.org>,
	Christoph Hellwig <hch@lst.de>,
	Benjamin Coddington <ben.coddington@hammerspace.com>,
	linux-nfs@vger.kernel.org
Subject: Re: [PATCH] pnfs/blocklayout: commit the layout before reading
 through the MDS
Message-ID: <20261103090859.GA5422@lst.de>
References: <20261103-nfs-bl-mdsread-v1-1-9b29915bbab7@samsung.com>
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
In-Reply-To: <20261103-nfs-bl-mdsread-v1-1-9b29915bbab7@samsung.com>
User-Agent: Mutt/1.5.17 (2007-11-01)

Looks good:

Reviewed-by: Christoph Hellwig <hch@lst.de>

