From: "Steinar H. Gunderson" <sesse@debian.org>
Subject: nhfsstone license
Date: Mon, 20 Nov 2006 22:53:05 +0100
Message-ID: <20061120215305.GA11924@uio.no>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: 398058@bugs.debian.org
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.91]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1GmH5y-0000uF-2W
	for nfs@lists.sourceforge.net; Mon, 20 Nov 2006 13:54:30 -0800
Received: from cassarossa.samfundet.no ([129.241.93.19] ident=Debian-exim)
	by mail.sourceforge.net with esmtps (TLSv1:AES256-SHA:256)
	(Exim 4.44) id 1GmH5u-0003Nb-TC
	for nfs@lists.sourceforge.net; Mon, 20 Nov 2006 13:54:28 -0800
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

[Please Cc me and the bug on replies; I'm not subscribed to the list]

Hi,

It has recently come to my attention that the DISCLAIMER file of nhfsstone
(distributed with nfs-utils) is distributed a non-free license. Specifically,
the wording says "Legato nhfsstone may be modified only for the purpose of
porting", and while we believe that they meant "you can only call this Legato
nhfsstone if you don't modify it except for porting reasons" (given the rest
of the text) this is unfortunately not what the words say.

debian/copyright (which used to be in upstream CVS) claims that the entire
package is under GPL; however, I cannot find anything about a relicensing
anywhere. I've tried contacting Legato (at nhfsstone@legato.com), but given
that this software seems to have been made in 1989, it's perhaps not that odd
that I haven't received any reply from them.

Does anybody know what the current license status of nhfsstone is? If we
cannot get this resolved, we'd have to remove nhfsstone from Debian main,
which would be rather painful (if nothing else because we'd have to modify
the upstream tarball), so I'd really hope we could find some sort of
solution.

/* Steinar */
-- 
Homepage: http://www.sesse.net/

-------------------------------------------------------------------------
Take Surveys. Earn Cash. Influence the Future of IT
Join SourceForge.net's Techsay panel and you'll get the chance to share your
opinions on IT & business topics through brief surveys - and earn cash
http://www.techsay.com/default.php?page=join.php&p=sourceforge&CID=DEVDEV
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
