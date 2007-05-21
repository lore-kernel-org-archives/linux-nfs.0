From: Neil Brown <neilb@suse.de>
Subject: Re: [RFC,
	PATCH 9/15] knfsd: add RDMA debug class to rpc_debug bitfield
Date: Mon, 21 May 2007 14:39:50 +1000
Message-ID: <18001.8854.771127.95716@notabene.brown>
References: <20070521031940.GF7482@sgi.com>
	<C2767CB3.30B42%tom@opengridcomputing.com>
	<20070521041617.GG7482@sgi.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: Linux NFS Mailing List <nfs@lists.sourceforge.net>,
	"Talpey,  Thomas" <Thomas.Talpey@netapp.com>,
	Peter Leckie <pleckie@melbourne.sgi.com>
To: Greg Banks <gnb@sgi.com>
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.91]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1Hpzgj-0007MJ-TW
	for nfs@lists.sourceforge.net; Sun, 20 May 2007 21:40:06 -0700
Received: from mx1.suse.de ([195.135.220.2])
	by mail.sourceforge.net with esmtps (TLSv1:AES256-SHA:256)
	(Exim 4.44) id 1Hpzgl-0004zI-II
	for nfs@lists.sourceforge.net; Sun, 20 May 2007 21:40:08 -0700
In-Reply-To: message from Greg Banks on Monday May 21
List-Id: "Discussion of NFS under Linux development, interoperability,
	and testing." <nfs.lists.sourceforge.net>
List-Unsubscribe: <https://lists.sourceforge.net/lists/listinfo/nfs>,
	<mailto:nfs-request@lists.sourceforge.net?subject=unsubscribe>
List-Archive: <http://sourceforge.net/mailarchive/forum.php?forum_name=nfs>
List-Post: <mailto:nfs@lists.sourceforge.net>
List-Help: <mailto:nfs-request@lists.sourceforge.net?subject=help>
List-Subscribe: <https://lists.sourceforge.net/lists/listinfo/nfs>,
	<mailto:nfs-request@lists.sourceforge.net?subject=subscribe>
Sender: nfs-bounces@lists.sourceforge.net
Errors-To: nfs-bounces@lists.sourceforge.net

On Monday May 21, gnb@sgi.com wrote:
> 
> In any case I'm happy to do whatever is necessary in the transport
> patchset,  but I'd appreciate Neil's guidance on which approach he'd
> prefer before I go in with the scalpel.  Neil?

I cannot immediately see the value in having different debug bits for
the socket transport code and the RDMA transport code.  The key
question is "When would you want to see the debugging from one, but
not from the other", and I cannot see when that would be.  Almost
certainly if you are testing one transport, you will not be using the
other, so it will not contribute any noise.

So I suspect we should simply
#define RPCDBG_FACILITY	RPCDBG_SVCSOCK

in any server-RDMA specific files, and see how we go.  If we find we
need another bit later, then we will know exactly why and be able to
make an informed decisions based on that knowledge.

Ofcouse if client and server share much code, that could be awkward.
Do they?

NeilBrown

-------------------------------------------------------------------------
This SF.net email is sponsored by DB2 Express
Download DB2 Express C - the FREE version of DB2 express and take
control of your XML. No limits. Just data. Click to get it now.
http://sourceforge.net/powerbar/db2/
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
