From: "FuturaHost.Com's "Support <support3@futurahost.com>
Subject: i insist! intermitent mount: RPC: Timed - please help
Date: 18 Jul 2003 03:07:22 +0200
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <1058490442.6067.7.camel@litio.futurahostdns.com>
References: <1058397662.3190.2.camel@litio.futurahostdns.com>
Reply-To: support3@futurahost.com
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-15
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from [216.218.212.247] (helo=mars.futurahostdns.com)
	by sc8-sf-list1.sourceforge.net with esmtp
	(Cipher TLSv1:DES-CBC3-SHA:168) (Exim 3.31-VA-mm2 #1 (Debian))
	id 19dJYt-000265-00
	for <nfs@lists.sourceforge.net>; Thu, 17 Jul 2003 17:57:27 -0700
To: nfs@lists.sourceforge.net
In-Reply-To: <1058397662.3190.2.camel@litio.futurahostdns.com>
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


	Im posting in the wrong list? Can someone in this list kindly make me
note it and point me to the right one?

	Please also note that i tried ALL, and this does not seems like a
portmapper problem

Thanks again

Pablo

El jue, 17 de 07 de 2003 a las 01:21, FuturaHost.Com's Support escribió:
>          Hello all
>  
>  From the client:
>  [root@beryllium bin]# iptables -L -n (output abreviated)
>  ACCEPT     tcp  --  ip.of.the.client      0.0.0.0/0          tcp
>  ACCEPT     tcp  --  ip.of.the.server      0.0.0.0/0          tcp
>  ACCEPT     udp  --  ip.of.the.client      0.0.0.0/0          udp
>  ACCEPT     udp  --  ip.of.the.server      0.0.0.0/0          udp
>  [root@beryllium bin]# rpcinfo -p server
>     program vers proto   port
>      100000    2   tcp    111  portmapper
>      100000    2   udp    111  portmapper
>      100011    1   udp    770  rquotad
>      100011    2   udp    770  rquotad
>      100005    1   udp    778  mountd
>      100005    1   tcp    781  mountd
>      100005    2   udp    778  mountd
>      100005    2   tcp    781  mountd
>      100005    3   udp    778  mountd
>      100005    3   tcp    781  mountd
>      100003    2   udp   2049  nfs
>      100003    3   udp   2049  nfs
>      100021    1   udp  33829  nlockmgr
>      100021    3   udp  33829  nlockmgr
>      100021    4   udp  33829  nlockmgr
>  [root@beryllium bin]# rpcinfo -u client nfs
>  program 100003 version 2 ready and waiting
>  program 100003 version 3 ready and waiting
>  [root@beryllium bin]# rpcinfo -u client mountd
>  program 100005 version 1 ready and waiting
>  program 100005 version 2 ready and waiting
>  program 100005 version 3 ready and waiting
>  [root@beryllium bin]# rpcinfo -u client nlockmgr
>  program 100021 version 1 ready and waiting
>  rpcinfo: RPC: Program/version mismatch; low version = 1, high version =
>  4
>  program 100021 version 2 is not available
>  program 100021 version 3 ready and waiting
>  program 100021 version 4 ready and waiting
>  [root@beryllium bin]#
>  
>  From the server:
>  
>  [root@mars service]# iptables -L -n (output abreviated)
>  ACCEPT     tcp  --  clientipaddr         0.0.0.0/0          tcp
>  ACCEPT     udp  --  clientipaddr         0.0.0.0/0          udp
>  [root@mars service]# rpcinfo -p
>     program vers proto   port
>      100000    2   tcp    111  portmapper
>      100000    2   udp    111  portmapper
>      100011    1   udp    770  rquotad
>      100011    2   udp    770  rquotad
>      100005    1   udp    778  mountd
>      100005    1   tcp    781  mountd
>      100005    2   udp    778  mountd
>      100005    2   tcp    781  mountd
>      100005    3   udp    778  mountd
>      100005    3   tcp    781  mountd
>      100003    2   udp   2049  nfs
>      100003    3   udp   2049  nfs
>      100021    1   udp  33829  nlockmgr
>      100021    3   udp  33829  nlockmgr
>      100021    4   udp  33829  nlockmgr
>  [root@mars service]# rpcinfo -u localhost nfs
>  program 100003 version 2 ready and waiting
>  program 100003 version 3 ready and waiting
>  [root@mars service]# rpcinfo -u localhost mountd
>  program 100005 version 1 ready and waiting
>  program 100005 version 2 ready and waiting
>  program 100005 version 3 ready and waiting
>  [root@mars service]# rpcinfo -u localhost nlockmgr
>  program 100021 version 1 ready and waiting
>  rpcinfo: RPC: Program/version mismatch; low version = 1, high version =
>  4
>  program 100021 version 2 is not available
>  program 100021 version 3 ready and waiting
>  program 100021 version 4 ready and waiting
>  [root@mars service]#
>  
> 
> 
>  Here goes the funny part:
>  [root@beryllium bin]# /bin/mount -t nfs -o,hard mars:/ /mnt/nfs
>  mount: RPC: Timed out
>  [root@beryllium bin]#
>  
>  But, when im trying to mount from the client, i see this in the server:
>  
>  [root@mars service]# netstat -alnp | grep :53
>  udp        0      0 an.ip.onthe.server:34451  
>  anip.on.the.server:53      
>  ESTABLISHED 13781/rpc.mountd
>  udp        0      0 anip.on.the.server:34453  
>  anip.on.the.server:53      
>  ESTABLISHED 13781/rpc.mountd
>  
>  udp        0      0 eth0.ip.on.server:34456  
>  some.ip.querying.dnscache:53       
>  ESTABLISHED 13781/rpc.mountd
>  udp        0      0 eth0.ip.on.server:34457  
>  a-dns.server.onresolv.conf:53            
>  ESTABLISHED 13781/rpc.mountd
>  
> 
>  It's like rpc.mountd is binding hiself on port 53.
>  
> 
>  This thing is happening in around 25 servers on our network...
>  
>  Obvious to say: PLEASE HELP :-)
>  
> 
> 
>  Pablo Povarchik
>  -- 
>  FuturaHost.Com Support
>  http://futurahost.com/
>  24/7/365 Toll Free Support: 800592259
>  24/7/365 Support: +39 0461 592710
>  FAX: +39 0461 592056
-- 
FuturaHost.Com Support
http://futurahost.com/
24/7/365 Toll Free Support: 800592259
24/7/365 Support: +39 0461 592710
FAX: +39 0461 592056



-------------------------------------------------------
This SF.net email is sponsored by: VM Ware
With VMware you can run multiple operating systems on a single machine.
WITHOUT REBOOTING! Mix Linux / Windows / Novell virtual machines at the
same time. Free trial click here: http://www.vmware.com/wl/offer/345/0
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
