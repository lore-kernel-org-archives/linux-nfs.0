From: Tengxiao Wu - Sun Microsystems <Tengxiao.Wu@Sun.COM>
Subject: NFS/TCP mount problem
Date: Fri, 12 Jul 2002 13:57:11 +0200 (MEST)
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <200207121157.g6CBvBg03130@bebop.France.Sun.COM>
Reply-To: Tengxiao Wu - Sun Microsystems <Tengxiao.Wu@Sun.COM>
Mime-Version: 1.0
Content-Type: TEXT/plain; charset=us-ascii
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from nwkea-mail-2.sun.com ([192.18.42.14])
	by usw-sf-list1.sourceforge.net with esmtp (Exim 3.31-VA-mm2 #1 (Debian))
	id 17Sz31-00023q-00
	for <nfs@lists.sourceforge.net>; Fri, 12 Jul 2002 04:57:19 -0700
Received: from bebop.France.Sun.COM ([129.157.174.15])
	by nwkea-mail-2.sun.com (8.9.3+Sun/8.9.3) with ESMTP id EAA22115
	for <nfs@lists.sourceforge.net>; Fri, 12 Jul 2002 04:57:12 -0700 (PDT)
Received: from buse (buse [129.157.212.11])
	by bebop.France.Sun.COM (8.11.6+Sun/8.10.2/ENSMAIL,v2.2) with SMTP id g6CBvBg03130
	for <nfs@lists.sourceforge.net>; Fri, 12 Jul 2002 13:57:11 +0200 (MEST)
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

Hi, all
I am trying nfs on tcp under linux 2.4.18
side server: 
server:/tmp# rpcinfo -p
   program vers proto   port
    100000    2   tcp    111  portmapper
    100000    2   udp    111  portmapper
    100024    1   udp   1024  status
    100024    1   tcp   1024  status
    100003    2   udp   2049  nfs
    100003    3   udp   2049  nfs
    100021    1   udp   1028  nlockmgr
    100021    3   udp   1028  nlockmgr
    100021    4   udp   1028  nlockmgr
    100005    1   udp   1029  mountd
    100005    1   tcp   1026  mountd
    100005    2   udp   1029  mountd
    100005    2   tcp   1026  mountd
    100005    3   udp   1029  mountd
    100005    3   tcp   1026  mountd
    
side client:
    I tried: mount -o tcp,vers=3 server:/direxport ./mountpoint
    
but I had a error message:
    nfs server reported service unavailable: Address already in use

but if I use nfs/udp(default) it seems ok.

Can someone help me? thx a lot.

Tengxiao



-------------------------------------------------------
This sf.net email is sponsored by:ThinkGeek
Gadgets, caffeine, t-shirts, fun stuff.
http://thinkgeek.com/sf
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
