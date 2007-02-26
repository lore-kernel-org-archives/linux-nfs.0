From: Kevin Coffman <kwc@citi.umich.edu>
Subject: [PATCH] Fix reference error when writing fsloc data to cache
Date: Mon, 26 Feb 2007 13:37:47 -0500
Message-ID: <20070226183747.4060.29293.stgit@rock.citi.umich.edu>
References: <20070226183709.4060.68393.stgit@rock.citi.umich.edu>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: nfs@lists.sourceforge.net
To: neilb@suse.de
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.91]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1HLkjO-0004nP-Q4
	for nfs@lists.sourceforge.net; Mon, 26 Feb 2007 10:37:54 -0800
Received: from citi.umich.edu ([141.211.133.111])
	by mail.sourceforge.net with esmtp (Exim 4.44) id 1HLkjP-00028c-Nt
	for nfs@lists.sourceforge.net; Mon, 26 Feb 2007 10:37:52 -0800
In-Reply-To: <20070226183709.4060.68393.stgit@rock.citi.umich.edu>
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

From: Kevin Coffman <kwc@citi.umich.edu>

Use the correct pointer when writing fslocations data to the cache.
---

 utils/mountd/cache.c |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/utils/mountd/cache.c b/utils/mountd/cache.c
index a14f4f2..97481bd 100644
--- a/utils/mountd/cache.c
+++ b/utils/mountd/cache.c
@@ -465,7 +465,7 @@ static int dump_to_cache(FILE *f, char *
  			qword_print(f, "uuid");
  			qword_printhex(f, exp->e_uuid, 16);
  		}
-		write_fsloc(f, &exp, path);
+		write_fsloc(f, exp, path);
 	}
 	return qword_eol(f);
 }

-------------------------------------------------------------------------
Take Surveys. Earn Cash. Influence the Future of IT
Join SourceForge.net's Techsay panel and you'll get the chance to share your
opinions on IT & business topics through brief surveys-and earn cash
http://www.techsay.com/default.php?page=join.php&p=sourceforge&CID=DEVDEV
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
