From: Tom Tucker <tom@opengridcomputing.com>
Subject: Re: [RFC,
	PATCH 13/35] svc: Change services to use new	svc_create_xprt service
Date: Tue, 09 Oct 2007 13:32:18 -0500
Message-ID: <1191954738.30309.60.camel@trinity.ogc.int>
References: <20071001191426.3250.15371.stgit@dell3.ogc.int>
	<20071001192758.3250.2651.stgit@dell3.ogc.int>
	<20071009170923.GH22750@fieldses.org>
Reply-To: tom@opengridcomputing.com
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: neilb@suse.de, nfs@lists.sourceforge.net, aglo@citi.umich.edu,
	gnb@sgi.com
To: "J. Bruce Fields" <bfields@fieldses.org>
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.92]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1IfJtf-0000XO-Ru
	for nfs@lists.sourceforge.net; Tue, 09 Oct 2007 11:33:35 -0700
Received: from 209-198-142-2-host.prismnet.net ([209.198.142.2]
	helo=smtp.opengridcomputing.com)
	by mail.sourceforge.net with esmtp (Exim 4.44) id 1IfJtk-0003V6-R2
	for nfs@lists.sourceforge.net; Tue, 09 Oct 2007 11:33:41 -0700
In-Reply-To: <20071009170923.GH22750@fieldses.org>
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

On Tue, 2007-10-09 at 13:09 -0400, J. Bruce Fields wrote:
> On Mon, Oct 01, 2007 at 02:27:59PM -0500, Tom Tucker wrote:
> > diff --git a/fs/nfs/callback.c b/fs/nfs/callback.c
> > index a796be5..e27ca14 100644
> > --- a/fs/nfs/callback.c
> > +++ b/fs/nfs/callback.c
> > @@ -123,8 +123,8 @@ int nfs_callback_up(void)
> >  	if (!serv)
> >  		goto out_err;
> >  
> > -	ret = svc_makesock(serv, IPPROTO_TCP, nfs_callback_set_tcpport,
> > -							SVC_SOCK_ANONYMOUS);
> > +	ret = svc_create_xprt(serv, "tcp", nfs_callback_set_tcpport,
> > +			      SVC_SOCK_ANONYMOUS);
> >  	if (ret <= 0)
> >  		goto out_destroy;
> >  	nfs_callback_tcpport = ret;
> 
> Looks like svc_makesock returned a port number, where svc_create_xprt
> returns a 0 or -ERRNO.  This is breaking nfsv4 callbacks.
> 

Bruce:

Yikes! I missed that. My inclination is to have this port number pulled
from xpt_local in the svc_xprt structure. What do you think?

Tom

> --b.


-------------------------------------------------------------------------
This SF.net email is sponsored by: Splunk Inc.
Still grepping through log files to find problems?  Stop.
Now Search log events and configuration files using AJAX and a browser.
Download your FREE copy of Splunk now >> http://get.splunk.com/
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
