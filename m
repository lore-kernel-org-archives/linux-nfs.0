From: "Amir Hermelin" <amir@montilio.com>
Subject: NFS request generator
Date: Wed, 10 Dec 2003 10:10:20 +0200
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <007201c3bef5$10e00e50$2801a8c0@CARTMAN>
Mime-Version: 1.0
Content-Type: text/plain;
	charset="us-ascii"
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.12] helo=sc8-sf-mx2.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.24)
	id 1ATzQf-0008Jb-3a
	for nfs@lists.sourceforge.net; Wed, 10 Dec 2003 00:10:41 -0800
Received: from [212.150.48.101] (helo=enigma.barak.net.il)
	by sc8-sf-mx2.sourceforge.net with esmtp (Exim 4.24)
	id 1ATzQe-0000T5-Ll
	for nfs@lists.sourceforge.net; Wed, 10 Dec 2003 00:10:40 -0800
Received: from CARTMAN ([62.90.35.123]) by enigma.barak.net.il
          (InterMail vK.4.04.00.00 201-232-137 license b2629777bce4038e9f419f7b71122558)
          with ESMTP id <20031210081206.FTFZ29986.enigma@CARTMAN>
          for <nfs@lists.sourceforge.net>; Wed, 10 Dec 2003 10:12:06 +0200
To: <nfs@lists.sourceforge.net>
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
I'm trying to experiment with NFS, where the server currently doesn't =
return
any replies.  This poses a problem, as clients wait for replies and =
can't
continue when a certain amount of requests are pending.  Even if I =
remove
the wait in the client, it wouldn't be able to continue requests since =
it
would miss some information (e.g. fh won't be returned from lookup
requests).
So, what I need is some script that simply generates NFS requests =
without
processing responses.  Anyone know of an available script/proggie that =
would
save me the time of writing one?

Thanks,
Amir.




-------------------------------------------------------
This SF.net email is sponsored by: SF.net Giveback Program.
Does SourceForge.net help you be more productive?  Does it
help you create better code?  SHARE THE LOVE, and help us help
YOU!  Click Here: http://sourceforge.net/donate/
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
