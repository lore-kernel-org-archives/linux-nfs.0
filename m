From: "J. Bruce Fields" <bfields@fieldses.org>
Subject: Re: [pnfs] [PATCH v3 03/12] nfsd41: sunrpc: add new xprt class for
	nfsv4.1 backchannel
Date: Sun, 13 Sep 2009 16:28:21 -0400
Message-ID: <20090913202821.GD13109@fieldses.org>
References: <4AA8C597.8080809@panasas.com> <1252574732-30108-1-git-send-email-bhalevy@panasas.com> <4AA90E3A.80400@panasas.com> <20090911205821.GE5701@fieldses.org> <5e24e8930909111412r2c7bdc58u119767517154d6@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Cc: Benny Halevy <bhalevy@panasas.com>, linux-nfs@vger.kernel.org,
	pnfs@linux-nfs.org
To: Alexandros Batsakis <alexandros-4GNroTWusrE@public.gmane.org>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from fieldses.org ([174.143.236.118]:47318 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751719AbZIMU2U (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Sun, 13 Sep 2009 16:28:20 -0400
In-Reply-To: <5e24e8930909111412r2c7bdc58u119767517154d6-JsoAwUIsXosN+BqQ9rBEUg@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Fri, Sep 11, 2009 at 02:12:35PM -0700, Alexandros Batsakis wrote:
> On Fri, Sep 11, 2009 at 1:58 PM, J. Bruce Fields <bfields-uC3wQj2KruMpug/h7KTFAQ@public.gmane.org=
g> wrote:
> > On Thu, Sep 10, 2009 at 05:33:30PM +0300, Benny Halevy wrote:
> >> diff --git a/include/linux/sunrpc/xprtrdma.h b/include/linux/sunrp=
c/xprtrdma.h
> >> index 54a379c..c2f04e1 100644
> >> --- a/include/linux/sunrpc/xprtrdma.h
> >> +++ b/include/linux/sunrpc/xprtrdma.h
> >> @@ -41,11 +41,6 @@
> >> =C2=A0#define _LINUX_SUNRPC_XPRTRDMA_H
> >>
> >> =C2=A0/*
> >> - * RPC transport identifier for RDMA
> >> - */
> >> -#define XPRT_TRANSPORT_RDMA =C2=A0256
> >> -
> >> -/*
> >> =C2=A0 * rpcbind (v3+) RDMA netid.
> >> =C2=A0 */
> >> =C2=A0#define RPCBIND_NETID_RDMA =C2=A0 "rdma"
> >> diff --git a/include/linux/sunrpc/xprtsock.h b/include/linux/sunrp=
c/xprtsock.h
> >> index c2a46c4..d7c98d1 100644
> >> --- a/include/linux/sunrpc/xprtsock.h
> >> +++ b/include/linux/sunrpc/xprtsock.h
> >> @@ -20,8 +20,13 @@ void =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =
=C2=A0 cleanup_socket_xprt(void);
> >> =C2=A0 * values. No such restriction exists for new transports, ex=
cept that
> >> =C2=A0 * they may not collide with these values (17 and 6, respect=
ively).
> >> =C2=A0 */
> >> -#define XPRT_TRANSPORT_UDP =C2=A0 IPPROTO_UDP
> >> -#define XPRT_TRANSPORT_TCP =C2=A0 IPPROTO_TCP
> >> +#define XPRT_TRANSPORT_BC =C2=A0 =C2=A0(1 << 31)
> >> +enum xprt_transports {
> >> + =C2=A0 =C2=A0 XPRT_TRANSPORT_UDP =C2=A0 =C2=A0 =C2=A0=3D IPPROTO=
_UDP,
> >> + =C2=A0 =C2=A0 XPRT_TRANSPORT_TCP =C2=A0 =C2=A0 =C2=A0=3D IPPROTO=
_TCP,
> >> + =C2=A0 =C2=A0 XPRT_TRANSPORT_BC_TCP =C2=A0 =3D IPPROTO_TCP | XPR=
T_TRANSPORT_BC,
> >> + =C2=A0 =C2=A0 XPRT_TRANSPORT_RDMA =C2=A0 =C2=A0 =3D 256
> >> +};
> >
> > This fails to compile when CONFIG_SUNRPC_XPRT_RDMA is set.
> >
> > A minimal fix might be:
> >
> > =C2=A0 =C2=A0 =C2=A0 =C2=A0--- a/net/sunrpc/xprtrdma/transport.c
> > =C2=A0 =C2=A0 =C2=A0 =C2=A0+++ b/net/sunrpc/xprtrdma/transport.c
> > =C2=A0 =C2=A0 =C2=A0 =C2=A0@@ -50,6 +50,8 @@
> > =C2=A0 =C2=A0 =C2=A0 =C2=A0 #include <linux/module.h>
> > =C2=A0 =C2=A0 =C2=A0 =C2=A0 #include <linux/init.h>
> > =C2=A0 =C2=A0 =C2=A0 =C2=A0 #include <linux/seq_file.h>
> > =C2=A0 =C2=A0 =C2=A0 =C2=A0+#include <linux/in.h>
> > =C2=A0 =C2=A0 =C2=A0 =C2=A0+#include <linux/sunrpc/xprtsock.h>
> >
> > =C2=A0 =C2=A0 =C2=A0 =C2=A0 #include "xprt_rdma.h"
> >
> > Or maybe just ditch the enum and leave these as they were before.
> >
>=20
> The incentive here was to have all the transports definitions togethe=
r
> so that nobody re-uses a number by mistake (not very likely of
> course), so I think the fix you suggested is appropriate.

OK.  Actually, rather than adding a socket-specific include to an
rdma-specific file, how about the below?  Applying with the following
change assuming no objections.

--b.

diff --git a/include/linux/sunrpc/xprt.h b/include/linux/sunrpc/xprt.h
index 7cc42af..6f9457a 100644
--- a/include/linux/sunrpc/xprt.h
+++ b/include/linux/sunrpc/xprt.h
@@ -124,6 +124,23 @@ struct rpc_xprt_ops {
 	void		(*print_stats)(struct rpc_xprt *xprt, struct seq_file *seq);
 };
=20
+/*
+ * RPC transport identifiers
+ *
+ * To preserve compatibility with the historical use of raw IP protoco=
l
+ * id's for transport selection, UDP and TCP identifiers are specified
+ * with the previous values. No such restriction exists for new transp=
orts,
+ * except that they may not collide with these values (17 and 6,
+ * respectively).
+ */
+#define XPRT_TRANSPORT_BC       (1 << 31)
+enum xprt_transports {
+	XPRT_TRANSPORT_UDP	=3D IPPROTO_UDP,
+	XPRT_TRANSPORT_TCP	=3D IPPROTO_TCP,
+	XPRT_TRANSPORT_BC_TCP	=3D IPPROTO_TCP | XPRT_TRANSPORT_BC,
+	XPRT_TRANSPORT_RDMA	=3D 256
+};
+
 struct rpc_xprt {
 	struct kref		kref;		/* Reference count */
 	struct rpc_xprt_ops *	ops;		/* transport methods */
diff --git a/include/linux/sunrpc/xprtsock.h b/include/linux/sunrpc/xpr=
tsock.h
index d7c98d1..3f14a02 100644
--- a/include/linux/sunrpc/xprtsock.h
+++ b/include/linux/sunrpc/xprtsock.h
@@ -13,22 +13,6 @@ int		init_socket_xprt(void);
 void		cleanup_socket_xprt(void);
=20
 /*
- * RPC transport identifiers for UDP, TCP
- *
- * To preserve compatibility with the historical use of raw IP protoco=
l
- * id's for transport selection, these are specified with the previous
- * values. No such restriction exists for new transports, except that
- * they may not collide with these values (17 and 6, respectively).
- */
-#define XPRT_TRANSPORT_BC	(1 << 31)
-enum xprt_transports {
-	XPRT_TRANSPORT_UDP 	=3D IPPROTO_UDP,
-	XPRT_TRANSPORT_TCP 	=3D IPPROTO_TCP,
-	XPRT_TRANSPORT_BC_TCP 	=3D IPPROTO_TCP | XPRT_TRANSPORT_BC,
-	XPRT_TRANSPORT_RDMA	=3D 256
-};
-
-/*
  * RPC slot table sizes for UDP, TCP transports
  */
 extern unsigned int xprt_udp_slot_table_entries;
