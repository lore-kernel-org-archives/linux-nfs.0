Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.remote-ip=170.10.129.124
ARC-Seal: i=1; d=subspace.kernel.org; s=arc20261015; a=rsa-sha256; cv=none;
	t=1795088992;
	b=McSEN8z9yrHCCf3UxZGH2de1zUch1FoXEKueJFkr+AExnlW0yKtNWNv0VyJadJ73EbIa
	 6HIxjbyaYnc7iMw58A/nbU2SBC0U0XloF6nf+dMROnXjQGoZpiqU8Bpttn/IYnv0vN+od
	 VbohjsrGLQNNGcxuvpnHzeI8TcEmXndxezpOObWdaROrgyBD6c2VeQvHAdXdSIs3lSY5k
	 N/Q2nhMb5NLzcotTquqjgtyVps/Vrt8KanjQsCmvxDjLUOu9XVDtcG+ZR/XvifoahaYmf
	 3bzrGRnUKr4rgzwf57j2R2JvrFly7YN7ILjKU5hV7bSeN+3XmoX5e9DLzEQuD5kb+WA==
ARC-Message-Signature: i=1; d=subspace.kernel.org; s=arc20261015;
	a=rsa-sha256; c=relaxed/relaxed; t=1795088992;
	h=DMARC-Filter:DKIM-Signature:Received:X-MC-Unique:
	 X-Mimecast-MFC-AGG-ID:Received:Received:Organization:In-Reply-To:
	 References:To:Cc:Subject:MIME-Version:Content-Type:Content-ID:
	 Content-Transfer-Encoding:From:Date:Message-ID:X-Scanned-By;
	bh=IsxZ3bxno6EnIg0EDPua9HML/+iFhkLvwUEGIoUt8W4=;
	b=Z+ZIOrdji5yy9mj2FjMpvE5E5JYLm8MkSq9EMp3JE46l/A5TMWokVEieLY8HGbw/mGkk
	 TP8fjSHs9OkHcHUtiQUzJFBvoS6qCuuOTznPRWftVFe7TtnuuaGnNbC1v7QzmaCttdWHQ
	 deSZ/gfo01Y9HkNHZozMsJJEtgvFf8K9zsyxJxD8g98JH3iKkAAJwMAzAU/mYVm/cOxpK
	 /Sf0z5PnKGwrxOcVxwfotg756/Pgcg2xtT0+EVqLXuHsnBLvdcWyzjUktEvF2y0X3F1R8
	 ZQY6A/ooaoLleh45VRnQrCP2sN/lGiAgfxJbcPub6v0kLEWq4Obp9LYLjKSyWYMBZug==
ARC-Authentication-Results: i=1; smtp.subspace.kernel.org; 
	dmarc=pass header.from=redhat.com;
	spf=pass smtp.mailfrom=redhat.com;
	dkim=pass header.d=redhat.com header.i=@redhat.com header.a=rsa-sha256 header.s=mimecast20190719 header.b=KxFxOqcW;
	arc=none smtp.remote-ip=170.10.129.124
Received: from us-smtp-delivery-124.mimecast.com (us-smtp-delivery-124.mimecast.com [170.10.129.124])
	(using TLSv1.3 with cipher TLS_AES_256_GCM_SHA384 (256/256 bits)
	 key-exchange X25519 server-signature ECDSA (prime256v1) server-digest SHA256)
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 4834E60A2610
	for <linux-nfs@vger.kernel.org>; Thu, 19 Nov 2026 11:49:51 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.4.2 smtp.subspace.kernel.org 4834E60A2610
Authentication-Results: smtp.subspace.kernel.org; dmarc=pass (p=quarantine dis=none) header.from=redhat.com
Authentication-Results: smtp.subspace.kernel.org; spf=pass smtp.mailfrom=redhat.com
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (1024-bit key) header.d=redhat.com header.i=@redhat.com header.a=rsa-sha256 header.s=mimecast20190719 header.b=KxFxOqcW
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=redhat.com;
	s=mimecast20190719; t=1795088990;
	h=from:from:reply-to:subject:subject:date:date:message-id:message-id:
	 to:to:cc:cc:mime-version:mime-version:content-type:content-type:
	 content-transfer-encoding:content-transfer-encoding:
	 in-reply-to:in-reply-to:references:references;
	bh=IsxZ3bxno6EnIg0EDPua9HML/+iFhkLvwUEGIoUt8W4=;
	b=KxFxOqcWk0ntE2JdHuEATQJeYXRTnub+pEFSsEfK0+FVhcTpx2CIDx6Em/LdXLgo5zcT4L
	p4jwnaNixvRHfnsTpBqmcnYj7WiVilEy49n36yzw6aK2ADQX2XFgMkfoj1XxS67P9jEMb/
	K1rpVP01ccvBUNFyKVM7ZC/Tpzvpw/8=
Received: from mx-prod-mc-01.mail-002.prod.us-west-2.aws.redhat.com
 (ec2-54-186-198-63.us-west-2.compute.amazonaws.com [54.186.198.63]) by
 relay.mimecast.com with ESMTP with STARTTLS (version=TLSv1.3,
 cipher=TLS_AES_256_GCM_SHA384) id us-mta-597-tJa0fbcpOc2FEqPbTXJloQ-1; Thu,
 19 Nov 2026 06:49:47 -0500
