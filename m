From: Olaf Kirch <okir@suse.de>
Subject: [PATCH] NFS nolock broken in 2.6.9-rc4
Date: Fri, 15 Oct 2004 11:58:40 +0200
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <20041015095840.GA22992@suse.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.12] helo=sc8-sf-mx2.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1CIOtG-00052l-PO
	for nfs@lists.sourceforge.net; Fri, 15 Oct 2004 03:00:50 -0700
Received: from cantor.suse.de ([195.135.220.2])
	by sc8-sf-mx2.sourceforge.net with esmtp (TLSv1:DES-CBC3-SHA:168)
	(Exim 4.41)
	id 1CIOsq-0007Y4-OQ
	for nfs@lists.sourceforge.net; Fri, 15 Oct 2004 03:00:50 -0700
To: nfs@lists.sourceforge.net, akpm@osdl.org
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


Hi,

2.6.9-rc2 and later contain the following hunks in fs/locks.c:

@@ -1489,8 +1534,7 @@ int fcntl_setlk(struct file *filp, unsig

        if (filp->f_op && filp->f_op->lock != NULL) {
                error = filp->f_op->lock(filp, cmd, file_lock);
-               if (error < 0)
-                       goto out;
+               goto out;
        }

        for (;;) {
@@ -1624,8 +1668,7 @@ int fcntl_setlk64(struct file *filp, uns

        if (filp->f_op && filp->f_op->lock != NULL) {
                error = filp->f_op->lock(filp, cmd, file_lock);
-               if (error < 0)
-                       goto out;
+               goto out;
        }

        for (;;) {

For an NFS file system mounted with -o nolock, this means filp->f_op->lock
will return 0 but do nothing. Previously, this would cause local locking
to be used. With the change above, we just return. 

I don't know why this change was made. The patch below simply reverts
these two hunks; maybe there's a better solution involving LOCK_USE_CLNT
the way it's used for F_GETLK at the moment.

Olaf
-- 
Olaf Kirch     | Things that make Monday morning interesting, #1:
okir@suse.de   |        "I want to use NFS over AX25, can you help me?"
---------------+ 


-------------------------------------------------------
This SF.net email is sponsored by: IT Product Guide on ITManagersJournal
Use IT products in your business? Tell us what you think of them. Give us
Your Opinions, Get Free ThinkGeek Gift Certificates! Click to find out more
http://productguide.itmanagersjournal.com/guidepromo.tmpl
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
