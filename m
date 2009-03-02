From: Jon Mason <jon@opengridcomputing.com>
Subject: [NFS] mount.nfs kernel version check override
Date: Mon, 2 Mar 2009 17:22:16 -0600
Message-ID: <20090302232216.GF3867@opengridcomputing.com>
Mime-Version: 1.0
Content-Type: multipart/mixed; boundary="opJtzjQTFsWo+cga"
Cc: swise@opengridcomputing.com, Jeffrey.C.Becker@nasa.gov
To: nfs@lists.sourceforge.net
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from neil.brown.name ([220.233.11.133]:38524 "EHLO neil.brown.name"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752745AbZCBXtJ (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Mon, 2 Mar 2009 18:49:09 -0500
Received: from brown by neil.brown.name with local (Exim 4.69)
	(envelope-from <nfs-bounces@lists.sourceforge.net>)
	id 1LeHsd-0002QH-C1
	for linux-nfs@vger.kernel.org; Tue, 03 Mar 2009 10:49:03 +1100
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>


--opJtzjQTFsWo+cga
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline

I am working on backporting NFS-RDMA to older versions of Linux for the
Open Fabrics Linux kernel stack (OFED).  I have backported NFS-RDMA to
RHEL5.2 (which has a kernel based on 2.6.18), and others are working on
backporting to other older kernels.  The issue that I have and they will
discover is that there is a check in the mount command for kernels
greater than 2.6.22.  If it is older than this version, it will not pass
args to the kernel.

I have come up with a patch to add an additional flag to the mount
command to allow this kernel version check to be over-ruled.  Please
consider adding it to the next release of the nfs-utils.

Thanks,
Jon

--opJtzjQTFsWo+cga
Content-Type: text/x-diff; charset=us-ascii
Content-Disposition: attachment; filename="nfs-utils-mount.patch"

--- utils/mount/mount.c.orig	2008-10-17 09:20:09.000000000 -0500
+++ utils/mount/mount.c	2009-03-02 16:41:44.000000000 -0600
@@ -331,6 +331,7 @@ void mount_usage(void)
 	printf(_("\t-f\t\tFake mount, do not actually mount\n"));
 	printf(_("\t-n\t\tDo not update /etc/mtab\n"));
 	printf(_("\t-s\t\tTolerate sloppy mount options rather than fail\n"));
+	printf(_("\t-i\t\tIgnore kernel version limitations\n"));
 	printf(_("\t-h\t\tPrint this help\n"));
 	printf(_("\tnfsoptions\tRefer to mount.nfs(8) or nfs(5)\n\n"));
 }
@@ -475,7 +476,7 @@ int main(int argc, char *argv[])
 	mount_point = argv[2];
 
 	argv[2] = argv[0]; /* so that getopt error messages are correct */
-	while ((c = getopt_long(argc - 2, argv + 2, "rvVwfno:hs",
+	while ((c = getopt_long(argc - 2, argv + 2, "rvVwfno:hsi",
 				longopts, NULL)) != -1) {
 		switch (c) {
 		case 'r':
@@ -505,6 +506,9 @@ int main(int argc, char *argv[])
 		case 's':
 			++sloppy;
 			break;
+		case 'i':
+			string++;
+			break;
 		case 'h':
 		default:
 			mount_usage();

--opJtzjQTFsWo+cga
Content-Type: text/plain; charset="us-ascii"
MIME-Version: 1.0
Content-Transfer-Encoding: 7bit
Content-Disposition: inline

------------------------------------------------------------------------------
Open Source Business Conference (OSBC), March 24-25, 2009, San Francisco, CA
-OSBC tackles the biggest issue in open source: Open Sourcing the Enterprise
-Strategies to boost innovation and cut costs with open source participation
-Receive a $600 discount off the registration fee with the source code: SFAD
http://p.sf.net/sfu/XcvMzF8H
--opJtzjQTFsWo+cga
Content-Type: text/plain; charset="us-ascii"
MIME-Version: 1.0
Content-Transfer-Encoding: 7bit
Content-Disposition: inline

_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
_______________________________________________
Please note that nfs@lists.sourceforge.net is being discontinued.
Please subscribe to linux-nfs@vger.kernel.org instead.
    http://vger.kernel.org/vger-lists.html#linux-nfs

--opJtzjQTFsWo+cga--


