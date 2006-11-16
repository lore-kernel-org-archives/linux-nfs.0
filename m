From: Neil Brown <neilb@suse.de>
Subject: Re: [PATCH 003 of 4] Make RPC 'ping' requests fail more
	quickly.
Date: Thu, 16 Nov 2006 14:20:47 +1100
Message-ID: <17755.55567.747018.295618@cse.unsw.edu.au>
References: <20061024122646.4426.patches@notabene> <1061024024903.4760@suse.de>
	<1163610870.5691.177.camel@lade.trondhjem.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: Olaf Kirch <okir@suse.de>, Chuck Lever <chuck.lever@oracle.com>,
	nfs@lists.sourceforge.net
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.92]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1GkXo6-0007Ue-Jz
	for nfs@lists.sourceforge.net; Wed, 15 Nov 2006 19:20:54 -0800
Received: from cantor2.suse.de ([195.135.220.15] helo=mx2.suse.de)
	by mail.sourceforge.net with esmtps (TLSv1:AES256-SHA:256)
	(Exim 4.44) id 1GkXo6-0000UB-Ii
	for nfs@lists.sourceforge.net; Wed, 15 Nov 2006 19:20:55 -0800
To: Trond Myklebust <trond.myklebust@fys.uio.no>
In-Reply-To: message from Trond Myklebust on Wednesday November 15
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

On Wednesday November 15, trond.myklebust@fys.uio.no wrote:
> On Tue, 2006-10-24 at 12:49 +1000, NeilBrown wrote:
> > Sometimes when an RPC client is created, an initial 'PING' is sent to
> > the RPC/NULL procedure to make sure the server is running.
> > This is always done as a 'soft' call so a major timeout will be fatal.
> > 
> > We change semantics so that if portmap reports that the service does
> > not exist, or if a ECONNREFUSED error is returned we abort early
> > rather than persist for the full timeout.
> 
> What if the server is in the process of booting? If the RPC layer
> doesn't handle that case, then we will have to add a loop to sleep and
> wait in the NLM client.

What is the purpose of the PING?

It seems to me that it is intended to allow a one-time soft-fail.
e.g. it would be used when first mounting a filesystem.  If the server
isn't responding, then fail the mount, even if it is a hard mount.

Once the PING succeeds we assume the server is genuine and all future
requests follow whatever soft/hard/intr rules are given for the mount.

If this is the case, then a PING should fail as soon as there seems to
be a genuine justification for the failure, such as an rpcbind error.

NeilBrown

-------------------------------------------------------------------------
Take Surveys. Earn Cash. Influence the Future of IT
Join SourceForge.net's Techsay panel and you'll get the chance to share your
opinions on IT & business topics through brief surveys - and earn cash
http://www.techsay.com/default.php?page=join.php&p=sourceforge&CID=DEVDEV
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
