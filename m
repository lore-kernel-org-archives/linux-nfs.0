From: Bill Johnstone <beejstone3@yahoo.com>
Subject: Configuration for NFSv3 only?
Date: Mon, 25 Jul 2005 13:40:47 -0700 (PDT)
Message-ID: <20050725204047.82740.qmail@web33907.mail.mud.yahoo.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.91] helo=mail.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1Dx9kv-0001CL-Fb
	for nfs@lists.sourceforge.net; Mon, 25 Jul 2005 13:40:57 -0700
Received: from web33907.mail.mud.yahoo.com ([66.163.178.71])
	by mail.sourceforge.net with smtp (Exim 4.44)
	id 1Dx9ku-00023C-9u
	for nfs@lists.sourceforge.net; Mon, 25 Jul 2005 13:40:57 -0700
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

Hello all.

What I would like to do is configure my server and clients to use NFSv3
only.  I'm running recent 2.6 kernels, e.g. 2.6.12 .  I have read the
FAQ on nfs.sourceforge.net .

My kernel on the server is configured for Providing NFS3 client and
server support.  My kernel on the test client is configured for NFS3
client support.

My init script on the server is giving rpc.mountd the "-N 1 -N 2"
command-line options.

Running "rpcinfo -p" on the server gives:

    100000    2   tcp    111  portmapper
    100000    2   udp    111  portmapper
    100024    1   udp  32768  status
    100024    1   tcp  32769  status
    100003    2   udp   2049  nfs
    100003    3   udp   2049  nfs
    100003    2   tcp   2049  nfs
    100003    3   tcp   2049  nfs
    100021    1   udp  32770  nlockmgr
    100021    3   udp  32770  nlockmgr
    100021    4   udp  32770  nlockmgr
    100021    1   tcp  32770  nlockmgr
    100021    3   tcp  32770  nlockmgr
    100021    4   tcp  32770  nlockmgr
    100005    3   udp    687  mountd
    100005    3   tcp    690  mountd

On the client, trying to perform a "mount -o vers=3D3 <server
IP>:<exportname> <local mountpoint>" gives the error "NFSv3 not
supported!" and the mount fails.  If I remove the options to
rpc.mountd,   and do not specify "-o vers=3D3" on the client side, then
mountd listens for protocol versions 1 and 2, and the mount succeeds.

This leads me to the following questions:

1. Should "rpcinfo -p" list a version 3 for portmapper in order for
NFSv3 to be successfully used, or should portmapper only be at version
2 even for the NFSv3 protocol?

2. Is it possible to tell the other NFS-related daemons to only listen
for NFSv3, e.g. "status" only seems to be speaking version 1, the nfs
daemon versions 2 and 3, and "nlockmgr" versions 1, 3, and 4.

3. Any suggestions on how to troubleshoot this problem?

Thanks.


	=09
__________________________________=20
Yahoo! Mail for Mobile=20
Take Yahoo! Mail with you! Check email on your mobile phone.=20
http://mobile.yahoo.com/learn/mail=20


-------------------------------------------------------
SF.Net email is sponsored by: Discover Easy Linux Migration Strategies
from IBM. Find simple to follow Roadmaps, straightforward articles,
informative Webcasts and more! Get everything you need to get up to
speed, fast. http://ads.osdn.com/?ad_id=3D7477&alloc_id=3D16492&op=3Dclic=
k
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
