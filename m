From: Steve Dickson <SteveD@redhat.com>
Subject: [Fwd: Re:  [PATCH] NFS: Sign Extentions with Tru64 FSIDs.]
Date: Fri, 16 Mar 2007 11:36:00 -0400
Message-ID: <45FAB960.5060002@RedHat.com>
Mime-Version: 1.0
Content-Type: multipart/mixed; boundary="------------080803000201040408060609"
Cc: neilb@suse.de, Trond.Myklebust@netapp.com
To: nfs@lists.sourceforge.net
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.91]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1HSETO-0006Vl-Br
	for nfs@lists.sourceforge.net; Fri, 16 Mar 2007 08:36:06 -0700
Received: from mx1.redhat.com ([66.187.233.31])
	by mail.sourceforge.net with esmtp (Exim 4.44) id 1HSETM-0003ST-UV
	for nfs@lists.sourceforge.net; Fri, 16 Mar 2007 08:36:05 -0700
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

This is a multi-part message in MIME format.
--------------080803000201040408060609
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit

Any status or hope with these patches??

steved.

-------- Original Message --------
Subject: Re: [NFS] [PATCH] NFS: Sign Extentions with Tru64 FSIDs.
Date: Tue, 06 Mar 2007 16:42:56 -0500
From: Steve Dickson <SteveD@RedHat.com>
To: Trond Myklebust <Trond.Myklebust@netapp.com>,  Neil Brown 
<neilb@suse.de>
CC: 'nfs@lists.sourceforge.net' <nfs@lists.sourceforge.net>
References: <45EC7F0F.4090600@RedHat.com>	 
<1173130678.6315.7.camel@heimdal.trondhjem.org>	 
<45EC8FD3.4010809@redhat.com>	 
<1173132182.6315.27.camel@heimdal.trondhjem.org>	 
<45EC9837.1010504@redhat.com> 
<1173186308.6393.7.camel@heimdal.trondhjem.org> 
<45ED8135.2010008@RedHat.com>



Steve Dickson wrote:
> 
> Trond Myklebust wrote:
>> On Mon, 2007-03-05 at 17:22 -0500, Peter Staubach wrote:
>>> Or we could just punt and document that READDIRPLUS must be disabled
>>> on all Tru64 NFS servers if this problem is seen.
>> That would also be an option.
> Assuming there is a way to turn off READDIRPLUS  on the
> server side... I'll look into it... Or are you suggesting
> that we have a mount option to turn off READDIRPLUS on the
> client side? (Note: I believe other implementations have
> this mount option if that means anything)....
Not too surprising, there does not seem to be away to
disable READDIRPLUS on the server side.... so...
Since it was incredibly easy to disable READDIRPLUS
from the client side... I went ahead came up and tested
the attached patches...

Again, I believe there are other implementations, like Apple,
that have this type of knob so in the end, this might be
a good thing to have in general... It definitely helps with
broken Tru64 servers...  So please consider...

tia,

steved.


--------------080803000201040408060609
Content-Type: text/x-patch;
 name="linux-2.6.20-nfs-nordirplus.patch"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline;
 filename="linux-2.6.20-nfs-nordirplus.patch"

Added support to turn off the NFSv3 READDIRPLUS RPC.

Signed-off-by: Steve Dickson <steved@redhat.com>

----------------------------------------------
--- linux-2.6.20.i686/fs/nfs/super.c.orig	2007-03-05 11:26:41.130885000 -0500
+++ linux-2.6.20.i686/fs/nfs/super.c	2007-03-06 16:10:13.390550000 -0500
@@ -291,6 +291,7 @@
 		{ NFS_MOUNT_NOAC, ",noac", "" },
 		{ NFS_MOUNT_NONLM, ",nolock", "" },
 		{ NFS_MOUNT_NOACL, ",noacl", "" },
+		{ NFS_MOUNT_NORDIRPLUS, ",nordirplus", "" },
 		{ 0, NULL, NULL }
 	};
 	const struct proc_nfs_info *nfs_infop;
