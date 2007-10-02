From: Tom Tucker <tom@opengridcomputing.com>
Subject: Re: [RFC,PATCH 20/35] svc: Make svc_send transport neutral
Date: Tue, 02 Oct 2007 11:46:36 -0500
Message-ID: <1191343596.1565.30.camel@trinity.ogc.int>
References: <20071001191426.3250.15371.stgit@dell3.ogc.int>
	<20071001192814.3250.76840.stgit@dell3.ogc.int>
	<F39B3C28-FF6B-4513-853F-121130E70932@oracle.com>
Reply-To: tom@opengridcomputing.com
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: neilb@suse.de, bfields@fieldses.org, nfs@lists.sourceforge.net,
	gnb@sgi.com
To: Chuck Lever <chuck.lever@oracle.com>
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.91]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1IckzL-0006qy-2j
	for nfs@lists.sourceforge.net; Tue, 02 Oct 2007 09:52:51 -0700
Received: from 209-198-142-2-host.prismnet.net ([209.198.142.2]
	helo=smtp.opengridcomputing.com)
	by mail.sourceforge.net with esmtp (Exim 4.44) id 1IckuZ-0002CO-8W
	for nfs@lists.sourceforge.net; Tue, 02 Oct 2007 09:47:56 -0700
In-Reply-To: <F39B3C28-FF6B-4513-853F-121130E70932@oracle.com>
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

On Tue, 2007-10-02 at 12:15 -0400, Chuck Lever wrote:
> On Oct 1, 2007, at 3:28 PM, Tom Tucker wrote:
> >

[...snip...]

> > -	if ((svsk = rqstp->rq_sock) == NULL) {
> > -		printk(KERN_WARNING "NULL socket pointer in %s:%d\n",
> > +	if ((xprt = rqstp->rq_xprt) == NULL) {
> > +		printk(KERN_WARNING "NULL transport pointer in %s:%d\n",
> >  				__FILE__, __LINE__);
> >  		return -EFAULT;
> >  	}
> 
> Do we still want this printk here?  Maybe it can be removed.

I don't know why it's here. Maybe replace it with a BUG_ON?

> 
> > @@ -1674,13 +1674,13 @@ svc_send(struct svc_rqst *rqstp)
> >  		xb->page_len +
> >  		xb->tail[0].iov_len;
> >
> > -	/* Grab svsk->sk_mutex to serialize outgoing data. */
> > -	mutex_lock(&svsk->sk_mutex);
> > -	if (test_bit(XPT_DEAD, &svsk->sk_xprt.xpt_flags))
> > +	/* Grab mutex to serialize outgoing data. */
> > +	mutex_lock(&xprt->xpt_mutex);
> > +	if (test_bit(XPT_DEAD, &xprt->xpt_flags))
> >  		len = -ENOTCONN;
> >  	else
> > -		len = svsk->sk_xprt.xpt_ops.xpo_sendto(rqstp);
> > -	mutex_unlock(&svsk->sk_mutex);
> > +		len = xprt->xpt_ops.xpo_sendto(rqstp);
> > +	mutex_unlock(&xprt->xpt_mutex);
> >  	svc_sock_release(rqstp);
> >
> >  	if (len == -ECONNREFUSED || len == -ENOTCONN || len == -EAGAIN)
> > @@ -1782,7 +1782,6 @@ static struct svc_sock *svc_setup_socket
> >  	svsk->sk_lastrecv = get_seconds();
> >  	spin_lock_init(&svsk->sk_lock);
> >  	INIT_LIST_HEAD(&svsk->sk_deferred);
> > -	mutex_init(&svsk->sk_mutex);
> >
> >  	/* Initialize the socket */
> >  	if (sock->type == SOCK_DGRAM)
> 
> Chuck Lever
> chuck.lever@oracle.com
> 
> 


-------------------------------------------------------------------------
This SF.net email is sponsored by: Microsoft
Defy all challenges. Microsoft(R) Visual Studio 2005.
http://clk.atdmt.com/MRT/go/vse0120000070mrt/direct/01/
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
