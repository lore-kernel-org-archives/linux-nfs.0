From: "J. Bruce Fields" <bfields@fieldses.org>
Subject: Re: [RFC,PATCH 0/8] RDMA Transport Provider
Date: Thu, 29 Nov 2007 23:45:53 -0500
Message-ID: <20071130044553.GA29851@fieldses.org>
References: <20071129224412.14887.14136.stgit@dell3.ogc.int>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Cc: bfields@fieldses.org, linux-nfs@vger.kernel.org
To: Tom Tucker <tom@opengridcomputing.com>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mail.fieldses.org ([66.93.2.214]:33806 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1761228AbXK3Ep7 (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Thu, 29 Nov 2007 23:45:59 -0500
In-Reply-To: <20071129224412.14887.14136.stgit-gUwIgmpLGaKNDNWfRnPdfg@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Thu, Nov 29, 2007 at 04:44:12PM -0600, Tom Tucker wrote:
> This patchset implements the RDMA Transport Driver for the=20
> SVC Transport Switch. This patchset has been tested with iozone
> and Connectathon over NFS v3.
>=20
> This patchset is against 2.6.24-rc3.
>=20
> This patchset along with the SVC transport switch and client
> side marshalling fix are also available in this git tree:
>=20
> git://linux-nfs.org/~tomtucker/nfs-rdma-dev-2.6.git
>=20
> --=20
> Signed-off-by: Tom Tucker <tom@opengridcomputing.com>
> -
> To unsubscribe from this list: send the line "unsubscribe linux-nfs" =
in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html

I still need the following to get it to compile.  Also, I'm getting
these warnings:

net/sunrpc/svc_rdma_transport.c: In function =E2=80=98dto_tasklet_func=E2=
=80=99:
net/sunrpc/svc_rdma_transport.c:232: warning: passing argument 2 of =E2=
=80=98test_and_clear_bit=E2=80=99 from incompatible pointer type
net/sunrpc/svc_rdma_transport.c:241: warning: passing argument 2 of =E2=
=80=98constant_test_bit=E2=80=99 from incompatible pointer type
net/sunrpc/svc_rdma_transport.c:241: warning: passing argument 2 of =E2=
=80=98variable_test_bit=E2=80=99 from incompatible pointer type
net/sunrpc/svc_rdma_transport.c:245: warning: passing argument 2 of =E2=
=80=98test_and_clear_bit=E2=80=99 from incompatible pointer type
net/sunrpc/svc_rdma_transport.c: In function =E2=80=98rq_comp_handler=E2=
=80=99:
net/sunrpc/svc_rdma_transport.c:271: warning: passing argument 2 of =E2=
=80=98set_bit=E2=80=99 from incompatible pointer type
net/sunrpc/svc_rdma_transport.c: In function =E2=80=98sq_comp_handler=E2=
=80=99:
net/sunrpc/svc_rdma_transport.c:382: warning: passing argument 2 of =E2=
=80=98set_bit=E2=80=99 from incompatible pointer type
net/sunrpc/svc_rdma_transport.c: In function =E2=80=98rdma_cma_handler=E2=
=80=99:
net/sunrpc/svc_rdma_transport.c:617: warning: passing argument 2 of =E2=
=80=98clear_bit=E2=80=99 from incompatible pointer type
net/sunrpc/svc_rdma_transport.c: In function =E2=80=98svc_rdma_accept=E2=
=80=99:
net/sunrpc/svc_rdma_transport.c:848: warning: passing argument 2 of =E2=
=80=98set_bit=E2=80=99 from incompatible pointer type

--b.


commit d128e461892e6aa5332e1b87d0f94eba4728ee90
Author: akpm@linux-foundation.org <akpm@linux-foundation.org>
Date:   Tue Nov 20 01:10:43 2007 -0800

    git-nfsd build fix
   =20
    From: Andrew Morton <akpm@linux-foundation.org>
   =20
    net/sunrpc/svcsock.c: In function 'svc_reclassify_socket':
    net/sunrpc/svcsock.c:100: error: 'struct sock' has no member named =
'sk_xprt'
   =20
    Cc: "J. Bruce Fields" <bfields@fieldses.org>
    Cc: Neil Brown <neilb@suse.de>
    Signed-off-by: Andrew Morton <akpm@linux-foundation.org>

diff --git a/net/sunrpc/svcsock.c b/net/sunrpc/svcsock.c
index 03207c9..2d0405a 100644
--- a/net/sunrpc/svcsock.c
+++ b/net/sunrpc/svcsock.c
@@ -97,7 +97,6 @@ static struct lock_class_key svc_slock_key[2];
 static inline void svc_reclassify_socket(struct socket *sock)
 {
 	struct sock *sk =3D sock->sk;
-	BUG_ON(sk->sk_xprt.xpt_lock.owner !=3D NULL);
 	switch (sk->sk_family) {
 	case AF_INET:
 		sock_lock_init_class_and_name(sk, "slock-AF_INET-NFSD",
