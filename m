From: "Suraj Jacob" <suraj.email@gmail.com>
Subject: Implementing nfs in vfs
Date: Thu, 24 May 2007 16:34:08 +0530
Message-ID: <359369180705240404s2887d881uf591119b6397683d@mail.gmail.com>
Mime-Version: 1.0
Content-Type: multipart/mixed; boundary="===============0738813513=="
To: nfs@lists.sourceforge.net
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.92]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1HrB75-0008BV-RA
	for nfs@lists.sourceforge.net; Thu, 24 May 2007 04:04:11 -0700
Received: from nz-out-0506.google.com ([64.233.162.236])
	by mail.sourceforge.net with esmtp (Exim 4.44) id 1HrB77-0006nm-JB
	for nfs@lists.sourceforge.net; Thu, 24 May 2007 04:04:14 -0700
Received: by nz-out-0506.google.com with SMTP id 18so162490nzp
	for <nfs@lists.sourceforge.net>; Thu, 24 May 2007 04:04:09 -0700 (PDT)
List-Id: "Discussion of NFS under Linux development, interoperability,
	and testing." <nfs.lists.sourceforge.net>
List-Unsubscribe: <https://lists.sourceforge.net/lists/listinfo/nfs>,
	<mailto:nfs-request@lists.sourceforge.net?subject=unsubscribe>
List-Archive: <http://sourceforge.net/mailarchive/forum.php?forum_name=nfs>
List-Post: <mailto:nfs@lists.sourceforge.net>
List-Help: <mailto:nfs-request@lists.sourceforge.net?subject=help>
List-Subscribe: <https://lists.sourceforge.net/lists/listinfo/nfs>,
	<mailto:nfs-request@lists.sourceforge.net?subject=subscribe>
Sender: nfs-bounces@lists.sourceforge.net
Errors-To: nfs-bounces@lists.sourceforge.net

--===============0738813513==
Content-Type: multipart/alternative;
	boundary="----=_Part_134452_11990710.1180004648144"

------=_Part_134452_11990710.1180004648144
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Content-Disposition: inline

Hi,
Please forgive me if this is a naive question or if it does not belong to
this list.

All the nfs implementations that Ive seen are always on top of local
filesystems. Why is it that there is no implementation that could bypass the
local fs like ext2 and implement a vfs layer for nfs? or eliminate vfs too
and write a server operating on raw disks(like some databases do for
performance)?


Thanks in advance

------=_Part_134452_11990710.1180004648144
Content-Type: text/html; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Content-Disposition: inline

Hi,<br>Please forgive me if this is a naive question or if it does not belong to this list.<br><br>All the nfs implementations that Ive seen are always on top of local filesystems. Why is it that there is no implementation that could bypass the local fs like ext2 and implement a vfs layer for nfs? or eliminate vfs too and write a server operating on raw disks(like some databases do for performance)? 
<br><br><br>Thanks in advance<br>

------=_Part_134452_11990710.1180004648144--


--===============0738813513==
Content-Type: text/plain; charset="us-ascii"
MIME-Version: 1.0
Content-Transfer-Encoding: 7bit
Content-Disposition: inline

-------------------------------------------------------------------------
This SF.net email is sponsored by DB2 Express
Download DB2 Express C - the FREE version of DB2 express and take
control of your XML. No limits. Just data. Click to get it now.
http://sourceforge.net/powerbar/db2/
--===============0738813513==
Content-Type: text/plain; charset="us-ascii"
MIME-Version: 1.0
Content-Transfer-Encoding: 7bit
Content-Disposition: inline

_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs

--===============0738813513==--
