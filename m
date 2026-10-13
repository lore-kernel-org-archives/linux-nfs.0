Received: from verein.lst.de (verein.lst.de [213.95.11.211])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 8757F3F23D0;
	Tue, 13 Oct 2026 14:38:53 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=213.95.11.211
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1791902334; cv=none; b=Yt55BArtW5J8nJr1EHBGMRUsGig967rNf+Dh2jHMms/CohigRoErCUdcHfGrH4PPkTiSaMGtWT5grdc8BS9jnzkB39c5lDJ60Xr+eyIk1RhfqWZ/D0ugxxio0d0XMZ4nmvWLsbx895BmXy+j5333VNYiXofpRwpI7h8Awq8XhZM=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1791902334; c=relaxed/simple;
	bh=M7NmYC/Iylm9myghHwqILim55SAUt9QrM+UZYk0eJlw=;
	h=Date:From:To:Cc:Subject:Message-ID:References:MIME-Version:
	 Content-Type:Content-Disposition:In-Reply-To; b=V4s+GBsSPgdfSOAiMK/IeOt0cYtuOWOzzE+mOMDHx7RUevo22Fbl8p5fRyPSCROW2Q6To5INZDbxx7WRqSiBTHD00Pdst4ex8r1bCPKvw2HA8K2wOkZzcKH8mxeDiAYhjEhPz82tVhOuMf0YhYS+tURxe2rsgsaqcs3Js4jqN/g=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dmarc=pass (p=none dis=none) header.from=lst.de; spf=pass smtp.mailfrom=lst.de; arc=none smtp.client-ip=213.95.11.211
Authentication-Results: smtp.subspace.kernel.org; dmarc=pass (p=none dis=none) header.from=lst.de
Authentication-Results: smtp.subspace.kernel.org; spf=pass smtp.mailfrom=lst.de
Received: by verein.lst.de (Postfix, from userid 2407)
	id 3766D227A8E; Tue, 13 Oct 2026 16:38:50 +0200 (CEST)
Date: Tue, 13 Oct 2026 16:38:49 +0200
From: "hch@lst.de" <hch@lst.de>
To: Daejun Park <daejun7.park@samsung.com>
Cc: "hch@lst.de" <hch@lst.de>, "sagi@grimberg.me" <sagi@grimberg.me>,
	"kch@nvidia.com" <kch@nvidia.com>,
	"kbusch@kernel.org" <kbusch@kernel.org>,
	"kanie@linux.alibaba.com" <kanie@linux.alibaba.com>,
	"linux-nvme@lists.infradead.org" <linux-nvme@lists.infradead.org>,
	"linux-nfs@vger.kernel.org" <linux-nfs@vger.kernel.org>,
	"linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>
Subject: Re: [PATCH 2/2] nvmet: fix preempt of another registrant by the
 reservation holder
Message-ID: <20261013143849.GB15964@lst.de>
References: <20261002070200epcms2p593a0aa8ac482e776e8f1de89d9f212ae@epcms2p5> <20261002065931epcms2p1cb2c16f98cf3b05f8c859ad92b0ad465@epcms2p1> <CGME20261002065931epcms2p1cb2c16f98cf3b05f8c859ad92b0ad465@epcms2p4> <20261002070341epcms2p4e1409e8fcea145562a2996ad1d1d24ea@epcms2p4>
Precedence: bulk
X-Mailing-List: linux-nfs@vger.kernel.org
List-Id: <linux-nfs.vger.kernel.org>
List-Subscribe: <mailto:linux-nfs+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:linux-nfs+unsubscribe@vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20261002070341epcms2p4e1409e8fcea145562a2996ad1d1d24ea@epcms2p4>
User-Agent: Mutt/1.5.17 (2007-11-01)

Looks good:

Reviewed-by: Christoph Hellwig <hch@lst.de>
