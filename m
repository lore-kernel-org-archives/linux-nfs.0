From: Chip Salzenberg <chip@pobox.com>
Subject: Proposal: Starting statd on demand
Date: Fri, 9 Apr 2004 14:03:52 -0400
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <20040409180352.GH2767@perlsupport.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.11] helo=sc8-sf-mx1.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1BC0MO-0007WY-U4
	for nfs@lists.sourceforge.net; Fri, 09 Apr 2004 11:04:12 -0700
Received: from perlsupport.com
	([66.220.6.226] helo=mail.topaz.cx ident=mail)
	by sc8-sf-mx1.sourceforge.net with esmtp (TLSv1:DES-CBC3-SHA:168)
	(Exim 4.30)
	id 1BC0MO-0002nt-P8
	for nfs@lists.sourceforge.net; Fri, 09 Apr 2004 11:04:12 -0700
Received: from [207.43.94.202] (helo=tytlal ident=Debian-exim)
	by mail.perlsupport.com with asmtp (Exim 3.35 #1 (Debian))
	id 1BC0MH-0004g1-00
	for <nfs@lists.sourceforge.net>; Fri, 09 Apr 2004 11:04:05 -0700
Received: from chip by tytlal with local (Exim 4.31)
	id 1BC0M4-0001OD-Bw
	for nfs@lists.sourceforge.net; Fri, 09 Apr 2004 14:03:52 -0400
To: nfs@lists.sourceforge.net
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

It's a well-known security principle that services should not be running
when they are not needed.

I would like to make statd follow that principle.

Does anyone have a suggestion on how?  I don't want to reinvent an
already-proposed wheel.
-- 
Chip Salzenberg               - a.k.a. -               <chip@pobox.com>
"I wanted to play hopscotch with the impenetrable mystery of existence,
    but he stepped in a wormhole and had to go in early."  // MST3K


-------------------------------------------------------
This SF.Net email is sponsored by: IBM Linux Tutorials
Free Linux tutorial presented by Daniel Robbins, President and CEO of
GenToo technologies. Learn everything from fundamentals to system
administration.http://ads.osdn.com/?ad_id=1470&alloc_id=3638&op=click
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
