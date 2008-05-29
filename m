From: Benny Halevy <bhalevy@panasas.com>
Subject: [RFC] nfsd: make nfs4xdr WRITEMEM safe against zero count
Date: Thu, 29 May 2008 12:56:08 +0300
Message-ID: <483E7DB8.1050705@panasas.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: NFS list <linux-nfs@vger.kernel.org>
To: "J. Bruce Fields" <bfields@fieldses.org>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from ug-out-1314.google.com ([66.249.92.173]:21503 "EHLO
	ug-out-1314.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752760AbYE2J4O (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 29 May 2008 05:56:14 -0400
Received: by ug-out-1314.google.com with SMTP id h2so51380ugf.16
        for <linux-nfs@vger.kernel.org>; Thu, 29 May 2008 02:56:12 -0700 (PDT)
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

WRITEMEM zeroes the last word in the destination buffer
for padding purposes, but this must not be done if
no bytes are to be copied, as it would result
in zeroing of the word right before the array.

Signed-off-by: Benny Halevy <bhalevy@panasas.com>

--
The current implementation works since it's always called
with non zero nbytes or it follows an encoding of the
string (or opaque) length which, if equal to zero, 
can be overwritten with zero.

Another way of implementing that is the way it's done in
fs/nfsd/nfs4callback.c:

static inline __be32 *
xdr_writemem(__be32 *p, const void *ptr, int nbytes)
{
	int tmp = XDR_QUADLEN(nbytes);
	if (!tmp)
		return p;
	p[tmp-1] = 0;
	memcpy(p, ptr, nbytes);
	return p + tmp;
}

#define WRITEMEM(ptr,nbytes)     do {                           \
	p = xdr_writemem(p, ptr, nbytes);                       \
} while (0)

Also, is there any plan to clean up the xdr encoding definition
any time and define a cleaner static inline API?
I'd be happy to take a stab at it and come up with a
written and tested proposal.

Benny

git diff --stat -p
 fs/nfsd/nfs4xdr.c |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/fs/nfsd/nfs4xdr.c b/fs/nfsd/nfs4xdr.c
index e8e27fb..588c9f6 100644
--- a/fs/nfsd/nfs4xdr.c
+++ b/fs/nfsd/nfs4xdr.c
@@ -1712,7 +1712,7 @@ nfsd4_decode_compound(struct nfsd4_compoundargs *argp)
 	*p++ = htonl((u32)((n) >> 32));				\
 	*p++ = htonl((u32)(n));					\
 } while (0)
-#define WRITEMEM(ptr,nbytes)     do {				\
+#define WRITEMEM(ptr,nbytes)     do if (nbytes > 0) {		\
 	*(p + XDR_QUADLEN(nbytes) -1) = 0;                      \
 	memcpy(p, ptr, nbytes);					\
 	p += XDR_QUADLEN(nbytes);				\
