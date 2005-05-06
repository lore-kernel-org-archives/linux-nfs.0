From: Christoph Hellwig <hch@infradead.org>
Subject: how to test rpc_pipefs
Date: Fri, 6 May 2005 17:10:18 +0100
Message-ID: <20050506161018.GA3979@infradead.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.12] helo=sc8-sf-mx2.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1DU5PD-0000kE-To
	for nfs@lists.sourceforge.net; Fri, 06 May 2005 09:10:23 -0700
Received: from pentafluge.infradead.org ([213.146.154.40])
	by sc8-sf-mx2.sourceforge.net with esmtp (TLSv1:AES256-SHA:256)
	(Exim 4.41)
	id 1DU5PA-0001jk-Ab
	for nfs@lists.sourceforge.net; Fri, 06 May 2005 09:10:23 -0700
Received: from hch by pentafluge.infradead.org with local (Exim 4.43 #1 (Red Hat Linux))
	id 1DU5P8-00012c-35
	for nfs@lists.sourceforge.net; Fri, 06 May 2005 17:10:18 +0100
To: nfs@lists.sourceforge.net
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

I have some simple changes to make rpc_pipefs use less obscure VFS
APIs and I'd like to test it before submitting, any idea how to give
rpc_pipefs some coverage without settign up a full-blown NFSv4 env?


-------------------------------------------------------
This SF.Net email is sponsored by: NEC IT Guy Games.
Get your fingers limbered up and give it your best shot. 4 great events, 4
opportunities to win big! Highest score wins.NEC IT Guy Games. Play to
win an NEC 61 plasma display. Visit http://www.necitguy.com/?r=20
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
