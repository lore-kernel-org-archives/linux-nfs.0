From: "sun lu" <lukesunlu@hotmail.com>
Subject: (no subject)
Date: Wed, 20 Jun 2007 17:00:06 +0800
Message-ID: <BAY115-F2711CDA7563D09F2CEA10DA9110@phx.gbl>
Mime-Version: 1.0
Content-Type: multipart/mixed; boundary="===============1509267953=="
To: nfs@lists.sourceforge.net
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.92]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1I0w2v-0003Ts-BK
	for nfs@lists.sourceforge.net; Wed, 20 Jun 2007 02:00:13 -0700
Received: from bay0-omc3-s38.bay0.hotmail.com ([65.54.246.238])
	by mail.sourceforge.net with esmtp (Exim 4.44) id 1I0w2x-0001ME-Hh
	for nfs@lists.sourceforge.net; Wed, 20 Jun 2007 02:00:16 -0700
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

--===============1509267953==
Content-Type: text/plain; charset=gb2312; format=flowed

I am a Chinese linux developer and now working on the ARM9 board EP9315 
development based on linux system. I have downloaded the 
nfs-utils-1.0.6-ptx4 package and attempted to build the nfs service module 
into the ARM linux system so that the ARM board can funtion as a nfs server 
which can be mounted by other boards.
However, some problems confused me :in the package, I have modified the 
file "configure.sh" aiming to let the package's compiling directory link to 
the cross-compiling enviroment 2.95.3( it exists in /usr/local/arm) ,but it 
doesn't work. The package cannot install the nfs modules which work in the 
ARM linux system.
So,I hope if you can give me some advices or offer me some help, I'll be 
appreciated for that very much!!

_________________________________________________________________
享用世界上最大的电子邮件系统— MSN Hotmail。  http://www.hotmail.com  



--===============1509267953==
Content-Type: text/plain; charset="us-ascii"
MIME-Version: 1.0
Content-Transfer-Encoding: 7bit
Content-Disposition: inline

-------------------------------------------------------------------------
This SF.net email is sponsored by DB2 Express
Download DB2 Express C - the FREE version of DB2 express and take
control of your XML. No limits. Just data. Click to get it now.
http://sourceforge.net/powerbar/db2/
--===============1509267953==
Content-Type: text/plain; charset="us-ascii"
MIME-Version: 1.0
Content-Transfer-Encoding: 7bit
Content-Disposition: inline

_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs

--===============1509267953==--
