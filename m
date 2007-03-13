From: Trond Myklebust <trond.myklebust@fys.uio.no>
Subject: Re: [PATCH] [RESEND] Improve idmap parallelism
Date: Mon, 12 Mar 2007 22:17:15 -0400
Message-ID: <1173752235.6428.5.camel@heimdal.trondhjem.org>
References: <1173723596.19257.12.camel@dyn9047022153>
	<1173726535.6436.58.camel@heimdal.trondhjem.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: NFS List <nfs@lists.sourceforge.net>
To: Frank Filz <ffilzlnx@us.ibm.com>
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.92]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1HQwaK-0006u2-AR
	for nfs@lists.sourceforge.net; Mon, 12 Mar 2007 19:17:56 -0700
Received: from pat.uio.no ([129.240.10.15]
	ident=[U2FsdGVkX1+jOWdvXrUfJG+8taDECkDhrEN5bOnLlR4=])
	by mail.sourceforge.net with esmtps (TLSv1:AES256-SHA:256)
	(Exim 4.44) id 1HQwaM-0001l7-13
	for nfs@lists.sourceforge.net; Mon, 12 Mar 2007 19:17:58 -0700
In-Reply-To: <1173726535.6436.58.camel@heimdal.trondhjem.org>
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

On Mon, 2007-03-12 at 15:08 -0400, Trond Myklebust wrote:
> On Mon, 2007-03-12 at 11:19 -0700, Frank Filz wrote:
> > Resend: I sent this awhile ago, but it may have been missed with the excitement of Connectathon, weddings, and honeymoons. I've verified it compiles against 2.6.21 (I originally tested it on 2.6.20).
> 
> You forgot the Linux Storage and Filesystem Workshop and FAST. It has
> been an exciting life in the past 2 months. :-)
> 
> At first glance it looks OK. I'll take it for a spin...

Hmm... Apart from having been mangled by your mailer, I immediately
started getting major complaints about scheduling under a spin lock.

Looking more closely, it seems you are holding the read lock while
calling rpc_queue_upcall(), which again will result in a call to
idmap_pipe_upcall(). That won't work since copy_to_user() is allowed to
sleep.

In addition, there were several leakages of the read lock.

Cheers
  Trond


-------------------------------------------------------------------------
Take Surveys. Earn Cash. Influence the Future of IT
Join SourceForge.net's Techsay panel and you'll get the chance to share your
opinions on IT & business topics through brief surveys-and earn cash
http://www.techsay.com/default.php?page=join.php&p=sourceforge&CID=DEVDEV
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
