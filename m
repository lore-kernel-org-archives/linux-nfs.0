From: Kevin Coffman <kwc@citi.umich.edu>
Subject: [PATCH 0/8] gssd cleanup and modified machine cred handling
Date: Fri, 30 Mar 2007 18:25:11 -0400
Message-ID: <20070330222511.28802.38147.stgit@RoCk.CiTi.UmIcH.EdU>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: nfs@lists.sourceforge.net
To: neilb@suse.de
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.92]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1HXPdd-0000Ik-AP
	for nfs@lists.sourceforge.net; Fri, 30 Mar 2007 15:32:05 -0700
Received: from citi.umich.edu ([141.211.133.111])
	by mail.sourceforge.net with esmtps (TLSv1:AES256-SHA:256)
	(Exim 4.44) id 1HXPde-00066P-4W
	for nfs@lists.sourceforge.net; Fri, 30 Mar 2007 15:32:07 -0700
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

These patches do some gssd code clean-up and change the way keytabs are
selected to obtain machine credentials.

1) adds missing newlines to some seldom printed error messages
2) fixes a memory leak in the error path of limit_krb5_enctypes()
3) adds some macros to clean up differences between MIT and Heimdal interfaces
4) adds the new functions that change the way keytabs are selected.
   the new behavior is to search for particular keytab entries in a
   specified order:

   root/<fqdn>@<REALM>
   nfs/<fqdn>@<REALM>
   host/<fqdn>@<REALM>
   root/<any-name>@<REALM>
   nfs/<any-name>@<REALM>
   host/<any-name>@<REALM>

5) actually use the new functions added in the previous patch
6) does some cleanup in gssd_get_single_krb5_cred() and improves
   the debugging messages
7) removes the now obsolete routines
8) adds a debug message to indicate processing is beginning

-------------------------------------------------------------------------
Take Surveys. Earn Cash. Influence the Future of IT
Join SourceForge.net's Techsay panel and you'll get the chance to share your
opinions on IT & business topics through brief surveys-and earn cash
http://www.techsay.com/default.php?page=join.php&p=sourceforge&CID=DEVDEV
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
