From: NeilBrown <neilb@cse.unsw.edu.au>
Subject: [PATCH kNFSd 013 of 28] nfsd4: reboot hash
Date: Thu, 02 Jun 2005 08:50:56 +1000
Message-ID: <E1Ddc36-0006iL-RZ@notabene.cse.unsw.edu.au>
References: <20050602084410.25538.patches@notabene>
Cc: nfs@lists.sourceforge.net
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.11] helo=sc8-sf-mx1.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1Ddc3N-0005wm-8P
	for nfs@lists.sourceforge.net; Wed, 01 Jun 2005 15:51:13 -0700
Received: from tone.orchestra.cse.unsw.edu.au ([129.94.242.59] ident=root)
	by sc8-sf-mx1.sourceforge.net with esmtp (Exim 4.41)
	id 1Ddc3J-0002QQ-8r
	for nfs@lists.sourceforge.net; Wed, 01 Jun 2005 15:51:13 -0700
To: Andrew Morton <akpm@osdl.org>
Sender: nfs-admin@lists.sourceforge.net
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


For the purposes of reboot recovery we keep a directory with subdirectories
each having a name that is the ascii hex representation of the md5 sum of a
client identifier for an active client.

This adds the code to calculate that name.  We also use it for the purposes of
comparing clients, so if someone ever manages to find two client names that are
md5 collisions, then we'll return clid_inuse to the second.

Signed-off-by: Andy Adamson <andros@citi.umich.edu>
Signed-off-by: J. Bruce Fields <bfields@citi.umich.edu>
Signed-off-by: Neil Brown <neilb@cse.unsw.edu.au>

### Diffstat output
 ./fs/Kconfig                 |    2 
 ./fs/nfsd/Makefile           |    2 
 ./fs/nfsd/nfs4recover.c      |   97 +++++++++++++++++++++++++++++++++++++++++++
 ./fs/nfsd/nfs4state.c        |   80 ++++++++++++++++-------------------
 ./include/linux/nfsd/state.h |    6 ++
 5 files changed, 143 insertions(+), 44 deletions(-)

diff ./fs/Kconfig~current~ ./fs/Kconfig
--- ./fs/Kconfig~current~	2005-05-31 14:21:01.000000000 +1000
+++ ./fs/Kconfig	2005-05-31 14:21:02.000000000 +1000
@@ -1574,6 +1574,8 @@ config NFSD_V4
 	bool "Provide NFSv4 server support (EXPERIMENTAL)"
 	depends on NFSD_V3 && EXPERIMENTAL
 	select NFSD_TCP
+	select CRYPTO_MD5
+	select CRYPTO
 	help
 	  If you would like to include the NFSv4 server as well as the NFSv2
 	  and NFSv3 servers, say Y here.  This feature is experimental, and

diff ./fs/nfsd/Makefile~current~ ./fs/nfsd/Makefile
--- ./fs/nfsd/Makefile~current~	2005-05-31 14:21:01.000000000 +1000
+++ ./fs/nfsd/Makefile	2005-05-31 14:21:02.000000000 +1000
@@ -10,5 +10,5 @@ nfsd-$(CONFIG_NFSD_V2_ACL) += nfs2acl.o
 nfsd-$(CONFIG_NFSD_V3)	+= nfs3proc.o nfs3xdr.o
 nfsd-$(CONFIG_NFSD_V3_ACL) += nfs3acl.o
 nfsd-$(CONFIG_NFSD_V4)	+= nfs4proc.o nfs4xdr.o nfs4state.o nfs4idmap.o \
-			   nfs4acl.o nfs4callback.o
+			   nfs4acl.o nfs4callback.o nfs4recover.o
 nfsd-objs		:= $(nfsd-y)