--- linux-2.6.20.i686/fs/nfs/client.c.orig	2007-03-05 11:26:40.995885000 -0500
+++ linux-2.6.20.i686/fs/nfs/client.c	2007-03-06 11:07:23.208538000 -0500
@@ -618,7 +618,8 @@
 	if (clp->cl_nfsversion == 3) {
 		if (server->namelen == 0 || server->namelen > NFS3_MAXNAMLEN)
 			server->namelen = NFS3_MAXNAMLEN;
-		server->caps |= NFS_CAP_READDIRPLUS;
+		if (!(data->flags & NFS_MOUNT_NORDIRPLUS))
+			server->caps |= NFS_CAP_READDIRPLUS;
 	} else {
 		if (server->namelen == 0 || server->namelen > NFS2_MAXNAMLEN)
 			server->namelen = NFS2_MAXNAMLEN;
--- linux-2.6.20.i686/include/linux/nfs_mount.h.orig	2007-02-04 13:44:54.000000000 -0500
+++ linux-2.6.20.i686/include/linux/nfs_mount.h	2007-03-06 10:59:06.457362000 -0500
@@ -61,6 +61,7 @@
 #define NFS_MOUNT_NOACL		0x0800	/* 4 */
 #define NFS_MOUNT_STRICTLOCK	0x1000	/* reserved for NFSv4 */
 #define NFS_MOUNT_SECFLAVOUR	0x2000	/* 5 */
+#define NFS_MOUNT_NORDIRPLUS	0x4000	/* 5 */
 #define NFS_MOUNT_FLAGMASK	0xFFFF
 
 #endif


--------------080803000201040408060609
Content-Type: text/x-patch;
 name="nfs-utils-1.0.12-mount-nordirplus.patch"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline; filename="nfs-utils-1.0.12-mount-nordirplus.patch"

Adds the -o nordirplus mount option that will disable 
NFS clients from using the READDIRPLUS RPC.

Signed-off-by: Steve Dickson <steved@redhat.com>

------------------------------
--- nfs-utils-1.0.12/utils/mount/nfs_mount.h.orig	2007-03-06 15:41:19.557090000 -0500
+++ nfs-utils-1.0.12/utils/mount/nfs_mount.h	2007-03-06 15:44:22.888922000 -0500
@@ -63,6 +63,7 @@
 #define NFS_MOUNT_BROKEN_SUID	0x0400	/* 4 */
 #define NFS_MOUNT_NOACL     0x0800  /* 4 */
 #define NFS_MOUNT_SECFLAVOUR	0x2000	/* 5 */
+#define NFS_MOUNT_NORDIRPLUS	0x4000	/* 5 */
 
 /* security pseudoflavors */
 
--- nfs-utils-1.0.12/utils/mount/nfsmount.c.orig	2007-03-06 15:41:19.582094000 -0500
+++ nfs-utils-1.0.12/utils/mount/nfsmount.c	2007-03-06 15:44:53.509748000 -0500
@@ -788,6 +788,10 @@
 				data->flags &= ~NFS_MOUNT_NOACL;
 				if (!val)
 					data->flags |= NFS_MOUNT_NOACL;
+			} else if (!strcmp(opt, "rdirplus")) {
+				data->flags &= ~NFS_MOUNT_NORDIRPLUS;
+				if (!val)
+					data->flags |= NFS_MOUNT_NORDIRPLUS;
 #endif
 			} else {
 			bad_option:
@@ -975,6 +979,7 @@
 #endif
 #if NFS_MOUNT_VERSION >= 5
 	printf("sec = %u ", data.pseudoflavor);
+	printf("readdirplus = %d ", (data.flags & NFS_MOUNT_NORDIRPLUS) != 0);
 #endif
 	printf("\n");
 #endif
--- nfs-utils-1.0.12/utils/mount/nfs.man.orig	2007-03-06 15:41:19.431090000 -0500
+++ nfs-utils-1.0.12/utils/mount/nfs.man	2007-03-06 16:06:29.487656000 -0500
@@ -272,6 +272,11 @@
 .I udp
 Mount the NFS filesystem using the UDP protocol.  This
 is the default.
+.TP 1.5i
+.I nordirplus
+Disables NFSv3 READDIRPLUS RPCs. Use this options when
+mounting servers that don't support or have broken
+READDIRPLUS implementations.
 .P
 All of the non-value options have corresponding nooption forms.
 For example, nointr means don't allow file operations to be


--------------080803000201040408060609
Content-Type: text/plain; charset="us-ascii"
MIME-Version: 1.0
Content-Transfer-Encoding: 7bit
Content-Disposition: inline

-------------------------------------------------------------------------
Take Surveys. Earn Cash. Influence the Future of IT
Join SourceForge.net's Techsay panel and you'll get the chance to share your
opinions on IT & business topics through brief surveys-and earn cash
http://www.techsay.com/default.php?page=join.php&p=sourceforge&CID=DEVDEV
--------------080803000201040408060609
Content-Type: text/plain; charset="us-ascii"
MIME-Version: 1.0
Content-Transfer-Encoding: 7bit
Content-Disposition: inline

_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs

--------------080803000201040408060609--
