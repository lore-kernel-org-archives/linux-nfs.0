From: "J. Bruce Fields" <bfields@fieldses.org>
Subject: 6 patches fixing server rpc callback authentication
Date: Thu, 09 Dec 2004 17:28:36 -0500
Message-ID: <1102628809.16c39937.0@fieldses.org>
Cc: nfs@lists.sourceforge.net, Trond Myklebust <trond.myklebust@fys.uio.no>
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.11] helo=sc8-sf-mx1.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1CcWlq-0005GB-5m
	for nfs@lists.sourceforge.net; Thu, 09 Dec 2004 14:28:22 -0800
Received: from dh173.citi.umich.edu
	([141.211.133.173] helo=puzzle.fieldses.org ident=Debian-exim)
	by sc8-sf-mx1.sourceforge.net with esmtp (TLSv1:RC4-SHA:128)
	(Exim 4.41)
	id 1CcWlh-0006Py-7o
	for nfs@lists.sourceforge.net; Thu, 09 Dec 2004 14:28:22 -0800
To: Neil Brown <neilb@cse.unsw.edu.au>
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

This is my second attempt; sorry for the delay.

To summarize the problem: The server insists on checking incoming rpc calls
against the list of clients that nfsd exports to, for all rpc services.  The
most visible bug caused by this is unnecessary delays granting locks, caused by
the client's lockd incorrectly rejecting GRANTED callbacks.

The following patches replace the client checks in svcauth_unix.c by a
program-specific pg_authenticate() callback.  In the case of nfsd,
pg_authenticate just does the usual client checks.

Changes since the previous version of these patches:

	* Move the call to the pg_authenticate() callback into svc_process()
	  and out of the flavor-specific code.
	* Add a flavor-specific callback to the server's rpc auth_ops to map
	  an incoming request to the "client" it is thought to be from, for
	  pg_authenticate to use in the case where it wants a client for
	  later checking against the export list.

I've tested that this does at least solve the problem with lockd callbacks.

--b.


-------------------------------------------------------
SF email is sponsored by - The IT Product Guide
Read honest & candid reviews on hundreds of IT Products from real users.
Discover which products truly live up to the hype. Start reading now. 
http://productguide.itmanagersjournal.com/
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
