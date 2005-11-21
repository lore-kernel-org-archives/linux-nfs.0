From: Vince Busam <vbusam@google.com>
Subject: [PATCH] Fix typo on __rpc_purge_upcall
Date: Mon, 21 Nov 2005 11:51:10 -0800
Message-ID: <4382252E.4000602@google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.92] helo=mail.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1EeHhF-0004uK-BR
	for nfs@lists.sourceforge.net; Mon, 21 Nov 2005 11:51:25 -0800
Received: from smtp-out.google.com ([216.239.45.12])
	by mail.sourceforge.net with esmtps (TLSv1:AES256-SHA:256)
	(Exim 4.44)
	id 1EeHhC-0004m7-2a
	for nfs@lists.sourceforge.net; Mon, 21 Nov 2005 11:51:25 -0800
Received: from mail2.smo.corp.google.com (mail2.smo.corp.google.com [172.29.48.30])
	by smtp-out.google.com with ESMTP id jALJpCrC016677
	for <nfs@lists.sourceforge.net>; Mon, 21 Nov 2005 11:51:12 -0800
Received: from [172.29.52.19] (dig.smo.corp.google.com [172.29.52.19])
	by mail2.smo.corp.google.com with ESMTP id jALJpAwQ030852
	for <nfs@lists.sourceforge.net>; Mon, 21 Nov 2005 11:51:10 -0800
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

I posted this last week.  Here's an official style patch.

Vince
------------------------------------------------------------------

Fix an obvious typo that would cause a NULL pointer dereference.

Signed-off-by: Vince Busam <vbusam@google.com>
---

--- linux-2.6.13.4/net/sunrpc/rpc_pipe.c.orig  2005-11-16 16:48:00.000000000 -0800
+++ linux-2.6.13.4/net/sunrpc/rpc_pipe.c       2005-11-16 16:52:23.000000000 -0800
@@ -51,7 +51,7 @@ __rpc_purge_upcall(struct inode *inode,
                  rpci->ops->destroy_msg(msg);
          }
          while (!list_empty(&rpci->in_upcall)) {
-               msg = list_entry(rpci->pipe.next, struct rpc_pipe_msg, list);
+               msg = list_entry(rpci->in_upcall.next, struct rpc_pipe_msg, list);
                  list_del_init(&msg->list);
                  msg->errno = err;
                  rpci->ops->destroy_msg(msg);


-------------------------------------------------------
This SF.Net email is sponsored by the JBoss Inc.  Get Certified Today
Register for a JBoss Training Course.  Free Certification Exam
for All Training Attendees Through End of 2005. For more info visit:
http://ads.osdn.com/?ad_id=7628&alloc_id=16845&op=click
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