diff ./fs/nfsd/nfs4recover.c~current~ ./fs/nfsd/nfs4recover.c
--- ./fs/nfsd/nfs4recover.c~current~	2005-05-31 14:21:01.000000000 +1000
+++ ./fs/nfsd/nfs4recover.c	2005-05-31 14:21:02.000000000 +1000
@@ -0,0 +1,97 @@
+/*
+*  linux/fs/nfsd/nfs4recover.c
+*
+*  Copyright (c) 2004 The Regents of the University of Michigan.
+*  All rights reserved.
+*
+*  Andy Adamson <andros@citi.umich.edu>
+*
+*  Redistribution and use in source and binary forms, with or without
+*  modification, are permitted provided that the following conditions
+*  are met:
+*
+*  1. Redistributions of source code must retain the above copyright
+*     notice, this list of conditions and the following disclaimer.
+*  2. Redistributions in binary form must reproduce the above copyright
+*     notice, this list of conditions and the following disclaimer in the
+*     documentation and/or other materials provided with the distribution.
+*  3. Neither the name of the University nor the names of its
+*     contributors may be used to endorse or promote products derived
+*     from this software without specific prior written permission.
+*
+*  THIS SOFTWARE IS PROVIDED ``AS IS'' AND ANY EXPRESS OR IMPLIED
+*  WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED WARRANTIES OF
+*  MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE
+*  DISCLAIMED. IN NO EVENT SHALL THE REGENTS OR CONTRIBUTORS BE LIABLE
+*  FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR
+*  CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF
+*  SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR
+*  BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF
+*  LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING
+*  NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS
+*  SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
+*
+*/
+
+
+#include <linux/sunrpc/svc.h>
+#include <linux/nfsd/nfsd.h>
+#include <linux/nfs4.h>
+#include <linux/nfsd/state.h>
+#include <linux/nfsd/xdr4.h>
+#include <asm/uaccess.h>
+#include <asm/scatterlist.h>
+#include <linux/crypto.h>
+
+
+#define NFSDDBG_FACILITY                NFSDDBG_PROC
+
+static void
+md5_to_hex(char *out, char *md5)
+{
+	int i;
+
+	for (i=0; i<16; i++) {
+		unsigned char c = md5[i];
+
+		*out++ = '0' + ((c&0xf0)>>4) + (c>=0xa0)*('a'-'9'-1);
+		*out++ = '0' + (c&0x0f) + ((c&0x0f)>=0x0a)*('a'-'9'-1);
+	}
+	*out = '\0';
+}
+
+int
+nfs4_make_rec_clidname(char *dname, struct xdr_netobj *clname)
+{
+	struct xdr_netobj cksum;
+	struct crypto_tfm *tfm;
+	struct scatterlist sg[1];
+	int status = nfserr_resource;
+
+	dprintk("NFSD: nfs4_make_rec_clidname for %.*s\n",
+			clname->len, clname->data);
+	tfm = crypto_alloc_tfm("md5", 0);
+	if (tfm == NULL)
+		goto out;
+	cksum.len = crypto_tfm_alg_digestsize(tfm);
+	cksum.data = kmalloc(cksum.len, GFP_KERNEL);
+	if (cksum.data == NULL)
+ 		goto out;
+	crypto_digest_init(tfm);
+
+	sg[0].page = virt_to_page(clname->data);
+	sg[0].offset = offset_in_page(clname->data);
+	sg[0].length = clname->len;
+
+	crypto_digest_update(tfm, sg, 1);
+	crypto_digest_final(tfm, cksum.data);
+
+	md5_to_hex(dname, cksum.data);
+
+	kfree(cksum.data);
+	status = nfs_ok;
+out:
+	if (tfm)
+		crypto_free_tfm(tfm);
+	return status;
+}

