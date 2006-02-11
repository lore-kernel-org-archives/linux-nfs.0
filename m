From: Jesper Juhl <jesper.juhl@gmail.com>
Subject: [PATCH] nfs: fix ICC Storage Class is not First warning
Date: Sun, 12 Feb 2006 00:29:52 +0100
Message-ID: <200602120029.52954.jesper.juhl@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="us-ascii"
Cc: Kendrick Smith <kmsmith@umich.edu>,
	Andy Adamson <andros@umich.edu>, Neil Brown <neilb@cse.unsw.edu.au>,
	Trond Myklebust <trond.myklebust@fys.uio.no>,
	nfs@lists.sourceforge.net
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.91] helo=mail.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1F84BY-0002J6-OD
	for nfs@lists.sourceforge.net; Sat, 11 Feb 2006 15:29:48 -0800
Received: from wproxy.gmail.com ([64.233.184.199])
	by mail.sourceforge.net with esmtp (Exim 4.44)
	id 1F84BX-0004i0-3i
	for nfs@lists.sourceforge.net; Sat, 11 Feb 2006 15:29:48 -0800
Received: by wproxy.gmail.com with SMTP id 57so588560wri
        for <nfs@lists.sourceforge.net>; Sat, 11 Feb 2006 15:29:44 -0800 (PST)
To: "Linux Kernel Mailing List" <linux-kernel@vger.kernel.org>
Sender: nfs-admin@lists.sourceforge.net
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

It seems my patch to change "const static" into "static const" in order to 
please ICC (commit: 3c6bee1d4037a5c569f30d40bd852a57ba250912) 
missed a single case.
This patch fixes the last instance.


Signed-off-by: Jesper Juhl <jesper.juhl@gmail.com>
---

--- linux-2.6.16-rc2-git10/fs/nfs/nfs4proc.c~	2006-02-12 00:22:00.000000000 +0100
+++ linux-2.6.16-rc2-git10/fs/nfs/nfs4proc.c	2006-02-12 00:22:00.000000000 +0100
@@ -2958,7 +2958,7 @@ static void nfs4_delegreturn_release(voi
 	kfree(calldata);
 }
 
-const static struct rpc_call_ops nfs4_delegreturn_ops = {
+static const struct rpc_call_ops nfs4_delegreturn_ops = {
 	.rpc_call_prepare = nfs4_delegreturn_prepare,
 	.rpc_call_done = nfs4_delegreturn_done,
 	.rpc_release = nfs4_delegreturn_release,




-------------------------------------------------------
This SF.net email is sponsored by: Splunk Inc. Do you grep through log files
for problems?  Stop!  Download the new AJAX search engine that makes
searching your log files as easy as surfing the  web.  DOWNLOAD SPLUNK!
http://sel.as-us.falkag.net/sel?cmd=lnk&kid=103432&bid=230486&dat=121642
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
