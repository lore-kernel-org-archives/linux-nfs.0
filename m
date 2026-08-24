Received: from us-smtp-delivery-124.mimecast.com (us-smtp-delivery-124.mimecast.com [170.10.129.124])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 25AD738757D
	for <linux-nfs@vger.kernel.org>; Mon, 24 Aug 2026 19:47:53 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=170.10.129.124
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1787600874; cv=none; b=ldNh8VEva2FYPHAFRpTWwRNZLUdBwMMjsBBP+d0IDdwVjCQzS3CozcchPZf3HdnO0oii3x4O3jEytvPNU3V0JGcDQLLwCeU8+cbI8i9LKpqi1HlW3IVCqwtNBZwnCN0cdSUaYHzljdUBFjtzVC61MceFO31kKRzhKSS5qdgPGgA=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1787600874; c=relaxed/simple;
	bh=ls9gAniDaxU60S488EwFx+HIbvW54OfMRM5lR9rJRqY=;
	h=From:In-Reply-To:References:To:Cc:Subject:MIME-Version:
	 Content-Type:Date:Message-ID; b=SJpv/Z9L6ckdDQDANBQNlx9lZR9zppKL9bGPmeOVQb8QrL3aVKGMkTZ6jWYO3oIBSeAJM81VNaaGw63bCNiIpLGR51gH1pZmuVsZKI4Z3x4SOe/9iOGY6mK5KpEvF4+5GAnz47fj54QWv31ugFxUfUsIJtv2pcIG0MrbMuvuG/w=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dmarc=pass (p=quarantine dis=none) header.from=redhat.com; spf=pass smtp.mailfrom=redhat.com; dkim=pass (1024-bit key) header.d=redhat.com header.i=@redhat.com header.b=TZBdtWjP; arc=none smtp.client-ip=170.10.129.124
Authentication-Results: smtp.subspace.kernel.org; dmarc=pass (p=quarantine dis=none) header.from=redhat.com
Authentication-Results: smtp.subspace.kernel.org; spf=pass smtp.mailfrom=redhat.com
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (1024-bit key) header.d=redhat.com header.i=@redhat.com header.b="TZBdtWjP"
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=redhat.com;
	s=mimecast20190719; t=1787600872;
	h=from:from:reply-to:subject:subject:date:date:message-id:message-id:
	 to:to:cc:cc:mime-version:mime-version:content-type:content-type:
	 content-transfer-encoding:content-transfer-encoding:
	 in-reply-to:in-reply-to:references:references;
	bh=HWkfuD+RoHFHnIf8MPWKdp7sPrGB/v7hQ704zJ+2+Ds=;
	b=TZBdtWjP/2sk3DX+bMMgowDcJBDvz8CQOAWZzZnkZ/iss8RIpBRsEjSqu1C6HMhWtNGrsh
	dCKF9zRQdFN9mC+akzXzdsDqVcOfE92AR06LMTocXrvLVN0KToDX7fwwv+O3dm95X9NhgB
	owtN3XD71wEhLK14UKTUmum50DhqNPI=
Received: from mx-prod-mc-08.mail-002.prod.us-west-2.aws.redhat.com
 (ec2-35-165-154-97.us-west-2.compute.amazonaws.com [35.165.154.97]) by
 relay.mimecast.com with ESMTP with STARTTLS (version=TLSv1.3,
 cipher=TLS_AES_256_GCM_SHA384) id us-mta-635-9XFVDZNVN-aHPcQHKQgWyA-1; Mon,
 24 Aug 2026 15:47:45 -0400
X-MC-Unique: 9XFVDZNVN-aHPcQHKQgWyA-1
X-Mimecast-MFC-AGG-ID: 9XFVDZNVN-aHPcQHKQgWyA_1787600862
Received: from mx-prod-int-05.mail-002.prod.us-west-2.aws.redhat.com (mx-prod-int-05.mail-002.prod.us-west-2.aws.redhat.com [10.30.177.17])
	(using TLSv1.3 with cipher TLS_AES_256_GCM_SHA384 (256/256 bits)
	 key-exchange X25519 server-signature RSA-PSS (2048 bits) server-digest SHA256)
	(No client certificate requested)
	by mx-prod-mc-08.mail-002.prod.us-west-2.aws.redhat.com (Postfix) with ESMTPS id 5D45F184B396;
	Mon, 24 Aug 2026 19:47:40 +0000 (UTC)
