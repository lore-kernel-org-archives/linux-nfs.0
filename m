From: "jehan.procaccia" <jehan.procaccia@int-evry.fr>
Subject: rpc.mountd: getfh failed: Operation not permitted
Date: Wed, 02 Feb 2005 00:03:08 +0100
Message-ID: <42000AAC.5000301@int-evry.fr>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.12] helo=sc8-sf-mx2.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1Cw73K-0007QT-BW
	for nfs@lists.sourceforge.net; Tue, 01 Feb 2005 15:03:22 -0800
Received: from smtp2.int-evry.fr ([157.159.10.45])
	by sc8-sf-mx2.sourceforge.net with esmtp (Exim 4.41)
	id 1Cw73J-0005dX-Jd
	for nfs@lists.sourceforge.net; Tue, 01 Feb 2005 15:03:22 -0800
Received: from smyrne.int-evry.fr (smtp-ext.int-evry.fr [157.159.11.17])
	by smtp2.int-evry.fr (Postfix) with ESMTP id BF4892FD91
	for <nfs@lists.sourceforge.net>; Wed,  2 Feb 2005 00:03:11 +0100 (CET)
Received: from [157.159.10.93] (unknown [157.159.10.93])
	(using TLSv1 with cipher DHE-RSA-AES256-SHA (256/256 bits))
	(No client certificate requested)
	by smyrne.int-evry.fr (Postfix) with ESMTP id 45BA8C7381
	for <nfs@lists.sourceforge.net>; Tue,  1 Feb 2005 23:58:28 +0100 (CET)
To: nfs@lists.sourceforge.net
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

Hello,

Can someone give me a clue about this "getfh" error ?

Feb  1 10:15:06 cobra3 rpc.mountd: getfh failed: Operation not permitted
Feb  1 10:15:06 cobra3 rpc.mountd: authenticated mount request from 
b04-02.int-evry.fr:763 for /p1v3f1/ei0306/test (/p1v3f1)

cobra3 NFS V3 server is running RedHat ES 3 , kernel 2.4.21-27.ELsmp, 
clients are Fedora Core 2 with kernel  2.6.9-1.3_FC2 .
reading this mailing archive I suppect things like:
1) clients are dual boot using dynamic dhcp/dns, so forward ip @ changes 
at every reboots, could this be a ip addressing pb   ?
2) I use automount, I heard about mount points not beeing unmount  as 
they are  ask for a new mount ?
3) getfh is for get file Handle no ?  a lack of file descriptor on the 
NFS server (ulimit)  could be  an issue ?
4) other things ....
Today my only solution is to restart NFS services on the server, until 
getfh problem rises again :-(

Thanks for any advices .


-------------------------------------------------------
This SF.Net email is sponsored by: IntelliVIEW -- Interactive Reporting
Tool for open source databases. Create drag-&-drop reports. Save time
by over 75%! Publish reports on the web. Export to DOC, XLS, RTF, etc.
Download a FREE copy at http://www.intelliview.com/go/osdn_nl
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
