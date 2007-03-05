From: Neil Brown <neilb@suse.de>
Subject: Re: Possible causes for rpc.mountd consuming 100 percent CPU.
Date: Mon, 5 Mar 2007 14:25:30 +1100
Message-ID: <17899.36266.588801.465727@notabene.brown>
References: <a6a251db0703041747l6e539890v7496b616aa8d5cc8@mail.gmail.com>
	<17899.31457.535979.478100@notabene.brown>
	<a6a251db0703041812h7bd3e771q690e30cc789189e0@mail.gmail.com>
	<17899.35209.373099.331797@notabene.brown>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
To: "Matt Proud" <matt.proud.list@gmail.com>,
	nfs@lists.sourceforge.net
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.92]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1HO3qW-00010m-SE
	for nfs@lists.sourceforge.net; Sun, 04 Mar 2007 19:26:45 -0800
Received: from mx2.suse.de ([195.135.220.15])
	by mail.sourceforge.net with esmtps (TLSv1:AES256-SHA:256)
	(Exim 4.44) id 1HO3qX-0007zR-Fi
	for nfs@lists.sourceforge.net; Sun, 04 Mar 2007 19:26:47 -0800
In-Reply-To: message from Neil Brown on Monday March 5
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

On Monday March 5, neilb@suse.de wrote:
> 
> Ho hum.  Time to set a bug report off to glibc...

Looks like this has already been fixed. 

2005-11-03  Roland McGrath  <roland@redhat.com>

        [BZ #1548]
        * sunrpc/svc.c (svc_getreqset): Use ffsl instead of ffs on fd_mask,
        make sure constant is long.
        From Jay Lan <jlan@engr.sgi.com>.

So it is fixed in glibc 2.4 and later which SuSE and RH ship, but not
in 2.3.6 which Debian and Ubuntu ship.

I wonder how hard it would be to autodetect the libc version and
include a fix in nfs-utils if an old glibc were in use.....

NeilBrown


-------------------------------------------------------------------------
Take Surveys. Earn Cash. Influence the Future of IT
Join SourceForge.net's Techsay panel and you'll get the chance to share your
opinions on IT & business topics through brief surveys-and earn cash
http://www.techsay.com/default.php?page=join.php&p=sourceforge&CID=DEVDEV
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
