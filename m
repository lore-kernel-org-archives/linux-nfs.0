From: Chip Salzenberg <chip@pobox.com>
Subject: Must portmap listen on * in NFS clients?
Date: Mon, 15 Dec 2003 16:48:44 -0500
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <20031215214844.GR20533@perlsupport.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.12] helo=sc8-sf-mx2.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.24)
	id 1AW0a5-0004zQ-No
	for nfs@lists.sourceforge.net; Mon, 15 Dec 2003 13:48:45 -0800
Received: from topaz.cx
	([66.220.6.227] helo=mail.topaz.cx ident=mail)
	by sc8-sf-mx2.sourceforge.net with esmtp (TLSv1:DES-CBC3-SHA:168)
	(Exim 4.24)
	id 1AW0a5-0003EK-Hu
	for nfs@lists.sourceforge.net; Mon, 15 Dec 2003 13:48:45 -0800
Received: from tytlal.hmsonline.com
	([207.43.94.202] helo=tytlal ident=Debian-exim)
	by mail.perlsupport.com with asmtp (Exim 3.35 #1 (Debian))
	id 1AW0a2-0002Hy-00
	for <nfs@lists.sourceforge.net>; Mon, 15 Dec 2003 13:48:42 -0800
Received: from chip by tytlal with local (Exim 4.30)
	id 1AW0a4-00070h-8f
	for nfs@lists.sourceforge.net; Mon, 15 Dec 2003 16:48:44 -0500
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

I have a question that will soon be relevant for Debian NFS packaging.

As far as NFS is concerned, need portmap listen on all interfaces when
the machine it's on is only an NFS *client*?  I know that servers'
portmaps must listen on * so clients can find mountd.  But, AFAICT,
clients need not have open portmaps.  Am I right in this?

PS: I should already know this.  But NFS protocol issues have always
    given me the screaming heebie jeebies.
-- 
Chip Salzenberg               - a.k.a. -               <chip@pobox.com>
"I wanted to play hopscotch with the impenetrable mystery of existence,
    but he stepped in a wormhole and had to go in early."  // MST3K


-------------------------------------------------------
This SF.net email is sponsored by: SF.net Giveback Program.
Does SourceForge.net help you be more productive?  Does it
help you create better code?  SHARE THE LOVE, and help us help
YOU!  Click Here: http://sourceforge.net/donate/
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
