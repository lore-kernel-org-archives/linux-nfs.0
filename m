Received: from mail-qv1-f52.google.com (mail-qv1-f52.google.com [209.85.219.52])
	(using TLSv1.2 with cipher ECDHE-RSA-AES128-GCM-SHA256 (128/128 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 2ADD352F276
	for <linux-nfs@vger.kernel.org>; Tue, 13 Oct 2026 18:02:56 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=209.85.219.52
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1791914580; cv=none; b=UTmeLFqQHTqbzd54g+4g66QOEtVRY4OO/xvEXQv7MSRXptZrmB5pGBBmh/tv64PeEqVIemCyl56KGYXgs5wu43UIF4UG97t9cleb/oPVrJ1V7IUkqaEa0k0mosG8MFcCDdQ6zw1HLUDc+IDpkkaz+GrSKotL1IIvb3tp+ygbDDA=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1791914580; c=relaxed/simple;
	bh=wBlk6u4aG2EVlQyPisgf3bspxRI3Odan0m/rs96yEjs=;
	h=From:Date:Subject:MIME-Version:Content-Type:Message-Id:To:Cc; b=OA+jFlfx7dJb697DFn8JseyBjSh3SkpFqFPrZ95LucJrJR5iGOWim2ZYhNEj91B4mw4xsBUj8iwIjx4jFKH/UhUKREupcP8i7Ykcjrj/pZAIVU+FZpS6SmN40tNM7cn75fR9S7MHcOZisCMmvIpu566QvvVqkOCuQ4A666U5Q6A=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dmarc=none (p=none dis=none) header.from=toxicpanda.com; spf=pass smtp.mailfrom=toxicpanda.com; dkim=pass (2048-bit key) header.d=toxicpanda.com header.i=@toxicpanda.com header.b=ZEa+04P7; arc=none smtp.client-ip=209.85.219.52
Authentication-Results: smtp.subspace.kernel.org; dmarc=none (p=none dis=none) header.from=toxicpanda.com
Authentication-Results: smtp.subspace.kernel.org; spf=pass smtp.mailfrom=toxicpanda.com
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=toxicpanda.com header.i=@toxicpanda.com header.b="ZEa+04P7"
Received: by mail-qv1-f52.google.com with SMTP id 6a1803df08f44-91b8b456dbeso20248406d6.2
        for <linux-nfs@vger.kernel.org>; Tue, 13 Oct 2026 11:02:56 -0700 (PDT)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=toxicpanda.com; s=google; t=1791914576; x=1792519376; darn=vger.kernel.org;
        h=cc:to:message-id:content-transfer-encoding:content-type
         :mime-version:subject:date:from:from:to:cc:subject:date:message-id
         :reply-to:content-type;
        bh=+hmJG7kWwVUskELoxr9dmPJXmwIZ8AA6DUhkJgvB+ls=;
        b=ZEa+04P7E05+KuSuek28IRqX+wKrrZO3y/NkzQ4sETO66NeC/0cwnzjv6gaoVoMdS6
         as8z2BU8J5ERl98pLqjWuij1drq3YkZ3YKxBV5YB1JRlDBuD/tVIG6v7ROaL75QlHkky
         wj5IX2XbKEteRXcJ2xEaxQtWvHknlrrzuFlmAtCTOXT5NoJwBfN/wa0EKn2UZFWiOAHR
         9wOsH5nYwCz9uAqy41PnIuJUT0qfbBppkE8P6G5AgcOyTqDldg30zsAHDygCAXxwXRUb
         nYrnpdiNjflqIiWCRzPzdnxfcyjZ1Rdrz5XxLjGSH8nd5NfuE7BHLbAyCcd6csSCV1mV
         LCKg==
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20260707; t=1791914576; x=1792519376;
        h=cc:to:message-id:content-transfer-encoding:content-type
         :mime-version:subject:date:from:x-gm-gg:x-gm-message-state:from:to
         :cc:subject:date:message-id:reply-to:content-type;
        bh=+hmJG7kWwVUskELoxr9dmPJXmwIZ8AA6DUhkJgvB+ls=;
        b=HBLdY4B//SLNmYoVpoV7KZxo1KsvAAlLiQlDhFVV3ypGyGvCCF82/Y4qW80zuI5dgV
         4YPl6Gizd9SPPgil8N6s1s1+M0FP9Phq+echSdvP3zdt9jWQE1AqKaajIDCKHnpZ7pQS
         JZGoE8cyO7zXrFYvJRAkU8BxZO68LESVUsDazA6SxcFLitvfT+ob+7US5ROJONqIejG1
         SthE2OGkgEn1EjikI7YCaSggdTemIQToGounwH4CxsXoGn4dLcypQATKR0eK/KxVmuu2
         yHErXEqMg8qpft9XIk+xPCMYfVG3dyvSNmmikA5SSp9/mnGcnMdR40pfMNZxLFMXtM9t
         1HuQ==
X-Forwarded-Encrypted: i=1; AKwUvBzg2sXDZD9Mxx0AEXtlEpI8Iviw9oTdSN3VVnFr5qKn0t79YaG1StNc1gdyVgkteOJPxxbYtP37e+Y=@vger.kernel.org
X-Gm-Message-State: AFq9FYKPLAfObbpPymb1enXFwQQT/XFtbMEqSX8wnnuylQzV/IAJTym1
	Hl3BpYfwwcnmHnpAtFHSepW3KoNXdO1/qc4fF6PaxzqvMeQWdsyFwahqPXkLiwEf5RERQ7uEsno
	XZp4h
X-Gm-Gg: AYBFou2JrVJhILnkUrMAAaC0ibyMsjXfsTpu8jilbbCmMgNIZTxuu+uG3r3on4Egylt
	iMmwvhW29bwYtHevXITzhauyzLzNSIU3UbeHB23M97Voo54UWBLjIZ9thOdUo6Ni1d2hwoP2pE5
	jGQgsMT+/P6ZWgv6OvFvZ3+oyxGqFaeHnPEfIBwqJ32H1HDKhpXNeXLLru9L+dMjCSM2iskYLbT
	b385I8GveBttux9jZ9XoDNmjYI1gywg1ur3LU9fR42LyIwCWv1tcRNNW/UPyugwDPpNncLWJtUu
	hnpD2U+QHnSSdTjyXroVsTpscLrWw4lzjFeNYnDgRzRrwxcDwRMabwKrpKb/fb1wrRjPXeC6H4L
	5G3hwivPJQfsgBxmytZKPGd5t92rwUwJ5UlfqOAmYMuaJ4VhwVXBZkiizgFc6LSBM8mx95R+u9Z
	ntiz7tkqvG0TWsAHiQAMUxznj4dOb7L4zW4DlcFyDdo/zWHm07Tl36JHoBAwB53TKxv0svLkPnM
	SW/V0sngvBekTw=
X-Received: by 2002:a05:6214:b6a:b0:91b:8e32:efdf with SMTP id 6a1803df08f44-91b8e32f30dmr83817526d6.41.1791914575403;
        Tue, 13 Oct 2026 11:02:55 -0700 (PDT)
Received: from toxicpanda.com ([153.61.196.249])
        by smtp.gmail.com with ESMTPSA id 6a1803df08f44-91b97b3bca7sm30846996d6.10.2026.10.13.11.02.54
        (version=TLS1_3 cipher=TLS_AES_256_GCM_SHA384 bits=256/256);
        Tue, 13 Oct 2026 11:02:54 -0700 (PDT)
From: Josef Bacik <josef@toxicpanda.com>
Date: Tue, 13 Oct 2026 18:02:44 +0000
Subject: [PATCH net v2] net: skbuff: make skb_copy_and_csum_bits() report
 unreadable frags
Precedence: bulk
X-Mailing-List: linux-nfs@vger.kernel.org
List-Id: <linux-nfs.vger.kernel.org>
List-Subscribe: <mailto:linux-nfs+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:linux-nfs+unsubscribe@vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Message-Id: <20261013-b4-skb-segment-nosg-unreadable-v2-1-6c28d8ffa51e@toxicpanda.com>
X-B4-Tracking: v=1; b=H4sIAERyzmoC/4WOSw7CMAxEr4K8xtCElt+KeyAWTuq24ZNUcahAq
 HenLaxhOU/2vHmBcHQssJ+9IHLnxAU/BD2fgW3I14yuHDLoTK9Vlm3R5CgXg8L1jX1CH6TGu49
 MJZkrI1GhN5aVUXkFQ0kbuXKPSXAEzwlOHyh3c2abxurxzJAwmkjeNiO6tkuTLyf4QzY+Nk5Si
 M9pf6cmy3fq7t/UTqHCDevVKqeiqHh7SOHhbEu+pIUNNzj1ff8G3KlniSEBAAA=
X-Change-ID: 20261008-b4-skb-segment-nosg-unreadable-aa527ce1b14f
To: Andrew Lunn <andrew+netdev@lunn.ch>, 
 "David S. Miller" <davem@davemloft.net>, Eric Dumazet <edumazet@kernel.org>, 
 Jakub Kicinski <kuba@kernel.org>, Paolo Abeni <pabeni@redhat.com>, 
 Simon Horman <horms@kernel.org>, David Ahern <dsahern@kernel.org>, 
 Ido Schimmel <idosch@nvidia.com>, Trond Myklebust <trondmy@kernel.org>, 
 Anna Schumaker <anna@kernel.org>, Chuck Lever <cel@kernel.org>, 
 Jeff Layton <jlayton@kernel.org>, NeilBrown <neil@brown.name>, 
 Olga Kornievskaia <okorniev@redhat.com>, Dai Ngo <Dai.Ngo@oracle.com>, 
 Tom Talpey <tom@talpey.com>, Josef Bacik <josef@toxicpanda.com>, 
 Mina Almasry <almasrymina@google.com>, Kaiyuan Zhang <kaiyuanz@google.com>, 
 Willem de Bruijn <willemb@google.com>
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org, 
 linux-nfs@vger.kernel.org, stable@vger.kernel.org
X-Mailer: b4 0.15.2
X-Developer-Signature: v=1; a=openssh-sha256; t=1791914572; l=13742;
 i=josef@toxicpanda.com; h=from:subject:message-id;
 bh=wBlk6u4aG2EVlQyPisgf3bspxRI3Odan0m/rs96yEjs=;
 b=U1NIU0lHAAAAAQAAADMAAAALc3NoLWVkMjU1MTkAAAAgUBr36M/n0nWN0DNbnxwzIiCZez6MG
 JiruuNaSCI/zXsAAAAGcGF0YXR0AAAAAAAAAAZzaGE1MTIAAABTAAAAC3NzaC1lZDI1NTE5AAAA
 QIqF05W7DA/gz1DPeLpctZ5GJfzMYz9pra+axIkjZgacwEhfL5KRs+lN/WqgaRArclYEfEwaQg/
 4VcRq6g6LfAU=
X-Developer-Key: i=josef@toxicpanda.com; a=openssh;
 fpr=SHA256:C8kOX2QUJCMqnCX+KEeoqRAjLo9L+ELOSH2NSAJHqGA

skb_copy_and_csum_bits() has no way to fail.  When it reaches
unreadable frags it zero-fills the rest of the buffer and returns 0,
and since commit ab9414ed70bd ("net: skbuff: don't leave stale bytes in
skb_copy_and_csum_bits()") that 0 is the correct checksum for what's in
the buffer.  Its callers can't tell the copy didn't happen.

That matters in the !sg && !csum branch of skb_segment().  A devmem TCP
skb keeps its whole payload in unreadable frags, so every segment ends
up with a payload of zeroes, tcp_gso_segment() writes a valid TCP
checksum over it, and the peer accepts the zeroes as stream data.  This
is reachable when both SG and TX checksum offload are turned off on a
device used for devmem TX: sk_setup_caps() still gives TCP SG and
HW_CSUM, so the dmabuf send is accepted, validate_xmit_unreadable_skb()
lets the skb through for a NETMEM_TX_NO_DMA device or a matching
binding, and software GSO segments it with neither feature.  Before
that commit the segments carried uninitialized memory with a checksum
that almost never matched.

Make skb_copy_and_csum_bits() return 0 or -EFAULT and hand the checksum
back through a pointer, and make it __must_check so a new caller can't
ignore the failure.  Each caller takes the error path it already has
for a failed copy:

 - skb_segment() fails the segmentation, as the csum branch already
   does when skb_copy_bits() fails.
 - icmp_glue_bits() and icmpv6_getfrag() return the error, so the ICMP
   error isn't sent.
 - __ip_append_data() and __ip6_append_data() drop the new skb and
   return -EFAULT, as they do when getfrag fails.
 - vnet_skb_shape() fails the same way it does when its skb_copy_bits()
   call fails.
 - xdr_skb_read_bits() returns 0 without consuming anything, as it does
   when skb_copy_bits() fails, so desc.count stays non-zero and
   csum_partial_copy_to_xdr() fails.  csum_partial_copy_to_xdr() used
   to checksum the bytes it hadn't copied before checking desc.count.
   desc.offset and desc.count always add up to skb->len, so that only
   ran when it was about to fail anyway, and on an unreadable skb
   skb_checksum() would WARN.  Drop it.
 - skb_copy_and_csum_dev() can't return an error, so it leaves the
   checksum alone and the frame goes out with a bad one.  Its callers
   are drivers that never see unreadable skbs anyway.

The zero-fill stays, so a caller that does send the buffer still
doesn't leak anything.

This was found by the Sashiko AI review of that commit, and
Mina suggested reporting the error from the helper rather than checking
for unreadable frags in skb_segment().

Fixes: ab9414ed70bd ("net: skbuff: don't leave stale bytes in skb_copy_and_csum_bits()")
Fixes: 65249feb6b3d ("net: add support for skbs with unreadable frags")
Link: https://lore.kernel.org/all/179148235783.434549.14322374227477832817@kernel.org/
Suggested-by: Mina Almasry <almasrymina@google.com>
Cc: stable@vger.kernel.org
Assisted-by: LLM
Signed-off-by: Josef Bacik <josef@toxicpanda.com>
---
v1: https://lore.kernel.org/all/20261009-b4-skb-segment-nosg-unreadable-v1-1-7e2334a55fe8@toxicpanda.com/

v1->v2:
- Report the failure from skb_copy_and_csum_bits() itself and handle it
  in every caller, instead of checking for unreadable frags up front in
  skb_segment() (Mina).
- Rebased onto current net.

Thanks,
Josef
---
 drivers/net/ethernet/sun/sunvnet_common.c | 10 +++--
 include/linux/skbuff.h                    |  4 +-
 net/core/skbuff.c                         | 61 ++++++++++++++++++++++---------
 net/ipv4/icmp.c                           |  9 +++--
 net/ipv4/ip_output.c                      | 11 ++++--
 net/ipv6/icmp.c                           |  7 +++-
 net/ipv6/ip6_output.c                     | 11 ++++--
 net/sunrpc/socklib.c                      |  9 ++---
 8 files changed, 82 insertions(+), 40 deletions(-)

diff --git a/drivers/net/ethernet/sun/sunvnet_common.c b/drivers/net/ethernet/sun/sunvnet_common.c
index 5cca95869052..4f229fcecc32 100644
--- a/drivers/net/ethernet/sun/sunvnet_common.c
+++ b/drivers/net/ethernet/sun/sunvnet_common.c
@@ -1167,9 +1167,13 @@ static inline struct sk_buff *vnet_skb_shape(struct sk_buff *skb, int ncookies)
 
 			/* copy the rest, with csum calculation */
 			*(__sum16 *)(skb->data + offset) = 0;
-			csum = skb_copy_and_csum_bits(skb, start,
-						      nskb->data + start,
-						      skb->len - start);
+			if (skb_copy_and_csum_bits(skb, start,
+						   nskb->data + start,
+						   skb->len - start, &csum)) {
+				dev_kfree_skb(nskb);
+				dev_kfree_skb(skb);
+				return NULL;
+			}
 
 			/* add in the header checksums */
 			if (skb->protocol == htons(ETH_P_IP)) {
diff --git a/include/linux/skbuff.h b/include/linux/skbuff.h
index a3ff380d43f0..542494fabbc4 100644
--- a/include/linux/skbuff.h
+++ b/include/linux/skbuff.h
@@ -4268,8 +4268,8 @@ void skb_free_datagram(struct sock *sk, struct sk_buff *skb);
 int skb_kill_datagram(struct sock *sk, struct sk_buff *skb, unsigned int flags);
 int skb_copy_bits(const struct sk_buff *skb, int offset, void *to, int len);
 int skb_store_bits(struct sk_buff *skb, int offset, const void *from, int len);
-__wsum skb_copy_and_csum_bits(const struct sk_buff *skb, int offset, u8 *to,
-			      int len);
+int __must_check skb_copy_and_csum_bits(const struct sk_buff *skb, int offset,
+					u8 *to, int len, __wsum *csum);
 int skb_splice_bits(struct sk_buff *skb, struct sock *sk, unsigned int offset,
 		    struct pipe_inode_info *pipe, unsigned int len,
 		    unsigned int flags);
diff --git a/net/core/skbuff.c b/net/core/skbuff.c
index 41beaf625421..9152448324f8 100644
--- a/net/core/skbuff.c
+++ b/net/core/skbuff.c
@@ -3611,14 +3611,27 @@ EXPORT_SYMBOL(skb_checksum);
 
 /* Both of above in one bottle. */
 
-__wsum skb_copy_and_csum_bits(const struct sk_buff *skb, int offset,
-				    u8 *to, int len)
+/**
+ *	skb_copy_and_csum_bits - copy data out of an skb and checksum it
+ *	@skb: source buffer
+ *	@offset: offset in @skb to start copying from
+ *	@to: destination buffer
+ *	@len: number of bytes to copy
+ *	@csump: where to store the checksum of the copied bytes
+ *
+ *	Return: 0 on success, or -EFAULT if @skb has unreadable frags.  On
+ *	failure *@csump is not set and the part of @to that couldn't be filled
+ *	is zeroed.
+ */
+int skb_copy_and_csum_bits(const struct sk_buff *skb, int offset,
+			   u8 *to, int len, __wsum *csump)
 {
 	int start = skb_headlen(skb);
 	int i, copy = start - offset;
 	struct sk_buff *frag_iter;
 	int pos = 0;
 	__wsum csum = 0;
+	int err;
 
 	/* Copy header. */
 	if (copy > 0) {
@@ -3627,7 +3640,7 @@ __wsum skb_copy_and_csum_bits(const struct sk_buff *skb, int offset,
 		csum = csum_partial_copy_nocheck(skb->data + offset, to,
 						 copy);
 		if ((len -= copy) == 0)
-			return csum;
+			goto out;
 		offset += copy;
 		to     += copy;
 		pos	= copy;
@@ -3637,7 +3650,7 @@ __wsum skb_copy_and_csum_bits(const struct sk_buff *skb, int offset,
 		/* Don't hand the caller a buffer with stale bytes in it. */
 		if (len > 0)
 			memset(to, 0, len);
-		return 0;
+		return -EFAULT;
 	}
 
 	for (i = 0; i < skb_shinfo(skb)->nr_frags; i++) {
@@ -3669,7 +3682,7 @@ __wsum skb_copy_and_csum_bits(const struct sk_buff *skb, int offset,
 			}
 
 			if (!(len -= copy))
-				return csum;
+				goto out;
 			offset += copy;
 			to     += copy;
 		}
@@ -3686,12 +3699,16 @@ __wsum skb_copy_and_csum_bits(const struct sk_buff *skb, int offset,
 		if ((copy = end - offset) > 0) {
 			if (copy > len)
 				copy = len;
-			csum2 = skb_copy_and_csum_bits(frag_iter,
-						       offset - start,
-						       to, copy);
+			err = skb_copy_and_csum_bits(frag_iter, offset - start,
+						     to, copy, &csum2);
+			if (err) {
+				/* The child zeroed its part; zero the rest. */
+				memset(to + copy, 0, len - copy);
+				return err;
+			}
 			csum = csum_block_add(csum, csum2, pos);
 			if ((len -= copy) == 0)
-				return csum;
+				goto out;
 			offset += copy;
 			to     += copy;
 			pos    += copy;
@@ -3699,7 +3716,9 @@ __wsum skb_copy_and_csum_bits(const struct sk_buff *skb, int offset,
 		start = end;
 	}
 	BUG_ON(len);
-	return csum;
+out:
+	*csump = csum;
+	return 0;
 }
 EXPORT_SYMBOL(skb_copy_and_csum_bits);
 
@@ -3964,9 +3983,13 @@ void skb_copy_and_csum_dev(const struct sk_buff *skb, u8 *to)
 	skb_copy_from_linear_data(skb, to, csstart);
 
 	csum = 0;
-	if (csstart != skb->len)
-		csum = skb_copy_and_csum_bits(skb, csstart, to + csstart,
-					      skb->len - csstart);
+	/* On failure the rest of @to is zeroed; leave the checksum alone so
+	 * the frame goes out with a bad one.
+	 */
+	if (csstart != skb->len &&
+	    skb_copy_and_csum_bits(skb, csstart, to + csstart,
+				   skb->len - csstart, &csum))
+		return;
 
 	if (skb->ip_summed == CHECKSUM_PARTIAL) {
 		long csstuff = csstart + skb->csum_offset;
@@ -4993,11 +5016,13 @@ struct sk_buff *skb_segment(struct sk_buff *head_skb,
 			if (!csum) {
 				if (!nskb->remcsum_offload)
 					nskb->ip_summed = CHECKSUM_NONE;
-				SKB_GSO_CB(nskb)->csum =
-					skb_copy_and_csum_bits(head_skb, offset,
-							       skb_put(nskb,
-								       len),
-							       len);
+				if (skb_copy_and_csum_bits(head_skb, offset,
+							   skb_put(nskb, len),
+							   len,
+							   &SKB_GSO_CB(nskb)->csum)) {
+					err = -EFAULT;
+					goto err;
+				}
 				SKB_GSO_CB(nskb)->csum_start =
 					skb_headroom(nskb) + doffset;
 			} else {
diff --git a/net/ipv4/icmp.c b/net/ipv4/icmp.c
index 90c0e22c29be..35008785e3d2 100644
--- a/net/ipv4/icmp.c
+++ b/net/ipv4/icmp.c
@@ -364,12 +364,15 @@ static int icmp_glue_bits(void *from, char *to, int offset, int len, int odd,
 	DEFINE_RAW_FLEX(struct icmp_bxm, icmp_param, replyopts.opt.__data,
 			IP_OPTIONS_DATA_FIXED_SIZE);
 	__wsum csum;
+	int err;
 
 	icmp_param = from;
 
-	csum = skb_copy_and_csum_bits(icmp_param->skb,
-				      icmp_param->offset + offset,
-				      to, len);
+	err = skb_copy_and_csum_bits(icmp_param->skb,
+				     icmp_param->offset + offset,
+				     to, len, &csum);
+	if (err)
+		return err;
 
 	skb->csum = csum_block_add(skb->csum, csum, odd);
 	if (icmp_param->data.icmph.type <= NR_ICMP_TYPES &&
diff --git a/net/ipv4/ip_output.c b/net/ipv4/ip_output.c
index eaa6fabda347..e3a927066f07 100644
--- a/net/ipv4/ip_output.c
+++ b/net/ipv4/ip_output.c
@@ -1162,9 +1162,14 @@ static int __ip_append_data(struct sock *sk,
 			data += fragheaderlen + exthdrlen;
 
 			if (fraggap) {
-				skb->csum = skb_copy_and_csum_bits(
-					skb_prev, maxfraglen,
-					data + transhdrlen, fraggap);
+				if (skb_copy_and_csum_bits(skb_prev, maxfraglen,
+							   data + transhdrlen,
+							   fraggap,
+							   &skb->csum)) {
+					err = -EFAULT;
+					kfree_skb(skb);
+					goto error;
+				}
 				skb_prev->csum = csum_sub(skb_prev->csum,
 							  skb->csum);
 				data += fraggap;
diff --git a/net/ipv6/icmp.c b/net/ipv6/icmp.c
index a95b0351824f..31ca3da80b1f 100644
--- a/net/ipv6/icmp.c
+++ b/net/ipv6/icmp.c
@@ -322,9 +322,12 @@ static int icmpv6_getfrag(void *from, char *to, int offset, int len, int odd, st
 	struct icmpv6_msg *msg = (struct icmpv6_msg *) from;
 	struct sk_buff *org_skb = msg->skb;
 	__wsum csum;
+	int err;
 
-	csum = skb_copy_and_csum_bits(org_skb, msg->offset + offset,
-				      to, len);
+	err = skb_copy_and_csum_bits(org_skb, msg->offset + offset,
+				     to, len, &csum);
+	if (err)
+		return err;
 	skb->csum = csum_block_add(skb->csum, csum, odd);
 	if (!(msg->type & ICMPV6_INFOMSG_MASK))
 		nf_ct_attach(skb, org_skb);
diff --git a/net/ipv6/ip6_output.c b/net/ipv6/ip6_output.c
index 550965058991..5c297d38eb8c 100644
--- a/net/ipv6/ip6_output.c
+++ b/net/ipv6/ip6_output.c
@@ -1724,9 +1724,14 @@ static int __ip6_append_data(struct sock *sk,
 			skb->transport_header = (skb->network_header +
 						 fragheaderlen);
 			if (fraggap) {
-				skb->csum = skb_copy_and_csum_bits(
-					skb_prev, maxfraglen,
-					data + transhdrlen, fraggap);
+				if (skb_copy_and_csum_bits(skb_prev, maxfraglen,
+							   data + transhdrlen,
+							   fraggap,
+							   &skb->csum)) {
+					err = -EFAULT;
+					kfree_skb(skb);
+					goto error;
+				}
 				skb_prev->csum = csum_sub(skb_prev->csum,
 							  skb->csum);
 				data += fraggap;
diff --git a/net/sunrpc/socklib.c b/net/sunrpc/socklib.c
index d8d8842c7de5..5d780ad4ae3a 100644
--- a/net/sunrpc/socklib.c
+++ b/net/sunrpc/socklib.c
@@ -49,7 +49,9 @@ xdr_skb_read_bits(struct xdr_skb_reader *desc, void *to, size_t len)
 	if (desc->need_checksum) {
 		__wsum csum;
 
-		csum = skb_copy_and_csum_bits(desc->skb, desc->offset, to, len);
+		if (unlikely(skb_copy_and_csum_bits(desc->skb, desc->offset,
+						    to, len, &csum)))
+			return 0;
 		desc->csum = csum_block_add(desc->csum, csum, desc->offset);
 	} else {
 		if (unlikely(skb_copy_bits(desc->skb, desc->offset, to, len)))
@@ -142,11 +144,6 @@ int csum_partial_copy_to_xdr(struct xdr_buf *xdr, struct sk_buff *skb)
 	desc.csum = csum_partial(skb->data, desc.offset, skb->csum);
 	if (xdr_partial_copy_from_skb(xdr, &desc) < 0)
 		return -1;
-	if (desc.offset != skb->len) {
-		__wsum csum2;
-		csum2 = skb_checksum(skb, desc.offset, skb->len - desc.offset, 0);
-		desc.csum = csum_block_add(desc.csum, csum2, desc.offset);
-	}
 	if (desc.count)
 		return -1;
 	if (csum_fold(desc.csum))

---
base-commit: af32da41b0327b9c6a37856ba82b6760d6c8d10e
change-id: 20261008-b4-skb-segment-nosg-unreadable-aa527ce1b14f

