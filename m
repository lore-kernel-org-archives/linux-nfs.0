From: Terry Spaulding <spauld@us.ibm.com>
Subject: setting up NFS and autofs to use specific ports for nfs, lockd,
 mountd, etc .....
Date: Mon, 16 Apr 2007 16:36:19 -0400
Message-ID: <OF767BD0CF.B0C0B8B2-ON852572BF.00705A7F-852572BF.00713038@us.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
To: nfs@lists.sourceforge.net
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.91]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1HdXwA-0004aY-5l
	for nfs@lists.sourceforge.net; Mon, 16 Apr 2007 13:36:34 -0700
Received: from e1.ny.us.ibm.com ([32.97.182.141])
	by mail.sourceforge.net with esmtp (Exim 4.44) id 1HdXwB-0003l6-By
	for nfs@lists.sourceforge.net; Mon, 16 Apr 2007 13:36:36 -0700
Received: from d01relay02.pok.ibm.com (d01relay02.pok.ibm.com [9.56.227.234])
	by e1.ny.us.ibm.com (8.13.8/8.13.8) with ESMTP id l3GKaQhX013241
	for <nfs@lists.sourceforge.net>; Mon, 16 Apr 2007 16:36:26 -0400
Received: from d01av04.pok.ibm.com (d01av04.pok.ibm.com [9.56.224.64])
	by d01relay02.pok.ibm.com (8.13.8/8.13.8/NCO v8.3) with ESMTP id
	l3GKaQK4534108
	for <nfs@lists.sourceforge.net>; Mon, 16 Apr 2007 16:36:26 -0400
Received: from d01av04.pok.ibm.com (loopback [127.0.0.1])
	by d01av04.pok.ibm.com (8.12.11.20060308/8.13.3) with ESMTP id
	l3GKaD1f001044
	for <nfs@lists.sourceforge.net>; Mon, 16 Apr 2007 16:36:13 -0400
Received: from d01ml251.pok.ibm.com (d01ml251.pok.ibm.com [9.56.227.119])
	by d01av04.pok.ibm.com (8.12.11.20060308/8.12.11) with ESMTP id
	l3GKaCTj000413
	for <nfs@lists.sourceforge.net>; Mon, 16 Apr 2007 16:36:12 -0400
List-Id: "Discussion of NFS under Linux development, interoperability,
	and testing." <nfs.lists.sourceforge.net>
List-Unsubscribe: <https://lists.sourceforge.net/lists/listinfo/nfs>,
	<mailto:nfs-request@lists.sourceforge.net?subject=unsubscribe>
List-Archive: <http://sourceforge.net/mailarchive/forum.php?forum=nfs>
List-Post: <mailto:nfs@lists.sourceforge.net>
List-Help: <mailto:nfs-request@lists.sourceforge.net?subject=help>
List-Subscribe: <https://lists.sourceforge.net/lists/listinfo/nfs>,
	<mailto:nfs-request@lists.sourceforge.net?subject=subscribe>
Sender: nfs-bounces@lists.sourceforge.net
Errors-To: nfs-bounces@lists.sourceforge.net


Can anyone provide me the steps necessary to set the NFS server and NFS
clients to use specific ports for nfs(nfsd) , lockd, mountd. I am trying to
setup my server and client to have these ports set at boot time. This is so
I can request the specific ports to be open thru the Firewalls for the
servers and the clients.

Any assistance or direction to doc would be greatly appreciated.

My servers are both SLES8 and SLES9 SP3. Clients are all SLES9 SP3.

My SLES9 Server (kernel 2.6.5-7.276-s390x #1 SMP Mon Jul 24 10:45:31 UTC
2006 s390x s390x s390x GNU/Linux)  :
 # rpcinfo -p
   program vers proto   port
    100000    2   tcp    111  portmapper
    100000    2   udp    111  portmapper
    100003    2   udp   2049  nfs
    100003    3   udp   2049  nfs
    100227    3   udp   2049  nfs_acl
    100003    2   tcp   2049  nfs
    100003    3   tcp   2049  nfs
    100227    3   tcp   2049  nfs_acl
    100024    1   udp  32773  status
    100021    1   udp  32773  nlockmgr
    100021    3   udp  32773  nlockmgr
    100021    4   udp  32773  nlockmgr
    100024    1   tcp  32843  status
    100021    1   tcp  32843  nlockmgr
    100021    3   tcp  32843  nlockmgr
    100021    4   tcp  32843  nlockmgr
    100005    1   udp    630  mountd
    100005    1   tcp    631  mountd
    100005    2   udp    630  mountd
    100005    2   tcp    631  mountd
    100005    3   udp    630  mountd
    100005    3   tcp    631  mountd

My SLES8 server (kernel 2.4.21-251-default #1 SMP Sun Sep 26 14:07:15 UTC
2004 s390 unknown) :
 # rpcinfo -p
   program vers proto   port
    100000    2   tcp    111  portmapper
    100000    2   udp    111  portmapper
    100003    2   udp   2049  nfs
    100003    3   udp   2049  nfs
    100003    2   tcp   2049  nfs
    100003    3   tcp   2049  nfs
    100021    1   udp   1024  nlockmgr
    100021    3   udp   1024  nlockmgr
    100021    4   udp   1024  nlockmgr
    100021    1   tcp   1967  nlockmgr
    100021    3   tcp   1967  nlockmgr
    100021    4   tcp   1967  nlockmgr
    100005    1   udp   1027  mountd
    100005    1   tcp   1968  mountd
    100005    2   udp   1027  mountd
    100005    2   tcp   1968  mountd
    100005    3   udp   1027  mountd
    100005    3   tcp   1968  mountd

TIA ....................

Regards,
Terry L. Spaulding
IBM
spauld@us.ibm.com

"The third-rate mind is only happy when it is thinking with the majority.
The second-rate mind is only happy when it is thinking with the minority.
The first-rate mind is only happy when it is thinking." -- A.A. Milne
(1882-1956)


-------------------------------------------------------------------------
This SF.net email is sponsored by DB2 Express
Download DB2 Express C - the FREE version of DB2 express and take
control of your XML. No limits. Just data. Click to get it now.
http://sourceforge.net/powerbar/db2/
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
