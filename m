From: NeilBrown <neilb@cse.unsw.edu.au>
Subject: [PATCH] kNFSd - 4 of 4 - First step to adding state management to NFSv4 server
Date: Sun, 13 Apr 2003 16:18:24 +1000
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <E194aoq-0007mA-00@notabene.cse.unsw.edu.au>
Cc: nfs@lists.sourceforge.net
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from tone.orchestra.cse.unsw.edu.au ([129.94.242.28] ident=root)
	by sc8-sf-list1.sourceforge.net with smtp (Exim 3.31-VA-mm2 #1 (Debian))
	id 194aps-0006hu-00
	for <nfs@lists.sourceforge.net>; Sat, 12 Apr 2003 23:19:28 -0700
Received: From
	notabene.cse.unsw.edu.au ([129.94.242.45] == bartok.orchestra.cse.unsw.EDU.AU)
	(for <torvalds@transmeta.com>) (for <nfs@lists.sourceforge.net>) By
	tone With Smtp ; Sun, 13 Apr 2003 16:19:23 +1000
To: Linus Torvalds <torvalds@transmeta.com>
Errors-To: nfs-admin@lists.sourceforge.net
List-Help: <mailto:nfs-request@lists.sourceforge.net?subject=help>
List-Post: <mailto:nfs@lists.sourceforge.net>
List-Subscribe: <https://lists.sourceforge.net/lists/listinfo/nfs>,
	<mailto:nfs-request@lists.sourceforge.net?subject=subscribe>
List-Id: Discussion of NFS under Linux development,
	interoperability,
	and testing. <nfs.lists.sourceforge.net>
List-Unsubscribe: <https://lists.sourceforge.net/lists/listinfo/nfs>,
	<mailto:nfs-request@lists.sourceforge.net?subject=unsubscribe>
List-Archive: <http://sourceforge.net/mailarchive/forum.php?forum=nfs>

### Comments for ChangeSet

A new file "nfs4state.c", and nfs4_setclientid{,_confirm} are moved there,
with lots of code.

 ----------- Diffstat output ------------
 ./fs/nfsd/Makefile           |    2 
 ./fs/nfsd/nfs4proc.c         |   14 
 ./fs/nfsd/nfs4state.c        |  634 +++++++++++++++++++++++++++++++++++++++++++
 ./fs/nfsd/nfsctl.c           |    2 
 ./include/linux/nfsd/nfsd.h  |   12 
 ./include/linux/nfsd/state.h |   63 ++++
 6 files changed, 712 insertions(+), 15 deletions(-)

diff ./fs/nfsd/Makefile~current~ ./fs/nfsd/Makefile
--- ./fs/nfsd/Makefile~current~	2003-04-13 16:15:50.000000000 +1000
+++ ./fs/nfsd/Makefile	2003-04-13 16:15:50.000000000 +1000
@@ -7,5 +7,5 @@ obj-$(CONFIG_NFSD)	+= nfsd.o
 nfsd-y 			:= nfssvc.o nfsctl.o nfsproc.o nfsfh.o vfs.o \
 			   export.o auth.o lockd.o nfscache.o nfsxdr.o stats.o
 nfsd-$(CONFIG_NFSD_V3)	+= nfs3proc.o nfs3xdr.o
-nfsd-$(CONFIG_NFSD_V4)	+= nfs4proc.o nfs4xdr.o
+nfsd-$(CONFIG_NFSD_V4)	+= nfs4proc.o nfs4xdr.o nfs4state.o
 nfsd-objs		:= $(nfsd-y)

diff ./fs/nfsd/nfs4proc.c~current~ ./fs/nfsd/nfs4proc.c
--- ./fs/nfsd/nfs4proc.c~current~	2003-04-13 16:15:50.000000000 +1000
+++ ./fs/nfsd/nfs4proc.c	2003-04-13 16:15:50.000000000 +1000
@@ -173,20 +173,6 @@ nfsd4_renew(clientid_t *clientid)
 	return nfs_ok;
 }
 
