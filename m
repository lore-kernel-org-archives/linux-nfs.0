From: Neil Brown <neilb@suse.de>
Subject: Re: [PATCH 002 of 4] Make the initial RPC PING interruptible.
Date: Thu, 16 Nov 2006 14:22:11 +1100
Message-ID: <17755.55651.988725.653072@cse.unsw.edu.au>
References: <20061024122646.4426.patches@notabene> <1061024024857.4748@suse.de>
	<76bd70e30610241619m545c5a33k4ee4b156464ef41d@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: Olaf Kirch <okir@suse.de>, Chuck Lever <chuck.lever@oracle.com>,
	nfs@lists.sourceforge.net,
	Trond Myklebust <trond.myklebust@fys.uio.no>
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.92]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1GkXpQ-0007g5-P1
	for nfs@lists.sourceforge.net; Wed, 15 Nov 2006 19:22:19 -0800
Received: from cantor.suse.de ([195.135.220.2] helo=mx1.suse.de)
	by mail.sourceforge.net with esmtps (TLSv1:AES256-SHA:256)
	(Exim 4.44) id 1GkXpQ-0000uf-IP
	for nfs@lists.sourceforge.net; Wed, 15 Nov 2006 19:22:18 -0800
To: "Chuck Lever" <chucklever@gmail.com>
In-Reply-To: message from Chuck Lever on Tuesday October 24
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

On Tuesday October 24, chucklever@gmail.com wrote:
> What's the harm in always using SOFT|INTR for doing pings?
> 
> I would think this would be a bit cleaner if you just eliminated the
> "flags" parameter of rpc_ping() and calculated the correct task flags
> inside rpc_ping().

Yes, that sounds right.

Thanks,

NeilBrown

-------------------------------------------------------------------------
Take Surveys. Earn Cash. Influence the Future of IT
Join SourceForge.net's Techsay panel and you'll get the chance to share your
opinions on IT & business topics through brief surveys - and earn cash
http://www.techsay.com/default.php?page=join.php&p=sourceforge&CID=DEVDEV
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
