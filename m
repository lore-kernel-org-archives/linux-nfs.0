From: Neil Brown <neilb@suse.de>
Subject: Re: PROBLEM: kernel nfsd does not log disk reads in system
	stats
Date: Fri, 16 Mar 2007 11:38:49 +1100
Message-ID: <17913.59161.456303.630877@notabene.brown>
References: <56d259a00703130901v3cf27269sf37c3e352eb6e9d7@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: nfs@lists.sourceforge.net
To: "Martin Guy" <martinwguy@yahoo.it>
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.92]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1HS0T8-0003iK-Rd
	for nfs@lists.sourceforge.net; Thu, 15 Mar 2007 17:38:54 -0700
Received: from mx2.suse.de ([195.135.220.15])
	by mail.sourceforge.net with esmtps (TLSv1:AES256-SHA:256)
	(Exim 4.44) id 1HS0T9-00066P-J4
	for nfs@lists.sourceforge.net; Thu, 15 Mar 2007 17:38:57 -0700
In-Reply-To: message from Martin Guy on Tuesday March 13
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

On Tuesday March 13, martinwguy@yahoo.it wrote:
> [1.] kernel nfsd does not log disk reads in system stats
> [2.] When intensive reads are happening on an NFS-mounted volume, the
> system activity stats for disk reads remain zero.

Seems unlikely....

> [5.] Compiling a source tree in an nfs-mounted volume, the output of
> "vmstat" shows zero disk reads, though a high number of disk writes is
> registered, and gkrellm system monitor shows the same info

Could it be that the clients have the tree in cache so no read is
needed?
Or maybe the server has it in cache, and again no read to disk is
needed.

Try unmounting on the client and the server, then remounting, then run
the compile.  I'm fairly sure you will see plenty of reads then.

NeilBrown

-------------------------------------------------------------------------
Take Surveys. Earn Cash. Influence the Future of IT
Join SourceForge.net's Techsay panel and you'll get the chance to share your
opinions on IT & business topics through brief surveys-and earn cash
http://www.techsay.com/default.php?page=join.php&p=sourceforge&CID=DEVDEV
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
