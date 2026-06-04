Received: from us-smtp-delivery-124.mimecast.com (us-smtp-delivery-124.mimecast.com [170.10.129.124])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id B7488481228
	for <linux-nfs@vger.kernel.org>; Thu,  4 Jun 2026 14:27:17 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=170.10.129.124
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1780583238; cv=none; b=fM3RI1jhK8J1h/iWuMZGQ005ia0rlNR9UTR5nXePDpMtspJzj6RUgimFODuutK+DGsdUAKjuoD7rPkbHYIRqPTMtFcjGzSMDiaBNIuRh4TR6IROCaK3mbu7ZudW2zwNCj8CNypZvQAV1EAp/VdNJSNgghbD7OOuSPXstXzgGZsY=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1780583238; c=relaxed/simple;
	bh=9QTOFDsJ3yOCe4Q053NkQEMQbsYSBManmQn/Nq59ARg=;
	h=From:In-Reply-To:References:To:Cc:Subject:MIME-Version:
	 Content-Type:Date:Message-ID; b=IGiXFsv15J+zAZbqM67DQgpehWGDg9NFKOqij9SQVfbEO/88EpGGLNvApSUFC+Sw8drw6WUOhFATMmjXIxKC6tdG0sIcdNu649RPebXQm9BUsl+3HCEKsfpoPIy2htHfdTrkaE0tbYawSwWaF0Jr0tAZcO8bAaDsDlafswhH+NI=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dmarc=pass (p=quarantine dis=none) header.from=redhat.com; spf=pass smtp.mailfrom=redhat.com; dkim=pass (1024-bit key) header.d=redhat.com header.i=@redhat.com header.b=S3T7Vf9A; arc=none smtp.client-ip=170.10.129.124
Authentication-Results: smtp.subspace.kernel.org; dmarc=pass (p=quarantine dis=none) header.from=redhat.com
Authentication-Results: smtp.subspace.kernel.org; spf=pass smtp.mailfrom=redhat.com
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (1024-bit key) header.d=redhat.com header.i=@redhat.com header.b="S3T7Vf9A"
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=redhat.com;
	s=mimecast20190719; t=1780583236;
	h=from:from:reply-to:subject:subject:date:date:message-id:message-id:
	 to:to:cc:cc:mime-version:mime-version:content-type:content-type:
	 in-reply-to:in-reply-to:references:references;
	bh=+OfjBfn5py7b5HQjhhTkuXyu2HLnt9jaf0NDydzON4I=;
	b=S3T7Vf9Ab60q4ESGJsSLYZsbJE/CKm9zaktRmcwhdnnqQkd1CP2o5Y574yYV5OXIVJGTg8
	uMvhe8fDUjNwng4b8uPF2EKb3XI7xUTlGPxfEmQ/veV59RxC0g0Y2zWtis4C9kzK2Fl28+
	0E4lzmtl7SdvK8Cf0WTxdu39JG8xfvQ=
Received: from mx-prod-mc-03.mail-002.prod.us-west-2.aws.redhat.com
 (ec2-54-186-198-63.us-west-2.compute.amazonaws.com [54.186.198.63]) by
 relay.mimecast.com with ESMTP with STARTTLS (version=TLSv1.3,
 cipher=TLS_AES_256_GCM_SHA384) id us-mta-493-PwOfHFj9OsiIKGl_Ou9BIA-1; Thu,
 04 Jun 2026 10:27:11 -0400
X-MC-Unique: PwOfHFj9OsiIKGl_Ou9BIA-1
X-Mimecast-MFC-AGG-ID: PwOfHFj9OsiIKGl_Ou9BIA_1780583228
Received: from mx-prod-int-03.mail-002.prod.us-west-2.aws.redhat.com (mx-prod-int-03.mail-002.prod.us-west-2.aws.redhat.com [10.30.177.12])
	(using TLSv1.3 with cipher TLS_AES_256_GCM_SHA384 (256/256 bits)
	 key-exchange X25519 server-signature RSA-PSS (2048 bits) server-digest SHA256)
	(No client certificate requested)
	by mx-prod-mc-03.mail-002.prod.us-west-2.aws.redhat.com (Postfix) with ESMTPS id 5D7CE1956050;
	Thu,  4 Jun 2026 14:27:07 +0000 (UTC)
Received: from warthog.procyon.org.uk (unknown [10.44.50.14])
	by mx-prod-int-03.mail-002.prod.us-west-2.aws.redhat.com (Postfix) with ESMTP id 22BEF1955BC0;
	Thu,  4 Jun 2026 14:26:59 +0000 (UTC)
Organization: Red Hat UK Ltd. Registered Address: Red Hat UK Ltd, Amberley
	Place, 107-111 Peascod Street, Windsor, Berkshire, SI4 1TE, United
	Kingdom.
	Registered in England and Wales under Company Registration No. 3798903
From: David Howells <dhowells@redhat.com>
In-Reply-To: <ahPon44OlN0SqzU6@infradead.org>
References: <ahPon44OlN0SqzU6@infradead.org> <20260518222959.488126-1-dhowells@redhat.com> <20260518222959.488126-7-dhowells@redhat.com>
To: Christoph Hellwig <hch@infradead.org>
Cc: dhowells@redhat.com, Christian Brauner <christian@brauner.io>,
    Matthew Wilcox <willy@infradead.org>,
    Paulo Alcantara <pc@manguebit.org>, Jens Axboe <axboe@kernel.dk>,
    Leon Romanovsky <leon@kernel.org>, Steve French <sfrench@samba.org>,
    ChenXiaoSong <chenxiaosong@chenxiaosong.com>,
    Marc Dionne <marc.dionne@auristor.com>,
    Eric Van Hensbergen <ericvh@kernel.org>,
    Dominique Martinet <asmadeus@codewreck.org>,
    Ilya Dryomov <idryomov@gmail.com>,
    Trond Myklebust <trondmy@kernel.org>, netfs@lists.linux.dev,
    linux-afs@lists.infradead.org, linux-cifs@vger.kernel.org,
    linux-nfs@vger.kernel.org, ceph-devel@vger.kernel.org,
    v9fs@lists.linux.dev, linux-erofs@lists.ozlabs.org,
    linux-fsdevel@vger.kernel.org, linux-kernel@vger.kernel.org,
    linux-block@vger.kernel.org
Subject: Re: [PATCH v2 06/21] iov_iter: Make iov_iter_get_pages*() wrap iov_iter_extract_pages()
Precedence: bulk
X-Mailing-List: linux-nfs@vger.kernel.org
List-Id: <linux-nfs.vger.kernel.org>
List-Subscribe: <mailto:linux-nfs+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:linux-nfs+unsubscribe@vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-ID: <127171.1780583218.1@warthog.procyon.org.uk>
Date: Thu, 04 Jun 2026 15:26:58 +0100
Message-ID: <127172.1780583218@warthog.procyon.org.uk>
X-Scanned-By: MIMEDefang 3.0 on 10.30.177.12

Christoph Hellwig <hch@infradead.org> wrote:

> On Mon, May 18, 2026 at 11:29:38PM +0100, David Howells wrote:
> > Make iov_iter_get_pages*() wrap iov_iter_extract_pages() for kernel
> > iterator types (e.g. ITER_BVEC, ITER_FOLIOQ, ITER_XARRAY).  The pages
> > obtained have their refcounts incremented afterwards if they're not slab
> > pages.  ITER_KVEC is left returning -EFAULT.
> 
> Just kill off iov_iter_get_pages*, please.  Or at least stop using it
> where these types matter.

Much as I would like to, this isn't the place to do it.  It will require an
overhaul of the network socket buffering.

David

