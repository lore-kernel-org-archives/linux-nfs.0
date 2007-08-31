From: Trond Myklebust <trond.myklebust@fys.uio.no>
Subject: Re: [RFC] [PATCH] rpcbind netid declared per-transport
Date: Fri, 31 Aug 2007 10:26:39 -0400
Message-ID: <1188570399.6649.83.camel@heimdal.trondhjem.org>
References: <EXNANE01Mb1s7nlT2Nq00000219@exnane01.hq.netapp.com>
	<46D820F8.6040309@oracle.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: nfs@lists.sourceforge.net,
	"Talpey, Thomas" <Thomas.Talpey@netapp.com>
To: chuck.lever@oracle.com
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.91]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1IR7TH-0008SJ-7r
	for nfs@lists.sourceforge.net; Fri, 31 Aug 2007 07:27:39 -0700
Received: from pat.uio.no ([129.240.10.15])
	by mail.sourceforge.net with esmtps (TLSv1:AES256-SHA:256)
	(Exim 4.44) id 1IR7TK-00054G-Fg
	for nfs@lists.sourceforge.net; Fri, 31 Aug 2007 07:27:43 -0700
In-Reply-To: <46D820F8.6040309@oracle.com>
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

On Fri, 2007-08-31 at 10:08 -0400, Chuck Lever wrote:

> >  
> > +/*
> > + * RFC1833/RFC3530 rpcbind (v3+) well-known netid's.
> > + */
> > +#define	RPCB_NETID_UDP	"\165\144\160"		/* "udp" */
> > +#define	RPCB_NETID_TCP	"\164\143\160"		/* "tcp" */
> > +#define	RPCB_NETID_UDP6	"\165\144\160\066"	/* "udp6" */
> > +#define	RPCB_NETID_TCP6	"\164\143\160\066"	/* "tcp6" */

BTW: Any reason why we are using escaped octal instead of plain ascii
here?

Trond


-------------------------------------------------------------------------
This SF.net email is sponsored by: Splunk Inc.
Still grepping through log files to find problems?  Stop.
Now Search log events and configuration files using AJAX and a browser.
Download your FREE copy of Splunk now >>  http://get.splunk.com/
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
