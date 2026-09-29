Received: from us-smtp-delivery-124.mimecast.com (us-smtp-delivery-124.mimecast.com [170.10.129.124])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 7C5BC3CE099
	for <linux-nfs@vger.kernel.org>; Tue, 29 Sep 2026 08:22:05 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=170.10.129.124
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1790670128; cv=none; b=vC6s621Qb7It/czvPT0UpZTNSAM4ULyJaBG1jKopj6O1azHdQfKdyo/X8SfickUAhcIEd9ViQuJgcxyw3oMDAkDPIXyyvl4HHTABrGhTj7xGTbFrHBIxijUpFO0AQL8A+zY8TXJ0q7D2ORrX8aocZZ2d8DB+xoluIySlEHniGLc=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1790670128; c=relaxed/simple;
	bh=r15FT8O0+h/Lmn4AjtALBT+TFXMGfpyHuzC/5T4v9fk=;
	h=From:In-Reply-To:References:To:Cc:Subject:MIME-Version:
	 Content-Type:Date:Message-ID; b=AAuBJowPfFJptHBjxyih5cHO+BP85C2bfXHyeW5mbwzF4wMQby2vjWExU8RIzJySOQ79ZN0FKgOxms87/e/0OCbJtRVQj6RSQ35MT31UhsRppebteIyBUv9ZSGgnd78gzQo5hE+1ei2HhhUwGDS1S/vHb12IPrskCBfZ+yjwEOo=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dmarc=pass (p=quarantine dis=none) header.from=redhat.com; spf=pass smtp.mailfrom=redhat.com; dkim=pass (1024-bit key) header.d=redhat.com header.i=@redhat.com header.b=dY20BVt3; arc=none smtp.client-ip=170.10.129.124
Authentication-Results: smtp.subspace.kernel.org; dmarc=pass (p=quarantine dis=none) header.from=redhat.com
Authentication-Results: smtp.subspace.kernel.org; spf=pass smtp.mailfrom=redhat.com
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (1024-bit key) header.d=redhat.com header.i=@redhat.com header.b="dY20BVt3"
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=redhat.com;
	s=mimecast20190719; t=1790670122;
	h=from:from:reply-to:subject:subject:date:date:message-id:message-id:
	 to:to:cc:cc:mime-version:mime-version:content-type:content-type:
	 in-reply-to:in-reply-to:references:references;
	bh=CL2aoSvWGvZB1oNYcZBn9qxNqNpbwole8e0uMT7sFzo=;
	b=dY20BVt37UY3EcK6OOFsH/cVL3IevvqkZb+hlFSFv+tFnSuRpqbfYKN0UO4xnvhUmktag0
	g8qVRnbw0DwkQ4I515A8SdRUmp7i6HWg2XliNFFukl9e7J8LJ9qq0bIIAvZmyyCtJtLXiS
	sRuM/v2+V0kXsPzYkh0HtyzFxSwLDHw=
Received: from mx-prod-mc-03.mail-002.prod.us-west-2.aws.redhat.com
 (ec2-54-186-198-63.us-west-2.compute.amazonaws.com [54.186.198.63]) by
 relay.mimecast.com with ESMTP with STARTTLS (version=TLSv1.3,
 cipher=TLS_AES_256_GCM_SHA384) id us-mta-271-oWsLDKbZPAqV-_pEJzYFOA-1; Tue,
 29 Sep 2026 04:21:58 -0400
X-MC-Unique: oWsLDKbZPAqV-_pEJzYFOA-1
X-Mimecast-MFC-AGG-ID: oWsLDKbZPAqV-_pEJzYFOA_1790670116
Received: from mx-prod-int-08.mail-002.prod.us-west-2.aws.redhat.com (mx-prod-int-08.mail-002.prod.us-west-2.aws.redhat.com [10.30.177.111])
	(using TLSv1.3 with cipher TLS_AES_256_GCM_SHA384 (256/256 bits)
	 key-exchange X25519 server-signature RSA-PSS (2048 bits) server-digest SHA256)
	(No client certificate requested)
	by mx-prod-mc-03.mail-002.prod.us-west-2.aws.redhat.com (Postfix) with ESMTPS id F3F5D1955E9E;
	Tue, 29 Sep 2026 08:21:55 +0000 (UTC)
Received: from warthog.procyon.org.uk (unknown [10.44.32.54])
	by mx-prod-int-08.mail-002.prod.us-west-2.aws.redhat.com (Postfix) with ESMTP id 49C70180034C;
	Tue, 29 Sep 2026 08:21:51 +0000 (UTC)
Organization: Red Hat UK Ltd. Registered Address: Red Hat UK Ltd, Amberley
	Place, 107-111 Peascod Street, Windsor, Berkshire, SI4 1TE, United
	Kingdom.
	Registered in England and Wales under Company Registration No. 3798903
From: David Howells <dhowells@redhat.com>
In-Reply-To: <20260929075913.2740968-1-dhowells@redhat.com>
References: <20260929075913.2740968-1-dhowells@redhat.com>
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
    linux-kernel@vger.kernel.org
Subject: Re: [PATCH v12 00/10] netfs, cachefiles: Changes for next, primarily occupancy tracking-related
Precedence: bulk
X-Mailing-List: linux-nfs@vger.kernel.org
List-Id: <linux-nfs.vger.kernel.org>
List-Subscribe: <mailto:linux-nfs+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:linux-nfs+unsubscribe@vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-ID: <2741972.1790670109.1@warthog.procyon.org.uk>
Date: Tue, 29 Sep 2026 09:21:49 +0100
Message-ID: <2741973.1790670109@warthog.procyon.org.uk>
X-Scanned-By: MIMEDefang 3.4.1 on 10.30.177.111

I forgot to change the cover subject line.  It should be something like:

	netfs, iov_iter: Use a chain of bio_vec arrays instead of folio_queue

David

