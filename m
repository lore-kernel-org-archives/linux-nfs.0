Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.remote-ip=213.95.11.211
ARC-Seal: i=1; d=subspace.kernel.org; s=arc20261015; a=rsa-sha256; cv=none;
	t=1794409468;
	b=uV6IaHeur+XV8s41e4abmU3xpiJDAnJO1Q3UEiR77JlQRLXgVWlhqE1fWFqaHLZE/S4Y
	 HBOomD9N6+1/kzYH8cj1LXqhdPgy/nOlApjrtOUE1Hd+IdSvmvARSL0N8ktCW2yhQYjs/
	 U3vT9chpY907vKq7wqJGgSjjvm4Ka4tUA1NflJpY4ioMgVmT/lj69U3Eonr1cErbTW9Xz
	 TOy/xD4Q0Cj4I13hIk5F6PVlhRf+4UvvhG8tNzHvlv8ISI9Ac73Ik4QHhAgu/nL0gsCGk
	 5+FVzc7SvNHK8hvPXaiZ5Usq9A4MQ0YSkqF/i/eRypBUaFV66re/ORNzPf/+liJFLsw==
ARC-Message-Signature: i=1; d=subspace.kernel.org; s=arc20261015;
	a=rsa-sha256; c=relaxed/relaxed; t=1794409468;
	h=DMARC-Filter:Received:Date:From:To:Cc:Subject:Message-ID:References:
	 MIME-Version:Content-Type:Content-Disposition:In-Reply-To:User-Agent;
	bh=M7NmYC/Iylm9myghHwqILim55SAUt9QrM+UZYk0eJlw=;
	b=uwmwluH+XglHcST8XlEdABuodfKjhsfuYf1tFKPh9HyH4JlGnlyj+ADjtU+alkUYrNuM
	 h8Hd97hJf/vB1Bucfpy5EuliO/w+ezvau9AgjSB/ChMihuj22VC6IPAqrpXfQLyQtl8k9
	 GQ0aknav3DqtVHk95yWA5jw/oght6CHa9viaKUSzAfVZFFBo7k7V7R0HMdNKIMjowoopQ
	 j2xr5naxQaSHdzoVdfXijtioPwI7Ys7PXJam9QjX4aO7VuEbcJJno3WGqqf60w8o+E1wd
	 POAHD2Uv96SDkuPnkdRig/E6jvyWqW1nP47hcCYxTEzGZjg4BOLjqt4B9/T29bi8uDg==
ARC-Authentication-Results: i=1; smtp.subspace.kernel.org; 
	dmarc=pass header.from=lst.de;
	spf=pass smtp.mailfrom=lst.de;
	arc=none smtp.remote-ip=213.95.11.211
Received: from verein.lst.de (verein.lst.de [213.95.11.211])
	(using TLSv1.2 with cipher ECDHE-ECDSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 9787D606A334;
	Wed, 11 Nov 2026 15:04:27 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.4.2 smtp.subspace.kernel.org 9787D606A334
Authentication-Results: smtp.subspace.kernel.org; dmarc=pass (p=none dis=none) header.from=lst.de
Authentication-Results: smtp.subspace.kernel.org; spf=pass smtp.mailfrom=lst.de
Received: by verein.lst.de (Postfix, from userid 2407)
	id 9B6F068D0A; Wed, 11 Nov 2026 16:04:20 +0100 (CET)
Date: Wed, 11 Nov 2026 16:04:19 +0100
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
Subject: Re: [PATCH RFC 04/41] fs: add SB_I_PSEUDO
Message-ID: <20261111150419.GA10644@lst.de>
References: <20261110-work-loop-pseudo-v1-0-4c998976c6c7@kernel.org> <20261110-work-loop-pseudo-v1-4-4c998976c6c7@kernel.org>
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
In-Reply-To: <20261110-work-loop-pseudo-v1-4-4c998976c6c7@kernel.org>
User-Agent: Mutt/1.5.17 (2007-11-01)

Looks good:

Reviewed-by: Christoph Hellwig <hch@lst.de>

