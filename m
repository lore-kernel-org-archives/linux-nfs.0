From: Olaf Kirch <okir@suse.de>
Subject: Re: Please remove getkversion
Date: Thu, 4 Jan 2007 16:41:34 +0100
Message-ID: <20070104154134.GA29909@suse.de>
References: <20070104134504.GA31206@uio.no>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: nfs@lists.sourceforge.net
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.91]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1H2Uir-0001tw-N9
	for nfs@lists.sourceforge.net; Thu, 04 Jan 2007 07:41:42 -0800
Received: from ns1.suse.de ([195.135.220.2] helo=mx1.suse.de)
	by mail.sourceforge.net with esmtps (TLSv1:AES256-SHA:256)
	(Exim 4.44) id 1H2Uis-0004We-2H
	for nfs@lists.sourceforge.net; Thu, 04 Jan 2007 07:41:43 -0800
To: "Steinar H. Gunderson" <sgunderson@bigfoot.com>
In-Reply-To: <20070104134504.GA31206@uio.no>
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

On Thu, Jan 04, 2007 at 02:45:05PM +0100, Steinar H. Gunderson wrote:
> getkversion fails when building against newer kernel headers, since
> UTS_RELEASE is no longer exported to userspace (nor is there any adequate
> replacement that I know of). This has already hit Ubuntu (making nfs-utils
> not build anymore), so they've simply stopped building it -- we're doing so
> in Debian as well, as we'll probably hit the same problems, and getkversion
> isn't really in use anyhow.

Given that it was a hack to start with, I'm suprised it has
been building for that long :)

Olaf
-- 
Olaf Kirch   |  --- o --- Nous sommes du soleil we love when we play
okir@suse.de |    / | \   sol.dhoop.naytheet.ah kin.ir.samse.qurax

-------------------------------------------------------------------------
Take Surveys. Earn Cash. Influence the Future of IT
Join SourceForge.net's Techsay panel and you'll get the chance to share your
opinions on IT & business topics through brief surveys - and earn cash
http://www.techsay.com/default.php?page=join.php&p=sourceforge&CID=DEVDEV
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
