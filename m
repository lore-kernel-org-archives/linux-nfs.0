From: Tom Tucker <tom@opengridcomputing.com>
Subject: Re: [RFC,
	PATCH 20/20] knfsd: create listener via portlist	write
Date: Tue, 10 Jul 2007 20:04:15 -0500
Message-ID: <1184115855.30033.98.camel@trinity.ogc.int>
References: <20070710052711.28979.70843.stgit@dell3.ogc.int>
	<20070710053502.28979.32613.stgit@dell3.ogc.int>
	<1184110606.6480.44.camel@heimdal.trondhjem.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: nfs@lists.sourceforge.net
To: Trond Myklebust <trond.myklebust@fys.uio.no>
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.91]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1I8QeE-0001rm-J5
	for nfs@lists.sourceforge.net; Tue, 10 Jul 2007 18:05:48 -0700
Received: from rrcs-71-42-183-126.sw.biz.rr.com ([71.42.183.126]
	helo=smtp.opengridcomputing.com)
	by mail.sourceforge.net with esmtp (Exim 4.44) id 1I8QeH-0001EP-P0
	for nfs@lists.sourceforge.net; Tue, 10 Jul 2007 18:05:46 -0700
In-Reply-To: <1184110606.6480.44.camel@heimdal.trondhjem.org>
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

[...snip...]

> > +	/* This implements the ability to add a transport by writing
> > +	 * it's transport name to the portlist file
> > +	 */
> > +	if (isalnum(buf[0])) {
> > +		int err;
> > +		char transport[16];
> > +		int port;
> > +		sscanf(buf, "%15s %4d", transport, &port);
> 
> Hmm... This looks dodgy to me. You are not initialising transport and
> port nor even checking the return value of sscanf()?
> 

Agreed, lazy code, but I think all I should do here is check that sscanf
got two parameters that met the format spec, i.e. no need to initialize
the port and transport variables.

> > +		err = nfsd_create_serv();
> > +		if (!err)
> > +			err = svc_create_svcsock(nfsd_serv,
> > +						 transport, port,
> > +						 SVC_SOCK_ANONYMOUS);
> > +		return err < 0 ? err : 0;
> > +	}
> > +	
> >  	return -EINVAL;
> >  }
> >  
> > 
> > -------------------------------------------------------------------------
> > This SF.net email is sponsored by DB2 Express
> > Download DB2 Express C - the FREE version of DB2 express and take
> > control of your XML. No limits. Just data. Click to get it now.
> > http://sourceforge.net/powerbar/db2/
> > _______________________________________________
> > NFS maillist  -  NFS@lists.sourceforge.net
> > https://lists.sourceforge.net/lists/listinfo/nfs
> 


-------------------------------------------------------------------------
This SF.net email is sponsored by DB2 Express
Download DB2 Express C - the FREE version of DB2 express and take
control of your XML. No limits. Just data. Click to get it now.
http://sourceforge.net/powerbar/db2/
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
