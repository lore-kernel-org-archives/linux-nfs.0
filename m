From: Tom Tucker <tom@opengridcomputing.com>
Subject: Re: [RFC,
	PATCH] svc: Modify svc_create_xprt to return local port
Date: Tue, 09 Oct 2007 21:28:17 -0500
Message-ID: <1191983297.16714.14.camel@trinity.ogc.int>
References: <20071009225253.25816.36183.stgit@dell3.ogc.int>
	<20071010023540.GB20690@sgi.com>
Reply-To: tom@opengridcomputing.com
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: neilb@suse.de, bfields@fieldses.org, nfs@lists.sourceforge.net
To: Greg Banks <gnb@sgi.com>
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.91]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1IfRKF-00053Z-LR
	for nfs@lists.sourceforge.net; Tue, 09 Oct 2007 19:29:31 -0700
Received: from 209-198-142-2-host.prismnet.net ([209.198.142.2]
	helo=smtp.opengridcomputing.com)
	by mail.sourceforge.net with esmtp (Exim 4.44) id 1IfRKI-0005x9-OG
	for nfs@lists.sourceforge.net; Tue, 09 Oct 2007 19:29:37 -0700
In-Reply-To: <20071010023540.GB20690@sgi.com>
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

On Wed, 2007-10-10 at 12:35 +1000, Greg Banks wrote:
> On Tue, Oct 09, 2007 at 05:52:53PM -0500, Tom Tucker wrote:
> > 
> > Please take this version of the patch. The previous version has a
> > whitespace issue. Sorry for the inconvenience.
> > 
> > This patch fixes a regression introduced by the svc transport
> > switch as follows:
> > 
> > - Listening endpoints need to have their local address set properly. 
> > 
> > - svc_create_xprt needs to return the local port number since the
> >   the nfs4 callback service uses the return value to determine the 
> >   local port elected by the transport when binding to zero.
> > 
> > [...]
> > --- a/net/sunrpc/svcsock.c
> > +++ b/net/sunrpc/svcsock.c
> > @@ -1278,6 +1278,8 @@ svc_create_socket(struct svc_serv *serv,
> >  	int		error;
> >  	int		type;
> >  	char		buf[RPC_MAX_ADDRBUFLEN];
> > +	struct sockaddr	newsin;
> > +	int		newlen;
> 
> Struct sockaddr isn't big enough for this to work with ipv6,
> use struct sockaddr_storage.  Or do the kernel_getsockname()
> driectly into xprt->xpt_local.

I think this is preferred. Thanks Greg.

> 
> Greg.


-------------------------------------------------------------------------
This SF.net email is sponsored by: Splunk Inc.
Still grepping through log files to find problems?  Stop.
Now Search log events and configuration files using AJAX and a browser.
Download your FREE copy of Splunk now >> http://get.splunk.com/
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
