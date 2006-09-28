From: Neil Brown <neilb@suse.de>
Subject: Re: [PATCH 008 of 11] knfsd: Prepare knfsd for support
	of	rsize/wsize of up to 1MB, over TCP.
Date: Thu, 28 Sep 2006 13:41:27 +1000
Message-ID: <17691.17511.884028.425714@cse.unsw.edu.au>
References: <20060824162917.3600.patches@notabene> <1060824063711.5008@suse.de>
	<20060925154316.GA17465@fieldses.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: Andrew Morton <akpm@osdl.org>, nfs@lists.sourceforge.net,
	linux-kernel@vger.kernel.org, Greg Banks <gnb@melbourne.sgi.com>
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.91]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1GSmmN-0001se-Ul
	for nfs@lists.sourceforge.net; Wed, 27 Sep 2006 20:41:43 -0700
Received: from mx2.suse.de ([195.135.220.15])
	by mail.sourceforge.net with esmtps (TLSv1:AES256-SHA:256)
	(Exim 4.44) id 1GSmmM-0005eG-88
	for nfs@lists.sourceforge.net; Wed, 27 Sep 2006 20:41:44 -0700
To: "J. Bruce Fields" <bfields@fieldses.org>
In-Reply-To: message from J. Bruce Fields on Monday September 25
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

On Monday September 25, bfields@fieldses.org wrote:
> On Thu, Aug 24, 2006 at 04:37:11PM +1000, NeilBrown wrote:
> > The limit over UDP remains at 32K.  Also, make some of
> > the apparently arbitrary sizing constants clearer.
> > 
> > The biggest change here involves replacing NFSSVC_MAXBLKSIZE
> > by a function of the rqstp.  This allows it to be different
> > for different protocols (udp/tcp) and also allows it
> > to depend on the servers declared sv_bufsiz.
> > 
> > Note that we don't actually increase sv_bufsz for nfs yet.
> > That comes next.
> 
> This patch has some problems.  (Apologies for being so slow to look at
> them!)

Problems. Yes.  It makes my brain hurt for one!  We have various
things called a 'size' with some being rounded up version of others
and ... ARG.

> 
> We're reporting svc_max_payload(rqstp) as the server's maximum
> read/write block size:
> 
> > @@ -538,15 +539,16 @@ nfsd3_proc_fsinfo(struct svc_rqst * rqst
> >  					   struct nfsd3_fsinfores *resp)
> >  {
> >  	int	nfserr;
> > +	u32	max_blocksize = svc_max_payload(rqstp);
...
> 
> But svc_max_payload() usually returns sv_bufsz in the TCP case:
> 
...
> 
> That's the *total* size of the buffer for holding requests and replies.

Yes... for consistency with nfsd_create_serv, this should probably
be
   max_blocksize = svc_max_payload(rqstp) - (NFSD_BUFSIZE - NFSSVC_MAXBLKSIZE);

as (NFSD_BUFSIZE - NFSSVC_MAXBLKSIZE) have been determined to be the
maximum overhead in a read reply / write request.

> > -#define NFSD_BUFSIZE		(1024 + NFSSVC_MAXBLKSIZE)
> > +/*
> > + * Largest number of bytes we need to allocate for an NFS
> > + * call or reply.  Used to control buffer sizes.  We use
> > + * the length of v3 WRITE, READDIR and READDIR replies
> > + * which are an RPC header, up to 26 XDR units of reply
> > + * data, and some page data.
> > + *
> > + * Note that accuracy here doesn't matter too much as the
> > + * size is rounded up to a page size when allocating space.
> > + */
> 
> Is the rounding up *always* going to increase the size?  And if not,
> then why doesn't accuracy matter?
> 
> > +#define NFSD_BUFSIZE		((RPC_MAX_HEADER_WITH_AUTH+26)*XDR_UNIT + NFSSVC_MAXBLKSIZE)

Well the code in svc_init_buffer says:
	pages = 2 + (size+ PAGE_SIZE -1) / PAGE_SIZE;
So it doesn't just round up, but adds one page.  It might look like it
is adding 2 pages, but one of those is for the message in the other
direction.
It is really one page for the request, one page for the reply, and
N pages for the data.  So why do we add all that padding to
NFSD_BUFSIZE?
I'm not sure.  I think there is a good reason, but as I said - it
makes my brain hurt.

And the above comment only mentions v3.  v4 could presumably have lots
more overhead.  A 'write' could be in compound with lots of other
stuff, and if we say we can handle a 32k write, might the client send
a 40K message with 8k of UNLINK requests???

> 
> No doubt we have lots of wiggle room here, but I'd rather we didn't
> decrease that size without seeing a careful analysis.

Yes. careful analysis.  That sounds like a good idea.
I'll race you ... but I hope you win :-)

NeilBrown

-------------------------------------------------------------------------
Take Surveys. Earn Cash. Influence the Future of IT
Join SourceForge.net's Techsay panel and you'll get the chance to share your
opinions on IT & business topics through brief surveys -- and earn cash
http://www.techsay.com/default.php?page=join.php&p=sourceforge&CID=DEVDEV
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
