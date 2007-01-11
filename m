From: Neil Brown <neilb@suse.de>
Subject: Re: nfs mount problem on vxfs
Date: Thu, 11 Jan 2007 13:12:49 +1100
Message-ID: <17829.40225.312372.954156@notabene.brown>
References: <56800.63.119.254.10.1168372296.squirrel@mail.sonysnowie.com>
	<20070110124704.GA3350@infradead.org>
	<1168447645.13083.2.camel@lade.trondhjem.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: Christoph Hellwig <hch@infradead.org>, nfs@lists.sourceforge.net
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.91]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1H4pRd-0005Qp-6i
	for nfs@lists.sourceforge.net; Wed, 10 Jan 2007 18:13:33 -0800
Received: from ns2.suse.de ([195.135.220.15] helo=mx2.suse.de)
	by mail.sourceforge.net with esmtps (TLSv1:AES256-SHA:256)
	(Exim 4.44) id 1H4pRe-0005z3-2I
	for nfs@lists.sourceforge.net; Wed, 10 Jan 2007 18:13:35 -0800
To: Trond Myklebust <trond.myklebust@fys.uio.no>
In-Reply-To: message from Trond Myklebust on Wednesday January 10
List-Id: "Discussion of NFS under Linux development, interoperability,
	and testing." <nfs.lists.sourceforge.net>
List-Unsubscribe: <https://lists.sourceforge.net/lists/listinfo/nfs>,
	<mailto:nfs-request@lists.sourceforge.net?subject=unsubscribe>
List-Archive: <http://sourceforge.net/mailarchive/forum.php?forum=nfs>
List-Post: <mailto:nfs@lists.sourceforge.net>
List-Help: <mailto:nfs-request@lists.sourceforge.net?subject=help>
List-Subscribe: <https://lists.sourceforge.net/lists/listinfo/nfs>,
	<mailto:nfs-request@lists.sourceforge.net?subject=subscribe>
Sender: nfs-bounces@lists.sourceforge.net
Errors-To: nfs-bounces@lists.sourceforge.net

On Wednesday January 10, trond.myklebust@fys.uio.no wrote:
> On Wed, 2007-01-10 at 12:47 +0000, Christoph Hellwig wrote:
> 
> > I haven't added support for nfs exporting to the vxfs driver.  To be honest
> > it's quite old and didn't resource (time and actual  vxfs native systems)
> > to test it again.
> 
> That brings up a point. Given that vxfs doesn't even define s_export_op,
> why is he seeing a hang rather than an error?
> 
> It sounds to me as if he should be getting an EINVAL error on the call
> to 'exportfs' on the server, as well as an immediate EACCES error when
> he tries to mount it from the client.
> 
> Neil?

'exportfs' doesn't talk to the kernel any more.  It just validates
/etc/exports and copies it to /var/lib/nfs/etab.  It might flush the
kernel tables but that is all.  So it cannot report an error.

Then when the mount is attempted, mountd exports the filesystem
without checking for errors....  I guess that could be fixed.
Then mountd tries to get the filehandle which probably triggers an
upcall to mountd which blocks and everything hangs.

I'd better go add some error checking.

Thanks,
NeilBrown

commit 8fd9fad1ea4b25b8962d70133f476650ef0637b0
Author: Neil Brown <neilb@suse.de>
Date:   Thu Jan 11 12:45:48 2007 +1100

    Error check messages sent to the kernel.
    
    And make sure that if we fail to export a filesystem in mountd,
    then we don't try to get a filehandle on it, or a deadlock
    might occur.

diff --git a/support/include/nfslib.h b/support/include/nfslib.h
index 3e25761..aba37c2 100644
--- a/support/include/nfslib.h
+++ b/support/include/nfslib.h
@@ -132,7 +132,7 @@ struct nfs_fh_len *	getfh_size(struct sockaddr *addr, const char *, int size);
 void qword_print(FILE *f, char *str);
 void qword_printhex(FILE *f, char *str, int slen);
 void qword_printint(FILE *f, int num);
-void qword_eol(FILE *f);
+int qword_eol(FILE *f);
 int readline(int fd, char **buf, int *lenp);
 int qword_get(char **bpp, char *dest, int bufsize);
 int qword_get_int(char **bpp, int *anint);
