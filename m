From: Frank van Maarseveen <frankvm@frankvm.com>
Subject: nfsv3 server no longer responding after umount/mount
Date: Tue, 15 May 2007 16:11:39 +0200
Message-ID: <20070515141139.GA17583@janus>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
To: Linux NFS mailing list <nfs@lists.sourceforge.net>
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.91]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1HnxkZ-0003OV-5v
	for nfs@lists.sourceforge.net; Tue, 15 May 2007 07:11:39 -0700
Received: from frankvm.xs4all.nl ([80.126.170.174] helo=janus.localdomain)
	by mail.sourceforge.net with esmtp (Exim 4.44) id 1Hnxka-0005mz-OG
	for nfs@lists.sourceforge.net; Tue, 15 May 2007 07:11:42 -0700
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

export options: rw,sync,no_root_squash,no_subtree_check,mp,fsid=2886795870

The following sequence renders the server dead (unresponsive that is)

	ip addr del... (delete IP address used by the client)
	exportfs -f
	umount /exported-fs
	mount /exported-fs
	ip addr add... (add IP address again)

I do not understand why but a second "exportfs -f" afterwards fixes it.

When trying this without "mp", the client will report ESTALE forever.

-- 
Frank

-------------------------------------------------------------------------
This SF.net email is sponsored by DB2 Express
Download DB2 Express C - the FREE version of DB2 express and take
control of your XML. No limits. Just data. Click to get it now.
http://sourceforge.net/powerbar/db2/
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
