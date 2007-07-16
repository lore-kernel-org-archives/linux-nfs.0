From: Chuck Lever <chuck.lever@oracle.com>
Subject: [PATCH 00/17] RFC: proposed changes to the NFS mount command
Date: Sun, 15 Jul 2007 23:14:48 -0400
Message-ID: <20070716030150.11209.85724.stgit@manray.1015granger.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: nfs@lists.sourceforge.net
To: neilb@suse.de
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.92]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1IAH2t-0001gl-JS
	for nfs@lists.sourceforge.net; Sun, 15 Jul 2007 20:14:47 -0700
Received: from flpvm09.prodigy.net ([207.115.20.39])
	by mail.sourceforge.net with esmtp (Exim 4.44) id 1IAH2w-0005nP-6o
	for nfs@lists.sourceforge.net; Sun, 15 Jul 2007 20:14:51 -0700
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

Hi Neil-

I've got a series of patches to the NFS mount command that prepare it
for using a C string to pass mount options to the kernel, rather than
a binary nfs_mount_data structure.

The goal of these clean-ups is to allow the creation of a ./configure
option that will disable building nfsmount.c and nfs4mount.c, and
enable building a version of these files that will introduce support
for passing mount options as a string (that work is yet to be done).

They certainly need some testing yet, but can you take a look at these
and tell me if they are generally acceptable or if I need to take a
different direction?  Hopefully they are straightforward and won't take
much of your time.

Thanks in advance for your advice!

-- 
corporate:    <chuck dot lever at oracle dot com>

-------------------------------------------------------------------------
This SF.net email is sponsored by DB2 Express
Download DB2 Express C - the FREE version of DB2 express and take
control of your XML. No limits. Just data. Click to get it now.
http://sourceforge.net/powerbar/db2/
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
