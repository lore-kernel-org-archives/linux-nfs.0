From: "Lever, Charles" <Charles.Lever@netapp.com>
Subject: RE: NetApp nfs server support tcp v3 root file system?
Date: Wed, 4 Sep 2002 20:51:59 -0700
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <6440EA1A6AA1D5118C6900902745938E07D54E10@black.eng.netapp.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: nfs@lists.sourceforge.net
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from mx01-a.netapp.com ([198.95.226.53])
	by usw-sf-list1.sourceforge.net with esmtp (Exim 3.31-VA-mm2 #1 (Debian))
	id 17mngd-0002cv-00
	for <nfs@lists.sourceforge.net>; Wed, 04 Sep 2002 20:52:07 -0700
To: "'Hua Qin'" <qinhua@poisson.ecse.rpi.edu>
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

hua-

what does linuxB use by default to mount /dev ?  v2?
have you tried to get a network trace (pktt on
the filer) to find out more?

> I have NetApp as a nfs server, and on the NetApp, 
> /etc/exports  shows the correct configure: /vol/vol0/dev/  
> anon=0 I can mount /dev from  linuxA using v3 tcp nfs, then I 
> try to use /dev as root file to boot linuxB, I [Bcan not boot 
> successfully. I can see it got the ip address from dhcp 
> server, then after that:
> 
> Looking up port of RPC 100003/3 on 172.29.255.1  
> Looking up port of RPC 100005/3 on 172.29.255.1
> mount: server 172.29.255.1 not responding, timed out
> Root-NFS: Server returned error -5 while mounting /dev
> VFS: Unable to mount root fs via NFS, trying floppy.
> VFS: Insert root floppy and press ENTER
> VFS: Cannot open root device "nfs" or 02:00
> Please append a correct "root=" boot option
> Kernel panic: VFS: Unable to mount root fs on 02:00
> 
> But I can use udp v3 to boot it. so I am wondering, what will 
> cause this problem, someone has the same setup?


-------------------------------------------------------
This sf.net email is sponsored by: OSDN - Tired of that same old
cell phone?  Get a new here for FREE!
https://www.inphonic.com/r.asp?r=sourceforge1&refcode1=vs3390
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
