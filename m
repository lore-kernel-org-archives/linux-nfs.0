From: Martin Spott <Martin.Spott@mgras.net>
Subject: Re: Accelerating 'mountd'
Date: Wed, 26 Oct 2005 10:46:22 +0000 (UTC)
Message-ID: <djnmpt$138e$1@osprey.mgras.de>
References: <dj5r3h$rqm$1@osprey.mgras.de>
Reply-To: Martin.Spott@mgras.net
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.91] helo=mail.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1EUinq-0005u8-V1
	for nfs@lists.sourceforge.net; Wed, 26 Oct 2005 03:46:42 -0700
Received: from quickstep.mgras.net ([213.146.115.59] helo=foehn.mgras.de)
	by mail.sourceforge.net with esmtp (Exim 4.44)
	id 1EUinq-0000Xz-EN
	for nfs@lists.sourceforge.net; Wed, 26 Oct 2005 03:46:43 -0700
Received: from osprey.mgras.de (osprey.mgras.de [192.168.48.3])
	by foehn.mgras.de (8.13.0/8.13.0) with ESMTP id j9QAkMhV001526
	for <nfs@lists.sourceforge.net>; Wed, 26 Oct 2005 12:46:23 +0200 (CEST)
Received: (from news@localhost) by osprey.mgras.de (AIX5.1/8.11.6p2/8.11.0) id j9QAkMg28772 for nfs@lists.sourceforge.net; Wed, 26 Oct 2005 12:46:22 +0200
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

Martin Spott wrote:

> In principle this is a stable setup but it comes to a bottleneck, when
> twenty diskless client intend to mount their shares almost at the same
> time. Therefore the server is supposed to handle about 200 mount
> requests within ten seconds ....  but when I look at my server I
> realize that at best only two requests are being handled per second.

Actually I had to realize that I've been fooled. A co-worker, although
having all NFS clients entered in /etc/hosts was claiming to face the
same problem - but this actually was not the case.
Now after entering all clients in /etc/hosts my server happily serves
20 mount requests per second - or even more.

Sorry for the noise,
	Martin.
-- 
 Unix _IS_ user friendly - it's just selective about who its friends are !
--------------------------------------------------------------------------


-------------------------------------------------------
This SF.Net email is sponsored by the JBoss Inc.
Get Certified Today * Register for a JBoss Training Course
Free Certification Exam for All Training Attendees Through End of 2005
Visit http://www.jboss.com/services/certification for more information
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
