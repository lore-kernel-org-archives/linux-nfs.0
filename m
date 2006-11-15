From: Trond Myklebust <trond.myklebust@fys.uio.no>
Subject: Re: [PATCH 003 of 4] Make RPC 'ping' requests fail more
	quickly.
Date: Wed, 15 Nov 2006 12:14:30 -0500
Message-ID: <1163610870.5691.177.camel@lade.trondhjem.org>
References: <20061024122646.4426.patches@notabene> <1061024024903.4760@suse.de>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: Olaf Kirch <okir@suse.de>, Chuck Lever <chuck.lever@oracle.com>,
	nfs@lists.sourceforge.net
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.91]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1GkOLk-0006VP-Qk
	for nfs@lists.sourceforge.net; Wed, 15 Nov 2006 09:15:01 -0800
Received: from pat.uio.no ([129.240.10.15]
	ident=[U2FsdGVkX1/eFJU9j3w6AOYShclcPNaonZfjOg8KGBY=])
	by mail.sourceforge.net with esmtps (TLSv1:AES256-SHA:256)
	(Exim 4.44) id 1GkOLj-0005NS-MS
	for nfs@lists.sourceforge.net; Wed, 15 Nov 2006 09:15:02 -0800
To: NeilBrown <neilb@suse.de>
In-Reply-To: <1061024024903.4760@suse.de>
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

On Tue, 2006-10-24 at 12:49 +1000, NeilBrown wrote:
> Sometimes when an RPC client is created, an initial 'PING' is sent to
> the RPC/NULL procedure to make sure the server is running.
> This is always done as a 'soft' call so a major timeout will be fatal.
> 
> We change semantics so that if portmap reports that the service does
> not exist, or if a ECONNREFUSED error is returned we abort early
> rather than persist for the full timeout.

What if the server is in the process of booting? If the RPC layer
doesn't handle that case, then we will have to add a loop to sleep and
wait in the NLM client.

Cheers
  Trond


-------------------------------------------------------------------------
Take Surveys. Earn Cash. Influence the Future of IT
Join SourceForge.net's Techsay panel and you'll get the chance to share your
opinions on IT & business topics through brief surveys - and earn cash
http://www.techsay.com/default.php?page=join.php&p=sourceforge&CID=DEVDEV
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
