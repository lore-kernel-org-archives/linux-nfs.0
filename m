From: Neil Brown <neilb@suse.de>
Subject: Re: [RFC,PATCH 4/14] knfsd: has_wspace per transport
Date: Thu, 17 May 2007 20:30:39 +1000
Message-ID: <17996.11983.278205.708747@notabene.brown>
References: <20070516192211.GJ9626@sgi.com>
	<20070516211053.GE18927@fieldses.org>
	<20070517071202.GE27247@sgi.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: "J. Bruce Fields" <bfields@fieldses.org>,
	Linux NFS Mailing List <nfs@lists.sourceforge.net>,
	Thomas Talpey <Thomas.Talpey@netapp.com>,
	Peter Leckie <pleckie@melbourne.sgi.com>
To: Greg Banks <gnb@sgi.com>
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.91]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1HodG4-0002p4-R9
	for nfs@lists.sourceforge.net; Thu, 17 May 2007 03:30:56 -0700
Received: from cantor2.suse.de ([195.135.220.15] helo=mx2.suse.de)
	by mail.sourceforge.net with esmtps (TLSv1:AES256-SHA:256)
	(Exim 4.44) id 1HodG6-0002a9-Vh
	for nfs@lists.sourceforge.net; Thu, 17 May 2007 03:30:59 -0700
In-Reply-To: message from Greg Banks on Thursday May 17
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

On Thursday May 17, gnb@sgi.com wrote:
> On Wed, May 16, 2007 at 05:10:53PM -0400, J. Bruce Fields wrote:
> > On Thu, May 17, 2007 at 05:22:11AM +1000, Greg Banks wrote:
> > > +	set_bit(SOCK_NOSPACE, &svsk->sk_sock->flags);
> > > +	if (required*2 > wspace) {
> > > +		/* Don't enqueue while not enough space for reply */
> > > +		dprintk("svc: socket %p  no space, %d*2 > %d, not enqueued\n",
> > > +			svsk->sk_sk, required, wspace);
> > > +		return 0;
> > > +	}
> > > +	clear_bit(SOCK_NOSPACE, &svsk->sk_sock->flags);
> > > +	return 1;
> > > +}
> > 
> > So, this is just my ignorance--why do the set and clear of SOCK_NOSPACE
> > need to be ordered in the way they are?  (Why not just set once inside
> > the if clause?)
> 
> I can't see a good reason for it, but I'm trying to minimise
> perturbations to the logic.

Unfortunately, you actually perturbed the important bit... Or at
least, the bit that I thought was important when I wrote it.

Previously, sk_stream_wspace(), or sock_wspace() would be called *after*
SOCK_NOSPACE was set.  With your patch it is called *before*.

It is a fairly improbably race, but if the output queue flushed
completely between calling XX_wspace and setting SOCK_NOSPACE, the
sk_write_space callback might never get called.
I wonder if we need a memory barrier to ensure that this actually works.??

So I think that code needs to be rearranged a bit, and maybe
commented, in case I don't remember next time :-)

And I gather by the fact that you test "->sko_has_wspace" that RDMA
doesn't have such a function?  Do that mean that RDMA will never
reject a write due to lack of space?  That seems unlikely.
I would rather assume that every transport has a sko_has_wspace
function... 

NeilBrown

-------------------------------------------------------------------------
This SF.net email is sponsored by DB2 Express
Download DB2 Express C - the FREE version of DB2 express and take
control of your XML. No limits. Just data. Click to get it now.
http://sourceforge.net/powerbar/db2/
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
