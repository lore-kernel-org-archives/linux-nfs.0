From: Payal Rathod <payal-nfs@scriptkitchen.com>
Subject: nfs client hanging
Date: Fri, 28 Apr 2006 09:28:53 -0400
Message-ID: <20060428132853.GA4431@tranquility.scriptkitchen.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.91] helo=mail.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1FZT1r-0007za-SK
	for nfs@lists.sourceforge.net; Fri, 28 Apr 2006 06:29:03 -0700
Received: from tranquility.scriptkitchen.com ([209.82.178.130] ident=qmailr)
	by mail.sourceforge.net with smtp (Exim 4.44)
	id 1FZT1m-00081s-BC
	for nfs@lists.sourceforge.net; Fri, 28 Apr 2006 06:28:59 -0700
To: nfs@lists.sourceforge.net
Sender: nfs-admin@lists.sourceforge.net
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
I am trying out NFS server on Mandrake 10.0 machine. I have /etc/exports 
as,
/home/test/ 192.168.10.101(ro,sync)

# cat /etc/hosts.allow
portmap: 192.168.10.0/255.255.255.0

# cat /etc/hosts.deny
telnetd:192.168.10.1

>From 192.168.10.101 I do,
mount 192.168.10.100:/home/test/ /mnt/tmp/

But the client hangs up for a very long time. What is wrong? On syslog 
of 192.168.10.100 I see,
Apr 28 09:18:40 designs rpc.mountd: authenticated mount request from 
192.168.10.101:916 for /home/test (/home/test)

The rpcinfo is given below. Can anyone tell what is wrong with the 
setup?
With warm regards,
-Payal




# rpcinfo -p
   program vers proto   port
    100000    2   tcp    111  portmapper
    100000    2   udp    111  portmapper
    100005    1   udp    651  mountd
    100005    1   tcp    654  mountd
    100005    2   udp    651  mountd
    100005    2   tcp    654  mountd
    100005    3   udp    651  mountd
    100005    3   tcp    654  mountd
    100003    2   udp   2049  nfs
    100003    3   udp   2049  nfs
    100003    4   udp   2049  nfs
    100003    2   tcp   2049  nfs
    100003    3   tcp   2049  nfs
    100003    4   tcp   2049  nfs
    100021    1   udp   1087  nlockmgr
    100021    3   udp   1087  nlockmgr
    100021    4   udp   1087  nlockmgr
    100021    1   tcp   1084  nlockmgr
    100021    3   tcp   1084  nlockmgr
    100021    4   tcp   1084  nlockmgr
    100024    1   udp    660  status
    100024    1   tcp    663  status




-------------------------------------------------------
Using Tomcat but need to do more? Need to support web services, security?
Get stuff done quickly with pre-integrated technology to make your job easier
Download IBM WebSphere Application Server v.1.0.1 based on Apache Geronimo
http://sel.as-us.falkag.net/sel?cmd=lnk&kid=120709&bid=263057&dat=121642
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
