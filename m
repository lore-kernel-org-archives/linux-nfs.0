From: Greg Banks <gnb@sgi.com>
Subject: Re: [RFC, PATCH 7/14] knfsd: export svc_sock_enqueue,
	svc_sock_received
Date: Fri, 18 May 2007 18:58:55 +1000
Message-ID: <20070518085855.GL5104@sgi.com>
References: <20070516192425.GM9626@sgi.com>
	<17996.10983.101466.866944@notabene.brown>
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
	id 1HoyIj-00046B-CD
	for nfs@lists.sourceforge.net; Fri, 18 May 2007 01:59:05 -0700
Received: from netops-testserver-3-out.sgi.com
	([192.48.171.28] helo=relay.sgi.com
	ident=[U2FsdGVkX19CibTkhIi/ExFGSWQ/aOqThdT1/ZZyu5k=])
	by mail.sourceforge.net with esmtp (Exim 4.44) id 1HoyIh-0004w1-Hx
	for nfs@lists.sourceforge.net; Fri, 18 May 2007 01:59:08 -0700
In-Reply-To: <17996.10983.101466.866944@notabene.brown>
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

On Thu, May 17, 2007 at 08:13:59PM +1000, Neil Brown wrote:
> On Thursday May 17, gnb@sgi.com wrote:
> > Index: linux/net/sunrpc/sunrpc_syms.c
> > ===================================================================
> > --- linux.orig/net/sunrpc/sunrpc_syms.c	2007-04-26 13:08:32.000000000 +1000
> > +++ linux/net/sunrpc/sunrpc_syms.c	2007-05-17 02:09:47.762054713 +1000
> > @@ -77,6 +77,8 @@ EXPORT_SYMBOL(svc_process);
> >  EXPORT_SYMBOL(svc_recv);
> >  EXPORT_SYMBOL(svc_wake_up);
> >  EXPORT_SYMBOL(svc_makesock);
> > +EXPORT_SYMBOL_GPL(svc_sock_enqueue);
> > +EXPORT_SYMBOL_GPL(svc_sock_received);
> >  EXPORT_SYMBOL(svc_reserve);
> >  EXPORT_SYMBOL(svc_auth_register);
> >  EXPORT_SYMBOL(auth_domain_lookup);
> 
> Can we please put new EXPORT_SYMBOLS near the function rather than in
> this file?

Fixed, in all 3 patches which did this.

>  And if anyone wants to move them all out, I'm fine with
> that.
> 

There won't be much left of sunrpc_syms.c ;-)

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
