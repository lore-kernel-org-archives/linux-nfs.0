From: "J. Bruce Fields" <bfields@fieldses.org>
Subject: 6 svcauth_unix patches to make export table lookups optional
Date: Thu, 16 Sep 2004 19:07:35 -0400
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <20040916230735.GB13415@fieldses.org>
References: <20040916230555.GA13415@fieldses.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: nfs@lists.sourceforge.net, Trond Myklebust <trond.myklebust@fys.uio.no>
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.12] helo=sc8-sf-mx2.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1C85Lp-0007xR-4V
	for nfs@lists.sourceforge.net; Thu, 16 Sep 2004 16:07:41 -0700
Received: from dsl093-002-214.det1.dsl.speakeasy.net ([66.93.2.214] helo=pickle.fieldses.org)
	by sc8-sf-mx2.sourceforge.net with esmtp (TLSv1:RC4-SHA:128)
	(Exim 4.34)
	id 1C85Ln-0005hD-NT
	for nfs@lists.sourceforge.net; Thu, 16 Sep 2004 16:07:41 -0700
To: Neil Brown <neilb@cse.unsw.edu.au>
In-Reply-To: <20040916230555.GA13415@fieldses.org>
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

Currently lockd and nfs4 callbacks have the problem that the
svcauth_unix and svcauth_null code insists on always doing the
ip_map_lookup stuff for all rpc services.

Of the six following patches, the first two are just cleanup, and should
be OK to apply now.  The third through sixth are first drafts posted to
give other people a chance to look them over--they'll need review at
least from Trond.  

In particular, I haven't actually tested either the lockd or the nfs4
callbacks.


-------------------------------------------------------
This SF.Net email is sponsored by: YOU BE THE JUDGE. Be one of 170
Project Admins to receive an Apple iPod Mini FREE for your judgement on
who ports your project to Linux PPC the best. Sponsored by IBM.
Deadline: Sept. 24. Go here: http://sf.net/ppc_contest.php
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
