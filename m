Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.remote-ip=213.95.11.211
ARC-Seal: i=1; d=subspace.kernel.org; s=arc20261015; a=rsa-sha256; cv=none;
	t=1793204303;
	b=gvhjY7493aecRyTcSlNao32KT74nYtZNChvkIQyAvFkANXIXVW7ezIBJT5kWnUwLLPHQ
	 hOg6uvhZRJECRMBwok0oRni0ZinvQTLXcJh6O9rFokVKVbqKcUccDr2dB4QIEciPHMkdP
	 P2ajFgb0ItsNc6CL/TXug51rmpNAPmUAHZalkjpd0OTZFQ0pVQ992jhO4+vt/mZE9Bpe+
	 Qc8P3tMrmXmzOyHKhLR4vr9t9pTVpGb5b1ehRJ1W4LuwZrnoY9mTvs8RJmbMHg2gNsLAd
	 KmPpLEACZryKBrWk1RXNkvMKXsuQSm5ygJsFT5o5n3+AEQSkSROGUI9J5wPMYvz0nqQ==
ARC-Message-Signature: i=1; d=subspace.kernel.org; s=arc20261015;
	a=rsa-sha256; c=relaxed/relaxed; t=1793204303;
	h=DMARC-Filter:Received:Date:From:To:Cc:Subject:Message-ID:References:
	 MIME-Version:Content-Type:Content-Disposition:In-Reply-To:User-Agent;
	bh=M7NmYC/Iylm9myghHwqILim55SAUt9QrM+UZYk0eJlw=;
	b=pYduPLfpcbQwStjTDO9hZhwMt019nk7h+QP+MhiVhG3/J7Cvf77p0O7sVNizmNjzK966
	 MyRXwdP7DYlzcFiji5GrrRjpsJUVdWqlMbKR3PA60t3xX1VbmaJpGTFrQh2koUvbwOkPV
	 sQ/YjcDj6AP4cVnREfxzgT0ercTSRnhnfi5dJnViVXUOEyBNsqdH1fCfcHBos26abwl+i
	 bYXp/orqec7gZcntVdH3cbyTE4GE9bQMmvKq2GMo9y6z0vV7D7lrMnsSqM/7N/cOTcqF/
	 sJQOyCVlF9Oc4KGxbcEfkc0GkpX8xVIMtYMNE4rKhxYMZcWO5nFYSa9Kp9+ORZ2G8AA==
ARC-Authentication-Results: i=1; smtp.subspace.kernel.org; 
	dmarc=pass header.from=lst.de;
	spf=pass smtp.mailfrom=lst.de;
	arc=none smtp.remote-ip=213.95.11.211
Received: from verein.lst.de (verein.lst.de [213.95.11.211])
	(using TLSv1.2 with cipher ECDHE-ECDSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 25FA3606A320
	for <linux-nfs@vger.kernel.org>; Wed, 28 Oct 2026 16:18:23 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.4.2 smtp.subspace.kernel.org 25FA3606A320
Authentication-Results: smtp.subspace.kernel.org; dmarc=pass (p=none dis=none) header.from=lst.de
Authentication-Results: smtp.subspace.kernel.org; spf=pass smtp.mailfrom=lst.de
Received: by verein.lst.de (Postfix, from userid 2407)
	id CCF1868AFE; Wed, 28 Oct 2026 17:18:19 +0100 (CET)
Date: Wed, 28 Oct 2026 17:18:19 +0100
From: Christoph Hellwig <hch@lst.de>
To: Benjamin Coddington <ben.coddington@hammerspace.com>
Cc: Trond Myklebust <trondmy@kernel.org>, Anna Schumaker <anna@kernel.org>,
	linux-nfs@vger.kernel.org, Daejun Park <daejun7.park@samsung.com>,
	Christoph Hellwig <hch@lst.de>
Subject: Re: [PATCH v2 1/2] pnfs/blocklayout: don't mark extents committed
 after a failed LAYOUTCOMMIT
Message-ID: <20261028161819.GA21989@lst.de>
References: <cover.1792157092.git.bcodding@hammerspace.com> <8b5b2e8ecc7e1150c9b4505d1094da893db2e1a6.1792157092.git.bcodding@hammerspace.com>
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
In-Reply-To: <8b5b2e8ecc7e1150c9b4505d1094da893db2e1a6.1792157092.git.bcodding@hammerspace.com>
User-Agent: Mutt/1.5.17 (2007-11-01)

Looks good:

Reviewed-by: Christoph Hellwig <hch@lst.de>

