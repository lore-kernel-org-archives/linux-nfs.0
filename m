Received: from us-smtp-delivery-124.mimecast.com (us-smtp-delivery-124.mimecast.com [170.10.129.124])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id E45993A5E89
	for <linux-nfs@vger.kernel.org>; Mon,  6 Jul 2026 15:52:00 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=170.10.129.124
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1783353123; cv=none; b=kjrMFnwKKPAb1CWjhPzS/u/sGQ2tNA15ANiVAU4Rh3vqYZmhQEQqNEKjLOYpfwRiGmsj//qXEBWzTrQ35xfbKYtuI5/ryZvx93aAMn5gNneueIky0yXTvv+3xp7/y1vLT5KMOGFfIZAzhIhDHVi7ZpAxSUYD1RWW+qBQ1EdKKP0=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1783353123; c=relaxed/simple;
	bh=RfbiN6+a8nTS5a6ju5aNp5of3WLEVBvd+s+Kdr5yXak=;
	h=From:In-Reply-To:References:To:Cc:Subject:MIME-Version:
	 Content-Type:Date:Message-ID; b=fIuvJg4JT/qKqF4Gk5NNDawwYpiBak7IuYaP5MJRuiGqSELvhCxpadpfaOUwv0JKI+I8nD+ggPRXO1gRWRG6R8ADvUh5hXJYKmAsVoK+9aXtKjjuIYgqWsniv88y9ejfXuOtKOpxkVW3xz7xsZbFpTlMMppDRmD5LV4gjX9HE6g=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dmarc=pass (p=quarantine dis=none) header.from=redhat.com; spf=pass smtp.mailfrom=redhat.com; dkim=pass (1024-bit key) header.d=redhat.com header.i=@redhat.com header.b=TdSKIvDz; arc=none smtp.client-ip=170.10.129.124
Authentication-Results: smtp.subspace.kernel.org; dmarc=pass (p=quarantine dis=none) header.from=redhat.com
Authentication-Results: smtp.subspace.kernel.org; spf=pass smtp.mailfrom=redhat.com
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (1024-bit key) header.d=redhat.com header.i=@redhat.com header.b="TdSKIvDz"
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=redhat.com;
	s=mimecast20190719; t=1783353119;
	h=from:from:reply-to:subject:subject:date:date:message-id:message-id:
	 to:to:cc:cc:mime-version:mime-version:content-type:content-type:
	 in-reply-to:in-reply-to:references:references;
	bh=URQzIFfS1/Haxdbz2Ns3BTAOv0VzNelQyqgK4lKywjc=;
	b=TdSKIvDz1tJ+4tk+PiOpq+sw0977pnwzoTbB77KhdpQUGV4e9HchtR8TLLn2hJ729xHTg7
	+mav2wJfKwJpvte+KcBMWjH+3hwF8FpJcNvbdtVJibm8oX2a964CTCXNT25BHQkBloc5YO
	pG/O3GzjY4Ku3xOtMMxummGUSs941rg=
Received: from mx-prod-mc-01.mail-002.prod.us-west-2.aws.redhat.com
 (ec2-54-186-198-63.us-west-2.compute.amazonaws.com [54.186.198.63]) by
 relay.mimecast.com with ESMTP with STARTTLS (version=TLSv1.3,
 cipher=TLS_AES_256_GCM_SHA384) id us-mta-65-GUd2VfxQPRuPQ_RMGkZGbw-1; Mon,
 06 Jul 2026 11:51:55 -0400
X-MC-Unique: GUd2VfxQPRuPQ_RMGkZGbw-1
X-Mimecast-MFC-AGG-ID: GUd2VfxQPRuPQ_RMGkZGbw_1783353112
Received: from mx-prod-int-05.mail-002.prod.us-west-2.aws.redhat.com (mx-prod-int-05.mail-002.prod.us-west-2.aws.redhat.com [10.30.177.17])
	(using TLSv1.3 with cipher TLS_AES_256_GCM_SHA384 (256/256 bits)
	 key-exchange X25519 server-signature RSA-PSS (2048 bits) server-digest SHA256)
	(No client certificate requested)
	by mx-prod-mc-01.mail-002.prod.us-west-2.aws.redhat.com (Postfix) with ESMTPS id CED291955DE7;
	Mon,  6 Jul 2026 15:51:51 +0000 (UTC)
Received: from warthog.procyon.org.uk (unknown [10.44.33.159])
	by mx-prod-int-05.mail-002.prod.us-west-2.aws.redhat.com (Postfix) with ESMTP id E3E741956053;
	Mon,  6 Jul 2026 15:51:45 +0000 (UTC)
Organization: Red Hat UK Ltd. Registered Address: Red Hat UK Ltd, Amberley
	Place, 107-111 Peascod Street, Windsor, Berkshire, SI4 1TE, United
	Kingdom.
	Registered in England and Wales under Company Registration No. 3798903
From: David Howells <dhowells@redhat.com>
In-Reply-To: <20260706152737.1231312-1-dhowells@redhat.com>
References: <20260706152737.1231312-1-dhowells@redhat.com>
To: Christian Brauner <christian@brauner.io>
Cc: dhowells@redhat.com, Matthew Wilcox <willy@infradead.org>,
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
    linux-fsdevel@vger.kernel.org, linux-kernel@vger.kernel.org
Subject: Re: [PATCH v5 00/21] netfs: Keep track of folios in a segmented bio_vec[] chain
Precedence: bulk
X-Mailing-List: linux-nfs@vger.kernel.org
List-Id: <linux-nfs.vger.kernel.org>
List-Subscribe: <mailto:linux-nfs+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:linux-nfs+unsubscribe@vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-ID: <1232536.1783353104.1@warthog.procyon.org.uk>
Date: Mon, 06 Jul 2026 16:51:44 +0100
Message-ID: <1232537.1783353104@warthog.procyon.org.uk>
X-Scanned-By: MIMEDefang 3.0 on 10.30.177.17

Apologies...  The outgoing MX decided to go offline in the middle of that:

	error: `git send-email`: 4.7.1 Service unavailable - try again later

So I've re-sent it.

David

