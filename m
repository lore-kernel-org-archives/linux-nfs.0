From: "Lever, Charles" <Charles.Lever@netapp.com>
Subject: NLM GRANT callback using AUTH_NULL is rejected
Date: Thu, 17 Nov 2005 07:38:22 -0800
Message-ID: <044B81DE141D7443BCE91E8F44B3C1E2013327B6@exsvl02.hq.netapp.com>
Mime-Version: 1.0
Content-Type: text/plain;
	charset="US-ASCII"
Cc: "Olaf Kirch" <okir@suse.de>, <nfs@lists.sourceforge.net>
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.92] helo=mail.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1EclqP-0004gF-Hm
	for nfs@lists.sourceforge.net; Thu, 17 Nov 2005 07:38:37 -0800
Received: from mx1.netapp.com ([216.240.18.38])
	by mail.sourceforge.net with esmtp (Exim 4.44)
	id 1EclqN-0006Hi-80
	for nfs@lists.sourceforge.net; Thu, 17 Nov 2005 07:38:37 -0800
To: <neilb@suse.de>
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

hi neil-

it looks like you have the most expertise in this area, so you are the
lucky victim today.

our filer sends NLM GRANTED callbacks back to clients using AUTH_NULL
authentication.  Linux clients always seem to reject these callbacks.

parsing through fs/lockd and net/sunrpc, i see a comment that indicates
that AUTH_NULL RPC requests are subject to IP access control (a la
/etc/exports).  theoretically, if lockd doesn't register the filer in
the ip_map cache, then all the filer's callbacks will be rejected,
right?

        - Chuck Lever
--
corporate:    <cel at netapp dot com>
personal:     <chucklever at bigfoot dot com>


-------------------------------------------------------
This SF.Net email is sponsored by the JBoss Inc.  Get Certified Today
Register for a JBoss Training Course.  Free Certification Exam
for All Training Attendees Through End of 2005. For more info visit:
http://ads.osdn.com/?ad_id=7628&alloc_id=16845&op=click
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
