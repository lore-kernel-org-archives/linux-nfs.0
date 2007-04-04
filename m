From: Olaf Kirch <okir@lst.de>
Subject: Re: lockd and statd
Date: Wed, 4 Apr 2007 19:33:26 +0200
Message-ID: <200704041933.27315.okir@lst.de>
References: <57bc13580704040011u3058e6d9wd0d4fc0de63d4d93@mail.gmail.com>
	<1175690426.6118.6.camel@heimdal.trondhjem.org>
	<57bc13580704040909o386259f1q84367459ce555671@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
To: nfs@lists.sourceforge.net
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.92]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1HZ9Ma-0005nX-8G
	for nfs@lists.sourceforge.net; Wed, 04 Apr 2007 10:33:40 -0700
Received: from verein.lst.de ([213.95.11.210] helo=mail.lst.de)
	by mail.sourceforge.net with esmtps (TLSv1:DES-CBC3-SHA:168)
	(Exim 4.44) id 1HZ9Mb-0002tK-6o
	for nfs@lists.sourceforge.net; Wed, 04 Apr 2007 10:33:42 -0700
Received: from [192.168.5.32] (p54A7F40A.dip.t-dialin.net [84.167.244.10])
	(authenticated bits=0)
	by mail.lst.de (8.12.3/8.12.3/Debian-7.1) with ESMTP id l34HXhLD029534
	(version=TLSv1/SSLv3 cipher=EXP1024-RC4-SHA bits=56 verify=NO)
	for <nfs@lists.sourceforge.net>; Wed, 4 Apr 2007 19:33:44 +0200
In-Reply-To: <57bc13580704040909o386259f1q84367459ce555671@mail.gmail.com>
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

On Wednesday 04 April 2007 18:09, Greg Bradner wrote:
> That's what I thought.  But it doesn't seem to be the case with SUSE 9.3:

Suse uses a patch that puts statd functionality into the kernel.
So when you switch to a non-Suse kernel, you also need to compile
and install rpc.statd manually - and frob your init scripts so that it gets
started.

Olaf
-- 
Olaf Kirch  |  --- o --- Nous sommes du soleil we love when we play
okir@lst.de |    / | \   sol.dhoop.naytheet.ah kin.ir.samse.qurax

-------------------------------------------------------------------------
Take Surveys. Earn Cash. Influence the Future of IT
Join SourceForge.net's Techsay panel and you'll get the chance to share your
opinions on IT & business topics through brief surveys-and earn cash
http://www.techsay.com/default.php?page=join.php&p=sourceforge&CID=DEVDEV
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
