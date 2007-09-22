From: "Steinar H. Gunderson" <sgunderson@bigfoot.com>
Subject: Multiple ranges in squash_uids
Date: Sat, 22 Sep 2007 12:11:54 +0200
Message-ID: <20070922101154.GA27465@uio.no>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
To: nfs@lists.sourceforge.net
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.92]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1IZ1xx-00061t-LL
	for nfs@lists.sourceforge.net; Sat, 22 Sep 2007 03:12:01 -0700
Received: from cassarossa.samfundet.no ([129.241.93.19] ident=Debian-exim)
	by mail.sourceforge.net with esmtps (TLSv1:AES256-SHA:256)
	(Exim 4.44) id 1IZ1xy-000068-UH
	for nfs@lists.sourceforge.net; Sat, 22 Sep 2007 03:12:05 -0700
Received: from trofast.ipv6.sesse.net ([2001:700:300:1803:20e:cff:fe36:a766]
	helo=trofast.sesse.net) by cassarossa.samfundet.no with esmtps
	(TLS-1.0:RSA_AES_256_CBC_SHA1:32) (Exim 4.63)
	(envelope-from <sesse@samfundet.no>) id 1IZ1xq-0000Ge-Vr
	for nfs@lists.sourceforge.net; Sat, 22 Sep 2007 12:11:55 +0200
Received: from root by trofast.sesse.net with local (Exim 4.67)
	(envelope-from <sesse@samfundet.no>) id 1IZ1xq-00079U-9s
	for nfs@lists.sourceforge.net; Sat, 22 Sep 2007 12:11:54 +0200
List-Id: "Discussion of NFS under Linux development, interoperability,
	and testing." <nfs.lists.sourceforge.net>
List-Unsubscribe: <https://lists.sourceforge.net/lists/listinfo/nfs>,
	<mailto:nfs-request@lists.sourceforge.net?subject=unsubscribe>
List-Archive: <http://sourceforge.net/mailarchive/forum.php?forum_name=nfs>
List-Post: <mailto:nfs@lists.sourceforge.net>
List-Help: <mailto:nfs-request@lists.sourceforge.net?subject=help>
List-Subscribe: <https://lists.sourceforge.net/lists/listinfo/nfs>,
	<mailto:nfs-request@lists.sourceforge.net?subject=subscribe>
Sender: nfs-bounces@lists.sourceforge.net
Errors-To: nfs-bounces@lists.sourceforge.net

Hi,

A user recently complained that you cannot use options like
"squash_uids=1000-1005,2000-3000", even though the manual page says it's
supported. The issue is that the option tokenizer thinks "2000-3000" is a
separate option, so although the uid range parser does handle multiple ranges
correctly, it doesn't work right.

The user also supplied a patch (see
http://bugs.debian.org/cgi-bin/bugreport.cgi?msg=5;filename=nfs-utils_parse_squashids_fix.diff;att=1;bug=442370),
but I'm not sure if it's the best way to do it. Any suggestions?

/* Steinar */
-- 
Homepage: http://www.sesse.net/

-------------------------------------------------------------------------
This SF.net email is sponsored by: Microsoft
Defy all challenges. Microsoft(R) Visual Studio 2005.
http://clk.atdmt.com/MRT/go/vse0120000070mrt/direct/01/
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
