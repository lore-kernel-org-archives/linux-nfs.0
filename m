From: Greg Banks <gnb@sgi.com>
Subject: Re: [RFC,PATCH 8/14] knfsd: centralise SK_CLOSE handling
Date: Fri, 18 May 2007 16:36:14 +1000
Message-ID: <20070518063614.GH5104@sgi.com>
References: <20070516192509.GN9626@sgi.com>
	<17996.13702.484468.777723@notabene.brown>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: Thomas Talpey <Thomas.Talpey@netapp.com>,
	Linux NFS Mailing List <nfs@lists.sourceforge.net>,
	Peter Leckie <pleckie@melbourne.sgi.com>
To: Neil Brown <neilb@suse.de>
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.92]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1How4a-00067j-Nt
	for nfs@lists.sourceforge.net; Thu, 17 May 2007 23:36:21 -0700
Received: from netops-testserver-3-out.sgi.com
	([192.48.171.28] helo=relay.sgi.com
	ident=[U2FsdGVkX18TjZH6BbuIJAEzw84V8AiuHnoXdR96fPE=])
	by mail.sourceforge.net with esmtp (Exim 4.44) id 1How4c-0005za-7t
	for nfs@lists.sourceforge.net; Thu, 17 May 2007 23:36:23 -0700
In-Reply-To: <17996.13702.484468.777723@notabene.brown>
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

On Thu, May 17, 2007 at 08:59:18PM +1000, Neil Brown wrote:
> On Thursday May 17, gnb@sgi.com wrote:
> > 
> > Centralise the handling of the SK_CLOSE bit to that future
> > sunrpc server transport implementations will be easier to
> > write correctly.  The bit should now not be manipulated
> > directly, inline exist to wrap that.  Also, the sko_recvfrom
> > method does not need to check for SK_CLOSE anymore, that's
> > handled in core code.
> ...
> >  
> >  		if (svsk) {
> > -			svc_sock_enqueue(svsk);
> > +			/*
> > +			 * We're always called in nfsd context so we
> > +			 * don't have to muck around with SK_CLOSE.
> > +			 */
> > +			svc_delete_socket(svsk);
> >  			svc_sock_put(svsk);
> >  		}
> 
> I'm not convinced that this is right.  

I believe it is right, but I'll admit it's not obvious enough ;-)

> svc_delete_socket has a comment:
> 	/*
> 	 * We used to delete the svc_sock from whichever list
> 	 * it's sk_ready node was on, but we don't actually
> 	 * need to.  This is because the only time we're called
> 	 * while still attached to a queue, the queue itself
> 	 * is about to be destroyed (in svc_destroy).
> 	 */
> and I think this change invalidate the premise of that comment.

The hunk above, which now calls svc_delete_socket() directly,
is in svc_tcp_accept(), which is only ever called from svc_recv()
*after* the svc_sock has been dequeued from the pool.  At this
point the svc_sock is not attached to a queue by sk_ready.  So
the premise of the comment is still valid.

I'll improve the comment to read:

			/*
			 * We're always called in nfsd context when not
			 * attached to a queue by sk_ready, so can call
			 * svc_delete_socket() directly and not have to
			 * muck around with SK_CLOSE.
			 */


BTW, I have a patch that moves that code out of svc_tcp_accept()
into more generic code, so that RDMA connection transports are also
subject to a connection limit.  Coming soon.

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
