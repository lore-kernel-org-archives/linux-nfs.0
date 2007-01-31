From: "Trinabh Shukla" <trinabh@gmail.com>
Subject: Move .nfsXXXX files
Date: Wed, 31 Jan 2007 19:03:15 +0530
Message-ID: <6ffeae550701310533p3bc731b3of53e4da4dd05d98d@mail.gmail.com>
Mime-Version: 1.0
Content-Type: multipart/mixed; boundary="===============0627103216=="
To: nfs@lists.sourceforge.net
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.92]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1HCFaP-0002zM-6h
	for nfs@lists.sourceforge.net; Wed, 31 Jan 2007 05:33:17 -0800
Received: from ug-out-1314.google.com ([66.249.92.171])
	by mail.sourceforge.net with esmtp (Exim 4.44) id 1HCFaQ-0008J8-Qh
	for nfs@lists.sourceforge.net; Wed, 31 Jan 2007 05:33:19 -0800
Received: by ug-out-1314.google.com with SMTP id z38so165837ugc
	for <nfs@lists.sourceforge.net>; Wed, 31 Jan 2007 05:33:16 -0800 (PST)
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

--===============0627103216==
Content-Type: multipart/alternative;
	boundary="----=_Part_3173_307377.1170250395686"

------=_Part_3173_307377.1170250395686
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Content-Disposition: inline

The .nfsXXXX file get created when I remove a file while it's being kept
open by one of the process. Due to this I can't remove directory which hold
this file. So I want to move this .nfsXXXX file on different temp directory
on the same nfs file system and delete that directory. Here it's working
properly.

But let me know that is it a correct solution? And removal of .nfs files
does not cause the server serious integrity.

Also it will be good, if you lead some pointers about how this .nfsXXXX
files handle by the NFS server.

Thanks,
-Trinabh

------=_Part_3173_307377.1170250395686
Content-Type: text/html; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Content-Disposition: inline

The .nfsXXXX file get created when I remove a file while it&#39;s being kept open by one of the process. Due to this I can&#39;t remove directory which hold this file. So I want to move this .nfsXXXX file on different temp directory on the same nfs file system and delete that directory. Here it&#39;s working properly. 
<br><br>But let me know that is it a correct solution? And removal of .nfs files does not cause the server serious integrity. <br><br>Also it will be good, if you lead some pointers about how this .nfsXXXX files handle by the NFS server. 
<br><br>Thanks,<br>-Trinabh <br> 

------=_Part_3173_307377.1170250395686--


--===============0627103216==
Content-Type: text/plain; charset="us-ascii"
MIME-Version: 1.0
Content-Transfer-Encoding: 7bit
Content-Disposition: inline

-------------------------------------------------------------------------
Take Surveys. Earn Cash. Influence the Future of IT
Join SourceForge.net's Techsay panel and you'll get the chance to share your
opinions on IT & business topics through brief surveys - and earn cash
http://www.techsay.com/default.php?page=join.php&p=sourceforge&CID=DEVDEV
--===============0627103216==
Content-Type: text/plain; charset="us-ascii"
MIME-Version: 1.0
Content-Transfer-Encoding: 7bit
Content-Disposition: inline

_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs

--===============0627103216==--
