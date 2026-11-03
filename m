Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.remote-ip=213.95.11.211
ARC-Seal: i=1; d=subspace.kernel.org; s=arc20261015; a=rsa-sha256; cv=none;
	t=1793692242;
	b=rB++i/hZTJtQW6KdxmRBpDGI+VMgnnBbr3sfI3FVrviuKEjsXrXbJngAOtTU+Ca4bap4
	 Jd7Z1iM8mnV0ks0d8xcaaiLHF5SQUShsvS88b7myXycSl6H6ehyZT8BFWbCdoXxtUvQVb
	 qZ0Ulb1o3hprsj3+lS8OtARfVSpq5i+56Xec9OYR32NeN0/a+yyDwU466wM1nK3XRtiXH
	 zIqp11S9hVntpjv9T9mJ2V7JICGbRQByHYrdaP4tTRjMyAC3i7QFMkSGMRSCsLX6W+Vq/
	 XmgE0ZMzF6kS0gXDzo2BOgOeSQpOQ5Gowa3we2Ak1dzIo50cs2Q4tGkDyyIehcjj0Gw==
ARC-Message-Signature: i=1; d=subspace.kernel.org; s=arc20261015;
	a=rsa-sha256; c=relaxed/relaxed; t=1793692242;
	h=DMARC-Filter:Received:Date:From:To:Cc:Subject:Message-ID:References:
	 MIME-Version:Content-Type:Content-Disposition:In-Reply-To:User-Agent;
	bh=M7NmYC/Iylm9myghHwqILim55SAUt9QrM+UZYk0eJlw=;
	b=Xe2CW51j7gQ05Fj5AsNRasob5/3gLzbCRLDV+5loD3qlYvXgO2Aws2xnhS0bAQ/uMM0O
	 mpxk21D2vRM8ZxfEjON+/RWrlFvbf3kJCCy8LxFj7hI/i2XFu4z459D39QDGgul6XdVF4
	 mte9ZAVjUin5CEHuKeD3mmebnJPgySrrYQ9Cg6grd5LAU1CipL5bOkbG/nc13vEnjLUVD
	 Mz0BaEON0xMErPp84hXO/bzp48T6PM+Lo7EidtX+B4xJEKO1+23YWsQ0h04JFdwAWuNiO
	 6QWFXBAdbdxbQdI8j/zAV4fR+qUveZpDPYDlxBMXGhojKQSr5hXUlNwr7fQLbX0954g==
ARC-Authentication-Results: i=1; smtp.subspace.kernel.org; 
	dmarc=pass header.from=lst.de;
	spf=pass smtp.mailfrom=lst.de;
	arc=none smtp.remote-ip=213.95.11.211
Received: from verein.lst.de (verein.lst.de [213.95.11.211])
	(using TLSv1.2 with cipher ECDHE-ECDSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id DCE6C606A324
	for <linux-nfs@vger.kernel.org>; Tue,  3 Nov 2026 07:50:41 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.4.2 smtp.subspace.kernel.org DCE6C606A324
Authentication-Results: smtp.subspace.kernel.org; dmarc=pass (p=none dis=none) header.from=lst.de
Authentication-Results: smtp.subspace.kernel.org; spf=pass smtp.mailfrom=lst.de
Received: by verein.lst.de (Postfix, from userid 2407)
	id 2787668BEB; Tue,  3 Nov 2026 08:50:38 +0100 (CET)
Date: Tue, 3 Nov 2026 08:50:37 +0100
From: Christoph Hellwig <hch@lst.de>
To: daejun7.park@samsung.com
Cc: Trond Myklebust <trondmy@kernel.org>, Anna Schumaker <anna@kernel.org>,
	Christoph Hellwig <hch@lst.de>,
	Benjamin Coddington <ben.coddington@hammerspace.com>,
	linux-nfs@vger.kernel.org
Subject: Re: [PATCH] pnfs/blocklayout: don't let a READ layout hide written
 extents
Message-ID: <20261103075037.GA3822@lst.de>
References: <20261030-nfs-bl-ro-v1-1-2a0957b016c3@samsung.com>
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
In-Reply-To: <20261030-nfs-bl-ro-v1-1-2a0957b016c3@samsung.com>
User-Agent: Mutt/1.5.17 (2007-11-01)

Looks good:

Reviewed-by: Christoph Hellwig <hch@lst.de>

