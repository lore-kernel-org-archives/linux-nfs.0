Received: from us-smtp-delivery-124.mimecast.com (us-smtp-delivery-124.mimecast.com [170.10.133.124])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 0CDEA449B05
	for <linux-nfs@vger.kernel.org>; Wed, 12 Aug 2026 13:13:08 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=170.10.133.124
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1786540390; cv=none; b=ZDFFicuaJD5Da1sNj0NQggQupJgwwVWPNI2kOr/F8slKB+x0YnYkDwt6uxSjE38PXSY6YmcrlieTd1DQSF3fzTO83Z2wOndVjrUTyD9AdKZ8jgacfLT8eaGSa/bX0uaUhBAS4ZcYY3ep7zc8VA55zo/aP90jgUCTxF0ET7i01Qs=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1786540390; c=relaxed/simple;
	bh=gWxthKON+rRjE/0W/xR+N9w37e1C0+/VotYjDJiwizI=;
	h=From:In-Reply-To:References:To:Cc:Subject:MIME-Version:
	 Content-Type:Date:Message-ID; b=ty3Sp7liPxTqpGvIRYh4d7bLWgczxYBsZAsij9/+tuhG0SZYS7KVt8fUOtBAkuNAaJ15eNGbP4hx6xoIZ2IL69Z62J6SWAgNJ4gqMPYf/W4NQebauZgct1y+S55vKsINcE+Rd9giB7hM5z9O+MdMwTpJEc1HJYa0d2OigNhdGHM=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dmarc=pass (p=quarantine dis=none) header.from=redhat.com; spf=pass smtp.mailfrom=redhat.com; dkim=pass (1024-bit key) header.d=redhat.com header.i=@redhat.com header.b=WxsCrWZS; arc=none smtp.client-ip=170.10.133.124
Authentication-Results: smtp.subspace.kernel.org; dmarc=pass (p=quarantine dis=none) header.from=redhat.com
Authentication-Results: smtp.subspace.kernel.org; spf=pass smtp.mailfrom=redhat.com
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (1024-bit key) header.d=redhat.com header.i=@redhat.com header.b="WxsCrWZS"
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=redhat.com;
	s=mimecast20190719; t=1786540387;
	h=from:from:reply-to:subject:subject:date:date:message-id:message-id:
	 to:to:cc:cc:mime-version:mime-version:content-type:content-type:
	 in-reply-to:in-reply-to:references:references;
	bh=E5SGICMAMUmFPm46fBeR3LuzkBRbUMvYLA1acXPgIik=;
	b=WxsCrWZSGhVQoYer7XeM4xlwdqySxc/GcL82icpyqmMyolytJTl3eFtkmx9eAIgg+x6rjz
	1Q1G/YWBA4f09kyU+SY99oXpYgVyG8ya3c0foyyncbajNbhTvh/5GIsXz06YfwTF0Y8kP6
	egXMGtp2zussZOY2C6gy3GC5zkxn0Oc=
Received: from mx-prod-mc-03.mail-002.prod.us-west-2.aws.redhat.com
 (ec2-54-186-198-63.us-west-2.compute.amazonaws.com [54.186.198.63]) by
 relay.mimecast.com with ESMTP with STARTTLS (version=TLSv1.3,
 cipher=TLS_AES_256_GCM_SHA384) id us-mta-146-0jxkndcSO621vToPp2Czag-1; Wed,
 12 Aug 2026 09:13:04 -0400
X-MC-Unique: 0jxkndcSO621vToPp2Czag-1
X-Mimecast-MFC-AGG-ID: 0jxkndcSO621vToPp2Czag_1786540382
Received: from mx-prod-int-10.mail-002.prod.us-west-2.aws.redhat.com (mx-prod-int-10.mail-002.prod.us-west-2.aws.redhat.com [10.30.177.95])
	(using TLSv1.3 with cipher TLS_AES_256_GCM_SHA384 (256/256 bits)
	 key-exchange X25519 server-signature RSA-PSS (2048 bits) server-digest SHA256)
	(No client certificate requested)
	by mx-prod-mc-03.mail-002.prod.us-west-2.aws.redhat.com (Postfix) with ESMTPS id 424AD195604B;
	Wed, 12 Aug 2026 13:13:01 +0000 (UTC)
Received: from warthog.procyon.org.uk (unknown [10.44.32.44])
	by mx-prod-int-10.mail-002.prod.us-west-2.aws.redhat.com (Postfix) with ESMTP id EE715422;
	Wed, 12 Aug 2026 13:12:55 +0000 (UTC)
Organization: Red Hat UK Ltd. Registered Address: Red Hat UK Ltd, Amberley
	Place, 107-111 Peascod Street, Windsor, Berkshire, SI4 1TE, United
	Kingdom.
	Registered in England and Wales under Company Registration No. 3798903
From: David Howells <dhowells@redhat.com>
In-Reply-To: <4bdf58bd593d9a54aa20760fd49aaa1df57ef216.camel@linux.ibm.com>
References: <4bdf58bd593d9a54aa20760fd49aaa1df57ef216.camel@linux.ibm.com> <20260728141344.1811120-1-dhowells@redhat.com> <20260728141344.1811120-2-dhowells@redhat.com>
To: Mimi Zohar <zohar@linux.ibm.com>
Cc: dhowells@redhat.com, Al Viro <viro@zeniv.linux.org.uk>,
    Christian Brauner <christian@brauner.io>,
    Marc Dionne <marc.dionne@auristor.com>,
    Jeffrey Altman <jaltman@auristor.com>,
    Steve French <sfrench@samba.org>, linux-afs@lists.infradead.org,
    openafs-devel@openafs.org, linux-cifs@vger.kernel.org,
    linux-nfs@vger.kernel.org, linux-fsdevel@vger.kernel.org,
    linux-kernel@vger.kernel.org,
    Etienne Champetier <champetier.etienne@gmail.com>,
    Chet Ramey <chet.ramey@case.edu>,
    Cheyenne Wills <cwills@sinenomine.net>,
    Christian Brauner <brauner@kernel.org>,
    linux-integrity@vger.kernel.org
Subject: Re: [PATCH v3 1/2] vfs: Allow filesystems with foreign owner IDs to override UID checks
Precedence: bulk
X-Mailing-List: linux-nfs@vger.kernel.org
List-Id: <linux-nfs.vger.kernel.org>
List-Subscribe: <mailto:linux-nfs+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:linux-nfs+unsubscribe@vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-ID: <986907.1786540374.1@warthog.procyon.org.uk>
Date: Wed, 12 Aug 2026 14:12:54 +0100
Message-ID: <986908.1786540374@warthog.procyon.org.uk>
X-Scanned-By: MIMEDefang 3.6 on 10.30.177.95

Mimi Zohar <zohar@linux.ibm.com> wrote:

> On Tue, 2026-07-28 at 15:13 +0100, David Howells wrote:
> > 
> >  (*) IMA policy ops.
> > 
> >      Unchanged for now.  I'm not sure what the best way to deal with this
> >      is - if, indeed, it needs any changes.
> 
> IMA policy rules may be written in terms of the uid, euid and fowner.  Any
> changes, if necessary, would need to be made to ima_match_rules().

I think I can probably leave this for now as using uids mapped through the
namespace mapping mechanism.  To do otherwise would, I think, require the
possibility of encoding foreign IDs in IMA rules.  Something to consider in
the future, maybe, but I don't think I need to deal with that here.

Possibly, we could make a general rule that "for any otherwise unmapped
foreign ID, do X" sort of thing.

David

