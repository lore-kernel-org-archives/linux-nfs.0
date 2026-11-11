Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.remote-ip=213.95.11.211
ARC-Seal: i=1; d=subspace.kernel.org; s=arc20261015; a=rsa-sha256; cv=none;
	t=1794409494;
	b=3fdyQ1aKi1VzxC9lG3PEq7TAT1IMr2WfgDesFBrTuxN7P+ezFXa7t9EpSGMyQAGGpCE3
	 iDHEZGkmT4orPVnZpyIrlUePrvXC9EzPYB8NITI12pjYCIlKIzOrw/T/fbllW7omgjtjO
	 N3Rr8Rvhj1PGbFvdD2pt7OMBHXsfuFPj0KxyNu6s2DUxBShWAlYWvoSFe0GfvUk5/pFyM
	 CyMsKSc/1s2UbVN6OzlfqycVAhffkiCd8pqLcUhfZ8VxunQ9sKOL/Aly4pjF0clsr2tMh
	 UT7KPkxc+8KEftmw9lNlvs1P/tHykg5UfA9CvHij7V4fGAM2375ZJI/hsh2raA+pu3Q==
ARC-Message-Signature: i=1; d=subspace.kernel.org; s=arc20261015;
	a=rsa-sha256; c=relaxed/relaxed; t=1794409494;
	h=DMARC-Filter:Received:Date:From:To:Cc:Subject:Message-ID:References:
	 MIME-Version:Content-Type:Content-Disposition:In-Reply-To:User-Agent;
	bh=M7NmYC/Iylm9myghHwqILim55SAUt9QrM+UZYk0eJlw=;
	b=x3NuN+SIYoOn6lcB1KUe/rxnncejffdTskvlFf6LC3RuC7RAbD1hQM6edqsR+5FUU+bI
	 U4SsqXvIJD97FdzPkHgBG2+gBwJh5M7bORLXY+YphPmFuInAwI0Gxv2wQRvLiZSXVABRg
	 h2s9dilil1MqCMCw0J6dAngHxhGkXd++gKK/SPPxi/HSCbFP2d3hYodqmG48dFPPWzPqs
	 ixtTfLbiP0U8E+Cf+eip3BggHW1FoQWRGkWD0yf8aAuPKG48isgs55LaCqXAvf8IAKzRa
	 7EdU5GiEgWZ8gDWM0sU3E7w/tK0C7MTC5XO8C8Rj8tEWBF4AJvgY4r0ugoFNtWjgraw==
ARC-Authentication-Results: i=1; smtp.subspace.kernel.org; 
	dmarc=pass header.from=lst.de;
	spf=pass smtp.mailfrom=lst.de;
	arc=none smtp.remote-ip=213.95.11.211
Received: from verein.lst.de (verein.lst.de [213.95.11.211])
	(using TLSv1.2 with cipher ECDHE-ECDSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 649C160A2606;
	Wed, 11 Nov 2026 15:04:54 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.4.2 smtp.subspace.kernel.org 649C160A2606
Authentication-Results: smtp.subspace.kernel.org; dmarc=pass (p=none dis=none) header.from=lst.de
Authentication-Results: smtp.subspace.kernel.org; spf=pass smtp.mailfrom=lst.de
Received: by verein.lst.de (Postfix, from userid 2407)
	id A445568D12; Wed, 11 Nov 2026 16:04:50 +0100 (CET)
Date: Wed, 11 Nov 2026 16:04:49 +0100
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
Subject: Re: [PATCH RFC 06/41] proc: use fc_init_pseudo()
Message-ID: <20261111150449.GC10644@lst.de>
References: <20261110-work-loop-pseudo-v1-0-4c998976c6c7@kernel.org> <20261110-work-loop-pseudo-v1-6-4c998976c6c7@kernel.org>
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
In-Reply-To: <20261110-work-loop-pseudo-v1-6-4c998976c6c7@kernel.org>
User-Agent: Mutt/1.5.17 (2007-11-01)

Looks good:

Reviewed-by: Christoph Hellwig <hch@lst.de>

