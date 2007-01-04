From: "Steinar H. Gunderson" <sgunderson@bigfoot.com>
Subject: Re: [PATCH] fix rpc.gssd -d
Date: Fri, 5 Jan 2007 00:51:40 +0100
Message-ID: <20070104235140.GA5288@uio.no>
References: <20070104194625.GA3000@uio.no>
	<4d569c330701041254m5a1fc1aem17a9eaadcbeaadfb@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: nfs@lists.sourceforge.net
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.91]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1H2cMS-0005YW-GZ
	for nfs@lists.sourceforge.net; Thu, 04 Jan 2007 15:51:04 -0800
Received: from cassarossa.samfundet.no ([129.241.93.19] ident=Debian-exim)
	by mail.sourceforge.net with esmtps (TLSv1:AES256-SHA:256)
	(Exim 4.44) id 1H2cMS-0004kd-PE
	for nfs@lists.sourceforge.net; Thu, 04 Jan 2007 15:51:06 -0800
To: Kevin Coffman <kwc@citi.umich.edu>
In-Reply-To: <4d569c330701041254m5a1fc1aem17a9eaadcbeaadfb@mail.gmail.com>
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

On Thu, Jan 04, 2007 at 03:54:05PM -0500, Kevin Coffman wrote:
> Thanks Steinar.  I'll get to this and the AM_MAINTAINER_MODE patch
> soon and resend them to Neil.  (Your other recent patches are out of
> my arena.)

Thanks.

By the way, I checked out the git repository (finding out the URL was
non-trivial, though!) and discovered that the bzero patch was not applied (I
believe it was sent in quite a while ago). Neil, did you forget, is it in
a queue somewhere, or did I just check out the wrong one? (I used
git://git.linux-nfs.org/pub/linux/nfs-utils/.)

/* Steinar */
-- 
Homepage: http://www.sesse.net/

-------------------------------------------------------------------------
Take Surveys. Earn Cash. Influence the Future of IT
Join SourceForge.net's Techsay panel and you'll get the chance to share your
opinions on IT & business topics through brief surveys - and earn cash
http://www.techsay.com/default.php?page=join.php&p=sourceforge&CID=DEVDEV
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
