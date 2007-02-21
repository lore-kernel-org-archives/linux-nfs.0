From: "Jesper Juhl" <jesper.juhl@gmail.com>
Subject: 2.6.13.4 - "lockd: weird return 1 for CANCEL call"
Date: Wed, 21 Feb 2007 11:46:58 +0100
Message-ID: <9a8748490702210246j38a1ca4bi8de371ba6829ada9@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: Linux Kernel Mailing List <linux-kernel@vger.kernel.org>
To: nfs@lists.sourceforge.net
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.92]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1HJozz-0002B9-Gl
	for nfs@lists.sourceforge.net; Wed, 21 Feb 2007 02:46:59 -0800
Received: from wr-out-0506.google.com ([64.233.184.234])
	by mail.sourceforge.net with esmtp (Exim 4.44) id 1HJp00-0000ut-6p
	for nfs@lists.sourceforge.net; Wed, 21 Feb 2007 02:47:01 -0800
Received: by wr-out-0506.google.com with SMTP id i4so2433851wra
	for <nfs@lists.sourceforge.net>; Wed, 21 Feb 2007 02:46:59 -0800 (PST)
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

Greetings,

I just got a unusual message from lockd on a webserver running a
custom compiled 2.6.13.4 (yes it is ancient, I know).

# uname -a
Linux webserv.somedomain.example 2.6.13.4 #1 SMP Wed Nov 16 10:03:05
CET 2005 i686 unknown

# dmesg | tail -n 3
do_vfs_lock: VFS is out of sync with lock manager!
lockd: weird return 1 for CANCEL call
lockd: weird return 1 for CANCEL call

The server seems to be running fine, so I'm not really worried, but I
thought maybe someone would like to know. :-)


-- 
Jesper Juhl <jesper.juhl@gmail.com>
Don't top-post  http://www.catb.org/~esr/jargon/html/T/top-post.html
Plain text mails only, please      http://www.expita.com/nomime.html

-------------------------------------------------------------------------
Take Surveys. Earn Cash. Influence the Future of IT
Join SourceForge.net's Techsay panel and you'll get the chance to share your
opinions on IT & business topics through brief surveys-and earn cash
http://www.techsay.com/default.php?page=join.php&p=sourceforge&CID=DEVDEV
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
