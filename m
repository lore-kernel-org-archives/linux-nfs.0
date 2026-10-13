Received: from us-smtp-delivery-124.mimecast.com (us-smtp-delivery-124.mimecast.com [170.10.129.124])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 83C7C3AAF76
	for <linux-nfs@vger.kernel.org>; Tue, 13 Oct 2026 08:14:23 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=170.10.129.124
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1791879265; cv=none; b=DWoOaanxDzV5k4sOn/FatC5drVZsGArXJWUdp2CCvwV1h5VghxnY1DifvFfwoBAsjH5D1eoL/WLY5XF2PZDWiNX4a0UE2D8uRCs0rEkm4MpuyX6mNcaPx0Jitbn/Rd3OiVdQdbCOTyeK2Go1IL6Ug6qAhQeVSKBWGmA9xaLW4MI=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1791879265; c=relaxed/simple;
	bh=/TsNlix0rD1la6imrvri2d2fqWkLRSA20dnSbOazxh0=;
	h=From:In-Reply-To:References:To:Cc:Subject:MIME-Version:
	 Content-Type:Date:Message-ID; b=UFeqq4oJownE7uJ97NSvC/C2n5XMZRis9o/Jg5rzvQQV+YEw17qD+caDP4iEuqBlm2ge/KVXZMNMZcZ+fVeT+MOLGAcs5pErQsLl8Qa+VZahuLeOcLvS8aI7oiYSI5xEeuVPg7sJresnE6Mj5coxJ+j0ksCj3XMwLOVtUawHmyQ=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dmarc=pass (p=quarantine dis=none) header.from=redhat.com; spf=pass smtp.mailfrom=redhat.com; dkim=pass (1024-bit key) header.d=redhat.com header.i=@redhat.com header.b=iloT7260; arc=none smtp.client-ip=170.10.129.124
Authentication-Results: smtp.subspace.kernel.org; dmarc=pass (p=quarantine dis=none) header.from=redhat.com
Authentication-Results: smtp.subspace.kernel.org; spf=pass smtp.mailfrom=redhat.com
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (1024-bit key) header.d=redhat.com header.i=@redhat.com header.b="iloT7260"
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=redhat.com;
	s=mimecast20190719; t=1791879262;
	h=from:from:reply-to:subject:subject:date:date:message-id:message-id:
	 to:to:cc:cc:mime-version:mime-version:content-type:content-type:
	 content-transfer-encoding:content-transfer-encoding:
	 in-reply-to:in-reply-to:references:references;
	bh=0rqjRqfF/5K2TERBFz32cqjmcGEc960K6cb/OYdJM6A=;
	b=iloT7260+fRXYsljf4hB4hG4M+hs1J+f839wpzcamsJNJIc4pdd5wCxJL0z13MvrC2EIH5
	kL1Kd9TqB9YPfUDgL8qqZKU9kI/0ZARb+wbHgT1j26mq7C3RU+kKf1KBzmOEFyVMtemraM
	c0UCujLdnJP9D0SZiZSjl6CrLNTpJlY=
Received: from mx-prod-mc-03.mail-002.prod.us-west-2.aws.redhat.com
 (ec2-54-186-198-63.us-west-2.compute.amazonaws.com [54.186.198.63]) by
 relay.mimecast.com with ESMTP with STARTTLS (version=TLSv1.3,
 cipher=TLS_AES_256_GCM_SHA384) id us-mta-15-W3Z3eWXuN-uipHnTTMh3Aw-1; Tue,
 13 Oct 2026 08:14:19 +0000
