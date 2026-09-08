Received: from us-smtp-delivery-124.mimecast.com (us-smtp-delivery-124.mimecast.com [170.10.129.124])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 8EB5C52D2DA
	for <linux-nfs@vger.kernel.org>; Tue,  8 Sep 2026 09:11:29 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=170.10.129.124
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1788858691; cv=none; b=FY94Yf/cLG5MqkKWtPATDLgEYRxTTSBlX/2seeN+090VgJxPVpv815MC02WIi2XCAkkjoKm3Xuvul7HD7Xd3yZ2g40odAkecYfibmNImruxmMjY5hDdV2YqtpzpJwnJ2FlHC40dtmeOSIxid1VPYkAGHakitQlkjGfDQPS7VPjw=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1788858691; c=relaxed/simple;
	bh=0IkU36lM2/887n2GlIbcF98M1ZBi6/OJZliwRLEeR0s=;
	h=From:To:Cc:Subject:Date:Message-ID:In-Reply-To:References:
	 MIME-Version; b=KxB4eWbnmje8RrRKxbulW6kEDMHAWODs1RNbe+3kPKqvVMAgZKhOPe4eqGlciQQfRBoNY6mcVJMS1RSI59G60w1mcmAJIdyI+ISVM0ofkh/zoKLBX37VromHRNUsXcxYxF8HRd/vYhhUdRW+015lkP8Jd91JGNFWNAwFqaazsjk=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dmarc=pass (p=quarantine dis=none) header.from=redhat.com; spf=pass smtp.mailfrom=redhat.com; dkim=pass (1024-bit key) header.d=redhat.com header.i=@redhat.com header.b=bvaMYbud; arc=none smtp.client-ip=170.10.129.124
Authentication-Results: smtp.subspace.kernel.org; dmarc=pass (p=quarantine dis=none) header.from=redhat.com
Authentication-Results: smtp.subspace.kernel.org; spf=pass smtp.mailfrom=redhat.com
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (1024-bit key) header.d=redhat.com header.i=@redhat.com header.b="bvaMYbud"
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=redhat.com;
	s=mimecast20190719; t=1788858688;
	h=from:from:reply-to:subject:subject:date:date:message-id:message-id:
	 to:to:cc:cc:mime-version:mime-version:
	 content-transfer-encoding:content-transfer-encoding:
	 in-reply-to:in-reply-to:references:references;
	bh=p1mDwxZ1LnJ55G7jnnc/zLXcplu6e9EZLDtgfjC8YTQ=;
	b=bvaMYbuduu4eXj4bNture412HGwzDFb8FVvl43JTqvItaAnFRoVCN3NJnVX70AorhpfFZ9
	okbs5ruMp8gsEltdvbr0MNLR/xKbY5/LeeTO2OozJAdwLKAZCV+93hDpMNWBh26eK9U4eT
	YRttU57blNtlxLphZRu05kpnyF6QLw0=
Received: from mx-prod-mc-05.mail-002.prod.us-west-2.aws.redhat.com
 (ec2-54-186-198-63.us-west-2.compute.amazonaws.com [54.186.198.63]) by
 relay.mimecast.com with ESMTP with STARTTLS (version=TLSv1.3,
 cipher=TLS_AES_256_GCM_SHA384) id us-mta-115-F60ph6FVPQuYkopXnMhIOw-1; Tue,
 08 Sep 2026 05:11:24 -0400
X-MC-Unique: F60ph6FVPQuYkopXnMhIOw-1
X-Mimecast-MFC-AGG-ID: F60ph6FVPQuYkopXnMhIOw_1788858682
Received: from mx-prod-int-01.mail-002.prod.us-west-2.aws.redhat.com (mx-prod-int-01.mail-002.prod.us-west-2.aws.redhat.com [10.30.177.4])
	(using TLSv1.3 with cipher TLS_AES_256_GCM_SHA384 (256/256 bits)
	 key-exchange X25519 server-signature RSA-PSS (2048 bits) server-digest SHA256)
	(No client certificate requested)
	by mx-prod-mc-05.mail-002.prod.us-west-2.aws.redhat.com (Postfix) with ESMTPS id DD9941934485;
	Tue,  8 Sep 2026 09:11:21 +0000 (UTC)
Received: from warthog.com (unknown [10.44.32.158])
	by mx-prod-int-01.mail-002.prod.us-west-2.aws.redhat.com (Postfix) with ESMTP id 5743230001A2;
	Tue,  8 Sep 2026 09:11:16 +0000 (UTC)
