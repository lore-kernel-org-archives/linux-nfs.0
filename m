Return-Path: <nfsv4-bounces@linux-nfs.org>
From: Olaf Kirch <okir@suse.de>
To: linux-nfs@vger.kernel.org
Subject: [PATCH 2/2] Introduce new helper function getpmaphandle
Date: Mon, 30 Aug 2010 15:04:57 +0200
References: <201008301503.19783.okir@suse.de> <201008301504.20634.okir@suse.de>
In-Reply-To: <201008301504.20634.okir@suse.de>
Message-Id: <201008301504.57459.okir@suse.de>
Cc: nfsv4@linux-nfs.org
List-Unsubscribe: <http://linux-nfs.org/cgi-bin/mailman/options/nfsv4>,
	<mailto:nfsv4-request@linux-nfs.org?subject=unsubscribe>
List-Archive: <http://linux-nfs.org/pipermail/nfsv4>
List-Post: <mailto:nfsv4@linux-nfs.org>
List-Help: <mailto:nfsv4-request@linux-nfs.org?subject=help>
List-Subscribe: <http://linux-nfs.org/cgi-bin/mailman/listinfo/nfsv4>,
	<mailto:nfsv4-request@linux-nfs.org?subject=subscribe>
Content-Type: text/plain; charset="iso-8859-1"
Sender: nfsv4-bounces@linux-nfs.org
Errors-To: nfsv4-bounces@linux-nfs.org
MIME-Version: 1.0
List-ID: <linux-nfs.vger.kernel.org>


From: Olaf Kirch <okir@suse.de>
Date: Mon, 23 Aug 2010 14:36:13 +0200
Subject: [PATCH] pmap_set/unset: allow compat functions to work with old-st=
yle=20
portmap

This change fixes a bug when running applications compiled against
libtirpc on a host with old-style portmap. Without this change, the
pmap_set/pmap_unset compatibility functions will actually be mapped
to a RPCB_SET/UNSET call. If the server does not support anything more
recent than PMAP, the operations will fail completely.

One choice to fix this problem would have been to reimplement just
pmap_set/pmap_unset. The alternative approach, which this patch
takes, it to make rpcb_set/unset default to the PMAP protocol when
changing an IPv4 registration.

Signed-off-by: Olaf Kirch <okir@suse.de>
---
 src/rpcb_clnt.c |   70=20
+++++++++++++++++++++++++++++++++++++++++++++++++++++++
 1 files changed, 70 insertions(+), 0 deletions(-)

diff --git a/src/rpcb_clnt.c b/src/rpcb_clnt.c
index 531c619..021525b 100644
--- a/src/rpcb_clnt.c
+++ b/src/rpcb_clnt.c
@@ -476,6 +476,65 @@ getpmaphandle(nconf, hostname, tgtaddr)
 #define IN4_LOCALHOST_STRING	"127.0.0.1"
 #define IN6_LOCALHOST_STRING	"::1"
=20
+#ifdef PORTMAP
+/*
+ * Perform a PMAP_SET or PMAP_UNSET call to the
+ * local rpcbind/portmap service.
+ */
+static bool_t
+pmap_setunset(pmapproc, program, version, nconf, address)
+	rpcproc_t pmapproc;
+	rpcprog_t program;
+	rpcvers_t version;
+	const struct netconfig *nconf;	/* Network structure of transport */
+	const struct netbuf *address;		/* Services netconfig address */
+{
+	CLIENT *client;
+	struct pmap pmapparms;
+	bool_t rslt =3D FALSE;
+	enum clnt_stat clnt_st;
+
+	if (strcmp(nconf->nc_protofmly, NC_INET) !=3D 0)
+		return (FALSE);
+
+	if (strcmp(nconf->nc_proto, NC_UDP) !=3D 0
+	 && strcmp(nconf->nc_proto, NC_TCP) !=3D 0)
+		return (FALSE);
+
+	pmapparms.pm_prog =3D program;
+	pmapparms.pm_vers =3D version;
+	pmapparms.pm_prot =3D strcmp(nconf->nc_proto, NC_TCP) ?  IPPROTO_UDP :=20
IPPROTO_TCP;
+	if (pmapproc =3D=3D PMAPPROC_UNSET) {
+		pmapparms.pm_port =3D 0;
+	} else {
+		if (address =3D=3D NULL)
+			return (FALSE);
+		pmapparms.pm_port =3D ntohs(((struct sockaddr_in *) address->buf)-
>sin_port);
+	}
+
+	client =3D getpmaphandle(nconf, IN4_LOCALHOST_STRING, NULL);
+	if (client =3D=3D NULL)
+		return (FALSE);
+
+	clnt_st =3D CLNT_CALL(client, pmapproc,
+	    (xdrproc_t) xdr_pmap, (caddr_t)(void *) &pmapparms,
+	    (xdrproc_t) xdr_bool, (caddr_t)(void *) &rslt,
+	    tottimeout);
+
+	if (clnt_st =3D=3D RPC_SUCCESS)
+		return rslt;
+
+	if (clnt_st !=3D RPC_PROGVERSMISMATCH &&
+	    clnt_st !=3D RPC_PROGUNAVAIL) {
+		rpc_createerr.cf_stat =3D RPC_PMAPFAILURE;
+		clnt_geterr(client, &rpc_createerr.cf_error);
+		return (FALSE);
+	}
+
+	return (TRUE);
+}
+#endif
+
 /*
  * This routine will return a client handle that is connected to the local
  * rpcbind. Returns NULL on error and free's everything.
@@ -600,6 +659,12 @@ rpcb_set(program, version, nconf, address)
 		rpc_createerr.cf_stat =3D RPC_UNKNOWNADDR;
 		return (FALSE);
 	}
+
+#ifdef PORTMAP
+	if (pmap_setunset(PMAPPROC_SET, program, version, nconf, address))
+		return (TRUE);
+#endif
+
 	client =3D local_rpcb();
 	if (! client) {
 		return (FALSE);
@@ -651,6 +716,11 @@ rpcb_unset(program, version, nconf)
 	RPCB parms;
 	char uidbuf[32];
=20
+#ifdef PORTMAP
+	if (pmap_setunset(PMAPPROC_UNSET, program, version, nconf, NULL))
+		return (TRUE);
+#endif
+
 	client =3D local_rpcb();
 	if (! client) {
 		return (FALSE);
--=20
1.6.0.2


--=20
Neo didn't bring down the Matrix. SOA did. (soafacts.com)
--------------------------------------------
Olaf Kirch - Director Server (okir@novell.com)
SUSE LINUX Products GmbH, Maxfeldstr. 5, D-90409 N=FCrnberg
GF: Markus Rex, HRB 16746 (AG N=FCrnberg)
_______________________________________________
NOTE: THIS LIST IS DEPRECATED.  Please use linux-nfs@vger.kernel.org instea=
d.
(To subscribe to linux-nfs@vger.kernel.org: send "subscribe linux-nfs" in t=
he body of a message to majordomo@vger.kernel.org.)

NFSv4 mailing list
NFSv4@linux-nfs.org
http://linux-nfs.org/cgi-bin/mailman/listinfo/nfsv4
