From: Sven Geggus <sven@geggus.net>
Subject: Authenticated NFS mounts
Date: Tue, 18 Oct 2005 11:00:39 +0000 (UTC)
Message-ID: <dj2kkn$4hr$1@benzin.geggus.net>
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.92] helo=mail.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1ERpD7-0003aJ-Cm
	for nfs@lists.sourceforge.net; Tue, 18 Oct 2005 04:00:49 -0700
Received: from dolly.gnuher.de ([212.227.64.154])
	by mail.sourceforge.net with esmtps (TLSv1:AES256-SHA:256)
	(Exim 4.44)
	id 1ERpD6-0003qe-6X
	for nfs@lists.sourceforge.net; Tue, 18 Oct 2005 04:00:49 -0700
Received: from benzin.geggus.net ([2001:8d8:81:672::1])
	by dolly.gnuher.de with esmtpsa TLS-1.0:RSA_AES_256_CBC_SHA:32
	(Exim 4.50 id 1ERpCy-00021f-QF)
	for <nfs@lists.sourceforge.net>; Tue, 18 Oct 2005 13:00:41 +0200
Received: from news by benzin.geggus.net with local
	(Exim 4.50 id 1ERpCx-0001HA-HX)
	for <nfs@lists.sourceforge.net>; Tue, 18 Oct 2005 13:00:39 +0200
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

Hello NFS-list,

Section A5 of the Linux NFS FAQ (Can I use Kerberos authentication with NFS
on Linux?) is somewhat confusing as it the Answer is not clearly yes or no.

So whats the current Answer to this simple Question:

Is ist possible to use RPCSEC GSSAPI in conjunction with NFSv3 on Linux
Clients and Servers?

I managed to use it in conjunction with NFSv4, but NFSv4 does not seem to be
stable enough for production use. I had machine lockups even on a
test-installation I have been using :(

Sven

-- 
Software patents are the software project equivalent of land mines: Each
design decision carries a risk of stepping on a patent, which can destroy
your project. (Richard M. Stallman)
/me is giggls@ircnet, http://sven.gegg.us/ on the Web


-------------------------------------------------------
This SF.Net email is sponsored by:
Power Architecture Resource Center: Free content, downloads, discussions,
and more. http://solutions.newsforge.com/ibmarch.tmpl
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
