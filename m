Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:44757 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750800Ab0LOFJD (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Wed, 15 Dec 2010 00:09:03 -0500
Date: Wed, 15 Dec 2010 14:09:01 +0900
From: Takuma Umeya <tumeya@redhat.com>
To: linux-nfs@vger.kernel.org
Cc: linux-kernel@vger.kernel.org
Subject: [PATCH] nfs4: set source address when callback is generated
Message-ID: <20101215050901.GB13532@redhat.com>
Content-Type: text/plain; charset=iso-2022-jp
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

when callback is generated in NFSv4 server, it doesn't set the source
address. When an alias IP is utilized on NFSv4 server and suppose the 
client is accessing via that alias IP (e.g. eth0:0), the client invokes 
the callback to the IP address that is set on the original device (e.g.
eth0). This behavior results in timeout of xprt. 
The patch sets the IP address that the client should invoke callback to. 

Signed-off-by: Takuma Umeya <tumeya@redhat.com>


diff --git a/fs/nfsd/nfs4callback.c b/fs/nfsd/nfs4callback.c
index 143da2e..bb5de7f 100644
--- a/fs/nfsd/nfs4callback.c
+++ b/fs/nfsd/nfs4callback.c
@@ -483,6 +483,7 @@ int setup_callback_client(struct nfs4_client *clp, struct nfs4_cb_conn *conn)
                .net            = &init_net,
                .address        = (struct sockaddr *) &conn->cb_addr,
                .addrsize       = conn->cb_addrlen,
+               .saddress       = (struct sockaddr *) &conn->cb_saddr,
                .timeout        = &timeparms,
                .program        = &cb_program,
                .version        = 0,
diff --git a/fs/nfsd/nfs4state.c b/fs/nfsd/nfs4state.c
index 116cab9..c7d3171 100644
--- a/fs/nfsd/nfs4state.c
+++ b/fs/nfsd/nfs4state.c
@@ -1177,9 +1177,11 @@ find_unconfirmed_client_by_str(const char *dname, unsigned int hashval,
 }
 
 static void
-gen_callback(struct nfs4_client *clp, struct nfsd4_setclientid *se, u32 scopeid)
+gen_callback(struct nfs4_client *clp, struct nfsd4_setclientid *se, 
+                                       u32 scopeid, struct svc_rqst *rqstp)
 {
        struct nfs4_cb_conn *conn = &clp->cl_cb_conn;
+       struct sockaddr s_sa;
        unsigned short expected_family;
 
        /* Currently, we only support tcp and tcp6 for the callback channel */
@@ -1205,6 +1207,19 @@ gen_callback(struct nfs4_client *clp, struct nfsd4_setclientid *se, u32 scopeid)
 
        conn->cb_prog = se->se_callback_prog;
        conn->cb_ident = se->se_callback_ident;
+       switch(expected_family){
+               case AF_INET:
+                       ((struct sockaddr_in *)&s_sa)->sin_family = AF_INET;
+                       ((struct sockaddr_in *)&s_sa)->sin_addr = rqstp->
+                                                               rq_daddr.addr;
+                        break;
+               case AF_INET6:
+                       ((struct sockaddr_in6 *)&s_sa)->sin6_family = AF_INET6;
+                       ((struct sockaddr_in6 *)&s_sa)->sin6_addr = rqstp->
+                                                               rq_daddr.addr6;
+                       break;
+       }
+       rpc_copy_addr((struct sockaddr *)&conn->cb_saddr, &s_sa);
        return;
 out_err:
        conn->cb_addr.ss_family = AF_UNSPEC;
@@ -1876,7 +1891,7 @@ nfsd4_setclientid(struct svc_rqst *rqstp, struct nfsd4_compound_state *cstate,
         * for consistent minorversion use throughout:
         */
        new->cl_minorversion = 0;
-       gen_callback(new, setclid, rpc_get_scope_id(sa));
+       gen_callback(new, setclid, rpc_get_scope_id(sa), rqstp);
        add_to_unconfirmed(new, strhashval);
        setclid->se_clientid.cl_boot = new->cl_clientid.cl_boot;
        setclid->se_clientid.cl_id = new->cl_clientid.cl_id;
diff --git a/fs/nfsd/state.h b/fs/nfsd/state.h
index 39adc27..0cee03d 100644
--- a/fs/nfsd/state.h
+++ b/fs/nfsd/state.h
@@ -95,6 +95,7 @@ struct nfs4_delegation {
 struct nfs4_cb_conn {
        /* SETCLIENTID info */
        struct sockaddr_storage cb_addr;
+       struct sockaddr_storage cb_saddr;
        size_t                  cb_addrlen;
        u32                     cb_prog; /* used only in 4.0 case;
                                            per-session otherwise */

