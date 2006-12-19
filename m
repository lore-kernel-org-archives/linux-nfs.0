From: Jeff Layton <jlayton@redhat.com>
Subject: [PATCH] add missing long option for -r in mountd
Date: Tue, 19 Dec 2006 11:59:07 -0500
Message-ID: <45881A5B.7080900@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: neilb@suse.de
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.92]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1GwiJ8-0006xI-Ng
	for nfs@lists.sourceforge.net; Tue, 19 Dec 2006 08:59:14 -0800
Received: from mx1.redhat.com ([66.187.233.31])
	by mail.sourceforge.net with esmtp (Exim 4.44) id 1GwiJ9-0004VF-1U
	for nfs@lists.sourceforge.net; Tue, 19 Dec 2006 08:59:16 -0800
To: nfs@lists.sourceforge.net
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

I forgot a bit of code that needs to go into patch 3 that I posted yesterday.
This adds a long option for the -r option. I'll post manpage update patches
once I get them written up.

Signed-off-by: Jeff Layton <jlayton@redhat.com>

--- nfs-utils-1.0.10/utils/mountd/mountd.c.longopt
+++ nfs-utils-1.0.10/utils/mountd/mountd.c
@@ -67,6 +67,7 @@ static struct option longopts[] =
  	{ "ha-callout", 1, 0, 'H' },
  	{ "state-directory-path", 1, 0, 's' },
  	{ "num-threads", 1, 0, 't' },
+	{ "reverse-lookup", 0, 0, 'r' },
  	{ NULL, 0, 0, 0 }
  };


-------------------------------------------------------------------------
Take Surveys. Earn Cash. Influence the Future of IT
Join SourceForge.net's Techsay panel and you'll get the chance to share your
opinions on IT & business topics through brief surveys - and earn cash
http://www.techsay.com/default.php?page=join.php&p=sourceforge&CID=DEVDEV
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
