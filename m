Received: from us-smtp-delivery-124.mimecast.com (us-smtp-delivery-124.mimecast.com [170.10.133.124])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 2E4254DD3C9
	for <linux-nfs@vger.kernel.org>; Wed, 14 Oct 2026 09:45:51 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=170.10.133.124
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1791971152; cv=none; b=Ffe9SSSR2zMr2px71JjVw+nQXltXh2Dk8nzBoECvr0H98LmdEKGOuYtOJTs1cazLPZ69X4lPpS3ggtz7OtAHbYKr0PVgPnPEeluvSoc0zTqX0cCoLz4O7f333X38/+nlG/n0LCyOuO3inYFygh0t3mM93f16r0y+afDJFlYysdU=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1791971152; c=relaxed/simple;
	bh=ID1YiJiWvOAG0AsnZJUSvdj0b+7VZeh7snBXhoGQ7yo=;
	h=From:In-Reply-To:References:To:Cc:Subject:MIME-Version:
	 Content-Type:Date:Message-ID; b=tqawQ3dyUHhIzWOpxr5mA1xGMWA4GDIGY10TsHEvMKFPdmvwS0+oGb+h/QnyO//cAI/yDtncuPzSempu1G9HHqXYN8MnFWZZYz+/zZt4gaHtkqP7nFpaRyHA77EFYLuI2CiFt/EVee4FSfelwkKHLLkwl4X8CADscJz2JGvIOc4=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dmarc=pass (p=quarantine dis=none) header.from=redhat.com; spf=pass smtp.mailfrom=redhat.com; dkim=pass (1024-bit key) header.d=redhat.com header.i=@redhat.com header.b=JrTqRSlg; arc=none smtp.client-ip=170.10.133.124
Authentication-Results: smtp.subspace.kernel.org; dmarc=pass (p=quarantine dis=none) header.from=redhat.com
Authentication-Results: smtp.subspace.kernel.org; spf=pass smtp.mailfrom=redhat.com
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (1024-bit key) header.d=redhat.com header.i=@redhat.com header.b="JrTqRSlg"
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=redhat.com;
	s=mimecast20190719; t=1791971150;
	h=from:from:reply-to:subject:subject:date:date:message-id:message-id:
	 to:to:cc:cc:mime-version:mime-version:content-type:content-type:
	 content-transfer-encoding:content-transfer-encoding:
	 in-reply-to:in-reply-to:references:references;
	bh=psHmh+mmjF/vIp3ChRxGhlRhpQq6TSm83eNrdquwHxw=;
	b=JrTqRSlg9U7WqHcm/+jjdgD9KpM80Qg69iZKL0HrnAkQso6/1CgBD0WJa5R+BjoL7B0vFb
	VXSzNECXleSnwXtQWU8l/IrmNHUVhI40klFMtgatoQbmdP2797JPgAS9zdc18G3P/FdLdu
	5mriKjCH+RCT2VLmvzBTC9LeOp/T5aI=
Received: from mx-prod-mc-01.mail-002.prod.us-west-2.aws.redhat.com
 (ec2-54-186-198-63.us-west-2.compute.amazonaws.com [54.186.198.63]) by
 relay.mimecast.com with ESMTP with STARTTLS (version=TLSv1.3,
 cipher=TLS_AES_256_GCM_SHA384) id us-mta-524-o3tIefQBPv-FG1zUwHrgIw-1; Wed,
 14 Oct 2026 09:45:38 +0000
X-MC-Unique: o3tIefQBPv-FG1zUwHrgIw-1
X-Mimecast-MFC-AGG-ID: o3tIefQBPv-FG1zUwHrgIw_1791971135
Received: from mx-prod-int-01.mail-002.prod.us-west-2.aws.redhat.com (mx-prod-int-01.mail-002.prod.us-west-2.aws.redhat.com [10.30.177.4])
	(using TLSv1.3 with cipher TLS_AES_256_GCM_SHA384 (256/256 bits)
	 key-exchange X25519 server-signature RSA-PSS (2048 bits) server-digest SHA256)
	(No client certificate requested)
	by mx-prod-mc-01.mail-002.prod.us-west-2.aws.redhat.com (Postfix) with ESMTPS id 396ED19560B2;
	Wed, 14 Oct 2026 09:45:34 +0000 (UTC)
Received: from warthog.procyon.org.uk (unknown [10.44.48.11])
	by mx-prod-int-01.mail-002.prod.us-west-2.aws.redhat.com (Postfix) with ESMTP id 696E830000E3;
	Wed, 14 Oct 2026 09:45:27 +0000 (UTC)
Organization: Red Hat UK Ltd. Registered Address: Red Hat UK Ltd, Amberley
	Place, 107-111 Peascod Street, Windsor, Berkshire, SI4 1TE, United
	Kingdom.
	Registered in England and Wales under Company Registration No. 3798903
From: David Howells <dhowells@redhat.com>
In-Reply-To: <20261013.cachefiles-partial-zeros-trace.pchmelar@innovatrics.com>
References: <20261013.cachefiles-partial-zeros-trace.pchmelar@innovatrics.com> <20260910220242.2165023-1-dhowells@redhat.com> <20260910220242.2165023-5-dhowells@redhat.com> <20261011.cachefiles-partial-zeros.pchmelar@innovatrics.com> <1655268.1791878098@warthog.procyon.org.uk>
To: Petr Chmelar <petr.chmelar@innovatrics.com>
Cc: dhowells@redhat.com, Christian Brauner <christian@brauner.io>,
    Paulo Alcantara <pc@manguebit.org>,
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
Subject: Re: [PATCH v12 4/5] cachefiles: Don't rely on backing fs storage map for most use cases
Precedence: bulk
X-Mailing-List: linux-nfs@vger.kernel.org
List-Id: <linux-nfs.vger.kernel.org>
List-Subscribe: <mailto:linux-nfs+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:linux-nfs+unsubscribe@vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-ID: <1995692.1791971125.1@warthog.procyon.org.uk>
Content-Transfer-Encoding: quoted-printable
Date: Wed, 14 Oct 2026 10:45:25 +0100
Message-ID: <1995693.1791971125@warthog.procyon.org.uk>
X-Scanned-By: MIMEDefang 3.4.1 on 10.30.177.4

Does the attached fix the problem?

David
---
diff --git a/fs/netfs/buffered_read.c b/fs/netfs/buffered_read.c
index cc1b00f301d2..c0157f9a338d 100644
--- a/fs/netfs/buffered_read.c
+++ b/fs/netfs/buffered_read.c
@@ -379,7 +379,7 @@ static void netfs_read_to_pagecache(struct netfs_io_re=
quest *rreq)
 		}
 =

 		subreq->start	=3D start;
-		subreq->len	=3D size;
+		subreq->len	=3D len;
 		if (copy)
 			__set_bit(NETFS_SREQ_COPY_TO_CACHE, &subreq->flags);
 =