-static inline int
-nfsd4_setclientid(struct svc_rqst *rqstp, struct nfsd4_setclientid *setclientid)
-{
-	memset(&setclientid->se_clientid, 0, sizeof(clientid_t));
-	memset(&setclientid->se_confirm, 0, sizeof(nfs4_verifier));
-	return nfs_ok;
-}
-
-static inline int
-nfsd4_setclientid_confirm(struct svc_rqst *rqstp, struct nfsd4_setclientid_confirm *setclientid_confirm)
-{
-	return nfs_ok;
-}
-
 /*
  * filehandle-manipulating ops.
  */

diff ./fs/nfsd/nfs4state.c~current~ ./fs/nfsd/nfs4state.c
--- ./fs/nfsd/nfs4state.c~current~	2003-04-13 16:15:50.000000000 +1000
+++ ./fs/nfsd/nfs4state.c	2003-04-13 16:15:50.000000000 +1000
@@ -0,0 +1,634 @@
+/*
+*  linux/fs/nfsd/nfs4state.c
+*
+*  Copyright (c) 2001 The Regents of the University of Michigan.
+*  All rights reserved.
+*
+*  Kendrick Smith <kmsmith@umich.edu>
+*  Andy Adamson <kandros@umich.edu>
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
+#include <linux/param.h>
+#include <linux/major.h>
+#include <linux/slab.h>
+
+
+#include <linux/sunrpc/svc.h>
+#include <linux/nfsd/nfsd.h>
+#include <linux/nfsd/cache.h>
+#include <linux/nfs4.h>
+#include <linux/nfsd/xdr4.h>
+#include <linux/nfsd/state.h>
+
+#define NFSDDBG_FACILITY                NFSDDBG_PROC
+
+/* Globals */
+time_t boot_time;
+static u32 current_clientid = 1;
+
+/* Locking:
+ *
+ * client_sema: 
+ * 	protects clientid_hashtbl[], clientstr_hashtbl[],
+ * 	unconfstr_hashtbl[], uncofid_hashtbl[].
+ */
+static struct semaphore client_sema;
+
+static inline u32
+opaque_hashval(const void *ptr, int nbytes)
+{
+	unsigned char *cptr = (unsigned char *) ptr;
+
+	u32 x = 0;
+	while (nbytes--) {
+		x *= 37;
+		x += *cptr++;
+	}
+	return x;
+}
+
+/* Hash tables for nfs4_clientid state */
+#define CLIENT_HASH_BITS                 4
+#define CLIENT_HASH_SIZE                (1 << CLIENT_HASH_BITS)
+#define CLIENT_HASH_MASK                (CLIENT_HASH_SIZE - 1)
+
+#define clientid_hashval(id) \
+	((id) & CLIENT_HASH_MASK)
+#define clientstr_hashval(name, namelen) \
+	(opaque_hashval((name), (namelen)) & CLIENT_HASH_MASK)
+
+/* conf_id_hashtbl[], and conf_str_hashtbl[] hold confirmed
+ * setclientid_confirmed info. 
+ *
+ * unconf_str_hastbl[] and unconf_id_hashtbl[] hold unconfirmed 
+ * setclientid info.
+ */
+static struct list_head	conf_id_hashtbl[CLIENT_HASH_SIZE];
+static struct list_head	conf_str_hashtbl[CLIENT_HASH_SIZE];
+static struct list_head	unconf_str_hashtbl[CLIENT_HASH_SIZE];
+static struct list_head	unconf_id_hashtbl[CLIENT_HASH_SIZE];
+
+/* SETCLIENTID and SETCLIENTID_CONFIRM Helper functions */
+static int
+STALE_CLIENTID(clientid_t *clid)
+{
+	if (clid->cl_boot == boot_time)
+		return 0;
+	printk("NFSD stale clientid (%08x/%08x)\n", clid->cl_boot, clid->cl_id);
+	return 1;
+}
+
+/* 
+ * XXX Should we use a slab cache ?
+ * This type of memory management is somewhat inefficient, but we use it
+ * anyway since SETCLIENTID is not a common operation.
+ */
+static inline struct nfs4_client *
+alloc_client(struct xdr_netobj name)
+{
+	struct nfs4_client *clp;
+
+	if ((clp = kmalloc(sizeof(struct nfs4_client), GFP_KERNEL))!= NULL) {
+		memset(clp, 0, sizeof(*clp));
+		if ((clp->cl_name.data = kmalloc(name.len, GFP_KERNEL)) != NULL) {
+			memcpy(clp->cl_name.data, name.data, name.len);
+			clp->cl_name.len = name.len;
+		}
+		else {
+			kfree(clp);
+			clp = NULL;
+		}
+	}
+	return clp;
+}
+
+static inline void
+free_client(struct nfs4_client *clp)
+{
+	kfree(clp->cl_name.data);
+	kfree(clp);
+}
+
+static void
+expire_client(struct nfs4_client *clp)
+{
+	dprintk("NFSD: expire_client\n");
+	list_del(&clp->cl_idhash);
+	list_del(&clp->cl_strhash);
+	free_client(clp);
+}
+
+static struct nfs4_client *
+create_client(struct xdr_netobj name) {
+	struct nfs4_client *clp;
+
+	if(!(clp = alloc_client(name)))
+		goto out;
+	INIT_LIST_HEAD(&clp->cl_idhash);
+	INIT_LIST_HEAD(&clp->cl_strhash);
+out:
+	return clp;
+}
+
+static void
+copy_verf(struct nfs4_client *target, nfs4_verifier source) {
+	memcpy(&target->cl_verifier, source, sizeof(nfs4_verifier));
+}
+
+static void
+copy_clid(struct nfs4_client *target, struct nfs4_client *source) {
+	target->cl_clientid.cl_boot = source->cl_clientid.cl_boot; 
+	target->cl_clientid.cl_id = source->cl_clientid.cl_id; 
+}
+
+static void
+copy_cred(struct svc_cred *target, struct svc_cred *source) {
+	int i;
+
+	target->cr_uid = source->cr_uid;
+	target->cr_gid = source->cr_gid;
+	for(i = 0; i < NGROUPS; i++)
+		target->cr_groups[i] = source->cr_groups[i];
+}
+
+static int
+cmp_name(struct xdr_netobj *n1, struct xdr_netobj *n2) {
+	if(!n1 || !n2)
+		return 0;
+	return((n1->len == n2->len) && !memcmp(n1->data, n2->data, n2->len));
+}
+
+static int
+cmp_verf(nfs4_verifier v1, nfs4_verifier v2) {
+	return(!memcmp(v1,v2,sizeof(nfs4_verifier)));
+}
+
+static int
+cmp_clid(clientid_t * cl1, clientid_t * cl2) {
+	return((cl1->cl_boot == cl2->cl_boot) &&
+	   	(cl1->cl_id == cl2->cl_id));
+}
+
+/* XXX what about NGROUP */
+static int
+cmp_creds(struct svc_cred *cr1, struct svc_cred *cr2){
+	return((cr1->cr_uid == cr2->cr_uid) &&
+	   	(cr1->cr_gid == cr2->cr_gid));
+
+}
+
+static void
+gen_clid(struct nfs4_client *clp) {
+	clp->cl_clientid.cl_boot = boot_time;
+	clp->cl_clientid.cl_id = current_clientid++; 
+}
+
+static void
+gen_confirm(struct nfs4_client *clp) {
+	struct timespec 	tv;
+	u32 *			p;
+
+	tv = CURRENT_TIME;
+	p = (u32 *)clp->cl_confirm;
+	*p++ = tv.tv_sec;
+	*p++ = tv.tv_nsec;
+}
+
+static int
+check_name(struct xdr_netobj name) {
+
+	if (name.len == 0) 
+		return 0;
+	if (name.len > NFSD4_CLIENT_MAXNAME) {
+		printk("NFSD: check_name: name too long(%d)!\n", name.len);
+		return 0;
+	}
+	return 1;
+}
+
+void
+add_to_unconfirmed(struct nfs4_client *clp, unsigned int strhashval)
+{
+	unsigned int idhashval;
+
+	list_add(&clp->cl_strhash, &unconf_str_hashtbl[strhashval]);
+	idhashval = clientid_hashval(clp->cl_clientid.cl_id);
+	list_add(&clp->cl_idhash, &unconf_id_hashtbl[idhashval]);
+}
+
+void
+move_to_confirmed(struct nfs4_client *clp, unsigned int idhashval)
+{
+	unsigned int strhashval;
+
+	printk("ANDROS: move_to_confirm nfs4_client %p\n", clp);
+	list_del_init(&clp->cl_strhash);
+	list_del_init(&clp->cl_idhash);
+	list_add(&clp->cl_idhash, &conf_id_hashtbl[idhashval]);
+	strhashval = clientstr_hashval(clp->cl_name.data, 
+			clp->cl_name.len);
+	list_add(&clp->cl_strhash, &conf_str_hashtbl[strhashval]);
+}
+
+/*
+ * RFC 3010 has a complex implmentation description of processing a 
+ * SETCLIENTID request consisting of 5 bullets, labeled as 
+ * CASE0 - CASE4 below.
+ *
+ * NOTES:
+ * 	callback information will be processed in a future patch
+ *
+ *	an unconfirmed record is added when:
+ *      NORMAL (part of CASE 4): there is no confirmed nor unconfirmed record.
+ *	CASE 1: confirmed record found with matching name, principal,
+ *		verifier, and clientid.
+ *	CASE 2: confirmed record found with matching name, principal,
+ *		and there is no unconfirmed record with matching
+ *		name and principal
+ *
+ *      an unconfirmed record is replaced when:
+ *	CASE 3: confirmed record found with matching name, principal,
+ *		and an unconfirmed record is found with matching 
+ *		name, principal, and with clientid and
+ *		confirm that does not match the confirmed record.
+ *	CASE 4: there is no confirmed record with matching name and 
+ *		principal. there is an unconfirmed record with 
+ *		matching name, principal.
+ *
+ *	an unconfirmed record is deleted when:
+ *	CASE 1: an unconfirmed record that matches input name, verifier,
+ *		and confirmed clientid.
+ *	CASE 4: any unconfirmed records with matching name and principal
+ *		that exist after an unconfirmed record has been replaced
+ *		as described above.
+ *
+ */
+int
+nfsd4_setclientid(struct svc_rqst *rqstp, struct nfsd4_setclientid *setclid)
+{
+	u32 			ip_addr = rqstp->rq_addr.sin_addr.s_addr;
+	struct xdr_netobj 	clname = { 
+		.len = setclid->se_namelen,
+		.data = setclid->se_name,
+	};
+	char *			clverifier = setclid->se_verf;
+	unsigned int 		strhashval;
+	struct nfs4_client *	conf, * unconf, * new, * clp;
+	int 			status;
+	struct list_head *pos, *next;
+	
+	status = nfserr_inval;
+	if (!check_name(clname))
+		goto out;
+
+	/* 
+	 * XXX The Duplicate Request Cache (DRC) has been checked (??)
+	 * We get here on a DRC miss.
+	 */
+
+	strhashval = clientstr_hashval(clname.data, clname.len);
+
+	conf = NULL;
+	down(&client_sema);
+	list_for_each_safe(pos, next, &conf_str_hashtbl[strhashval]) {
+		clp = list_entry(pos, struct nfs4_client, cl_strhash);
+		if (!cmp_name(&clp->cl_name, &clname))
+			continue;
+		/* 
+		 * CASE 0:
+		 * clname match, confirmed, different principal
+		 * or different ip_address
+		 */
+		status = nfserr_clid_inuse;
+		if (!cmp_creds(&clp->cl_cred,&rqstp->rq_cred)) {
+			printk("NFSD: setclientid: string in use by client"
+			"(clientid %08x/%08x)\n",
+			clp->cl_clientid.cl_boot, clp->cl_clientid.cl_id);
+			goto out;
+		}
+		if (clp->cl_addr != ip_addr) { 
+			printk("NFSD: setclientid: string in use by client"
+			"(clientid %08x/%08x)\n",
+			clp->cl_clientid.cl_boot, clp->cl_clientid.cl_id);
+			goto out;
+		}
+
+		/* 
+	 	 * cl_name match from a previous SETCLIENTID operation
+	 	 * XXX check for additional matches?
+		 */
+		conf = clp;
+		break;
+	}
+	unconf = NULL;
+	list_for_each_safe(pos, next, &unconf_str_hashtbl[strhashval]) {
+		clp = list_entry(pos, struct nfs4_client, cl_strhash);
+		if (!cmp_name(&clp->cl_name, &clname))
+			continue;
+		/* cl_name match from a previous SETCLIENTID operation */
+		unconf = clp;
+		break;
+	}
+	status = nfserr_resource;
+	if (!conf) {
+		/* 
+		 * CASE 4:
+		 * placed first, because it is the normal case.
+		 */
+		if (unconf)
+			expire_client(unconf);
+		if (!(new = create_client(clname)))
+			goto out;
+		copy_verf(new,clverifier);
+		new->cl_addr = ip_addr;
+		copy_cred(&new->cl_cred,&rqstp->rq_cred);
+		gen_clid(new);
+		gen_confirm(new);
+		add_to_unconfirmed(new, strhashval);
+	} else if (cmp_verf(conf->cl_verifier, clverifier)) {
+		/*
+		 * CASE 1:
+		 * cl_name match, confirmed, principal match
+		 * verifier match: probable callback update
+		 *
+		 * remove any unconfirmed nfs4_client with 
+		 * matching cl_name, cl_verifier, and cl_clientid
+		 *
+		 * create and insert an unconfirmed nfs4_client with same 
+		 * cl_name, cl_verifier, and cl_clientid as existing 
+		 * nfs4_client,  but with the new callback info and a 
+		 * new cl_confirm
+		 */
+		if ((unconf) && 
+		    cmp_verf(unconf->cl_verifier, conf->cl_verifier) &&
+		     cmp_clid(&unconf->cl_clientid, &conf->cl_clientid)) {
+				expire_client(unconf);
+		}
+		if (!(new = create_client(clname)))
+			goto out;
+		copy_verf(new,conf->cl_verifier);
+		new->cl_addr = ip_addr;
+		copy_cred(&new->cl_cred,&rqstp->rq_cred);
+		copy_clid(new, conf);
+		gen_confirm(new);
+		add_to_unconfirmed(new,strhashval);
+	} else if (!unconf) {
+		/*
+		 * CASE 2:
+		 * clname match, confirmed, principal match
+		 * verfier does not match
+		 * no unconfirmed. create a new unconfirmed nfs4_client
+		 * using input clverifier, clname, and callback info
+		 * and generate a new cl_clientid and cl_confirm.
+		 */
+		if (!(new = create_client(clname)))
+			goto out;
+		copy_verf(new,clverifier);
+		new->cl_addr = ip_addr;
+		copy_cred(&new->cl_cred,&rqstp->rq_cred);
+		gen_clid(new);
+		gen_confirm(new);
+		add_to_unconfirmed(new, strhashval);
+	} else if (!cmp_clid(&conf->cl_clientid, &unconf->cl_clientid) &&
+	      !cmp_verf(conf->cl_confirm, unconf->cl_confirm)) {
+		/*	
+		 * CASE3:
+		 * confirmed found (name, principal match)
+		 * confirmed verifier does not match input clverifier
+		 *
+		 * unconfirmed found (name match)
+		 * confirmed->cl_clientid != unconfirmed->cl_clientid and
+		 * confirmed->cl_confirm != unconfirmed->cl_confirm
+		 *
+		 * remove unconfirmed.
+		 *
+		 * create an unconfirmed nfs4_client 
+		 * with same cl_name as existing confirmed nfs4_client, 
+		 * but with new callback info, new cl_clientid,
+		 * new cl_verifier and a new cl_confirm
+		 */
+		expire_client(unconf);
+		if (!(new = create_client(clname)))
+			goto out;
+		copy_verf(new,clverifier);
+		new->cl_addr = ip_addr;
+		copy_cred(&new->cl_cred,&rqstp->rq_cred);
+		gen_clid(new);
+		gen_confirm(new);
+		add_to_unconfirmed(new, strhashval);
+	} else {
+		/* No cases hit !!! */
+		status = nfserr_inval;
+		goto out;
+
+	}
+	setclid->se_clientid.cl_boot = new->cl_clientid.cl_boot;
+	setclid->se_clientid.cl_id = new->cl_clientid.cl_id;
+	memcpy(&setclid->se_confirm, new->cl_confirm, sizeof(nfs4_verifier));
+	printk(KERN_INFO "NFSD: this client will not receive delegations\n");
+	status = nfs_ok;
+out:
+	up(&client_sema);
+	return status;
+}
+
+
+/*
+ * RFC 3010 has a complex implmentation description of processing a 
+ * SETCLIENTID_CONFIRM request consisting of 4 bullets describing
+ * processing on a DRC miss, labeled as CASE1 - CASE4 below.
+ *
+ * NOTE: callback information will be processed here in a future patch
+ */
+int
+nfsd4_setclientid_confirm(struct svc_rqst *rqstp, struct nfsd4_setclientid_confirm *setclientid_confirm)
+{
+	u32 ip_addr = rqstp->rq_addr.sin_addr.s_addr;
+	unsigned int idhashval;
+	struct nfs4_client *clp, *conf = NULL, *unconf = NULL;
+	char * confirm = setclientid_confirm->sc_confirm; 
+	clientid_t * clid = &setclientid_confirm->sc_clientid;
+	struct list_head *pos, *next;
+	int status;
+
+	status = nfserr_stale_clientid;
+	if (STALE_CLIENTID(clid))
+		goto out;
+	/* 
+	 * XXX The Duplicate Request Cache (DRC) has been checked (??)
+	 * We get here on a DRC miss.
+	 */
+
+	idhashval = clientid_hashval(clid->cl_id);
+	down(&client_sema);
+	list_for_each_safe(pos, next, &conf_id_hashtbl[idhashval]) {
+		clp = list_entry(pos, struct nfs4_client, cl_idhash);
+		if (!cmp_clid(&clp->cl_clientid, clid))
+			continue;
+
+		status = nfserr_inval;
+		/* 
+		 * Found a record for this clientid. If the IP addresses
+		 * don't match, return ERR_INVAL just as if the record had
+		 * not been found.
+		 */
+		if (clp->cl_addr != ip_addr) { 
+			printk("NFSD: setclientid: string in use by client"
+			"(clientid %08x/%08x)\n",
+			clp->cl_clientid.cl_boot, clp->cl_clientid.cl_id);
+			goto out;
+		}
+		conf = clp;
+		break;
+	}
+	list_for_each_safe(pos, next, &unconf_id_hashtbl[idhashval]) {
+		clp = list_entry(pos, struct nfs4_client, cl_idhash);
+		if (!cmp_clid(&clp->cl_clientid, clid))
+			continue;
+		status = nfserr_inval;
+		if (clp->cl_addr != ip_addr) { 
+			printk("NFSD: setclientid: string in use by client"
+			"(clientid %08x/%08x)\n",
+			clp->cl_clientid.cl_boot, clp->cl_clientid.cl_id);
+			goto out;
+		}
+		unconf = clp;
+		break;
+	}
+	/* CASE 1: 
+	* unconf record that matches input clientid and input confirm.
+	* conf record that matches input clientid.
+	* conf  and unconf records match names, verifiers 
+	*/
+	if ((conf && unconf) && 
+	    (cmp_verf(unconf->cl_confirm, confirm)) &&
+	    (cmp_verf(conf->cl_verifier, unconf->cl_verifier)) &&
+	    (cmp_name(&conf->cl_name,&unconf->cl_name))  &&
+	    (!cmp_verf(conf->cl_confirm, unconf->cl_confirm))) {
+		if (!cmp_creds(&conf->cl_cred, &unconf->cl_cred)) 
+			status = nfserr_clid_inuse;
+		else {
+			expire_client(conf);
+			move_to_confirmed(unconf, idhashval);
+			status = nfs_ok;
+		}
+		goto out;
+	} 
+	/* CASE 2:
+	 * conf record that matches input clientid.
+	 * if unconf record that matches input clientid, then unconf->cl_name
+	 * or unconf->cl_verifier don't match the conf record.
+	 */
+	if ((conf && !unconf) || 
+	    ((conf && unconf) && 
+	     (!cmp_verf(conf->cl_verifier, unconf->cl_verifier) ||
+	      !cmp_name(&conf->cl_name, &unconf->cl_name)))) {
+		if (!cmp_creds(&conf->cl_cred,&rqstp->rq_cred)) {
+			status = nfserr_clid_inuse;
+		} else {
+			status = nfs_ok;
+		}
+		goto out;
+	}
+	/* CASE 3:
+	 * conf record not found.
+	 * unconf record found. 
+	 * unconf->cl_confirm matches input confirm
+	 */ 
+	if (!conf && unconf && cmp_verf(unconf->cl_confirm, confirm)) {
+		if (!cmp_creds(&unconf->cl_cred, &rqstp->rq_cred)) {
+			status = nfserr_clid_inuse;
+		} else {
+			status = nfs_ok;
+			move_to_confirmed(unconf, idhashval);
+		}
+		goto out;
+	}
+	/* CASE 4:
+	 * conf record not found, or if conf, then conf->cl_confirm does not
+	 * match input confirm.
+	 * unconf record not found, or if unconf, then unconf->cl_confirm 
+	 * does not match input confirm.
+	 */
+	if ((!conf || (conf && !cmp_verf(conf->cl_confirm, confirm))) &&
+	    (!unconf || (unconf && !cmp_verf(unconf->cl_confirm, confirm)))) {
+		status = nfserr_stale_clientid;
+		goto out;
+	}
+	/* check that we have hit one of the cases...*/
+	status = nfserr_inval;
+	goto out;
+out:
+	/* XXX if status == nfs_ok, probe callback path */
+	up(&client_sema);
+	return status;
+}
+
+void
+nfs4_state_init(void)
+{
+	struct timespec 	tv;
+	int i;
+
+	for (i = 0; i < CLIENT_HASH_SIZE; i++) {
+		INIT_LIST_HEAD(&conf_id_hashtbl[i]);
+		INIT_LIST_HEAD(&conf_str_hashtbl[i]);
+		INIT_LIST_HEAD(&unconf_str_hashtbl[i]);
+		INIT_LIST_HEAD(&unconf_id_hashtbl[i]);
+	}
+	init_MUTEX(&client_sema);
+	tv = CURRENT_TIME;
+	boot_time = tv.tv_sec;
+}
+
+static void
+__nfs4_state_shutdown(void)
+{
+	int i;
+	struct nfs4_client *clp = NULL;
+
+	for (i = 0; i < CLIENT_HASH_SIZE; i++) {
+		while (!list_empty(&conf_id_hashtbl[i])) {
+			clp = list_entry(conf_id_hashtbl[i].next, struct nfs4_client, cl_idhash);
+			expire_client(clp);
+		}
+		while (!list_empty(&unconf_str_hashtbl[i])) {
+			clp = list_entry(unconf_str_hashtbl[i].next, struct nfs4_client, cl_strhash);
+			expire_client(clp);
+		}
+	}
+}
+
+void
+nfs4_state_shutdown(void)
+{
+	down(&client_sema);
+	__nfs4_state_shutdown();
+	up(&client_sema);
+}

