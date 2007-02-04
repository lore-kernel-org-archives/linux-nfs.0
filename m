From: "J. Bruce Fields" <bfields@fieldses.org>
Subject: Re: [PATCH 9/14] lockd: handle fl_notify callbacks
Date: Sat, 3 Feb 2007 21:10:44 -0500
Message-ID: <20070204021044.GK7588@fieldses.org>
References: <6f2a40ca33ea2b58e3f515bea9be1e0fa8cda6aa.1170479265.git.bfields@citi.umich.edu>
	<1170549605.5749.5.camel@lade.trondhjem.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: linux-fsdevel@vger.kernel.org, nfs@lists.sourceforge.net,
	Marc Eshel <eshel@almaden.ibm.com>
To: Trond Myklebust <trond.myklebust@fys.uio.no>
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.91]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1HDWq9-0007g9-2p
	for nfs@lists.sourceforge.net; Sat, 03 Feb 2007 18:10:49 -0800
Received: from mail.fieldses.org ([66.93.2.214] helo=fieldses.org)
	by mail.sourceforge.net with esmtp (Exim 4.44) id 1HDWq9-0005pi-P7
	for nfs@lists.sourceforge.net; Sat, 03 Feb 2007 18:10:51 -0800
In-Reply-To: <1170549605.5749.5.camel@lade.trondhjem.org>
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

On Sat, Feb 03, 2007 at 04:40:05PM -0800, Trond Myklebust wrote:
> On Sat, 2007-02-03 at 00:34 -0500, J. Bruce Fields wrote:
> >  nlmsvc_notify_blocked(struct file_lock *fl, struct file_lock *conf, int result)
> >  {
> >  	struct nlm_block	*block;
> > +	int rc = -ENOENT;
> >  
> >  	dprintk("lockd: nlmsvc_notify_blocked lock %p conf %p result %d\n",
> >  							fl, conf, result);
> > +	lock_kernel();
> >  	list_for_each_entry(block, &nlm_blocked, b_list) {
> >  		if (nlm_compare_locks(&block->b_call->a_args.lock.fl, fl)) {
> > +			dprintk("lockd: nlmsvc_notify_blocked block %p flags %d\n",
> > +							block, block->b_flags);
> > +			if (block->b_flags & B_QUEUED) {
> > +				if (block->b_flags & B_TOO_LATE) {
> > +					rc = -ENOLCK;
> > +					break;
> > +				}
> > +				nlmsvc_update_deferred_block(block, conf, result);
> 
> but nlmsvc_update_deferred_block() can sleep!

Yep, you're right.  Fortunately, the only reason it sleeps is a single
allocation that's probably easy enough to do elsewhere, which I believe
would fix this:

> How are you protecting against races with notification? Also, how are
> you guaranteeing that the block queue won't change underneath you when
> you lose the BKL.

--b.

-------------------------------------------------------------------------
Using Tomcat but need to do more? Need to support web services, security?
Get stuff done quickly with pre-integrated technology to make your job easier.
Download IBM WebSphere Application Server v.1.0.1 based on Apache Geronimo
http://sel.as-us.falkag.net/sel?cmd=lnk&kid=120709&bid=263057&dat=121642
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
