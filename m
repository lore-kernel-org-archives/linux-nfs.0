From: Steve Dickson <SteveD@redhat.com>
Subject: [PATCH] NFS/RPC/GSS - oops in gss_pipe_release()
Date: Fri, 16 Sep 2005 13:40:15 -0400
Message-ID: <432B037F.7020308@RedHat.com>
Mime-Version: 1.0
Content-Type: multipart/mixed;
 boundary="------------010204060405000401060507"
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.92] helo=mail.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1EGKCF-00065t-8I
	for nfs@lists.sourceforge.net; Fri, 16 Sep 2005 10:40:23 -0700
Received: from mx1.redhat.com ([66.187.233.31])
	by mail.sourceforge.net with esmtps (TLSv1:AES256-SHA:256)
	(Exim 4.44)
	id 1EGKCF-0005Zm-0W
	for nfs@lists.sourceforge.net; Fri, 16 Sep 2005 10:40:23 -0700
Received: from int-mx1.corp.redhat.com (int-mx1.corp.redhat.com [172.16.52.254])
	by mx1.redhat.com (8.12.11/8.12.11) with ESMTP id j8GHeGx7007149
	for <nfs@lists.sourceforge.net>; Fri, 16 Sep 2005 13:40:16 -0400
Received: from lacrosse.corp.redhat.com (lacrosse.corp.redhat.com [172.16.52.154])
	by int-mx1.corp.redhat.com (8.11.6/8.11.6) with ESMTP id j8GHeGV30361
	for <nfs@lists.sourceforge.net>; Fri, 16 Sep 2005 13:40:16 -0400
Received: from [172.16.80.110] (IDENT:U2FsdGVkX1+YSRw3V6ds9LB20olsyF7THXzJ3VjW/Kg@dickson.boston.redhat.com [172.16.80.110])
	by lacrosse.corp.redhat.com (8.11.6/8.11.6) with ESMTP id j8GHeG428888
	for <nfs@lists.sourceforge.net>; Fri, 16 Sep 2005 13:40:16 -0400
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

This is a multi-part message in MIME format.
--------------010204060405000401060507
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit

During some recent debugging I found that an oops can
occur in gss_pipe_release() because the client handle
that is being passed in has already been freed.

The scenario is as follows:

root# mount -o sec=krb5 server:/export /mnt/export
user$ ls /mnt/export (which hangs because user does not
                       have the correct credentials)
root# reboot

The oops occurs when the /mnt/export filesystem
is unmounted. The reason being is gss_pipe_release()
was already called when the ls process was killed.
The stack dump of the ls process was:

  [<e09dda84>] gss_pipe_release+0x74/0xd8 [auth_rpcgss]
  [<e0a045c0>] rpc_pipe_release+0xa5/0xb9 [sunrpc]
  [<c015a9d6>] __fput+0x55/0x100
  [<c0159626>] filp_close+0x59/0x5f
  [<c012363f>] put_files_struct+0x57/0xc0
  [<c0124255>] do_exit+0x227/0x3de
  [<c01244fa>] sys_exit_group+0x0/0xd
  [<c02d120b>] syscall_call+0x7/0xb

So when the rpc_shutdown_client code is called
via the umount:
  [<e09dda84>] gss_pipe_release+0x74/0xd8 [auth_rpcgss]
  [<e0a0447c>] rpc_close_pipes+0x80/0x9a [sunrpc]
  [<e0a04bb0>] rpc_depopulate+0xfb/0x142 [sunrpc]
  [<c01651bc>] cached_lookup+0xf/0x56
  [<c0166410>] __lookup_hash+0x46/0x89
  [<e0a05005>] rpc_rmdir+0x5a/0x89 [sunrpc]
  [<e09fcede>] rpcauth_free_credcache+0x87/0xd0 [sunrpc]
  [<e09f8431>] rpc_destroy_client+0x70/0xa4 [sunrpc]
  [<e09f8421>] rpc_destroy_client+0x60/0xa4 [sunrpc]
  [<e09f83ba>] rpc_shutdown_client+0xd1/0xd8 [sunrpc]
  [<c011e586>] default_wake_function+0x0/0xc
  [<e0aefe75>] nfs_kill_super+0x38/0x63 [nfs]

the client handle (which is in the rpc_inode) passed
to gss_pipe_release() has already been freeded.

It appears from other places in the code (namely
rpc_close_pipes()) that the only way to invalidate
an rpc_inode is to set the ops pointer to NULL which
is what the attached patch does.

Is there a better way to invalid an rpc_inode?

steved.

--------------010204060405000401060507
Content-Type: text/x-patch;
 name="linux-2.6.13-rpc-gss-release.patch"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline;
 filename="linux-2.6.13-rpc-gss-release.patch"

This patch stops the release_pipe() funtion from being called
twice by invalidating the ops pointer in the rpc_inode
when rpc_pipe_release() is called.

Signed-off-by: Steve Dickson <steved@redhat.com>
------------------------------------------------------
--- linux-2.6.13/net/sunrpc/rpc_pipe.c.orig	2005-08-28 19:41:01.000000000 -0400
+++ linux-2.6.13/net/sunrpc/rpc_pipe.c	2005-09-16 11:18:53.598157000 -0400
@@ -177,6 +177,8 @@ rpc_pipe_release(struct inode *inode, st
 		__rpc_purge_upcall(inode, -EPIPE);
 	if (rpci->ops->release_pipe)
 		rpci->ops->release_pipe(inode);
+	if (!rpci->nreaders && !rpci->nwriters)
+		rpci->ops = NULL;
 out:
 	up(&inode->i_sem);
 	return 0;

--------------010204060405000401060507--


-------------------------------------------------------
SF.Net email is sponsored by:
Tame your development challenges with Apache's Geronimo App Server. 
Download it for free - -and be entered to win a 42" plasma tv or your very
own Sony(tm)PSP.  Click here to play: http://sourceforge.net/geronimo.php
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