diff ./fs/nfsd/nfsctl.c~current~ ./fs/nfsd/nfsctl.c
--- ./fs/nfsd/nfsctl.c~current~	2003-04-13 16:15:50.000000000 +1000
+++ ./fs/nfsd/nfsctl.c	2003-04-13 16:15:50.000000000 +1000
@@ -512,6 +512,7 @@ static int __init init_nfsd(void)
 	nfsd_cache_init();	/* RPC reply cache */
 	nfsd_export_init();	/* Exports table */
 	nfsd_lockd_init();	/* lockd->nfsd callbacks */
+	nfs4_state_init();      /* NFSv4 State */
 	if (proc_mkdir("fs/nfs", 0)) {
 		struct proc_dir_entry *entry;
 		entry = create_proc_entry("fs/nfs/exports", 0, NULL);
@@ -530,6 +531,7 @@ static void __exit exit_nfsd(void)
 	remove_proc_entry("fs/nfs", NULL);
 	nfsd_stat_shutdown();
 	nfsd_lockd_shutdown();
+	nfs4_state_shutdown();
 	unregister_filesystem(&nfsd_fs_type);
 }
 

diff ./include/linux/nfsd/nfsd.h~current~ ./include/linux/nfsd/nfsd.h
--- ./include/linux/nfsd/nfsd.h~current~	2003-04-13 16:15:50.000000000 +1000
+++ ./include/linux/nfsd/nfsd.h	2003-04-13 16:15:50.000000000 +1000
@@ -117,6 +117,17 @@ int		nfsd_notify_change(struct inode *, 
 int		nfsd_permission(struct svc_export *, struct dentry *, int);
 
 
+/* 
+ * NFSv4 State
+ */
+#ifdef CONFIG_NFSD_V4
+void nfs4_state_init(void);
+void nfs4_state_shutdown(void);
+#else
+void static inline nfs4_state_init(void){}
+void static inline nfs4_state_shutdown(void){}
+#endif
+
 /*
  * lockd binding
  */
@@ -162,6 +173,7 @@ void		nfsd_lockd_shutdown(void);
 #define	nfserr_bad_cookie	__constant_htonl(NFSERR_BAD_COOKIE)
 #define	nfserr_same		__constant_htonl(NFSERR_SAME)
 #define	nfserr_clid_inuse	__constant_htonl(NFSERR_CLID_INUSE)
+#define	nfserr_stale_clientid	__constant_htonl(NFSERR_STALE_CLIENTID)
 #define	nfserr_resource		__constant_htonl(NFSERR_RESOURCE)
 #define	nfserr_nofilehandle	__constant_htonl(NFSERR_NOFILEHANDLE)
 #define	nfserr_minor_vers_mismatch	__constant_htonl(NFSERR_MINOR_VERS_MISMATCH)

diff ./include/linux/nfsd/state.h~current~ ./include/linux/nfsd/state.h
--- ./include/linux/nfsd/state.h~current~	2003-04-13 16:15:50.000000000 +1000
+++ ./include/linux/nfsd/state.h	2003-04-13 16:15:50.000000000 +1000
@@ -0,0 +1,63 @@
+/*
+ *  linux/include/nfsd/state.h
+ *
+ *  Copyright (c) 2001 The Regents of the University of Michigan.
+ *  All rights reserved.
+ *
+ *  Kendrick Smith <kmsmith@umich.edu>
+ *  Andy Adamson <andros@umich.edu>
+ *  
+ *  Redistribution and use in source and binary forms, with or without
+ *  modification, are permitted provided that the following conditions
+ *  are met:
+ *  
+ *  1. Redistributions of source code must retain the above copyright
+ *     notice, this list of conditions and the following disclaimer.
+ *  2. Redistributions in binary form must reproduce the above copyright
+ *     notice, this list of conditions and the following disclaimer in the
+ *     documentation and/or other materials provided with the distribution.
+ *  3. Neither the name of the University nor the names of its
+ *     contributors may be used to endorse or promote products derived
+ *     from this software without specific prior written permission.
+ *
+ *  THIS SOFTWARE IS PROVIDED ``AS IS'' AND ANY EXPRESS OR IMPLIED
+ *  WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED WARRANTIES OF
+ *  MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE
+ *  DISCLAIMED. IN NO EVENT SHALL THE REGENTS OR CONTRIBUTORS BE LIABLE
+ *  FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR
+ *  CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF
+ *  SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR
+ *  BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF
+ *  LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING
+ *  NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS
+ *  SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
+ *
+ */
+
+#ifndef _NFSD4_STATE_H
+#define _NFSD4_STATE_H
+
+#include <linux/list.h>
+
+#define NFSD4_CLIENT_MAXNAME 1024
+
+extern int nfsd4_setclientid(struct svc_rqst *rqstp, struct nfsd4_setclientid *setclid);
+
+/*
+ * struct nfs4_client - one per client.  Clientids live here.
+ * 	o Each nfs4_client is hashed by clientid.
+ *
+ * 	o Each nfs4_clients is also hashed by name 
+ * 	  (the opaque quantity initially sent by the client to identify itself).
+ */
+struct nfs4_client {
+	struct list_head	cl_idhash; 	/* hash by cl_clientid.id */
+	struct list_head	cl_strhash; 	/* hash by cl_name */
+	struct xdr_netobj	cl_name; 	/* id generated by client */
+	nfs4_verifier		cl_verifier; 	/* generated by client */
+	u32			cl_addr; 	/* client ipaddress */
+	struct svc_cred		cl_cred; 	/* setclientid principal */
+	clientid_t		cl_clientid;	/* generated by server */
+	nfs4_verifier		cl_confirm;	/* generated by server */
+};
+#endif   /* NFSD4_STATE_H */


-------------------------------------------------------
This SF.net email is sponsored by: Etnus, makers of TotalView, The debugger 
for complex code. Debugging C/C++ programs can leave you feeling lost and 
disoriented. TotalView can help you find your way. Available on major UNIX 
and Linux platforms. Try it free. www.etnus.com
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
