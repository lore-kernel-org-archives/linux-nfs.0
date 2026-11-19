Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.remote-ip=170.10.133.124
ARC-Seal: i=1; d=subspace.kernel.org; s=arc20261015; a=rsa-sha256; cv=none;
	t=1795088973;
	b=UHUuaucyUbznRKJcuce/S0F+KGkTpCR7orxr5IYRyMQ3e7+hMVFIh/CyfmHPvWtXcuxA
	 9AaysJ4+0xxa/q1fJ8ryAFOYeJtelHJ5k4DMqusPI+YnRLDQLo3J+0n6SQnKUXrg/OE/4
	 pyoDLfpsHVYDCnRiVLRhQ8CsjpynP8bGaLPNmcn2eGHFNW/s03Fpwd/+0wtPEcORj9yhJ
	 Os0hgXGfVIwh5b82FSGduWmnD+SBOHWUZkqPISsXNwlLx3lWlXo3zolWwV8KujlySkn6J
	 sot6ZFCCdhs8OdAgVQ8tDktHT2EqRBo6MYiz72dPNNHChJrsYV1ybIoRry9KMB9JRyw==
ARC-Message-Signature: i=1; d=subspace.kernel.org; s=arc20261015;
	a=rsa-sha256; c=relaxed/relaxed; t=1795088973;
	h=DMARC-Filter:DKIM-Signature:Received:X-MC-Unique:
	 X-Mimecast-MFC-AGG-ID:Received:Received:Organization:In-Reply-To:
	 References:To:Cc:Subject:MIME-Version:Content-Type:Content-ID:
	 Content-Transfer-Encoding:From:Date:Message-ID:X-Scanned-By;
	bh=mDnX51SDsJdD3E0ns8PkWtEeSC5ZSzbEduD4fLsTeX4=;
	b=n1hyigOX7mk8LgeR05/hRxrZFPlEWAM5v/VojEbJZlZELnv6Rm0G2UNV1UKO/rotjLGX
	 ABRABpkJMhmj/rJ2pc6OpFPZ394t3U+m5bxwmf7Yqg03ykUrmnDG3Yvu5SG/SYC/60ZkT
	 0M7UzzE8mkgmpaPbpT1pmvr9iJ8E8cs9OXQlaQApOqN0YAXHYd9UZO49S2AIMfjc6U0xV
	 1ghAM5aS6kouGQMWfbUOmW95xCt3GjAJDxUrZBD+v531/Yq+caoz+mZPbIQ6FuU8G+W61
	 t2d9XaiVNXNKzCPBm4o/KDRh8goO5I0/eZWIDbd7VgrEgcd/c5ZoHhW4WGc+bX4e4oA==
ARC-Authentication-Results: i=1; smtp.subspace.kernel.org; 
	dmarc=pass header.from=redhat.com;
	spf=pass smtp.mailfrom=redhat.com;
	dkim=pass header.d=redhat.com header.i=@redhat.com header.a=rsa-sha256 header.s=mimecast20190719 header.b=JoQMIpVW;
	arc=none smtp.remote-ip=170.10.133.124
Received: from us-smtp-delivery-124.mimecast.com (us-smtp-delivery-124.mimecast.com [170.10.133.124])
	(using TLSv1.3 with cipher TLS_AES_256_GCM_SHA384 (256/256 bits)
	 key-exchange X25519 server-signature ECDSA (prime256v1) server-digest SHA256)
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 2E08D606A331
	for <linux-nfs@vger.kernel.org>; Thu, 19 Nov 2026 11:49:33 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.4.2 smtp.subspace.kernel.org 2E08D606A331
Authentication-Results: smtp.subspace.kernel.org; dmarc=pass (p=quarantine dis=none) header.from=redhat.com
Authentication-Results: smtp.subspace.kernel.org; spf=pass smtp.mailfrom=redhat.com
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (1024-bit key) header.d=redhat.com header.i=@redhat.com header.a=rsa-sha256 header.s=mimecast20190719 header.b=JoQMIpVW
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=redhat.com;
	s=mimecast20190719; t=1795088972;
	h=from:from:reply-to:subject:subject:date:date:message-id:message-id:
	 to:to:cc:cc:mime-version:mime-version:content-type:content-type:
	 content-transfer-encoding:content-transfer-encoding:
	 in-reply-to:in-reply-to:references:references;
	bh=mDnX51SDsJdD3E0ns8PkWtEeSC5ZSzbEduD4fLsTeX4=;
	b=JoQMIpVWkvMeGr6IcVKRgqmCQM2hLbqwKdT7pcn5Ugo0QZ6xsJNRNzyf56Vtw7KWJRIm/i
	BnMc1ef/NR3zMko7b7pOzh47rYIV+cBadDlcYgj7j8fpPOb94DXbH+umvowaDAh81dGgTS
	vOQUqPfX7D3BCbOmTokmIR699+SS34g=
