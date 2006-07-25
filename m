From: Steven Shiau <steven@nchc.org.tw>
Subject: root over nfs4 ?
Date: Tue, 25 Jul 2006 09:54:32 +0800
Message-ID: <44C579D8.6030908@nchc.org.tw>
Reply-To: steven@nchc.org.tw
Mime-Version: 1.0
Content-Type: multipart/mixed; boundary="===============0883357944=="
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.91]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1G5C8a-0004a4-3y
	for nfs@lists.sourceforge.net; Mon, 24 Jul 2006 18:55:08 -0700
Received: from smtp.nchc.org.tw ([140.110.16.10])
	by mail.sourceforge.net with esmtp (Exim 4.44) id 1G5C8Y-0003sS-9V
	for nfs@lists.sourceforge.net; Mon, 24 Jul 2006 18:55:08 -0700
Received: from [140.110.59.180] (palm180.nchc.org.tw [140.110.59.180])
	(using TLSv1 with cipher DHE-RSA-AES256-SHA (256/256 bits))
	(No client certificate requested)
	by smtp.nchc.org.tw (Postfix) with ESMTP id 48854E6043
	for <nfs@lists.sourceforge.net>; Tue, 25 Jul 2006 09:54:56 +0800 (CST)
To: nfs@lists.sourceforge.net
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

--===============0883357944==
Content-Type: text/plain; charset=Big5
Content-Transfer-Encoding: 7bit

Hi,
Does anybody has any experience about root over nfs4 ?
We found that more programs are necessary in root over nfs4 than root
over nfs3.
For NFS3, the initrd in the diskless environment, only program "mount"
from busybox is necessary to mount the directory from nfs3 server.
However, for NFS4, program "mount" from busybox (1.2.0) does not support
nfs4, so the one from util-linux in necessary. Moreover, portmap and
rpc.idmapd are necessary. Hence the idmapd.conf is necessary, too.
Is that possible we can use some options to make it easier, such as in
nfs3, option "nolock" is used to mount the read-only root.

Any comment is welcome.
Thanks in advance.

-- 
Steven Shiau <steven _at_ nchc org tw> <steven _at_ stevenshiau org>
National Center for High-performance Computing, Taiwan.
http://www.nchc.org.tw
Public Key Server PGP Key ID: 9762755A


--===============0883357944==
Content-Type: text/plain; charset="us-ascii"
MIME-Version: 1.0
Content-Transfer-Encoding: 7bit
Content-Disposition: inline

-------------------------------------------------------------------------
Take Surveys. Earn Cash. Influence the Future of IT
Join SourceForge.net's Techsay panel and you'll get the chance to share your
opinions on IT & business topics through brief surveys -- and earn cash
http://www.techsay.com/default.php?page=join.php&p=sourceforge&CID=DEVDEV
--===============0883357944==
Content-Type: text/plain; charset="us-ascii"
MIME-Version: 1.0
Content-Transfer-Encoding: 7bit
Content-Disposition: inline

_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs

--===============0883357944==--
