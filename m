Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.remote-ip=213.95.11.211
ARC-Seal: i=1; d=subspace.kernel.org; s=arc20261015; a=rsa-sha256; cv=none;
	t=1794408995;
	b=nb4Fj8/mpIcsCgH6THk63/hNibg6h+mY6xahwJw397nb1ctD7xjZ+HWNiJqbNry+l83i
	 VNastHeHnE23T89iw18jjnCQ5q2jvwXkDtqmk0hA1k4JhLGDCt+Ad6hi+jcsA2f3AgcA+
	 Neo0WYSdmsNsYFyFbRblgr38mxvryIrA6gqpgJ7XfTyJCFz3ccc1zJP3HCzpQGiehOKiU
	 BNgJONslvI2DBCCagHTM1jrEJVQnhlgsoWGpjrj8/tncLk7NjdOtozVwWDRxckabUMOMU
	 Nrd7QZtc60Hs5ffFBX6+LDcu0beV2eSnCiAZsanGoKFRlbBiJcKfqFAjI7TYp7Ttrew==
ARC-Message-Signature: i=1; d=subspace.kernel.org; s=arc20261015;
	a=rsa-sha256; c=relaxed/relaxed; t=1794408995;
	h=DMARC-Filter:Received:Date:From:To:Cc:Subject:Message-ID:References:
	 MIME-Version:Content-Type:Content-Disposition:In-Reply-To:User-Agent;
	bh=M7NmYC/Iylm9myghHwqILim55SAUt9QrM+UZYk0eJlw=;
	b=LaK6jybiNSlNXQej1mhBAxeQj82i0WRPfBBrqoj1kg3Wk0tLJYvKOk34T3hUfneeBGTW
	 SkqKpvrBR+yYcbXn6SacbvL8EU/nJd4IOo4NQoMvBqGBoopkCsD5Bp0RFGqTdHWRIExs1
	 idY5xlSnfjDY0vjCGoaZ2bkCtPrl+K2jJh2YloAUWGyaz2UMn3fknKHsjCsn604JdqWgU
	 nbPftWgN8MSmXE3j52IheIAm4DCrqU2qnIYKI56rR5gB9UGRkDmGx6Sxj/Qa4zlU1SQt5
	 VIG+TiAyS8pSYRotM5V+nvW7HNCmTJNeBi4MFvnw0RamdRhU49QR9VBwKCkJD+kqB7A==
ARC-Authentication-Results: i=1; smtp.subspace.kernel.org; 
	dmarc=pass header.from=lst.de;
	spf=pass smtp.mailfrom=lst.de;
	arc=none smtp.remote-ip=213.95.11.211
Received: from verein.lst.de (verein.lst.de [213.95.11.211])
	(using TLSv1.2 with cipher ECDHE-ECDSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id D85E9606A321;
	Wed, 11 Nov 2026 14:56:34 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.4.2 smtp.subspace.kernel.org D85E9606A321
Authentication-Results: smtp.subspace.kernel.org; dmarc=pass (p=none dis=none) header.from=lst.de
Authentication-Results: smtp.subspace.kernel.org; spf=pass smtp.mailfrom=lst.de
Received: by verein.lst.de (Postfix, from userid 2407)
	id 3FC4B68D05; Wed, 11 Nov 2026 15:56:31 +0100 (CET)
Date: Wed, 11 Nov 2026 15:56:30 +0100
From: Christoph Hellwig <hch@lst.de>
To: Christian Brauner <brauner@kernel.org>
Cc: linux-fsdevel@vger.kernel.org, Jann Horn <jannh@google.com>,
	Chris Mason <mason@kernel.org>, Josef Bacik <josef@toxicpanda.com>,
	Christoph Hellwig <hch@lst.de>, linux-block@vger.kernel.org,
	linux-kernel@vger.kernel.org, linux-nvme@lists.infradead.org,
	Alexander Viro <viro@zeniv.linux.org.uk>, Jan Kara <jack@suse.cz>,
	linux-scsi@vger.kernel.org, target-devel@vger.kernel.org,
	driver-core@lists.linux.dev, linux-mm@kvack.org,
	bpf@vger.kernel.org, linux-security-module@vger.kernel.org,
	selinux@vger.kernel.org, apparmor@lists.ubuntu.com,
	linux-nfs@vger.kernel.org, netdev@vger.kernel.org,
	fuse-devel@lists.linux.dev, linux-efi@vger.kernel.org,
	xen-devel@lists.xenproject.org, ocfs2-devel@lists.linux.dev,
	linux-s390@vger.kernel.org, linuxppc-dev@lists.ozlabs.org,
	linux-usb@vger.kernel.org, Amir Goldstein <amir73il@gmail.com>,
	linux-erofs@lists.ozlabs.org, linux-kselftest@vger.kernel.org
Subject: Re: [PATCH RFC 02/41] nvmet: check that the file backend supports
 ->{read,write}_iter
Message-ID: <20261111145630.GB9996@lst.de>
References: <20261110-work-loop-pseudo-v1-0-4c998976c6c7@kernel.org> <20261110-work-loop-pseudo-v1-2-4c998976c6c7@kernel.org>
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
In-Reply-To: <20261110-work-loop-pseudo-v1-2-4c998976c6c7@kernel.org>
User-Agent: Mutt/1.5.17 (2007-11-01)

Looks good:

Reviewed-by: Christoph Hellwig <hch@lst.de>

