From: Trond Myklebust <trond.myklebust@fys.uio.no>
Subject: Re: [PATCH 001 of 4] Copy intr and soft flags to	portmap-bind
	client
Date: Wed, 15 Nov 2006 12:11:29 -0500
Message-ID: <1163610689.5691.174.camel@lade.trondhjem.org>
References: <20061024122646.4426.patches@notabene> <1061024024851.4734@suse.de>
	<76bd70e30610241605x13ae0bamdd306aee2f67d4e1@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: NeilBrown <neilb@suse.de>, Olaf Kirch <okir@suse.de>,
	Chuck Lever <chuck.lever@oracle.com>, nfs@lists.sourceforge.net
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.92]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1GkOIs-0006Bv-1B
	for nfs@lists.sourceforge.net; Wed, 15 Nov 2006 09:12:02 -0800
Received: from pat.uio.no ([129.240.10.15]
	ident=[U2FsdGVkX19PjRXMymaPenAYb5tBTc4JVN6G3V3CGHU=])
	by mail.sourceforge.net with esmtps (TLSv1:AES256-SHA:256)
	(Exim 4.44) id 1GkOIr-0004R2-P6
	for nfs@lists.sourceforge.net; Wed, 15 Nov 2006 09:12:03 -0800
To: Chuck Lever <chucklever@gmail.com>
In-Reply-To: <76bd70e30610241605x13ae0bamdd306aee2f67d4e1@mail.gmail.com>
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

On Tue, 2006-10-24 at 16:05 -0700, Chuck Lever wrote:
> Looking at this has forced me to actually think about it  ;-)
> 
> Since portmapper is always a child task, I think it is safe and
> reasonable to use a "hard,intr" RPC client all the time.  The parent
> task will timeout automatically if it is a soft mount, right?  The RPC
> client should terminate the child if the parent dies.

...or to set it to always be soft. The main problem with that might be
nfsroot.

Hmm... Looking at that code, though there is something that bothers me.
Why are we calling pmap_wake_portmap_waiters every time the call to
xprt_test_and_set_binding(xprt)!=0? That looks like a nasty bug.

Trond


-------------------------------------------------------------------------
Take Surveys. Earn Cash. Influence the Future of IT
Join SourceForge.net's Techsay panel and you'll get the chance to share your
opinions on IT & business topics through brief surveys - and earn cash
http://www.techsay.com/default.php?page=join.php&p=sourceforge&CID=DEVDEV
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
