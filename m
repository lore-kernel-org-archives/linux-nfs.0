From: Vincent ROQUETA <vincent.roqueta@ext.bull.net>
Subject: CITI page up to date?
Date: Tue, 13 Apr 2004 13:19:19 +0200
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <200404131319.19518.vincent.roqueta@ext.bull.net>
Reply-To: vincent.roqueta@ext.bull.net
Mime-Version: 1.0
Content-Type: text/plain;
  charset="us-ascii"
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.12] helo=sc8-sf-mx2.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1BDMtm-00015Y-Vf
	for nfs@lists.sourceforge.net; Tue, 13 Apr 2004 05:20:18 -0700
Received: from ecbull20.frec.bull.fr ([129.183.4.3])
	by sc8-sf-mx2.sourceforge.net with esmtp (Exim 4.30)
	id 1BDMtk-0008DE-GH
	for nfs@lists.sourceforge.net; Tue, 13 Apr 2004 05:20:18 -0700
Received: from roquetav (roquetav.frec.bull.fr [129.183.101.52])
	by ecbull20.frec.bull.fr (8.9.2/8.9.1) with ESMTP id NAA17862
	for <nfs@lists.sourceforge.net>; Tue, 13 Apr 2004 13:19:48 +0200
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

Hello,

        I experiment some problem with mount using the NFSv4 CITI proposed 
configuration:
linux 2.6.5-rc2 + linux-2.6.5-rc2-CITI_NFS4_ALL.dif
nfs-utils-1.0.6.tar.gz + nfs-utils-CITI_NFS4_ALL.dif
util-linux-2.11z.tar.bz2 + util-linux-2.11z-CITI_NFS4_ALL.patch

Here is the problem :

Client :
mount: bad system type, bad option, bad super bloc on 172.16.109.40:/,
      or too many filesystems mounted

logs (without idmapd):
Apr 13 09:11:53 nfs2 kernel: decode_getfattr: xdr error 5!
Apr 13 09:11:53 nfs2 kernel: nfs_get_root: getattr error = 5
Apr 13 09:11:53 nfs2 kernel: nfs_read_super: get root inode failed

logs (with idmapd)
Apr 13 10:31:01 nfs2 kernel: decode_getfattr: xdr error 10008!
Apr 13 10:31:01 nfs2 kernel: nfs4_map_errors could not handle NFSv4 error 
10008
Apr 13 10:31:01 nfs2 kernel: nfs_get_root: getattr error = 5
Apr 13 10:31:01 nfs2 kernel: nfs_read_super: get root inode failed

Maybe the CITI page (http://www.citi.umich.edu/projects/nfsv4/linux/) is not 
updated?



-------------------------------------------------------
This SF.Net email is sponsored by: IBM Linux Tutorials
Free Linux tutorial presented by Daniel Robbins, President and CEO of
GenToo technologies. Learn everything from fundamentals to system
administration.http://ads.osdn.com/?ad_id=1470&alloc_id=3638&op=click
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
