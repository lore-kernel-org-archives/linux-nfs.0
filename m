From: Greg Banks <gnb@melbourne.sgi.com>
Subject: Re: [PATCH] SGI 907674: document fsid export option
Date: Fri, 27 Feb 2004 22:37:41 +1100
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <403F2C05.EF210E45@melbourne.sgi.com>
References: <40188282.36FBA905@melbourne.sgi.com>
		<16442.51053.96888.392883@notabene.cse.unsw.edu.au>
		<403ACE01.2BBF39D6@melbourne.sgi.com>
		<16442.52922.613916.868991@notabene.cse.unsw.edu.au>
		<403AD38A.58FACE61@melbourne.sgi.com>
		<16443.59027.38890.186568@notabene.cse.unsw.edu.au>
		<403BECC5.F8D65725@melbourne.sgi.com> <16444.5325.978979.117912@notabene.cse.unsw.edu.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Linux NFS Mailing List <nfs@lists.sourceforge.net>
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.12] helo=sc8-sf-mx2.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1AwgLr-0005jL-58
	for nfs@lists.sourceforge.net; Fri, 27 Feb 2004 03:40:19 -0800
Received: from mtvcafw.sgi.com ([192.48.171.6] helo=zok.sgi.com)
	by sc8-sf-mx2.sourceforge.net with esmtp (Exim 4.30)
	id 1Awg4u-0001ez-21
	for nfs@lists.sourceforge.net; Fri, 27 Feb 2004 03:22:48 -0800
To: Neil Brown <neilb@cse.unsw.edu.au>
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

Neil Brown wrote:
> 
> On Wednesday February 25, gnb@melbourne.sgi.com wrote:
> > Neil Brown wrote:
> >
> > > This interface is not needed in 2.6 and will be going away in 2.7, and
> > > the new interface (via text written into /proc ) doesn't have the 16
> > > bit limit.
> > >
> > > I think we should document it as a 32bit number, but note that only 16
> > > bits are significant in certain situations.
> >
> > >From my reading of nfs-utils last night it seems it still gets truncated
> > even with the new interface, because a struct nfsctl_export is used as
> > temporary storage.
> 
> Hmm.  That can and should be fixed.  I will look at it.



This patch against nfs-utils 1.0.6 enables 32 bit fsid when the new
/proc/fs/nfsd interface is being used.  It even works with fsid > 2^31
(although both the kernel and nfs-utils print such fsids as negative,
they do work).

I have a much larger and uglier patch which enables 32 bit fsid on
2.4 kernels and the 2.6 kernels using nfsservctl(), which does work
but I believe risks compatibility issues.  I won't post it.



diff -Napur --exclude-from=excludes
nfs-utils-sgi/nfs-utils-1.0.6/support/include/nfs/nfs.h
nfs-utils-work/nfs-utils-1.0.6/support/include/nfs/nfs.h
--- nfs-utils-sgi/nfs-utils-1.0.6/support/include/nfs/nfs.h	Wed Feb 25 20:43:02 2004
+++ nfs-utils-work/nfs-utils-1.0.6/support/include/nfs/nfs.h	Fri Feb 27 21:49:58 2004
@@ -71,7 +71,8 @@ struct nfsctl_client {
 #endif
 
 /* EXPORT/UNEXPORT */
-struct nfsctl_export {
+/* kernel's version */
+struct nfsctl_kexport {
 	char			ex_client[NFSCLNT_IDMAX+1];
 	char			ex_path[NFS_MAXPATHLEN+1];
 	__nfsd_dev_t		ex_dev;
@@ -80,6 +81,18 @@ struct nfsctl_export {
 	__kernel_uid_t		ex_anon_uid;
 	__kernel_gid_t		ex_anon_gid;
 };
+/* userspace version with 32bit ex_dev/fsid field */
+struct nfsctl_export {
+	char			ex_client[NFSCLNT_IDMAX+1];
+	char			ex_path[NFS_MAXPATHLEN+1];
+	__nfsd_dev_t		ex_unused1;
+	__kernel_ino_t		ex_ino;
+	int			ex_flags;
+	__kernel_uid_t		ex_anon_uid;
+	__kernel_gid_t		ex_anon_gid;
+
+	uint32_t		ex_dev;
+};
 
 /* UGIDUPDATE */
 struct nfsctl_uidmap {
@@ -128,7 +141,7 @@ struct nfsctl_arg {
 	union {
 		struct nfsctl_svc	u_svc;
 		struct nfsctl_client	u_client;
-		struct nfsctl_export	u_export;
+		struct nfsctl_kexport	u_export;
 		struct nfsctl_uidmap	u_umap;
 		struct nfsctl_fhparm	u_getfh;
 		struct nfsctl_fdparm	u_getfd;
diff -Napur --exclude-from=excludes
nfs-utils-sgi/nfs-utils-1.0.6/support/nfs/nfsexport.c
nfs-utils-work/nfs-utils-1.0.6/support/nfs/nfsexport.c
--- nfs-utils-sgi/nfs-utils-1.0.6/support/nfs/nfsexport.c	Fri Aug  1 13:42:04 2003
+++ nfs-utils-work/nfs-utils-1.0.6/support/nfs/nfsexport.c	Fri Feb 27 21:50:43 2004
@@ -99,6 +99,7 @@ nfsexport(struct nfsctl_export *exp)
 	}
 	arg.ca_version = NFSCTL_VERSION;
 	memcpy(&arg.ca_export, exp, sizeof(arg.ca_export));
+	arg.ca_export.ex_dev = (__nfsd_dev_t)exp->ex_dev;
 	return nfsctl(NFSCTL_EXPORT, &arg, NULL);
 }
 
@@ -115,5 +116,6 @@ nfsunexport(struct nfsctl_export *exp)
 
 	arg.ca_version = NFSCTL_VERSION;
 	memcpy(&arg.ca_export, exp, sizeof(arg.ca_export));
+	arg.ca_export.ex_dev = (__nfsd_dev_t)exp->ex_dev;
 	return nfsctl(NFSCTL_UNEXPORT, &arg, NULL);
 }



Greg.
-- 
Greg Banks, R&D Software Engineer, SGI Australian Software Group.
I don't speak for SGI.


-------------------------------------------------------
SF.Net is sponsored by: Speed Start Your Linux Apps Now.
Build and deploy apps & Web services for Linux with
a free DVD software kit from IBM. Click Now!
http://ads.osdn.com/?ad_id=1356&alloc_id=3438&op=click
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
