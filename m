Received: from mx1.manguebit.org (mx1.manguebit.org [143.255.12.172])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id A55201F872D;
	Sat, 28 Mar 2026 18:25:39 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=143.255.12.172
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1774722341; cv=none; b=E/Pilp20HGd8wohYEQ1VRX4lngSNz7QkwVFWdFrNcA0w93zw45Cuv85mYIkzUgTfcnjdHJLybYP4wUJqRAtNb8Pp0RxRvXv3KNMnyj4fkobbpTgJuNJeiwVpfmJs3w+3BLMl7rkjJ1dDkPz0mS1LPdvuKIUK7wQvOor++FNzulw=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1774722341; c=relaxed/simple;
	bh=0UEGef5iLo//4VE1xibw19GkofM9EQr+QR7Zasq5KqQ=;
	h=Message-ID:From:To:Cc:Subject:In-Reply-To:References:Date:
	 MIME-Version:Content-Type; b=b6T1cRdOUpi/p0TEUNTMIfB82xLWLUXRzxEVfp4PcQ0wJ1G5HRV3fhFf44YEdwZej8HwIZZEdrYgHsZjwhXoFUxpQPo0EwHosemwsjgA1bEOmw+jIBcogcoVLvKbPpsZvRAb7uqKPpw7UtHpmUZetqifGp2bsMzO+OXvE3W+D0o=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dmarc=fail (p=quarantine dis=none) header.from=manguebit.com; spf=pass smtp.mailfrom=manguebit.org; dkim=pass (2048-bit key) header.d=manguebit.org header.i=@manguebit.org header.b=rTHrKogG; arc=none smtp.client-ip=143.255.12.172
Authentication-Results: smtp.subspace.kernel.org; dmarc=fail (p=quarantine dis=none) header.from=manguebit.com
Authentication-Results: smtp.subspace.kernel.org; spf=pass smtp.mailfrom=manguebit.org
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=manguebit.org header.i=@manguebit.org header.b="rTHrKogG"
DKIM-Signature: v=1; a=rsa-sha256; q=dns/txt; c=relaxed/relaxed;
	d=manguebit.org; s=dkim; h=Sender:Content-Type:MIME-Version:Date:References:
	In-Reply-To:Subject:Cc:To:From:Message-ID:Reply-To:Content-Transfer-Encoding:
	Content-ID:Content-Description;
	bh=vtvToygHD/XhQ/RgwXcfB1cu6LKJlBXHH2QlzqxoAkc=; b=rTHrKogGPS9SS4H5Xyzci5KbyJ
	XKCEjVCCUGW0MPjqZyKrvkvKJxf0WNl3E46gZ2GJLqoBxj9PZI5sg46wECKkS6vmMz3pg3uWz/iST
	d2AciCtqNPlAP3ARviB3hcA/WCr+iB1dl5GORx18D4DiXUBx2VslCgq3L5g2yQjs430mdesNStHxc
	l/i6xO/XxwNK1pBiWFgd3JEIQOqeTW/5iYWGNXyWaaUlKQ08SunfIbk7xXfm/gUUDS6JoRV8uRT6E
	KYWg4hW9AKFWaanekAYiM56fYDhBikopDjrQUVm6Et5i9/uyg8ClhrcpddsRsrWeVqLS8Nm+qgNl9
	X0nQJvTQ==;
Received: from pc by mx1.manguebit.org with local (Exim 4.99.1)
	id 1w6YLp-00000001nin-3OQp;
	Sat, 28 Mar 2026 15:25:37 -0300
Message-ID: <f73f5322e1e964404deefe64cc3e33db@manguebit.com>
From: Paulo Alcantara <pc@manguebit.com>
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
 linux-kernel@vger.kernel.org
Subject: Re: [PATCH 06/26] netfs: Fix the handling of stream->front by
 removing it
In-Reply-To: <20260326104544.509518-7-dhowells@redhat.com>
References: <20260326104544.509518-1-dhowells@redhat.com>
 <20260326104544.509518-7-dhowells@redhat.com>
Date: Sat, 28 Mar 2026 15:25:37 -0300
Precedence: bulk
X-Mailing-List: linux-nfs@vger.kernel.org
List-Id: <linux-nfs.vger.kernel.org>
List-Subscribe: <mailto:linux-nfs+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:linux-nfs+unsubscribe@vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain
Sender: pc@manguebit.org

David Howells <dhowells@redhat.com> writes:

> The netfs_io_stream::front member is meant to point to the subrequest
> currently being collected on a stream, but it isn't actually used this way
> by direct write (which mostly ignores it).  However, there's a tracepoint
> which looks at it.  Further, stream->front is actually redundant with
> stream->subrequests.next.
>
> Fix the potential problem in the direct code by just removing the member
> and using stream->subrequests.next instead, thereby also simplifying the
> code.
>
> Fixes: a0b4c7a49137 ("netfs: Fix unbuffered/DIO writes to dispatch subrequests in strict sequence")
> Reported-by: Paulo Alcantara <pc@manguebit.org>
> Signed-off-by: David Howells <dhowells@redhat.com>
> cc: netfs@lists.linux.dev
> cc: linux-fsdevel@vger.kernel.org
> ---
>  fs/netfs/buffered_read.c     | 3 +--
>  fs/netfs/direct_read.c       | 3 +--
>  fs/netfs/direct_write.c      | 1 -
>  fs/netfs/read_collect.c      | 4 ++--
>  fs/netfs/read_single.c       | 1 -
>  fs/netfs/write_collect.c     | 4 ++--
>  fs/netfs/write_issue.c       | 3 +--
>  include/linux/netfs.h        | 1 -
>  include/trace/events/netfs.h | 8 ++++----
>  9 files changed, 11 insertions(+), 17 deletions(-)

Reviewed-by: Paulo Alcantara (Red Hat) <pc@manguebit.org>
