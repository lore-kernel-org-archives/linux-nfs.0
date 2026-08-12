Received: from us-smtp-delivery-124.mimecast.com (us-smtp-delivery-124.mimecast.com [170.10.133.124])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 37AE943F0A6
	for <linux-nfs@vger.kernel.org>; Wed, 12 Aug 2026 13:08:11 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=170.10.133.124
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1786540092; cv=none; b=dQ+1RNt4yzrA1UWZT1segcKrpcWTi/bSYvhXKOQtjScikH5EpjVBKhHlWRh8Qg0Jo4NJnJNIF21ZcNNSYyD6ID5qRh36NawehXSsNMvmIIY0c3el4REy4m5oo8zeMBwiKj2d9JOs0Ggnj7DK0HfECKezDQgMbYMhg1TcaLp/A4o=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1786540092; c=relaxed/simple;
	bh=MxtxiHUFGbpG7wyR5W/M29tb30zag0BJASeiKHwLsI0=;
	h=From:In-Reply-To:References:To:Cc:Subject:MIME-Version:
	 Content-Type:Date:Message-ID; b=nsA9T/GU6zjUDcyPovGk6pTOo8DZbNSeJPC692B4/SCPwYtajU1tNRP/m134OSb6ej5ObeGinPnnKkHKS+T6CP01oYp6K3wuxX6sFyuRiT/ydKGEoHEwCUVYPtBE2SofuOKl+rx4DmrRZI5LNVUHcshLOkLmCcJqJLqCzCA7RjA=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dmarc=pass (p=quarantine dis=none) header.from=redhat.com; spf=pass smtp.mailfrom=redhat.com; dkim=pass (1024-bit key) header.d=redhat.com header.i=@redhat.com header.b=HBNVuXPb; arc=none smtp.client-ip=170.10.133.124
Authentication-Results: smtp.subspace.kernel.org; dmarc=pass (p=quarantine dis=none) header.from=redhat.com
Authentication-Results: smtp.subspace.kernel.org; spf=pass smtp.mailfrom=redhat.com
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (1024-bit key) header.d=redhat.com header.i=@redhat.com header.b="HBNVuXPb"
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=redhat.com;
	s=mimecast20190719; t=1786540090;
	h=from:from:reply-to:subject:subject:date:date:message-id:message-id:
	 to:to:cc:cc:mime-version:mime-version:content-type:content-type:
	 in-reply-to:in-reply-to:references:references;
	bh=I3xqDyj2MmpztW1ops8Nu205Xj6JE2nK9d9TnUz1EEA=;
	b=HBNVuXPbneWBsLBMIvbJZu4HQi2xE+5TSGcp+UEpGBMGCsXOiKl3/UzsBZOBx/hLPhbcMP
	1orE0Yqz8y1Dm33VcZGg+r/lEfY2M8IzUuisFvIVqw/8Ifko+vEKLcB605BI9oJzJd0FK7
	+lkIzTPsnvELLIVsinr1S14Cys3XZQ0=
Received: from mx-prod-mc-08.mail-002.prod.us-west-2.aws.redhat.com
 (ec2-35-165-154-97.us-west-2.compute.amazonaws.com [35.165.154.97]) by
 relay.mimecast.com with ESMTP with STARTTLS (version=TLSv1.3,
 cipher=TLS_AES_256_GCM_SHA384) id us-mta-588-szUloSf1MwK4mgbg-tv4vQ-1; Wed,
 12 Aug 2026 09:08:04 -0400
X-MC-Unique: szUloSf1MwK4mgbg-tv4vQ-1
X-Mimecast-MFC-AGG-ID: szUloSf1MwK4mgbg-tv4vQ_1786540083
Received: from mx-prod-int-10.mail-002.prod.us-west-2.aws.redhat.com (mx-prod-int-10.mail-002.prod.us-west-2.aws.redhat.com [10.30.177.95])
	(using TLSv1.3 with cipher TLS_AES_256_GCM_SHA384 (256/256 bits)
	 key-exchange X25519 server-signature RSA-PSS (2048 bits) server-digest SHA256)
	(No client certificate requested)
	by mx-prod-mc-08.mail-002.prod.us-west-2.aws.redhat.com (Postfix) with ESMTPS id 6A0831800646;
	Wed, 12 Aug 2026 13:08:02 +0000 (UTC)
Received: from warthog.procyon.org.uk (unknown [10.44.32.44])
	by mx-prod-int-10.mail-002.prod.us-west-2.aws.redhat.com (Postfix) with ESMTP id 9B6A2426;
	Wed, 12 Aug 2026 13:07:57 +0000 (UTC)
Organization: Red Hat UK Ltd. Registered Address: Red Hat UK Ltd, Amberley
	Place, 107-111 Peascod Street, Windsor, Berkshire, SI4 1TE, United
	Kingdom.
	Registered in England and Wales under Company Registration No. 3798903
From: David Howells <dhowells@redhat.com>
In-Reply-To: <20260810-jazzfest-unglaubhaft-miene-4d1cf4cf42d3@brauner>
References: <20260810-jazzfest-unglaubhaft-miene-4d1cf4cf42d3@brauner> <20260728141344.1811120-1-dhowells@redhat.com>
To: Christian Brauner <brauner@kernel.org>
Cc: dhowells@redhat.com, Al Viro <viro@zeniv.linux.org.uk>,
    Christian Brauner <christian@brauner.io>,
    Marc Dionne <marc.dionne@auristor.com>,
    Jeffrey Altman <jaltman@auristor.com>,
    Steve French <sfrench@samba.org>, linux-afs@lists.infradead.org,
    openafs-devel@openafs.org, linux-cifs@vger.kernel.org,
    linux-nfs@vger.kernel.org, linux-fsdevel@vger.kernel.org,
    linux-kernel@vger.kernel.org
Subject: Re: [PATCH v3 0/2] vfs, afs, bash: Fix miscomparison of foreign user IDs in the VFS
Precedence: bulk
X-Mailing-List: linux-nfs@vger.kernel.org
List-Id: <linux-nfs.vger.kernel.org>
List-Subscribe: <mailto:linux-nfs+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:linux-nfs+unsubscribe@vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-ID: <986589.1786540076.1@warthog.procyon.org.uk>
Date: Wed, 12 Aug 2026 14:07:56 +0100
Message-ID: <986590.1786540076@warthog.procyon.org.uk>
X-Scanned-By: MIMEDefang 3.6 on 10.30.177.95

Christian Brauner <brauner@kernel.org> wrote:

> > Note that chown may also need modifying in some way - but that can't
> > necessarily supply the information required (for instance, an AuriStor YFS
> > ID is 64 bits, but chown can only handle a 32-bit integer; CIFS might use
> > a GUID).
> 
> Seems that some other changes are required for this. I'll take a look
> once a new version is out.

If you're referring to the chown thing, can we ignore that for now?  It would
probably need some sort of new system call, but I don't know how that should
look for now.

David

