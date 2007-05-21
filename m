From: Greg Banks <gnb@sgi.com>
Subject: Re: [RFC,
	PATCH 9/15] knfsd: add RDMA debug class to rpc_debug bitfield
Date: Mon, 21 May 2007 14:16:18 +1000
Message-ID: <20070521041617.GG7482@sgi.com>
References: <20070521031940.GF7482@sgi.com>
	<C2767CB3.30B42%tom@opengridcomputing.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: NeilBrown <neilb@suse.de>,
	"Talpey, Thomas" <Thomas.Talpey@netapp.com>,
	Linux NFS Mailing List <nfs@lists.sourceforge.net>,
	Peter Leckie <pleckie@melbourne.sgi.com>
To: Tom Tucker <tom@opengridcomputing.com>
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.92]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1HpzJn-00055F-2p
	for nfs@lists.sourceforge.net; Sun, 20 May 2007 21:16:23 -0700
Received: from netops-testserver-4-out.sgi.com ([192.48.171.29]
	helo=relay.sgi.com) by mail.sourceforge.net with esmtp (Exim 4.44)
	id 1HpzJo-00040Q-Q6
	for nfs@lists.sourceforge.net; Sun, 20 May 2007 21:16:26 -0700
In-Reply-To: <C2767CB3.30B42%tom@opengridcomputing.com>
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

On Sun, May 20, 2007 at 10:31:15PM -0500, Tom Tucker wrote:
> 
> BTW, Chuck Lever also pointed out that we should probably have a generic
> RPCDBG_XPRT debug flag instead of RPCDBG_RDMA.

So he did.  Serves me right for not reading all my email before
replying.

> I think he's right. I think
> this should be part of the transport patchset that you're working on. Do you
> agree?

I'm a little confused as to precisely what is suggested.

Currently we have an existing RPCDBG_SVCSOCK which enables dprintks
in both the generic transport code and in the sockets-specific code
too; this is hard to separate because all the code is intermingled in
the one file svcsock.c.

If the suggestion is to have separate bits for the sockets-specific
and the generic code, then the two painful alternatives seem to be

a) splitting the sockets and generic code into separate .c files, or

b) changing half the dprintk()s in svcsock.c to dfprintks().

I wasn't planning to do either of those anytime soon; either would
be a significant change.

I think the ideal case would be a total of 3 debug bits: one for the
generic transport code, one for the sockets transport-specific code and
one for the RDMA transport-specific code.  Getting there isn't easy.

However given that the new svc_rdma* code is large and in separate
files, giving it it's own RPCDBG_RDMA bit, as you've already done,
is easy and useful and a step in the right direction.

In any case I'm happy to do whatever is necessary in the transport
patchset,  but I'd appreciate Neil's guidance on which approach he'd
prefer before I go in with the scalpel.  Neil?

Greg.
-- 
Greg Banks, R&D Software Engineer, SGI Australian Software Group.
Apparently, I'm Bedevere.  Which MPHG character are you?
I don't speak for SGI.

-------------------------------------------------------------------------
This SF.net email is sponsored by DB2 Express
Download DB2 Express C - the FREE version of DB2 express and take
control of your XML. No limits. Just data. Click to get it now.
http://sourceforge.net/powerbar/db2/
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
