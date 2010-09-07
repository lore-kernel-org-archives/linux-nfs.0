Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from cantor.suse.de ([195.135.220.2]:47057 "EHLO mx1.suse.de"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755743Ab0IGL1K convert rfc822-to-8bit (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Tue, 7 Sep 2010 07:27:10 -0400
From: Olaf Kirch <okir@suse.de>
To: Chuck Lever <chuck.lever@oracle.com>
Subject: Re: [PATCH 0/2] Make libtirpc work with old style portmapper
Date: Tue, 7 Sep 2010 13:27:07 +0200
Cc: linux-nfs@vger.kernel.org, nfsv4@linux-nfs.org,
        Steve Dickson <SteveD@redhat.com>
References: <201008301503.19783.okir@suse.de> <201008301819.18773.okir@suse.de> <42F5CE2D-786B-464F-A6B7-D14FBF963F99@oracle.com>
In-Reply-To: <42F5CE2D-786B-464F-A6B7-D14FBF963F99@oracle.com>
Content-Type: Text/Plain;
  charset="iso-8859-1"
Message-Id: <201009071327.07291.okir@suse.de>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

On Tuesday 31 August 2010 01:48:02 Chuck Lever wrote:
> On Aug 30, 2010, at 12:19 PM, Olaf Kirch wrote:
> > On Monday 30 August 2010 17:59:18 Chuck Lever wrote:
> >> Another minor problem I think I remember is that if libtirpc is used on
> >> a system (perhaps because it is statically linked with said ISV
> >> RPC-enabled application) that does not have /etc/netconfig installed,
> >> the transport creation logic in rpcb_clnt.c simply doesn't work.
> >
> > Well, but that's something that's fixed easily - we can always tell
> > such customer to install an /etc/netconfig on their system.
> 
> Agreed, but for various reasons, the symptoms don't necessarily immediately
>  imply what is needed to correct the problem.

I've updated the second patch, which now modifies pmap_set/unset
directly, without messing with the functionality of rpbc_set/unset.
With this change, the compatibility functions (pmap_{,un}set) will
first try the old API and then fall through to the new rpcbind
interface.

Olaf
-- 
Neo didn't bring down the Matrix. SOA did. (soafacts.com)
--------------------------------------------
Olaf Kirch - Director Server (okir@novell.com)
SUSE LINUX Products GmbH, Maxfeldstr. 5, D-90409 Nürnberg
GF: Markus Rex, HRB 16746 (AG Nürnberg)
-----------------------------

commit 30feadb3ae5a8d001aabc44f8ddad44298ec61a2
Author: Olaf Kirch <okir@suse.de>
Date:   Mon Aug 23 14:36:13 2010 +0200

    pmap_set/unset: allow compat functions to work with old-style portmap
    
    This change fixes a bug when running applications compiled against
    libtirpc on a host with old-style portmap. Without this change, the
    pmap_set/pmap_unset compatibility functions will actually be mapped
    to a RPCB_SET/UNSET call. If the server does not support anything more
    recent than PMAP, the operations will fail completely.
    
    This fix makes pmap_set/unset try the old portmapper functions
    first, and if those fail, try to fall back to the new rpcbind
    interface.
    
    Signed-off-by: Olaf Kirch <okir@suse.de>

diff --git a/src/pmap_clnt.c b/src/pmap_clnt.c
index 1d5d153..24cf94a 100644
--- a/src/pmap_clnt.c
+++ b/src/pmap_clnt.c
@@ -58,6 +58,10 @@ pmap_set(u_long program, u_long version, int protocol, int 
port)
 	struct netconfig *nconf;
 	char buf[32];
 
+#ifdef PORTMAP
+	if (__pmap_set(program, version, protocol, port))
+		return (TRUE);
+#endif
 	if ((protocol != IPPROTO_UDP) && (protocol != IPPROTO_TCP)) {
 		return (FALSE);
 	}
@@ -89,6 +93,11 @@ pmap_unset(u_long program, u_long version)
 	bool_t udp_rslt = FALSE;
 	bool_t tcp_rslt = FALSE;
 
+#ifdef PORTMAP
+	if (__pmap_set(program, version, IPPROTO_UDP, 0)
+	 && __pmap_set(program, version, IPPROTO_TCP, 0))
+		return (TRUE);
+#endif
 	nconf = __rpc_getconfip("udp");
 	if (nconf != NULL) {
 		udp_rslt = rpcb_unset((rpcprog_t)program, (rpcvers_t)version,
diff --git a/src/rpc_com.h b/src/rpc_com.h
index 38c2cfe..0a20a01 100644
--- a/src/rpc_com.h
+++ b/src/rpc_com.h
@@ -86,6 +86,9 @@ bool_t __xdrrec_getrec(XDR *, enum xprt_stat *, bool_t);
 void __xprt_unregister_unlocked(SVCXPRT *);
 void __xprt_set_raddr(SVCXPRT *, const struct sockaddr_storage *);
 
+#ifdef PORTMAP
+bool_t __pmap_set(rpcprog_t, rpcvers_t, int protocol, int port);
+#endif
 
 SVCXPRT **__svc_xports;
 int __svc_maxrec;
diff --git a/src/rpcb_clnt.c b/src/rpcb_clnt.c
index 531c619..9562646 100644
--- a/src/rpcb_clnt.c
+++ b/src/rpcb_clnt.c
@@ -476,6 +476,55 @@ getpmaphandle(nconf, hostname, tgtaddr)
 #define IN4_LOCALHOST_STRING	"127.0.0.1"
 #define IN6_LOCALHOST_STRING	"::1"
 
+#ifdef PORTMAP
+/*
+ * Perform a PMAP_SET or PMAP_UNSET call to the
+ * local rpcbind/portmap service.
+ */
+bool_t
+__pmap_set(program, version, protocol, port)
+	rpcprog_t program;
+	rpcvers_t version;
+	int protocol;
+	int port;
+{
+	CLIENT *client;
+	rpcproc_t pmapproc;
+	struct pmap pmapparms;
+	bool_t rslt = FALSE;
+	enum clnt_stat clnt_st;
+
+	/* Arguments should already have been checked by caller */
+
+	pmapproc = port? PMAPPROC_SET : PMAPPROC_UNSET;
+	pmapparms.pm_prog = program;
+	pmapparms.pm_vers = version;
+	pmapparms.pm_prot = protocol;
+	pmapparms.pm_port = port;
+
+	client = getpmaphandle(NULL, IN4_LOCALHOST_STRING, NULL);
+	if (client == NULL)
+		return (FALSE);
+
+	clnt_st = CLNT_CALL(client, pmapproc,
+	    (xdrproc_t) xdr_pmap, (caddr_t)(void *) &pmapparms,
+	    (xdrproc_t) xdr_bool, (caddr_t)(void *) &rslt,
+	    tottimeout);
+
+	if (clnt_st == RPC_SUCCESS)
+		return rslt;
+
+	if (clnt_st != RPC_PROGVERSMISMATCH &&
+	    clnt_st != RPC_PROGUNAVAIL) {
+		rpc_createerr.cf_stat = RPC_PMAPFAILURE;
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