X-MC-Unique: tJa0fbcpOc2FEqPbTXJloQ-1
X-Mimecast-MFC-AGG-ID: tJa0fbcpOc2FEqPbTXJloQ_1795088984
Received: from mx-prod-int-05.mail-002.prod.us-west-2.aws.redhat.com (mx-prod-int-05.mail-002.prod.us-west-2.aws.redhat.com [10.30.177.17])
	(using TLSv1.3 with cipher TLS_AES_256_GCM_SHA384 (256/256 bits)
	 key-exchange X25519 server-signature RSA-PSS (2048 bits) server-digest SHA256)
	(No client certificate requested)
	by mx-prod-mc-01.mail-002.prod.us-west-2.aws.redhat.com (Postfix) with ESMTPS id A5DBA19560AA;
	Thu, 19 Nov 2026 11:49:43 +0000 (UTC)
Received: from dhowells-thinkpadp1gen8.rmtgb.csb (headnet04.pony-001.prod.iad2.dc.redhat.com [10.2.32.116])
	by mx-prod-int-05.mail-002.prod.us-west-2.aws.redhat.com (Postfix) with ESMTP id 1C098195B3C6;
	Thu, 19 Nov 2026 11:49:38 +0000 (UTC)
Organization: Red Hat UK Ltd. Registered Address: Red Hat UK Ltd, Amberley
	Place, 107-111 Peascod Street, Windsor, Berkshire, SI4 1TE, United
	Kingdom.
	Registered in England and Wales under Company Registration No. 3798903
In-Reply-To: <20261119083851.3306418-15-dhowells@redhat.com>
References: <20261119083851.3306418-15-dhowells@redhat.com> <20261119083851.3306418-1-dhowells@redhat.com>
To: Christian Brauner <christian@brauner.io>
Cc: dhowells@redhat.com, Paulo Alcantara <pc@manguebit.org>,
    Matthew Wilcox <willy@infradead.org>,
    Namjae Jeon <linkinjeon@kernel.org>,
    Marc Dionne <marc.dionne@auristor.com>,
    Stefan Metzmacher <metze@samba.org>,
    Eric Van Hensbergen <ericvh@kernel.org>,
    Dominique Martinet <asmadeus@codewreck.org>,
    Ilya Dryomov <idryomov@gmail.com>, netfs@lists.linux.dev,
    linux-afs@lists.infradead.org, linux-cifs@vger.kernel.org,
    linux-nfs@vger.kernel.org, ceph-devel@vger.kernel.org,
    v9fs@lists.linux.dev, linux-fsdevel@vger.kernel.org,
    linux-kernel@vger.kernel.org, Shyam Prasad N <sprasad@microsoft.com>,
    Tom Talpey <tom@talpey.com>, Christoph Hellwig <hch@infradead.org>
Subject: Re: [PATCH v19 14/17] netfs: Switch folioq to bvecq
X-Mailing-List: linux-nfs@vger.kernel.org
List-Id: <linux-nfs.vger.kernel.org>
List-Post: <mailto:linux-nfs@vger.kernel.org>
List-Help: <mailto:linux-nfs+help@vger.kernel.org>
List-Subscribe: <mailto:linux-nfs+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:linux-nfs+unsubscribe@vger.kernel.org>
List-Owner: <mailto:linux-nfs+owner@vger.kernel.org>
Precedence: list
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-ID: <3330894.1795088857.1@dhowells-thinkpadp1gen8.rmtgb.csb>
Content-Transfer-Encoding: quoted-printable
From: David Howells <dhowells@redhat.com>
Date: Thu, 19 Nov 2026 11:49:38 +0000
Message-ID: <3331469.1795088978@dhowells-thinkpadp1gen8.rmtgb.csb>
X-Scanned-By: MIMEDefang 3.0 on 10.30.177.17

Hi Christian,

If you apply this patch, can you apply the attached change to it to fix a
potential NULL deref spotted by Sashiko[1]?

Thanks,
David
    =

[1] https://sashiko.dev/#/patchset/20261119083851.3306418-1-dhowells%40red=
hat.com
---
diff --git a/fs/netfs/buffered_read.c b/fs/netfs/buffered_read.c
index 852b2cb73435..d229e797ef23 100644
--- a/fs/netfs/buffered_read.c
+++ b/fs/netfs/buffered_read.c
@@ -277,14 +277,15 @@ static void netfs_read_to_pagecache(struct netfs_io_=
request *rreq)
 		.cached_to[1]	=3D ULLONG_MAX,
 	};
 	struct fscache_occupancy *occ =3D &_occ;
-	struct bvecq *mark_bq =3D rreq->buffer.tail, *mark_pin;
+	struct bvecq *mark_bq =3D rreq->buffer.tail, *mark_pin =3D NULL;
 	unsigned int mark_offset =3D 0;
 	ssize_t size =3D rreq->len;
 	uoff_t start =3D rreq->start;
 	int ret =3D 0, mark_slot =3D 0;
 =

 	/* Pin the bvecq whilst we mark folios for copying to the cache. */
-	mark_pin =3D bvecq_get(mark_bq);
+	if (mark_bq)
+		mark_pin =3D bvecq_get(mark_bq);
 =

 	do {
 		int (*prepare_read)(struct netfs_io_subrequest *subreq) =3D NULL;

