From: Nicolas Brainez <nb@many.be>
Subject: Performance problem
Date: 13 May 2002 17:10:16 +0200
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <1021302616.27660.20.camel@nb>
Mime-Version: 1.0
Content-Type: text/plain
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from 212.68.239.49.brutele.be ([212.68.239.49] helo=many.be)
	by usw-sf-list1.sourceforge.net with esmtp
	(Cipher TLSv1:DES-CBC3-SHA:168) (Exim 3.31-VA-mm2 #1 (Debian))
	id 177HR9-0005Ju-00
	for <nfs@lists.sourceforge.net>; Mon, 13 May 2002 08:08:32 -0700
Received: from localhost ([127.0.0.1] helo=localhost.localdomain)
	by many.be with esmtp (Exim 3.35 #1)
	id 177HQQ-0004jO-00
	for nfs@lists.sourceforge.net; Mon, 13 May 2002 17:07:46 +0200
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
List-Archive: <http://www.geocrawler.com/redir-sf.php3?list=nfs>

Hello,

I have an nfs server who exports some backup directories for the lan's
users, it's a new install.

First I would like say that's not an hardware problem, because we have
no problem to use appletalk, ftp, ...

I can mount remotly a partition on the nfs server without problem but
when I copy something on it, the client ('cp' in this case) hangs, and I
receive these messages on my console :

nfs: task XXX can't get a request slot

where XXX is begin from 1 to...

When I look on the server, the file I was trying to copy is only 8192
bytes :

-rwxr-xr-x    1 root     root         8192 May 13 16:56 bash

After looking web, newsgroup, etc.. I've tried all what I can do to
optimize performance (wsize=8192,rsize=8192,hard/soft, etc.. etc..)

The only changes is when I use wsize and rsize to 8192, the file I sent
to the server can goes to 16384 bytes, but never more..

This is a LAN of ~ 10 computers, 100mbps, and we use switchs.
The servers and workstation use Debian woody, nfs kernel and user server
tried, same results.

Any type of help is welcome.

Thanks.

--
Nicolas Brainez


_______________________________________________________________

Have big pipes? SourceForge.net is looking for download mirrors. We supply
the hardware. You get the recognition. Email Us: bandwidth@sourceforge.net
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
