From: Olaf Kirch <okir@suse.de>
Subject: NFS direct IO needs page lock?
Date: Tue, 15 Feb 2005 21:36:54 +0100
Message-ID: <20050215203654.GA15634@suse.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.11] helo=sc8-sf-mx1.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1D19RT-0000T0-1E
	for nfs@lists.sourceforge.net; Tue, 15 Feb 2005 12:37:07 -0800
Received: from cantor.suse.de ([195.135.220.2])
	by sc8-sf-mx1.sourceforge.net with esmtp (TLSv1:DES-CBC3-SHA:168)
	(Exim 4.41)
	id 1D19RR-0007A5-GK
	for nfs@lists.sourceforge.net; Tue, 15 Feb 2005 12:37:06 -0800
Received: from hermes.suse.de (hermes-ext.suse.de [195.135.221.8])
	(using TLSv1 with cipher EDH-RSA-DES-CBC3-SHA (168/168 bits))
	(No client certificate requested)
	by Cantor.suse.de (Postfix) with ESMTP id 0DD1D147F72E
	for <nfs@lists.sourceforge.net>; Tue, 15 Feb 2005 21:36:55 +0100 (CET)
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

Hi,

I'm currently looking at a customer problem problem with weird VM oopses
that is somehow related to a large application doing heavy NFS direct
IO to/from a POSIX shmem area (hm, what application would *that* be :-).

I haven't had a bright idea so far, and I'm not even convinced this is
NFS related at all - but one thing that struck me as odd when meditated
over the code today was that the directio code doesn't lock the pages
in nfs_get_user_pages.  Is that an oversight, or does it do that
intentionally?

Olaf
-- 
Olaf Kirch   |  --- o --- Nous sommes du soleil we love when we play
okir@suse.de |    / | \   sol.dhoop.naytheet.ah kin.ir.samse.qurax


-------------------------------------------------------
SF email is sponsored by - The IT Product Guide
Read honest & candid reviews on hundreds of IT Products from real users.
Discover which products truly live up to the hype. Start reading now.
http://ads.osdn.com/?ad_id=6595&alloc_id=14396&op=click
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
