From: Chris Dos <chris@chrisdos.com>
Subject: New error
Date: Sun, 02 Mar 2003 20:23:49 -0700
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <3E62CAC5.6070305@chrisdos.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii; format=flowed
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from 12-252-254-16.client.attbi.com
	([12.252.254.16] helo=windwalker.chrisdos.com ident=postfix)
	by sc8-sf-list1.sourceforge.net with esmtp (Exim 3.31-VA-mm2 #1 (Debian))
	id 18pgYY-0003Si-00
	for <nfs@lists.sourceforge.net>; Sun, 02 Mar 2003 19:23:59 -0800
Received: from localhost (localhost.localdomain [127.0.0.1])
	by windwalker.chrisdos.com (Postfix) with ESMTP id 712BA2CC1D9
	for <nfs@lists.sourceforge.net>; Sun,  2 Mar 2003 20:23:52 -0700 (MST)
Received: from windwalker.chrisdos.com ([127.0.0.1]) by localhost (windwalker.chrisdos.com [127.0.0.1]) (amavisd-new) with SMTP id 10538-10 for <nfs@lists.sourceforge.net>; Sun, 2 Mar 2003 20:23:50 -0000 (MST)
Received: from chrisdos.com (taffy.chrisdos.com [192.168.9.64])
	by windwalker.chrisdos.com (Postfix) with ESMTP id 0DC252CC137
	for <nfs@lists.sourceforge.net>; Sun,  2 Mar 2003 20:23:50 -0700 (MST)
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
List-Archive: <http://sourceforge.net/mailarchive/forum.php?forum=nfs>

I had a system crash on my main server and now that it's up, I'm 
constantly seeing this error in /var/log/messages and on the console

"kernel: nfsd: request from insecure port (ac1e02bc:47720)!"

I have no idea if this was happening before on this server as it's been 
completly rock solid and has been running as an extreamly high volume 
NAS for serveral servers for that last six months and I haven't needed 
to go into the server.  I'm running kernel 2.4.19 with all the NFS 
patches as of six months ago.  Any ideas on what might be causing this? 
  Thanks in advance.

	Chris Dos



-------------------------------------------------------
This sf.net email is sponsored by:ThinkGeek
Welcome to geek heaven.
http://thinkgeek.com/sf
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
