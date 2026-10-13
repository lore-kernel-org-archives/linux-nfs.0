Received: from us-smtp-delivery-124.mimecast.com (us-smtp-delivery-124.mimecast.com [170.10.133.124])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id C2204397B1B
	for <linux-nfs@vger.kernel.org>; Tue, 13 Oct 2026 07:55:22 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=170.10.133.124
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1791878124; cv=none; b=WmXeOZPDBaD4ODSMbVu/hxCRAGhsyY+FEN8jysBBsRvxVIsPORm+JojQhMkCl5oQ5kRi+xxDk/AFOaCB8zBgmeK40CbZdKwR8e0y6xh5x3MtNtVgYcX0okrDHM1pBaUcFvms7IzdZGbll0SH1hWX+B/6Heo+P9vTq2NuqiFP6VU=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1791878124; c=relaxed/simple;
	bh=RPlfzWYmM8FirW88IjwmpVbxiR/zbaOepgou5oQs+ac=;
	h=From:In-Reply-To:References:To:Cc:Subject:MIME-Version:
	 Content-Type:Date:Message-ID; b=dbS9hquYMQpf8OOnd9wlCaycrcj3aiapyclXEKiTPP1RtZxTpJ1kbFLe0lL+haQNWpiUrxDJi19gUWbBzgHKewQcqlJMaaCP+JApy4FP9XlJTZiuVGcfGVkz4UeyTd2V6zFMV+LGo/zKj24diBBe4p/OR7r1zlf7eVb7wvzlwMU=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dmarc=pass (p=quarantine dis=none) header.from=redhat.com; spf=pass smtp.mailfrom=redhat.com; dkim=pass (1024-bit key) header.d=redhat.com header.i=@redhat.com header.b=gGj6PS0s; arc=none smtp.client-ip=170.10.133.124
Authentication-Results: smtp.subspace.kernel.org; dmarc=pass (p=quarantine dis=none) header.from=redhat.com
Authentication-Results: smtp.subspace.kernel.org; spf=pass smtp.mailfrom=redhat.com
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (1024-bit key) header.d=redhat.com header.i=@redhat.com header.b="gGj6PS0s"
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=redhat.com;
	s=mimecast20190719; t=1791878121;
	h=from:from:reply-to:subject:subject:date:date:message-id:message-id:
	 to:to:cc:cc:mime-version:mime-version:content-type:content-type:
	 content-transfer-encoding:content-transfer-encoding:
	 in-reply-to:in-reply-to:references:references;
	bh=CaDYtVwJjGFlT9vzY/XFr3IPNhGIGR2PZeK9wCQ1Tvk=;
	b=gGj6PS0sNj6RbN1b9VfhrFSHp5DMI3NECxrObVQdkpL/xYKOPxweqDiXSkhrjytJiiiiKo
	30HZSSqa0KSiLIzVyHItIX9enPcv3WImpQZdCKB0LjN5QF5o32zr6WUle3a/msB9YuQo2u
	RKeTL5Hare5HHYBaAmIQt9/4ol+JjMA=
Received: from mx-prod-mc-06.mail-002.prod.us-west-2.aws.redhat.com
 (ec2-35-165-154-97.us-west-2.compute.amazonaws.com [35.165.154.97]) by
 relay.mimecast.com with ESMTP with STARTTLS (version=TLSv1.3,
 cipher=TLS_AES_256_GCM_SHA384) id us-mta-58-rUZAsi6DMcieVbVMGWpCBQ-1; Tue,
 13 Oct 2026 07:55:12 +0000
X-MC-Unique: rUZAsi6DMcieVbVMGWpCBQ-1
X-Mimecast-MFC-AGG-ID: rUZAsi6DMcieVbVMGWpCBQ_1791878109
Received: from mx-prod-int-01.mail-002.prod.us-west-2.aws.redhat.com (mx-prod-int-01.mail-002.prod.us-west-2.aws.redhat.com [10.30.177.4])
	(using TLSv1.3 with cipher TLS_AES_256_GCM_SHA384 (256/256 bits)
	 key-exchange X25519 server-signature RSA-PSS (2048 bits) server-digest SHA256)
	(No client certificate requested)
	by mx-prod-mc-06.mail-002.prod.us-west-2.aws.redhat.com (Postfix) with ESMTPS id 972E618009D3;
	Tue, 13 Oct 2026 07:55:06 +0000 (UTC)
Received: from warthog.procyon.org.uk (unknown [10.44.48.11])
	by mx-prod-int-01.mail-002.prod.us-west-2.aws.redhat.com (Postfix) with ESMTP id 3345430001B9;
	Tue, 13 Oct 2026 07:54:59 +0000 (UTC)
Organization: Red Hat UK Ltd. Registered Address: Red Hat UK Ltd, Amberley
	Place, 107-111 Peascod Street, Windsor, Berkshire, SI4 1TE, United
	Kingdom.
	Registered in England and Wales under Company Registration No. 3798903
From: David Howells <dhowells@redhat.com>
In-Reply-To: <20261011.cachefiles-partial-zeros.pchmelar@innovatrics.com>
References: <20261011.cachefiles-partial-zeros.pchmelar@innovatrics.com> <20260910220242.2165023-1-dhowells@redhat.com> <20260910220242.2165023-5-dhowells@redhat.com>
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
Content-ID: <1655267.1791878098.1@warthog.procyon.org.uk>
Content-Transfer-Encoding: quoted-printable
Date: Tue, 13 Oct 2026 08:54:58 +0100
Message-ID: <1655268.1791878098@warthog.procyon.org.uk>
X-Scanned-By: MIMEDefang 3.4.1 on 10.30.177.4

