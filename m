From: Tom Tucker <tom@opengridcomputing.com>
Subject: Re: [RFC,PATCH 4/14] knfsd: has_wspace per transport
Date: Fri, 18 May 2007 08:39:00 -0500
Message-ID: <1179495540.23385.32.camel@trinity.ogc.int>
References: <20070516192211.GJ9626@sgi.com>
	<20070516211053.GE18927@fieldses.org> <20070517071202.GE27247@sgi.com>
	<17996.11983.278205.708747@notabene.brown>
	<20070518040509.GC5104@sgi.com>
	<1179495234.23385.30.camel@trinity.ogc.int>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: Neil Brown <neilb@suse.de>,
	"J. Bruce Fields" <bfields@fieldses.org>,
	Thomas Talpey <Thomas.Talpey@netapp.com>,
	Peter Leckie <pleckie@melbourne.sgi.com>,
	Linux NFS Mailing List <nfs@lists.sourceforge.net>
To: Greg Banks <gnb@sgi.com>
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.91]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1Hp2fg-0007tT-Ch
	for nfs@lists.sourceforge.net; Fri, 18 May 2007 06:39:04 -0700
Received: from rrcs-71-42-183-126.sw.biz.rr.com ([71.42.183.126]
	helo=smtp.opengridcomputing.com)
	by mail.sourceforge.net with esmtp (Exim 4.44) id 1Hp2fi-0003ez-7G
	for nfs@lists.sourceforge.net; Fri, 18 May 2007 06:39:07 -0700
In-Reply-To: <1179495234.23385.30.camel@trinity.ogc.int>
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

On Fri, 2007-05-18 at 08:33 -0500, Tom Tucker wrote:
> On Fri, 2007-05-18 at 14:05 +1000, Greg Banks wrote:
> > On Thu, May 17, 2007 at 08:30:39PM +1000, Neil Brown wrote:
> > > On Thursday May 17, gnb@sgi.com wrote:
> > > > On Wed, May 16, 2007 at 05:10:53PM -0400, J. Bruce Fields wrote:
> > > > > On Thu, May 17, 2007 at 05:22:11AM +1000, Greg Banks wrote:
> > > > > > +	set_bit(SOCK_NOSPACE, &svsk->sk_sock->flags);
> > > > > > +	if (required*2 > wspace) {
> > > > > > +		/* Don't enqueue while not enough space for reply */
> > > > > > +		dprintk("svc: socket %p  no space, %d*2 > %d, not enqueued\n",
> > > > > > +			svsk->sk_sk, required, wspace);
> > > > > > +		return 0;
> > > > > > +	}
> > > > > > +	clear_bit(SOCK_NOSPACE, &svsk->sk_sock->flags);
> > > > > > +	return 1;
> > > > > > +}
> > > > > 
> > > > > So, this is just my ignorance--why do the set and clear of SOCK_NOSPACE
> > > > > need to be ordered in the way they are?  (Why not just set once inside
> > > > > the if clause?)
> > > > 
> > > > I can't see a good reason for it, but I'm trying to minimise
> > > > perturbations to the logic.
> > > 
> > > Unfortunately, you actually perturbed the important bit... Or at
> > > least, the bit that I thought was important when I wrote it.
> > > 
> > > Previously, sk_stream_wspace(), or sock_wspace() would be called *after*
> > > SOCK_NOSPACE was set.  With your patch it is called *before*.
> > > 
> > > It is a fairly improbably race, but if the output queue flushed
> > > completely between calling XX_wspace and setting SOCK_NOSPACE, the
> > > sk_write_space callback might never get called.
> > 
> > Woops.  I'll fix that.
> > 
> > > And I gather by the fact that you test "->sko_has_wspace" that RDMA
> > > doesn't have such a function?
> > 
> > You gather correctly.
> > 
> > >  Do that mean that RDMA will never
> > > reject a write due to lack of space? 
> > 
> > No, it means that the current RDMA send code will block waiting
> > for space to become available.  That's right, nfsd threads block on
> > the network.  Steel yourself, there's worse to come.
> > 
> 
> Uh... Not really. The queue depths are designed to match credits to
> worst case reply sizes. In the normal case, it should never have to
> wait. The wait is to catch the margins in the same way that a kmalloc
> will wait for memory to become available. 

What I mean here is that the server code will wait when a kmalloc fails,
not that kmalloc itself will wait.

> 
> There's actually a stat kept by the transport that counts the number of
> times it waits.
> 
> There is a place that a wait is done in the "normal" case and that's for
> the completion of an RDMA_READ in the process of gathering the data for
> and RPC on receive. That wait happens _every_ time.
> 
> > > That seems unlikely.
> > > I would rather assume that every transport has a sko_has_wspace
> > > function... 
> > 
> > Ok, but for today the RDMA one will be
> > 
> > static int svc_rdma_has_wspace(struct svc_sock *svsk)
> > {
> > 	return 1;
> > }
> > 
> > We might be able to pull the condition in the blocking logic out
> > of svc_rdma_send() out to implement an sko_has_wspace, but there's
> > something of an impedance mismatch.  The RDMA queue limit is expressed
> > in Work Requests not bytes, and the mapping between the two is not
> > precisely visible at the point when has_wspace is called.  I guess
> > we'd have to use an upper bound.
> > Greg.
> 
> 
> -------------------------------------------------------------------------
> This SF.net email is sponsored by DB2 Express
> Download DB2 Express C - the FREE version of DB2 express and take
> control of your XML. No limits. Just data. Click to get it now.
> http://sourceforge.net/powerbar/db2/
> _______________________________________________
> NFS maillist  -  NFS@lists.sourceforge.net
> https://lists.sourceforge.net/lists/listinfo/nfs


-------------------------------------------------------------------------
This SF.net email is sponsored by DB2 Express
Download DB2 Express C - the FREE version of DB2 express and take
control of your XML. No limits. Just data. Click to get it now.
http://sourceforge.net/powerbar/db2/
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
