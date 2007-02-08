From: Kevin Coffman <kwc@citi.umich.edu>
Subject: [PATCH 08/12] Various minor manpage fixes.
Date: Thu, 08 Feb 2007 17:27:30 -0500
Message-ID: <20070208222730.23464.68498.stgit@rock.citi.umich.edu>
References: <20070208222606.23464.71348.stgit@rock.citi.umich.edu>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: nfs@lists.sourceforge.net
To: neilb@suse.de
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.92]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1HFHk7-0006sx-L6
	for nfs@lists.sourceforge.net; Thu, 08 Feb 2007 14:27:51 -0800
Received: from citi.umich.edu ([141.211.133.111])
	by mail.sourceforge.net with esmtps (TLSv1:AES256-SHA:256)
	(Exim 4.44) id 1HFHk8-0006nq-1B
	for nfs@lists.sourceforge.net; Thu, 08 Feb 2007 14:27:53 -0800
In-Reply-To: <20070208222606.23464.71348.stgit@rock.citi.umich.edu>
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

From: Kevin Coffman <kwc@citi.umich.edu>

Signed-off-by: Steinar H. Gunderson <sgunderson@bigfoot.com>
Signed-off-by: Kevin Coffman <kwc@citi.umich.edu>

  This mostly takes care of the difference between - and \-; in
  man pages, the former is hyphen (which indicates, among others,
  that a line might be split at that point), while the latter is a
  dash. For options, the latter is correct.

  There's also one minor grammatical fix.
---

 utils/nfsstat/nfsstat.man |    6 +++---
 1 files changed, 3 insertions(+), 3 deletions(-)

diff --git a/utils/nfsstat/nfsstat.man b/utils/nfsstat/nfsstat.man
index ed7f69c..895c36b 100644
--- a/utils/nfsstat/nfsstat.man
+++ b/utils/nfsstat/nfsstat.man
@@ -113,9 +113,9 @@ interface to the mounted filesystems.
 .SH BUGS
 The default output has been changed.  To get the old default output you must run \fBnfsstat \-\-auto \-2\fR.
 .P
-The function of the \fB-v\fR and \fB-a\fR options have changed. The \fB-a\fR option
-is now reserved for future use. The \fB-v\fR does what the \fB-a\fR option used to do,
-and the new \fB-[234]\fR options replace the \fB-v\fR option.
+The function of the \fB\-v\fR and \fB\-a\fR options have changed. The \fB\-a\fR option
+is now reserved for future use. The \fB\-v\fR does what the \fB\-a\fR option used to do,
+and the new \fB\-[234]\fR options replace the \fB\-v\fR option.
 .P
 The \fBDisplay\fR section should be more complete.
 .P

-------------------------------------------------------------------------
Using Tomcat but need to do more? Need to support web services, security?
Get stuff done quickly with pre-integrated technology to make your job easier.
Download IBM WebSphere Application Server v.1.0.1 based on Apache Geronimo
http://sel.as-us.falkag.net/sel?cmd=lnk&kid=120709&bid=263057&dat=121642
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
