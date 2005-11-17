From: Vince Busam <vbusam@google.com>
Subject: Funny looking code in __rpc_purge_upcall
Date: Wed, 16 Nov 2005 16:53:46 -0800
Message-ID: <437BD49A.5070509@google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.91] helo=mail.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1EcY2F-0004Cr-Dr
	for nfs@lists.sourceforge.net; Wed, 16 Nov 2005 16:53:55 -0800
Received: from smtp-out.google.com ([216.239.45.12])
	by mail.sourceforge.net with esmtps (TLSv1:AES256-SHA:256)
	(Exim 4.44)
	id 1EcY2E-0004m1-FC
	for nfs@lists.sourceforge.net; Wed, 16 Nov 2005 16:53:55 -0800
Received: from mail2.smo.corp.google.com (mail2.smo.corp.google.com [172.29.48.30])
	by smtp-out.google.com with ESMTP id jAH0rnFW015874
	for <nfs@lists.sourceforge.net>; Wed, 16 Nov 2005 16:53:49 -0800
Received: from [172.29.52.19] (dig.smo.corp.google.com [172.29.52.19])
	by mail2.smo.corp.google.com with ESMTP id jAH0rkoI020877
	for <nfs@lists.sourceforge.net>; Wed, 16 Nov 2005 16:53:47 -0800
To: nfs@lists.sourceforge.net
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

In __rpc_purge_upcall (net/sunrpc/rpc_pipe.c), the newer code to clean up the in_upcall 
list looks bad.  Shouldn't the first argument to list_entry() be rpci->in_upcall.next?

--- net/sunrpc/rpc_pipe.c.orig  2005-11-16 16:48:00.000000000 -0800
+++ net/sunrpc/rpc_pipe.c       2005-11-16 16:52:23.000000000 -0800
@@ -51,7 +51,7 @@ __rpc_purge_upcall(struct inode *inode,
                 rpci->ops->destroy_msg(msg);
         }
         while (!list_empty(&rpci->in_upcall)) {
-               msg = list_entry(rpci->pipe.next, struct rpc_pipe_msg, list);
+               msg = list_entry(rpci->in_upcall.next, struct rpc_pipe_msg, list);
                 list_del_init(&msg->list);
                 msg->errno = err;
                 rpci->ops->destroy_msg(msg);

Vince


-------------------------------------------------------
This SF.Net email is sponsored by the JBoss Inc.  Get Certified Today
Register for a JBoss Training Course.  Free Certification Exam
for All Training Attendees Through End of 2005. For more info visit:
http://ads.osdn.com/?ad_id=7628&alloc_id=16845&op=click
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
