From: Bernd Schubert <bernd-schubert@web.de>
Subject: Re: RE: Chrooted BIND broke on NFS server between kernel 2.4.21 and 2.4.22
Date: Sun, 14 Dec 2003 15:46:04 +0100
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <200312141546.04970.bernd-schubert@web.de>
References: <F7F4B5EA9EBD414D8A0091E80389450569D3D1@exchange.nrtc.coop>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="iso-8859-1"
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.12] helo=sc8-sf-mx2.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.24)
	id 1AVXVn-0003AK-25
	for nfs@lists.sourceforge.net; Sun, 14 Dec 2003 06:46:23 -0800
Received: from smtp05.web.de ([217.72.192.209] helo=smtp.web.de)
	by sc8-sf-mx2.sourceforge.net with esmtp (TLSv1:DES-CBC3-SHA:168)
	(Exim 4.24)
	id 1AVXVm-0000bo-M6
	for nfs@lists.sourceforge.net; Sun, 14 Dec 2003 06:46:22 -0800
To: "Jeremy Kusnetz" <JKusnetz@nrtc.org>,
 <nfs@lists.sourceforge.net>
In-Reply-To: <F7F4B5EA9EBD414D8A0091E80389450569D3D1@exchange.nrtc.coop>
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

>         if (!(exp->ex_flags & NFSEXP_NOSUBTREECHECK)) {

So giving 'no_subtree_check' as export option (man exports) should work as 
well, shouldn't it? Due to the problems already described on this list, I 
recently set this option to all rw-exported filesystems.

Cheers,
	Bernd


-------------------------------------------------------
This SF.net email is sponsored by: SF.net Giveback Program.
Does SourceForge.net help you be more productive?  Does it
help you create better code?  SHARE THE LOVE, and help us help
YOU!  Click Here: http://sourceforge.net/donate/
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
