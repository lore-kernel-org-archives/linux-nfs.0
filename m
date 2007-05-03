From: Jonathan Woithe <jwoithe@physics.adelaide.edu.au>
Subject: Clients not displaying NFS quotas
Date: Thu, 3 May 2007 11:43:15 +0930 (CST)
Message-ID: <200705030213.l432DFce017563@turbo.physics.adelaide.edu.au>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: Jonathan Woithe <jwoithe@physics.adelaide.edu.au>
To: nfs@lists.sourceforge.net
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.91]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1HjQoy-00029G-Gg
	for nfs@lists.sourceforge.net; Wed, 02 May 2007 19:13:28 -0700
Received: from adelphi.physics.adelaide.edu.au ([129.127.102.1])
	by mail.sourceforge.net with esmtps (TLSv1:AES256-SHA:256)
	(Exim 4.44) id 1HjQp0-0008Ac-IT
	for nfs@lists.sourceforge.net; Wed, 02 May 2007 19:13:31 -0700
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

We have a Slackware 9.1 box (with numerous software upgrades) exporting a
directory to various NFS clients.  While running a 2.4.x kernel this all
worked fine - users on clients could use "quota" to display their quota
information.  When the system was moved to a 2.6.19.2 kernel a few months
ago the clients could no longer display quota information.  The server
still knew and enforced the quotas, it's just that from the client's
point of view there were no quotas.

The system is running the following software versions:

  * kernel 2.6.19.2
  * nfs-utils 1.0.10
  * util-linux 2.12
  * portmap 5.0

The filesystem concerned is reiserfs3.  The kernel has reiserfs quota
support enabled.

The relevant partition is mounted on the server using an fstab entry of

  /dev/...  /home/foobar  reiserfs  usrquota

All clients mount the volume via the automounter with the "hard,intr,bg"
mount options.

Users cannot log into the NFS server.

We have clients running various versions of redhat, fedora and slackware
with different kernels.  In all cases things worked with the 2.4.x
kernel and don't now.  It therefore seems to be a server-related issue.

Does anyone have any idea as to why client access to quota information
isn't working in this scenario?

Regards
  jonathan

-------------------------------------------------------------------------
This SF.net email is sponsored by DB2 Express
Download DB2 Express C - the FREE version of DB2 express and take
control of your XML. No limits. Just data. Click to get it now.
http://sourceforge.net/powerbar/db2/
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
