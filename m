From: Rene Salmon <rsalmon@tulane.edu>
Subject: cp: getting attribute `system.nfs4_acl' Operation not
	supported
Date: Thu, 04 Jan 2007 15:55:22 -0600
Message-ID: <C1C2D3EA.28C7%rsalmon@tulane.edu>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.92]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1H2aYb-0001Jq-Ri
	for nfs@lists.sourceforge.net; Thu, 04 Jan 2007 13:55:30 -0800
Received: from ex01.ad.tulane.edu ([129.81.114.31])
	by mail.sourceforge.net with esmtp (Exim 4.44) id 1H2aYa-0004e5-1F
	for nfs@lists.sourceforge.net; Thu, 04 Jan 2007 13:55:31 -0800
To: <nfs@lists.sourceforge.net>, Rene Salmon <rsalmon@tulane.edu>
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

Hi list,

I am getting this message when I try to do a cp on an nfsv4 mounted file
system:

cp: getting attribute `system.nfs4_acl' of
`rsalmon/test-q/single-cpu/ForRene.f': Operation not supported

I found one thread in the list archives about this:
http://linux-nfs.org/pipermail/nfsv4/2006-February/003518.html

>From the thread it looks like this was already fixed.  I am running kernel
2.9.16.29.  Any ideas as to if this kernel contains this fix?

Thank you in advanced for any help on this.

Rene



-- 
        Rene Salmon
        Tulane University
        Center for Computational Science
        http://www.ccs.tulane.edu
        rsalmon@tulane.edu
        Tel 504-862-8393
        Fax 504-862-8392



-------------------------------------------------------------------------
Take Surveys. Earn Cash. Influence the Future of IT
Join SourceForge.net's Techsay panel and you'll get the chance to share your
opinions on IT & business topics through brief surveys - and earn cash
http://www.techsay.com/default.php?page=join.php&p=sourceforge&CID=DEVDEV
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