From: David Howells <dhowells@redhat.com>
To: Paulo Alcantara <pc@manguebit.org>
Cc: David Howells <dhowells@redhat.com>,
	Christian Brauner <christian@brauner.io>,
	Matthew Wilcox <willy@infradead.org>,
	Namjae Jeon <linkinjeon@kernel.org>,
	Marc Dionne <marc.dionne@auristor.com>,
	Stefan Metzmacher <metze@samba.org>,
	Eric Van Hensbergen <ericvh@kernel.org>,
	Dominique Martinet <asmadeus@codewreck.org>,
	Ilya Dryomov <idryomov@gmail.com>,
	netfs@lists.linux.dev,
	linux-afs@lists.infradead.org,
	linux-cifs@vger.kernel.org,
	linux-nfs@vger.kernel.org,
	ceph-devel@vger.kernel.org,
	v9fs@lists.linux.dev,
	linux-erofs@lists.ozlabs.org,
	linux-fsdevel@vger.kernel.org,
	linux-kernel@vger.kernel.org
Subject: [PATCH v12 5/8] netfs: Add the cache object ID to netfs_read/write tracepoints
Date: Tue,  8 Sep 2026 10:10:26 +0100
Message-ID: <20260908091031.1506798-6-dhowells@redhat.com>
In-Reply-To: <20260908091031.1506798-1-dhowells@redhat.com>
References: <20260908091031.1506798-1-dhowells@redhat.com>
Precedence: bulk
X-Mailing-List: linux-nfs@vger.kernel.org
List-Id: <linux-nfs.vger.kernel.org>
List-Subscribe: <mailto:linux-nfs+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:linux-nfs+unsubscribe@vger.kernel.org>
MIME-Version: 1.0
Content-Transfer-Encoding: 8bit
X-Scanned-By: MIMEDefang 3.4.1 on 10.30.177.4

Add the cache object debug ID to netfs_read/write tracepoints to make
debugging easier as there's now a direct cross-reference with the
cachefiles tracepoints that only log that debug ID.

Signed-off-by: David Howells <dhowells@redhat.com>
Reviewed-by: Paulo Alcantara <pc@manguebit.org>
cc: netfs@lists.linux.dev
cc: linux-fsdevel@vger.kernel.org
---
 fs/cachefiles/io.c           |  1 +
 fs/netfs/fscache_io.c        |  2 +-
 include/linux/netfs.h        |  3 ++-
 include/trace/events/netfs.h | 27 +++++++++++++++------------
 4 files changed, 19 insertions(+), 14 deletions(-)

