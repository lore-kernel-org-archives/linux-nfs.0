Return-Path: linux-nfs-owner@vger.kernel.org
Received: from countercultured.net ([209.51.175.25]:48508 "HELO
	countercultured.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with SMTP id S1752443Ab2KNEc4 (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Tue, 13 Nov 2012 23:32:56 -0500
Message-ID: <50A31EF5.1050801@davequigley.com>
Date: Tue, 13 Nov 2012 23:32:53 -0500
From: Dave Quigley <dpquigl@davequigley.com>
MIME-Version: 1.0
To: Steve Dickson <SteveD@redhat.com>
CC: "J. Bruce Fields" <bfields@fieldses.org>,
        "David P. Quigley" <selinux@davequigley.com>,
        trond.myklebust@netapp.com, sds@tycho.nsa.gov,
        linux-nfs@vger.kernel.org, selinux@tycho.nsa.gov,
        linux-security-module@vger.kernel.org
Subject: Re: Labeled NFS [v5]
References: <1352700947-3915-1-git-send-email-dpquigl@davequigley.com> <20121112152335.GH30713@fieldses.org> <50A116F0.5050404@davequigley.com> <20121112160959.GK30713@fieldses.org> <50A16269.4060601@RedHat.com> <50A1A4EE.7030507@davequigley.com> <50A24345.8080309@RedHat.com>
In-Reply-To: <50A24345.8080309@RedHat.com>
Content-Type: multipart/mixed;
 boundary="------------080501030904020300030304"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

This is a multi-part message in MIME format.
--------------080501030904020300030304
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit

On 11/13/2012 7:55 AM, Steve Dickson wrote:
>
>
> On 12/11/12 20:39, Dave Quigley wrote:
>> If you're ok with non Fedora kernel images I can try to put up a tree either tonight or tomorrow with the patches that you just need to build and install. That plus the one patch for nfs-utils should make everything work.
> I'm good with that....
>
> steved.
>

Ok so if you go to http://www.selinuxproject.org/git you will see a repo 
for lnfs and lnfs-patchset. The instructions at 
http://www.selinuxproject.org/page/Labeled_NFS give you a better 
indication on how to pull the trees. I've attached a patch for NFS utils 
which gives support for security_label/nosecurity_label in your 
/etc/exports file. I've also attached a script called setup which should 
build a test directory called /export with a copy of /var/www under it 
which should be labeled properly. It does all the proper SELinux 
commands to make sure labeling is correct. Once you have that setup just 
mount -t nfs localhost:/ /mnt/lnfs (or wherever you want) and you should 
be good to go. Just ls -Z in /mnt/lnfs/var and check to make sure the 
labels are the same as /export/var. It should have the labels showing up 
in the network transfer. If you have any problems just let me know and I 
can try to help figure them out.

Dave

--------------080501030904020300030304
Content-Type: text/plain; charset=windows-1252;
 name="0001-Add-support-to-specify-which-exports-will-provide-La.patch"
Content-Transfer-Encoding: 7bit
Content-Disposition: attachment;
 filename*0="0001-Add-support-to-specify-which-exports-will-provide-La.pa";
 filename*1="tch"

>From da84919c6957090cd961bb4ce40753820312a845 Mon Sep 17 00:00:00 2001
From: Dave Quigley <dpquigl@taiga.selinuxproject.org>
Date: Fri, 18 Sep 2009 08:53:58 -0700
Subject: [PATCH] Add support to specify which exports will provide Labeled NFS support.

diff --git a/support/include/nfs/export.h b/support/include/nfs/export.h
index 1547a87..b8e2fb0 100644
--- a/support/include/nfs/export.h
+++ b/support/include/nfs/export.h
@@ -17,7 +17,8 @@
 #define NFSEXP_ALLSQUASH	0x0008
 #define NFSEXP_ASYNC		0x0010
 #define NFSEXP_GATHERED_WRITES	0x0020
-/* 40, 80, 100 unused */
+#define NFSEXP_SECURITY_LABEL	0x0040	/* Support MAC attribute */
+/* 80, 100 unused */
 #define NFSEXP_NOHIDE		0x0200
 #define NFSEXP_NOSUBTREECHECK	0x0400
 #define NFSEXP_NOAUTHNLM	0x0800
diff --git a/support/nfs/exports.c b/support/nfs/exports.c
index a93941c..8965c8d 100644
--- a/support/nfs/exports.c
+++ b/support/nfs/exports.c
@@ -239,6 +239,8 @@ putexportent(struct exportent *ep)
 	fprintf(fp, "%ssync,", (ep->e_flags & NFSEXP_ASYNC)? "a" : "");
 	fprintf(fp, "%swdelay,", (ep->e_flags & NFSEXP_GATHERED_WRITES)?
 				"" : "no_");
+	fprintf(fp, "%ssecurity_label,", (ep->e_flags & NFSEXP_SECURITY_LABEL)?
+				"" : "no");
 	fprintf(fp, "%shide,", (ep->e_flags & NFSEXP_NOHIDE)?
 				"no" : "");
 	fprintf(fp, "%scrossmnt,", (ep->e_flags & NFSEXP_CROSSMOUNT)?
@@ -531,6 +533,10 @@ parseopts(char *cp, struct exportent *ep, int warn, int *had_subtree_opt_ptr)
 			setflags(NFSEXP_GATHERED_WRITES, active, ep);
 		else if (!strcmp(opt, "no_wdelay"))
 			clearflags(NFSEXP_GATHERED_WRITES, active, ep);
+		else if (strcmp(opt, "security_label") == 0)
+			ep->e_flags |= NFSEXP_SECURITY_LABEL;
+		else if (strcmp(opt, "nosecurity_label") == 0)
+			ep->e_flags &= ~NFSEXP_SECURITY_LABEL;
 		else if (strcmp(opt, "root_squash") == 0)
 			setflags(NFSEXP_ROOTSQUASH, active, ep);
 		else if (!strcmp(opt, "no_root_squash"))
diff --git a/utils/exportfs/exportfs.c b/utils/exportfs/exportfs.c
index b78957f..6434825 100644
--- a/utils/exportfs/exportfs.c
+++ b/utils/exportfs/exportfs.c
@@ -531,6 +531,8 @@ dump(int verbose)
 				c = dumpopt(c, "async");
 			if (ep->e_flags & NFSEXP_GATHERED_WRITES)
 				c = dumpopt(c, "wdelay");
+			if (ep->e_flags & NFSEXP_SECURITY_LABEL)
+				c = dumpopt(c, "security_label");
 			if (ep->e_flags & NFSEXP_NOHIDE)
 				c = dumpopt(c, "nohide");
 			if (ep->e_flags & NFSEXP_CROSSMOUNT)

--------------080501030904020300030304
Content-Type: text/plain; charset=windows-1252;
 name="setup.sh"
Content-Transfer-Encoding: 7bit
Content-Disposition: attachment;
 filename="setup.sh"

#!/bin/bash
mkdir /export
semanage fcontext -a -t mnt_t /export
mkdir /export/var
cp -R /var/www /export/var
semanage fcontext -ae /var /export/var
restorecon -R /export

echo "/export *(rw,fsid=0,sec=unix,security_label,insecure,no_subtree_check,sync, no_root_squash)" >> /etc/exports
systemctl restart nfs-server.service 

--------------080501030904020300030304--
