From: Christoph Hellwig <hch@infradead.org>
Subject: Re: [PATCH 010 of 11] knfsd: make pools numa aware (ifdefless)
Date: Wed, 26 Jul 2006 14:06:47 +0100
Message-ID: <20060726130647.GB25636@infradead.org>
References: <1153913457.21040.854.camel@hole.melbourne.sgi.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: Linux NFS Mailing List <nfs@lists.sourceforge.net>
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.92]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1G5rK2-0001eG-4w
	for nfs@lists.sourceforge.net; Wed, 26 Jul 2006 14:53:45 -0700
Received: from externalmx-1.sourceforge.net ([12.152.184.25])
	by mail.sourceforge.net with esmtps (TLSv1:AES256-SHA:256)
	(Exim 4.44) id 1G5rJz-0000iS-1X
	for nfs@lists.sourceforge.net; Wed, 26 Jul 2006 14:53:42 -0700
Received: from pentafluge.infradead.org ([213.146.154.40])
	by externalmx-1.sourceforge.net with esmtp (TLSv1:AES256-SHA:256)
	(Exim 4.41) id 1G5j6C-0005ng-Ae
	for nfs@lists.sourceforge.net; Wed, 26 Jul 2006 06:06:53 -0700
To: Greg Banks <gnb@melbourne.sgi.com>
In-Reply-To: <1153913457.21040.854.camel@hole.melbourne.sgi.com>
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

And btw, any chance to fix your patchscript to say

[PATCH 10/11]

instead of the annoying 010?


-------------------------------------------------------------------------
Take Surveys. Earn Cash. Influence the Future of IT
Join SourceForge.net's Techsay panel and you'll get the chance to share your
opinions on IT & business topics through brief surveys -- and earn cash
http://www.techsay.com/default.php?page=join.php&p=sourceforge&CID=DEVDEV
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
