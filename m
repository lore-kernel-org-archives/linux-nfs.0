From: Kevin Coffman <kwc@citi.umich.edu>
Subject: [enctypes round 3: PATCH 15/24] sunrpc: Export function
	write_bytes_to_xdr_buf
Date: Tue, 06 May 2008 17:04:48 -0400
Message-ID: <20080506210448.3770.40110.stgit@jazz.citi.umich.edu>
References: <20080506210156.3770.95914.stgit@jazz.citi.umich.edu>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Cc: linux-nfs@vger.kernel.org
To: bfields@fieldses.org
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from citi.umich.edu ([141.211.133.111]:34608 "EHLO citi.umich.edu"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1765953AbYEFVEs (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Tue, 6 May 2008 17:04:48 -0400
In-Reply-To: <20080506210156.3770.95914.stgit-zTNJhAanYLVZN1qrTdtDg5Vzexx5G7lz@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Implementation of the AES encryption for gss_krb5 needs to use
read_bytes_from_xdr_buf() and write_bytes_to_xdr_buf().
The read function is already exported.  Export the write function.

Signed-off-by: Kevin Coffman <kwc@citi.umich.edu>
---

 net/sunrpc/xdr.c |    1 +
 1 files changed, 1 insertions(+), 0 deletions(-)

diff --git a/net/sunrpc/xdr.c b/net/sunrpc/xdr.c
index 79a55d5..493c95c 100644
--- a/net/sunrpc/xdr.c
+++ b/net/sunrpc/xdr.c
@@ -761,6 +761,7 @@ int write_bytes_to_xdr_buf(struct xdr_buf *buf, unsigned int base, void *obj, un
 	__write_bytes_to_xdr_buf(&subbuf, obj, len);
 	return 0;
 }
+EXPORT_SYMBOL(write_bytes_to_xdr_buf);
 
 int
 xdr_decode_word(struct xdr_buf *buf, unsigned int base, u32 *obj)

