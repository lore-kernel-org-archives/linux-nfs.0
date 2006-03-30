From: Olaf Kirch <okir@suse.de>
Subject: NFS directio
Date: Thu, 30 Mar 2006 17:15:44 +0200
Message-ID: <20060330151544.GA11915@suse.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.92] helo=mail.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1FOytg-0005iP-Km
	for nfs@lists.sourceforge.net; Thu, 30 Mar 2006 07:17:16 -0800
Received: from mx2.suse.de ([195.135.220.15])
	by mail.sourceforge.net with esmtps (TLSv1:AES256-SHA:256)
	(Exim 4.44)
	id 1FOyte-0002fF-3w
	for nfs@lists.sourceforge.net; Thu, 30 Mar 2006 07:17:16 -0800
Received: from Relay2.suse.de (mail2.suse.de [195.135.221.8])
	(using TLSv1 with cipher DHE-RSA-AES256-SHA (256/256 bits))
	(No client certificate requested)
	by mx2.suse.de (Postfix) with ESMTP id 67B851D0F6
	for <nfs@lists.sourceforge.net>; Thu, 30 Mar 2006 17:17:10 +0200 (CEST)
Resent-Message-ID: <20060330151710.GB11915@suse.de>
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

In recent kernels, NFS direct IO limits the size of a request to
4096 pages, ie 16M on most platforms. This causes growisofs from the
dvd+rw-tools package (http://fy.chalmers.se/~appro/linux/DVD+RW/) to fail.
Its builtin "dd" style function uses 32M buffers by default.

It puzzled me a lot that it is returning -EFBIG, which means "file too
big". At least that should be EINVAL, I think. EFBIG should be reserved
for problems related to largefile support, IMO.

We can easily work around the problem by restricting the buffer size
growisofs uses on NFS, but that feels strange. I think the right way
would be to increase MAX_DIRECTIO_SIZE, and if someone submits a bigger
request, to loop and do that in MAX_DIRECTIO_SIZE chunks.

Comments?

Thanks,
Olaf
-- 
Olaf Kirch   |  --- o --- Nous sommes du soleil we love when we play
okir@suse.de |    / | \   sol.dhoop.naytheet.ah kin.ir.samse.qurax


-------------------------------------------------------
This SF.Net email is sponsored by xPML, a groundbreaking scripting language
that extends applications into web and mobile media. Attend the live webcast
and join the prime developer group breaking into this new coding territory!
http://sel.as-us.falkag.net/sel?cmd=lnk&kid=110944&bid=241720&dat=121642
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
