From: Juergen Rose <rose@rz.uni-potsdam.de>
Subject: "rpcinfo -u IP nfs" timeout
Date: Thu, 22 Jul 2004 20:46:37 +0200
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <1090521997.8708.14.camel@vilm.bioinf.mdc-berlin.de>
Mime-Version: 1.0
Content-Type: text/plain
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.12] helo=sc8-sf-mx2.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1Bniac-0008W3-6z
	for nfs@lists.sourceforge.net; Thu, 22 Jul 2004 11:46:46 -0700
Received: from server1.bbb2.mdc-berlin.de ([141.80.34.10] ident=root)
	by sc8-sf-mx2.sourceforge.net with esmtp (Exim 4.34)
	id 1Bniaa-0007wp-Sd
	for nfs@lists.sourceforge.net; Thu, 22 Jul 2004 11:46:45 -0700
Received: from orion.bbb3.mdc-berlin.de (orion.bbb3.mdc-berlin.de [141.80.35.20])
	by server1.bbb2.mdc-berlin.de (8.12.10/8.12.10) with ESMTP id i6MIkcX8017877
	for <nfs@lists.sourceforge.net>; Thu, 22 Jul 2004 20:46:38 +0200 (METDST)
Received: from vilm.bioinf.mdc-berlin.de (IDENT:1203@vilm.bioinf.mdc-berlin.de [141.80.80.51])
	by orion.bbb3.mdc-berlin.de (8.11.6/8.11.2) with SMTP id i6MIkb421330
	for <nfs@lists.sourceforge.net>; Thu, 22 Jul 2004 20:46:37 +0200 (MET DST)
To: nfs@lists.sourceforge.net
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

sitting at "bornholm" (linux-2.6.[6-8]), I have problems to mount
filesystems from a nfs server. I found, that there is already a strange
behaviour of rpcinfo, if I want to get rpc information only about
bornholm. I get the following response:
root@bornholm:/root(10)# rpcinfo -p localhost
   program vers proto   port
    100000    2   tcp    111  portmapper
    100000    2   udp    111  portmapper
    100024    1   udp  32768  status
    100024    1   tcp  32768  status
    100003    2   udp   2049  nfs
    100003    3   udp   2049  nfs
    100003    2   tcp   2049  nfs
    100003    3   tcp   2049  nfs
    100021    1   udp  32770  nlockmgr
    100021    3   udp  32770  nlockmgr
    100021    4   udp  32770  nlockmgr
    100021    1   tcp  32769  nlockmgr
    100021    3   tcp  32769  nlockmgr
    100021    4   tcp  32769  nlockmgr
    100005    1   udp    817  mountd
    100005    1   tcp    820  mountd
    100005    2   udp    817  mountd
    100005    2   tcp    820  mountd
    100005    3   udp    817  mountd
    100005    3   tcp    820  mountd
root@bornholm:/root(11)# rpcinfo -p bornholm 
   program vers proto   port
    100000    2   tcp    111  portmapper
    100000    2   udp    111  portmapper
    100024    1   udp  32768  status
    100024    1   tcp  32768  status
    100003    2   udp   2049  nfs
    100003    3   udp   2049  nfs
    100003    2   tcp   2049  nfs
    100003    3   tcp   2049  nfs
    100021    1   udp  32770  nlockmgr
    100021    3   udp  32770  nlockmgr
    100021    4   udp  32770  nlockmgr
    100021    1   tcp  32769  nlockmgr
    100021    3   tcp  32769  nlockmgr
    100021    4   tcp  32769  nlockmgr
    100005    1   udp    817  mountd
    100005    1   tcp    820  mountd
    100005    2   udp    817  mountd
    100005    2   tcp    820  mountd
    100005    3   udp    817  mountd
    100005    3   tcp    820  mountd
root@bornholm:/root(12)# rpcinfo -u localhost nfs 
program 100003 version 2 ready and waiting
program 100003 version 3 ready and waiting
root@bornholm:/root(13)# rpcinfo -u bornholm nfs
rpcinfo: RPC: Timed out
program 100003 version 0 is not available
root@bornholm:/root(14)# ifconfig
eth0      Link encap:Ethernet  HWaddr 00:E0:81:51:39:C5  
          inet addr:141.80.80.32  Bcast:141.80.80.255 
Mask:255.255.255.0
...
root@bornholm:/root(15)# rpcinfo -u 141.80.80.32 nfs
rpcinfo: RPC: Timed out
program 100003 version 0 is not available

What can be the reason, that the last two rpcinfo calls produce
timeouts?
Please help!  
		Regards
			Juergen

-- 
Juergen Rose <rose@rz.uni-potsdam.de>
Max-Delbrueck-Zentrum



-------------------------------------------------------
This SF.Net email is sponsored by BEA Weblogic Workshop
FREE Java Enterprise J2EE developer tools!
Get your free copy of BEA WebLogic Workshop 8.1 today.
http://ads.osdn.com/?ad_id=4721&alloc_id=10040&op=click
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
