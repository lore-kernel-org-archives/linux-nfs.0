From: Christoph Hellwig <hch@infradead.org>
Subject: Re: Portmap - was Re: Does mountd/statd really need to listen
	on a privileged port??
Date: Tue, 24 Apr 2007 17:10:28 +0100
Message-ID: <20070424161027.GA30213@infradead.org>
References: <17958.48121.280256.493824@notabene.brown>
	<462CB496.6000308@RedHat.com>
	<17965.15503.703515.820793@notabene.brown>
	<200704240908.39672.olaf.kirch@oracle.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: Neil Brown <neilb@suse.de>, Steve Dickson <SteveD@redhat.com>,
	Matthias Koenig <mkoenig@novell.com>, nfs@lists.sourceforge.net,
	Javier Fern?ndez-Sanguino Pe?a <jfs@computer.org>, anibal@debian.org
To: Olaf Kirch <olaf.kirch@Oracle.com>
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.91]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1HgNbY-0001yi-D2
	for nfs@lists.sourceforge.net; Tue, 24 Apr 2007 09:11:01 -0700
Received: from pentafluge.infradead.org ([213.146.154.40])
	by mail.sourceforge.net with esmtp (Exim 4.44) id 1HgNbX-0007sE-Az
	for nfs@lists.sourceforge.net; Tue, 24 Apr 2007 09:11:02 -0700
In-Reply-To: <200704240908.39672.olaf.kirch@oracle.com>
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

On Tue, Apr 24, 2007 at 09:08:38AM +0200, Olaf Kirch wrote:
> On Tuesday 24 April 2007 01:09, Neil Brown wrote:
> > Is there someone "maintaining" rpcbind?  Should there be?
> > I notice there is an rpcbind at Wietse Venema's site:
> >   ftp://ftp.porcupine.org/pub/security/index.html
> > 
> > Is this rpcbind derived from that?
> 
> Bull maintains a copy of rpcbind alongside their tirpc code.
> I think both Wietse's and Bull's rpcbind implementation derive
> from the TI-RPC code released by Sun some time during the
> last millenium.
> 
> Personally, I'm very wary of the tirpc code. I think it needs a haircut
> and a thorough security audit before it can go into distributions.
> I did a very quick comparison of the tirpc code vs glibc, and
> I think there's a potential buffer overflow if a rogue rpcbind server
> replies with a string length of 0xffffffff.
> 
> The rpcb_clnt.c functions use xdr_wrapstring, which
> gives a max string size of MAX_UNSIGNED, so a string
> length of 0xffffffff would be acceptable. The subsequent malloc
> would allocate a buffer of length 0 however. Depending on
> how you link your binary, malloc may return NULL in that case
> (simple segfault), or a very small buffer - and the moment you
> start copying to that, you will corrupt the heap. This is fixed
> in glibc, but still exists in tirpc. A security audit may turn up
> more.
> 
> Apart from these concerns, the coding style is abominable - K&R
> almost everywhere; there's still a bunch of u_long's in 
> the code which makes it non-64bit-clean, and there's
> crap like
> 
> clnt_st = CLNT_CALL(client, (rpcproc_t)RPCBPROC_GETADDR,
>                     (xdrproc_t) xdr_rpcb, (char *)(void *)&parms,
>                     (xdrproc_t) xdr_wrapstring, (char *)(void *) &ua, *tp);
> 
> Those casts aren't just plain ugly, they're utterly useless too, since
> the pointer arguments to cl_call are void *.

Although not the fastes approach the only long-term viable one
would be to update the glibc rpc code for the new TIRPC APIs and
IPv6 support.  Even if it's unclear whether Uli would actually
include it that gives a better start to avoid all kinds of security
or useability-related regressions.

-------------------------------------------------------------------------
This SF.net email is sponsored by DB2 Express
Download DB2 Express C - the FREE version of DB2 express and take
control of your XML. No limits. Just data. Click to get it now.
http://sourceforge.net/powerbar/db2/
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
