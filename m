From: Trond Myklebust <trond.myklebust@fys.uio.no>
Subject: Re: rquota overflow fix never applied ?
Date: Tue, 30 Aug 2005 09:05:20 -0700
Message-ID: <1125417920.8443.20.camel@lade.trondhjem.org>
References: <200508300108.52636.vapier@gentoo.org>
	 <17171.63513.738531.932794@cse.unsw.edu.au>
Mime-Version: 1.0
Content-Type: text/plain
Cc: Mike Frysinger <vapier@gentoo.org>, nfs@lists.sourceforge.net
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.92] helo=mail.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1EA8cO-0007xA-VP
	for nfs@lists.sourceforge.net; Tue, 30 Aug 2005 09:05:48 -0700
Received: from pat.uio.no ([129.240.130.16])
	by mail.sourceforge.net with esmtps (TLSv1:AES256-SHA:256)
	(Exim 4.44)
	id 1EA8cN-0007mN-Ke
	for nfs@lists.sourceforge.net; Tue, 30 Aug 2005 09:05:49 -0700
To: Neil Brown <neilb@cse.unsw.edu.au>
In-Reply-To: <17171.63513.738531.932794@cse.unsw.edu.au>
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

ty den 30.08.2005 Klokka 16:09 (+1000) skreiv Neil Brown:

> However I seem to be a bit thick today and cannot see where the
> overflow is happening.
> dqblk is 6 u_int32_t's and 2 time_t's

Isn't time_t defined to be unsigned long?

> struct rquota (after rq_bhardlimit) is 8 u_int's

Whether or not it fixes the particular problem it claims to, this is a
patch we should apply (or we should write something similar).

It is just evil to do direct memcpy between different structures. As
soon as someone does something that changes field alignments, starts
appending new fields,... on one structure but not the other, you
immediately get into trouble.

Cheers,
  Trond



-------------------------------------------------------
SF.Net email is Sponsored by the Better Software Conference & EXPO
September 19-22, 2005 * San Francisco, CA * Development Lifecycle Practices
Agile & Plan-Driven Development * Managing Projects & Teams * Testing & QA
Security * Process Improvement & Measurement * http://www.sqe.com/bsce5sf
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
