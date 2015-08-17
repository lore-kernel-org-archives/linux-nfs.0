Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from bombadil.infradead.org ([198.137.202.9]:52619 "EHLO
	bombadil.infradead.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755625AbbHQQGk (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 17 Aug 2015 12:06:40 -0400
Date: Mon, 17 Aug 2015 09:06:39 -0700
From: Christoph Hellwig <hch@infradead.org>
To: Chuck Lever <chuck.lever@oracle.com>
Cc: Steve Dickson <SteveD@redhat.com>,
        Linux NFS Mailing List <linux-nfs@vger.kernel.org>
Subject: Re: nfs-utils regression on IPv6-less kernels
Message-ID: <20150817160639.GA1173@infradead.org>
References: <20150810131358.GA19466@infradead.org>
 <55C9D2F2.1020300@RedHat.com>
 <20150817124220.GA17877@infradead.org>
 <F810C54A-A075-40D1-9912-80A85A7A0D63@oracle.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <F810C54A-A075-40D1-9912-80A85A7A0D63@oracle.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Mon, Aug 17, 2015 at 08:40:25AM -0700, Chuck Lever wrote:
> Probably stopped working with "rpc.nfsd: Squelch DNS errors when
> using --host option".
> 
> getaddrinfo(3) returns a list of addresses, some of which are
> IPv6 addresses. It gets the list from /etc/hosts, or DNS. Even
> on kernels which do not support IPv6, there may be at least one
> IPv6 address in the list.
> 
> nfssvc_setfds() then loops over this list. The error handling
> in nfssvc_setfds() causes the loop to exit if the socket(2)
> call fails. It should "continue" if the error is EAFNOSUPPORT.
> In fact, that xlog notice can also be removed.
> 
> I'm traveling this week. Is this enough for you to generate a
> fix?

Yes, that works:

---
From: Christoph Hellwig <hch@lst.de>
Subject: nfsd: ignore unsupported address types in nfssvc_setfds

Just continue and try a different record returned from getaddrinfo
if the kernel does not support an address family.  This fixes nfsd
startup on kernels without IPv6 support.

Suggested-by: Chuck Lever <chuck.lever@oracle.com>
Signed-off-by: Christoph Hellwig <hch@lst.de>

diff --git a/utils/nfsd/nfssvc.c b/utils/nfsd/nfssvc.c
index a2b11d8..fc11d23 100644
--- a/utils/nfsd/nfssvc.c
+++ b/utils/nfsd/nfssvc.c
@@ -174,15 +174,14 @@ nfssvc_setfds(const struct addrinfo *hints, const char *node, const char *port)
 		sockfd = socket(addr->ai_family, addr->ai_socktype,
 				addr->ai_protocol);
 		if (sockfd < 0) {
-			if (errno == EAFNOSUPPORT)
-				xlog(L_NOTICE, "address family %s not "
-						"supported by protocol %s",
-						family, proto);
-			else
+			if (errno != EAFNOSUPPORT) {
 				xlog(L_ERROR, "unable to create %s %s socket: "
 				     "errno %d (%m)", family, proto, errno);
-			rc = errno;
-			goto error;
+				rc = errno;
+				goto error;
+			}
+			addr = addr->ai_next;
+			continue;
 		}
 #ifdef IPV6_SUPPORTED
 		if (addr->ai_family == AF_INET6 &&
