From: "Didier CONTIS" <didier@ece.gatech.edu>
Subject: RE: Pb of optimization for a Cluster under Gigabit
Date: Wed, 7 Apr 2004 16:46:10 -0400
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <200404072046.i37KkAgE009317@mail.ece.gatech.edu>
References: <482A3FA0050D21419C269D13989C611302B07C06@lavender-fe.eng.netapp.com>
Mime-Version: 1.0
Content-Type: text/plain;
	charset="US-ASCII"
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.12] helo=sc8-sf-mx2.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1BBJwo-00070E-PF
	for nfs@lists.sourceforge.net; Wed, 07 Apr 2004 13:46:58 -0700
Received: from mail.ece.gatech.edu ([199.77.227.200])
	by sc8-sf-mx2.sourceforge.net with esmtp (TLSv1:DES-CBC3-SHA:168)
	(Exim 4.30)
	id 1BBJwo-0005WP-Ax
	for nfs@lists.sourceforge.net; Wed, 07 Apr 2004 13:46:58 -0700
Received: from localhost (bigzilla.ece.gatech.edu [130.207.225.103])
	by mail.ece.gatech.edu (8.12.10/8.12.10) with ESMTP id i37Kkvat009382
	for <nfs@lists.sourceforge.net>; Wed, 7 Apr 2004 16:46:57 -0400 (EDT)
Received: from mail.ece.gatech.edu ([199.77.227.200])
 by localhost (bigzilla.ece.gatech.edu [130.207.225.103]) (amavisd-new, port 10024)
 with LMTP id 21508-04 for <nfs@lists.sourceforge.net>;
 Wed,  7 Apr 2004 16:46:38 -0400 (EDT)
Received: from darkwolf (darkwolf.ee.gatech.edu [130.207.226.19])
	(authenticated bits=0)
	by mail.ece.gatech.edu (8.12.10/8.12.10) with ESMTP id i37KkAgE009317
	(version=TLSv1/SSLv3 cipher=RC4-MD5 bits=128 verify=NOT)
	for <nfs@lists.sourceforge.net>; Wed, 7 Apr 2004 16:46:10 -0400 (EDT)
To: <nfs@lists.sourceforge.net>
In-Reply-To: <482A3FA0050D21419C269D13989C611302B07C06@lavender-fe.eng.netapp.com>
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

 

>-----Original Message-----
>From: Lever, Charles [mailto:Charles.Lever@netapp.com] 
>Sent: Wednesday, April 07, 2004 12:40 AM
>To: Didier CONTIS
>Cc: nfs@lists.sourceforge.net
>Subject: RE: [NFS] Pb of optimization for a Cluster under Gigabit
>
>hi didier-
>
>do you really need to use the "sync" mount option on
>the clients?  the "sync" export option on the server
>should be enough for most applications.

That definitely helped. Now the NFS options passed
via automount to the client are:

rw,nfsvers=3,udp,hard,intr,rsize=8192,wsize=8192

However, the load of the nfs server still goes up to 3.5

What else could I check for ?

Thanks - Didier.

The output of nfsstat look like (after 2 days of uptime)

[didier@xnfs1 ~]$ /usr/sbin/nfsstat 
Server rpc stats:
calls      badcalls   badauth    badclnt    xdrcall
58142076   0          0          0          0       
Server nfs v2:
null       getattr    setattr    root       lookup     readlink   
1      100% 0       0% 0       0% 0       0% 0       0% 0       0% 
read       wrcache    write      create     remove     rename     
0       0% 0       0% 0       0% 0       0% 0       0% 0       0% 
link       symlink    mkdir      rmdir      readdir    fsstat     
0       0% 0       0% 0       0% 0       0% 0       0% 0       0% 

Server nfs v3:
null       getattr    setattr    lookup     access     readlink   
1       0% 15158205 26% 53353   0% 996812  1% 42526   0% 1067    0% 
read       write      create     mkdir      symlink    mknod      
7941851 13% 33614209 57% 139897  0% 5118    0% 865     0% 0       0% 
remove     rmdir      rename     link       readdir    readdirplus
92778   0% 651     0% 1080    0% 394     0% 15436   0% 0       0% 
fsstat     fsinfo     pathconf   commit     
1106    0% 1106    0% 0       0% 75620   0% 

>IP fragmentation is normal for any UDP-based protocol,
>and your stats don't show any reassembly failures or
>timeouts.  btw you can get this information in slightly
>friendlier form with "netstat -s".

I got the following:

[didier@xnfs1 ~]$ netstat -s | more
Ip:
    79283261 total packets received
    0 forwarded
    19816 incoming packets discarded
    58326116 incoming packets delivered
    87711576 requests sent out
    148509 outgoing packets dropped
    30853764 reassemblies required
    9927976 packets reassembled ok
    37294547 fragments created

[......]

Udp:
    58212451 packets received
    190 packets to unknown port received.
    19816 packet receive errors
    57985833 packets sent

[didier@xnfs1 ~]$ netstat -in
Kernel Interface table
Iface       MTU Met    RX-OK RX-ERR RX-DRP RX-OVR    TX-OK TX-ERR TX-DRP
TX-OVR Flg
eth0       1500   0   109165      0      0      0   144631      0      0
0 BMRU
eth1       1500   0 79305078      0      0      0 87676856      0      0
0 BMRU
lo        16436   0      299      0      0      0      299      0      0
0 LRU




-------------------------------------------------------
This SF.Net email is sponsored by: IBM Linux Tutorials
Free Linux tutorial presented by Daniel Robbins, President and CEO of
GenToo technologies. Learn everything from fundamentals to system
administration.http://ads.osdn.com/?ad_id=1470&alloc_id=3638&op=click
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
