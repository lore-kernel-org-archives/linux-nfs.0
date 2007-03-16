From: Kevin Coffman <kwc@citi.umich.edu>
Subject: [PATCH 0/4] gssd updates
Date: Fri, 16 Mar 2007 10:18:26 -0400
Message-ID: <20070316141826.6349.9988.stgit@RoCk.CiTi.UmIcH.EdU>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: nfs@lists.sourceforge.net
To: neilb@suse.de
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.92]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1HSDPB-0007E4-Cp
	for nfs@lists.sourceforge.net; Fri, 16 Mar 2007 07:27:41 -0700
Received: from citi.umich.edu ([141.211.133.111])
	by mail.sourceforge.net with esmtps (TLSv1:AES256-SHA:256)
	(Exim 4.44) id 1HSDPB-0007vW-BT
	for nfs@lists.sourceforge.net; Fri, 16 Mar 2007 07:27:43 -0700
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

1/4 Cleans up a minor memory leak while processing the keytab.
2/4 Adds a new "-n" option to specify that machine credentials
    should not be used for all root accesses.
3/4 No longer limits machine credentials to only "nfs/<hostname>".
    Any key in the keytab (i.e. "host/<hostname>") can be used for
    machine credentials.
4/4 Creates separate paths for the base pipefs directory and the
    nfs subdirectory.  This is needed by future changes.

K.C.

-------------------------------------------------------------------------
Take Surveys. Earn Cash. Influence the Future of IT
Join SourceForge.net's Techsay panel and you'll get the chance to share your
opinions on IT & business topics through brief surveys-and earn cash
http://www.techsay.com/default.php?page=join.php&p=sourceforge&CID=DEVDEV
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
