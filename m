From: Frank van Maarseveen <frankvm@frankvm.com>
Subject: exportfs bug
Date: Wed, 16 May 2007 17:34:38 +0200
Message-ID: <20070516153438.GA30140@janus>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
To: Linux NFS mailing list <nfs@lists.sourceforge.net>
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.91]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1HoLWV-0001nj-Md
	for nfs@lists.sourceforge.net; Wed, 16 May 2007 08:34:45 -0700
Received: from frankvm.xs4all.nl ([80.126.170.174] helo=janus.localdomain)
	by mail.sourceforge.net with esmtp (Exim 4.44) id 1HoLWU-0004od-UP
	for nfs@lists.sourceforge.net; Wed, 16 May 2007 08:34:45 -0700
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

Multiple exportfs commands within a second don't work as expected. This
is caused by writing either the wall clock time or the /etc/exports mtime
to various /proc files, all with the granularity of 1 second. Scripts
can easily issue more than one exportfs command within that time.

A repeated sequence of

- script modifies /etc/exports
- script runs exportfs -r

fails horribly (client gets EACCES, ESTALE)

IMO exportfs should at least hide the time granularity problem e.g. by
maintaining a timestamp file, waiting if necessary.

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
