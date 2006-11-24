From: linuxkernel@arcor.de
Subject: several oopses of nfsd in 2.6.16.29 where /proc/fs/nfsd
	mounted
Date: Fri, 24 Nov 2006 08:51:12 +0100 (CET)
Message-ID: <28552016.1164354672990.JavaMail.ngmail@webmail11>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.92]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1GnVqE-0007qi-JJ
	for nfs@lists.sourceforge.net; Thu, 23 Nov 2006 23:51:22 -0800
Received: from mail-in-02.arcor-online.net ([151.189.21.42])
	by mail.sourceforge.net with esmtps (TLSv1:AES256-SHA:256)
	(Exim 4.44) id 1GnVqD-0000yC-Jd
	for nfs@lists.sourceforge.net; Thu, 23 Nov 2006 23:51:24 -0800
Received: from mail-in-08-z2.arcor-online.net (mail-in-08-z2.arcor-online.net
	[151.189.8.20])
	by mail-in-02.arcor-online.net (Postfix) with ESMTP id 75A542D74B7
	for <nfs@lists.sourceforge.net>; Fri, 24 Nov 2006 08:51:13 +0100 (CET)
Received: from mail-in-09.arcor-online.net (mail-in-09.arcor-online.net
	[151.189.21.49])
	by mail-in-08-z2.arcor-online.net (Postfix) with ESMTP id 69C89212F9E
	for <nfs@lists.sourceforge.net>; Fri, 24 Nov 2006 08:51:13 +0100 (CET)
Received: from webmail11 (webmail11.arcor-online.net [151.189.8.83])
	by mail-in-09.arcor-online.net (Postfix) with ESMTP id F366C13F62
	for <nfs@lists.sourceforge.net>; Fri, 24 Nov 2006 08:51:12 +0100 (CET)
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

Hello list!

I just reported bug #7572 just before i read in bug #6172 that "The NFS server
maintainer doesn't use bugzilla."  which is very clever, very clever...
Anyways we use kernel 2.6.16.x series because it was promised that this would
be a "long -living kernel series".  So I hope that whatever will be the fix for these oopses
it will make it to the 2.6.16.x kernel.  Please have a look at the report:

http://bugzilla.kernel.org/show_bug.cgi?id=7572

Best thanks,

      Peter

-------------------------------------------------------------------------
Take Surveys. Earn Cash. Influence the Future of IT
Join SourceForge.net's Techsay panel and you'll get the chance to share your
opinions on IT & business topics through brief surveys - and earn cash
http://www.techsay.com/default.php?page=join.php&p=sourceforge&CID=DEVDEV
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
