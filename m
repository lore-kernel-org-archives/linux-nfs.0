From: niu <niu@clusterfs.com>
Subject: Can't get port of RPC while boot linux(root NFS)
Date: Tue, 09 Sep 2003 18:00:25 -0400
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <3F5E4D79.8020705@clusterfs.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii; format=flowed
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.11] helo=sc8-sf-mx1.sourceforge.net)
	by sc8-sf-list1.sourceforge.net with esmtp
	(Cipher TLSv1:DES-CBC3-SHA:168) (Exim 3.31-VA-mm2 #1 (Debian))
	id 19wfRb-0006DF-00
	for <nfs@lists.sourceforge.net>; Tue, 09 Sep 2003 03:09:55 -0700
Received: from moraine.clusterfs.com ([216.138.243.178])
	by sc8-sf-mx1.sourceforge.net with esmtp (Exim 4.22)
	id 19wfRa-0006OL-Pu
	for nfs@lists.sourceforge.net; Tue, 09 Sep 2003 03:09:54 -0700
Received: from clusterfs.com (unknown [202.108.67.67])
	by moraine.clusterfs.com (Postfix) with ESMTP id A97793100B2
	for <nfs@lists.sourceforge.net>; Tue,  9 Sep 2003 06:09:41 -0400 (EDT)
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
List-Archive: <http://sourceforge.net/mailarchive/forum.php?forum=nfs>

Hi, All

I've compliled a linux kernel with cfg_root_nfs, cfg_ip_dhcp, 
cfg_ip_rarp, cfg_ip_bootp.
and set up tftp server and nfs server properly. the /home/client on 
server be exported as
nfs root. some necessary files have been copied to there.

well, I boot the client machine by grub. the confgiure looks like:

ifconfig --address=xxx.xxx.xxx.xxx --server=yyy.yyy.yyy.yyy
root (nd)
kernel /tftp-bootimg root=/dev/nfs nfsroot=yyy.yyy.yyy.yyy:/home/client

But it report error message said that can't get RPC port from protmap while
mounting /home/client. Did I make something wrong?

BTW: the /home/client can be mount from client machine as non-root 
filesystem.

Niu



-------------------------------------------------------
This sf.net email is sponsored by:ThinkGeek
Welcome to geek heaven.
http://thinkgeek.com/sf
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
