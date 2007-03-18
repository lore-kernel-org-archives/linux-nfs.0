From: Neil Brown <neilb@suse.de>
Subject: Re: rpc.mountd memory leak?
Date: Mon, 19 Mar 2007 09:25:03 +1100
Message-ID: <17917.48191.64592.864739@notabene.brown>
References: <1174248657.21998.6.camel@blackwidow.nbk>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: nfs@lists.sourceforge.net
To: Albert Hopkins <marduk@letterboxes.org>
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.92]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1HT3oU-0004Wa-IV
	for nfs@lists.sourceforge.net; Sun, 18 Mar 2007 15:25:18 -0700
Received: from ns.suse.de ([195.135.220.2] helo=mx1.suse.de)
	by mail.sourceforge.net with esmtps (TLSv1:AES256-SHA:256)
	(Exim 4.44) id 1HT3oV-0003iZ-9B
	for nfs@lists.sourceforge.net; Sun, 18 Mar 2007 15:25:20 -0700
In-Reply-To: message from Albert Hopkins on Sunday March 18
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

On Sunday March 18, marduk@letterboxes.org wrote:
> I am using 1.0.12 of nfs-utils (linux/x86).  I have a problem in that
> after a while rpc.mountd starts to eat up gobs of memory (sometimes >
> 1GB) and usually I am required to stop/restart NFS services to regain
> memory.  I do not have many exported filesystems and very few clients
> have anything mounted at a given time, so I'm not sure why it would need
> as much memory so I'm guessing it's some kind of leak.  Please let me
> know what I can do to debug this situation.

Known problem (fixed if you use debian-unstable).

Apparently there is a memory leak in libblkid which mounted now uses.

http://bugs.debian.org/cgi-bin/bugreport.cgi?bug=413661

There is also a smaller leak in mountd.

http://linux-nfs.org/cgi-bin/gitweb.cgi?p=nfs-utils;a=commitdiff;h=08964495c2a65f6228426e4565a50dae5b75834d

From: Steinar H. Gunderson <sgunderson@bigfoot.com>
Date: Fri, 16 Mar 2007 00:26:35 +0000 (+1100)
Subject: Fix memory leak in mountd.
X-Git-Url: http://linux-nfs.org/cgi-bin/gitweb.cgi?p=nfs-utils;a=commitdiff;h=08964495c2a65f6228426e4565a50dae5b75834d

Fix memory leak in mountd.

Signed-off-by: Neil Brown <neilb@suse.de>
---

--- a/support/export/client.c
+++ b/support/export/client.c
@@ -329,6 +329,7 @@ add_name(char *old, char *add)
 		strcat(new, ",");
 		strcat(new, cp);
 	}
+	free(old);
 	return new;
 }
 


Maybe I should do a 1.0.13 which makes libblkid optional...
NeilBrown

-------------------------------------------------------------------------
Take Surveys. Earn Cash. Influence the Future of IT
Join SourceForge.net's Techsay panel and you'll get the chance to share your
opinions on IT & business topics through brief surveys-and earn cash
http://www.techsay.com/default.php?page=join.php&p=sourceforge&CID=DEVDEV
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
