Received: from mail-pj2-f43.google.com (mail-pj2-f43.google.com [74.125.227.171])
	(using TLSv1.2 with cipher ECDHE-RSA-AES128-GCM-SHA256 (128/128 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id DDC0C3BCD3F
	for <linux-nfs@vger.kernel.org>; Thu, 24 Sep 2026 05:28:31 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=74.125.227.171
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1790227713; cv=none; b=BmLcmZ3ve5vBS7E/Nw6s18DULre9TODT7SS+nVntdKpm3HX9ctEHCLWec33wzjmDzGbAda94TDzxd0Li0CqtUBdVeNsA74SQcpmjZDh4FF+QvgEr8EmtPE18baMp+Et9j3K9XCTfY4mwmbnCBHRmPs3/AcTi0KFxG2AuBH0EgR8=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1790227713; c=relaxed/simple;
	bh=e+OZIelYvK/yW3MEYNdbbd+8AdKe0UgUkTq5M6EkYXU=;
	h=Message-ID:Date:From:To:Cc:Subject:Content-Type:MIME-Version; b=ub89tqMfBYkngK3mZf2tA9ql28idEpbR7Arc0XzYUYi+GBToqukfRroGA5TyRBq4zeqhQ61pEsKvWrUgZ+7qn40mWpG4VKc/B+PLFKpHMdKxhqeB5l9YYFJzza5Nn0HTynsFTcBsELYt8x0cSRWUdvDvjT5UbdYXcBVGpGkLIZw=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dmarc=pass (p=none dis=none) header.from=gmail.com; spf=pass smtp.mailfrom=gmail.com; dkim=pass (2048-bit key) header.d=gmail.com header.i=@gmail.com header.b=m2RGcCZJ; arc=none smtp.client-ip=74.125.227.171
Authentication-Results: smtp.subspace.kernel.org; dmarc=pass (p=none dis=none) header.from=gmail.com
Authentication-Results: smtp.subspace.kernel.org; spf=pass smtp.mailfrom=gmail.com
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=gmail.com header.i=@gmail.com header.b="m2RGcCZJ"
Received: by mail-pj2-f43.google.com with SMTP id 98e67ed59e1d1-39b2ad83dc6so1167863a91.0
        for <linux-nfs@vger.kernel.org>; Wed, 23 Sep 2026 22:28:31 -0700 (PDT)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=gmail.com; s=20251104; t=1790227711; x=1790832511; darn=vger.kernel.org;
        h=mime-version:content-transfer-encoding:content-type:subject:cc:to
         :from:date:message-id:from:to:cc:subject:date:message-id:reply-to
         :content-type;
        bh=lVN2eNiwwxk4TUWmm+W90XKndUi4LnNI4kBH4rOG7Hs=;
        b=m2RGcCZJWtObDBtyENX1FRl5PYejeuDiOON2r/UVbRUp4skoMLStgM7xhdFatFc62V
         MMy/C6xd3MoPM0Y1P23DvaZSGg2EleJy3n9m38sP0h7huv/V1b9khdkt9Plji+esulu7
         jrYoOg8kixb7i+lWf2Wn4RYQip9Ev5H1dzu32IpwBeSlNRL0vj0PZjBN+OT2pgRwV8L9
         LAb88uHV9qMq820+CD0amf20tHJ9poxHMevfw2WLbc0twH1fldgxwSFufeVF3JSwRdqN
         fSIAMW7jIFHDqhzV4CHawk695bnI6XpfZEg6c6ClVvPM9p/WXj4Lb/lZ7UKFgn9cjlfT
         y8GA==
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20260707; t=1790227711; x=1790832511;
        h=mime-version:content-transfer-encoding:content-type:subject:cc:to
         :from:date:message-id:x-gm-gg:x-gm-message-state:from:to:cc:subject
         :date:message-id:reply-to:content-type;
        bh=lVN2eNiwwxk4TUWmm+W90XKndUi4LnNI4kBH4rOG7Hs=;
        b=E8nBC+s1r9ePmyvrdVm4O4oZcEgYagpWGSySyr+N+Btj35KasgYFHErAIHvpNwWstv
         0sU5JbA3Mk9GNCKqentU5eRb7DqmBKWXGtDaI/DaM/JNg2LYqK++iBT0uUuYNMgiYJLN
         tLACPcOkHIl+ZTPxVtgAEJjFMF93IX91ZSWnGHvz5fzJe4uHlyVOP9HEqiR3r2p+ZYxe
         vP7Z7xRgfJjhCqe967IH7616lU5ydY+UpR3blIsy1x5LJ9sqX3T48oqJObIupJQBW56a
         FNP5VylZpPmk9orcvQbrZVv6V+7tLAMzouKpK4mqP6uYLFCj+hWIKW1FM7ZGBfcgNZJI
         YbYQ==
X-Gm-Message-State: AFuF++kDHuJnSDiOlsnU5LJbjBy+mQsmy8dhrxtp9cIONdK0HHYMF/5z
	3t+wV+n7LxxYFQDvjqhVxN73OBU08BI2BFeB5lB4nvbEimCb3Fs786d1naaCeNOedIsgzQ==
X-Gm-Gg: AYBFou3PPoENf1f6Y1ruyLigIJlKD11fg2uLbAoUU0Alyoi/mOpUmpoYceMkGo/Gyr/
	iBQ6jGJo4uJ3nuJjmu9qqc5/5V27ZneD3l9RrVijCh2awGCAwsPknce47FCwXAJLKjV42+GJy5p
	Cl5kq1MJ4x2FQsUC1ENa4nwjp+Y0sKSc4IDFDyGzVkJjQS1GdOCMfg9o/c7wbqPTlC853n27fbP
	Nub/0wQA0+2OaCFJ797quA8fExK1eBaf1P2mpaXVIBw2yx+evn/KKE7gRZhP1U/iiKx56bbQs28
	28VIdTgPgRbmXKcz00YjNNDtiYBxINoteHmNRKIEJlr8wvJcIvuTD8N2DVgd5vj6k/ZyUUmCMHe
	lc3VPO0ExDQUg1OUjCjwrZmSzTq/YUHYzmLO8RhUoCk7EvRR6Tdv/zw8uOtObqbPciig9I9kLxZ
	YUqUB4R7xNVzoZjnYzrsUZeMgq6OgFB3fKy7fxd4dqr6vNcXuswwaJC1q+FIOVZqAHE9CSiAdH2
	Y2h0C7KvthM3lk=
X-Received: by 2002:a17:90a:d643:b0:39e:6a7f:1dc7 with SMTP id 98e67ed59e1d1-3a098db98a7mr1203937a91.35.1790227711172;
        Wed, 23 Sep 2026 22:28:31 -0700 (PDT)
Received: from AiAgentServer.internal ([103.77.211.82])
        by smtp.gmail.com with ESMTPSA id 98e67ed59e1d1-3a096b8753csm2746079a91.0.2026.09.23.22.28.27
        (version=TLS1_3 cipher=TLS_AES_256_GCM_SHA384 bits=256/256);
        Wed, 23 Sep 2026 22:28:29 -0700 (PDT)
Message-ID: <6ab4b4fd.8f0cbdd2.2427cb.7612@mx.google.com>
Date: Wed, 23 Sep 2026 22:28:29 -0700 (PDT)
From: Chu Zhou <jack.wemmick@gmail.com>
To: linux-nfs@vger.kernel.org
Cc: trondmy@kernel.org, anna@kernel.org, cel@kernel.org, neil@brown.name,
 okorniev@redhat.com, Dai.Ngo@oracle.com, tom@talpey.com,
 stable@vger.kernel.org
Subject: [PATCH] SUNRPC: Validate TCP record marker length before trusting it
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: quoted-printable
Precedence: bulk
X-Mailing-List: linux-nfs@vger.kernel.org
List-Id: <linux-nfs.vger.kernel.org>
List-Subscribe: <mailto:linux-nfs+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:linux-nfs+unsubscribe@vger.kernel.org>
MIME-Version: 1.0

From: Chu Zhou <jack.wemmick@gmail.com>
Subject: [PATCH] SUNRPC: Validate TCP record marker length before trusting it

The SUNRPC/TCP receive parser trusts the 31-bit fragment length of the
record marker (RFC 5531) unconditionally. If the byte stream ever loses
framing sync - for example due to corruption below the RPC layer
(driver / checksum offload / DMA coherence bugs seen on embedded
platforms) or a malfunctioning peer - arbitrary payload bytes are
interpreted as a record marker, and the parser can latch onto a huge
bogus fragment length.

Observed in the field on an OrangePi 5 Plus (Rockchip RK3588) NFSv3/TCP
client: the parser latched onto reclen=3D0x4DB5ED05 (~1.24 GiB) and
entered the MSG_TRUNC discard path. From that point on, every genuine
reply was discarded as payload of the bogus fragment, with recv.offset
advancing one skb at a time toward a 1.24 GiB boundary that does not
exist in the stream. The TCP connection stayed ESTABLISHED and data
kept flowing, so no socket error or state change ever triggered a
transport reset, and record marking has no resynchronization mechanism.
All RPC tasks piled up in uninterruptible sleep until the hung task
watchdog panicked the machine. Restarting the NFS server (which tears
down the connection) was the only way to recover.

The set of legitimate fragment lengths has a hard upper bound: NFS over
TCP negotiates message sizes of at most 1 MiB (rsize/wsize). Treat any
length above 16 MiB (a generous 16x margin) as proof of framing desync,
emit a tracepoint that captures the parser state for post-mortem
analysis, and fail the read with -ESHUTDOWN so that the connection is
torn down and re-established by the existing transport reset machinery.

The check costs one comparison per fragment.

Fixes: 277e4ab7d530 ("SUNRPC: Simplify TCP receive code by switching to using=
 iterators")
Cc: stable@vger.kernel.org
Tested-by: Chu Zhou <jack.wemmick@gmail.com>
Signed-off-by: Chu Zhou <jack.wemmick@gmail.com>
---
 include/trace/events/sunrpc.h | 30 ++++++++++++++++++++++++++++++
 net/sunrpc/xprtsock.c         | 14 ++++++++++++++
 2 files changed, 44 insertions(+)

diff --git a/include/trace/events/sunrpc.h b/include/trace/events/sunrpc.h
index ff85519..d7e2b10 100644
--- a/include/trace/events/sunrpc.h
+++ b/include/trace/events/sunrpc.h
@@ -1370,6 +1370,36 @@ TRACE_EVENT(xs_stream_read_request,
 			__entry->copied, __entry->reclen, __entry->offset)
 );
=20
+TRACE_EVENT(xs_stream_bogus_marker,
+	TP_PROTO(const struct sock_xprt *xs),
+
+	TP_ARGS(xs),
+
+	TP_STRUCT__entry(
+		__string(addr, xs->xprt.address_strings[RPC_DISPLAY_ADDR])
+		__string(port, xs->xprt.address_strings[RPC_DISPLAY_PORT])
+		__field(u32, fraghdr)
+		__field(u32, xid)
+		__field(unsigned int, reclen)
+		__field(unsigned int, offset)
+		__field(long, copied)
+	),
+
+	TP_fast_assign(
+		__assign_str(addr);
+		__assign_str(port);
+		__entry->fraghdr =3D be32_to_cpu(xs->recv.fraghdr);
+		__entry->xid =3D be32_to_cpu(xs->recv.xid);
+		__entry->reclen =3D xs->recv.len;
+		__entry->offset =3D xs->recv.offset;
+		__entry->copied =3D (long)xs->recv.copied;
+	),
+
+	TP_printk("peer=3D[%s]:%s fraghdr=3D0x%08x reclen=3D%u xid=3D0x%08x offset=
=3D%u copied=3D%ld",
+		__get_str(addr), __get_str(port), __entry->fraghdr,
+		__entry->reclen, __entry->xid, __entry->offset, __entry->copied)
+);
+
 TRACE_EVENT(rpcb_getport,
 	TP_PROTO(
 		const struct rpc_clnt *clnt,
diff --git a/net/sunrpc/xprtsock.c b/net/sunrpc/xprtsock.c
index 7f60723..cd03dc6 100644
--- a/net/sunrpc/xprtsock.c
+++ b/net/sunrpc/xprtsock.c
@@ -80,6 +80,15 @@ static unsigned int xprt_max_resvport =3D RPC_DEF_MAX_RESV=
PORT;
 #define XS_TCP_LINGER_TO	(15U * HZ)
 static unsigned int xs_tcp_fin_timeout __read_mostly =3D XS_TCP_LINGER_TO;
=20
+/*
+ * Largest RPC record marker length we are prepared to trust.
+ * NFS over TCP negotiates message sizes of at most 1 MiB (rsize/wsize),
+ * so this leaves a generous margin. A larger value means the stream
+ * parser has lost framing sync; the only recovery is to reset the
+ * connection, since record marking has no resynchronization mechanism.
+ */
+#define XS_MAX_RECORD_LEN	(16U << 20)
+
 /*
  * We can register our own files under /proc/sys/sunrpc by
  * calling register_sysctl() again.  The files in that
@@ -713,6 +722,11 @@ xs_read_stream(struct sock_xprt *transport, int flags)
 			return transport->recv.offset;
 		transport->recv.len =3D be32_to_cpu(transport->recv.fraghdr) &
 			RPC_FRAGMENT_SIZE_MASK;
+		if (unlikely(transport->recv.len > XS_MAX_RECORD_LEN)) {
+			trace_xs_stream_bogus_marker(transport);
+			ret =3D -ESHUTDOWN;
+			goto out_err;
+		}
 		transport->recv.offset -=3D sizeof(transport->recv.fraghdr);
 		read =3D ret;
 	}
