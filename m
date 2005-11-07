From: "Lever, Charles" <Charles.Lever@netapp.com>
Subject: updates to the Linux NFS FAQ
Date: Mon, 7 Nov 2005 08:51:22 -0800
Message-ID: <044B81DE141D7443BCE91E8F44B3C1E288E5F3@exsvl02.hq.netapp.com>
Mime-Version: 1.0
Content-Type: text/plain;
	charset="US-ASCII"
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.92] helo=mail.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1EZADR-0003YO-9w
	for nfs@lists.sourceforge.net; Mon, 07 Nov 2005 08:51:29 -0800
Received: from mx1.netapp.com ([216.240.18.38])
	by mail.sourceforge.net with esmtp (Exim 4.44)
	id 1EZADR-0001vm-AN
	for nfs@lists.sourceforge.net; Mon, 07 Nov 2005 08:51:29 -0800
Received: from svlexc02.hq.netapp.com (svlexc02.corp.netapp.com [10.57.157.136])
	by smtp2.corp.netapp.com (8.13.1/8.13.1/NTAP-1.6) with ESMTP id jA7GpMjr017644
	for <nfs@lists.sourceforge.net>; Mon, 7 Nov 2005 08:51:23 -0800 (PST)
To: <nfs@lists.sourceforge.net>
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

i've finally gotten off my lazy ass and added some updates to the FAQ
that have been queued for a while.

question A8 (what is close-to-open cache coherency?) has been
substantially updated to discuss noac, file locking, O_DIRECT, and write
caching behavior.

question D2 now has a better explanation of silly renames, based on some
recent questions to this mailing list.

question D12 has been added, describing how to use "umount -f" and
"umount -l".

        - Chuck Lever
--
corporate:     <cel at netapp dot com>
personal:      <chucklever at bigfoot dot com>


-------------------------------------------------------
SF.Net email is sponsored by:
Tame your development challenges with Apache's Geronimo App Server. Download
it for free - -and be entered to win a 42" plasma tv or your very own
Sony(tm)PSP.  Click here to play: http://sourceforge.net/geronimo.php
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
