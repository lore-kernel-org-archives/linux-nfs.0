From: Trond Myklebust <trond.myklebust@fys.uio.no>
Subject: Re: [PATCH] fix nfsidem cthon test
Date: Thu, 21 Oct 2004 09:31:31 +0200
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <1098343891.28394.15.camel@lade.trondhjem.org>
References: <1098341478.21421.7.camel@hole.melbourne.sgi.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: Linux NFS Mailing List <nfs@lists.sourceforge.net>
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.11] helo=sc8-sf-mx1.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1CKXQP-0005GG-Cg
	for nfs@lists.sourceforge.net; Thu, 21 Oct 2004 00:31:53 -0700
Received: from pat.uio.no ([129.240.130.16] ident=7411)
	by sc8-sf-mx1.sourceforge.net with esmtp (Exim 4.41)
	id 1CKXQO-0000Sl-Lh
	for nfs@lists.sourceforge.net; Thu, 21 Oct 2004 00:31:53 -0700
To: Greg Banks <gnb@melbourne.sgi.com>
In-Reply-To: <1098341478.21421.7.camel@hole.melbourne.sgi.com>
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

to den 21.10.2004 Klokka 16:51 (+1000) skreiv Greg Banks:
> G'day,
> 
> The attached patch forward ports from 2.4 the fix to nfs_rename()
> which makes the nfsidem test in the Connectathon test suite pass.


Vetoed.

This remains a server bug, not a client bug. The default should NOT be
no_subtree_check.

Besides, that patch will screw up on "nohide" partitions which may
indeed cause 2 different files to have the same fileid.

Cheers,
  Trond

-- 
Trond Myklebust <trond.myklebust@fys.uio.no>



-------------------------------------------------------
This SF.net email is sponsored by: IT Product Guide on ITManagersJournal
Use IT products in your business? Tell us what you think of them. Give us
Your Opinions, Get Free ThinkGeek Gift Certificates! Click to find out more
http://productguide.itmanagersjournal.com/guidepromo.tmpl
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
