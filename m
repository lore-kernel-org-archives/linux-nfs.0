From: Jan Kara <jack@ucw.cz>
Subject: Clean way of finding NFSv4 pseudofs root?
Date: Thu, 14 Apr 2005 12:17:19 +0200
Message-ID: <20050414101719.GB18727@atrey.karlin.mff.cuni.cz>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.11] helo=sc8-sf-mx1.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1DM1Pa-0006aq-2a
	for nfs@lists.sourceforge.net; Thu, 14 Apr 2005 03:17:26 -0700
Received: from atrey.karlin.mff.cuni.cz ([195.113.31.123] ident=postfix)
	by sc8-sf-mx1.sourceforge.net with esmtp (Exim 4.41)
	id 1DM1PY-000781-J9
	for nfs@lists.sourceforge.net; Thu, 14 Apr 2005 03:17:25 -0700
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

  Hello!

  I'm a developer of quota tools and I'd like to implement a support for
NFSv4 into rpc.rquotad. The only difference for quotas is that in NFSv4
clients use only relative references to NFSv4 pseudofilesystem root. So
rpc.rquotad needs to find out where this root is. How can it cleanly do
it? It could for example parse /var/lib/nfs/xtab but is this supposed to
be a reasonably stable interface? Are there some other possibilites?

						Thanks for ideas
								Honza

PS: Please CC me directly as I'm not on the list.


-------------------------------------------------------
This SF.Net email is sponsored by: New Crystal Reports XI.
Version 11 adds new functionality designed to reduce time involved in
creating, integrating, and deploying reporting solutions. Free runtime info,
new features, or free trial, at: http://www.businessobjects.com/devxi/728
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
