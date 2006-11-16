From: Neil Brown <neilb@suse.de>
Subject: Re: [PATCH 001 of 4] Copy intr and soft flags to portmap-bind
	client
Date: Thu, 16 Nov 2006 14:27:25 +1100
Message-ID: <17755.55965.786552.20142@cse.unsw.edu.au>
References: <20061024122646.4426.patches@notabene> <1061024024851.4734@suse.de>
	<76bd70e30610241605x13ae0bamdd306aee2f67d4e1@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: Olaf Kirch <okir@suse.de>, Chuck Lever <chuck.lever@oracle.com>,
	nfs@lists.sourceforge.net,
	Trond Myklebust <trond.myklebust@fys.uio.no>
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.91]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1GkXuV-00088L-RJ
	for nfs@lists.sourceforge.net; Wed, 15 Nov 2006 19:27:31 -0800
Received: from mail.suse.de ([195.135.220.2] helo=mx1.suse.de)
	by mail.sourceforge.net with esmtps (TLSv1:AES256-SHA:256)
	(Exim 4.44) id 1GkXuV-0003go-Qn
	for nfs@lists.sourceforge.net; Wed, 15 Nov 2006 19:27:33 -0800
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
> Looking at this has forced me to actually think about it  ;-)

Good :-)

> 
> Since portmapper is always a child task, I think it is safe and
> reasonable to use a "hard,intr" RPC client all the time.  The parent
> task will timeout automatically if it is a soft mount, right?  The RPC
> client should terminate the child if the parent dies.

Maybe.  Can one task timeout while a child task is active?  If it can
then 'hard' would make sense.
I guess 'intr' makes sense to and the parent would just retry, but I
would need to pour over the code again to be sure.

> 
> In any event, I think the NONPRIVPORT and NO_PING flags should be
> managed entirely within pmap_create().  No need to clutter the callers
> with that.

pmap needs a privport when registering and not when doing a lookup, so
I don't think we can get rid of all the flags.

NeilBrown

-------------------------------------------------------------------------
Take Surveys. Earn Cash. Influence the Future of IT
Join SourceForge.net's Techsay panel and you'll get the chance to share your
opinions on IT & business topics through brief surveys - and earn cash
http://www.techsay.com/default.php?page=join.php&p=sourceforge&CID=DEVDEV
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
