From: "Smith, Travis" <Travis.Smith@tycoelectronics.com>
Subject: setting default permissions
Date: Thu, 12 Sep 2002 09:51:49 -0400
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <5CE83B571395D311A2160008C7B12CDE17B523B8@ammex003.amp.com>
Mime-Version: 1.0
Content-Type: text/plain;
	charset="iso-8859-1"
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from nat208239159213.amp.com ([208.239.159.213] helo=us038mx00.amp.com)
	by usw-sf-list1.sourceforge.net with esmtp (Exim 3.31-VA-mm2 #1 (Debian))
	id 17pUhJ-0002c3-00
	for <nfs@lists.sourceforge.net>; Thu, 12 Sep 2002 07:11:58 -0700
To: "'nfs@lists.sourceforge.net'" <nfs@lists.sourceforge.net>
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
List-Archive: <http://www.geocrawler.com/redir-sf.php3?list=nfs>

Is there a way to specify the permissions on an exported directory beyond
that of locking it down to certain machines/users.  What I want to do is
export a directory from a linux box to some HP boxen and make sure that any
file they write to the directory has full 777 permissions.  Security isn't
an issue.

Thanks,
Travis Smith


-------------------------------------------------------
This sf.net email is sponsored by:ThinkGeek
Welcome to geek heaven.
http://thinkgeek.com/sf
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
