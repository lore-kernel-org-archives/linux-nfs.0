From: Martin Spott <Martin.Spott@mgras.net>
Subject: Accelerating 'mountd'
Date: Wed, 19 Oct 2005 16:09:21 +0000 (UTC)
Message-ID: <dj5r3h$rqm$1@osprey.mgras.de>
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.91] helo=mail.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1ESGVk-0004by-Mt
	for nfs@lists.sourceforge.net; Wed, 19 Oct 2005 09:09:52 -0700
Received: from quickstep.mgras.net ([213.146.115.59] helo=foehn.mgras.de)
	by mail.sourceforge.net with esmtp (Exim 4.44)
	id 1ESGVe-0005P9-9C
	for nfs@lists.sourceforge.net; Wed, 19 Oct 2005 09:09:52 -0700
Received: from osprey.mgras.de (osprey.mgras.de [192.168.48.3])
	by foehn.mgras.de (8.13.0/8.13.0) with ESMTP id j9JG9M7c005944
	for <nfs@lists.sourceforge.net>; Wed, 19 Oct 2005 18:09:23 +0200 (CEST)
Received: (from news@localhost) by osprey.mgras.de (AIX5.1/8.11.6p2/8.11.0) id j9JG9M431636 for nfs@lists.sourceforge.net; Wed, 19 Oct 2005 18:09:22 +0200
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
I'm having a setup with NFSv3 service over UDP from a 2.4.31 kernel.
Multiple diskless clients mount all their filesystems during boot and
the the crazy guy who contructed this diskless boot mimic lets each
client mount _ten_ NFS shares from the server (for some complicated
automatic configuration purposes).

In principle this is a stable setup but it comes to a bottleneck, when
twenty diskless client intend to mount their shares almost at the same
time. Therefore the server is supposed to handle about 200 mount
requests within ten seconds ....  but when I look at my server I
realize that at best only two requests are being handled per second.

In this context I'm seeking for answers to the following questions:
1.) Should a 'mountd' from mostly current nfs-utils be able to handle
    such a load on performant hardware with a sane setup ?
2.) Are there typical environments that degrade the performance of the
    'mountd' where I should have a closer look at ?
3.) Do I probably focus on the wrong culprit ....  ?

This sort of difficulties is a bit new to me and I know that such a
setup sounds a bit crazy, but I simply have to face the situation  :-)

I'd appreciate if you'd share some of your experience on this topic.

Thanks,
	Martin.
-- 
 Unix _IS_ user friendly - it's just selective about who its friends are !
--------------------------------------------------------------------------


-------------------------------------------------------
This SF.Net email is sponsored by:
Power Architecture Resource Center: Free content, downloads, discussions,
and more. http://solutions.newsforge.com/ibmarch.tmpl
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
