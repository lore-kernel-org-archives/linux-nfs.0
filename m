Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.remote-ip=213.95.11.211
ARC-Seal: i=1; d=subspace.kernel.org; s=arc20261015; a=rsa-sha256; cv=none;
	t=1794409540;
	b=AbrI1/sgpjQie8/cFefXRqp6bsiO/yF1BJS4B7c/xQZBcPdJQleeuiHjO0jCkCLdnRbo
	 BXXfuu/LhDDJyrZjLyzPQGi5h/MyfDarVTLc8IvsnR7pGuhTsS2bOiR+yE8BlIBOpld0D
	 BYoygJFRU2IwpVXtRvKVzcL1axOV7K/dUEjoUnMEtTPpS0kNCQmrT8jDeI7lBGoJQhuse
	 Z8dDs7maoTSb6I7ZwiKLeu8ZR38Xlo75LHKq+OJvbuKd9FgaWxjoIFI+S2AU1LYKOZ9tM
	 v9Oc8zGM4ehpbTfYFfubRWj5Fx+wL/4H85i4YeFLEyiHFGFI0MPUoQKORDHJq0Dx8gQ==
ARC-Message-Signature: i=1; d=subspace.kernel.org; s=arc20261015;
	a=rsa-sha256; c=relaxed/relaxed; t=1794409540;
	h=DMARC-Filter:Received:Date:From:To:Cc:Subject:Message-ID:References:
	 MIME-Version:Content-Type:Content-Disposition:In-Reply-To:User-Agent;
	bh=3eXaujzWsI4QrtOtWgTNBZbBC275dnsr/pB67SZEqiA=;
	b=X4NfyOD6+QRr4Za4nMlFVrIeif5qFURHhbx546siOF4BEjlqp3sthyXWGO8ZnlSN2XjF
	 qCgGSwSECFCeV1lpE2qdqLSXgX/BAop3+PTiS8QYyJVthf40Yx3TpJ/sB84EIzznPvmJI
	 j3A+Vqct2NEZWXCsq2xh3m6xfoEiGcaGj+5H2+3VNqBMG5LhJ9slMVxAHQRh1WURFvBZs
	 B+vQmWfcvgtmhIpsVR28z7kV/XX7lsWGWdD1MwXGigbedN9k+S12Kz1Rx3osXH7ft3wZp
	 RjR24zhI37RThpvyfQ6vPI1P5RtX+ewjPwnai6RtusjMMrW8pjpJHxenD0YJOaklSUA==
ARC-Authentication-Results: i=1; smtp.subspace.kernel.org; 
	dmarc=pass header.from=lst.de;
	spf=pass smtp.mailfrom=lst.de;
	arc=none smtp.remote-ip=213.95.11.211
Received: from verein.lst.de (verein.lst.de [213.95.11.211])
	(using TLSv1.2 with cipher ECDHE-ECDSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 50E6B606A33F;
	Wed, 11 Nov 2026 15:05:40 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.4.2 smtp.subspace.kernel.org 50E6B606A33F
Authentication-Results: smtp.subspace.kernel.org; dmarc=pass (p=none dis=none) header.from=lst.de
Authentication-Results: smtp.subspace.kernel.org; spf=pass smtp.mailfrom=lst.de
Received: by verein.lst.de (Postfix, from userid 2407)
	id D9F2668D0D; Wed, 11 Nov 2026 16:05:36 +0100 (CET)
Date: Wed, 11 Nov 2026 16:05:36 +0100
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
Subject: Re: [PATCH RFC 10/41] nullfs: use fc_init_pseudo()
Message-ID: <20261111150536.GF10644@lst.de>
References: <20261110-work-loop-pseudo-v1-0-4c998976c6c7@kernel.org> <20261110-work-loop-pseudo-v1-10-4c998976c6c7@kernel.org>
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
In-Reply-To: <20261110-work-loop-pseudo-v1-10-4c998976c6c7@kernel.org>
User-Agent: Mutt/1.5.17 (2007-11-01)

Looks good:

Reviewed-by: Christoph Hellwig <hch@lst.de>

>  #include <linux/uio.h>
