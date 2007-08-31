From: Trond Myklebust <trond.myklebust@fys.uio.no>
Subject: Re: [RFC] [PATCH] rpcbind netid declared per-transport
Date: Fri, 31 Aug 2007 11:13:48 -0400
Message-ID: <1188573228.6649.100.camel@heimdal.trondhjem.org>
References: <EXNANE01Mb1s7nlT2Nq00000219@exnane01.hq.netapp.com>
	<46D820F8.6040309@oracle.com>
	<1188570399.6649.83.camel@heimdal.trondhjem.org>
	<46D825EB.90801@oracle.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: nfs@lists.sourceforge.net,
	"Talpey, Thomas" <Thomas.Talpey@netapp.com>
To: chuck.lever@oracle.com
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.92]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1IR8UE-0007I7-Pj
	for nfs@lists.sourceforge.net; Fri, 31 Aug 2007 08:32:43 -0700
Received: from pat.uio.no ([129.240.10.15])
	by mail.sourceforge.net with esmtps (TLSv1:AES256-SHA:256)
	(Exim 4.44) id 1IR8C6-0001ie-Pt
	for nfs@lists.sourceforge.net; Fri, 31 Aug 2007 08:14:00 -0700
In-Reply-To: <46D825EB.90801@oracle.com>
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

On Fri, 2007-08-31 at 10:30 -0400, Chuck Lever wrote:
> Trond Myklebust wrote:
> > On Fri, 2007-08-31 at 10:08 -0400, Chuck Lever wrote:
> > 
> >>>  
> >>> +/*
> >>> + * RFC1833/RFC3530 rpcbind (v3+) well-known netid's.
> >>> + */
> >>> +#define	RPCB_NETID_UDP	"\165\144\160"		/* "udp" */
> >>> +#define	RPCB_NETID_TCP	"\164\143\160"		/* "tcp" */
> >>> +#define	RPCB_NETID_UDP6	"\165\144\160\066"	/* "udp6" */
> >>> +#define	RPCB_NETID_TCP6	"\164\143\160\066"	/* "tcp6" */
> > 
> > BTW: Any reason why we are using escaped octal instead of plain ascii
> > here?
> 
> Is there a guarantee that these C strings will be US-ASCII on *every* 
> platform in every locale on which Linux kernels are built?  Z-series, 
> for example?
> 
> If yes, then we can use a normal string.

I don't understand your reasoning. Are you expecting someone to be
converting our source code into EBCDIC?

The basic character set of C is US-ASCII. Even if you are cross
compiling from a EBCDIC computer, the source code will be in US-ASCII.

You might have somebody convert all the strings in the kernel into
EBCDIC, just for fun, but that will make the strings unreadable on the
computer running the resulting kernel ('cos Linux uses ASCII) and would
likely break all sorts of kernel-userspace interfaces besides breaking
this little snippet in the rpcbind code.

Trond


-------------------------------------------------------------------------
This SF.net email is sponsored by: Splunk Inc.
Still grepping through log files to find problems?  Stop.
Now Search log events and configuration files using AJAX and a browser.
Download your FREE copy of Splunk now >>  http://get.splunk.com/
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
