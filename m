From: Gopal Santhanam <gopal@nerur.com>
Subject: NFSv3+ACL
Date: Wed, 1 Mar 2006 08:00:08 -0800
Message-ID: <200603010800.08604.gopal@nerur.com>
References: <200602241547.49425.gopal@nerur.com>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="iso-8859-1"
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.92] helo=mail.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1FETkL-0007dR-7L
	for nfs@lists.sourceforge.net; Wed, 01 Mar 2006 08:00:13 -0800
Received: from smtp1.stanford.edu ([171.67.16.123])
	by mail.sourceforge.net with esmtp (Exim 4.44)
	id 1FETkL-0003iw-5o
	for nfs@lists.sourceforge.net; Wed, 01 Mar 2006 08:00:13 -0800
Received: from shruthi.stanford.edu (shruthi.Stanford.EDU [128.12.190.74])
	by smtp1.Stanford.EDU (8.12.11/8.12.11) with ESMTP id k21G09GX027767
	for <nfs@lists.sourceforge.net>; Wed, 1 Mar 2006 08:00:10 -0800
To: nfs@lists.sourceforge.net
In-Reply-To: <200602241547.49425.gopal@nerur.com>
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

I have found out the following with some testing:

1) It appears that FC4 kernel 2.6.15-1.1831 does not seem to 
properly support ACL support in NFSD.  However, ACL support does 
seem to work as a client.

2) I tried running an older known-good version of a kernel 
(2.6.12-rc3 with appropriate CITI patches).  NFSv3+ACL on the 
server works great when running with the latest userland 
utilities in FC4.  I am able to export a directory with ACLs and 
mount it through the loopback interface and see the ACLs.

3) Clients running FC4 are able to connect to the server above 
without problems.  The ACLs show up nicely.

Is this a known issue?  What are the plans to get NFSD+ACL server 
into the mainstream kernel distributions?


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
