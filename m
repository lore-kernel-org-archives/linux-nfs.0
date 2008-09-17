From: Chuck Lever <chuck.lever@oracle.com>
Subject: [PATCH 07/10] lockd: Remove unused fields in the nlm_reboot structure
Date: Wed, 17 Sep 2008 11:18:04 -0500
Message-ID: <20080917161804.4963.71981.stgit@ellison.1015granger.net>
References: <20080917161337.4963.74674.stgit@ellison.1015granger.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Cc: linux-nfs@vger.kernel.org
To: bfields@fieldses.org
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from rgminet01.oracle.com ([148.87.113.118]:21640 "EHLO
	rgminet01.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754039AbYIQQYb (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Wed, 17 Sep 2008 12:24:31 -0400
In-Reply-To: <20080917161337.4963.74674.stgit-ewv44WTpT0t9HhUboXbp9zCvJB+x5qRC@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

The nlm_reboot structure is used to store information provided by the
NSM_NOTIFY procedure.  This procedure is not specified by the NLM or NSM
protocols, other than to say that the procedure can be used to transmit
information private to a particular NLM/NSM implementation.

For Linux, the callback arguments include the name of the monitored host,
the new NSM state of the host, and a 16-byte private opaque.

Linux encodes the monitored host's IP address into the opaque field.
Formerly, this field contained a 4-byte in_addr IPv4 address and the NSM
version and transport protocol used to contact the monitored host.
Recently this was changed so that the private field now contains the
4-byte IPv4 address and 12 bytes of zero.

As a clean up, remove the unused fields and the server-side XDR logic that
decodes them.

Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
---

 fs/lockd/xdr.c            |    2 --
 fs/lockd/xdr4.c           |    2 --
 include/linux/lockd/xdr.h |    2 --
 3 files changed, 0 insertions(+), 6 deletions(-)

diff --git a/fs/lockd/xdr.c b/fs/lockd/xdr.c
index 3e459e1..1f22629 100644
--- a/fs/lockd/xdr.c
+++ b/fs/lockd/xdr.c
@@ -351,8 +351,6 @@ nlmsvc_decode_reboot(struct svc_rqst *rqstp, __be32 *p, struct nlm_reboot *argp)
 	argp->state = ntohl(*p++);
 	/* Preserve the address in network byte order */
 	argp->addr = *p++;
-	argp->vers = *p++;
-	argp->proto = *p++;
 	return xdr_argsize_check(rqstp, p);
 }
 
diff --git a/fs/lockd/xdr4.c b/fs/lockd/xdr4.c
index 43ff939..50c493a 100644
--- a/fs/lockd/xdr4.c
+++ b/fs/lockd/xdr4.c
@@ -358,8 +358,6 @@ nlm4svc_decode_reboot(struct svc_rqst *rqstp, __be32 *p, struct nlm_reboot *argp
 	argp->state = ntohl(*p++);
 	/* Preserve the address in network byte order */
 	argp->addr  = *p++;
-	argp->vers  = *p++;
-	argp->proto = *p++;
 	return xdr_argsize_check(rqstp, p);
 }
 
diff --git a/include/linux/lockd/xdr.h b/include/linux/lockd/xdr.h
index df18fa0..d6b3a80 100644
--- a/include/linux/lockd/xdr.h
+++ b/include/linux/lockd/xdr.h
@@ -81,8 +81,6 @@ struct nlm_reboot {
 	unsigned int	len;
 	u32		state;
 	__be32		addr;
-	__be32		vers;
-	__be32		proto;
 };
 
 /*

