From: NeilBrown <neilb@cse.unsw.edu.au>
Subject: [PATCH kNFSd 7 of 9] Parse nsfd4 callback information
Date: Thu, 24 Jun 2004 14:46:51 +1000
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <E1BdM8R-0001Lt-RI@notabene.cse.unsw.edu.au>
References: <20040624143710.5086.patches@notabene>
Cc: nfs@lists.sourceforge.net
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.11] helo=sc8-sf-mx1.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1BdMQz-0005LD-Kf
	for nfs@lists.sourceforge.net; Wed, 23 Jun 2004 22:06:01 -0700
Received: from note.orchestra.cse.unsw.edu.au ([129.94.242.24] ident=root)
	by sc8-sf-mx1.sourceforge.net with esmtp (Exim 4.30)
	id 1BdMQy-0000JX-RN
	for nfs@lists.sourceforge.net; Wed, 23 Jun 2004 22:06:01 -0700
To: Andrew Morton <akpm@osdl.org>
Errors-To: nfs-admin@lists.sourceforge.net
List-Unsubscribe: <https://lists.sourceforge.net/lists/listinfo/nfs>,
	<mailto:nfs-request@lists.sourceforge.net?subject=unsubscribe>
List-Id: Discussion of NFS under Linux development,
	interoperability,
	and testing. <nfs.lists.sourceforge.net>
List-Post: <mailto:nfs@lists.sourceforge.net>
List-Help: <mailto:nfs-request@lists.sourceforge.net?subject=help>
List-Subscribe: <https://lists.sourceforge.net/lists/listinfo/nfs>,
	<mailto:nfs-request@lists.sourceforge.net?subject=subscribe>
List-Archive: <http://sourceforge.net/mailarchive/forum.php?forum=nfs>


Preparation for delegations: parse callback information provided in setclientid
request.

>From Andy Adamson <andros@citi.umich.edu>
Signed-off-by: J. Bruce Fields <bfields@citi.umich.edu>         
Signed-off-by: Neil Brown <neilb@cse.unsw.edu.au>

### Diffstat output
 ./fs/nfsd/nfs4state.c        |   94 ++++++++++++++++++++++++++++++++++++++++++-
 ./include/linux/nfsd/state.h |   18 ++++++++
 2 files changed, 111 insertions(+), 1 deletion(-)

diff ./fs/nfsd/nfs4state.c~current~ ./fs/nfsd/nfs4state.c
--- ./fs/nfsd/nfs4state.c~current~	2004-06-23 14:37:44.000000000 +1000
+++ ./fs/nfsd/nfs4state.c	2004-06-23 14:37:55.000000000 +1000
@@ -339,6 +339,95 @@ move_to_confirmed(struct nfs4_client *cl
 	renew_client(clp);
 }
 
