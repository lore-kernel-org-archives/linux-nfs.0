From: Shehjar Tikoo <shehjart-YbfuJp6tym7X/JP9YwkgDA@public.gmane.org>
Subject: Re: Doc for adding new NFS export option
Date: Wed, 09 Jul 2008 12:45:15 +1000
Message-ID: <4874263B.50902@cse.unsw.edu.au>
References: <48718FF4.4030200@cse.unsw.edu.au> <18545.47041.516146.605353@notabene.brown>
Mime-Version: 1.0
Content-Type: multipart/mixed;
 boundary="------------020502040307080806040800"
Cc: linux-nfs@vger.kernel.org
To: Neil Brown <neilb@suse.de>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from tone.orchestra.cse.unsw.EDU.AU ([129.94.242.59]:50235 "EHLO
	tone.orchestra.cse.unsw.EDU.AU" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1752902AbYGIC7Z (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Tue, 8 Jul 2008 22:59:25 -0400
In-Reply-To: <18545.47041.516146.605353-wvvUuzkyo1EYVZTmpyfIwg@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

This is a multi-part message in MIME format.
--------------020502040307080806040800
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit

Neil Brown wrote:
> On Monday July 7, shehjart-YbfuJp6tym7X/JP9YwkgDA@public.gmane.org wrote:
>> Hi All
>>
>> Is there a document that enumerates which files and functions I need 
>> to add stuff to, for adding a new server-side export option?
> 
> No.  I think the theory is that unless you have read and understood
> the code, you should really be thinking about adding new options.
> And if you have, then you don't need any documentations.
> :-)
> 
>> I've tried adding it to some of the functions in the exportfs related 
>> code in nfs-utils and also in the kernel's export related headers but 
>> I dont think that is all there is to it.
> 
> That sounds good, but without details, it is hard to be sure.
> Don't be afraid to send a patch which shows what you are trying to do.

See the two diffs attached here:

1. nfs_utils_add_prealloc.diff
Adds support for "prealloc" and "no_prealloc" export options to 
nfs-utils. Based on the latest nfs-utils at:
git://linux-nfs.org/nfs-utils

2. add_nfsd_prealloc.diff
Adds support to kernel for the two options above. Based on 2.6.25.10 
git checkout from:
git://git.kernel.org/pub/scm/linux/kernel/git/stable/linux-2.6.25.y.git

The patches dont actually make nfsd do anything at this point because 
to do any "prealloc" related work, I first need to be able to mount 
the export with the new option. :)

>> I ask this because without my new option, I am able to mount the 
>> export correctly but with it, the mount command fails with the 
>> following message:
>>
>> mount.nfs: 192.168.10.5:/data/nfstest failed, reason given by server: 
>> Permission denied
The above behaviour was observed with nfs-utils 1.1.2.
The strange thing is, for nfs-utils from the git repo, with the 
patches above, mount command returns the same error regardless of 
whether "prealloc" option is specified in /etc/exports.

> 
> So what exactly is this new export option that you want to add?

As the option's name suggests, the idea is to use fallocate support in 
ext4 and XFS, to pre-allocate disk blocks. I feel this might help nfsd 
  sync writes where each write request has to go to disk almost ASAP. 
Because NFSv3 writes have to be stable(..not sure about NFSv4..), the 
write-to-disk and block allocation must happen immediately. It is 
possible that the blocks being allocated for each NFS sync write are 
not as contiguous as they could be for say, local buffered writes.
I am hoping that by using some form of adaptive pre-allocation we can 
improve the contiguity of disk blocks for nfsd writes.

This will help in two ways:

1. Disk block allocation will be invoked in its entirety at less 
frequent intervals(..i.e. not on every NFS write request..) because 
we'll be pre-allocating larger blocks.
At this point, I am not sure what exactly the block allocation 
overhead is, but I'll measure all that once I have a prototype working.

2. Read-ahead will benefit because the blocks being allocated are 
contiguous.

Thanks
Shehjar

> 
> NeilBrown

--------------020502040307080806040800
Content-Type: text/x-patch;
 name="nfs_utils_add_prealloc.diff"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline;
 filename="nfs_utils_add_prealloc.diff"

diff --git a/support/include/nfs/export.h b/support/include/nfs/export.h
index f7a99ba..0911c9a 100644
--- a/support/include/nfs/export.h
+++ b/support/include/nfs/export.h
@@ -17,7 +17,8 @@
 #define NFSEXP_ALLSQUASH	0x0008
 #define NFSEXP_ASYNC		0x0010
 #define NFSEXP_GATHERED_WRITES	0x0020
-/* 40, 80, 100 unused */
+#define NFSEXP_PREALLOC		0x0040
+/* 80, 100 unused */
 #define NFSEXP_NOHIDE		0x0200
 #define NFSEXP_NOSUBTREECHECK	0x0400
 #define NFSEXP_NOAUTHNLM	0x0800
diff --git a/support/nfs/exports.c b/support/nfs/exports.c
index 525e5b1..16d03cc 100644
--- a/support/nfs/exports.c
+++ b/support/nfs/exports.c
@@ -111,6 +111,7 @@ getexportent(int fromkernel, int fromexports)
 		if (fromkernel) {
 			def_ee.e_flags &= ~NFSEXP_ASYNC;
 			def_ee.e_flags &= ~NFSEXP_GATHERED_WRITES;
+			def_ee.e_flags &= ~NFSEXP_PREALLOC;
 		}
 		def_ee.e_anonuid = 65534;
 		def_ee.e_anongid = 65534;
