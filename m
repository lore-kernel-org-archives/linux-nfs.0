Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.remote-ip=213.95.11.211
ARC-Seal: i=1; d=subspace.kernel.org; s=arc20261015; a=rsa-sha256; cv=none;
	t=1794409482;
	b=JNTgig+JfygPcr/AhBosCANXLu51Wg2rgPoazRmZRo6zokgpoStrTFrWE84gRu49K/lP
	 OoNFFT04uZkI0EKK/BJg+sxchO5MHsvoSApNd/r/KOVaURxlSItjyDYhRDMGQSjZXMlSG
	 n6XL9LwSdpitsSglbyxJieAMF/tctybgO/Cqc/7E32Xm/BU3JrDi9vKbVQwFyNLm3vUgh
	 gZa4wwM5dMxTmJ+zdhn6ibmOJjEHbjnQxaEF7xHeTgr4HcrBP37ZkNKIsmQLy35mW0Va4
	 1QS3IzhN78SDIBDF/2LXO007xlhiOqwtIYDuVnak7AyEE1c0sp3+8Ps5zVNVCas/Cfw==
ARC-Message-Signature: i=1; d=subspace.kernel.org; s=arc20261015;
	a=rsa-sha256; c=relaxed/relaxed; t=1794409482;
	h=DMARC-Filter:Received:Date:From:To:Cc:Subject:Message-ID:References:
	 MIME-Version:Content-Type:Content-Disposition:In-Reply-To:User-Agent;
	bh=M7NmYC/Iylm9myghHwqILim55SAUt9QrM+UZYk0eJlw=;
	b=2kJswL4u+LSWFmHcWLHv8GBCrNzgWIaLHXnkq22DWSJdSo2yAheZwKXv1mGQzOGcWuNC
	 moAw5ZCalVXQ0w4fXhGF3DH2idlweuQ7RxwO9NWo3yt9k7ODXGHIl6gCvJu2MraUceTz4
	 zHTcgU4EL+1lN062c/PuNhInw0ukrV9usczV+MFm0M74+U7mMU1ZXqulOLEYeu9YqUMKP
	 EFBSxaxoChKiduW6PjLXlAXE/iIGxtHB56mX0NZwjBY/VyY48zYf6OTMhCg+WE27wPkim
	 Max7MY+Fg+SRR6OmsI4TH+XaRMV8BayCtZxMbWgmuejGltGunXA+/R74Hw8cMzaSCeg==
ARC-Authentication-Results: i=1; smtp.subspace.kernel.org; 
	dmarc=pass header.from=lst.de;
	spf=pass smtp.mailfrom=lst.de;
	arc=none smtp.remote-ip=213.95.11.211
Received: from verein.lst.de (verein.lst.de [213.95.11.211])
	(using TLSv1.2 with cipher ECDHE-ECDSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id AC6CF606A336;
	Wed, 11 Nov 2026 15:04:41 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.4.2 smtp.subspace.kernel.org AC6CF606A336
Authentication-Results: smtp.subspace.kernel.org; dmarc=pass (p=none dis=none) header.from=lst.de
Authentication-Results: smtp.subspace.kernel.org; spf=pass smtp.mailfrom=lst.de
Received: by verein.lst.de (Postfix, from userid 2407)
	id 269A268D0F; Wed, 11 Nov 2026 16:04:37 +0100 (CET)
Date: Wed, 11 Nov 2026 16:04:36 +0100
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
Subject: Re: [PATCH RFC 05/41] kernfs: use fc_init_pseudo()
Message-ID: <20261111150436.GB10644@lst.de>
References: <20261110-work-loop-pseudo-v1-0-4c998976c6c7@kernel.org> <20261110-work-loop-pseudo-v1-5-4c998976c6c7@kernel.org>
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
In-Reply-To: <20261110-work-loop-pseudo-v1-5-4c998976c6c7@kernel.org>
User-Agent: Mutt/1.5.17 (2007-11-01)

Looks good:

Reviewed-by: Christoph Hellwig <hch@lst.de>