Received: from mx-prod-mc-05.mail-002.prod.us-west-2.aws.redhat.com
 (ec2-54-186-198-63.us-west-2.compute.amazonaws.com [54.186.198.63]) by
 relay.mimecast.com with ESMTP with STARTTLS (version=TLSv1.3,
 cipher=TLS_AES_256_GCM_SHA384) id us-mta-194-stBv0V2IPZSPIYz6hREm5Q-1; Thu,
 19 Nov 2026 06:49:28 -0500
X-MC-Unique: stBv0V2IPZSPIYz6hREm5Q-1
X-Mimecast-MFC-AGG-ID: stBv0V2IPZSPIYz6hREm5Q_1795088966
Received: from mx-prod-int-08.mail-002.prod.us-west-2.aws.redhat.com (mx-prod-int-08.mail-002.prod.us-west-2.aws.redhat.com [10.30.177.111])
	(using TLSv1.3 with cipher TLS_AES_256_GCM_SHA384 (256/256 bits)
	 key-exchange X25519 server-signature RSA-PSS (2048 bits) server-digest SHA256)
	(No client certificate requested)
	by mx-prod-mc-05.mail-002.prod.us-west-2.aws.redhat.com (Postfix) with ESMTPS id E4FCC1955DCC;
	Thu, 19 Nov 2026 11:49:25 +0000 (UTC)
Received: from dhowells-thinkpadp1gen8.rmtgb.csb (headnet04.pony-001.prod.iad2.dc.redhat.com [10.2.32.116])
	by mx-prod-int-08.mail-002.prod.us-west-2.aws.redhat.com (Postfix) with ESMTP id D70A21801971;
	Thu, 19 Nov 2026 11:49:20 +0000 (UTC)
Organization: Red Hat UK Ltd. Registered Address: Red Hat UK Ltd, Amberley
	Place, 107-111 Peascod Street, Windsor, Berkshire, SI4 1TE, United
	Kingdom.
	Registered in England and Wales under Company Registration No. 3798903
In-Reply-To: <20261119083851.3306418-5-dhowells@redhat.com>
References: <20261119083851.3306418-5-dhowells@redhat.com> <20261119083851.3306418-1-dhowells@redhat.com>
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
    linux-kernel@vger.kernel.org, Christoph Hellwig <hch@infradead.org>
Subject: Re: [PATCH v19 04/17] netfs: Add some tools for managing bvecq chains
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
Content-ID: <3330734.1795088718.1@dhowells-thinkpadp1gen8.rmtgb.csb>
Content-Transfer-Encoding: quoted-printable
From: David Howells <dhowells@redhat.com>
Date: Thu, 19 Nov 2026 11:49:19 +0000
Message-ID: <3331436.1795088959@dhowells-thinkpadp1gen8.rmtgb.csb>
X-Scanned-By: MIMEDefang 3.4.1 on 10.30.177.111

Hi Christian,

If you pull this patch, can you apply the attached diff to it to fix some
issues that Sashiko brought up[1]?

- In bvecq_alloc_buffer2(), fix OOM discard where the requested number of
  pre-slots fills up a entire bvecq.

- In bvecq_alloc_buffer2(), add comment on why we want to exit the buffer
  alloc loop immediately.

- In bvecq_put(), clear the prev pointer of the next bvecq if it points
  back to the one being released.

- Fix bvecq_append() kdoc.

- Change %flags to @flags in function kdoc when referring to func arg.

Thanks,
David

[1] https://sashiko.dev/#/patchset/20261119083851.3306418-1-dhowells%40red=
hat.com
---
diff --git a/fs/netfs/bvecq.c b/fs/netfs/bvecq.c
index b140cd47a1fa..1b2ad42e6d50 100644
--- a/fs/netfs/bvecq.c
+++ b/fs/netfs/bvecq.c
@@ -61,7 +61,7 @@ EXPORT_SYMBOL(bvecq_dump);
  * that at least some progress can be made.
  *
  * Return: The node pointer or NULL on allocation failure.  BVECQ_HIT_OOM=
 is