+
+/* a helper function for parse_callback */
+static int
+parse_octet(unsigned int *lenp, char **addrp)
+{
+	unsigned int len = *lenp;
+	char *p = *addrp;
+	int n = -1;
+	char c;
+
+	for (;;) {
+		if (!len)
+			break;
+		len--;
+		c = *p++;
+		if (c == '.')
+			break;
+		if ((c < '0') || (c > '9')) {
+			n = -1;
+			break;
+		}
+		if (n < 0)
+			n = 0;
+		n = (n * 10) + (c - '0');
+		if (n > 255) {
+			n = -1;
+			break;
+		}
+	}
+	*lenp = len;
+	*addrp = p;
+	return n;
+}
+
+/* parse and set the setclientid ipv4 callback address */
+int
+parse_ipv4(unsigned int addr_len, char *addr_val, unsigned int *cbaddrp, unsigned short *cbportp)
+{
+	int temp = 0;
+	u32 cbaddr = 0;
+	u16 cbport = 0;
+	u32 addrlen = addr_len;
+	char *addr = addr_val;
+	int i, shift;
+
+	/* ipaddress */
+	shift = 24;
+	for(i = 4; i > 0  ; i--) {
+		if ((temp = parse_octet(&addrlen, &addr)) < 0) {
+			return 0;
+		}
+		cbaddr |= (temp << shift);
+		if(shift > 0)
+		shift -= 8;
+	}
+	*cbaddrp = cbaddr;
+
+	/* port */
+	shift = 8;
+	for(i = 2; i > 0  ; i--) {
+		if ((temp = parse_octet(&addrlen, &addr)) < 0) {
+			return 0;
+		}
+		cbport |= (temp << shift);
+		if(shift > 0)
+			shift -= 8;
+	}
+	*cbportp = cbport;
+	return 1;
+}
+
+void
+gen_callback(struct nfs4_client *clp, struct nfsd4_setclientid *se)
+{
+	struct nfs4_callback *cb = &clp->cl_callback;
+
+	if( !(parse_ipv4(se->se_callback_addr_len, se->se_callback_addr_val,
+		         &cb->cb_addr, &cb->cb_port))) {
+		printk(KERN_INFO "NFSD: BAD callback address. client will not receive delegations\n");
+		cb->cb_parsed = 0;
+		return;
+	}
+	cb->cb_netid.len = se->se_callback_netid_len;
+	cb->cb_netid.data = se->se_callback_netid_val;
+        cb->cb_prog = se->se_callback_prog;
+        cb->cb_ident = se->se_callback_ident;
+        cb->cb_parsed = 1;
+}
+
 /*
  * RFC 3010 has a complex implmentation description of processing a 
  * SETCLIENTID request consisting of 5 bullets, labeled as 
@@ -450,6 +539,7 @@ nfsd4_setclientid(struct svc_rqst *rqstp
 		copy_cred(&new->cl_cred,&rqstp->rq_cred);
 		gen_clid(new);
 		gen_confirm(new);
+		gen_callback(new, setclid);
 		add_to_unconfirmed(new, strhashval);
 	} else if (cmp_verf(&conf->cl_verifier, &clverifier)) {
 		/*
@@ -477,6 +567,7 @@ nfsd4_setclientid(struct svc_rqst *rqstp
 		copy_cred(&new->cl_cred,&rqstp->rq_cred);
 		copy_clid(new, conf);
 		gen_confirm(new);
+		gen_callback(new, setclid);
 		add_to_unconfirmed(new,strhashval);
 	} else if (!unconf) {
 		/*
@@ -494,6 +585,7 @@ nfsd4_setclientid(struct svc_rqst *rqstp
 		copy_cred(&new->cl_cred,&rqstp->rq_cred);
 		gen_clid(new);
 		gen_confirm(new);
+		gen_callback(new, setclid);
 		add_to_unconfirmed(new, strhashval);
 	} else if (!cmp_verf(&conf->cl_confirm, &unconf->cl_confirm)) {
 		/*	
@@ -519,6 +611,7 @@ nfsd4_setclientid(struct svc_rqst *rqstp
 		copy_cred(&new->cl_cred,&rqstp->rq_cred);
 		gen_clid(new);
 		gen_confirm(new);
+		gen_callback(new, setclid);
 		add_to_unconfirmed(new, strhashval);
 	} else {
 		/* No cases hit !!! */
@@ -529,7 +622,6 @@ nfsd4_setclientid(struct svc_rqst *rqstp
 	setclid->se_clientid.cl_boot = new->cl_clientid.cl_boot;
 	setclid->se_clientid.cl_id = new->cl_clientid.cl_id;
 	memcpy(setclid->se_confirm.data, new->cl_confirm.data, sizeof(setclid->se_confirm.data));
-	printk(KERN_INFO "NFSD: this client will not receive delegations\n");
 	status = nfs_ok;
 out:
 	nfs4_unlock_state();

diff ./include/linux/nfsd/state.h~current~ ./include/linux/nfsd/state.h
--- ./include/linux/nfsd/state.h~current~	2004-06-23 14:37:06.000000000 +1000
+++ ./include/linux/nfsd/state.h	2004-06-23 14:38:35.000000000 +1000
@@ -38,6 +38,7 @@
 #define _NFSD4_STATE_H
 
 #include <linux/list.h>
+#include <linux/sunrpc/clnt.h>
 
 #define NFS4_OPAQUE_LIMIT 1024
 typedef struct {
@@ -65,6 +66,22 @@ extern stateid_t onestateid;
 #define ZERO_STATEID(stateid)       (!memcmp((stateid), &zerostateid, sizeof(stateid_t)))
 #define ONE_STATEID(stateid)        (!memcmp((stateid), &onestateid, sizeof(stateid_t)))
 
+/* client delegation callback info */
+struct nfs4_callback {
+	/* SETCLIENTID info */
+	u32			cb_parsed;  /* addr parsed */
+	u32                     cb_addr;
+	unsigned short          cb_port;
+	u32                     cb_prog;
+	u32                     cb_ident;
+	struct xdr_netobj	cb_netid;
+	/* RPC client info */
+	u32			cb_set;     /* successful CB_NULL call */
+	struct rpc_program      cb_program;
+	struct rpc_stat         cb_stat;
+	struct rpc_clnt *       cb_client;
+};
+
 /*
  * struct nfs4_client - one per client.  Clientids live here.
  * 	o Each nfs4_client is hashed by clientid.
@@ -87,6 +104,7 @@ struct nfs4_client {
 	struct svc_cred		cl_cred; 	/* setclientid principal */
 	clientid_t		cl_clientid;	/* generated by server */
 	nfs4_verifier		cl_confirm;	/* generated by server */
+	struct nfs4_callback	cl_callback;    /* callback info */
 };
 
 static inline void


-------------------------------------------------------
This SF.Net email sponsored by Black Hat Briefings & Training.
Attend Black Hat Briefings & Training, Las Vegas July 24-29 - 
digital self defense, top technical experts, no vendor pitches, 
unmatched networking opportunities. Visit www.blackhat.com
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