diff --git a/support/nfs/cacheio.c b/support/nfs/cacheio.c
index 3e868d8..36473cf 100644
--- a/support/nfs/cacheio.c
+++ b/support/nfs/cacheio.c
@@ -109,10 +109,10 @@ void qword_printint(FILE *f, int num)
 	fprintf(f, "%d ", num);
 }
 
-void qword_eol(FILE *f)
+int qword_eol(FILE *f)
 {
 	fprintf(f,"\n");
-	fflush(f);
+	return fflush(f);
 }
 
 
diff --git a/support/nfs/nfsexport.c b/support/nfs/nfsexport.c
index aa0e49b..f129fd2 100644
--- a/support/nfs/nfsexport.c
+++ b/support/nfs/nfsexport.c
@@ -38,6 +38,7 @@ exp_unexp(struct nfsctl_export *exp, int export)
 	char fsidstr[8];
 	__u16 dev;
 	__u32 inode;
+	int err;
 
 
 	f = fopen("/proc/net/rpc/nfsd.export/channel", "w");
@@ -53,7 +54,7 @@ exp_unexp(struct nfsctl_export *exp, int export)
 	} else
 		qword_printint(f, 1);
 
-	qword_eol(f);
+	err = qword_eol(f);
 	fclose(f);
 
 	if (stat(exp->ex_path, &stb) != 0)
@@ -71,7 +72,7 @@ exp_unexp(struct nfsctl_export *exp, int export)
 		} else
 			qword_printint(f, 1);
 
-		qword_eol(f);
+		err = qword_eol(f) || err;
 	}
 	qword_print(f,exp->ex_client);
 	qword_printint(f,0);
@@ -85,9 +86,9 @@ exp_unexp(struct nfsctl_export *exp, int export)
 		qword_print(f, exp->ex_path);
 	} else
 		qword_printint(f, 1);
-	qword_eol(f);
+	err = qword_eol(f) || err;
 	fclose(f);
-	return 0;
+	return err;
 }
 
 int
diff --git a/utils/gssd/cacheio.c b/utils/gssd/cacheio.c
index 75c7a5d..f2f2960 100644
--- a/utils/gssd/cacheio.c
+++ b/utils/gssd/cacheio.c
@@ -173,11 +173,13 @@ void qword_printint(FILE *f, int num)
 	printerr(2, "%d ", num);
 }
 
-void qword_eol(FILE *f)
+int qword_eol(FILE *f)
 {
+	int err;
 	fprintf(f,"\n");
-	fflush(f);
+	err = fflush(f);
 	printerr(2, "\n");
+	return err;
 }
 
 
diff --git a/utils/gssd/cacheio.h b/utils/gssd/cacheio.h
index cc97b36..dfff258 100644
--- a/utils/gssd/cacheio.h
+++ b/utils/gssd/cacheio.h
@@ -40,7 +40,7 @@ void qword_addeol(char **bpp, int *lp);
 void qword_print(FILE *f, char *str);
 void qword_printhex(FILE *f, char *str, int slen);
 void qword_printint(FILE *f, int num);
-void qword_eol(FILE *f);
+int qword_eol(FILE *f);
 int readline(int fd, char **buf, int *lenp);
 int qword_get(char **bpp, char *dest, int bufsize);
 int qword_get_int(char **bpp, int *anint);
