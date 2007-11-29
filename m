From: Tom Tucker <tom@opengridcomputing.com>
Subject: [RFC,PATCH 7/8] rdma: makefile
Date: Thu, 29 Nov 2007 16:45:13 -0600
Message-ID: <20071129224513.14887.8074.stgit@dell3.ogc.int>
References: <20071129224412.14887.14136.stgit@dell3.ogc.int>
Content-Type: text/plain; charset=utf-8; format=fixed
Cc: linux-nfs@vger.kernel.org
To: bfields-ag9A2Eb6PFsgsBAKwltoeQ@public.gmane.org
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from 209-198-142-2-host.prismnet.net ([209.198.142.2]:48896 "EHLO
	smtp.opengridcomputing.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S933906AbXK2XDc (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 29 Nov 2007 18:03:32 -0500
In-Reply-To: <20071129224412.14887.14136.stgit-gUwIgmpLGaKNDNWfRnPdfg@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>


Add the NFSD_RDMA module to the sunrpc makefile.

Signed-off-by: Tom Tucker <tom@opengridcomputing.com>
---

 net/sunrpc/Makefile |    4 ++++
 1 files changed, 4 insertions(+), 0 deletions(-)

diff --git a/net/sunrpc/Makefile b/net/sunrpc/Makefile
index 92e1dbe..6d03dbf 100644
--- a/net/sunrpc/Makefile
+++ b/net/sunrpc/Makefile
@@ -15,3 +15,7 @@ sunrpc-y := clnt.o xprt.o socklib.o xprtsock.o sched.o \
 	    svc_xprt.o
 sunrpc-$(CONFIG_PROC_FS) += stats.o
 sunrpc-$(CONFIG_SYSCTL) += sysctl.o
+
+obj-$(CONFIG_NFSD_RDMA) += svcrdma.o
+svcrdma-y := svc_rdma.o svc_rdma_transport.o \
+	svc_rdma_marshal.o svc_rdma_sendto.o svc_rdma_recvfrom.o
