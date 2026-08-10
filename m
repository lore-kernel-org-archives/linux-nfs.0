Received: from us-smtp-delivery-124.mimecast.com (us-smtp-delivery-124.mimecast.com [170.10.133.124])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id EFBB944213C
	for <linux-nfs@vger.kernel.org>; Mon, 10 Aug 2026 20:31:23 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=170.10.133.124
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1786393885; cv=none; b=Xo0WCH6doVUoQq6kfvZxzxn8UaVlpUTzoQ9m86hTkUACYKoojUrUv5XHHQPOsBIjDmgJAZfulIivkv+6f12z+RSwEs8IR1blsAg6ZboAc1fD0QW8CA3kKj6eVVA7UIIPZoUq5/Lc6qkfGBXwTO5o7a0xrU3htBxyuU5uXlhJ84Y=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1786393885; c=relaxed/simple;
	bh=SqaRd//dvVr9mB50I7wn+QndPUln3nLYJ57OMJu5Bos=;
	h=From:In-Reply-To:References:To:Cc:Subject:MIME-Version:
	 Content-Type:Date:Message-ID; b=ockE8t0uiu+9EgTeB6gAPmkYsU9eikf6cJnU5nR17Fu15oIwoEJ/KgEMGFOaZvrt7EKg1J0Gd9RREoSnISN4v+m2VHMNy85IQ5GCLU52UBS8SByBK5yFbl0Tu2LwgJ2He2wm1EIVqREmks/btV5Cu6Y4bvRzUzyGkTjhb1jtfw4=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dmarc=pass (p=quarantine dis=none) header.from=redhat.com; spf=pass smtp.mailfrom=redhat.com; dkim=pass (1024-bit key) header.d=redhat.com header.i=@redhat.com header.b=cWLbI9Dj; arc=none smtp.client-ip=170.10.133.124
Authentication-Results: smtp.subspace.kernel.org; dmarc=pass (p=quarantine dis=none) header.from=redhat.com
Authentication-Results: smtp.subspace.kernel.org; spf=pass smtp.mailfrom=redhat.com
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (1024-bit key) header.d=redhat.com header.i=@redhat.com header.b="cWLbI9Dj"
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=redhat.com;
	s=mimecast20190719; t=1786393883;
	h=from:from:reply-to:subject:subject:date:date:message-id:message-id:
	 to:to:cc:cc:mime-version:mime-version:content-type:content-type:
	 in-reply-to:in-reply-to:references:references;
	bh=N+nHIX4qndv3AfBXSobDAVXCw7W2PVPh2/yZZQrRWZU=;
	b=cWLbI9DjNZqP0bOUzpNFWt4VUzsxt6tCIww0Ph97nrSdcZFKCYwjcVCddbpcrG4O4LJJa4
	DE7QACMNte5lUMzuMX7mZWsc+HOQR86/6vFdJvLe1vbImzaLoJF1w3kKi3BfSY79taWME2
	b2qxD0gRoL7DF8ClSY3qDTNmEGsRYQ8=
Received: from mx-prod-mc-05.mail-002.prod.us-west-2.aws.redhat.com
 (ec2-54-186-198-63.us-west-2.compute.amazonaws.com [54.186.198.63]) by
 relay.mimecast.com with ESMTP with STARTTLS (version=TLSv1.3,
 cipher=TLS_AES_256_GCM_SHA384) id us-mta-278-8366SUk-OtWzAoVznGm_-g-1; Mon,
 10 Aug 2026 16:31:19 -0400
X-MC-Unique: 8366SUk-OtWzAoVznGm_-g-1
X-Mimecast-MFC-AGG-ID: 8366SUk-OtWzAoVznGm_-g_1786393877
Received: from mx-prod-int-08.mail-002.prod.us-west-2.aws.redhat.com (mx-prod-int-08.mail-002.prod.us-west-2.aws.redhat.com [10.30.177.111])
	(using TLSv1.3 with cipher TLS_AES_256_GCM_SHA384 (256/256 bits)
	 key-exchange X25519 server-signature RSA-PSS (2048 bits) server-digest SHA256)
	(No client certificate requested)
	by mx-prod-mc-05.mail-002.prod.us-west-2.aws.redhat.com (Postfix) with ESMTPS id 03F33195608A;
	Mon, 10 Aug 2026 20:31:15 +0000 (UTC)
Received: from warthog.procyon.org.uk (unknown [10.44.32.44])
	by mx-prod-int-08.mail-002.prod.us-west-2.aws.redhat.com (Postfix) with ESMTP id 2A89D1800346;
	Mon, 10 Aug 2026 20:31:04 +0000 (UTC)
Organization: Red Hat UK Ltd. Registered Address: Red Hat UK Ltd, Amberley
	Place, 107-111 Peascod Street, Windsor, Berkshire, SI4 1TE, United
	Kingdom.
	Registered in England and Wales under Company Registration No. 3798903
From: David Howells <dhowells@redhat.com>
In-Reply-To: <anooK9-UCNTmoSAq@casper.infradead.org>
References: <anooK9-UCNTmoSAq@casper.infradead.org> <20260810144746.574036-1-dhowells@redhat.com> <20260810144746.574036-5-dhowells@redhat.com>
To: Matthew Wilcox <willy@infradead.org>
Cc: dhowells@redhat.com, Christian Brauner <christian@brauner.io>,
    Christoph Hellwig <hch@infradead.org>,
    Paulo Alcantara <pc@manguebit.org>, Jens Axboe <axboe@kernel.dk>,
    Leon Romanovsky <leon@kernel.org>, Steve French <sfrench@samba.org>,
    ChenXiaoSong <chenxiaosong@chenxiaosong.com>,
    Marc Dionne <marc.dionne@auristor.com>,
    Stefan Metzmacher <metze@samba.org>,
    Eric Van Hensbergen <ericvh@kernel.org>,
    Dominique Martinet <asmadeus@codewreck.org>,
    Ilya Dryomov <idryomov@gmail.com>, netfs@lists.linux.dev,
    linux-afs@lists.infradead.org, linux-cifs@vger.kernel.org,
    linux-nfs@vger.kernel.org, ceph-devel@vger.kernel.org,
    v9fs@lists.linux.dev, linux-erofs@lists.ozlabs.org,
    linux-fsdevel@vger.kernel.org, linux-kernel@vger.kernel.org,
    linux-block@vger.kernel.org
Subject: Re: [PATCH v9 04/26] Add a function to kmap one page of a multipage bio_vec
Precedence: bulk
X-Mailing-List: linux-nfs@vger.kernel.org
List-Id: <linux-nfs.vger.kernel.org>
List-Subscribe: <mailto:linux-nfs+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:linux-nfs+unsubscribe@vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-ID: <586047.1786393863.1@warthog.procyon.org.uk>
Date: Mon, 10 Aug 2026 21:31:03 +0100
Message-ID: <586048.1786393863@warthog.procyon.org.uk>
X-Scanned-By: MIMEDefang 3.4.1 on 10.30.177.111

Matthew Wilcox <willy@infradead.org> wrote:

> On Mon, Aug 10, 2026 at 03:47:21PM +0100, David Howells wrote:
> > Add a function to kmap one page of a multipage bio_vec by offset (which is
> > added to the offset in the bio_vec internally).  The caller is responsible
> > for calculating how much of the page is then available.
> 
> I think this should be kmap_local_bvec().  Living in bvec.h makes sense,
> but keeping it in the kmap_local_ namespace is better than putting it in
> the bvec_ namespace.

Christoph disagrees with you:-/

David