diff --git a/utils/gssd/svcgssd_proc.c b/utils/gssd/svcgssd_proc.c
index 7981399..4037159 100644
--- a/utils/gssd/svcgssd_proc.c
+++ b/utils/gssd/svcgssd_proc.c
@@ -72,6 +72,7 @@ do_svc_downcall(gss_buffer_desc *out_handle, struct svc_cred *cred,
 	FILE *f;
 	int i;
 	char *fname = NULL;
+	int err;
 
 	printerr(1, "doing downcall\n");
 	if ((fname = mech2file(mech)) == NULL)
@@ -93,9 +94,9 @@ do_svc_downcall(gss_buffer_desc *out_handle, struct svc_cred *cred,
 		qword_printint(f, cred->cr_groups[i]);
 	qword_print(f, fname);
 	qword_printhex(f, context_token->value, context_token->length);
-	qword_eol(f);
+	err = qword_eol(f);
 	fclose(f);
-	return 0;
+	return err;
 out_err:
 	printerr(0, "WARNING: downcall failed\n");
 	return -1;
diff --git a/utils/mountd/cache.c b/utils/mountd/cache.c
index 726b98f..dcb5dac 100644
--- a/utils/mountd/cache.c
+++ b/utils/mountd/cache.c
@@ -35,7 +35,7 @@
  * Record is terminated with newline.
  *
  */
-void cache_export_ent(char *domain, struct exportent *exp);
+int cache_export_ent(char *domain, struct exportent *exp);
 
 
 char *lbuf  = NULL;
@@ -352,12 +352,12 @@ int cache_process_req(fd_set *readfds)
  * % echo $domain $path $[now+30*60] $options $anonuid $anongid $fsid > /proc/net/rpc/nfsd.export/channel
  */
 
-void cache_export_ent(char *domain, struct exportent *exp)
+int cache_export_ent(char *domain, struct exportent *exp)
 {
-
+	int err;
 	FILE *f = fopen("/proc/net/rpc/nfsd.export/channel", "w");
 	if (!f)
-		return;
+		return -1;
 
 	qword_print(f, domain);
 	qword_print(f, exp->e_path);
@@ -366,28 +366,32 @@ void cache_export_ent(char *domain, struct exportent *exp)
 	qword_printint(f, exp->e_anonuid);
 	qword_printint(f, exp->e_anongid);
 	qword_printint(f, exp->e_fsid);
-	qword_eol(f);
+	err = qword_eol(f);
 
 	fclose(f);
+	return err;
 }
 
-void cache_export(nfs_export *exp)
+int cache_export(nfs_export *exp)
 {
+	int err;
 	FILE *f;
 
 	f = fopen("/proc/net/rpc/auth.unix.ip/channel", "w");
 	if (!f)
-		return;
+		return -1;
 
 	qword_print(f, "nfsd");
 	qword_print(f, inet_ntoa(exp->m_client->m_addrlist[0]));
 	qword_printint(f, time(0)+30*60);
 	qword_print(f, exp->m_client->m_hostname);
-	qword_eol(f);
+	err = qword_eol(f);
 	
 	fclose(f);
 
-	cache_export_ent(exp->m_client->m_hostname, &exp->m_export);
+	err = cache_export_ent(exp->m_client->m_hostname, &exp->m_export)
+		|| err;
+	return err;
 }
 
 /* Get a filehandle.
@@ -413,9 +417,10 @@ cache_get_filehandle(nfs_export *exp, int len, char *p)
 	qword_print(f, exp->m_client->m_hostname);
 	qword_print(f, p);
 	qword_printint(f, len);	
-	qword_eol(f);
+	failed = qword_eol(f);
 	
-	failed = (fgets(buf, sizeof(buf), f) == NULL);
+	if (!failed)
+		failed = (fgets(buf, sizeof(buf), f) == NULL);
 	fclose(f);
 	if (failed)
 		return NULL;
diff --git a/utils/mountd/mountd.c b/utils/mountd/mountd.c
index 08f294d..72332ce 100644
--- a/utils/mountd/mountd.c
+++ b/utils/mountd/mountd.c
@@ -29,7 +29,7 @@
 
 extern void	cache_open(void);
 extern struct nfs_fh_len *cache_get_filehandle(nfs_export *exp, int len, char *p);
-extern void cache_export(nfs_export *exp);
+extern int cache_export(nfs_export *exp);
 
 extern void my_svc_run(void);
 
@@ -416,7 +416,10 @@ get_rootfh(struct svc_req *rqstp, dirpath *path, mountstat3 *error, int v3)
 		 */
 		struct nfs_fh_len  *fh;
 
-		cache_export(exp);
+		if (cache_export(exp)) {
+			*error = NFSERR_ACCES;
+			return NULL;
+		}
 		fh = cache_get_filehandle(exp, v3?64:32, p);
 		if (fh == NULL) 
 			*error = NFSERR_ACCES;

-------------------------------------------------------------------------
Take Surveys. Earn Cash. Influence the Future of IT
Join SourceForge.net's Techsay panel and you'll get the chance to share your
opinions on IT & business topics through brief surveys - and earn cash
http://www.techsay.com/default.php?page=join.php&p=sourceforge&CID=DEVDEV
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
