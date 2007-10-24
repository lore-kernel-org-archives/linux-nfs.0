From: Prasad P <pvp@us.ibm.com>
Subject: [PATCH] Fix incorrect assignment
Date: Wed, 24 Oct 2007 15:14:32 -0500
Message-ID: <OFE5621A0A.80A31B03-ON8725737E.006E4E77-8625737E.006F322A@us.ibm.com>
Mime-Version: 1.0
Content-Type: multipart/mixed; boundary="===============1755424904=="
To: nfs@lists.sourceforge.net
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.91]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1Ikmh8-0006eE-Eh
	for nfs@lists.sourceforge.net; Wed, 24 Oct 2007 13:19:14 -0700
Received: from e32.co.us.ibm.com ([32.97.110.150])
	by mail.sourceforge.net with esmtps (TLSv1:AES256-SHA:256)
	(Exim 4.44) id 1Ikmcj-00054U-ML
	for nfs@lists.sourceforge.net; Wed, 24 Oct 2007 13:14:43 -0700
Received: from d03relay02.boulder.ibm.com (d03relay02.boulder.ibm.com
	[9.17.195.227])
	by e32.co.us.ibm.com (8.12.11.20060308/8.13.8) with ESMTP id
	l9OJ5RqC029820
	for <nfs@lists.sourceforge.net>; Wed, 24 Oct 2007 15:05:27 -0400
Received: from d03av02.boulder.ibm.com (d03av02.boulder.ibm.com [9.17.195.168])
	by d03relay02.boulder.ibm.com (8.13.8/8.13.8/NCO v8.5) with ESMTP id
	l9OKEYcf117106
	for <nfs@lists.sourceforge.net>; Wed, 24 Oct 2007 14:14:34 -0600
Received: from d03av02.boulder.ibm.com (loopback [127.0.0.1])
	by d03av02.boulder.ibm.com (8.12.11.20060308/8.13.3) with ESMTP id
	l9OKEYbw030749
	for <nfs@lists.sourceforge.net>; Wed, 24 Oct 2007 14:14:34 -0600
Received: from d03nm121.boulder.ibm.com (d03nm121.boulder.ibm.com
	[9.17.195.147])
	by d03av02.boulder.ibm.com (8.12.11.20060308/8.12.11) with ESMTP id
	l9OKEYEL030718
	for <nfs@lists.sourceforge.net>; Wed, 24 Oct 2007 14:14:34 -0600
List-Id: "Discussion of NFS under Linux development, interoperability,
	and testing." <nfs.lists.sourceforge.net>
List-Unsubscribe: <https://lists.sourceforge.net/lists/listinfo/nfs>,
	<mailto:nfs-request@lists.sourceforge.net?subject=unsubscribe>
List-Archive: <http://sourceforge.net/mailarchive/forum.php?forum_name=nfs>
List-Post: <mailto:nfs@lists.sourceforge.net>
List-Help: <mailto:nfs-request@lists.sourceforge.net?subject=help>
List-Subscribe: <https://lists.sourceforge.net/lists/listinfo/nfs>,
	<mailto:nfs-request@lists.sourceforge.net?subject=subscribe>
Sender: nfs-bounces@lists.sourceforge.net
Errors-To: nfs-bounces@lists.sourceforge.net

--===============1755424904==
Content-type: multipart/alternative;
	Boundary="0__=08BBF9EDDFFDC8E78f9e8a93df938690918c08BBF9EDDFFDC8E7"
Content-Disposition: inline

--0__=08BBF9EDDFFDC8E78f9e8a93df938690918c08BBF9EDDFFDC8E7
Content-type: text/plain; charset=US-ASCII



Dereferenced pointer "dentry" without checking and assigned to inode
in the declaration.

Cc: Steve French <smfltc@us.ibm.com>
Signed-off-by: Prasad V Potluri <pvp@us.ibm.com>
---

diff -uprN a/fs/nfsd/nfs2acl.c b/fs/nfsd/nfs2acl.c
--- a/fs/nfsd/nfs2acl.c 2007-10-09 15:31:38.000000000 -0500
+++ b/fs/nfsd/nfs2acl.c 2007-10-24 14:03:13.000000000 -0500
@@ -221,7 +221,7 @@ static int nfsaclsvc_encode_getaclres(st
            struct nfsd3_getaclres *resp)
 {
      struct dentry *dentry = resp->fh.fh_dentry;
-     struct inode *inode = dentry->d_inode;
+     struct inode *inode;
      struct kvec *head = rqstp->rq_res.head;
      unsigned int base;
      int n;
--
Thanks.

Regards,
Prasad Potluri
email: pvp at-sign us dot ibm dot com
--0__=08BBF9EDDFFDC8E78f9e8a93df938690918c08BBF9EDDFFDC8E7
Content-type: text/html; charset=US-ASCII
Content-Disposition: inline

<html><body>
<p>Dereferenced pointer &quot;dentry&quot; without checking and assigned to inode<br>
in the declaration.<br>
<br>
Cc: Steve French &lt;smfltc@us.ibm.com&gt;<br>
Signed-off-by: Prasad V Potluri &lt;pvp@us.ibm.com&gt;<br>
---<br>
<br>
diff -uprN a/fs/nfsd/nfs2acl.c b/fs/nfsd/nfs2acl.c<br>
--- a/fs/nfsd/nfs2acl.c	2007-10-09 15:31:38.000000000 -0500<br>
+++ b/fs/nfsd/nfs2acl.c	2007-10-24 14:03:13.000000000 -0500<br>
@@ -221,7 +221,7 @@ static int nfsaclsvc_encode_getaclres(st<br>
 		struct nfsd3_getaclres *resp)<br>
 {<br>
 	struct dentry *dentry = resp-&gt;fh.fh_dentry;<br>
-	struct inode *inode = dentry-&gt;d_inode;<br>
+	struct inode *inode;<br>
 	struct kvec *head = rqstp-&gt;rq_res.head;<br>
 	unsigned int base;<br>
 	int n;<br>
--<br>
Thanks.<br>
<br>
Regards,<br>
Prasad Potluri<br>
email: pvp at-sign us dot ibm dot com</body></html>
--0__=08BBF9EDDFFDC8E78f9e8a93df938690918c08BBF9EDDFFDC8E7--



--===============1755424904==
Content-Type: text/plain; charset="us-ascii"
MIME-Version: 1.0
Content-Transfer-Encoding: 7bit
Content-Disposition: inline

-------------------------------------------------------------------------
This SF.net email is sponsored by: Splunk Inc.
Still grepping through log files to find problems?  Stop.
Now Search log events and configuration files using AJAX and a browser.
Download your FREE copy of Splunk now >> http://get.splunk.com/
--===============1755424904==
Content-Type: text/plain; charset="us-ascii"
MIME-Version: 1.0
Content-Transfer-Encoding: 7bit
Content-Disposition: inline

_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs

--===============1755424904==--
