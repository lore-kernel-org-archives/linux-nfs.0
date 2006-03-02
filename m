From: Gopal Santhanam <gopal@nerur.com>
Subject: NFSv3 + ACL + XFS?
Date: Thu, 2 Mar 2006 07:56:44 -0800
Message-ID: <200603020756.44610.gopal@nerur.com>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="iso-8859-1"
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.92] helo=mail.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1FEqAf-0005gX-Pi
	for nfs@lists.sourceforge.net; Thu, 02 Mar 2006 07:56:53 -0800
Received: from smtp2.stanford.edu ([171.67.16.125])
	by mail.sourceforge.net with esmtp (Exim 4.44)
	id 1FEqAd-0001wt-QV
	for nfs@lists.sourceforge.net; Thu, 02 Mar 2006 07:56:54 -0800
Received: from shruthi.stanford.edu (shruthi.Stanford.EDU [128.12.190.74])
	by smtp2.Stanford.EDU (8.12.11/8.12.11) with ESMTP id k22FunNE006495
	for <nfs@lists.sourceforge.net>; Thu, 2 Mar 2006 07:56:49 -0800
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

Hi all,

I am successful in exporting an EXT3 partition with ACLs through
NFSv3.

However, I cannot do the same for an XFS partition with ACLs. =A0I
did a quick search on the web and did not easily find any
information on this. =A0What's the status on this? =A0Is there a way
I can get this to work through proper configuration?

Thanks!
Gopal


-------------------------------------------------------
This SF.Net email is sponsored by xPML, a groundbreaking scripting language
that extends applications into web and mobile media. Attend the live webcast
and join the prime developer group breaking into this new coding territory!
http://sel.as-us.falkag.net/sel?cmd=lnk&kid=110944&bid=241720&dat=121642
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
