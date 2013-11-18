Return-Path: linux-nfs-owner@vger.kernel.org
Received: from colin.muc.de ([193.149.48.1]:26098 "EHLO mail.muc.de"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751628Ab3KRMus (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Mon, 18 Nov 2013 07:50:48 -0500
Date: Mon, 18 Nov 2013 13:44:06 +0100
From: Albert Fluegel <af@muc.de>
To: linux-nfs@vger.kernel.org
Subject: Bugs / Patch in nfsd
Message-ID: <20131118124406.GA46678@colin.muc.de>
MIME-Version: 1.0
Content-Type: multipart/mixed; boundary="EeQfGwPcQSOJBaQU"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>


--EeQfGwPcQSOJBaQU
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline

Hello,

i posted Bug 1028439 to bugzilla.redhat.com and was asked to post the patch
to this mailing list for discussion and possibly upstream fix.

As most of the followers here probably do not have access to the redhat
bugzilla, i'll repeat the most important parts of the report here. A proposed
patch is attached. Sorry, this is not short, but it's not a simle topic

Description of problem:
When a Solaris 2.5, 2.6, 7 or Solaris 8 client uses a Linux
NFS (version 3) server, the directories are messed up over NFS,
many files not found. As an example, GNU make 3.81 is tried to build.
After the configure step running make the Makefile is not found.
Some lines from truss showing an inconsistency:
...
stat(".", 0xFFBEE628)                           = 0
open64(".", O_RDONLY|O_NDELAY)                  = 3
fcntl(3, F_SETFD, 0x00000001)                   = 0
fstat64(3, 0xFFBEE4F8)                          = 0
getdents64(3, 0x00054FE0, 1048)                 = 1024
close(3)                                        = 0
stat("GNUmakefile", 0xFFBEE708)                 Err#2 ENOENT
stat("makefile", 0xFFBEE708)                    Err#2 ENOENT
stat("Makefile", 0xFFBEE708)                    = 0
makewrite(2, " m a k e", 4)                             = 4
: *** write(2, " :   * * *  ", 6)                       = 6
No targets specified and no makefile foundwrite(2, " N o   t a r g e t s   s".., 42)    = 42

prompt% ls Makefile
Makefile

The problem does not show up with Linux or e.g. SunOS-4 NFS clients.

What i've seen on the network is, that the
Linux NFS server replies among other things to a "Check access permission"
the following:

NFS:    File type = 2 (Directory)
NFS:    Mode = 040755

A netapp server replies here:
NFS:    File type = 2 (Directory)
NFS:    Mode = 0755

The RFC 1813 i read:
   fattr3

      struct fattr3 {
         ftype3     type;
         mode3      mode;
         uint32     nlink;
...
For the mode bits only the lowest 9 are defined in the RFC

The problem occurs with the kernels 2.6.18-348.3.1.el5 upward for RHEL5,
2.6.32-358.18.1.el6 upward and some versions earlier and with Fedora kernel
3.9.10-100 on the NFS server

There seem to be several issues, all caused by the 64 bit cookies enabled,
directly or indirectly.
One change:
diff -r kernel-2.6.18-308/linux-2.6.18-308.11.1.el5.i386/fs/nfsd/vfs.c kernel-2.6.18-348/linux-2.6.18-348.3.1.el5.i386/fs/nfsd/vfs.c
725a727,733
> 	else {
> 		if (may_flags & NFSD_MAY_64BIT_COOKIE)
> 			(*filp)->f_mode |= FMODE_64BITHASH;
> 		else
> 			(*filp)->f_mode |= FMODE_32BITHASH;
> 	}
> 

makes bits set in the mode field of the
RPC reply, that are used internally by the kernel.
They should really not go into the RPC reply.
imo these internally used bits should be set in an own component of
the struct and not in f_mode (like the f_type, which is separate).
Probably for NFSv4 this must be fixed, too.

The other problem is, that the nfsd_readdir seems not to find cookies
or at least does not position the read pointer correctly and starts
reading the directory anew, causing the (Solaris) client to be in an
endless loop. The cookie returned in a "Read Directory" reply is actually
32 bit and with the next query issued with this (identical) cookie
the Linux NFS server replies with the directories started anew.
I don't know, in how far the cookies depend on the client. However,
with a Solaris client i consider it worth noting, that in the reply
to the directory read the upper 32 bits are either all 0 or all 1
(0xffffffff). With a Linux client, they are either 0 or have some
random value, but not constantly 0xffffffff .

How to definitely correctly fix this cookie oddity is imo up to the
maintainers. In the meantime i propose the attached patch to mask
out the internally used FMODE_*BITHASH flags from the mode in the
RPC reply and to use only 32 bit cookies.

Regarding the cookie thing i don't think the clients misbehave.
Linux clients seem to evaluate an entire reply to a "Read Directory" and
use the cookie of the last received entry for the next query. Solaris in
my test case with the unpacked GNU make 3.81 uses about 60% of the entries
and puts the cookie of the next one into the next "Read Directory"
NFS query to the server. As far as i can see in the wireshark evaluating
the network trace, the cookie is 100 % correct, but the Linux NFS server
starts with the beginning of the directory again in the next reply.
Could be, all cookies except the last one of the query are actually
unusable and the problem is not seen on a Linux NFS client, because it
always takes the last cookie for the next query.

The attached patches fix the problem with Solaris clients. With HP-UX
there's still trouble (stale filehandle all the time).
See the names of the patch files regarding for what kernel version they fit.
The first part of each fixes the higher bits problem in f_mode. The second
part disabled 64 bit cookies.

Thank you for looking into this.
Best Regards,
 Albert Fluegel


--EeQfGwPcQSOJBaQU
Content-Type: text/x-diff; charset=us-ascii
Content-Disposition: attachment; filename="kernel-2.6.18-af.patch"

--- linux-2.6.18-348.3.1.el5.i386/fs/nfsd//nfs3xdr.c	2013-11-14 14:39:32.000000000 +0100
+++ linux-2.6.18-348.3.1.el5.i386/fs/nfsd//nfs3xdr.c	2013-11-14 15:58:17.000000000 +0100
@@ -161,7 +161,7 @@
 	struct timespec time;
 
 	*p++ = htonl(nfs3_ftypes[(stat->mode & S_IFMT) >> 12]);
-	*p++ = htonl((u32) stat->mode);
+	*p++ = htonl((u32) (stat->mode & (S_IRWXU | S_IRWXG | S_IRWXO | S_ISUID | S_ISGID | S_ISVTX)));
 	*p++ = htonl((u32) stat->nlink);
 	*p++ = htonl((u32) nfsd_ruid(rqstp, stat->uid));
 	*p++ = htonl((u32) nfsd_rgid(rqstp, stat->gid));
@@ -193,7 +193,8 @@
 	*p++ = xdr_one;
 
 	*p++ = htonl(nfs3_ftypes[(fhp->fh_post_attr.mode & S_IFMT) >> 12]);
-	*p++ = htonl((u32) fhp->fh_post_attr.mode);
+	*p++ = htonl((u32) (fhp->fh_post_attr.mode
+				& (S_IRWXU | S_IRWXG | S_IRWXO | S_ISUID | S_ISGID | S_ISVTX)));
 	*p++ = htonl((u32) fhp->fh_post_attr.nlink);
 	*p++ = htonl((u32) nfsd_ruid(rqstp, fhp->fh_post_attr.uid));
 	*p++ = htonl((u32) nfsd_rgid(rqstp, fhp->fh_post_attr.gid));
--- linux-2.6.18-348.3.1.el5.i386/fs/nfsd/vfs.c	2013-11-14 14:39:32.000000000 +0100
+++ linux-2.6.18-348.3.1.el5.i386/fs/nfsd/vfs.c	2013-11-15 11:42:05.000000000 +0100
@@ -725,7 +725,7 @@
 	if (IS_ERR(*filp))
 		err = PTR_ERR(*filp);
 	else {
-		if (may_flags & NFSD_MAY_64BIT_COOKIE)
+		if (may_flags & NFSD_MAY_64BIT_COOKIE && 0)
 			(*filp)->f_mode |= FMODE_64BITHASH;
 		else
 			(*filp)->f_mode |= FMODE_32BITHASH;

--EeQfGwPcQSOJBaQU
Content-Type: text/x-diff; charset=us-ascii
Content-Disposition: attachment; filename="kernel-2.6.32-358.23.2-af.patch"

diff -ru linux-2.6.32-358.23.2.el6.x86_64/fs/nfsd/nfs3xdr.c linux-2.6.32-358.23.2.el6.x86_64.paf/fs/nfsd/nfs3xdr.c
--- linux-2.6.32-358.23.2.el6.x86_64.paf/fs/nfsd/nfs3xdr.c	2013-11-15 15:54:26.648622688 +0100
+++ linux-2.6.32-358.23.2.el6.x86_64/fs/nfsd/nfs3xdr.c	2013-09-14 10:52:32.000000000 +0200
@@ -163,7 +163,7 @@
 	      struct kstat *stat)
 {
 	*p++ = htonl(nfs3_ftypes[(stat->mode & S_IFMT) >> 12]);
-	*p++ = htonl((u32) stat->mode);
+	*p++ = htonl((u32) (stat->mode & (S_IRWXU | S_IRWXG | S_IRWXO | S_ISUID | S_ISGID | S_ISVTX)));
 	*p++ = htonl((u32) stat->nlink);
 	*p++ = htonl((u32) nfsd_ruid(rqstp, stat->uid));
 	*p++ = htonl((u32) nfsd_rgid(rqstp, stat->gid));
diff -ru linux-2.6.32-358.23.2.el6.x86_64.paf/fs/nfsd/vfs.c linux-2.6.32-358.23.2.el6.x86_64/fs/nfsd/vfs.c
--- linux-2.6.32-358.23.2.el6.x86_64/fs/nfsd/vfs.c	2013-11-15 15:57:10.802262655 +0100
+++ linux-2.6.32-358.23.2.el6.x86_64.paf/fs/nfsd/vfs.c	2013-09-14 10:53:17.000000000 +0200
@@ -784,7 +784,7 @@
 	else {
 		host_err = ima_file_check(*filp, may_flags);
 
-		if (may_flags & NFSD_MAY_64BIT_COOKIE)
+		if (may_flags & NFSD_MAY_64BIT_COOKIE && 0)
 			(*filp)->f_mode |= FMODE_64BITHASH;
 		else
 			(*filp)->f_mode |= FMODE_32BITHASH;

--EeQfGwPcQSOJBaQU--