diff ./fs/nfsd/nfs4state.c~current~ ./fs/nfsd/nfs4state.c
--- ./fs/nfsd/nfs4state.c~current~	2005-05-31 14:21:01.000000000 +1000
+++ ./fs/nfsd/nfs4state.c	2005-05-31 14:21:02.000000000 +1000
@@ -231,8 +231,8 @@ unhash_delegation(struct nfs4_delegation
 
 #define clientid_hashval(id) \
 	((id) & CLIENT_HASH_MASK)
-#define clientstr_hashval(name, namelen) \
-	(opaque_hashval((name), (namelen)) & CLIENT_HASH_MASK)
+#define clientstr_hashval(name) \
+	(opaque_hashval((name), 8) & CLIENT_HASH_MASK)
 /*
  * reclaim_str_hashtbl[] holds known client info from previous reset/reboot
  * used in reboot/reset lease grace period processing
@@ -366,11 +366,12 @@ expire_client(struct nfs4_client *clp)
 }
 
 static struct nfs4_client *
-create_client(struct xdr_netobj name) {
+create_client(struct xdr_netobj name, char *recdir) {
 	struct nfs4_client *clp;
 
 	if (!(clp = alloc_client(name)))
 		goto out;
+	memcpy(clp->cl_recdir, recdir, HEXDIR_LEN);
 	atomic_set(&clp->cl_count, 1);
 	atomic_set(&clp->cl_callback.cb_set, 0);
 	clp->cl_callback.cb_parsed = 0;
@@ -403,11 +404,9 @@ copy_cred(struct svc_cred *target, struc
 	get_group_info(target->cr_group_info);
 }
 
-static int
-cmp_name(struct xdr_netobj *n1, struct xdr_netobj *n2) {
-	if (!n1 || !n2)
-		return 0;
-	return((n1->len == n2->len) && !memcmp(n1->data, n2->data, n2->len));
+static inline int
+same_name(const char *n1, const char *n2) {
+	return 0 == memcmp(n1, n2, HEXDIR_LEN);
 }
 
 static int
@@ -479,8 +478,7 @@ move_to_confirmed(struct nfs4_client *cl
 	list_del_init(&clp->cl_strhash);
 	list_del_init(&clp->cl_idhash);
 	list_add(&clp->cl_idhash, &conf_id_hashtbl[idhashval]);
-	strhashval = clientstr_hashval(clp->cl_name.data, 
-			clp->cl_name.len);
+	strhashval = clientstr_hashval(clp->cl_recdir);
 	list_add(&clp->cl_strhash, &conf_str_hashtbl[strhashval]);
 	renew_client(clp);
 }
@@ -651,22 +649,27 @@ nfsd4_setclientid(struct svc_rqst *rqstp
 	unsigned int 		strhashval;
 	struct nfs4_client *	conf, * unconf, * new, * clp;
 	int 			status;
+	char                    dname[HEXDIR_LEN];
 	
 	status = nfserr_inval;
 	if (!check_name(clname))
 		goto out;
 
+	status = nfs4_make_rec_clidname(dname, &clname);
+	if (status)
+		goto out;
+
 	/* 
 	 * XXX The Duplicate Request Cache (DRC) has been checked (??)
 	 * We get here on a DRC miss.
 	 */
 
-	strhashval = clientstr_hashval(clname.data, clname.len);
+	strhashval = clientstr_hashval(dname);
 
 	conf = NULL;
 	nfs4_lock_state();
 	list_for_each_entry(clp, &conf_str_hashtbl[strhashval], cl_strhash) {
-		if (!cmp_name(&clp->cl_name, &clname))
+		if (!same_name(clp->cl_recdir, dname))
 			continue;
 		/* 
 		 * CASE 0:
@@ -686,7 +689,7 @@ nfsd4_setclientid(struct svc_rqst *rqstp
 	}
 	unconf = NULL;
 	list_for_each_entry(clp, &unconf_str_hashtbl[strhashval], cl_strhash) {
-		if (!cmp_name(&clp->cl_name, &clname))
+		if (!same_name(clp->cl_recdir, dname))
 			continue;
 		/* cl_name match from a previous SETCLIENTID operation */
 		unconf = clp;
@@ -700,7 +703,8 @@ nfsd4_setclientid(struct svc_rqst *rqstp
 		 */
 		if (unconf)
 			expire_client(unconf);
-		if (!(new = create_client(clname)))
+		new = create_client(clname, dname);
+		if (new == NULL)
 			goto out;
 		copy_verf(new, &clverifier);
 		new->cl_addr = ip_addr;
@@ -728,7 +732,8 @@ nfsd4_setclientid(struct svc_rqst *rqstp
 		     cmp_clid(&unconf->cl_clientid, &conf->cl_clientid)) {
 				expire_client(unconf);
 		}
-		if (!(new = create_client(clname)))
+		new = create_client(clname, dname);
+		if (new == NULL)
 			goto out;
 		copy_verf(new,&conf->cl_verifier);
 		new->cl_addr = ip_addr;
@@ -746,7 +751,8 @@ nfsd4_setclientid(struct svc_rqst *rqstp
 		 * using input clverifier, clname, and callback info
 		 * and generate a new cl_clientid and cl_confirm.
 		 */
-		if (!(new = create_client(clname)))
+		new = create_client(clname, dname);
+		if (new == NULL)
 			goto out;
 		copy_verf(new,&clverifier);
 		new->cl_addr = ip_addr;
@@ -772,7 +778,8 @@ nfsd4_setclientid(struct svc_rqst *rqstp
 		 * new cl_verifier and a new cl_confirm
 		 */
 		expire_client(unconf);
-		if (!(new = create_client(clname)))
+		new = create_client(clname, dname);
+		if (new == NULL)
 			goto out;
 		copy_verf(new,&clverifier);
 		new->cl_addr = ip_addr;
@@ -856,7 +863,7 @@ nfsd4_setclientid_confirm(struct svc_rqs
 	if ((conf && unconf) && 
 	    (cmp_verf(&unconf->cl_confirm, &confirm)) &&
 	    (cmp_verf(&conf->cl_verifier, &unconf->cl_verifier)) &&
-	    (cmp_name(&conf->cl_name,&unconf->cl_name))  &&
+	    (same_name(conf->cl_recdir,unconf->cl_recdir))  &&
 	    (!cmp_verf(&conf->cl_confirm, &unconf->cl_confirm))) {
 		if (!cmp_creds(&conf->cl_cred, &unconf->cl_cred)) 
 			status = nfserr_clid_inuse;
@@ -876,7 +883,7 @@ nfsd4_setclientid_confirm(struct svc_rqs
 	if ((conf && !unconf) || 
 	    ((conf && unconf) && 
 	     (!cmp_verf(&conf->cl_verifier, &unconf->cl_verifier) ||
-	      !cmp_name(&conf->cl_name, &unconf->cl_name)))) {
+	      !same_name(conf->cl_recdir, unconf->cl_recdir)))) {
 		if (!cmp_creds(&conf->cl_cred,&rqstp->rq_cred)) {
 			status = nfserr_clid_inuse;
 		} else {
@@ -3074,39 +3081,28 @@ out:
 }
 
 static inline struct nfs4_client_reclaim *
-alloc_reclaim(int namelen)
+alloc_reclaim(void)
 {
-	struct nfs4_client_reclaim *crp = NULL;
-
-	crp = kmalloc(sizeof(struct nfs4_client_reclaim), GFP_KERNEL);
-	if (!crp)
-		return NULL;
-	crp->cr_name.data = kmalloc(namelen, GFP_KERNEL);
-	if (!crp->cr_name.data) {
-		kfree(crp);
-		return NULL;
-	}
-	return crp;
+	return kmalloc(sizeof(struct nfs4_client_reclaim), GFP_KERNEL);
 }
 
 /*
  * failure => all reset bets are off, nfserr_no_grace...
  */
 static int
-nfs4_client_to_reclaim(char *name, int namlen)
+nfs4_client_to_reclaim(char *name)
 {
 	unsigned int strhashval;
 	struct nfs4_client_reclaim *crp = NULL;
 
-	dprintk("NFSD nfs4_client_to_reclaim NAME: %.*s\n", namlen, name);
-	crp = alloc_reclaim(namlen);
+	dprintk("NFSD nfs4_client_to_reclaim NAME: %.*s\n", HEXDIR_LEN, name);
+	crp = alloc_reclaim();
 	if (!crp)
 		return 0;
-	strhashval = clientstr_hashval(name, namlen);
+	strhashval = clientstr_hashval(name);
 	INIT_LIST_HEAD(&crp->cr_strhash);
 	list_add(&crp->cr_strhash, &reclaim_str_hashtbl[strhashval]);
-	memcpy(crp->cr_name.data, name, namlen);
-	crp->cr_name.len = namlen;
+	memcpy(crp->cr_recdir, name, HEXDIR_LEN);
 	reclaim_str_hashtbl_size++;
 	return 1;
 }
@@ -3122,7 +3118,6 @@ nfs4_release_reclaim(void)
 			crp = list_entry(reclaim_str_hashtbl[i].next,
 			                struct nfs4_client_reclaim, cr_strhash);
 			list_del(&crp->cr_strhash);
-			kfree(crp->cr_name.data);
 			kfree(crp);
 			reclaim_str_hashtbl_size--;
 		}
@@ -3145,13 +3140,14 @@ nfs4_find_reclaim_client(clientid_t *cli
 	if (clp == NULL)
 		return NULL;
 
-	dprintk("NFSD: nfs4_find_reclaim_client for %.*s\n",
-		            clp->cl_name.len, clp->cl_name.data);
+	dprintk("NFSD: nfs4_find_reclaim_client for %.*s with recdir %s\n",
+		            clp->cl_name.len, clp->cl_name.data,
+			    clp->cl_recdir);
 
 	/* find clp->cl_name in reclaim_str_hashtbl */
-	strhashval = clientstr_hashval(clp->cl_name.data, clp->cl_name.len);
+	strhashval = clientstr_hashval(clp->cl_recdir);
 	list_for_each_entry(crp, &reclaim_str_hashtbl[strhashval], cr_strhash) {
-		if (cmp_name(&crp->cr_name, &clp->cl_name)) {
+		if (same_name(crp->cr_recdir, clp->cl_recdir)) {
 			return crp;
 		}
 	}

diff ./include/linux/nfsd/state.h~current~ ./include/linux/nfsd/state.h
--- ./include/linux/nfsd/state.h~current~	2005-05-31 14:21:01.000000000 +1000
+++ ./include/linux/nfsd/state.h	2005-05-31 14:21:02.000000000 +1000
@@ -109,6 +109,8 @@ struct nfs4_callback {
 	struct rpc_clnt *       cb_client;
 };
 
+#define HEXDIR_LEN     33 /* hex version of 16 byte md5 of cl_name plus '\0' */
+
 /*
  * struct nfs4_client - one per client.  Clientids live here.
  * 	o Each nfs4_client is hashed by clientid.
@@ -126,6 +128,7 @@ struct nfs4_client {
 	struct list_head	cl_del_perclnt; /* list: delegations */
 	struct list_head        cl_lru;         /* tail queue */
 	struct xdr_netobj	cl_name; 	/* id generated by client */
+	char                    cl_recdir[HEXDIR_LEN]; /* recovery dir */
 	nfs4_verifier		cl_verifier; 	/* generated by client */
 	time_t                  cl_time;        /* time of last lease renewal */
 	u32			cl_addr; 	/* client ipaddress */
@@ -143,7 +146,7 @@ struct nfs4_client {
  */
 struct nfs4_client_reclaim {
 	struct list_head	cr_strhash;	/* hash by cr_name */
-	struct xdr_netobj 	cr_name; 	/* id generated by client */
+	char			cr_recdir[HEXDIR_LEN]; /* recover dir */
 };
 
 static inline void
@@ -283,6 +286,7 @@ extern void nfs4_free_stateowner(struct 
 extern void nfsd4_probe_callback(struct nfs4_client *clp);
 extern void nfsd4_cb_recall(struct nfs4_delegation *dp);
 extern void nfs4_put_delegation(struct nfs4_delegation *dp);
+extern int nfs4_make_rec_clidname(char *clidname, struct xdr_netobj *clname);
 
 static inline void
 nfs4_put_stateowner(struct nfs4_stateowner *so)


-------------------------------------------------------
This SF.Net email is sponsored by Yahoo.
Introducing Yahoo! Search Developer Network - Create apps using Yahoo!
Search APIs Find out how you can build Yahoo! directly into your own
Applications - visit http://developer.yahoo.net/?fr=offad-ysdn-ostg-q22005
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
