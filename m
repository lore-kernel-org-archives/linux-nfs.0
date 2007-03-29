From: Trond Myklebust <trond.myklebust@fys.uio.no>
Subject: Re: RELEASE CANDIDATE - nfs-utils-1.1.0-rc1
Date: Thu, 29 Mar 2007 10:24:24 -0400
Message-ID: <1175178264.6182.9.camel@heimdal.trondhjem.org>
References: <17931.15549.578071.112573@notabene.brown>
	<20070329084433.GA1627@sith.mimuw.edu.pl>
	<17931.34669.47062.146703@notabene.brown>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: nfs@lists.sourceforge.net,
	Jan Rekorajski <baggins@sith.mimuw.edu.pl>
To: Neil Brown <neilb@suse.de>
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.91]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1HWvYI-0003xj-5p
	for nfs@lists.sourceforge.net; Thu, 29 Mar 2007 07:24:35 -0700
Received: from pat.uio.no ([129.240.10.15]
	ident=[U2FsdGVkX1/GHwhuLNkoyzudBcDHO4/8mrHbKhHi+rk=])
	by mail.sourceforge.net with esmtp (Exim 4.44) id 1HWvYJ-0000jp-7Y
	for nfs@lists.sourceforge.net; Thu, 29 Mar 2007 07:24:36 -0700
In-Reply-To: <17931.34669.47062.146703@notabene.brown>
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

On Thu, 2007-03-29 at 19:31 +1000, Neil Brown wrote:
>   - idmapd and gssd should be started before any nfs mount
>   - idmapd and svcgssd should be started before nfsd
>   - mountd should start before nfsd.
>   - sm-notify should start *after* nfsd.

...and _after_ statd. If the server is not ready to accept lock reclaim
requests, then it is wrong to be sending out sm-notify requests.

Trond


-------------------------------------------------------------------------
Take Surveys. Earn Cash. Influence the Future of IT
Join SourceForge.net's Techsay panel and you'll get the chance to share your
opinions on IT & business topics through brief surveys-and earn cash
http://www.techsay.com/default.php?page=join.php&p=sourceforge&CID=DEVDEV
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
