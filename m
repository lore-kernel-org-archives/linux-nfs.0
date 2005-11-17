From: Trond Myklebust <trond.myklebust@fys.uio.no>
Subject: RE: NLM GRANT callback using AUTH_NULL is rejected
Date: Thu, 17 Nov 2005 11:56:40 -0500
Message-ID: <1132246600.8028.5.camel@lade.trondhjem.org>
References: <044B81DE141D7443BCE91E8F44B3C1E2013327B7@exsvl02.hq.netapp.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: "J. Bruce Fields" <bfields@fieldses.org>, neilb@suse.de,
	Olaf Kirch <okir@suse.de>, nfs@lists.sourceforge.net
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.92] helo=mail.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1Ecn4X-000820-PJ
	for nfs@lists.sourceforge.net; Thu, 17 Nov 2005 08:57:17 -0800
Received: from pat.uio.no ([129.240.130.16] ident=7411)
	by mail.sourceforge.net with esmtps (TLSv1:AES256-SHA:256)
	(Exim 4.44)
	id 1Ecn4V-0000dq-Dd
	for nfs@lists.sourceforge.net; Thu, 17 Nov 2005 08:57:18 -0800
To: "Lever, Charles" <Charles.Lever@netapp.com>
In-Reply-To: <044B81DE141D7443BCE91E8F44B3C1E2013327B7@exsvl02.hq.netapp.com>
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

On Thu, 2005-11-17 at 08:20 -0800, Lever, Charles wrote:

> was it the judgement of the community that no IP address checking for
> AUTH_NULL callbacks is better than having at least *some* sanity
> checking?  seems reasonable to me to register the IP address of the file
> server so that not just any joe IP address can grant locks.
> (limitations of authentication via IP address notwithstanding).

nlmsvc_grant_callback() checks that both the IP address and the cookie
match a request that was sent by the client.

Cheers,
  Trond



-------------------------------------------------------
This SF.Net email is sponsored by the JBoss Inc.  Get Certified Today
Register for a JBoss Training Course.  Free Certification Exam
for All Training Attendees Through End of 2005. For more info visit:
http://ads.osdn.com/?ad_id=7628&alloc_id=16845&op=click
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
