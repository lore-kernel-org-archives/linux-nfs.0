Received: from smtp.kernel.org (aws-us-west-2-korg-mail-alma10-1.taild15c8.ts.net [100.103.45.18])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 8ADB3306776;
	Tue, 11 Aug 2026 07:27:06 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=100.103.45.18
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1786433227; cv=none; b=GK4ADPMF+aXYIFVTG2TZOFycC2pZI7O0z66AQOtpT/WjV32Zrpvxuyxv/C6beG775tidR0vksfmAA0yM4lyzSoVGcULJIB9hus+jvhZKYZO9Bkqvxf/RI+CjAUZrtBRe01108htADRivZ3il/pBn454Ey9c/HNq79LuHhZo5MPM=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1786433227; c=relaxed/simple;
	bh=SbLo78Cr2HW2DkoM+Zu8uqrpTL6/jkg7YGLG/5Ws134=;
	h=MIME-Version:Content-Type:Subject:From:To:Cc:In-Reply-To:
	 References:Date:Message-Id; b=fQraOK32pApFCkl3sNbHYCw47sSuOGjFK5h6iQZqoUdB5BY+YxsyMy3k2psrs1le/s3jHdpqN/MfkOs0k6UKGszHLjfG+fFdlJxYrWr6gqZRs/5NaOXg6reW11Ia7sne7D2SXetxEavbA6whnbbluqCQ6cxANrEXvq++STT3J4E=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.b=jyhX1YFr; arc=none smtp.client-ip=100.103.45.18
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.b="jyhX1YFr"
Received: by smtp.kernel.org (Postfix) with ESMTPSA id 881E11F000E9;
	Tue, 11 Aug 2026 07:27:01 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=kernel.org;
	s=k20260515; t=1786433226;
	bh=K66bNXWEf3y6O/2oqZ+5XO0lv/SJwQqJyQa/tQNc0AA=;
	h=Subject:From:To:Cc:In-Reply-To:References:Date;
	b=jyhX1YFrrnq1wTxRvMX2adEyfpPN3v/LJ7/qtkjf+TYdWFsYYIcugMNXAPa+bsGb/
	 K/t7nFn3T7LYAgj/TynmyrcK3PZxbWxXlwHLiiQ/Y4kFCPNuv5IEcYsHUfdEiW+Pxp
	 2RhUyax+NkA0059s4IyvBX9JhRD7NVUe85TJCyjg2CMsC5MBqQh8WBd5CwGBSBdCdn
	 GQxT+li/hISZxCSp6HCFTAYrjNCgXdi7JRHv3tHOS34+Nlo8+p2FgK40/y3WWGPwhg
	 Nkpi9xSZrGb1Uc0q5QOmLvYqQAzyBiUYoHN0fp5YJ46Or6u9LTuAuZTuOub0fsdPN0
	 xQoweGsA1+/VA==
Precedence: bulk
X-Mailing-List: linux-nfs@vger.kernel.org
List-Id: <linux-nfs.vger.kernel.org>
List-Subscribe: <mailto:linux-nfs+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:linux-nfs+unsubscribe@vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Subject: Re: [PATCH v9 00/26] netfs: Keep track of folios in a segmented
 bio_vec[] chain
From: Christian Brauner <brauner@kernel.org>
To: Christoph Hellwig <hch@infradead.org>
Cc: David Howells <dhowells@redhat.com>, 
 Christian Brauner <christian@brauner.io>, 
 Matthew Wilcox <willy@infradead.org>, Paulo Alcantara <pc@manguebit.org>, 
 Jens Axboe <axboe@kernel.dk>, Leon Romanovsky <leon@kernel.org>, 
 Steve French <sfrench@samba.org>, 
 ChenXiaoSong <chenxiaosong@chenxiaosong.com>, 
 Marc Dionne <marc.dionne@auristor.com>, Stefan Metzmacher <metze@samba.org>, 
 Eric Van Hensbergen <ericvh@kernel.org>, 
 Dominique Martinet <asmadeus@codewreck.org>, 
 Ilya Dryomov <idryomov@gmail.com>, netfs@lists.linux.dev, 
 linux-afs@lists.infradead.org, linux-cifs@vger.kernel.org, 
 linux-nfs@vger.kernel.org, ceph-devel@vger.kernel.org, v9fs@lists.linux.dev, 
 linux-erofs@lists.ozlabs.org, linux-fsdevel@vger.kernel.org, 
 linux-kernel@vger.kernel.org
In-Reply-To: <annlWwsCPjNgcKa-@infradead.org>
References: <20260810144746.574036-1-dhowells@redhat.com>
 <annlWwsCPjNgcKa-@infradead.org>
Date: Tue, 11 Aug 2026 09:26:58 +0200
Message-Id: <20260811-wegkommen-unfehlbar-selektiert-547aaf3c775b@brauner>
X-Mailer: b4 0.17-dev-362b8
X-Developer-Signature: v=1; a=openpgp-sha256; l=600; i=brauner@kernel.org;
 h=from:subject:message-id; bh=SbLo78Cr2HW2DkoM+Zu8uqrpTL6/jkg7YGLG/5Ws134=;
 b=owGbwMvMwCU28Zj0gdSKO4sYT6slMWRVnTv6756TAWNwzpYbp6uPrDGo4imQ/fbk+jW7DUsuL
 b71cnIze0cpC4MYF4OsmCKLQ7tJuNxynorNRpkaMHNYmUCGMHBxCsBEFv5n+KftNFM8KmD21nd8
 72qdX0/+//vls7jriRGWqee6nD1evXJi+Kef+vzIchGNyFqW00a/fZW2Xk22O79bdrrI22h3iYi
 zz9gA
X-Developer-Key: i=brauner@kernel.org; a=openpgp;
 fpr=4880B8C9BD0E5106FC070F4F7B3C391EFEA93624

> this is a bad idea.  This is a giant series that also touches core code
> with no review whatsoever.  And I repeatedly asked for:

Since it's post the cut off point the series does not make the coming
merge window. It's also not in -next on purpose. The series was just
pulled for testing.

> 
>  1) the core changes to be split out
>  2) come up with users for this very core primitive in the hot path
>     (iov_iter) that are not just for your rather niche use case
> 
> There's been absolutely no follow on to this, and we should not treat
> the absolute core I/O path like this.

