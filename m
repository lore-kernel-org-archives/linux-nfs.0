From: Greg Banks <gnb@sgi.com>
Subject: Re: [RFC,PATCH 8/14] knfsd: centralise SK_CLOSE handling
Date: Mon, 21 May 2007 09:56:54 +1000
Message-ID: <20070520235654.GA24779@sgi.com>
References: <20070516192509.GN9626@sgi.com>
	<17996.13702.484468.777723@notabene.brown>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: Thomas Talpey <Thomas.Talpey@netapp.com>,
	Linux NFS Mailing List <nfs@lists.sourceforge.net>,
	Peter Leckie <pleckie@melbourne.sgi.com>
To: Neil Brown <neilb@suse.de>
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.91]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1HpvGp-0006Ex-8h
	for nfs@lists.sourceforge.net; Sun, 20 May 2007 16:57:03 -0700
Received: from netops-testserver-3-out.sgi.com
	([192.48.171.28] helo=relay.sgi.com
	ident=[U2FsdGVkX19qoUmUyZRxn/qHWL8frFaDCMCBxfGE9+M=])
	by mail.sourceforge.net with esmtp (Exim 4.44) id 1HpvGr-00085N-1e
	for nfs@lists.sourceforge.net; Sun, 20 May 2007 16:57:06 -0700
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

On further thought, you were entirely right and that part of my
patch was bogus.  At that point in the code, my comments about it
being safe to call svc_delete_socket() are true for the `svsk' that
is passed in from the caller.  However the `svsk' I was passing
to svc_delete_socket() is *another* struct svc_sock which was
just chosen as a sacrificial victim, and it is *not* safe to call
svc_delete_socket() directly on that.  Woops.

The code now reads:

                if (svsk) {
                        /*
                         * Although we're always called in nfsd context,
                         * there's no guarantee that the svsk we've just
                         * chosen is not attached to a queue by sk_ready,
                         * so we cannot just svc_delete_socket() directly.
                         */
                        svc_sock_delete_bh(svsk);
                        svc_sock_put(svsk);
                }

I'm glad you caught that one.

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
