From: Kevin <Fear@shmack.us>
Subject: RPC timeout errors
Date: Mon, 11 Nov 2002 00:21:54 -0500
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <02111100215404.06294@192.168.0.254>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from smtp.comcast.net ([24.153.64.2])
	by usw-sf-list1.sourceforge.net with esmtp (Exim 3.31-VA-mm2 #1 (Debian))
	id 18B7CZ-00075h-00
	for <nfs@lists.sourceforge.net>; Sun, 10 Nov 2002 21:33:35 -0800
Received: from 192.168.0.254
 (bgp01093287bgs.waren401.mi.comcast.net [68.43.192.156])
 by mtaout02.icomcast.net
 (iPlanet Messaging Server 5.1 HotFix 1.5 (built Sep 23 2002))
 with SMTP id <0H5E00JP4CR5XP@mtaout02.icomcast.net> for
 nfs@lists.sourceforge.net; Mon, 11 Nov 2002 00:33:06 -0500 (EST)
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

I am running an nfs server and client; bot machines having RedHat 7.1 
installed with kernel 2.4.2-2 and nfs-utils-0.3.1-5.  The server seems fine.  
Everything in my host files are perfect.  Infact, i checked my messages file 
in /var and it shows the server allowing an incoming nfs connection from 
client  192.168.0.1.  

I have the following line in my /etc/fstab:
192.168.0.254:/home/Fear                /mnt/server1          nfs     
rw,hard,intr    0 0

With that added, i used to be able to type mount -a and it would mount 
everything in /etc/fstab.  It tries to mount the nfs, but chokes up & gives 
me the error "mount: RPC: Timed out".  I followed every instruction located 
in the Linux NFS HOWTO and it referred me to this e-mail for questions.

Thanks for your time.

Kevin


-------------------------------------------------------
This sf.net email is sponsored by:ThinkGeek
Welcome to geek heaven.
http://thinkgeek.com/sf
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
