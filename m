From: "Lever, Charles" <Charles.Lever@netapp.com>
Subject: [PATCH 0/3]: NFS: nfs_inode->flags is not SMP safe
Date: Sat, 9 Jul 2005 08:31:41 -0700
Message-ID: <482A3FA0050D21419C269D13989C611308539D84@lavender-fe.eng.netapp.com>
Mime-Version: 1.0
Content-Type: text/plain;
	charset="us-ascii"
Cc: <nfs@lists.sourceforge.net>
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.92] helo=sc8-sf-mx2.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1DrHJL-0001OH-3u
	for nfs@lists.sourceforge.net; Sat, 09 Jul 2005 08:32:11 -0700
Received: from mx2.netapp.com ([216.240.18.37])
	by sc8-sf-mx2.sourceforge.net with esmtp (Exim 4.44)
	id 1DrHJJ-00062Y-He
	for nfs@lists.sourceforge.net; Sat, 09 Jul 2005 08:32:11 -0700
To: "Nick Wilson" <njw@osdl.org>,
	"Bill Rugolsky Jr." <brugolsky@telemetry-investments.com>
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

 The following three patches make updating the contents of the nfs_inode
 structures "flags" field SMP safe without using the global kernel lock.


-------------------------------------------------------
This SF.Net email is sponsored by the 'Do More With Dual!' webinar happening
July 14 at 8am PDT/11am EDT. We invite you to explore the latest in dual
core and dual graphics technology at this free one hour event hosted by HP, 
AMD, and NVIDIA.  To register visit http://www.hp.com/go/dualwebinar
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
