From: Robin Humble <rjh@cita.utoronto.ca>
Subject: max number of NFS mounts
Date: Mon, 7 Apr 2003 23:59:25 -0400
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <20030408035925.GB19119@marmot.cita.utoronto.ca>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from rail.cita.utoronto.ca ([128.100.76.4])
	by sc8-sf-list1.sourceforge.net with esmtp (Exim 3.31-VA-mm2 #1 (Debian))
	id 192kFF-00040F-00
	for <nfs@lists.sourceforge.net>; Mon, 07 Apr 2003 20:58:01 -0700
Received: from marmot.cita.utoronto.ca (localhost [127.0.0.1])
	by cita.utoronto.ca (8.12.5/8.12.5) with ESMTP id h383xPLk019136
	for <nfs@lists.sourceforge.net>; Mon, 7 Apr 2003 23:59:25 -0400
Received: (from rjh@localhost)
	by marmot.cita.utoronto.ca (8.12.5/8.12.5/Submit) id h383xPNg019134
	for nfs@lists.sourceforge.net; Mon, 7 Apr 2003 23:59:25 -0400
To: nfs@lists.sourceforge.net
Errors-To: nfs-admin@lists.sourceforge.net
List-Help: <mailto:nfs-request@lists.sourceforge.net?subject=help>
List-Post: <mailto:nfs@lists.sourceforge.net>
List-Subscribe: <https://lists.sourceforge.net/lists/listinfo/nfs>,
	<mailto:nfs-request@lists.sourceforge.net?subject=subscribe>
List-Id: Discussion of NFS under Linux development,
	interoperability,
	and testing. <nfs.lists.sourceforge.net>
List-Unsubscribe: <https://lists.sourceforge.net/lists/listinfo/nfs>,
	<mailto:nfs-request@lists.sourceforge.net?subject=unsubscribe>
List-Archive: <http://sourceforge.net/mailarchive/forum.php?forum=nfs>


Hi,

We have a large linux cluster with 256 backend nodes, 10 development
nodes, plus a few other mounts/machines of various sorts.

When using autofs in an attempt to mount all backend disks at once we
hit the 256 mounts limitation and only get to about 246 backend disks
mounted - this is a pain :-/

so yes, your message (that I eventually found via Neil Brown) was most
helpful and please add it to the FAQ and also into linux/Documentation/*
somewhere.
  http://sourceforge.net/mailarchive/message.php?msg_id=4215392

also, can you guess whether 2.5/2.6 will lift the lame 256 mounts
limit... ??

cheers,
robin

ps. please CC me on replies as I'm not subscribed to the list


-------------------------------------------------------
This SF.net email is sponsored by: ValueWeb: 
Dedicated Hosting for just $79/mo with 500 GB of bandwidth! 
No other company gives more support or power for your dedicated server
http://click.atdmt.com/AFF/go/sdnxxaff00300020aff/direct/01/
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