Petr Chmelar <petr.chmelar@innovatrics.com> wrote:

> Reproducer: random 64 KiB reads covering half of a 256 MiB file of
> random data, then a full read after dropping the page cache, compared
> with the original per 64 KiB block:
> =

>   fio --name=3Dhalf --filename=3D/mnt/part.bin --rw=3Drandread --bs=3D64=
k \
>       --ioengine=3Dpsync --fadvise_hint=3Drandom --size=3D256m --io_size=
=3D128m \
>       --randrepeat=3D1
>   sync; echo 3 > /proc/sys/vm/drop_caches
>   cmp /mnt/part.bin /path/to/original

Unfortunately, I can't reproduce this.  Can you get me some tracing?

echo 65536 >/sys/kernel/tracing/buffer_size_kb
echo 1 >/sys/kernel/tracing/events/netfs/netfs_read/enable
echo 1 >/sys/kernel/tracing/events/netfs/netfs_write/enable
echo 1 >/sys/kernel/tracing/events/netfs/netfs_rreq/enable
echo 1 >/sys/kernel/tracing/events/netfs/netfs_sreq/enable
echo 1 >/sys/kernel/tracing/events/netfs/netfs_failure/enable
echo 1 >/sys/kernel/tracing/events/cachefiles/cachefiles_coherency/enable

before running, then after running do:

cat /sys/kernel/tracing/trace | bzip2 -9 >/tmp/cachefiles-bug.trace.bz2

When I do this and grep the trace output for 'WRITEBACK\|WRIT TERM\|cachef=
iles'
it all looks reasonable, looking something like:

fio-5895 : netfs_write: R=3D00001301 WRITEBACK c=3D00000006 o=3D00000004 i=
=3Dc6a742 by=3D0-ffffffffffffffff
fio-5895 : netfs_sreq: R=3D00001301[2] WRIT TERM  f=3D100 s=3D0 100000/100=
000 s=3D7 e=3D0
fio-5895 : netfs_sreq: R=3D00001301[4] WRIT TERM  f=3D100 s=3D100000 10000=
0/100000 s=3D15 e=3D0
fio-5895 : netfs_sreq: R=3D00001301[6] WRIT TERM  f=3D100 s=3D200000 10000=
0/100000 s=3D23 e=3D0
fio-5895 : netfs_sreq: R=3D00001301[8] WRIT TERM  f=3D100 s=3D300000 10000=
0/100000 s=3D0 e=3D0
fio-5895 : netfs_sreq: R=3D00001301[a] WRIT TERM  f=3D100 s=3D400000 10000=
0/100000 s=3D8 e=3D0
fio-5895 : netfs_sreq: R=3D00001301[c] WRIT TERM  f=3D100 s=3D500000 10000=
0/100000 s=3D16 e=3D0
fio-5895 : netfs_sreq: R=3D00001301[e] WRIT TERM  f=3D100 s=3D600000 10000=
0/100000 s=3D24 e=3D0
...
fio-5895 : netfs_sreq: R=3D00001301[1f4] WRIT TERM  f=3D100 s=3Df900000 10=
0000/100000 s=3D15 e=3D0
fio-5895 : netfs_sreq: R=3D00001301[1f6] WRIT TERM  f=3D100 s=3Dfa00000 10=
0000/100000 s=3D23 e=3D0
fio-5895 : netfs_sreq: R=3D00001301[1f8] WRIT TERM  f=3D100 s=3Dfb00000 10=
0000/100000 s=3D0 e=3D0
fio-5895 : netfs_sreq: R=3D00001301[1fa] WRIT TERM  f=3D100 s=3Dfc00000 10=
0000/100000 s=3D8 e=3D0
fio-5895 : netfs_sreq: R=3D00001301[1fc] WRIT TERM  f=3D100 s=3Dfd00000 10=
0000/100000 s=3D16 e=3D0
fio-5895 : netfs_sreq: R=3D00001301[1fe] WRIT TERM  f=3D100 s=3Dfe00000 10=
0000/100000 s=3D24 e=3D0
fio-5895 : netfs_sreq: R=3D00001301[200] WRIT TERM  f=3D100 s=3Dff00000 10=
0000/100000 s=3D1 e=3D0
 kworker : cachefiles_coherency: o=3D00000004 SET ok   B=3D46012e oz=3D100=
00000 c=3D2 aux=3D0 dsk=3D0

You can see the writes to the cache terminating and then the cache is set =
c=3D2
which is CACHEFILES_CONTENT_ALL indicating that the cache file has no hole=
s in
it.

That happens pretty much as soon as fio lays out its file and then all fut=
ure
accesses are just reads from the cache.

Looking at the UPLD lines is interesting:

fio-5895 : netfs_sreq: R=3D00001301[185] UPLD TERM  f=3D110 s=3Dc1fedd0 ff=
fe8/fffe8 s=3D8 e=3D0
fio-5895 : netfs_sreq: R=3D00001301[187] UPLD TERM  f=3D110 s=3Dc2fedb8 ff=
fe8/fffe8 s=3D16 e=3D0
fio-5895 : netfs_sreq: R=3D00001301[189] UPLD TERM  f=3D110 s=3Dc3feda0 ff=
fe8/fffe8 s=3D24 e=3D0
fio-5895 : netfs_sreq: R=3D00001301[18b] UPLD TERM  f=3D110 s=3Dc4fed88 ff=
fe8/fffe8 s=3D1 e=3D0

I guess 9P can't quite squeeze 1M of data in a packet as metadata has to g=
o in
as well.

One further question occurs to me: does the entire 256M file fit in the te=
st
VM's memory?

Thanks,
David