Received: from warthog.procyon.org.uk (unknown [10.44.32.15])
	by mx-prod-int-05.mail-002.prod.us-west-2.aws.redhat.com (Postfix) with ESMTP id C8E871944B2A;
	Mon, 24 Aug 2026 19:47:31 +0000 (UTC)
Organization: Red Hat UK Ltd. Registered Address: Red Hat UK Ltd, Amberley
	Place, 107-111 Peascod Street, Windsor, Berkshire, SI4 1TE, United
	Kingdom.
	Registered in England and Wales under Company Registration No. 3798903
From: David Howells <dhowells@redhat.com>
In-Reply-To: <CA+1jF5qPZUhCevwbu7zQDEVWss6gMdoDMhqKqH3k7v=WStRtEA@mail.gmail.com>
References: <CA+1jF5qPZUhCevwbu7zQDEVWss6gMdoDMhqKqH3k7v=WStRtEA@mail.gmail.com> <20260824144130.759997-1-dhowells@redhat.com> <20260824144130.759997-31-dhowells@redhat.com>
To: =?us-ascii?Q?=3D=3FUTF-8=3FQ=3FAur=3DC3=3DA9lien=5FCouderc=3F=3D?= <aurelien.couderc2002@gmail.com>
Cc: dhowells@redhat.com, Paulo Alcantara <pc@manguebit.org>,
    Christian Brauner <christian@brauner.io>,
    Matthew Wilcox <willy@infradead.org>,
    Christoph Hellwig <hch@infradead.org>, Jens Axboe <axboe@kernel.dk>,
    Leon Romanovsky <leon@kernel.org>,
    Namjae Jeon <linkinjeon@kernel.org>,
    ChenXiaoSong <chenxiaosong@chenxiaosong.com>,
    Marc Dionne <marc.dionne@auristor.com>,
    Stefan Metzmacher <metze@samba.org>,
    Eric Van Hensbergen <ericvh@kernel.org>,
    Dominique Martinet <asmadeus@codewreck.org>,
    Ilya Dryomov <idryomov@gmail.com>, netfs@lists.linux.dev,
    linux-afs@lists.infradead.org, linux-cifs@vger.kernel.org,
    Linux NFS Mailing List <linux-nfs@vger.kernel.org>,
    ceph-devel@vger.kernel.org, v9fs@lists.linux.dev,
    linux-erofs@lists.ozlabs.org, linux-fsdevel@vger.kernel.org,
    linux-kernel@vger.kernel.org
Subject: Re: READ_PLUS in NetFS? Re: [PATCH v10 30/35] netfs: Simplify read abandonment
Precedence: bulk
X-Mailing-List: linux-nfs@vger.kernel.org
List-Id: <linux-nfs.vger.kernel.org>
List-Subscribe: <mailto:linux-nfs+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:linux-nfs+unsubscribe@vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: quoted-printable
Date: Mon, 24 Aug 2026 20:47:30 +0100
Message-ID: <771538.1787600850@warthog.procyon.org.uk>
X-Scanned-By: MIMEDefang 3.0 on 10.30.177.17

Aur=C3=A9lien Couderc <aurelien.couderc2002@gmail.com> wrote:

> What about READ_PLUS, i.e. sparse file reads? If you do this kind of
> work of handling partial abandonment, can such a work also benefit
> READ_PLUS?

READ_PLUS is NFS, right?

I'm not sure it would particularly help or hinder.

The VFS/VM only asks to read contiguous regions and netfslib breaks that up
into subrequests, but currently netfslib doesn't know anything about sparse
reads.  What I'm looking at with Ceph, for example, is that Ceph knows where
the gaps are and will clear them before terminating the subrequest.

Partial abandonment is for when some sort of fatal error occurs and we cann=
ot
finish the request.

David