- * set in *flags if an allocation failure occurs.
+ * set in *@flags if an allocation failure occurs.
  */
 struct bvecq *bvecq_alloc_one(size_t nr_slots, gfp_t gfp, unsigned int *f=
lags)
 {
@@ -136,10 +136,10 @@ EXPORT_SYMBOL(bvecq_alloc_one);
  *
  * Allocate a chain of bvecq nodes providing at least the requested cumul=
ative
  * number of slots.  Each node is a maximum of 4KiB in size.  If
- * %BVECQ_SHORT_OKAY is set in *%flags, then the chain may be shortened o=
n OOM.
+ * %BVECQ_SHORT_OKAY is set in *@flags, then the chain may be shortened o=
n OOM.
  *
  * Return: The first node pointer or NULL on allocation failure.  BVECQ_H=
IT_OOM
- * is set in *flags if an allocation failure occurs.
+ * is set in *@flags if an allocation failure occurs.
  */
 struct bvecq *bvecq_alloc_chain(size_t nr_slots, gfp_t gfp, unsigned int =
*flags)
 {
@@ -191,7 +191,7 @@ EXPORT_SYMBOL(bvecq_alloc_chain);
  * refcounts set to 1 and can be passed to MSG_SPLICE_PAGES.
  *
  * Return: The first node pointer or NULL on allocation failure.  BVECQ_H=
IT_OOM
- * is set in *flags if a bvecq chain allocation failure occurs (though if
+ * is set in *@flags if a bvecq chain allocation failure occurs (though i=
f
  * %BVECQ_SHORT_OKAY is set, the func may return early but will have at l=
east
  * one bvecq in the allocation).
  */
@@ -200,6 +200,7 @@ struct bvecq *bvecq_alloc_buffer2(size_t size, unsigne=
d int pre_slots, gfp_t gfp
 {
 	struct bvecq *head =3D NULL, *tail =3D NULL;
 	size_t count =3D pre_slots + DIV_ROUND_UP(size, PAGE_SIZE);
+	bool got_page =3D false;
 =

 	_enter("%zx,%zx,%u", size, count, pre_slots);
 =

@@ -258,7 +259,12 @@ struct bvecq *bvecq_alloc_buffer2(size_t size, unsign=
ed int pre_slots, gfp_t gfp
 =

 		bvecq_filled_to(tail, slot);
 		count -=3D got;
+		got_page =3D true;
 =

+		/* TODO: If we got an OOM trying to allocate a bvecq, we should
+		 * probably stop allocating pages unless/until we have an
+		 * emergency pool of those also.
+		 */
 		if (unlikely(*flags & BVECQ_HIT_OOM) && (*flags & BVECQ_SHORT_OKAY))
 			break;
 	} while (count > 0);
@@ -273,7 +279,9 @@ struct bvecq *bvecq_alloc_buffer2(size_t size, unsigne=
d int pre_slots, gfp_t gfp
 		bvecq_put(tail);
 	}
 oom:
-	if (!head || (tail =3D=3D head && head->nr_slots =3D=3D pre_slots))
+	if (!head)
+		goto out;
+	if (!got_page && size > 0)
 		goto discard; /* Allocated no pages */
 	if (*flags & BVECQ_SHORT_OKAY)
 		goto out;
@@ -328,6 +336,8 @@ void bvecq_put(struct bvecq *bq)
 		for (int slot =3D 0; slot < bq->nr_slots; slot++)
 			bvecq_free_slot(bq, slot);
 		next =3D bq->next;
+		if (next && next->prev =3D=3D bq)
+			next->prev =3D NULL;
 		netfs_stat_d(&netfs_n_bvecq);
 =

 		if (bq->from_pool !=3D BVECQ_USE_NO_POOL)
diff --git a/include/linux/bvecq.h b/include/linux/bvecq.h
index f670a031ac44..da2385c91e9a 100644
--- a/include/linux/bvecq.h
+++ b/include/linux/bvecq.h
@@ -162,7 +162,7 @@ static inline bool bvecq_acquire_slot(const struct bve=
cq *bvecq, unsigned int sl
 }
 =

 /**
- * bvecq_append - Get the next bvecq with appropriate barrier
+ * bvecq_append - Attach new bvecq to chain with appropriate barrier
  * @to: The bvecq to append to
  * @add: The bvecq to append
  *

