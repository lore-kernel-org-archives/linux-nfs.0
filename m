From: Chip Salzenberg <chip@pobox.com>
Subject: Debian, SIGPIPE, "libnfsidmap", and init.d vs. umount
Date: Sat, 4 Dec 2004 17:15:04 -0500
Message-ID: <20041204221504.GD6146@perlsupport.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.12] helo=sc8-sf-mx2.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1CaiBD-0002we-EI
	for nfs@lists.sourceforge.net; Sat, 04 Dec 2004 14:15:03 -0800
Received: from perlsupport.com
	([66.220.6.226] helo=mail.perlsupport.com ident=Debian-exim)
	by sc8-sf-mx2.sourceforge.net with esmtp (TLSv1:RC4-SHA:128)
	(Exim 4.41)
	id 1CaiBB-0000iF-M8
	for nfs@lists.sourceforge.net; Sat, 04 Dec 2004 14:15:02 -0800
Received: from pcp03344017pcs.malvrn01.pa.comcast.net ([68.54.140.48] helo=tytlal)
	by mail.perlsupport.com (Exim 4) with asmtp (TLS-1.0:RSA_ARCFOUR_SHA:16)
	id 1CaiB6-0001Cs-EL
	for nfs@lists.sourceforge.net; Sat, 04 Dec 2004 14:14:56 -0800
Received: from chip by tytlal with local (Exim 4.34)
	id 1CaiBE-0001SS-8z
	for nfs@lists.sourceforge.net; Sat, 04 Dec 2004 17:15:04 -0500
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

Debian needs a bugfix release of nfs-utils, because of the SIGPIPE
bug.  This being my job, I figured I could grab the HEAD version of
nfs-utils.  And since the Debian sarge release is coming up soon (no,
really), I hoped I'd find something unlikely to crash; instead I'm
having difficulty with the build.

I gather that "libnfsidmap" is what I'll find in:

  http://www.citi.umich.edu/projects/nfsv4/linux/libnfsidmap/

Is there some reason this hasn't been made part of Debian already,
seeing as how it already contains Debian build infrastructure?

Also, is it a bug or a feature that the NFS startup scripts know how
to mount special-purpose filesystems, but not unmount them?
-- 
Chip Salzenberg              - a.k.a. -           <chip@pobox.com>
People are supposed to die for freedom.  Not the other way around.


-------------------------------------------------------
SF email is sponsored by - The IT Product Guide
Read honest & candid reviews on hundreds of IT Products from real users.
Discover which products truly live up to the hype. Start reading now. 
http://productguide.itmanagersjournal.com/
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
