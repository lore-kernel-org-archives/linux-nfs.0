Received: from mx1.manguebit.org (mx1.manguebit.org [143.255.12.172])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id F14CD26AC3;
	Sat, 28 Mar 2026 18:36:31 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=143.255.12.172
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1774722993; cv=none; b=SRw1Hgp3gznyr5GAdqBDY4MT5DzHjiHemgMMz51YjtEaraUYqDPy89xpJPNtDPjjONv3TUYcQay6K6BMXwrLa/8gsfmLuiNWvguz7/nxuG/MqclejRRRWLhRD79Y1IZMjoipV8tEIrt1gG2FvvhmVP0tUE1aptOuQN7FRcjpQg0=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1774722993; c=relaxed/simple;
	bh=WoRFq7WH6yWt0HlAkR8LB5xu8HJctOmMzLs2QF1iPsQ=;
	h=Message-ID:From:To:Cc:Subject:In-Reply-To:References:Date:
	 MIME-Version:Content-Type; b=IcpTakOgTz6bw7OM+AdQmLi1Nhiz63o+F475K+QUudnW9ryPOGggrZRulx8J8xiTn1Q8Z27W/cys3ujA/++zIZ/9FAk6Z116ydpK1RCGx/BzhffQ6tJUUQ4am5VsVdyR5Ugaq/tU5W7epJvdXLn6GvxK27wnoJKbw708Q1iaYt0=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dmarc=pass (p=quarantine dis=none) header.from=manguebit.org; spf=pass smtp.mailfrom=manguebit.org; dkim=pass (2048-bit key) header.d=manguebit.org header.i=@manguebit.org header.b=l/xJtaqQ; arc=none smtp.client-ip=143.255.12.172
Authentication-Results: smtp.subspace.kernel.org; dmarc=pass (p=quarantine dis=none) header.from=manguebit.org
Authentication-Results: smtp.subspace.kernel.org; spf=pass smtp.mailfrom=manguebit.org
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=manguebit.org header.i=@manguebit.org header.b="l/xJtaqQ"
DKIM-Signature: v=1; a=rsa-sha256; q=dns/txt; c=relaxed/relaxed;
	d=manguebit.org; s=dkim; h=Content-Type:MIME-Version:Date:References:
	In-Reply-To:Subject:Cc:To:From:Message-ID:Sender:Reply-To:
	Content-Transfer-Encoding:Content-ID:Content-Description;
	bh=2G5EjnsDra2FRBDfpoHL88rw7wDpJJ6XyDPUAlNk2CE=; b=l/xJtaqQbIOEJk9zlI9x/R+HbG
	L3R5sAwTtHIxcRDqGQ/yRYtEadhEfcAjWRqZaSAkqrg5zakHzc+vhUyBV0Jsj+1zTGC4tqfKAWA7M
	Wo6es5dWLIMPpy6h76cu5buH4eOZavh8FiAkBQ6PFw8X/KsusWS5ujfeX8qOS1SNeFnzdeRyJTSKg
	zWLYh5AsjWaO+d4ynavPbCAidz0ioWER1Z+rwWyGvBgxCXD0UMShGguznBykol887FSTaTtPTcut8
	cO3L8CVZPJgZ7sLRxl6Q2/ts+kmHtPc4e4fiJYBKjnK360N/gJolVTh3J90rd7PpgFPZdHOtMtWJD
	DtIEPVPg==;
Received: from pc by mx1.manguebit.org with local (Exim 4.99.1)
	id 1w6YWL-00000001nom-3cop;
	Sat, 28 Mar 2026 15:36:29 -0300
Message-ID: <9faf4ad6b806a377678a03917edc580b@manguebit.org>
From: Paulo Alcantara <pc@manguebit.org>
To: David Howells <dhowells@redhat.com>, Christian Brauner
 <christian@brauner.io>, Matthew Wilcox <willy@infradead.org>, Christoph
 Hellwig <hch@infradead.org>
Cc: David Howells <dhowells@redhat.com>, Jens Axboe <axboe@kernel.dk>, Leon
 Romanovsky <leon@kernel.org>, Steve French <sfrench@samba.org>,
 ChenXiaoSong <chenxiaosong@chenxiaosong.com>, Marc Dionne
 <marc.dionne@auristor.com>, Eric Van Hensbergen <ericvh@kernel.org>,
 Dominique Martinet <asmadeus@codewreck.org>, Ilya Dryomov
 <idryomov@gmail.com>, Trond Myklebust <trondmy@kernel.org>,
 netfs@lists.linux.dev, linux-afs@lists.infradead.org,
 linux-cifs@vger.kernel.org, linux-nfs@vger.kernel.org,
 ceph-devel@vger.kernel.org, v9fs@lists.linux.dev,
 linux-erofs@lists.ozlabs.org, linux-fsdevel@vger.kernel.org,
 linux-kernel@vger.kernel.org, linux-mm@kvack.org
Subject: Re: [PATCH 10/26] netfs: Bulk load the readahead-provided folios up
 front
In-Reply-To: <20260326104544.509518-11-dhowells@redhat.com>
References: <20260326104544.509518-1-dhowells@redhat.com>
 <20260326104544.509518-11-dhowells@redhat.com>
Date: Sat, 28 Mar 2026 15:36:29 -0300
Precedence: bulk
X-Mailing-List: linux-nfs@vger.kernel.org
List-Id: <linux-nfs.vger.kernel.org>
List-Subscribe: <mailto:linux-nfs+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:linux-nfs+unsubscribe@vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain

David Howells <dhowells@redhat.com> writes:

> Load all the folios by the VM for readahead up front into the folio queue.
> With the number of folios provided by the VM, the folio queue can be fully
> allocated first and then the loading happen in one go inside the RCU read
> lock.  The folio refs acquired from readahead are dropped in bulk once the
> first subrequest is dispatched as it's quite a slow operation.
>
> This simplifies the buffer handling later and isn't noticeably slower as
> the xarray doesn't need to be modified and the folios are all already
> pre-locked.
>
> Signed-off-by: David Howells <dhowells@redhat.com>
> cc: Paulo Alcantara <pc@manguebit.org>
> cc: Matthew Wilcox <willy@infradead.org>
> cc: netfs@lists.linux.dev
> cc: linux-mm@kvack.org
> cc: linux-fsdevel@vger.kernel.org
> ---
>  fs/netfs/buffered_read.c       | 95 +++++++++++++++++++++-------------
>  fs/netfs/rolling_buffer.c      | 75 +++++++++++++++++++++++++++
>  include/linux/netfs.h          |  1 +
>  include/linux/rolling_buffer.h |  3 ++
>  include/trace/events/netfs.h   |  1 +
>  5 files changed, 138 insertions(+), 37 deletions(-)

Reviewed-by: Paulo Alcantara (Red Hat) <pc@manguebit.org>