@@ -237,6 +238,7 @@ putexportent(struct exportent *ep)
 	fprintf(fp, "%ssync,", (ep->e_flags & NFSEXP_ASYNC)? "a" : "");
 	fprintf(fp, "%swdelay,", (ep->e_flags & NFSEXP_GATHERED_WRITES)?
 				"" : "no_");
+	fprintf(fp, "%sprealloc,", (ep->e_flags & NFSEXP_PREALLOC)? "" : "no_");
 	fprintf(fp, "%shide,", (ep->e_flags & NFSEXP_NOHIDE)?
 				"no" : "");
 	fprintf(fp, "%scrossmnt,", (ep->e_flags & NFSEXP_CROSSMOUNT)?
@@ -558,6 +560,10 @@ parseopts(char *cp, struct exportent *ep, int warn, int *had_subtree_opt_ptr)
 			ep->e_flags &= ~NFSEXP_NOACL;
 		else if (strcmp(opt, "no_acl") == 0)
 			ep->e_flags |= NFSEXP_NOACL;
+		else if (strcmp(opt, "prealloc") == 0)
+			ep->e_flags |= NFSEXP_PREALLOC;
+		else if (strcmp(opt, "no_prealloc") == 0)
+			ep->e_flags &= ~NFSEXP_PREALLOC;
 		else if (strncmp(opt, "anonuid=", 8) == 0) {
 			char *oe;
 			ep->e_anonuid = strtol(opt+8, &oe, 10);
diff --git a/utils/exportfs/exportfs.c b/utils/exportfs/exportfs.c
index 18dfe5a..03dbdca 100644
--- a/utils/exportfs/exportfs.c
+++ b/utils/exportfs/exportfs.c
@@ -470,6 +470,8 @@ dump(int verbose)
 				c = dumpopt(c, "async");
 			if (ep->e_flags & NFSEXP_GATHERED_WRITES)
 				c = dumpopt(c, "wdelay");
+			if (ep->e_flags & NFSEXP_PREALLOC)
+				c = dumpopt(c, "prealloc");
 			if (ep->e_flags & NFSEXP_NOHIDE)
 				c = dumpopt(c, "nohide");
 			if (ep->e_flags & NFSEXP_CROSSMOUNT)

--------------020502040307080806040800
Content-Type: text/x-patch;
 name="add_nfsd_prealloc.diff"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline;
 filename="add_nfsd_prealloc.diff"

diff --git a/fs/nfsd/export.c b/fs/nfsd/export.c
index 8a6f7c9..5bb2bd5 100644
--- a/fs/nfsd/export.c
+++ b/fs/nfsd/export.c
@@ -1439,6 +1439,7 @@ static struct flags {
 	{ NFSEXP_CROSSMOUNT, {"crossmnt", ""}},
 	{ NFSEXP_NOSUBTREECHECK, {"no_subtree_check", ""}},
 	{ NFSEXP_NOAUTHNLM, {"insecure_locks", ""}},
+	{ NFSEXP_PREALLOC, {"prealloc", "no_prealloc"}},
 #ifdef MSNFS
 	{ NFSEXP_MSNFS, {"msnfs", ""}},
 #endif
diff --git a/include/linux/nfsd/export.h b/include/linux/nfsd/export.h
index 5431512..0310659 100644
--- a/include/linux/nfsd/export.h
+++ b/include/linux/nfsd/export.h
@@ -32,7 +32,8 @@
 #define NFSEXP_ALLSQUASH	0x0008
 #define NFSEXP_ASYNC		0x0010
 #define NFSEXP_GATHERED_WRITES	0x0020
-/* 40 80 100 currently unused */
+#define NFSEXP_PREALLOC		0x0040
+/* 80 100 currently unused */
 #define NFSEXP_NOHIDE		0x0200
 #define NFSEXP_NOSUBTREECHECK	0x0400
 #define	NFSEXP_NOAUTHNLM	0x0800		/* Don't authenticate NLM requests - just trust */
@@ -40,7 +41,7 @@
 #define NFSEXP_FSID		0x2000
 #define	NFSEXP_CROSSMOUNT	0x4000
 #define	NFSEXP_NOACL		0x8000	/* reserved for possible ACL related use */
-#define NFSEXP_ALLFLAGS		0xFE3F
+#define NFSEXP_ALLFLAGS		0xFE7F
 
 /* The flags that may vary depending on security flavor: */
 #define NFSEXP_SECINFO_FLAGS	(NFSEXP_READONLY | NFSEXP_ROOTSQUASH \
@@ -113,6 +114,7 @@ struct svc_expkey {
 #define EX_ISSYNC(exp)		(!((exp)->ex_flags & NFSEXP_ASYNC))
 #define EX_NOHIDE(exp)		((exp)->ex_flags & NFSEXP_NOHIDE)
 #define EX_WGATHER(exp)		((exp)->ex_flags & NFSEXP_GATHERED_WRITES)
+#define EX_PREALLOC(exp)	((exp)->ex_flags & NFSEXP_PREALLOC)
 
 int nfsexp_flags(struct svc_rqst *rqstp, struct svc_export *exp);
 __be32 check_nfsd_access(struct svc_export *exp, struct svc_rqst *rqstp);

--------------020502040307080806040800--
