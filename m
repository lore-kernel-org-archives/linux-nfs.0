From: ashutosh.varshney@st.com
Subject: isolation of NFS threads  ?
Date: Tue, 17 Sep 2002 13:08:01 +0530
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <H00004750469f746.1032247966.dlx99.dlh.st.com@MHS>
References: <000f01c25e1b$961ac560$4f0010ac@Ashwamedha>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from beta.dmz-eu.st.com ([164.129.1.35])
	by usw-sf-list1.sourceforge.net with esmtp (Exim 3.31-VA-mm2 #1 (Debian))
	id 17rCwU-000109-00
	for <nfs@lists.sourceforge.net>; Tue, 17 Sep 2002 00:38:43 -0700
Received: from zeta.dmz-eu.st.com (ns2.st.com [164.129.230.9])
	by beta.dmz-eu.st.com (STMicroelectronics) with SMTP id 4E708498C
	for <nfs@lists.sourceforge.net>; Tue, 17 Sep 2002 07:38:08 +0000 (GMT)
Received: from dlx99.dlh.st.com (localhost [127.0.0.1])
	by zeta.dmz-eu.st.com (STMicroelectronics) with ESMTP id 1BDDC1848
	for <nfs@lists.sourceforge.net>; Tue, 17 Sep 2002 07:38:07 +0000 (GMT)
Received: from localhost (root@localhost)
	by dlx99.dlh.st.com (8.9.3 (PHNE_22672)/8.9.3) with ESMTP id NAA05279
	for <nfs@lists.sourceforge.net>; Tue, 17 Sep 2002 13:08:04 +0530 (IST)
In-Reply-To: <000f01c25e1b$961ac560$4f0010ac@Ashwamedha>
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
List-Archive: <http://sourceforge.net/mailarchives/forum.php?forum=nfs>

Hi

We had a lot of SUN machines and just installed few linux machines.We
have all our licenses/Softwares of Solaris m/cs( NIS also on Solaris).But
when we access the things from linux client..network chokes..all things
hang..then we reboot the linux ..and set the rsize & wsize to 8K and now
things work fine..
Can any one puts lights why this all happen ..where is the problem.. in
linux or solairs.
Any site referneces for this customization..

thanks in advance

Ashutosh



-------------------------------------------------------
Sponsored by: AMD - Your access to the experts on Hammer Technology! 
Open Source & Linux Developers, register now for the AMD Developer 
Symposium. Code: EX8664 http://www.developwithamd.com/developerlab
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
