From: Peter Astrand <peter@cendio.se>
Subject: NFS Howto: SSH tunnels
Date: Tue, 16 Mar 2004 15:12:05 +0100 (CET)
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <Pine.LNX.4.44.0403161450510.14479-100000@maggie.lkpg.cendio.se>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=iso-8859-1
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.12] helo=sc8-sf-mx2.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1B3FKN-0007Pq-Pe
	for nfs@lists.sourceforge.net; Tue, 16 Mar 2004 06:13:55 -0800
Received: from mail.cendio.se ([193.12.253.66])
	by sc8-sf-mx2.sourceforge.net with esmtp (Exim 4.30)
	id 1B3FKF-0007ve-92
	for nfs@lists.sourceforge.net; Tue, 16 Mar 2004 06:13:47 -0800
Received: from maggie.lkpg.cendio.se (maggie.lkpg.cendio.se [10.47.1.208])
	by mail.cendio.se (Postfix) with ESMTP id DAA9525DB28
	for <nfs@lists.sourceforge.net>; Tue, 16 Mar 2004 15:12:05 +0100 (CET)
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


It looks like http://nfs.sourceforge.net/nfs-howto/security.html#NFS-SSH 
is incorrect wrt privileged ports:

The HOWTO seems to assume that if you do "ssh root@192.168.0.42 -L
250:localhost:2049", then sshd will use a low port when connecting to
nfsd. This is not true, at least not on common distributions like SuSE 9.  
As far as I know, it's not possible to make the sshd use low ports when
connecting through tunnels.

*If* sshd would use a low, port, then the statements about that *any* user 
could mount the server is wrong. 


As I understand it, tunneling NFS through SSH would be done more like:

1) Add to /etc/exports:

/home   127.0.0.1(rw,insecure)


2) Start tunnels (no need to be root, one tunnel sufficient):

ssh user@192.168.0.42 -L 12049:localhost:2049 -L 32767:localhost:32767 -f sleep 60m


3) Mount, as root:

mount -o nolock,tcp,port=12049,mountport=32767 localhost:/home /mnt

Now, when using the "insecure" option and an export to 127.0.0.1, the
statement about "any users can do everything" is correct.


Btw, I think a userspace server like "unfs3", running as an ordinary user,
is more suitable for SSH tunnels.


-- 
Peter Åstrand		www.thinlinc.com
Cendio			www.cendio.se
Teknikringen 3		Phone: +46-13-21 46 00
583 30 Linköping




-------------------------------------------------------
This SF.Net email is sponsored by: IBM Linux Tutorials
Free Linux tutorial presented by Daniel Robbins, President and CEO of
GenToo technologies. Learn everything from fundamentals to system
administration.http://ads.osdn.com/?ad_id=1470&alloc_id=3638&op=click
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
