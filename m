Return-Path: linux-nfs-owner@vger.kernel.org
Received: from fieldses.org ([174.143.236.118]:59197 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754466Ab3LPSgL (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Mon, 16 Dec 2013 13:36:11 -0500
Date: Mon, 16 Dec 2013 13:36:10 -0500
To: Tony Asleson <tasleson@redhat.com>
Cc: linux-nfs@vger.kernel.org
Subject: Re: exportfs: Messages indicating unsupported operation that works
Message-ID: <20131216183610.GA31816@fieldses.org>
References: <52AE712B.3060404@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <52AE712B.3060404@redhat.com>
From: "J. Bruce Fields" <bfields@fieldses.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Sun, Dec 15, 2013 at 09:19:07PM -0600, Tony Asleson wrote:
> When I try to export a directory that has a space in it I get the following:
> 
> # exportfs *:"/mnt/has space"
> exportfs: /mnt/has space does not support NFS export
> 
> exit code is 0.
> 
> If I do:
> 
> # exportfs -v
> /mnt/has space	<world>(ro,wdelay,root_squash,no_subtree_check,
> sec=sys,ro,secure,root_squash,no_all_squash)
> 
> It exists and I can mount it from a client and everything appears fine.
> 
> I took a peek at the code and we are failing in test_export.  We are
> getting a -1 returned when we write to: /proc/net/rpc/nfsd.export/channel .
> 
> This seems like a confusing message when it appears that everything is
> working, thoughts?
> 
> Notes:
> - Kernel Linux rawhide 3.13.0-0.rc3.git1.2.fc21.x86_64
> - nfs-utils: Latest from git, but this happens on older released
> versions tested too.

test_export clearly isn't escaping the pathname.  It probably needs
something like the following (completely untested).

--b.

diff --git a/utils/exportfs/exportfs.c b/utils/exportfs/exportfs.c
index 4331697..d5dfb0b 100644
--- a/utils/exportfs/exportfs.c
+++ b/utils/exportfs/exportfs.c
@@ -418,11 +418,15 @@ static int can_test(void)
 static int test_export(char *path, int with_fsid)
 {
 	char buf[1024];
+	char *bp = buf;
+	int len = sizeof(buf);
 	int fd, n;
 
-	sprintf(buf, "-test-client- %s 3 %d 65534 65534 0\n",
-		path,
-		with_fsid ? NFSEXP_FSID : 0);
+	n = sprintf(buf, "-test-client- ");
+	bp += n;
+	len -= n;
+	qword_add(&bp, &len, path);
+	sprintf(bp, " 3 %d 65534 65534 0\n", with_fsid ? NFSEXP_FSID : 0);
 	fd = open("/proc/net/rpc/nfsd.export/channel", O_WRONLY);
 	if (fd < 0)
 		return 0;
