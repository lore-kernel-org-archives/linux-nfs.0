From: NeilBrown <neilb@suse.de>
Subject: [PATCH 000 of 4] Introduction - enhancment of support for
	larger rsize/wsize
Date: Mon, 7 Aug 2006 10:34:58 +1000
Message-ID: <20060807103020.12286.patches@notabene>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: nfs@lists.sourceforge.net
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.91]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1G9t5G-0007TV-Qi
	for nfs@lists.sourceforge.net; Sun, 06 Aug 2006 17:35:06 -0700
Received: from mx2.suse.de ([195.135.220.15])
	by mail.sourceforge.net with esmtps (TLSv1:AES256-SHA:256)
	(Exim 4.44) id 1G9t5F-0002IV-0W
	for nfs@lists.sourceforge.net; Sun, 06 Aug 2006 17:35:07 -0700
To: Greg Banks <gnb@melbourne.sgi.com>
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

For review (not being sent to Andrew yet),

I made some changes to the knfsd support for larger rsize/wsize patch,
and have add 3 extra patches!!

The first two patches reduce the number of arrays indexed by
RPCSVC_MAXPAGES so avoid wastage.
The last makes the maximum nfsd payload configurable.
Comments on exactly what the defaults should be are most
welcome, as is any review.

Note: I dropped the idea of calling svc_recvfrom in a loop, and just
allocate the vector on inside svc_rqst.

Thanks,
NeilBrown


 [PATCH 001 of 4] Replace two page lists in struct svc_rqst with one.
 [PATCH 002 of 4] Avoid excess stack usage in svc_tcp_recvfrom
 [PATCH 003 of 4] Prepare knfsd for support of rsize/wsize of up to 1MB, over TCP.
 [PATCH 004 of 4] Allow max size of NFSd payload to be configured.

-------------------------------------------------------------------------
Take Surveys. Earn Cash. Influence the Future of IT
Join SourceForge.net's Techsay panel and you'll get the chance to share your
opinions on IT & business topics through brief surveys -- and earn cash
http://www.techsay.com/default.php?page=join.php&p=sourceforge&CID=DEVDEV
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
