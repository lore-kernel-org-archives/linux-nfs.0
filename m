From: "Vadim A. Markel" <vmarkel@mail.med.upenn.edu>
Subject: NFS server Itanium-II server running AS 3.3
Date: Fri, 1 Apr 2005 16:38:30 -0500 (EST)
Message-ID: <Pine.LNX.4.44.0504011634440.1448-100000@H102PC1.seas.upenn.edu>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.11] helo=sc8-sf-mx1.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1DHTmF-0006ew-2C
	for nfs@lists.sourceforge.net; Fri, 01 Apr 2005 13:34:03 -0800
Received: from mail87.messagelabs.com ([216.82.255.99])
	by sc8-sf-mx1.sourceforge.net with smtp (Exim 4.41)
	id 1DHTmC-0007Ob-JZ
	for nfs@lists.sourceforge.net; Fri, 01 Apr 2005 13:34:02 -0800
Received: from H102PC1.SEAS.upenn.edu (H102PC1.SEAS.upenn.edu [158.130.14.210])
	by pobox.upenn.edu (Postfix) with ESMTP id 48776533F
	for <nfs@lists.sourceforge.net>; Fri,  1 Apr 2005 16:33:55 -0500 (EST)
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

Hello!

I am having problem starting an NSF service. I have an
Itanium-II server running RedHat AS version 3 update 3. I would like
to share directories on this server with Itanium-II workstations
running RedHat AW 2.1. 

Here are the configuration files on the server [hay311-11]. (IP
address of a client workstation is 158.130.14.210).


[vmarkel@hay311-11 /etc]$ more exports
/opt                     158.130.14.210(ro,insecure,sync,no_subtree_check,insecure_locks)

[vmarkel@hay311-11 /etc]$ more hosts.allow
#
# hosts.allow	This file describes the names of the hosts which are
#		allowed to use the local INET services, as decided
#		by the '/usr/sbin/tcpd' server.
#
portmap: 158.130.14.210
lockd:   158.130.14.210
mountd:  158.130.14.210
rquotad: 158.130.14.210
statd:   158.130.14.210

[vmarkel@hay311-11 /etc]$ more hosts.deny
#
# hosts.deny	This file describes the names of the hosts which are
#		*not* allowed to use the local INET services, as decided
#		by the '/usr/sbin/tcpd' server.
#
# The portmap line is redundant, but it is left to remind you that
# the new secure portmap uses hosts.deny and hosts.allow.  In particular
# you should know that NFS uses portmap!
portmap:ALL
lockd:ALL
mountd:ALL
rquotad:ALL
statd:ALL
[vmarkel@hay311-11 /etc]$ 



Here is the outputs of rpcinfo run on the client:

[vmarkel@H102PC1 vmarkel]# /usr/sbin/rpcinfo -p
   program vers proto   port
    100000    2   tcp    111  portmapper
    100000    2   udp    111  portmapper
    100024    1   udp  32768  status
    100024    1   tcp  32768  status
    391002    2   tcp  32769  sgi_fam
    100011    1   udp    882  rquotad
    100011    2   udp    882  rquotad
    100011    1   tcp    885  rquotad
    100011    2   tcp    885  rquotad
    100005    1   udp  32769  mountd
    100005    1   tcp  32770  mountd
    100005    2   udp  32769  mountd
    100005    2   tcp  32770  mountd
    100005    3   udp  32769  mountd
    100005    3   tcp  32770  mountd
    100003    2   udp   2049  nfs
    100003    3   udp   2049  nfs
    100021    1   udp  32770  nlockmgr
    100021    3   udp  32770  nlockmgr
    100021    4   udp  32770  nlockmgr
[vmarkel@H102PC1 vmarkel]# 


[vmarkel@H102PC1 vmarkel]# /usr/sbin/rpcinfo -p whale.seas.upenn.edu
   program vers proto   port
    100000    2   tcp    111  portmapper
    100000    2   udp    111  portmapper
    100024    1   udp  32768  status
    100024    1   tcp  32768  status
    391002    2   tcp  32769  sgi_fam
    100003    2   udp   2049  nfs
    100003    3   udp   2049  nfs
    100003    2   tcp   2049  nfs
    100003    3   tcp   2049  nfs
    100021    1   udp  32770  nlockmgr
    100021    3   udp  32770  nlockmgr
    100021    4   udp  32770  nlockmgr
    100021    1   tcp  32774  nlockmgr
    100021    3   tcp  32774  nlockmgr
    100021    4   tcp  32774  nlockmgr
    100011    1   udp    832  rquotad
    100011    2   udp    832  rquotad
    100011    1   tcp    835  rquotad
    100011    2   tcp    835  rquotad
    100005    1   udp    838  mountd
    100005    1   tcp    841  mountd
    100005    2   udp    838  mountd
    100005    2   tcp    841  mountd
    100005    3   udp    838  mountd
    100005    3   tcp    841  mountd
[vmarkel@H102PC1 vmarkel]# 

(here whale.seas.upenn.edu is the domain name of the server).


When I try to mount, I am timed out:

[vmarkel@H102PC1 vmarkel]# mount whale.seas.upenn.edu:/opt /whale
mount: RPC: Timed out
[vmarkel@H102PC1 vmarkel]# 


Please help!

Thank you, -- Vadim Markel



-------------------------------------------------------
SF email is sponsored by - The IT Product Guide
Read honest & candid reviews on hundreds of IT Products from real users.
Discover which products truly live up to the hype. Start reading now.
http://ads.osdn.com/?ad_id=6595&alloc_id=14396&op=click
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