X-MC-Unique: W3Z3eWXuN-uipHnTTMh3Aw-1
X-Mimecast-MFC-AGG-ID: W3Z3eWXuN-uipHnTTMh3Aw_1791879256
Received: from mx-prod-int-05.mail-002.prod.us-west-2.aws.redhat.com (mx-prod-int-05.mail-002.prod.us-west-2.aws.redhat.com [10.30.177.17])
	(using TLSv1.3 with cipher TLS_AES_256_GCM_SHA384 (256/256 bits)
	 key-exchange X25519 server-signature RSA-PSS (2048 bits) server-digest SHA256)
	(No client certificate requested)
	by mx-prod-mc-03.mail-002.prod.us-west-2.aws.redhat.com (Postfix) with ESMTPS id 8FC411956055;
	Tue, 13 Oct 2026 08:14:15 +0000 (UTC)
Received: from warthog.procyon.org.uk (unknown [10.44.48.11])
	by mx-prod-int-05.mail-002.prod.us-west-2.aws.redhat.com (Postfix) with ESMTP id F30691956095;
	Tue, 13 Oct 2026 08:14:09 +0000 (UTC)
Organization: Red Hat UK Ltd. Registered Address: Red Hat UK Ltd, Amberley
	Place, 107-111 Peascod Street, Windsor, Berkshire, SI4 1TE, United
	Kingdom.
	Registered in England and Wales under Company Registration No. 3798903
From: David Howells <dhowells@redhat.com>
In-Reply-To: <20261011.cachefiles-seek-hole-walk.pchmelar@innovatrics.com>
References: <20261011.cachefiles-seek-hole-walk.pchmelar@innovatrics.com> <20260910220242.2165023-1-dhowells@redhat.com>
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
Subject: Re: [PATCH v12 0/5] netfs, cachefiles: Changes for next, primarily occupancy tracking-related
Precedence: bulk
X-Mailing-List: linux-nfs@vger.kernel.org
List-Id: <linux-nfs.vger.kernel.org>
List-Subscribe: <mailto:linux-nfs+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:linux-nfs+unsubscribe@vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-ID: <1655914.1791879248.1@warthog.procyon.org.uk>
Content-Transfer-Encoding: quoted-printable
Date: Tue, 13 Oct 2026 09:14:08 +0100
Message-ID: <1655915.1791879248@warthog.procyon.org.uk>
X-Scanned-By: MIMEDefang 3.0 on 10.30.177.17

Petr Chmelar <petr.chmelar@innovatrics.com> wrote:

> The cover letter leaves non-contiguous objects, which still use
> SEEK_DATA/SEEK_HOLE, for a later series.  We hit that case badly in
> production, so here are numbers in case they help with its priority.

I know.  But it's a tricky problem to solve as I need to store a map of th=
e
content somewhere.  xattrs are painful as I can only read or write them
atomically and as whole blobs - and also I'm not sure if I need to limit t=
he
size of any given xattr to 512 bytes.  Further, the xattr wangling interfa=
ce
inside the kernel assumes a flat virtual buffer rather than taking an I/O
iterator.

I have patches that store a bitmap in an xattr, with 1 bit per 256K block =
of
cachefile, for a 512 byte xattr able to map up to 1G of file size.  I need=
 to
revisit this at some point soon.  It may be better to switch to storing an
extent list, but:

> On our NFS clients (Ubuntu, v6.8, cache on XFS), a sequential read of a
> fully cached 184 GB object with 1,080,732 extents ran at 0.4 MB/s.

Trying to store a million+ extent records in a single xattr would kind of
suck.  Now, it might be possible to collapse that somewhat if a lot of the
extents are virtually sequential within the file, since I don't care about
physical sequentiality.

Also, can you tell if you have a preferred cache granularity?  Would a 256=
K
granularity, say, use too much space?

> I expect the right fix is for cachefiles to track what it has written
> itself, as CONTENT_ALL now does for contiguous files, rather than
> something like the above.

Indeed - as mentioned above.

> I can send the workaround if it's useful as a reference,

If you could, that would be great!

> and I'm happy to test whatever you plan for this case on our workload.

Thanks.  Now I just need to reproduce your bug.  Note that I posted anothe=
r
cachefiles patch that Christian hasn't picked up yet:

https://lore.kernel.org/linux-fsdevel/1091807.1791483394@warthog.procyon.o=
rg.uk/T/#u

David