diff --git a/fs/cachefiles/io.c b/fs/cachefiles/io.c
index 7de8069d15b6..e61e885784d6 100644
--- a/fs/cachefiles/io.c
+++ b/fs/cachefiles/io.c
@@ -721,6 +721,7 @@ bool cachefiles_begin_operation(struct netfs_cache_resources *cres,
 
 	if (!cachefiles_cres_file(cres)) {
 		cres->ops = &cachefiles_netfs_cache_ops;
+		cres->object_id = object->debug_id;
 		if (object->file) {
 			spin_lock(&object->lock);
 			if (!cres->cache_priv2 && object->file)
diff --git a/fs/netfs/fscache_io.c b/fs/netfs/fscache_io.c
index 8bca63721eeb..056a2bae5d99 100644
--- a/fs/netfs/fscache_io.c
+++ b/fs/netfs/fscache_io.c
@@ -79,7 +79,7 @@ static int fscache_begin_operation(struct netfs_cache_resources *cres,
 	cres->ops		= NULL;
 	cres->cache_priv	= cookie;
 	cres->cache_priv2	= NULL;
-	cres->debug_id		= cookie->debug_id;
+	cres->cookie_id		= cookie->debug_id;
 	cres->inval_counter	= cookie->inval_counter;
 
 	if (!fscache_begin_cookie_access(cookie, why)) {
diff --git a/include/linux/netfs.h b/include/linux/netfs.h
index a3ef0e983a86..f2b3e61c1891 100644
--- a/include/linux/netfs.h
+++ b/include/linux/netfs.h
@@ -161,7 +161,8 @@ struct netfs_cache_resources {
 	const struct netfs_cache_ops	*ops;
 	void				*cache_priv;
 	void				*cache_priv2;
-	unsigned int			debug_id;	/* Cookie debug ID */
+	unsigned int			cookie_id;	/* Cache cookie debug ID */
+	unsigned int			object_id;	/* Cache object debug ID */
 	unsigned int			inval_counter;	/* object->inval_counter at begin_op */
 };
 
diff --git a/include/trace/events/netfs.h b/include/trace/events/netfs.h
index 21a661cd1ca4..c9ec4da97f0b 100644
--- a/include/trace/events/netfs.h
+++ b/include/trace/events/netfs.h
@@ -305,6 +305,7 @@ TRACE_EVENT(netfs_read,
 	    TP_STRUCT__entry(
 		    __field(unsigned int,		rreq)
 		    __field(unsigned int,		cookie)
+		    __field(unsigned int,		object)
 		    __field(uoff_t,			i_size)
 		    __field(uoff_t,			start)
 		    __field(size_t,			len)
@@ -314,7 +315,8 @@ TRACE_EVENT(netfs_read,
 
 	    TP_fast_assign(
 		    __entry->rreq	= rreq->debug_id;
-		    __entry->cookie	= rreq->cache_resources.debug_id;
+		    __entry->cookie	= rreq->cache_resources.cookie_id;
+		    __entry->object	= rreq->cache_resources.object_id;
 		    __entry->i_size	= rreq->i_size;
 		    __entry->start	= start;
 		    __entry->len	= len;
@@ -322,10 +324,10 @@ TRACE_EVENT(netfs_read,
 		    __entry->netfs_inode = rreq->inode->i_ino;
 			   ),
 
-	    TP_printk("R=%08x %s c=%08x ni=%llx s=%llx l=%zx sz=%llx",
+	    TP_printk("R=%08x %s c=%08x o=%08x ni=%llx s=%llx l=%zx sz=%llx",
 		      __entry->rreq,
 		      __print_symbolic(__entry->what, netfs_read_traces),
-		      __entry->cookie,
+		      __entry->cookie, __entry->object,
 		      __entry->netfs_inode,
 		      __entry->start, __entry->len, __entry->i_size)
 	    );
@@ -549,6 +551,7 @@ TRACE_EVENT(netfs_write,
 	    TP_STRUCT__entry(
 		    __field(unsigned int,		wreq)
 		    __field(unsigned int,		cookie)
+		    __field(unsigned int,		object)
 		    __field(unsigned int,		ino)
 		    __field(enum netfs_write_trace,	what)
 		    __field(uoff_t,			start)
@@ -556,20 +559,19 @@ TRACE_EVENT(netfs_write,
 			     ),
 
 	    TP_fast_assign(
-		    struct netfs_inode *__ctx = netfs_inode(wreq->inode);
-		    struct fscache_cookie *__cookie = netfs_i_cookie(__ctx);
 		    __entry->wreq	= wreq->debug_id;
-		    __entry->cookie	= __cookie ? __cookie->debug_id : 0;
+		    __entry->cookie	= wreq->cache_resources.cookie_id;
+		    __entry->object	= wreq->cache_resources.object_id;
 		    __entry->ino	= wreq->inode->i_ino;
 		    __entry->what	= what;
 		    __entry->start	= wreq->start;
 		    __entry->len	= wreq->len;
 			   ),
 
-	    TP_printk("R=%08x %s c=%08x i=%x by=%llx-%llx",
+	    TP_printk("R=%08x %s c=%08x o=%08x i=%x by=%llx-%llx",
 		      __entry->wreq,
 		      __print_symbolic(__entry->what, netfs_write_traces),
-		      __entry->cookie,
+		      __entry->cookie, __entry->object,
 		      __entry->ino,
 		      __entry->start, __entry->start + __entry->len - 1)
 	    );
@@ -584,22 +586,23 @@ TRACE_EVENT(netfs_copy2cache,
 		    __field(unsigned int,	rreq)
 		    __field(unsigned int,	creq)
 		    __field(unsigned int,	cookie)
+		    __field(unsigned int,	object)
 		    __field(unsigned int,	ino)
 			     ),
 
 	    TP_fast_assign(
-		    struct netfs_inode *__ctx = netfs_inode(rreq->inode);
-		    struct fscache_cookie *__cookie = netfs_i_cookie(__ctx);
 		    __entry->rreq	= rreq->debug_id;
 		    __entry->creq	= creq->debug_id;
-		    __entry->cookie	= __cookie ? __cookie->debug_id : 0;
+		    __entry->cookie	= rreq->cache_resources.cookie_id;
+		    __entry->object	= rreq->cache_resources.object_id;
 		    __entry->ino	= rreq->inode->i_ino;
 			   ),
 
-	    TP_printk("R=%08x CR=%08x c=%08x i=%x ",
+	    TP_printk("R=%08x CR=%08x c=%08x o=%08x i=%x ",
 		      __entry->rreq,
 		      __entry->creq,
 		      __entry->cookie,
+		      __entry->object,
 		      __entry->ino)
 	    );
 

