From: Neil Brown <neilb@suse.de>
Subject: Re: [PATCH 0/4] gssd updates
Date: Mon, 19 Mar 2007 09:48:18 +1100
Message-ID: <17917.49586.711520.490818@notabene.brown>
References: <20070316141826.6349.9988.stgit@RoCk.CiTi.UmIcH.EdU>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: nfs@lists.sourceforge.net
To: Kevin Coffman <kwc@citi.umich.edu>
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.92]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1HT4Av-0007Up-Sb
	for nfs@lists.sourceforge.net; Sun, 18 Mar 2007 15:48:29 -0700
Received: from mx1.suse.de ([195.135.220.2])
	by mail.sourceforge.net with esmtps (TLSv1:AES256-SHA:256)
	(Exim 4.44) id 1HT4At-00033X-9q
	for nfs@lists.sourceforge.net; Sun, 18 Mar 2007 15:48:27 -0700
In-Reply-To: message from Kevin Coffman on Friday March 16
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

On Friday March 16, kwc@citi.umich.edu wrote:
> 1/4 Cleans up a minor memory leak while processing the keytab.
> 2/4 Adds a new "-n" option to specify that machine credentials
>     should not be used for all root accesses.
> 3/4 No longer limits machine credentials to only "nfs/<hostname>".
>     Any key in the keytab (i.e. "host/<hostname>") can be used for
>     machine credentials.
> 4/4 Creates separate paths for the base pipefs directory and the
>     nfs subdirectory.  This is needed by future changes.

Complete with man-page updates - excellent!

Applied - thanks.

NeilBrown

-------------------------------------------------------------------------
Take Surveys. Earn Cash. Influence the Future of IT
Join SourceForge.net's Techsay panel and you'll get the chance to share your
opinions on IT & business topics through brief surveys-and earn cash
http://www.techsay.com/default.php?page=join.php&p=sourceforge&CID=DEVDEV
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
