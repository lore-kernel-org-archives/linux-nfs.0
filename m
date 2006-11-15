From: "Chuck Lever" <chucklever@gmail.com>
Subject: Re: [PATCH 001 of 4] Copy intr and soft flags to portmap-bind
	client
Date: Wed, 15 Nov 2006 16:14:23 -0500
Message-ID: <76bd70e30611151314w1f0f2cb3y2d27133bf917ee8a@mail.gmail.com>
References: <20061024122646.4426.patches@notabene> <1061024024851.4734@suse.de>
	<76bd70e30610241605x13ae0bamdd306aee2f67d4e1@mail.gmail.com>
	<1163610689.5691.174.camel@lade.trondhjem.org>
	<76bd70e30611151138p1b41c85as5b954ed886051ff2@mail.gmail.com>
	<1163622686.5880.1.camel@lade.trondhjem.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: NeilBrown <neilb@suse.de>, Olaf Kirch <okir@suse.de>,
	Chuck Lever <chuck.lever@oracle.com>, nfs@lists.sourceforge.net
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.92]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1GkS5Z-00077f-0W
	for nfs@lists.sourceforge.net; Wed, 15 Nov 2006 13:14:33 -0800
Received: from ug-out-1314.google.com ([66.249.92.174])
	by mail.sourceforge.net with esmtp (Exim 4.44) id 1GkS5Y-0003VN-VF
	for nfs@lists.sourceforge.net; Wed, 15 Nov 2006 13:14:34 -0800
Received: by ug-out-1314.google.com with SMTP id z38so245892ugc
	for <nfs@lists.sourceforge.net>; Wed, 15 Nov 2006 13:14:23 -0800 (PST)
To: "Trond Myklebust" <trond.myklebust@fys.uio.no>
In-Reply-To: <1163622686.5880.1.camel@lade.trondhjem.org>
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

On 11/15/06, Trond Myklebust <trond.myklebust@fys.uio.no> wrote:
> On Wed, 2006-11-15 at 14:38 -0500, Chuck Lever wrote:
> > > Hmm... Looking at that code, though there is something that bothers me.
> > > Why are we calling pmap_wake_portmap_waiters every time the call to
> > > xprt_test_and_set_binding(xprt)!=0? That looks like a nasty bug.
> >
> > Well the idea is to make sure the task isn't left on the binding queue
> > if pmap_getport can't actually queue an rpcbind request.   I don't
> > think it should be waking up all waiters, though -- that part is
> > probably wrong.
>
> It shouldn't be waking anybody up if it just failed because a portmapper
> request has already been created. In that case, it should just sleep and
> wait for the request to finish.

OK, agreed.  That logic should just set task->tk_status to -EACESS and return.

Waking up all waiters after bailout_nofree: is still excessive, though.

-- 
"We who cut mere stones must always be envisioning cathedrals"
   -- Quarry worker's creed

-------------------------------------------------------------------------
Take Surveys. Earn Cash. Influence the Future of IT
Join SourceForge.net's Techsay panel and you'll get the chance to share your
opinions on IT & business topics through brief surveys - and earn cash
http://www.techsay.com/default.php?page=join.php&p=sourceforge&CID=DEVDEV
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
