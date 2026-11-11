Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.remote-ip=213.95.11.211
ARC-Seal: i=1; d=subspace.kernel.org; s=arc20261015; a=rsa-sha256; cv=none;
	t=1794409012;
	b=lBIJqOfVroz66XqZMACwnq77wFnnibNZ9d6xCCqANCKLR8L+z+uR/cIKCcnEhiTiyTRC
	 iol0jq1B3h6zZ9BAswMEr0+Gi/YpG+rDVLnRDitVv8pUV/DFJkM+2zSgLxywBDLSXoURJ
	 HkRbhy90QMaf1Nxl6Wo7MpYFnTORH6PoRi1aC7sKFMY6MEhUYdQcDOxa7m+gmqi6Hg0Ew
	 ptpuD9uQdyL4hl/H+zeQxt+PoIKYujw23qB/mAHpNt8TP0RltncoYCZ/bXmMN0MyqeRcn
	 Pf3PizwXQkjjkM6VHPzd0XlDmS/hgS3efl+4VgsPx3rkBHAAJXiaHRtmviJtKQwMJDA==
ARC-Message-Signature: i=1; d=subspace.kernel.org; s=arc20261015;
	a=rsa-sha256; c=relaxed/relaxed; t=1794409012;
	h=DMARC-Filter:Received:Date:From:To:Cc:Subject:Message-ID:References:
	 MIME-Version:Content-Type:Content-Disposition:In-Reply-To:User-Agent;
	bh=uTScRtTvc50Ly2VnPZ+IRL7zVmHRGtRnjIEMUslXOU4=;
	b=Qobh15CJ3JpoTdqtIsJPaZ4wbdspYIDAKZ8haFc3oVC5+YRq8uyZXzAw7VqpXVYavruy
	 BZvIuh31v+f5Xm69m9HpVd6exHSKnu5D7WixXZS7CYYjd9MGVYxRTgyV28vghBPGWvjX2
	 8axfaQRopt9gI24sSklTdzPNqedWv3dV3uU+7+Lyk9cKh50z2KgzSLoz6zj0LwhMWcbzG
	 v01GEbalvED5ZoYPi3+OyJq6qwblxWqKxR6weT9IYbMeulfkLaBNKH7A34rIJCaMiFfFr
	 ZrXjxjMlOI719XN0ejuOimrm2yCAnSLtFkqufP++Fd2ZGpVH6b3SlI3pqN+bGkjwX5Q==
ARC-Authentication-Results: i=1; smtp.subspace.kernel.org; 
	dmarc=pass header.from=lst.de;
	spf=pass smtp.mailfrom=lst.de;
	arc=none smtp.remote-ip=213.95.11.211
Received: from verein.lst.de (verein.lst.de [213.95.11.211])
	(using TLSv1.2 with cipher ECDHE-ECDSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 824FE606A331;
	Wed, 11 Nov 2026 14:56:51 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.4.2 smtp.subspace.kernel.org 824FE606A331
Authentication-Results: smtp.subspace.kernel.org; dmarc=pass (p=none dis=none) header.from=lst.de
Authentication-Results: smtp.subspace.kernel.org; spf=pass smtp.mailfrom=lst.de
Received: by verein.lst.de (Postfix, from userid 2407)
	id BF2AF68D09; Wed, 11 Nov 2026 15:56:47 +0100 (CET)
Date: Wed, 11 Nov 2026 15:56:47 +0100
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
Subject: Re: [PATCH RFC 03/41] target: fileio: check that the backing file
 supports ->{read,write}_iter
Message-ID: <20261111145647.GC9996@lst.de>
References: <20261110-work-loop-pseudo-v1-0-4c998976c6c7@kernel.org> <20261110-work-loop-pseudo-v1-3-4c998976c6c7@kernel.org>
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
In-Reply-To: <20261110-work-loop-pseudo-v1-3-4c998976c6c7@kernel.org>
User-Agent: Mutt/1.5.17 (2007-11-01)

On Tue, Nov 10, 2026 at 10:14:19AM +0100, Christian Brauner wrote:
> With fd_async_io=1 the fileio backend calls ->read_iter() and
> ->write_iter() of the backing file directly. The synchronous path goes
> through vfs_iter_read() and vfs_iter_write() which check for them but
> the aio path doesn't. So a backing file without them calls a NULL
> pointer on its first I/O.
> 
> Refuse such files when configuring the device. On the synchronous path
> every read or write that needed the missing method failed with EINVAL
> anyway.

Looks good:

Reviewed-by: Christoph Hellwig <hch@lst.de>

