Received: from mx1.manguebit.org (mx1.manguebit.org [143.255.12.172])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id A35F92D23BC;
	Wed,  9 Sep 2026 21:02:28 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=143.255.12.172
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1788987750; cv=none; b=Dj+PQ050FCbmwNyhtNRARO+xdmy8IuGpDWTbJI8HBvqWnPMD6QeENDhlCAHY6gmNAXuei0rUFeeWxC8VhNaLcm2xbYBLGa6Hk2ebjuNl1cJM4EYmbH6QgHUjFmKRrG48Pc/3sTbx1JXKMrkQLcFHvUwxbrSS3UCeML/2gprMMIQ=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1788987750; c=relaxed/simple;
	bh=RbRwkmG+k97srXT46X9TZcXY34D0Uib07sm/Diy6nCg=;
	h=Message-ID:From:To:Cc:Subject:In-Reply-To:References:Date:
	 MIME-Version:Content-Type; b=cIyozAFhvIpN3uhIvTsYPf/Iomo28As05q+CxUIge/jmo33jBTBACxz9SdlSnh1MeoiXBuACaEONn4vmGJeiTrPbderxu7W4N4Y7l/37vku7zAVzVWBz7MBy7Irwyg2qecrClmwlc5mBgR5CTTigGOmFa0x+ppS/4+FiYza6NQQ=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dmarc=pass (p=quarantine dis=none) header.from=manguebit.org; spf=pass smtp.mailfrom=manguebit.org; dkim=pass (2048-bit key) header.d=manguebit.org header.i=@manguebit.org header.b=nvPxz3C1; arc=none smtp.client-ip=143.255.12.172
Authentication-Results: smtp.subspace.kernel.org; dmarc=pass (p=quarantine dis=none) header.from=manguebit.org
Authentication-Results: smtp.subspace.kernel.org; spf=pass smtp.mailfrom=manguebit.org
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=manguebit.org header.i=@manguebit.org header.b="nvPxz3C1"
DKIM-Signature: v=1; a=rsa-sha256; q=dns/txt; c=relaxed/relaxed;
	d=manguebit.org; s=dkim; h=Content-Type:MIME-Version:Date:References:
	In-Reply-To:Subject:Cc:To:From:Message-ID:Sender:Reply-To:
	Content-Transfer-Encoding:Content-ID:Content-Description;
	bh=XsW6lJv/Bxdj2Oiz5fJR6QVOHYJCmPAhWfl3TIaVqsE=; b=nvPxz3C1HCEzGPmCdRVEArPWdb
	bAiKEoVUeEHWMf10rF39TDfqobn3II5ANtmoNi+bLfojXAY/Dj9TfjWusQtYJUMgcrTXmxeX9jx1w
	RaalzMmKyu4mlaasbHSPzH0BGEergiJtp9KOaB453dEAOXahz96SQ2VmLWzn4xC0Oe0qTqK2iXRYR
	l2g/jkSNsmpt9X7oqdXvZFPVz+mq74UdeKX5LleBRDeXEZAD8k2RK30rkw9KXPJsLgQHpMTrps641
	t5XBovqqp7Y4U7laHq/4g3TA1A4A+twfjM009AdSX7Cw5LsJHRVHkYktJ7vGfKqI4SOQyN+EPMFN1
	s/ZFOktA==;
Received: from pc by mx1.manguebit.org with local (Exim 4.99.5)
	id 1x4PQq-0000000146Q-3izt;
	Wed, 09 Sep 2026 18:02:12 -0300
Message-ID: <b38953d143e8949d66415c461f46eb68@manguebit.org>
From: Paulo Alcantara <pc@manguebit.org>
To: David Howells <dhowells@redhat.com>, Christian Brauner
 <christian@brauner.io>
Cc: David Howells <dhowells@redhat.com>, Matthew Wilcox
 <willy@infradead.org>, Namjae Jeon <linkinjeon@kernel.org>, Marc Dionne
 <marc.dionne@auristor.com>, Stefan Metzmacher <metze@samba.org>, Eric Van
 Hensbergen <ericvh@kernel.org>, Dominique Martinet
 <asmadeus@codewreck.org>, Ilya Dryomov <idryomov@gmail.com>,
 netfs@lists.linux.dev, linux-afs@lists.infradead.org,
 linux-cifs@vger.kernel.org, linux-nfs@vger.kernel.org,
 ceph-devel@vger.kernel.org, v9fs@lists.linux.dev,
 linux-erofs@lists.ozlabs.org, linux-fsdevel@vger.kernel.org,
 linux-kernel@vger.kernel.org, linux-mm@kvack.org
Subject: Re: [PATCH v13 8/8] netfs: Set subrequest->source at alloc before
 trace emission
In-Reply-To: <20260909072105.1663687-9-dhowells@redhat.com>
References: <20260909072105.1663687-1-dhowells@redhat.com>
 <20260909072105.1663687-9-dhowells@redhat.com>
Date: Wed, 09 Sep 2026 18:02:12 -0300
Precedence: bulk
X-Mailing-List: linux-nfs@vger.kernel.org
List-Id: <linux-nfs.vger.kernel.org>
List-Subscribe: <mailto:linux-nfs+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:linux-nfs+unsubscribe@vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain

David Howells <dhowells@redhat.com> writes:

> Set subrequest->source in netfs_alloc_subrequest() before we emit the trace
> line indicating we allocated the subrequest.  Note that this requires the
> allocation of the subreq in netfs_read_to_pagecache() to be pushed to after
> the decision about what sort of subreq it should be.
>
> Signed-off-by: David Howells <dhowells@redhat.com>
> cc: Paulo Alcantara <pc@manguebit.org>
> cc: netfs@lists.linux.dev
> cc: linux-fsdevel@vger.kernel.org
> cc: linux-mm@kvack.org

Reviewed-by: Paulo Alcantara <pc@manguebit.org>
