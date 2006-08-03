From: Olaf Kirch <okir@suse.de>
Subject: [PATCH 0/4] Introduce sysctl registration helpers
Date: Thu, 3 Aug 2006 13:05:37 +0200
Message-ID: <20060803110537.GA17158@suse.de>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.91]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1G8b1I-0007dN-MN
	for nfs@lists.sourceforge.net; Thu, 03 Aug 2006 04:05:40 -0700
Received: from ns.suse.de ([195.135.220.2] helo=mx1.suse.de)
	by mail.sourceforge.net with esmtps (TLSv1:AES256-SHA:256)
	(Exim 4.44) id 1G8b1I-0001dT-RR
	for nfs@lists.sourceforge.net; Thu, 03 Aug 2006 04:05:41 -0700
Received: from Relay1.suse.de (mail2.suse.de [195.135.221.8])
	(using TLSv1 with cipher DHE-RSA-AES256-SHA (256/256 bits))
	(No client certificate requested)
	by mx1.suse.de (Postfix) with ESMTP id 0AE1DFE7B
	for <nfs@lists.sourceforge.net>; Thu,  3 Aug 2006 13:05:38 +0200 (CEST)
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

Subject: Introduce sysctl registration helpers

1/4 register_sysctl_path
	This patch introduces a new mechanism for registering a sysctl
	table, without having to create those funky dummy tables for
	all the parent directories.

2/4 nfs-sysctl
	This makes the NFS client code register a sysctl table, and
	adds a sysctl for max_readahead

3/4 nfsd-sysctl
	This makes the NFS server code register a sysctl table,
	and adds a sysctl for max readdirplus data we return.
	We had problems with some clients not being able to 
	grok more than 4K worth of data.

4/4 fs-sysctl-register-convert
	Converts lockd and sunrpc to use the new sysctl
	registration code.


-------------------------------------------------------------------------
Take Surveys. Earn Cash. Influence the Future of IT
Join SourceForge.net's Techsay panel and you'll get the chance to share your
opinions on IT & business topics through brief surveys -- and earn cash
http://www.techsay.com/default.php?page=join.php&p=sourceforge&CID=DEVDEV
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
