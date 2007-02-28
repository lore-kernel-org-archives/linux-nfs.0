From: wolfgang@noten5.maas-noten.de
Subject: access error - not owner
Date: 28 Feb 2007 08:42:42 -0000
Message-ID: <wolfgang-1070228094242.A011160@noten5.maas-noten.de>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
To: nfs@lists.sourceforge.net
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.92]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1HMKPN-000456-Bm
	for nfs@lists.sourceforge.net; Wed, 28 Feb 2007 00:43:33 -0800
Received: from maas-noten.de ([213.239.193.103])
	by mail.sourceforge.net with smtp (Exim 4.44) id 1HMKPN-00060M-Vz
	for nfs@lists.sourceforge.net; Wed, 28 Feb 2007 00:43:35 -0800
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

I occasionally get access failures on an nfs volume
The files are mode 666, owned by a user who has no account on the nfs machine.
The volume is exported rw, no_root_squash and mounted rw by clients

When the error occurs, the file has been truncated but cannot be written

Changing ownership of the file to someone else helps

The server is running kernel nfs on suse 10.1

lsmod
Module                  Size  Used by
nfsd                  267368  0 
exportfs               22272  1 nfsd
lockd                  87792  1 nfsd
nfs_acl                20352  1 nfsd
sunrpc                172616  3 nfsd,lockd,nfs_acl

rpcinfo -p localhost
   Program Vers Proto   Port
    100000    2   tcp    111  portmapper
    100000    2   udp    111  portmapper
    100005    1   udp    828  mountd
    100005    2   udp    828  mountd
    100005    1   tcp    829  mountd
    100005    2   tcp    829  mountd
    100003    2   udp   2049  nfs
    100003    2   tcp   2049  nfs


Wolfgang Hamann





-------------------------------------------------------------------------
Take Surveys. Earn Cash. Influence the Future of IT
Join SourceForge.net's Techsay panel and you'll get the chance to share your
opinions on IT & business topics through brief surveys-and earn cash
http://www.techsay.com/default.php?page=join.php&p=sourceforge&CID=DEVDEV
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
